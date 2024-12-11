#pragma once

#include <QObject>
#include <functional>
#include <QJSEngine>

class DialogManager : public QObject {
    Q_OBJECT

public:
    explicit DialogManager(QWidget* parent = nullptr);

public slots:
    void showConfirmation(const QString& title, const QString& message);
    void showError(const QString& title, const QString& message);
    void showClearConfirmation(const QJSValue& callback);

private:
    QWidget* m_parentWidget;
};
