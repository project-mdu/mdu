// windowcontroller.hpp
#pragma once

#include <QObject>
#include <QWindow>
#include <QWidget>
#include "aboutqt.hpp"  // Add this include

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

signals:
    void isMaximizedChanged();
    void isActiveChanged();
    void newDownloadRequested();
    void importLinksRequested();
    void exportHistoryRequested();
    void settingsRequested();
    void clearHistoryRequested();
    void updateYtDlpRequested();
    void checkFFmpegRequested();
    void downloadManagerRequested();
    void documentationRequested();
    void checkUpdateRequested();
    void aboutRequested();
    void aboutQtRequested();

private slots:
    void showAboutQt();  // Add this slot

private:
    QWidget* m_window;
};
