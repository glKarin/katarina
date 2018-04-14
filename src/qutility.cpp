#include <QNetworkAccessManager>
#include <QNetworkConfiguration>
#include <QDeclarativeEngine>
#include <QString>
#include <QSettings>
#include <QProcess>

#include "qutility.h"
#include "qstd.h"

#ifdef KATARINA_Q_MAEMO_MEEGOTOUCH_INTERFACES_DEV
#include <maemo-meegotouch-interfaces/videosuiteinterface.h>
#else
#define KATARINA_Q_VIDEO_SUITE_BIN "/usr/bin/video-suite"
#endif

#define KATARINA_Q_GROB "/usr/bin/grob"

using namespace katarina;

QUtility::QUtility(QDeclarativeEngine *e, QObject *parent)
	: QObject(parent),
	engine(e),
	settings(new QSettings(this))
{
}

QUtility::~QUtility()
{
}

QString QUtility::bearerTypeName() const
{
	if(engine)
		return engine -> networkAccessManager() -> activeConfiguration().bearerTypeName();
	return "2G";
}

QVariant QUtility::getSetting(const QString &name) const
{
	if(!settings -> contains(name))
		settings -> setValue(name, QUtility::GetDefaultSetting(name));
	return settings -> value(name);
}

void QUtility::setSetting(const QString &name, const QVariant &value)
{
	settings -> setValue(name, value);
}

QVariant QUtility::GetDefaultSetting(const QString &name)
{
	static QMap<QString, QVariant> SettingsMap;
	if(!SettingsMap.size())
	{
		SettingsMap.insert("user_name", QVariant(""));
		SettingsMap.insert("user_server_name", QVariant(""));
		SettingsMap.insert("user_server_id", QVariant(""));
		SettingsMap.insert("lock_orientation", QVariant("automatic"));
		SettingsMap.insert("default_player", QVariant("katarina"));
		SettingsMap.insert("gl_widget_orientation", QVariant(1));
	}
	return SettingsMap[name];
}

void QUtility::openHarmattanGrob(const QString &url) const
{
	QStringList arg(url);
	QProcess::startDetached(QString(KATARINA_Q_GROB), arg);
}

void QUtility::openHarmattanVideoSuite(const QString &url) const
{
	QStringList arg(url);
#ifdef KATARINA_Q_MAEMO_MEEGOTOUCH_INTERFACES_DEV
	VideoSuiteInterface player;
	player.play(QStringList(arg));
#else
	QProcess::startDetached(QString(VIDEO_SUITE), arg);
#endif
}

QVariant QUtility::getAppInfo(const QString &name) const
{
	if(name == "app_name")
		return KATARINA_Q_APPLICATION_NAME;
	if(name == "app_developer")
		return KATARINA_Q_APPLICATION_DEVELOPER;
	if(name == "app_version")
		return KATARINA_Q_APPLICATION_VERSION;
	if(name == "app_time")
		return KATARINA_Q_APPLICATION_TIME;
	if(name == "app_status")
		return KATARINA_Q_APPLICATION_STATUS;
	return "";
}
