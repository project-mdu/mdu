// confirmdialog.cpp
#include "confirmdialog.hpp"

ConfirmDialog::ConfirmDialog(const QString& message, QWidget* parent)
    : CustomDialog("Download Started", parent)
{
    setupContent();

    auto okButton = new QPushButton("OK", this);
    connect(okButton, &QPushButton::clicked, this, &QDialog::accept);
    addButton(okButton);

    setFixedWidth(400);
}

void ConfirmDialog::setupContent() {
    auto contentLayout = new QVBoxLayout(contentWidget);
    contentLayout->setContentsMargins(20, 20, 20, 20);

    auto messageLabel = new QLabel("Download has been added to the queue", contentWidget);
    messageLabel->setWordWrap(true);
    contentLayout->addWidget(messageLabel);
}
