// clearconfirmdialog.h
#pragma once

#include "customdialog.hpp"

class ClearConfirmDialog : public CustomDialog {
    Q_OBJECT

public:
    explicit ClearConfirmDialog(QWidget* parent = nullptr);

private:
    void setupContent();
};
