// errordialog.cpp
#include "errordialog.hpp"

ErrorDialog::ErrorDialog(const QString& error, QWidget* parent)
    : CustomDialog("Download Error", parent)
    , errorMessage(error)
{
    setupContent();

    auto okButton = new QPushButton("OK", this);
    connect(okButton, &QPushButton::clicked, this, &QDialog::accept);
    addButton(okButton);

    setFixedWidth(400);
}

void ErrorDialog::setupContent() {
    auto contentLayout = new QVBoxLayout(contentWidget);
    contentLayout->setContentsMargins(20, 20, 20, 20);

    auto messageLabel = new QLabel(errorMessage, contentWidget);
    messageLabel->setWordWrap(true);
    contentLayout->addWidget(messageLabel);
}
