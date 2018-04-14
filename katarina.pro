# Add more folders to ship with the application, here
folder_01.source = qml/katarina
folder_01.target = qml
DEPLOYMENTFOLDERS = folder_01

# Additional import path used to resolve QML modules in Creator's code model
QML_IMPORT_PATH =

symbian:TARGET.UID3 = 0xE14F9767

# Smart Installer package's UID
# This UID is from the protected range and therefore the package will
# fail to install if self-signed. By default qmake uses the unprotected
# range value if unprotected UID is defined for the application and
# 0x2002CCCF value if protected UID is given to the application
#symbian:DEPLOYMENT.installer_header = 0x2002CCCF

# Allow network access on Symbian
symbian:TARGET.CAPABILITY += NetworkServices

# If your application uses the Qt Mobility libraries, uncomment the following
# lines and add the respective components to the MOBILITY variable.
# CONFIG += mobility
# MOBILITY +=

# Speed up launching on MeeGo/Harmattan when using applauncherd daemon
CONFIG += qdeclarative-boostable

# Add dependency to Symbian components
# CONFIG += qt-components

TEMPLATE = app
TARGET = katarina
DEPENDPATH += . qmlapplicationviewer src gl lolking SOIL OpenEXR
INCLUDEPATH += . src gl lolking SOIL OpenEXR
QT += declarative network webkit opengl
QT += declarative network webkit
MOBILITY += multimedia systeminfo
CONFIG += mobility #libtuiclient
DEFINES += _HARMATTAN
LIBS += -lz
# The .cpp file which was generated for your project. Feel free to hack it.
# Input
HEADERS += src/qutility.h \
src/qnetworkmanager.h \
src/declarativewebview.h \
src/katarinaapplicationviewer.h \
src/qstd.h \
lolking/glwidget.h \
lolking/lk_std.h \
lolking/lk_struct.h \
lolking/lk_utility.h \
lolking/mesh_reader.h \
lolking/anim_reader.h \
lolking/model_loader.h \
lolking/texture_reader.h \
lolking/model_loader_task.h \
lolking/gutility.h \
lolking/lk_render.h \
lolking/imath_ext.h \
lolking/g_gui.h \
gl/karin_glu.h \
SOIL/image_DXT.h \
SOIL/stbi_DDS_aug_c.h \
SOIL/image_helper.h \
SOIL/stbi_DDS_aug.h \
SOIL/SOIL.h \
SOIL/stb_image_aug.h \
OpenEXR/IexBaseExc.h \
OpenEXR/ImathMatrix.h \
OpenEXR/ImathExc.h \
OpenEXR/ImathPlatform.h \
OpenEXR/ImathFun.h \
OpenEXR/ImathQuat.h \
OpenEXR/ImathInt64.h \
OpenEXR/ImathShear.h \
OpenEXR/ImathLimits.h \
OpenEXR/ImathVec.h \
OpenEXR/ImathMath.h

SOURCES += main.cpp \
src/qutility.cpp \
src/qnetworkmanager.cpp \
src/declarativewebview.cpp \
SOIL/image_DXT.c \
SOIL/SOIL.c \
SOIL/image_helper.c \
SOIL/stb_image_aug.c \
gl/karin_glu.cpp\
lolking/glwidget.cpp \
lolking/lk_utility.cpp \
lolking/mesh_reader.cpp \
lolking/anim_reader.cpp \
lolking/model_loader.cpp \
lolking/texture_reader.cpp \
lolking/model_loader_task.cpp \
lolking/g_gui.cpp \
lolking/lk_render.cpp \
OpenEXR/IexBaseExc.cpp \
OpenEXR/ImathFun.cpp

contains(MEEGO_EDITION,harmattan){
DEFINES += KATARINA_Q_MAEMO_MEEGOTOUCH_INTERFACES_DEV
CONFIG += qdeclarative-boostable
CONFIG += videosuiteinterface-maemo-meegotouch  #video suite
CONFIG += meegotouch
#splash.files = res/verena_splash.png
#splash.path = /opt/verena/res
folder_js.source = qml/js
folder_js.target = qml
folder_img.source = qml/image
folder_img.target = qml
DEPLOYMENTFOLDERS += folder_js folder_img
#INSTALLS += splash
#CONFIG += debug_and_release

folder_translation.source = i18n
folder_translation.target = .
#icon.files = katarina_80.png
#icon.path = /usr/share/icons/hicolor/80x80/apps
folder_texture.source = texture
folder_texture.target = .
folder_glsl.source = glsl
folder_glsl.target = .
DEPLOYMENTFOLDERS += folder_translation folder_glsl folder_texture
}
# Please do not modify the following two lines. Required for deployment.
include(qmlapplicationviewer/qmlapplicationviewer.pri)
qtcAddDeployment()

OTHER_FILES += \
    qtc_packaging/debian_harmattan/rules \
    qtc_packaging/debian_harmattan/README \
    qtc_packaging/debian_harmattan/manifest.aegis \
    qtc_packaging/debian_harmattan/copyright \
    qtc_packaging/debian_harmattan/control \
    qtc_packaging/debian_harmattan/compat \
    qtc_packaging/debian_harmattan/changelog
