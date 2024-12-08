#include "mainwindow.hpp"
#include <QQmlContext>
#include <QVBoxLayout>
#include <QScreen>
#include <QGuiApplication>
#include <QStyle>
#include <QResizeEvent>
#include <QQuickView>
#include <QWidget>

// Constructor
MainWindow::MainWindow(QWidget *parent)
    : QWidget(parent)
    , m_quickView(new QQuickView)
    , m_engine(m_quickView->engine())
    , m_windowController(new WindowController(this))
    , m_downloadManager(new DownloadManager(this))  // Initialize DownloadManager
{
    setupWindow();
    setupQml();
}

// Setup the main application window
void MainWindow::setupWindow()
{
    setWindowTitle("Media Downloader Utility");
    setWindowFlags(Qt::Window | Qt::FramelessWindowHint);  // Standard window with decorations
    setMinimumSize(800, 600);    // Set a minimum size
    resize(1200, 800);           // Default starting size

    // Center the window on the primary screen
    if (QScreen *screen = QGuiApplication::primaryScreen()) {
        const QRect availableGeometry = screen->availableGeometry();
        setGeometry(QStyle::alignedRect(Qt::LeftToRight, Qt::AlignCenter, size(), availableGeometry));
    }

    // Create and configure QQuickWidget as a child of the main window
    m_quickWidget = QWidget::createWindowContainer(m_quickView, this);
    m_quickWidget->setMinimumSize(800, 600);  // Minimum size for the QML view
    m_quickWidget->setFocusPolicy(Qt::StrongFocus);  // Enable keyboard focus

    // Set up the layout for the main window
    auto layout = new QVBoxLayout(this);
    layout->setContentsMargins(0, 0, 0, 0);
    layout->setSpacing(0);
    layout->addWidget(m_quickWidget);  // Add the QQuickWidget to the layout
}

// Setup QML environment and load QML file
void MainWindow::setupQml()
{
    // Expose C++ objects to QML
    m_quickView->rootContext()->setContextProperty("windowController", m_windowController);
    m_quickView->rootContext()->setContextProperty("downloadManager", m_downloadManager);

    // Add import paths for QML
    m_engine->addImportPath("qrc:/interface");

    // Load the main QML file
    m_quickView->setSource(QUrl("qrc:/interface/RootLayout.qml"));

    // Automatically resize QML content to fit the window
    m_quickView->setResizeMode(QQuickView::SizeRootObjectToView);
}

// Handle window resize events
void MainWindow::resizeEvent(QResizeEvent *event)
{
    QWidget::resizeEvent(event);

    if (m_quickWidget) {
        // Resize the QML container to match the window size
        m_quickWidget->resize(size());
    }
}

// Handle other window state changes
void MainWindow::changeEvent(QEvent *event)
{
    if (event->type() == QEvent::WindowStateChange) {
        emit m_windowController->isMaximizedChanged();  // Signal when maximized
    } else if (event->type() == QEvent::ActivationChange) {
        emit m_windowController->isActiveChanged();     // Signal on activation change
    }

    QWidget::changeEvent(event);  // Pass to base class for default handling
}
