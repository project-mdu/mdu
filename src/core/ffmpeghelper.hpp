#ifndef FFMPEGHELPER_HPP
#define FFMPEGHELPER_HPP

#include <QString>
#include <QObject>
#include <QProcess>
#include <QMap>
#include <QJsonArray>
#include <QStringList>
#include <QCoreApplication>

struct EncodingSettings {
    // Video settings
    QString videoCodec;
    QString preset;
    int crf;
    QString resolution;
    int customWidth;
    int customHeight;
    QString fps;

    // Audio settings
    QString audioCodec;
    QString bitrate;
    QString sampleRate;
    QString channels;
};

class FFmpegHelper : public QObject {
    Q_OBJECT

public:
    explicit FFmpegHelper(QObject* parent = nullptr);
    ~FFmpegHelper();

    // Initialize FFmpeg paths and check availability
    bool initialize();

    // Check if FFmpeg is available
    bool isAvailable() const;

    // Get FFmpeg version
    QString getVersion() const;

    // Get media information
    bool getMediaInfo(const QString& inputFile, QMap<QString, QString>& mediaInfo);

    // Convert media with specified settings
    bool convertMedia(const QString& inputFile,
                      const QString& outputFile,
                      const EncodingSettings& settings);

    // Generate FFmpeg command from settings
    QString generateCommand(const QString& inputFile,
                            const QString& outputFile,
                            const EncodingSettings& settings) const;

    // Stop current conversion
    void stopConversion();

signals:
    void conversionProgress(int percentage);
    void conversionStarted();
    void conversionFinished(bool success);
    void conversionError(const QString& error);
    void logMessage(const QString& message);

private:
    bool findFFmpegPath();
    QString getFfmpegCodecString(const QString& codec) const;
    QString calculateProgress(const QString& line, qint64 duration);
    void parseFFmpegOutput(const QString& output);

    QString m_ffmpegPath;
    QString m_ffprobePath;
    QProcess* m_process;
    bool m_initialized;
    qint64 m_totalDuration;

    // Codec mapping
    const QMap<QString, QString> m_videoCodecMap {
        {"H.264/AVC", "libx264"},
        {"H.265/HEVC", "libx265"},
        {"VP9", "libvpx-vp9"},
        {"AV1", "libaom-av1"}
    };

    const QMap<QString, QString> m_audioCodecMap {
        {"AAC", "aac"},
        {"Opus", "libopus"},
        {"MP3", "libmp3lame"},
        {"FLAC", "flac"}
    };
};

#endif // FFMPEGHELPER_HPP
