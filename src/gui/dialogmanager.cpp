// utils/dialogmanager.cpp
#include "dialogmanager.hpp"
#include "confirmdialog.hpp"
#include "errordialog.hpp"
#include "clearconfirmdialog.hpp"
#include <QJSEngine>

DialogManager::DialogManager(QWidget* parent)
    : QObject(parent)
    , m_parentWidget(parent)
{
}

void DialogManager::showConfirmation(const QString& title, const QString& message)
{
    ConfirmDialog dialog(message, m_parentWidget);
    dialog.setWindowTitle(title);
    dialog.exec();
}

void DialogManager::showError(const QString& title, const QString& message)
{
    ErrorDialog dialog(message, m_parentWidget);
    dialog.setWindowTitle(title);
    dialog.exec();
}

void DialogManager::showClearConfirmation(const QJSValue& callback)
{
    ClearConfirmDialog dialog(m_parentWidget);
    if (dialog.exec() == QDialog::Accepted && callback.isCallable()) {
        callback.call();
    }
}
