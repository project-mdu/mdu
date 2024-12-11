// confirmdialog.h
#pragma once

#include "customdialog.hpp"

class ConfirmDialog : public CustomDialog {
    Q_OBJECT

public:
    explicit ConfirmDialog(const QString& message, QWidget* parent = nullptr);

private:
    void setupContent();
};
