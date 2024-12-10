#include "uvrhelper.hpp"
#include <QDir>
#include <QFileInfo>
#include <QStandardPaths>
#include <QCoreApplication>
#include <QDebug>

UVRHelper::UVRHelper(QObject *parent)
    : QObject(parent)
    , m_process(new QProcess(this))
    , m_isProcessing(false)
{
    initializePaths();
    setupProcessConnections();
}

UVRHelper::~UVRHelper()
{
    if (m_process->state() == QProcess::Running) {
        m_process->terminate();
        m_process->waitForFinished(3000);
        if (m_process->state() == QProcess::Running) {
            m_process->kill();
        }
    }
}

void UVRHelper::initializePaths()
{
    // Get base application directory
    QString baseDir = QCoreApplication::applicationDirPath();

#ifdef Q_OS_WIN
        // For Windows, check if we're in a debug/release subdirectory
    QDir dir(baseDir);
    if (dir.dirName().toLower() == "debug" || dir.dirName().toLower() == "release") {
        dir.cdUp();
        baseDir = dir.absolutePath();
    }
#endif

    // Set up CLI path
    m_cliPath = QDir::toNativeSeparators(baseDir + "/plugins/uvr/cli.exe");

    // Set up model path
    m_modelPath = QDir::toNativeSeparators(baseDir + "/models");

    // Set up output path in user's documents directory
    m_outputPath = QDir::toNativeSeparators(
        QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation)
        + "/UVR_Output");

    // Create output directory if it doesn't exist
    QDir().mkpath(m_outputPath);

    // Verify paths exist
    if (!QFile::exists(m_cliPath)) {
        qWarning() << "UVR CLI not found at:" << m_cliPath;
    }

    if (!QDir(m_modelPath).exists()) {
        qWarning() << "UVR models directory not found at:" << m_modelPath;
    }

    // Debug output
    qDebug() << "Base Directory:" << baseDir;
    qDebug() << "UVR CLI Path:" << m_cliPath;
    qDebug() << "Model Path:" << m_modelPath;
    qDebug() << "Output Path:" << m_outputPath;

    // Optional: Verify CLI executable
    QFileInfo cliInfo(m_cliPath);
    if (!cliInfo.isExecutable()) {
        qWarning() << "UVR CLI exists but is not executable:" << m_cliPath;
    }
}

void UVRHelper::setupProcessConnections()
{
    connect(m_process, &QProcess::started, this, [this]() {
        m_isProcessing = true;
        emit processingStarted();
    });

    connect(m_process, &QProcess::readyReadStandardOutput, this, [this]() {
        QString output = QString::fromLocal8Bit(m_process->readAllStandardOutput());
        emit progressUpdate(output);
    });

    connect(m_process, &QProcess::readyReadStandardError, this, [this]() {
        QString error = QString::fromLocal8Bit(m_process->readAllStandardError());
        emit errorOccurred(error);
    });

    connect(m_process, static_cast<void(QProcess::*)(int, QProcess::ExitStatus)>(&QProcess::finished),
            this, [this](int exitCode, QProcess::ExitStatus exitStatus) {
                m_isProcessing = false;
                emit processingFinished(exitCode == 0 && exitStatus == QProcess::NormalExit);
            });
}

bool UVRHelper::checkCliExists() const
{
    return QFileInfo::exists(m_cliPath);
}

bool UVRHelper::processAudio(const QString& inputFile,
                             const QString& modelPath,
                             const QString& outputDir,
                             ArchType archType,
                             ExtractType extractType,
                             DeviceType deviceType,
                             OutputFormat format,
                             int mp3Bitrate)
{
    if (m_isProcessing) {
        emit errorOccurred("Another process is already running");
        return false;
    }

    if (!checkCliExists()) {
        emit errorOccurred("UVR CLI executable not found at: " + m_cliPath);
        return false;
    }

    QString actualModelPath = modelPath.isEmpty() ? m_modelPath : modelPath;
    QString actualOutputDir = outputDir.isEmpty() ? m_outputPath : outputDir;

    // Validate input file
    if (!QFileInfo::exists(inputFile)) {
        emit errorOccurred("Input file does not exist: " + inputFile);
        return false;
    }

    QStringList arguments;
    arguments << "--input" << QDir::toNativeSeparators(inputFile)
              << "--model_path" << QDir::toNativeSeparators(actualModelPath)
              << "--output_dir" << QDir::toNativeSeparators(actualOutputDir)
              << "--arch_type" << getArchTypeString(archType)
              << "--extract_type" << getExtractTypeString(extractType)
              << "--device" << getDeviceTypeString(deviceType)
              << "--format" << getOutputFormatString(format);

    if (format == OutputFormat::MP3) {
        arguments << "--mp3_bitrate" << QString::number(mp3Bitrate);
    }

    qDebug() << "Starting UVR process with arguments:" << arguments;

    m_process->start(m_cliPath, arguments);
    return m_process->waitForStarted();
}

QString UVRHelper::getModelPath() const
{
    return m_modelPath;
}

QString UVRHelper::getOutputPath() const
{
    return m_outputPath;
}

bool UVRHelper::isProcessing() const
{
    return m_isProcessing;
}

QString UVRHelper::getArchTypeString(ArchType type) const
{
    switch (type) {
    case ArchType::VR: return "vr";
    case ArchType::MDX: return "mdx";
    case ArchType::MDX_C: return "mdx_c";
    case ArchType::DEMUCS: return "demucs";
    default: return "mdx";
    }
}

QString UVRHelper::getExtractTypeString(ExtractType type) const
{
    switch (type) {
    case ExtractType::VOCAL: return "vocal";
    case ExtractType::DRUM: return "drum";
    case ExtractType::BASS: return "bass";
    case ExtractType::GUITAR: return "guitar";
    case ExtractType::INSTRUMENT: return "instrument";
    default: return "vocal";
    }
}

QString UVRHelper::getDeviceTypeString(DeviceType type) const
{
    switch (type) {
    case DeviceType::CPU: return "cpu";
    case DeviceType::CUDA: return "cuda";
    default: return "cpu";
    }
}

QString UVRHelper::getOutputFormatString(OutputFormat format) const
{
    switch (format) {
    case OutputFormat::WAV: return "wav";
    case OutputFormat::MP3: return "mp3";
    case OutputFormat::FLAC: return "flac";
    default: return "wav";
    }
}
