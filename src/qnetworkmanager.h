#ifndef _KATARINA_NETWORK_H
#define _KATARINA_NETWORK_H

#include <QNetworkAccessManager>
#include <QDeclarativeNetworkAccessManagerFactory>
#include <QMutex>

namespace katarina{

	class QNetworkManager : public QNetworkAccessManager
	{
		Q_OBJECT

		public:
			QNetworkManager(QObject *parent = 0);
			virtual ~QNetworkManager();

			virtual QNetworkReply *	createRequest ( Operation op, const QNetworkRequest & req, QIODevice * outgoingData = 0 );

	};

	class QDeclarativeNetworkManagerFactory : public QDeclarativeNetworkAccessManagerFactory
	{
		public:
			QDeclarativeNetworkManagerFactory();
			~QDeclarativeNetworkManagerFactory();
			QNetworkAccessManager * create(QObject *parent);

		private:
			QMutex mutex;
	};

}

#endif
