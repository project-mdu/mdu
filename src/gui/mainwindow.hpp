// mainwindow.hpp
#pragma once

#include <QWidget>
#include <QQuickView>
#include <QQmlEngine>
#include "windowcontroller.hpp"
#include "core/downloadmanager.hpp"
#include "utils/devicesmanager.hpp"
#include "core/stemextractor/uvrhelper.hpp"
#include "dialogmanager.hpp"  // Add this include
#include "core/ytdlphelper.hpp"  // Add this include


class MainWindow : public QWidget
{
    Q_OBJECT

public:
    explicit MainWindow(QWidget *parent = nullptr);
    ~MainWindow() override = default;

protected:
    void resizeEvent(QResizeEvent *event) override;
    void changeEvent(QEvent *event) override;

private:
    void setupWindow();
    void setupQml();

    QQuickView *m_quickView;
    QQmlEngine *m_engine;
    WindowController *m_windowController;
    DownloadManager *m_downloadManager;
    DeviceManager *m_deviceManager;
    UVRHelper *m_uvrHelper;
    DialogManager *m_dialogManager;  // Add this member
    QWidget *m_quickWidget;
    YtDlpHelper *m_ytDlpHelper;  // Add this member
};
