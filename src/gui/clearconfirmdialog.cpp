// clearconfirmdialog.cpp
#include "clearconfirmdialog.hpp"

ClearConfirmDialog::ClearConfirmDialog(QWidget* parent)
    : CustomDialog("Clear All Downloads", parent)
{
    setupContent();

    auto noButton = new QPushButton("No", this);
    noButton->setFlat(true);
    connect(noButton, &QPushButton::clicked, this, &QDialog::reject);

    auto yesButton = new QPushButton("Yes", this);
    connect(yesButton, &QPushButton::clicked, this, &QDialog::accept);

    addButton(noButton);
    addButton(yesButton);

    setFixedWidth(400);
}

void ClearConfirmDialog::setupContent() {
    auto contentLayout = new QVBoxLayout(contentWidget);
    contentLayout->setContentsMargins(20, 20, 20, 20);

    auto messageLabel = new QLabel("Are you sure you want to clear all downloads?", contentWidget);
    messageLabel->setWordWrap(true);
    contentLayout->addWidget(messageLabel);
}
