#ifndef DOWNLOADBINARY_HPP
#define DOWNLOADBINARY_HPP

#include <QDialog>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QLabel>
#include <QProgressBar>
#include <QPushButton>
#include <QVBoxLayout>

class DownloadBinary : public QDialog {
    Q_OBJECT

public:
    enum class BinaryType {
        FFmpeg,
        YtDlp
    };

    explicit DownloadBinary(BinaryType type, QWidget* parent = nullptr);
    ~DownloadBinary();

signals:
    void downloadFinished(bool success);

private slots:
    void startDownload();
    void updateProgress(qint64 bytesReceived, qint64 bytesTotal);
    void handleDownloadFinished();
    void handleError(QNetworkReply::NetworkError error);
    void extractArchive(const QString& archivePath);

private:
    void setupUI();
    void applyStyle();
    QString getBinaryUrl() const;
    QString getDownloadPath() const;
    QString getBinaryName() const;
    bool isArchive() const;

    QLabel* m_statusLabel;
    QProgressBar* m_progressBar;
    QPushButton* m_cancelButton;
    QNetworkAccessManager* m_networkManager;
    QNetworkReply* m_currentReply;
    BinaryType m_type;
    QString m_downloadUrl;
};

#endif // DOWNLOADBINARY_HPP
