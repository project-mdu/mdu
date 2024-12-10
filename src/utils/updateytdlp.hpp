#ifndef UPDATEYTDLP_HPP
#define UPDATEYTDLP_HPP

#include <QDialog>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QLabel>
#include <QProgressBar>
#include <QPushButton>
#include <QVBoxLayout>

class UpdateYtDlp : public QDialog {
    Q_OBJECT

public:
    explicit UpdateYtDlp(QWidget* parent = nullptr);
    ~UpdateYtDlp();

signals:
    void updateFinished(bool success);

private slots:
    void startUpdate();
    void updateProgress(qint64 bytesReceived, qint64 bytesTotal);
    void handleUpdateFinished();
    void handleError(QNetworkReply::NetworkError error);

private:
    void setupUI();
    QString getYtDlpPath() const;
    bool backupCurrentVersion() const;
    bool restoreBackupVersion() const;
    void applyStyle();

    QLabel* m_statusLabel;
    QProgressBar* m_progressBar;
    QPushButton* m_cancelButton;
    QNetworkAccessManager* m_networkManager;
    QNetworkReply* m_currentReply;
    QString m_downloadUrl;
};

#endif // UPDATEYTDLP_HPP
