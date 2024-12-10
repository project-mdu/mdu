#include "encoderoption.h"
#include "ui_encoderoption.h"

EncoderOption::EncoderOption(QWidget *parent)
    : QWidget(parent)
    , ui(new Ui::EncoderOption)
{
    ui->setupUi(this);
}

EncoderOption::~EncoderOption()
{
    delete ui;
}
