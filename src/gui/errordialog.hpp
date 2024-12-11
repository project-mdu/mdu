// errordialog.h
#pragma once

#include "customdialog.hpp"

class ErrorDialog : public CustomDialog {
    Q_OBJECT

public:
    explicit ErrorDialog(const QString& error, QWidget* parent = nullptr);

private:
    void setupContent();
    QString errorMessage;
};
