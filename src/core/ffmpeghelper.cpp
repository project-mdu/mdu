#include "ffmpeghelper.hpp"
#include <QProcess>
#include <QFileInfo>
#include <QDir>
#include <QRegularExpression>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QDebug>

FFmpegHelper::FFmpegHelper(QObject* parent)
    : QObject(parent)
    , m_process(nullptr)
    , m_initialized(false)
    , m_totalDuration(0)
{
    m_process = new QProcess(this);

    connect(m_process, &QProcess::readyReadStandardOutput,
            this, [this]() {
                QString output = QString::fromUtf8(m_process->readAllStandardOutput());
                parseFFmpegOutput(output);
            });

    connect(m_process, &QProcess::readyReadStandardError,
            this, [this]() {
                QString error = QString::fromUtf8(m_process->readAllStandardError());
                parseFFmpegOutput(error);
            });

    connect(m_process, &QProcess::errorOccurred,
            this, [this](QProcess::ProcessError error) {
                emit conversionError(QString("Process error: %1").arg(error));
            });

    connect(m_process, QOverload<int, QProcess::ExitStatus>::of(&QProcess::finished),
            this, [this](int exitCode, QProcess::ExitStatus exitStatus) {
                bool success = (exitCode == 0 && exitStatus == QProcess::NormalExit);
                emit conversionFinished(success);
            });
}

FFmpegHelper::~FFmpegHelper() {
    if (m_process) {
        m_process->kill();
        m_process->waitForFinished();
    }
}

bool FFmpegHelper::initialize() {
    if (m_initialized)
        return true;

    if (!findFFmpegPath())
        return false;

    m_initialized = true;
    return true;
}

bool FFmpegHelper::findFFmpegPath() {
    // Get base application directory
    QString baseDir = QCoreApplication::applicationDirPath();

#ifdef Q_OS_WIN
    // Set paths to FFmpeg executables in the bin directory
    m_ffmpegPath = QDir::toNativeSeparators(baseDir + "/bin/ffmpeg.exe");
    m_ffprobePath = QDir::toNativeSeparators(baseDir + "/bin/ffprobe.exe");
#else
    // Set paths for Unix-like systems
    m_ffmpegPath = QDir::toNativeSeparators(baseDir + "/bin/ffmpeg");
    m_ffprobePath = QDir::toNativeSeparators(baseDir + "/bin/ffprobe");
#endif

    // Check if both executables exist and are executable
    QFileInfo ffmpegInfo(m_ffmpegPath);
    QFileInfo ffprobeInfo(m_ffprobePath);

    if (ffmpegInfo.exists() && ffmpegInfo.isExecutable() &&
        ffprobeInfo.exists() && ffprobeInfo.isExecutable()) {
        qDebug() << "FFmpeg found at:" << m_ffmpegPath;
        qDebug() << "FFprobe found at:" << m_ffprobePath;
        return true;
    }

    qWarning() << "FFmpeg executables not found at:" << m_ffmpegPath;
    emit logMessage("FFmpeg executables not found");
    return false;
}

bool FFmpegHelper::isAvailable() const {
    return m_initialized;
}

QString FFmpegHelper::getVersion() const {
    if (!m_initialized)
        return QString();

    QProcess process;
    process.start(m_ffmpegPath, {"-version"});
    process.waitForFinished();

    QString output = QString::fromUtf8(process.readAllStandardOutput());
    QRegularExpression re("version\\s+(\\S+)\\s+");
    auto match = re.match(output);

    if (match.hasMatch())
        return match.captured(1);

    return QString();
}

bool FFmpegHelper::getMediaInfo(const QString& inputFile, QMap<QString, QString>& mediaInfo) {
    if (!m_initialized)
        return false;

    QProcess process;
    QStringList args;
    args << "-v" << "quiet"
         << "-print_format" << "json"
         << "-show_format"
         << "-show_streams"
         << inputFile;

    process.start(m_ffprobePath, args);
    process.waitForFinished();

    if (process.exitCode() != 0)
        return false;

    QString output = QString::fromUtf8(process.readAllStandardOutput());
    QJsonDocument doc = QJsonDocument::fromJson(output.toUtf8());
    QJsonObject obj = doc.object();

    // Parse format information
    if (obj.contains("format")) {
        QJsonObject format = obj["format"].toObject();
        mediaInfo["duration"] = format["duration"].toString();
        mediaInfo["size"] = format["size"].toString();
        mediaInfo["bitrate"] = format["bit_rate"].toString();
    }

    // Parse stream information
    if (obj.contains("streams")) {
        QJsonArray streams = obj["streams"].toArray();
        for (const QJsonValue& stream : streams) {
            QJsonObject streamObj = stream.toObject();
            QString codecType = streamObj["codec_type"].toString();

            if (codecType == "video") {
                mediaInfo["video_codec"] = streamObj["codec_name"].toString();
                mediaInfo["width"] = QString::number(streamObj["width"].toInt());
                mediaInfo["height"] = QString::number(streamObj["height"].toInt());
                mediaInfo["fps"] = streamObj["r_frame_rate"].toString();
            }
            else if (codecType == "audio") {
                mediaInfo["audio_codec"] = streamObj["codec_name"].toString();
                mediaInfo["sample_rate"] = streamObj["sample_rate"].toString();
                mediaInfo["channels"] = QString::number(streamObj["channels"].toInt());
            }
        }
    }

    return true;
}

bool FFmpegHelper::convertMedia(const QString& inputFile,
                                const QString& outputFile,
                                const EncodingSettings& settings) {
    if (!m_initialized)
        return false;

    // Get input duration for progress calculation
    QMap<QString, QString> mediaInfo;
    if (getMediaInfo(inputFile, mediaInfo)) {
        m_totalDuration = mediaInfo["duration"].toDouble() * 1000; // Convert to milliseconds
    }

    QString command = generateCommand(inputFile, outputFile, settings);
    QStringList args = command.split(' ', Qt::SkipEmptyParts);

    emit conversionStarted();
    m_process->start(m_ffmpegPath, args);

    return true;
}

QString FFmpegHelper::generateCommand(const QString& inputFile,
                                      const QString& outputFile,
                                      const EncodingSettings& settings) const {
    QStringList command;

    // Input file
    command << "-i" << QString("\"%1\"").arg(inputFile);

    // Video settings
    if (!settings.videoCodec.isEmpty()) {
        command << "-c:v" << m_videoCodecMap.value(settings.videoCodec, settings.videoCodec);

        if (settings.videoCodec.contains("264") || settings.videoCodec.contains("265")) {
            command << "-preset" << settings.preset;
            command << "-crf" << QString::number(settings.crf);
        }
    }

    // Resolution
    if (settings.resolution != "Original") {
        if (settings.resolution == "Custom") {
            command << "-vf" << QString("scale=%1:%2")
                                    .arg(settings.customWidth)
                                    .arg(settings.customHeight);
        } else {
            QStringList dims = settings.resolution.split('x');
            if (dims.size() == 2) {
                command << "-vf" << QString("scale=%1:%2")
                                        .arg(dims[0].trimmed())
                                        .arg(dims[1].trimmed());
            }
        }
    }

    // Frame rate
    if (settings.fps != "Original") {
        command << "-r" << settings.fps;
    }

    // Audio settings
    if (!settings.audioCodec.isEmpty()) {
        command << "-c:a" << m_audioCodecMap.value(settings.audioCodec, settings.audioCodec);

        if (!settings.bitrate.isEmpty()) {
            command << "-b:a" << settings.bitrate + "k";
        }

        if (settings.sampleRate != "Original") {
            command << "-ar" << settings.sampleRate.split(' ')[0];
        }

        if (settings.channels != "Original") {
            if (settings.channels == "Mono")
                command << "-ac" << "1";
            else if (settings.channels == "Stereo")
                command << "-ac" << "2";
        }
    }

    // Output file
    command << QString("\"%1\"").arg(outputFile);

    return command.join(" ");
}

void FFmpegHelper::stopConversion() {
    if (m_process && m_process->state() != QProcess::NotRunning) {
        m_process->kill();
    }
}

void FFmpegHelper::parseFFmpegOutput(const QString& output) {
    emit logMessage(output);

    // Parse progress
    QRegularExpression timeRe("time=(\\d+):(\\d+):(\\d+\\.\\d+)");
    auto match = timeRe.match(output);

    if (match.hasMatch()) {
        int hours = match.captured(1).toInt();
        int minutes = match.captured(2).toInt();
        float seconds = match.captured(3).toFloat();

        qint64 currentTime = (hours * 3600 + minutes * 60 + static_cast<qint64>(seconds)) * 1000;
        if (m_totalDuration > 0) {
            int progress = static_cast<int>((currentTime * 100) / m_totalDuration);
            emit conversionProgress(qBound(0, progress, 100));
        }
    }
}
