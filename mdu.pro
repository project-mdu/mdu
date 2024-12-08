# Basic configuration
TARGET = mdu
TEMPLATE = app
VERSION = 1.0.0

# Qt configuration
QT += core gui quick quickcontrols2 gui-private quickwidgets widgets concurrent
CONFIG += c++17 skip_target_version_ext
CONFIG -= debug_and_release debug_and_release_target

# Define version
DEFINES += APP_VERSION=\\\"$$VERSION\\\"

# Source files
SOURCES += \
    src/core/ytdlphelper.cpp \
    src/gui/aboutqt.cpp \
    src/gui/windowcontroller.cpp \
    src/main.cpp \
    src/gui/mainwindow.cpp \
    src/gui/framelesshelper.cpp \
    src/gui/winnativeeventfilter.cpp \
    src/core/downloadmanager.cpp

# Header files
HEADERS += \
    src/core/downloadmanager.hpp \
    src/core/ytdlphelper.hpp \
    src/gui/aboutqt.hpp \
    src/gui/mainwindow.hpp \
    src/gui/framelesshelper.hpp \
    src/gui/windowcontroller.hpp \
    src/gui/winnativeeventfilter.hpp

# Resources
RESOURCES += resources/shared.qrc

# Include paths
INCLUDEPATH += \
    src \
    src/gui \
    src/core

# Windows specific configuration
win32 {
    # Windows libraries
    LIBS += \
        -luser32 \
        -ldwmapi \
        -lshcore \
        -ld2d1 \
        -luxtheme \
        -lgdi32 \
        -lshell32

    # Windows version definitions
    DEFINES += \
        WINVER=0x0601 \
        _WIN32_WINNT=0x0601 \
        _CRT_SECURE_NO_WARNINGS

    # Icon
    RC_ICONS = resources/icons/ap2.ico
}

# Compiler settings
msvc {
    # MSVC specific flags
    QMAKE_CXXFLAGS_WARN_ON = -W3
    QMAKE_CXXFLAGS -= -W4
    QMAKE_CXXFLAGS += -W3 /MP

    # Optimization flags for release
    QMAKE_CXXFLAGS_RELEASE += /O2 /GL /Zi
    QMAKE_LFLAGS_RELEASE += /LTCG /DEBUG

    # Additional MSVC settings
    QMAKE_LFLAGS += /SUBSYSTEM:WINDOWS
    CONFIG += embed_manifest_exe
    QMAKE_LFLAGS += /MANIFEST:NO
}

gcc {
    QMAKE_CXXFLAGS += -Wall -Wextra -Wpedantic
    QMAKE_CXXFLAGS_RELEASE += -O2
}

# Output directories
CONFIG(debug, debug|release) {
    DESTDIR = $$PWD/build/debug
    OBJECTS_DIR = $$PWD/build/debug/.obj
    MOC_DIR = $$PWD/build/debug/.moc
    RCC_DIR = $$PWD/build/debug/.rcc
    UI_DIR = $$PWD/build/debug/.ui
} else {
    DESTDIR = $$PWD/build/release
    OBJECTS_DIR = $$PWD/build/release/.obj
    MOC_DIR = $$PWD/build/release/.moc
    RCC_DIR = $$PWD/build/release/.rcc
    UI_DIR = $$PWD/build/release/.ui
}

# Default rules for deployment
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

# Qt deployment configuration for Windows
win32 {
    CONFIG(release, debug|release) {
        # Define deployment paths
        DEPLOY_TARGET = $$shell_path($$DESTDIR/$$TARGET.exe)
        DEPLOY_DIR = $$shell_path($$DESTDIR/deploy)

        # Deploy commands
        deploy.commands = \
            @echo Creating deployment directory... && \
            @if not exist \"$$DEPLOY_DIR\" mkdir \"$$DEPLOY_DIR\" && \
            @echo Copying application... && \
            $(COPY_FILE) \"$$DEPLOY_TARGET\" \"$$DEPLOY_DIR\" && \
            @echo Running windeployqt... && \
            windeployqt --release --no-translations --no-system-d3d-compiler \"$$DEPLOY_DIR/$$TARGET.exe\" && \
            @echo Copying additional files... && \
            $(COPY_FILE) \"$$PWD/README.md\" \"$$DEPLOY_DIR\" && \
            $(COPY_FILE) \"$$PWD/LICENSE\" \"$$DEPLOY_DIR\" && \
            @echo Creating version file... && \
            @echo $$VERSION > \"$$DEPLOY_DIR/version.txt\" && \
            @echo Deployment complete!

        # Clean deployment
        deployclean.commands = \
            @if exist \"$$DEPLOY_DIR\" \
            (@echo Cleaning deployment directory... && \
            rmdir /S /Q \"$$DEPLOY_DIR\")

        # Make deploy a dependency
        first.depends = $(first) deploy
        QMAKE_EXTRA_TARGETS += first deploy deployclean
    }
}

# Additional Qt settings
DEFINES += \
    QT_DEPRECATED_WARNINGS \
    QT_MESSAGELOGCONTEXT \
    QT_USE_QSTRINGBUILDER \
    QT_ENABLE_HIGHDPI_SCALING

# Project files
DISTFILES += \
    .gitignore \
    README.md \
    LICENSE
