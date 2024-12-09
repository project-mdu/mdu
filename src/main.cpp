#include <QApplication>
#include <QQuickStyle>
#include "gui/framelesshelper.hpp"
#include "mainwindow.hpp"
#include "core/stemextractor/stemextractor.hpp"
// #include "utils/devicesmanager.hpp"

int main(int argc, char *argv[]) {
#if (QT_VERSION < QT_VERSION_CHECK(6, 0, 0))
    QGuiApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QGuiApplication::setAttribute(Qt::AA_UseHighDpiPixmaps);
#endif
    QQuickStyle::setStyle("Basic");
    QApplication app(argc, argv);
    app.setOrganizationName("Khaoniewji");
    app.setApplicationName("Media Downloader Utility");

    FramelessHelper helper;

    MainWindow window;
    helper.setFramelessWindows({&window});
    helper.setTitlebarHeight(32);
    window.show();

    return app.exec();
}
