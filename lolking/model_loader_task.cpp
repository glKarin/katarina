#include "model_loader_task.h"
#include <QIODevice>
#include <QDebug>
#include <QNetworkReply>
#include <QByteArray>

model_loader_task::model_loader_task(QObject *parent)
	:QObject(parent),
	_file(0),
	_reply(0),
	_name(""),
	_size(0),
	_read(0),
	_state(model_loader_task::Ready),
	_type(MeshFile)
{
}

model_loader_task::~model_loader_task()
{
	abort();
	_reply -> deleteLater();
	delete _file;
}

void model_loader_task::abort()
{
	if(_state == model_loader_task::Loading && _reply != 0)
	{
		_reply -> abort();
		_state = model_loader_task::Fail;
		emit finished(this);
	}
	if(_file && _file -> isOpen())
	{
		_file -> close();
	}
}

void model_loader_task::load(QNetworkReply *reply, QIODevice *file, const QString &name, ModelFile type)
{
	if(_state == model_loader_task::Loading)
		return;
	if(!reply ||!file)
		return;
	_type = type;
	_name = name;
	setRead(0);
	setSize(0);
	_state = model_loader_task::Ready;
	_reply = reply;
	_file = file;
	_file -> open(QIODevice::WriteOnly);
	if(!_file -> isOpen())
	{
		abort();
	}
	_state = model_loader_task::Loading;
	connect(_reply, SIGNAL(readyRead()), this, SLOT(write_data()));
	connect(_reply, SIGNAL(downloadProgress(qint64, qint64)), this, SLOT(update_progress(qint64, qint64)));
	connect(_reply, SIGNAL(finished()), this, SLOT(do_finished()));
}

void model_loader_task::do_finished()
{
	if(_state == model_loader_task::Loading)
	{
		_state = model_loader_task::Finished;
		if(_file -> isOpen())
		{
			_file -> close();
		}
		//qDebug() << "Load successful";
		emit finished(this);
	}
}

void model_loader_task::write_data()
{
	//qDebug() << _read << " / " << _size;
	if(_reply -> error() != QNetworkReply::NoError)
	{
		emit log(QString("QNetworkReply::NetworkError = ") + QString::number(_reply -> error()));
		abort();
		return;
	}
	if(_file && _file -> isOpen() && _state == model_loader_task::Loading)
	{
		_file -> write(_reply -> readAll());
	}
}

void model_loader_task::update_progress(qint64 read, qint64 total)
{
	//qDebug() << _read << " / " << _size;
	if(read == 0 && total == 0)
	{
		emit log(tr("No download associated"));
		abort();
		return;
	}
	/*
	if(total == -1)
	{
		qDebug() << tr("unkown size");
	}
	*/
	setSize(total);
	setRead(read);
}

void model_loader_task::setSize(qint64 s)
{
	if(_size != s)
	{
		_size = s;
		emit size_changed(_size);
	}
}

void model_loader_task::setRead(qint64 s)
{
	if(_read != s)
	{
		_read = s;
		emit read_changed(_read);
	}
}

qint64 model_loader_task::size() const
{
	return _size;
}

model_loader_task::State model_loader_task::state() const
{
	return _state;
}

qint64 model_loader_task::read() const
{
	return _read;
}

QIODevice * model_loader_task::data()
{
	return _file;
}

ModelFile model_loader_task::type() const
{
	return _type;
}

QString model_loader_task::name() const
{
	return _name;
}
