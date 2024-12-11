// customdialog.cpp
#include "customdialog.hpp"

CustomDialog::CustomDialog(const QString& title, QWidget* parent)
    : QDialog(parent)
{
    setWindowTitle(title);
    setupUI();
    setupStyle();
}

void CustomDialog::setupUI() {
    mainLayout = new QVBoxLayout(this);
    mainLayout->setSpacing(0);
    mainLayout->setContentsMargins(0, 0, 0, 0);

    // Header
    headerWidget = new QWidget(this);
    auto headerLayout = new QHBoxLayout(headerWidget);
    headerLayout->setContentsMargins(20, 0, 20, 0);

    titleLabel = new QLabel(windowTitle(), this);
    headerLayout->addWidget(titleLabel);

    mainLayout->addWidget(headerWidget);

    // Content
    contentWidget = new QWidget(this);
    mainLayout->addWidget(contentWidget);

    // Button layout
    buttonLayout = new QHBoxLayout();
    buttonLayout->setContentsMargins(20, 20, 20, 20);
    buttonLayout->addStretch();
    mainLayout->addLayout(buttonLayout);
}

void CustomDialog::setupStyle() {
    setStyleSheet(R"(
        CustomDialog {
            background-color: #252525;
            border: 1px solid #333333;
            border-radius: 8px;
        }
        QWidget#headerWidget {
            background-color: #2d2d2d;
            min-height: 48px;
            border-top-left-radius: 8px;
            border-top-right-radius: 8px;
        }
        QLabel {
            color: #ffffff;
        }
        QPushButton {
            background-color: #0078D4;
            border: none;
            border-radius: 4px;
            color: #ffffff;
            padding: 6px 12px;
            min-width: 80px;
        }
        QPushButton:hover {
            background-color: #1884D9;
        }
        QPushButton:pressed {
            background-color: #006CBE;
        }
        QPushButton[flat="true"] {
            background-color: transparent;
        }
        QPushButton[flat="true"]:hover {
            background-color: rgba(255, 255, 255, 0.1);
        }
    )");

    titleLabel->setStyleSheet("font-size: 16px; font-weight: bold;");
}

void CustomDialog::addButton(QPushButton* button) {
    buttonLayout->addWidget(button);
}
