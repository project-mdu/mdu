// aboutqt.cpp
#include "aboutqt.hpp"
#include <QMessageBox>
#include <QPixmap>

namespace AboutQt {

void showDialog(QWidget* parent)
{
    QString translatedTextAboutQtCaption;
    translatedTextAboutQtCaption = QObject::tr("<h3>About Qt</h3>"
                                               "<p>This program uses Qt version %1.</p>").arg(QLatin1String(QT_VERSION_STR));

    QString translatedTextAboutQtText;
    translatedTextAboutQtText = QObject::tr(
                                    "<p>Qt is a C++ toolkit for cross-platform application development.</p>"
                                    "<p>Qt provides single-source portability across all major desktop operating systems. "
                                    "It is also available for embedded Linux and other embedded and mobile operating systems.</p>"
                                    "<p>Qt is available under multiple licensing options designed to accommodate the needs of our various users.</p>"
                                    "<p>Qt licensed under our commercial license agreement is appropriate for development of proprietary/commercial "
                                    "software where you do not want to share any source code with third parties or otherwise cannot comply with the "
                                    "terms of GNU (L)GPL.</p>"
                                    "<p>Qt licensed under GNU (L)GPL is appropriate for the development of Qt applications provided you can comply "
                                    "with the terms and conditions of the respective licenses.</p>"
                                    "<p>Please see <a href=\"http://%2/\">%2</a> for an overview of Qt licensing.</p>"
                                    "<p>Copyright (C) %3 The Qt Company Ltd. and other contributors.</p>"
                                    "<p>Qt and the Qt logo are trademarks of The Qt Company Ltd.</p>"
                                    "<p>Qt is The Qt Company Ltd. product developed as an open source project. "
                                    "See <a href=\"http://%4/\">%4</a> for more information.</p>")
                                    .arg(QLatin1String("6.8.0"),
                                         QLatin1String("qt.io/licensing"),
                                         QLatin1String("2024"),
                                         QLatin1String("qt.io"));


    // Create and show the QMessageBox
    QMessageBox msgBox(parent);
    msgBox.setWindowTitle(QObject::tr("About Qt"));
    msgBox.setText(translatedTextAboutQtCaption);
    msgBox.setInformativeText(translatedTextAboutQtText);

    // Set the Qt logo as the icon
    QPixmap pm(QLatin1String(":/image/qtlogo.png"));
    if (pm.isNull()) {
        qDebug() << "Failed to load Qt logo";
    } else {
        qDebug() << "Successfully loaded Qt logo";
    }
    msgBox.setIconPixmap(pm);
    msgBox.exec();
}

}  // namespace AboutQt
