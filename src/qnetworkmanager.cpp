#include <QNetworkRequest>
#include <QMutexLocker>
#include <QDebug>

#include "qnetworkmanager.h"

using namespace katarina;

QNetworkManager::QNetworkManager(QObject *parent)
	: QNetworkAccessManager(parent)
{
}

QNetworkManager::~QNetworkManager()
{
}

QNetworkReply *	QNetworkManager::createRequest ( QNetworkAccessManager::Operation op, const QNetworkRequest & req, QIODevice * outgoingData)
{
	QNetworkRequest request(req);
	//request.setRawHeader("User-Agent", userAgent);
	//static const QString MatchDetailNew1("http://lolbox.duowan.com/phone/matchDetailNew.php");
	//static const QString MatchDetailNew2("http://zdl.mbox.duowan.com/phone/matchDetailNew.php");
		//qDebug()<<req.url().toString();
	QString url = req.url().toString();
	//if(url.startsWith(MatchDetailNew1) || url.startsWith(MatchDetailNew2))
	{
		//request.setAttribute(QNetworkRequest::CookieLoadControlAttribute, QNetworkRequest::Manual);
		//QList<QVariant> list = request.header(QNetworkRequest::CookieHeader).toList();
		request.setRawHeader("Dw-Ua", "lolbox&3.1.1d-311&yingyongbao&socia");
	}
	QNetworkReply *reply = QNetworkAccessManager::createRequest(op, request, outgoingData);
	return reply;
}

	QDeclarativeNetworkManagerFactory::QDeclarativeNetworkManagerFactory()
:QDeclarativeNetworkAccessManagerFactory()
{
}

QDeclarativeNetworkManagerFactory::~QDeclarativeNetworkManagerFactory()
{
}

QNetworkAccessManager * QDeclarativeNetworkManagerFactory::create(QObject *parent)
{
	QMutexLocker lock(&mutex);
	QNetworkAccessManager* manager = new QNetworkManager(parent);
	return manager;
}

