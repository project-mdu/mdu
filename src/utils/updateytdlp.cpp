#include "updateytdlp.hpp"
#include <QFile>
#include <QDir>
#include <QCoreApplication>
#include <QMessageBox>
#include <QStandardPaths>
#include <QHBoxLayout>
#include <QSpacerItem>
#include <QStyle>
#include <QApplication>

UpdateYtDlp::UpdateYtDlp(QWidget* parent)
    : QDialog(parent)
    , m_networkManager(new QNetworkAccessManager(this))
    , m_currentReply(nullptr)
{
    setupUI();
    applyStyle();
    startUpdate();
}

UpdateYtDlp::~UpdateYtDlp() {
    if (m_currentReply) {
        m_currentReply->abort();
        m_currentReply->deleteLater();
    }
}

void UpdateYtDlp::setupUI() {
    setWindowTitle(tr("Update yt-dlp"));
    setWindowFlags(windowFlags() & ~Qt::WindowContextHelpButtonHint);
    setFixedSize(400, 200);

    auto mainLayout = new QVBoxLayout(this);
    mainLayout->setSpacing(10);
    mainLayout->setContentsMargins(20, 20, 20, 20);

    // Status Label
    m_statusLabel = new QLabel(tr("Checking for updates..."), this);
    m_statusLabel->setAlignment(Qt::AlignCenter);
    mainLayout->addWidget(m_statusLabel);

    // Progress Bar
    m_progressBar = new QProgressBar(this);
    m_progressBar->setMinimum(0);
    m_progressBar->setMaximum(100);
    m_progressBar->setValue(0);
    mainLayout->addWidget(m_progressBar);

    // Button Layout
    auto buttonLayout = new QHBoxLayout;
    auto spacer = new QSpacerItem(40, 20, QSizePolicy::Expanding, QSizePolicy::Minimum);
    buttonLayout->addSpacerItem(spacer);

    m_cancelButton = new QPushButton(tr("Cancel"), this);
    m_cancelButton->setIcon(style()->standardIcon(QStyle::SP_DialogCancelButton));
    connect(m_cancelButton, &QPushButton::clicked, this, [this]() {
        if (m_currentReply) {
            m_currentReply->abort();
        }
        reject();
    });
    buttonLayout->addWidget(m_cancelButton);

    mainLayout->addLayout(buttonLayout);
    mainLayout->addStretch();
}

void UpdateYtDlp::applyStyle() {
    setStyleSheet(R"(
        QDialog {
            background-color: #2d2d2d;
        }
        QLabel {
            color: #ffffff;
            font-size: 12px;
        }
        QProgressBar {
            border: 1px solid #555555;
            border-radius: 3px;
            background-color: #1e1e1e;
            color: #ffffff;
            text-align: center;
            min-height: 20px;
        }
        QProgressBar::chunk {
            background-color: #0078d4;
            border-radius: 2px;
        }
        QPushButton {
            background-color: #333333;
            border: 1px solid #555555;
            border-radius: 3px;
            color: #ffffff;
            padding: 5px 15px;
            min-width: 80px;
            min-height: 24px;
        }
        QPushButton:hover {
            background-color: #404040;
        }
        QPushButton:pressed {
            background-color: #505050;
        }
    )");
}

void UpdateYtDlp::startUpdate() {
#ifdef Q_OS_WIN
    m_downloadUrl = "https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe";
#else
    m_downloadUrl = "https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp";
#endif

    QNetworkRequest request(m_downloadUrl);
    m_currentReply = m_networkManager->get(request);

    connect(m_currentReply, &QNetworkReply::downloadProgress,
            this, &UpdateYtDlp::updateProgress);
    connect(m_currentReply, &QNetworkReply::finished,
            this, &UpdateYtDlp::handleUpdateFinished);
    connect(m_currentReply, &QNetworkReply::errorOccurred,
            this, &UpdateYtDlp::handleError);
}

void UpdateYtDlp::updateProgress(qint64 bytesReceived, qint64 bytesTotal) {
    if (bytesTotal > 0) {
        int progress = static_cast<int>((bytesReceived * 100) / bytesTotal);
        m_progressBar->setValue(progress);
        m_statusLabel->setText(QString(tr("Downloading update... %1%")).arg(progress));
    }
}

void UpdateYtDlp::handleUpdateFinished() {
    if (!m_currentReply)
        return;

    if (m_currentReply->error() == QNetworkReply::NoError) {
        QByteArray data = m_currentReply->readAll();

        // Backup current version
        if (!backupCurrentVersion()) {
            QMessageBox::warning(this, tr("Update Failed"),
                                 tr("Failed to backup current version."));
            emit updateFinished(false);
            reject();
            return;
        }

        // Save new version
        QString ytdlpPath = getYtDlpPath();
        QFile file(ytdlpPath);
        if (file.open(QIODevice::WriteOnly)) {
            file.write(data);
            file.close();

#ifndef Q_OS_WIN
            // Make executable on Unix-like systems
            QFile::setPermissions(ytdlpPath, QFile::ReadOwner | QFile::WriteOwner |
                                                 QFile::ExeOwner | QFile::ReadGroup |
                                                 QFile::ExeGroup | QFile::ReadOther |
                                                 QFile::ExeOther);
#endif

            m_statusLabel->setText(tr("Update completed successfully!"));
            emit updateFinished(true);
            m_cancelButton->setText(tr("Close"));
            m_progressBar->setValue(100);
        } else {
            if (!restoreBackupVersion()) {
                QMessageBox::critical(this, tr("Critical Error"),
                                      tr("Failed to restore backup version!"));
            }
            QMessageBox::warning(this, tr("Update Failed"),
                                 tr("Failed to save new version."));
            emit updateFinished(false);
            reject();
        }
    }

    m_currentReply->deleteLater();
    m_currentReply = nullptr;
}

void UpdateYtDlp::handleError(QNetworkReply::NetworkError error) {
    if (error == QNetworkReply::OperationCanceledError) {
        m_statusLabel->setText(tr("Update cancelled."));
    } else {
        QString errorMessage = tr("Update failed: %1").arg(m_currentReply->errorString());
        m_statusLabel->setText(errorMessage);
        QMessageBox::warning(this, tr("Update Error"), errorMessage);
    }
    emit updateFinished(false);
}

QString UpdateYtDlp::getYtDlpPath() const {
    QString appPath = QCoreApplication::applicationDirPath();
#ifdef Q_OS_WIN
    return appPath + "/yt-dlp.exe";
#else
    return appPath + "/yt-dlp";
#endif
}

bool UpdateYtDlp::backupCurrentVersion() const {
    QString currentPath = getYtDlpPath();
    QString backupPath = currentPath + ".backup";

    if (QFile::exists(currentPath)) {
        if (QFile::exists(backupPath)) {
            QFile::remove(backupPath);
        }
        return QFile::copy(currentPath, backupPath);
    }
    return true; // No current version to backup
}

bool UpdateYtDlp::restoreBackupVersion() const {
    QString currentPath = getYtDlpPath();
    QString backupPath = currentPath + ".backup";

    if (QFile::exists(backupPath)) {
        if (QFile::exists(currentPath)) {
            QFile::remove(currentPath);
        }
        return QFile::copy(backupPath, currentPath);
    }
    return false;
}
