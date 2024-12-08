// windowcontroller.cpp
#include "windowcontroller.hpp"

WindowController::WindowController(QWidget* window, QObject *parent)
    : QObject(parent)
    , m_window(window)
{
    // Connect the aboutQtRequested signal to the showAboutQt slot
    connect(this, &WindowController::aboutQtRequested,
            this, &WindowController::showAboutQt);
}

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

void WindowController::showAboutQt()
{
    AboutQt::showDialog(m_window);  // Simply call the namespace function
}
