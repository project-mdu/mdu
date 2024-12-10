#include "downloadbinary.hpp"
#include <QFile>
#include <QDir>
#include <QCoreApplication>
#include <QMessageBox>
#include <QProcess>
#include <QHBoxLayout>
#include <QSpacerItem>
#include <QStyle>
#include <QApplication>

DownloadBinary::DownloadBinary(BinaryType type, QWidget* parent)
    : QDialog(parent)
    , m_networkManager(new QNetworkAccessManager(this))
    , m_currentReply(nullptr)
    , m_type(type)
{
    setupUI();
    applyStyle();
    startDownload();
}

DownloadBinary::~DownloadBinary() {
    if (m_currentReply) {
        m_currentReply->abort();
        m_currentReply->deleteLater();
    }
}

void DownloadBinary::setupUI() {
    QString title = m_type == BinaryType::FFmpeg ? "FFmpeg" : "yt-dlp";
    setWindowTitle(tr("Download %1").arg(title));
    setWindowFlags(windowFlags() & ~Qt::WindowContextHelpButtonHint);
    setFixedSize(400, 200);

    auto mainLayout = new QVBoxLayout(this);
    mainLayout->setSpacing(10);
    mainLayout->setContentsMargins(20, 20, 20, 20);

    // Status Label
    m_statusLabel = new QLabel(tr("Preparing download..."), this);
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

void DownloadBinary::applyStyle() {
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

void DownloadBinary::startDownload() {
    m_downloadUrl = getBinaryUrl();
    QNetworkRequest request(m_downloadUrl);
    m_currentReply = m_networkManager->get(request);

    connect(m_currentReply, &QNetworkReply::downloadProgress,
            this, &DownloadBinary::updateProgress);
    connect(m_currentReply, &QNetworkReply::finished,
            this, &DownloadBinary::handleDownloadFinished);
    connect(m_currentReply, &QNetworkReply::errorOccurred,
            this, &DownloadBinary::handleError);
}

QString DownloadBinary::getBinaryUrl() const {
    if (m_type == BinaryType::FFmpeg) {
#ifdef Q_OS_WIN
        return "https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-win64-gpl.zip";
#else
        return "https://johnvansickle.com/ffmpeg/releases/ffmpeg-release-amd64-static.tar.xz";
#endif
    } else {
#ifdef Q_OS_WIN
        return "https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe";
#else
        return "https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp";
#endif
    }
}

void DownloadBinary::updateProgress(qint64 bytesReceived, qint64 bytesTotal) {
    if (bytesTotal > 0) {
        int progress = static_cast<int>((bytesReceived * 100) / bytesTotal);
        m_progressBar->setValue(progress);
        m_statusLabel->setText(QString(tr("Downloading... %1%")).arg(progress));
    }
}

void DownloadBinary::handleDownloadFinished() {
    if (!m_currentReply)
        return;

    if (m_currentReply->error() == QNetworkReply::NoError) {
        QByteArray data = m_currentReply->readAll();
        QString savePath = getDownloadPath();

        QFile file(savePath);
        if (file.open(QIODevice::WriteOnly)) {
            file.write(data);
            file.close();

            if (isArchive()) {
                m_statusLabel->setText(tr("Extracting archive..."));
                extractArchive(savePath);
            } else {
#ifndef Q_OS_WIN
                // Make executable on Unix-like systems
                QFile::setPermissions(savePath, QFile::ReadOwner | QFile::WriteOwner |
                                                    QFile::ExeOwner | QFile::ReadGroup |
                                                    QFile::ExeGroup | QFile::ReadOther |
                                                    QFile::ExeOther);
#endif
                m_statusLabel->setText(tr("Download completed successfully!"));
                emit downloadFinished(true);
                m_cancelButton->setText(tr("Close"));
            }
        } else {
            QMessageBox::warning(this, tr("Download Failed"),
                                 tr("Failed to save downloaded file."));
            emit downloadFinished(false);
            reject();
        }
    }

    m_currentReply->deleteLater();
    m_currentReply = nullptr;
}

void DownloadBinary::handleError(QNetworkReply::NetworkError error) {
    if (error == QNetworkReply::OperationCanceledError) {
        m_statusLabel->setText(tr("Download cancelled."));
    } else {
        QString errorMessage = tr("Download failed: %1").arg(m_currentReply->errorString());
        m_statusLabel->setText(errorMessage);
        QMessageBox::warning(this, tr("Download Error"), errorMessage);
    }
    emit downloadFinished(false);
}

QString DownloadBinary::getDownloadPath() const {
    QString appPath = QCoreApplication::applicationDirPath();
    if (isArchive()) {
        return appPath + "/" + (m_type == BinaryType::FFmpeg ? "ffmpeg" : "yt-dlp") +
#ifdef Q_OS_WIN
               ".zip";
#else
               ".tar.xz";
#endif
    }
    return appPath + "/" + getBinaryName();
}

QString DownloadBinary::getBinaryName() const {
    if (m_type == BinaryType::FFmpeg) {
#ifdef Q_OS_WIN
        return "ffmpeg.exe";
#else
        return "ffmpeg";
#endif
    } else {
#ifdef Q_OS_WIN
        return "yt-dlp.exe";
#else
        return "yt-dlp";
#endif
    }
}

bool DownloadBinary::isArchive() const {
    return m_type == BinaryType::FFmpeg;
}

void DownloadBinary::extractArchive(const QString& archivePath) {
    QProcess process;
    QStringList args;

#ifdef Q_OS_WIN
    // Use 7zip for Windows
    args << "x" << archivePath << "-o" + QCoreApplication::applicationDirPath();
    process.start("7z", args);
#else
    // Use tar for Unix-like systems
    args << "-xf" << archivePath << "-C" << QCoreApplication::applicationDirPath();
    process.start("tar", args);
#endif

    if (process.waitForFinished()) {
        QFile::remove(archivePath);
        m_statusLabel->setText(tr("Download and extraction completed!"));
        emit downloadFinished(true);
        m_cancelButton->setText(tr("Close"));
    } else {
        QMessageBox::warning(this, tr("Extraction Failed"),
                             tr("Failed to extract the archive."));
        emit downloadFinished(false);
        reject();
    }
}
