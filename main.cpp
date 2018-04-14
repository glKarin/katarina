#include "qutility.h"
#include "qnetworkmanager.h"
#include "declarativewebview.h"
#include "qstd.h"
#include "glwidget.h"

#include "katarinaapplicationviewer.h"
#include <QScopedPointer>
#include <QApplication>
#include <QLocale>
#include <QTranslator>
#include <QDeclarativeEngine>
#include <QDeclarativeContext>
#include <QDir>
#include <QDebug>

Q_DECL_EXPORT int main(int argc, char *argv[])
{
	QApplication *a = createApplication(argc, argv);
	a -> setApplicationName(KATARINA_Q_APPLICATION_NAME);
	a -> setOrganizationName(KATARINA_Q_APPLICATION_DEVELOPER);
	/*
	a->setApplicationVersion(APPLICATION_VERSION);
	QTextCodec::setCodecForCStrings(QTextCodec::codecForName("UTF-8"));

	QWebSettings::enablePersistentStorage();
	QScopedPointer<QApplication> app(a);

	qmlRegisterType<QDeclarativeWebView>("VerenaWebKit", 1, 0, "VWebView");
	qmlRegisterType<QDeclarativeWebSettings>();
	qmlRegisterType<VVideoPlayer>("karin.verena",1,5,"VPlayer");

	QmlApplicationViewer viewer;
	viewer.setOrientation(QmlApplicationViewer::ScreenOrientationAuto);

	VDeclarativeNetworkAccessManagerFactory factory;
	QDeclarativeEngine *engine = viewer.engine();
	engine -> setNetworkAccessManagerFactory(&factory);
	VUT vut(engine);
	viewer.rootContext() -> setContextProperty("vut", &vut);
	*/
	qmlRegisterType<QDeclarativeWebView>("KatarinaWebKit", 1, 0, "KatarinaWebView");
	qmlRegisterType<QDeclarativeWebSettings>();
	//qmlRegisterType<GLWidget>("GLWidget", 1, 0, "GLModelViewer");

	QScopedPointer<QApplication> app(a);

	QTranslator translator;
#ifdef _KATARINA_Q_WITHOUT_SDK
	QString dir = "/i18n";
#else
	QString dir = "/../i18n";
#endif
	QString path = QDir::cleanPath(qApp -> applicationDirPath() + dir);
	//qDebug()<<path;
	if(translator.load("katarina_zh_CN.qm", path))
	{
		QString locale = QLocale::system().name();

		a -> installTranslator(&translator);
	}

	KatarinaApplicationViewer viewer;
	GLWidget glWidget;
	QObject::connect(&viewer, SIGNAL(closing()), &glWidget, SLOT(close()));

	QDeclarativeEngine *engine = viewer.engine();
	katarina::QDeclarativeNetworkManagerFactory factory;
	engine -> setNetworkAccessManagerFactory(&factory);
	katarina::QUtility utility(engine);
	glWidget.setOrientation(static_cast<GLWidget::ScreenOrientation>(utility.getSetting("gl_widget_orientation").toInt()));
	viewer.rootContext() -> setContextProperty("qUtility", &utility);
	viewer.rootContext() -> setContextProperty("qGLModelViewer", &glWidget);

	viewer.setMainQmlFile(QLatin1String("qml/katarina/main.qml"));
	viewer.showExpanded();

	return app -> exec();
}

