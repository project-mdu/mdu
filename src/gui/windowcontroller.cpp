// windowcontroller.cpp
#include "windowcontroller.hpp"

WindowController::WindowController(QWidget* window, QObject *parent)
    : QObject(parent)
    , m_window(window)
    , m_updateDialog(nullptr)
    , m_downloadDialog(nullptr)
{
    // Connect signals to slots
    // File menu
    connect(this, &WindowController::newDownloadRequested,
            this, &WindowController::handleNewDownload);
    connect(this, &WindowController::importLinksRequested,
            this, &WindowController::handleImportLinks);
    connect(this, &WindowController::exportHistoryRequested,
            this, &WindowController::handleExportHistory);

    // Edit menu
    connect(this, &WindowController::settingsRequested,
            this, &WindowController::handleSettings);
    connect(this, &WindowController::clearHistoryRequested,
            this, &WindowController::handleClearHistory);

    // Tools menu
    connect(this, &WindowController::updateYtDlpRequested,
            this, &WindowController::handleUpdateYtDlp);
    connect(this, &WindowController::checkFFmpegRequested,
            this, &WindowController::handleCheckFFmpeg);
    connect(this, &WindowController::downloadManagerRequested,
            this, &WindowController::handleDownloadManager);

    // Help menu
    connect(this, &WindowController::documentationRequested,
            this, &WindowController::handleDocumentation);
    connect(this, &WindowController::checkUpdateRequested,
            this, &WindowController::handleCheckUpdate);
    connect(this, &WindowController::aboutQtRequested,
            this, &WindowController::handleAboutQt);
}

// Window control functions
void WindowController::moveWindow()
{
    if (m_window) {
        if (QWindow *handle = m_window->windowHandle()) {
            handle->startSystemMove();
        }
    }
}

void WindowController::maximizeWindow()
{
    if (m_window) {
        if (m_window->isMaximized()) {
            m_window->showNormal();
        } else {
            m_window->showMaximized();
        }
        emit isMaximizedChanged();
    }
}

void WindowController::minimizeWindow()
{
    if (m_window) {
        m_window->showMinimized();
    }
}

void WindowController::closeWindow()
{
    if (m_window) {
        m_window->close();
    }
}

bool WindowController::isMaximized() const
{
    return m_window ? m_window->isMaximized() : false;
}

bool WindowController::isActive() const
{
    return m_window ? m_window->isActiveWindow() : false;
}

// File menu handlers
void WindowController::handleNewDownload()
{
    QMessageBox::information(m_window, tr("New Download"),
                             tr("New download dialog will be implemented here."));
}

void WindowController::handleImportLinks()
{
    QMessageBox::information(m_window, tr("Import Links"),
                             tr("Import links functionality will be implemented here."));
}

void WindowController::handleExportHistory()
{
    QMessageBox::information(m_window, tr("Export History"),
                             tr("Export history functionality will be implemented here."));
}

// Edit menu handlers
void WindowController::handleSettings()
{
    QMessageBox::information(m_window, tr("Settings"),
                             tr("Settings dialog will be implemented here."));
}

void WindowController::handleClearHistory()
{
    auto result = QMessageBox::question(m_window, tr("Clear History"),
                                        tr("Are you sure you want to clear all download history?"),
                                        QMessageBox::Yes | QMessageBox::No);
    if (result == QMessageBox::Yes) {
        // Implement clear history functionality
        QMessageBox::information(m_window, tr("Clear History"),
                                 tr("History cleared successfully."));
    }
}

// Tools menu handlers
void WindowController::handleUpdateYtDlp()
{
    if (!m_updateDialog) {
        m_updateDialog = new UpdateYtDlp(m_window);
        connect(m_updateDialog, &UpdateYtDlp::updateFinished,
                this, [this](bool success) {
                    if (success) {
                        QMessageBox::information(m_window, tr("Update Successful"),
                                                 tr("yt-dlp has been updated successfully."));
                    }
                    m_updateDialog->deleteLater();
                    m_updateDialog = nullptr;
                });
    }
    m_updateDialog->exec();
}

void WindowController::handleCheckFFmpeg()
{
    if (!m_downloadDialog) {
        m_downloadDialog = new DownloadBinary(DownloadBinary::BinaryType::FFmpeg, m_window);
        connect(m_downloadDialog, &DownloadBinary::downloadFinished,
                this, [this](bool success) {
                    if (success) {
                        QMessageBox::information(m_window, tr("Download Successful"),
                                                 tr("FFmpeg has been downloaded and installed successfully."));
                    }
                    m_downloadDialog->deleteLater();
                    m_downloadDialog = nullptr;
                });
    }
    m_downloadDialog->exec();
}

void WindowController::handleDownloadManager()
{
    QMessageBox::information(m_window, tr("Download Manager"),
                             tr("Download manager dialog will be implemented here."));
}

// Help menu handlers
void WindowController::handleDocumentation()
{
    QDesktopServices::openUrl(QUrl("https://docs.uppriez.net/mdu"));
}

void WindowController::handleCheckUpdate()
{
    QMessageBox::information(m_window, tr("Check for Updates"),
                             tr("Update checker will be implemented here."));
}

void WindowController::handleAboutQt()
{
    QMessageBox::aboutQt(m_window, tr("About Qt - Media Downloader Utility"));
}
