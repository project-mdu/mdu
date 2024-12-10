#ifndef ENCODEROPTION_H
#define ENCODEROPTION_H

#include <QWidget>

namespace Ui {
class EncoderOption;
}

class EncoderOption : public QWidget
{
    Q_OBJECT

public:
    explicit EncoderOption(QWidget *parent = nullptr);
    ~EncoderOption();

private:
    Ui::EncoderOption *ui;
};

#endif // ENCODEROPTION_H
