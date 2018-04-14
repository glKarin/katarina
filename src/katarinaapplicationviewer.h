#include "qmlapplicationviewer.h"

class KatarinaApplicationViewer : public QmlApplicationViewer
{
	Q_OBJECT

	public:
		explicit KatarinaApplicationViewer(QDeclarativeView *view = 0)
			: QmlApplicationViewer(view)
		{
		}
		virtual ~KatarinaApplicationViewer(){}

Q_SIGNALS:
		void closing();

	protected:
		virtual void closeEvent(QCloseEvent *e)
		{
			emit closing();
			QmlApplicationViewer::closeEvent(e);
		}
};

