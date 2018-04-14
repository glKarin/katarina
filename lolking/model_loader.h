#ifndef _MODEL_LOADER_H
#define _MODEL_LOADER_H

#include "lk_struct.h"
#include "model_loader_task.h"

#include <QObject>
#include <QMutex>

class QNetworkAccessManager;
class model_loader_task;

class model_loader : public QObject
{
	Q_OBJECT

	public:
		model_loader(QObject *parent = 0);
		~model_loader();

public Q_SLOTS:
	void load_mesh(const QString &id, const QString &skinId);
	void load_anim(const QString &name);
	void load_texture(const QString &id, const QString &name);

Q_SIGNALS:
		void log(const QString &log);
		void load_finished(model_loader_task *task);

		private Q_SLOTS:
			void do_finished(model_loader_task *task);

	private:
		model_loader(const model_loader &manager);
		model_loader & operator=(const model_loader &manager);

	private:
		QNetworkAccessManager *manager;
		QMutex mutex;

}; 

#endif
