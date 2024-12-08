#pragma once

#include <QWidget>
#include <QQuickView>
#include <QQmlEngine>
#include "windowcontroller.hpp"
#include "core/downloadmanager.hpp"

class MainWindow : public QWidget
{
    Q_OBJECT

public:
    explicit MainWindow(QWidget *parent = nullptr);  // Constructor
    ~MainWindow() override = default;               // Destructor

protected:
    // Handles window resizing and state changes
    void resizeEvent(QResizeEvent *event) override;
    void changeEvent(QEvent *event) override;

private:
    // Helper functions
    void setupWindow();  // Configures the main window properties
    void setupQml();     // Sets up the QML environment

    // Member variables
    QQuickView *m_quickView;         // Container for QML view
    QQmlEngine *m_engine;           // QML engine for managing QML components
    WindowController *m_windowController;  // Controller for window state and interaction
    DownloadManager *m_downloadManager;    // Manager for handling downloads
    QWidget *m_quickWidget;         // Embeds QQuickView in the main window
};
