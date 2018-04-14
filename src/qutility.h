#ifndef _KATARINA_UTILITY_H
#define _KATARINA_UTILITY_H

#include <QObject>
#include <QMap>
#include <QVariant>

class QDeclarativeEngine;
class QString;
class QSettings;
class QVariant;

namespace katarina
{
	class QUtility : public QObject
	{
		Q_OBJECT
		Q_PROPERTY(QString bearerTypeName READ bearerTypeName)
		public:
			QUtility(QDeclarativeEngine *e = 0, QObject *parent = 0);
			~QUtility();
			QString bearerTypeName() const;
			Q_INVOKABLE QVariant getSetting(const QString &name) const;
			Q_INVOKABLE void setSetting(const QString &name, const QVariant &value);
			Q_INVOKABLE void openHarmattanGrob(const QString &url) const;
			Q_INVOKABLE void openHarmattanVideoSuite(const QString &url) const;
			Q_INVOKABLE QVariant getAppInfo(const QString &name) const;

		private:
			QUtility(const QUtility &u);
			QUtility & operator= (const QUtility &u);
			static QVariant GetDefaultSetting(const QString &name);

		private:
			QDeclarativeEngine *engine;
			QSettings *settings;
	};
}

#endif
