TEMPLATE = app
TARGET = tweetian

# Application version
VERSION = 1.8.1
DEFINES += APP_VERSION=\\\"$$VERSION\\\"

# Qt Library
QT += network widgets

# Qt Mobility Library
CONFIG += mobility sailfishapp

MOBILITY += feedback location gallery

HEADERS += \
    src/qmlutils.h \
    src/thumbnailcacher.h \
    src/userstream.h \
    src/networkmonitor.h \
    src/imageuploader.h

SOURCES += main.cpp \
    src/qmlutils.cpp \
    src/thumbnailcacher.cpp \
    src/userstream.cpp \
    src/networkmonitor.cpp \
    src/imageuploader.cpp

simulator{
    qml_harmattan.source = qml/tweetian-harmattan
    qml_harmattan.target = qml
    qml_symbian.source = qml/tweetian-symbian
    qml_symbian.target = qml
    DEPLOYMENTFOLDERS = qml_harmattan qml_symbian

    RESOURCES += qml-harmattan.qrc qml-symbian.qrc
}

PKGCONFIG += mlite5
CONFIG += link_pkgconfig

MEEGO_EDITION=harmattan
simulator|contains(MEEGO_EDITION,harmattan){
    include(notifications/notifications.pri)

    splash.files = splash/tweetian-splash-portrait.jpg splash/tweetian-splash-landscape.jpg
    splash.path = /opt/tweetian/splash

#        desktopfile.files = $${TARGET}_harmattan.desktop
#        desktopfile.path = /usr/share/applications

#        icon.files = $${TARGET}80.png
#        icon.path = /usr/share/icons/hicolor/80x80/apps

#    INSTALLS += splash

    HEADERS += src/harmattanutils.h
    SOURCES += src/harmattanutils.cpp
}


contains(MEEGO_EDITION,harmattan){
    QT += dbus
    CONFIG += qdeclarative-boostable shareuiinterface-maemo-meegotouch share-ui-plugin share-ui-common mdatauri
    DEFINES += Q_OS_HARMATTAN
    RESOURCES += qml-harmattan.qrc

    HEADERS += src/tweetianif.h
    SOURCES += src/tweetianif.cpp
}

symbian{
    TARGET.UID3 = 0x2005e90a
    TARGET.CAPABILITY += NetworkServices Location LocalServices ReadUserData WriteUserData
    TARGET.EPOCHEAPSIZE = 0x40000 0x4000000

    CONFIG += qt-components
    vendorinfo += "%{\"Dickson\"}" ":\"Dickson\""
    my_deployment.pkg_prerules = vendorinfo
    DEPLOYMENT += my_deployment
    DEPLOYMENT.display_name = Tweetian
    ICON = Tweetian.svg
    RESOURCES += qml-symbian.qrc

    # Symbian have a different syntax
    DEFINES -= APP_VERSION=\\\"$$VERSION\\\"
    DEFINES += APP_VERSION=\"$$VERSION\"
}

OTHER_FILES += qtc_packaging/debian_harmattan/* \
    i18n/tweetian_*.ts \
    tweetian_harmattan.desktop \
    README.md \
    qml/tweetian-harmattan/*.qml \
    qml/tweetian-harmattan/*.js \
    qml/tweetian-harmattan/MainPageCom/*.qml \
    qml/tweetian-harmattan/Component/*.qml \
    qml/tweetian-harmattan/Delegate/*.qml \
    qml/tweetian-harmattan/Dialog/*.qml \
    qml/tweetian-harmattan/Utils/*js

# Please do not modify the following two lines. Required for deployment.
include(qmlapplicationviewer/qmlapplicationviewer.pri)
qtcAddDeployment()
