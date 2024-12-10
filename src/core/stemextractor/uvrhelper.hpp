#pragma once

#include <QObject>
#include <QProcess>
#include <QString>

class UVRHelper : public QObject
{
    Q_OBJECT

public:
    explicit UVRHelper(QObject *parent = nullptr);
    ~UVRHelper() override;

    // Enums exposed to QML
    enum class ArchType {
        VR,
        MDX,
        MDX_C,
        DEMUCS
    };
    Q_ENUM(ArchType)

    enum class ExtractType {
        VOCAL,
        DRUM,
        BASS,
        GUITAR,
        INSTRUMENT
    };
    Q_ENUM(ExtractType)

    enum class DeviceType {
        CPU,
        CUDA
    };
    Q_ENUM(DeviceType)

    enum class OutputFormat {
        WAV,
        MP3,
        FLAC
    };
    Q_ENUM(OutputFormat)

    // QML-invokable methods
    Q_INVOKABLE bool processAudio(const QString& inputFile,
                                  const QString& modelPath,
                                  const QString& outputDir,
                                  ArchType archType = ArchType::MDX,
                                  ExtractType extractType = ExtractType::VOCAL,
                                  DeviceType deviceType = DeviceType::CPU,
                                  OutputFormat format = OutputFormat::WAV,
                                  int mp3Bitrate = 320);

    Q_INVOKABLE QString getModelPath() const;
    Q_INVOKABLE QString getOutputPath() const;
    Q_INVOKABLE bool isProcessing() const;

signals:
    void processingStarted();
    void processingFinished(bool success);
    void progressUpdate(const QString& message);
    void errorOccurred(const QString& error);

private:
    QString getArchTypeString(ArchType type) const;
    QString getExtractTypeString(ExtractType type) const;
    QString getDeviceTypeString(DeviceType type) const;
    QString getOutputFormatString(OutputFormat format) const;

    QProcess* m_process;
    QString m_cliPath;
    QString m_modelPath;
    QString m_outputPath;
    bool m_isProcessing;

    bool checkCliExists() const;
    void setupProcessConnections();
    void initializePaths();
};
