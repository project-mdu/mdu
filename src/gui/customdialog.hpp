// customdialog.hpp
#pragma once

#include <QDialog>
#include <QLabel>
#include <QPushButton>
#include <QVBoxLayout>

class CustomDialog : public QDialog {
    Q_OBJECT

public:
    explicit CustomDialog(const QString& title, QWidget* parent = nullptr);

protected:
    QVBoxLayout* mainLayout;
    QLabel* titleLabel;
    QWidget* headerWidget;
    QWidget* contentWidget;
    QHBoxLayout* buttonLayout;

    virtual void setupUI();
    virtual void setupStyle();
    void addButton(QPushButton* button);
};
