// core/ytdlphelper.hpp
#pragma once

#include <QObject>
#include <QString>
#include <QRegularExpression>
#include <QProcess>
#include <QMap>
#include <QDateTime>
#include <QDir>
#include <QCoreApplication>

class YtDlpHelper : public QObject {
    Q_OBJECT

public:
    explicit YtDlpHelper(QObject *parent = nullptr);
    ~YtDlpHelper();

    enum class DownloadState {
        Initializing,
        Downloading,
        Processing,
        Completed,
        Error
    };
    Q_ENUM(DownloadState)

    struct DownloadProgress {
        QString filename;
        double percentage = 0.0;
        QString speed;
        QString eta;
        QString filesize;
        QString status;
        QString error;
        QString elapsedTime;
        QDateTime startTime;
        DownloadState state = DownloadState::Initializing;
    };

    QString getYtDlpPath() const { return m_ytDlpPath; }
    bool isYtDlpAvailable() const { return m_ytDlpAvailable; }

public slots:
    void startDownload(const QString& url, const QString& outputPath, const QStringList& options = QStringList());
    void cancelDownload();

signals:
    void progressUpdated(const DownloadProgress& progress);
    void downloadFinished(bool success, const QString& filename);
    void downloadError(const QString& error);

private:
    QProcess* m_process;
    DownloadProgress m_currentProgress;
    QString m_ytDlpPath;
    bool m_ytDlpAvailable;

    // Regular expressions for parsing output
    const QRegularExpression RE_FILENAME{R"(\[download\] Destination: (.+))"};
    const QRegularExpression RE_PROGRESS{R"(\[download\]\s+(\d+\.?\d*)%\s+of\s+~?\s*(\d+\.?\d*)(K|M|G)iB\s+at\s+(\d+\.?\d*)(K|M|G)iB/s\s+ETA\s+(\d+:\d+))"};
    const QRegularExpression RE_PROCESSING{R"(\[(\w+)\]\s+(.+))"};
    const QRegularExpression RE_ERROR{R"(ERROR:\s+(.+))"};

    void initYtDlpPath();
    void verifyYtDlpVersion();
    QString formatFileSize(double size, const QString& unit);
    QString formatDuration(qint64 seconds);
    QString sanitizePath(const QString& path) const;
    QString ensureDirectoryExists(const QString& path) const;
    QString formatOutputTemplate(const QString& basePath, bool isAudioOnly) const;

private slots:
    void handleProcessOutput();
    void handleProcessError(QProcess::ProcessError error);
    void handleProcessFinished(int exitCode, QProcess::ExitStatus exitStatus);
    void parseOutput(const QString& output);
    void updateProgress(const QRegularExpressionMatch& match);
    void handleError(const QString& error);
};
