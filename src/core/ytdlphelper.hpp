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

    /**
     * @brief Download states enumeration
     */
    enum class DownloadState {
        Initializing,    ///< Download is being initialized
        Downloading,     ///< Active download in progress
        Processing,      ///< Post-download processing
        Completed,       ///< Download successfully completed
        Error           ///< Error occurred during download
    };
    Q_ENUM(DownloadState)

    /**
     * @brief Structure to hold download progress information
     */
    struct DownloadProgress {
        QString filename;        ///< Output filename
        double percentage = 0.0; ///< Download progress percentage
        QString speed;          ///< Download speed
        QString eta;            ///< Estimated time remaining
        QString filesize;       ///< Total file size
        QString status;         ///< Current status message
        QString error;          ///< Error message if any
        QString elapsedTime;    ///< Elapsed download time
        QDateTime startTime;    ///< Download start time
        DownloadState state = DownloadState::Initializing;
    };

    /**
     * @brief Get the path to yt-dlp executable
     * @return QString containing the path
     */
    QString getYtDlpPath() const { return m_ytDlpPath; }

    /**
     * @brief Check if yt-dlp is available
     * @return true if yt-dlp is found and executable
     */
    bool isYtDlpAvailable() const { return m_ytDlpAvailable; }

public slots:
    /**
     * @brief Start a download
     * @param url URL to download from
     * @param outputPath Output path template
     * @param options Additional yt-dlp options
     */
    void startDownload(const QString& url, const QString& outputPath, const QStringList& options = QStringList());

    /**
     * @brief Cancel the current download
     */
    void cancelDownload();

signals:
    /**
     * @brief Emitted when download progress is updated
     * @param progress Current download progress information
     */
    void progressUpdated(const DownloadProgress& progress);

    /**
     * @brief Emitted when download is finished
     * @param success Whether download was successful
     * @param filename Final output filename
     */
    void downloadFinished(bool success, const QString& filename);

    /**
     * @brief Emitted when an error occurs
     * @param error Error message
     */
    void downloadError(const QString& error);

private:
    QProcess* m_process;                ///< Process for running yt-dlp
    DownloadProgress m_currentProgress; ///< Current download progress
    QString m_ytDlpPath;               ///< Path to yt-dlp executable
    bool m_ytDlpAvailable;             ///< Whether yt-dlp is available

    // Regular expressions for parsing yt-dlp output
    const QRegularExpression RE_FILENAME{R"(\[download\] Destination: (.+))"};
    const QRegularExpression RE_PROGRESS{R"(\[download\]\s+(\d+\.?\d*)%\s+of\s+~?\s*(\d+\.?\d*)(K|M|G)iB\s+at\s+(\d+\.?\d*)(K|M|G)iB/s\s+ETA\s+(\d+:\d+))"};
    const QRegularExpression RE_PROCESSING{R"(\[(\w+)\]\s+(.+))"};
    const QRegularExpression RE_ERROR{R"(ERROR:\s+(.+))"};

    /**
     * @brief Initialize yt-dlp path and check availability
     */
    void initYtDlpPath();

    /**
     * @brief Verify yt-dlp version
     */
    void verifyYtDlpVersion();

    /**
     * @brief Format file size with appropriate units
     * @param size Size value
     * @param unit Unit (K, M, G)
     * @return Formatted size string
     */
    QString formatFileSize(double size, const QString& unit);

    /**
     * @brief Format duration in seconds to readable string
     * @param seconds Duration in seconds
     * @return Formatted duration string
     */
    QString formatDuration(qint64 seconds);

private slots:
    /**
     * @brief Handle process output
     */
    void handleProcessOutput();

    /**
     * @brief Handle process errors
     * @param error Process error type
     */
    void handleProcessError(QProcess::ProcessError error);

    /**
     * @brief Handle process completion
     * @param exitCode Process exit code
     * @param exitStatus Process exit status
     */
    void handleProcessFinished(int exitCode, QProcess::ExitStatus exitStatus);

private:
    /**
     * @brief Parse yt-dlp output line
     * @param output Output line to parse
     */
    void parseOutput(const QString& output);

    /**
     * @brief Update progress information
     * @param match Regular expression match containing progress information
     */
    void updateProgress(const QRegularExpressionMatch& match);

    /**
     * @brief Handle download error
     * @param error Error message
     */
    void handleError(const QString& error);
};
