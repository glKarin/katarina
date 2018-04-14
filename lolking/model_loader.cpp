#include "model_loader.h"

#include <QNetworkRequest>
#include <QNetworkReply>
#include <QString>
#include <QStringList>
#include <QUrl>
#include <QDebug>
#include <QMutexLocker>
#include <QBuffer>

//const QString JsonUrl = "http://lkstatic.zamimg.com/shared/mv/meta/%1.json";
const QString Mesh_Url = "http://lkstatic.zamimg.com/shared/mv/models/%1_%2.lmesh";
const QString Texture_Url = "http://lkstatic.zamimg.com/shared/mv/textures/%1/%2.png";
const QString Anim_Url = "http://lkstatic.zamimg.com/shared/mv/models/%1.lanim";

const QString Mesh_Url_2 = "http://media.services.zam.com/v1/media/byName/lol/mv/models/%1_%2.lmesh";
const QString Texture_Url_2 = "http://media.services.zam.com/v1/media/byName/lol/mv/textures/%1/%2.png";
const QString Anim_Url_2 = "http://media.services.zam.com/v1/media/byName/lol/mv/models/%1.lanim";

model_loader::model_loader(QObject *parent)
	:QObject(parent),
	manager(new QNetworkAccessManager(this))
{
}

model_loader::~model_loader()
{
}

void model_loader::load_mesh(const QString &id, const QString &skinId)
{
	QMutexLocker lock(&mutex);

	model_loader_task *task = new model_loader_task;
	QString name(Mesh_Url_2.arg(id).arg(skinId));
	QNetworkReply *reply = manager -> get(QNetworkRequest(QUrl(name)));
	QBuffer *mesh = new QBuffer;
	task -> load(reply, mesh, id + "_" + skinId, MeshFile);
	connect(task, SIGNAL(finished(model_loader_task *)), this, SLOT(do_finished(model_loader_task *)));
	connect(task, SIGNAL(log(const QString &)), this, SIGNAL(log(const QString &)));
	//qDebug() << "Load mesh from: " << Mesh_Url_2.arg(id).arg(skinId);
	emit log(tr("Download mesh") + " -> " + name);
}

void model_loader::do_finished(model_loader_task *task)
{
	if(!task)
		return;
	if(task -> state() != model_loader_task::Finished)
	{
		emit log(tr("Download fail"));
		task -> deleteLater();
		return;
	}
	emit log(tr("Download finished"));
	emit load_finished(task);
}

void model_loader::load_texture(const QString &id, const QString &n)
{
	QMutexLocker lock(&mutex);

	model_loader_task *task = new model_loader_task;
	QString name(Texture_Url_2.arg(id).arg(n));
	QNetworkReply *reply = manager -> get(QNetworkRequest(QUrl(name)));
	QBuffer *texture = new QBuffer;
	task -> load(reply, texture, n, TextureFile);
	connect(task, SIGNAL(finished(model_loader_task *)), this, SLOT(do_finished(model_loader_task *)));
	connect(task, SIGNAL(log(const QString &)), this, SIGNAL(log(const QString &)));
	//qDebug() << "Load texture from: " << Texture_Url_2.arg(id).arg(name);
	emit log(tr("Download texture") + " -> " + name);
}

void model_loader::load_anim(const QString &n)
{
	QMutexLocker lock(&mutex);

	model_loader_task *task = new model_loader_task;
	QString name(Anim_Url_2.arg(n));
	QNetworkReply *reply = manager -> get(QNetworkRequest(QUrl(name)));
	QBuffer *anim = new QBuffer;
	task -> load(reply, anim, n, AnimFile);
	connect(task, SIGNAL(finished(model_loader_task *)), this, SLOT(do_finished(model_loader_task *)));
	connect(task, SIGNAL(log(const QString &)), this, SIGNAL(log(const QString &)));
	//qDebug() << "Load mesh from: " << Mesh_Url_2.arg(id).arg(skinId);
	emit log(tr("Download anim") + " -> " + name);
}

