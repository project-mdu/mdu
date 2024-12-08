// core/ytdlphelper.cpp
#include "ytdlphelper.hpp"
#include <QDebug>
#include <QFileInfo>
#include <QDateTime>

YtDlpHelper::YtDlpHelper(QObject *parent)
    : QObject(parent)
    , m_process(new QProcess(this))
    , m_ytDlpAvailable(false)
{
    initYtDlpPath();

    connect(m_process, &QProcess::readyReadStandardOutput, this, &YtDlpHelper::handleProcessOutput);
    connect(m_process, &QProcess::readyReadStandardError, this, &YtDlpHelper::handleProcessOutput);
    connect(m_process, &QProcess::errorOccurred, this, &YtDlpHelper::handleProcessError);
    connect(m_process, QOverload<int, QProcess::ExitStatus>::of(&QProcess::finished),
            this, &YtDlpHelper::handleProcessFinished);
}

YtDlpHelper::~YtDlpHelper()
{
    if (m_process->state() != QProcess::NotRunning) {
        m_process->kill();
        m_process->waitForFinished();
    }
}

void YtDlpHelper::initYtDlpPath()
{
    QString appDir = QCoreApplication::applicationDirPath();
    m_ytDlpPath = QDir(appDir).filePath("bin/yt-dlp.exe");

    QFileInfo ytDlpFile(m_ytDlpPath);
    m_ytDlpAvailable = ytDlpFile.exists() && ytDlpFile.isExecutable();

    if (!m_ytDlpAvailable) {
        qWarning() << "yt-dlp not found at:" << m_ytDlpPath;
    } else {
        qDebug() << "yt-dlp found at:" << m_ytDlpPath;
        // Verify version
        verifyYtDlpVersion();
    }
}

void YtDlpHelper::verifyYtDlpVersion()
{
    QProcess versionCheck;
    versionCheck.start(m_ytDlpPath, {"--version"});

    if (versionCheck.waitForFinished(5000)) {
        QString version = QString::fromUtf8(versionCheck.readAllStandardOutput()).trimmed();
        qDebug() << "yt-dlp version:" << version;
    } else {
        qWarning() << "Failed to get yt-dlp version";
    }
}

void YtDlpHelper::startDownload(const QString& url, const QString& outputPath, const QStringList& options)
{
    if (!m_ytDlpAvailable) {
        handleError("yt-dlp.exe not found in bin directory");
        return;
    }

    if (m_process->state() != QProcess::NotRunning) {
        qWarning() << "Download process is already running";
        return;
    }

    // Validate URL
    if (url.isEmpty() || !url.startsWith("http")) {
        handleError("Invalid URL provided");
        return;
    }

    // Prepare output directory
    QFileInfo outputInfo(outputPath);
    QDir outputDir = outputInfo.dir();
    if (!outputDir.exists()) {
        if (!outputDir.mkpath(".")) {
            handleError("Failed to create output directory: " + outputDir.path());
            return;
        }
    }

    QStringList args;
    args << "--progress" << "--newline";
    // Add default options for better output parsing
    args << "--print-json" << "--no-warnings";
    args.append(options);
    args << "-o" << outputPath;
    args << url;

    m_currentProgress = DownloadProgress();
    m_currentProgress.state = DownloadState::Initializing;
    m_currentProgress.startTime = QDateTime::currentDateTime();
    emit progressUpdated(m_currentProgress);

    qDebug() << "Starting download with command:" << m_ytDlpPath << args.join(" ");
    m_process->setWorkingDirectory(outputDir.path());
    m_process->start(m_ytDlpPath, args);
}

void YtDlpHelper::cancelDownload()
{
    if (m_process->state() != QProcess::NotRunning) {
        m_process->kill();
        handleError("Download cancelled by user");
    }
}

void YtDlpHelper::handleProcessOutput()
{
    while (m_process->canReadLine()) {
        QString line = QString::fromUtf8(m_process->readLine()).trimmed();
        if (!line.isEmpty()) {
            parseOutput(line);
        }
    }
}

void YtDlpHelper::parseOutput(const QString& output)
{
    // Check for filename
    QRegularExpressionMatch filenameMatch = RE_FILENAME.match(output);
    if (filenameMatch.hasMatch()) {
        m_currentProgress.filename = QFileInfo(filenameMatch.captured(1)).fileName();
        m_currentProgress.state = DownloadState::Downloading;
        emit progressUpdated(m_currentProgress);
        return;
    }

    // Check for progress
    QRegularExpressionMatch progressMatch = RE_PROGRESS.match(output);
    if (progressMatch.hasMatch()) {
        updateProgress(progressMatch);
        return;
    }

    // Check for processing status
    QRegularExpressionMatch processingMatch = RE_PROCESSING.match(output);
    if (processingMatch.hasMatch()) {
        m_currentProgress.state = DownloadState::Processing;
        m_currentProgress.status = processingMatch.captured(2);
        emit progressUpdated(m_currentProgress);
        return;
    }

    // Check for errors
    QRegularExpressionMatch errorMatch = RE_ERROR.match(output);
    if (errorMatch.hasMatch()) {
        handleError(errorMatch.captured(1));
        return;
    }

    // Log unhandled output for debugging
    qDebug() << "Unhandled yt-dlp output:" << output;
}

void YtDlpHelper::updateProgress(const QRegularExpressionMatch& match)
{
    m_currentProgress.percentage = match.captured(1).toDouble();
    m_currentProgress.filesize = formatFileSize(match.captured(2).toDouble(), match.captured(3));
    m_currentProgress.speed = QString("%1%2iB/s").arg(match.captured(4)).arg(match.captured(5));
    m_currentProgress.eta = match.captured(6);

    // Calculate elapsed time
    qint64 elapsed = m_currentProgress.startTime.secsTo(QDateTime::currentDateTime());
    m_currentProgress.elapsedTime = formatDuration(elapsed);

    // Update status
    m_currentProgress.status = QString("Downloading - %1% at %2 (ETA: %3)")
                                   .arg(m_currentProgress.percentage, 0, 'f', 1)
                                   .arg(m_currentProgress.speed)
                                   .arg(m_currentProgress.eta);

    emit progressUpdated(m_currentProgress);
}

QString YtDlpHelper::formatFileSize(double size, const QString& unit)
{
    return QString("%1 %2iB").arg(size, 0, 'f', 2).arg(unit);
}

QString YtDlpHelper::formatDuration(qint64 seconds)
{
    int hours = seconds / 3600;
    int minutes = (seconds % 3600) / 60;
    int secs = seconds % 60;

    if (hours > 0) {
        return QString("%1:%2:%3")
            .arg(hours, 2, 10, QChar('0'))
            .arg(minutes, 2, 10, QChar('0'))
            .arg(secs, 2, 10, QChar('0'));
    }
    return QString("%1:%2")
        .arg(minutes, 2, 10, QChar('0'))
        .arg(secs, 2, 10, QChar('0'));
}

void YtDlpHelper::handleError(const QString& error)
{
    m_currentProgress.state = DownloadState::Error;
    m_currentProgress.error = error;
    m_currentProgress.status = "Error: " + error;
    emit downloadError(error);
    emit progressUpdated(m_currentProgress);
}

void YtDlpHelper::handleProcessError(QProcess::ProcessError error)
{
    QString errorMessage;
    switch (error) {
    case QProcess::FailedToStart:
        errorMessage = QString("Failed to start yt-dlp at path: %1").arg(m_ytDlpPath);
        break;
    case QProcess::Crashed:
        errorMessage = "The download process crashed";
        break;
    case QProcess::Timedout:
        errorMessage = "The process timed out";
        break;
    case QProcess::WriteError:
        errorMessage = "Failed to write to the process";
        break;
    case QProcess::ReadError:
        errorMessage = "Failed to read from the process";
        break;
    default:
        errorMessage = "An unknown error occurred during download";
    }
    handleError(errorMessage);
}

void YtDlpHelper::handleProcessFinished(int exitCode, QProcess::ExitStatus exitStatus)
{
    if (exitCode == 0 && exitStatus == QProcess::NormalExit) {
        m_currentProgress.state = DownloadState::Completed;
        m_currentProgress.percentage = 100.0;
        m_currentProgress.status = "Download completed";
        emit progressUpdated(m_currentProgress);
        emit downloadFinished(true, m_currentProgress.filename);
    } else if (m_currentProgress.state != DownloadState::Error) {
        QString errorMsg = QString("Download failed with exit code: %1").arg(exitCode);
        if (!m_process->readAllStandardError().isEmpty()) {
            errorMsg += "\n" + QString::fromUtf8(m_process->readAllStandardError());
        }
        handleError(errorMsg);
        emit downloadFinished(false, m_currentProgress.filename);
    }
}
