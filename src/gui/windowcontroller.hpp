// windowcontroller.hpp
#pragma once

#include <QObject>
#include <QWindow>
#include <QWidget>
#include "aboutqt.hpp"
#include "utils/updateytdlp.hpp"
#include "utils/downloadbinary.hpp"
#include <QMessageBox>
#include <QDesktopServices>
#include <QUrl>

class WindowController : public QObject {
    Q_OBJECT
    Q_PROPERTY(bool isMaximized READ isMaximized NOTIFY isMaximizedChanged)
    Q_PROPERTY(bool isActive READ isActive NOTIFY isActiveChanged)

public:
    explicit WindowController(QWidget* window, QObject *parent = nullptr);

    Q_INVOKABLE void moveWindow();
    Q_INVOKABLE void maximizeWindow();
    Q_INVOKABLE void minimizeWindow();
    Q_INVOKABLE void closeWindow();

    bool isMaximized() const;
    bool isActive() const;

public slots:
    // File menu handlers
    void handleNewDownload();
    void handleImportLinks();
    void handleExportHistory();

    // Edit menu handlers
    void handleSettings();
    void handleClearHistory();

    // Tools menu handlers
    void handleUpdateYtDlp();
    void handleCheckFFmpeg();
    void handleDownloadManager();

    // Help menu handlers
    void handleDocumentation();
    void handleCheckUpdate();
    void handleAboutQt();

signals:
    void isMaximizedChanged();
    void isActiveChanged();

    // File menu signals
    void newDownloadRequested();
    void importLinksRequested();
    void exportHistoryRequested();

    // Edit menu signals
    void settingsRequested();
    void clearHistoryRequested();

    // Tools menu signals
    void updateYtDlpRequested();
    void checkFFmpegRequested();
    void downloadManagerRequested();

    // Help menu signals
    void documentationRequested();
    void checkUpdateRequested();
    void aboutRequested();
    void aboutQtRequested();

private:
    QWidget* m_window;
    UpdateYtDlp* m_updateDialog;
    DownloadBinary* m_downloadDialog;
};
