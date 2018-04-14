#ifndef GLWidget_H
#define GLWidget_H

#include "lk_struct.h"
#include "gutility.h"
#include "OpenEXR/ImathMatrix.h"
#include <QGLWidget>
#include <QStringList>
using Imath::Matrix44;

#define BUTTON_LEN 64

class QTimer;
class QIODevice;
class model_loader;
class model_loader_task;
class QIODevice;

class GLWidget : public QGLWidget
{
    Q_OBJECT
			Q_PROPERTY(QString championId READ championId NOTIFY championIdChanged FINAL)
			Q_PROPERTY(QString skinId READ skinId NOTIFY skinIdChanged FINAL)
			Q_PROPERTY(RenderType renderType READ renderType WRITE setRenderType NOTIFY renderTypeChanged FINAL)
			Q_PROPERTY(QString loadMessage READ loadMessage NOTIFY loadMessageChanged FINAL)
			Q_PROPERTY(QStringList animationList READ animationList NOTIFY animationListChanged FINAL)
			Q_PROPERTY(int animationIndex READ animationIndex NOTIFY animationIndexChanged FINAL)
			Q_PROPERTY(ScreenOrientation orientation READ orientation WRITE setOrientation NOTIFY orientationChanged FINAL)
			Q_ENUMS(RenderType)
			Q_ENUMS(ScreenOrientation)

	public:
			enum RenderType
			{
				StaticModel = 1,
				StaticBone = 2,
				AnimationModel = 5,
				AnimationBone = 6
			};
			enum ScreenOrientation
			{
				Landscape = 0,
				Portrait
			};
    
public:
    explicit GLWidget(QWidget *parent = 0);
    ~GLWidget();
		Q_INVOKABLE void loadModel(const QString &id, const QString &skinId);
		Q_INVOKABLE void loadAnim(int index);
		Q_INVOKABLE void clear();

public:
		QString championId() const;
		QString skinId() const;
		RenderType renderType() const;
		void setRenderType(RenderType type);
		QString loadMessage() const;
		QStringList animationList() const;
		int animationIndex() const;
		ScreenOrientation orientation() const;
		void setOrientation(ScreenOrientation o);

Q_SIGNALS:
		void renderTypeChanged(RenderType type);
		void championIdChanged(const QString &championId);
		void skinIdChanged(const QString &skinId);
		void loadMessageChanged(const QString &msg);
		void closing();
		void animationListChanged(const QStringList &list);
		void animationIndexChanged(int index);
		void orientationChanged(ScreenOrientation o);

public Q_SLOTS:
    void play();
    void stop();
    void playAnimation();
    void stopAnimation();

protected:
    void keyPressEvent(QKeyEvent *e);
    void keyReleaseEvent(QKeyEvent *e);
    void mousePressEvent(QMouseEvent *e);
    void mouseReleaseEvent(QMouseEvent *e);
    void mouseMoveEvent(QMouseEvent *e);
    void wheelEvent(QWheelEvent *e);
		void closeEvent(QCloseEvent *e);
		void changeEvent(QEvent *e);
		void hideEvent(QHideEvent *e);

    virtual void	initializeGL();
    virtual void	paintGL ();
    virtual void	resizeGL ( int width, int height );

private:
		enum
		{
			VertexBuffer = 0,
			IndexBuffer,
			AnimationVertexBuffer,
			TotalBuffer
		};
		enum
		{
			BonePointBuffer = 0,
			BoneLineBuffer,
			AnimationBonePointBuffer,
			AnimationBoneLineBuffer,
			TotalBoneBuffer
		};
		enum
		{
			VertexShader = 0,
			FragmentShader,
			TotalShader
		};
		enum
		{
			ProjectionMatrix = 0,
			ModelviewMatrix,
			TotalMatrix
		};
		struct Program
		{
			Program()
				: program(0)
			{
				shaders[VertexShader] = 0;
				shaders[FragmentShader] = 0;
			}
			GLuint program;
			GLuint shaders[TotalShader];
		};
		enum
		{
			TextureProgram = 0,
			FlatProgram,
			TotalProgram
		};
		enum ButtonWidgetBuffer
		{
			ForwardButtonBuffer = 0,
			BackwardButtonBuffer,
			LeftButtonBuffer,
			RightButtonBuffer,
			UpButtonBuffer,
			DownButtonBuffer,
			CloseButtonBuffer,
			PlayButtonBuffer,
			StopButtonBuffer,
			TotalButtonBuffer
		};
		struct VirtualButton
		{
			GLuint buffer;
			GLboolean pressed;
			GLint xCoord[2];
			GLint yCoord[2];
		};

		private Q_SLOTS:
			void init(model_loader_task *task);
		void setLoadMessage(const QString &msg);
		void nextFrame();
    void idle();

private:
    void reset();
    void resetRender();
    void shutdown();
    void mouseClickHandler(int button, bool pressed, int x, int y);
    void mouseMotionHandler(int button, bool pressed, int x, int y, int dx, int dy);
    void keyboardHandler(unsigned int key, bool pressed, int x, int y);
		Program initProgram(const char *files[]);
		void initBuffer();
		void drawModel(RenderType type);
		void drawSkeleton(RenderType type);
		void render2D();
		void render3D();
		void draw2DScene();
	
private:
		void setChampionId(const QString &championId);
		void setSkinId(const QString &skinId);
		void setAnimationList();

private:
    float yAxisRotate;
    float xAxisRotate;

    float x_t;
    float y_t;
    float z_t;

    float x_r;
    float y_r;

    GLboolean move[TotalPosition];
    GLboolean turn[TotalOrientation];
    GLboolean function[4];

    GLint delta_x;
    GLint delta_y;

    GLfloat scale;

		Mesh *mesh;
    Texture *g_tex;
		Anim *anim;
		model_loader *loader;

    QTimer *timer;
    QTimer *animationTimer;
		GLuint playInterval;
		GLuint animationInterval;

		Matrix44<GLfloat> matrixs[TotalMatrix];
		GLuint buffers[TotalBuffer];
		GLuint boneBuffers[TotalBoneBuffer];
		VirtualButton buttons[TotalButtonBuffer];
		GLuint boneCount[TotalBoneBuffer];
		Program programs[TotalProgram];
    Texture *button_tex;

		QString _championId;
		QString _skinId;
		QString _meshFile;
		QString _textureFile;
		QString _animFile;
		RenderType _renderType;
		QString _loadMessage;
		QStringList _animationList;
		int _animationIndex;
		int _frame;
		ScreenOrientation _orientation;

};

#endif // GLWidget_H
