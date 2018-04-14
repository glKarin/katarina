#ifndef _MODEL_LOADER_TASK_H
#define _MODEL_LOADER_TASK_H

#include "lk_struct.h"
#include <QObject>
#include <QString>

class QIODevice;
class QNetworkReply;
class model_loader;

class model_loader_task : public QObject
{
	Q_OBJECT
	public:
		enum State
		{
			Ready = 0,
			Loading,
			Finished,
			Fail
		};

	public:
		model_loader_task(QObject *parent = 0);
		~model_loader_task();
		qint64 read() const;
		qint64 size() const;
		State state() const;
		QString name() const;
		ModelFile type() const;
		QIODevice * data();
		void load(QNetworkReply *reply, QIODevice *file, const QString &name, ModelFile type);

Q_SIGNALS:
		void log(const QString &log);
		void read_changed(qint64 s);
		void size_changed(qint64 s);
		void finished(model_loader_task *task);

		private Q_SLOTS:
		void write_data();
		void update_progress(qint64 read, qint64 total);
		void do_finished();
		void abort();

	private:
		model_loader_task(const model_loader_task &task);
		model_loader_task & operator=(const model_loader_task &task);
		void setRead(qint64 i);
		void setSize(qint64 i);

	private:
		QIODevice *_file;
		QNetworkReply *_reply;
		QString _name;
		qint64 _size;
		qint64 _read;
		State _state;
		ModelFile _type;

		friend class model_loader;
};

#endif
