#include "glwidget.h"
#include "mesh_reader.h"
#include "anim_reader.h"
#include "model_loader.h"
#include "model_loader_task.h"
#include "texture_reader.h"
#include "lk_render.h"
#include "gutility.h"
#include "g_gui.h"
#include "OpenEXR/ImathVec.h"

#include <QKeyEvent>
#include <QIODevice>
#include <QDebug>
#include <QTimer>
using Imath::Matrix44;
using Imath::Vec3;

#ifdef HARMATTAN_DRIVER
#define TEXTUREVSHADERFILE "../glsl/vertex_shader.sl"
#define TEXTUREFSHADERFILE "../glsl/fragment_shader.sl"
#define FLATVSHADERFILE "../glsl/flat_vertex_shader.sl"
#define FLATFSHADERFILE "../glsl/flat_fragment_shader.sl"
#define BUTTON_TEXTURE_FILE "./texture/anna_buttons.png"
#else
#define TEXTUREVSHADERFILE "/opt/katarina/glsl/vertex_shader.sl"
#define TEXTUREFSHADERFILE "/opt/katarina/glsl/fragment_shader.sl"
#define FLATVSHADERFILE "/opt/katarina/glsl/flat_vertex_shader.sl"
#define FLATFSHADERFILE "/opt/katarina/glsl/flat_fragment_shader.sl"
#define BUTTON_TEXTURE_FILE "/opt/katarina/texture/anna_buttons.png"
#endif

#define VPOSITION "vPosition"
#define VNORMAL "vNormal"
#define VTEXCOORD "vTexcoord"
#define FTEXTURE "fTexture"
#define V_MODELVIEWPROJECTIONMATRIX "v_ModelviewProjectionMatrix"
#define FHASTEXTURE "fHasTexture"
#define VCOLOR "vColor"
#define VPOINTSIZE "vPointSize"

#define ator(a) ((double)(a) / 180.0 * M_PI)

#define ROTATION_UNIT 0.5
#define MOVE_UNIT 20
#define TURN_UNIT 5.0

#define SCALE_UNIT 0.1
#define MAX_SCALE_LIMIT 10.0
#define MIN_SCALE_LIMIT 0.1

#define DEFAULT_TIME_INTERVAL 34
#define DEFAULT_ANIMATION_INTERVAL 34

#define BUTTON_WIDTH 64
#define SPACING 20

#define Y_COORD_OPENGL_TO_X11(y) (this -> height() - (y))
#define X_COORD_IS_IN_RANGE(x, o, w) (((x) >= (o)) && ((x) <= ((o) + (w))))
#define Y_COORD_IS_IN_RANGE(y, o, h) (((y) <= ((Y_COORD_OPENGL_TO_X11(o)))) && ((y) >= (((Y_COORD_OPENGL_TO_X11(o))) - (h))))

#define CLOSE_X (this -> width() - 1 - BUTTON_WIDTH)
#define CLOSE_Y (this -> height() - 1 - BUTTON_WIDTH)
#define FORWARD_X (SPACING * 2 + BUTTON_WIDTH)
#define FORWARD_Y (SPACING * 3 + BUTTON_WIDTH * 2)
#define BACKWARD_X (SPACING * 2 + BUTTON_WIDTH)
#define BACKWARD_Y (SPACING)
#define LEFT_X (SPACING)
#define LEFT_Y (SPACING * 2 + BUTTON_WIDTH)
#define RIGHT_X (SPACING * 3 + BUTTON_WIDTH * 2)
#define RIGHT_Y (SPACING * 2 + BUTTON_WIDTH)
#define UP_X (this -> width() - SPACING - BUTTON_WIDTH)
#define UP_Y (SPACING * 8)
#define DOWN_X (this -> width() - SPACING - BUTTON_WIDTH)
#define DOWN_Y (SPACING * 3)
#define PLAY_X 0
#define PLAY_Y (this -> height() - 1 - BUTTON_WIDTH)

#define CLOSE_P_X (0)
#define CLOSE_P_Y (this -> height() - 1 - BUTTON_WIDTH)
#define FORWARD_P_X (this -> width() - SPACING * 3 - BUTTON_WIDTH * 3)
#define FORWARD_P_Y (SPACING * 2 + BUTTON_WIDTH)
#define BACKWARD_P_X (this -> width() - SPACING - BUTTON_WIDTH)
#define BACKWARD_P_Y (SPACING * 2 + BUTTON_WIDTH)
#define LEFT_P_X (this -> width() - BUTTON_WIDTH * 2 - SPACING * 2)
#define LEFT_P_Y (SPACING)
#define RIGHT_P_X (this -> width() - BUTTON_WIDTH * 2 - SPACING * 2)
#define RIGHT_P_Y (SPACING * 3 + BUTTON_WIDTH * 2)
#define UP_P_X (this -> width() - SPACING * 8 - BUTTON_WIDTH)
#define UP_P_Y (this -> height() - SPACING - BUTTON_WIDTH)
#define DOWN_P_X (this -> width() - SPACING * 3 - BUTTON_WIDTH)
#define DOWN_P_Y (this -> height() - SPACING - BUTTON_WIDTH)
#define PLAY_P_X 0
#define PLAY_P_Y 0

#define KARIN_FLOAT_TEXCOORD(x, w) ((GLfloat)(x) / (GLfloat)(w))
#define BUTTON_TEXTURE_BUTTON_WIDTH 64
#define BUTTON_TEXTURE_WIDTH 512
#define BUTTON_TEXTURE_TEXCOORD_LT(i) (KARIN_FLOAT_TEXCOORD(((i) * BUTTON_TEXTURE_BUTTON_WIDTH), BUTTON_TEXTURE_WIDTH))
#define BUTTON_TEXTURE_TEXCOORD_RB(i) (KARIN_FLOAT_TEXCOORD(((i) * BUTTON_TEXTURE_BUTTON_WIDTH + BUTTON_TEXTURE_BUTTON_WIDTH), BUTTON_TEXTURE_WIDTH)) //??? - 1

#define FORWARD_TEXCOORD_X 3
#define FORWARD_TEXCOORD_Y 0
#define BACKWARD_TEXCOORD_X 5
#define BACKWARD_TEXCOORD_Y 0
#define LEFT_TEXCOORD_X 2
#define LEFT_TEXCOORD_Y 0
#define RIGHT_TEXCOORD_X 4
#define RIGHT_TEXCOORD_Y 0
#define CLOSE_TEXCOORD_X 1
#define CLOSE_TEXCOORD_Y 0
#define ARROW_TEXCOORD_X 5
#define ARROW_TEXCOORD_Y 4
#define PLAY_TEXCOORD_X 4
#define PLAY_TEXCOORD_Y 2
#define STOP_TEXCOORD_X 3
#define STOP_TEXCOORD_Y 2

static const char *TextureShaderFile[] = {
	TEXTUREVSHADERFILE,
	TEXTUREFSHADERFILE
};
static const char *FlatShaderFile[] = {
	FLATVSHADERFILE,
	FLATFSHADERFILE
};

static int ox = 0;
static int oy = 0;
static bool mousePressed = false;

GLWidget::GLWidget(QWidget *parent)
	: QGLWidget(parent),
		mesh(0),
		g_tex(0),
		anim(0),
		loader(new model_loader(this)),
    timer(0),
    animationTimer(0),
		button_tex(0),
		_orientation(Portrait)
{
		resize(854, 480);
		QGLWidget::setWindowTitle("GL LOL Model Viewer");
		connect(loader, SIGNAL(load_finished(model_loader_task *)), this, SLOT(init(model_loader_task *)));
		connect(loader, SIGNAL(log(const QString &)), this, SLOT(setLoadMessage(const QString &)));
#define MAKE_BUTTON_COORD(N, V) \
		{ \
			buttons[N##ButtonBuffer].xCoord[0] = V##_X; \
			buttons[N##ButtonBuffer].yCoord[0] = V##_Y; \
			buttons[N##ButtonBuffer].xCoord[1] = V##_P_X; \
			buttons[N##ButtonBuffer].yCoord[1] = V##_P_Y; \
		}

		MAKE_BUTTON_COORD(GLWidget::Forward, FORWARD)
		MAKE_BUTTON_COORD(GLWidget::Backward, BACKWARD);
		MAKE_BUTTON_COORD(GLWidget::Left, LEFT)
		MAKE_BUTTON_COORD(GLWidget::Right, RIGHT)
		MAKE_BUTTON_COORD(GLWidget::Up, UP)
		MAKE_BUTTON_COORD(GLWidget::Down, DOWN)
		MAKE_BUTTON_COORD(GLWidget::Close, CLOSE)
		MAKE_BUTTON_COORD(GLWidget::Play, PLAY)
		MAKE_BUTTON_COORD(GLWidget::Stop, PLAY)

#undef MAKE_BUTTON_COORD
    reset();
    QGLWidget::setFocusPolicy(Qt::ClickFocus);
}

GLWidget::~GLWidget()
{
    shutdown();
		glUseProgram(0);
		for(int i = 0; i < GLWidget::TotalProgram; i++)
			if(glIsProgram(programs[i].program))
			{
				if(glIsShader(programs[i].shaders[0]))
					glDeleteShader(programs[i].shaders[0]);
				if(glIsShader(programs[i].shaders[1]))
					glDeleteShader(programs[i].shaders[1]);
				glDeleteProgram(programs[i].program);
			}
		if(button_tex)
		{
			if(glIsTexture(button_tex -> texid))
				glDeleteTextures(1, &(button_tex -> texid));
			free_texture(button_tex);
		}
		for(int i = 0; i < GLWidget::TotalButtonBuffer; i++)
			if(glIsBuffer(buttons[i].buffer))
			{
				glDeleteBuffers(1, &(buttons[i].buffer));
			}
}

void GLWidget::resetRender()
{
    yAxisRotate = 0;
    xAxisRotate = 0;
    x_t = 0;
    y_t = -300.0f;
    z_t = _orientation == GLWidget::Landscape ? -100.0f : 100.0f;
    x_r = 0;
    y_r = 0;
    delta_x = 0;
    delta_y = 0;
    scale = 1.0f;
		_frame = -1;
    stop();
		stopAnimation();
    for(int i = Up; i < TotalPosition; i++)
        move[i] = GL_FALSE;
    for(int i = TurnUp; i < TotalOrientation; i++)
        turn[i] = GL_FALSE;
    for(int i = 0; i < 4; i++)
        function[i] = GL_FALSE;
    for(int i = 0; i < GLWidget::TotalButtonBuffer; i++)
        buttons[i].pressed = GL_FALSE;
}

void GLWidget::reset()
{
		resetRender();
		_renderType = GLWidget::AnimationModel;
		emit renderTypeChanged(_renderType);
		_meshFile.clear();
		_textureFile.clear();
		_animFile.clear();
		_championId.clear();
		_skinId.clear();
		playInterval = DEFAULT_TIME_INTERVAL;
		animationInterval = DEFAULT_ANIMATION_INTERVAL;
		_animationIndex = -1;
		setAnimationList();
}

void GLWidget::clear()
{
	_loadMessage.clear();
	shutdown();
	reset();
}

void GLWidget::loadModel(const QString &id, const QString &skinId)
{
	clear();
	setChampionId(id);
	setSkinId(skinId);
	_meshFile = _championId + "_" + _skinId;
	setLoadMessage(tr("Loading mesh file") + " -> " + _championId + "_" + _skinId);
	loader -> load_mesh(_championId, _skinId);
}

void GLWidget::init(model_loader_task *task)
{
		QGLWidget::makeCurrent();
    if(!task)
    {
        setLoadMessage(tr("Load model file fail"));
				return;
    }
		ModelFile type = task -> type();
		QIODevice *in = task -> data();
		if(type == MeshFile)
		{
			if(_meshFile != task -> name())
			{
				task -> deleteLater();
				return;
			}
			setLoadMessage(tr("Parsing mesh file"));
			mesh = read_mesh(in);
			if(mesh)
			{
				setLoadMessage(tr("Mesh version") + " -> " + QString::number(mesh -> version));
				{
					_textureFile = mesh -> textureFile;
					setLoadMessage(tr("Loading texture file") + " -> " + _textureFile);
					loader -> load_texture(_championId, _textureFile);
				}
				{
					_animFile = mesh -> animFile;
					setLoadMessage(tr("Loading animation file") + " -> " + _animFile);
					loader -> load_anim( _animFile);
				}
				setLoadMessage(tr("Writing OpenGL buffer"));
				initBuffer();
				setLoadMessage(tr("Rendering"));
				setLoadMessage(tr("Showing full screen"));
				QGLWidget::showFullScreen();
			}
			else
			{
				setLoadMessage(tr("Parse mesh file fail"));
				task -> deleteLater();
				return;
			}
		}
		else if(type == TextureFile)
		{
			if(_textureFile != task -> name())
			{
				task -> deleteLater();
				return;
			}
			setLoadMessage(tr("Loading texture to OpenGL"));
			g_tex = read_texture(in);
			if(g_tex)
			{
				setLoadMessage(tr("texture") + " -> " + QString::number(g_tex -> w) + " * " + QString::number(g_tex -> h) + " (" + (g_tex -> format == GL_LUMINANCE ? "luminance" : (g_tex -> format == GL_LUMINANCE_ALPHA ? "luminance-alpha" : (g_tex -> format == GL_RGB ? "RGB" : "RGBA"))) + ")");
				setLoadMessage(tr("Rendering"));
			}
			else
			{
				setLoadMessage(tr("Load texture file fail"));
				task -> deleteLater();
				return;
			}
		}
		else if(type == AnimFile)
		{
			if(_animFile != task -> name())
			{
				task -> deleteLater();
				return;
			}
			setLoadMessage(tr("Parsing anim file"));
			anim = read_anim(in);
			if(anim)
			{
				setLoadMessage(tr("Anim version") + " -> " + QString::number(anim -> version));
				setAnimationList();
				loadAnim(0);
			}
			else
			{
				setLoadMessage(tr("Parse anim file fail"));
				task -> deleteLater();
				return;
			}
		}
    updateGL();
		task -> deleteLater();
}

void GLWidget::paintGL()
{
		QGLWidget::makeCurrent();
    //qDebug()<<"//idle()";
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

		render3D();

		matrixs[GLWidget::ModelviewMatrix].makeIdentity();
		Matrix44<GLfloat> translationMatrix;
		Matrix44<GLfloat> xRotationMatrix;
		Matrix44<GLfloat> yRotationMatrix;
		Vec3<GLfloat> translation;
		if(_orientation == GLWidget::Landscape)
		{
			translation.x = x_t;
			translation.y = z_t;
			translation.z = y_t;
		}
		else
		{
			translation.x = z_t;
			translation.y = x_t;
			translation.z = y_t;
		}
		translationMatrix.translate(translation);

		Vec3<GLfloat> xRotation(1.0f, 0.0f, 0.0f);
		Vec3<GLfloat> yRotation(0.0f, 1.0f, 0.0f);
		Vec3<GLfloat> zRotation(0.0f, 0.0f, 1.0f);
		if(_orientation == GLWidget::Landscape)
		{
			yRotationMatrix.setAxisAngle(yRotation, (GLfloat)KARIN_ANGLE_TO_RADIAN(y_r));
			xRotationMatrix.setAxisAngle(xRotation, (GLfloat)KARIN_ANGLE_TO_RADIAN(x_r));
		}
		else
		{
			yRotationMatrix.setAxisAngle(yRotation, (GLfloat)KARIN_ANGLE_TO_RADIAN(x_r));
			xRotationMatrix.setAxisAngle(xRotation, (GLfloat)KARIN_ANGLE_TO_RADIAN(y_r));
		}

		Matrix44<GLfloat> xORotationMatrix;
		Matrix44<GLfloat> yORotationMatrix;
		Matrix44<GLfloat> zORotationMatrix;
		yORotationMatrix.setAxisAngle(yRotation, (GLfloat)KARIN_ANGLE_TO_RADIAN(yAxisRotate));
		xORotationMatrix.setAxisAngle(xRotation, (GLfloat)KARIN_ANGLE_TO_RADIAN(xAxisRotate));
		if(_orientation == GLWidget::Landscape)
			zORotationMatrix.makeIdentity();
		else
			zORotationMatrix.setAxisAngle(zRotation, (GLfloat)KARIN_ANGLE_TO_RADIAN(90));

		matrixs[GLWidget::ModelviewMatrix] = zORotationMatrix * (xORotationMatrix * yORotationMatrix) * translationMatrix * (xRotationMatrix * yRotationMatrix); // rotation -> translation
		Vec3<GLfloat> scaleVec(scale, scale, scale);
		matrixs[GLWidget::ModelviewMatrix].scale(scaleVec);

    if(mesh)
		{
			if(anim && (_renderType & 4))
			{
				updateBone(&(mesh -> bone), anim -> animations + _animationIndex, _frame);
				if(_renderType == GLWidget::AnimationBone)
					drawSkeleton(GLWidget::AnimationBone);
				else
					drawModel(GLWidget::AnimationModel);
			}
			else
			{
				if(_renderType == GLWidget::StaticBone)
					drawSkeleton(GLWidget::StaticBone);
				else
					drawModel(GLWidget::StaticModel);
			}
		}

		render2D();
		draw2DScene();

    glFlush();
}

void GLWidget::initializeGL()
{
		QGLWidget::makeCurrent();
    glClearColor(1.0f, 1.0f, 1.0f, 1.0f);
    //glPolygonMode(GL_FRONT_AND_BACK,GL_LINE);
    glCullFace(GL_BACK);
    glEnable(GL_CULL_FACE);
    //glEnable(GL_DEPTH_TEST);

		glEnable(GL_BLEND);
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

		programs[GLWidget::TextureProgram] = initProgram(TextureShaderFile);
		programs[GLWidget::FlatProgram] = initProgram(FlatShaderFile);

		button_tex = read_texture_from_file(BUTTON_TEXTURE_FILE);
#define MAKE_TEXCOORD_ARRAY(N) \
		GLfloat texcoord_##N##_release[] = { \
			BUTTON_TEXTURE_TEXCOORD_LT(N##_TEXCOORD_X), \
			BUTTON_TEXTURE_TEXCOORD_RB(N##_TEXCOORD_Y), \
			BUTTON_TEXTURE_TEXCOORD_RB(N##_TEXCOORD_X), \
			BUTTON_TEXTURE_TEXCOORD_RB(N##_TEXCOORD_Y), \
			BUTTON_TEXTURE_TEXCOORD_LT(N##_TEXCOORD_X), \
			BUTTON_TEXTURE_TEXCOORD_LT(N##_TEXCOORD_Y), \
			BUTTON_TEXTURE_TEXCOORD_RB(N##_TEXCOORD_X), \
			BUTTON_TEXTURE_TEXCOORD_LT(N##_TEXCOORD_Y) \
		}; \
		GLfloat texcoord_##N##_press[] = { \
			BUTTON_TEXTURE_TEXCOORD_LT(N##_TEXCOORD_X), \
			BUTTON_TEXTURE_TEXCOORD_RB(N##_TEXCOORD_Y + 1), \
			BUTTON_TEXTURE_TEXCOORD_RB(N##_TEXCOORD_X), \
			BUTTON_TEXTURE_TEXCOORD_RB(N##_TEXCOORD_Y + 1), \
			BUTTON_TEXTURE_TEXCOORD_LT(N##_TEXCOORD_X), \
			BUTTON_TEXTURE_TEXCOORD_LT(N##_TEXCOORD_Y + 1), \
			BUTTON_TEXTURE_TEXCOORD_RB(N##_TEXCOORD_X), \
			BUTTON_TEXTURE_TEXCOORD_LT(N##_TEXCOORD_Y + 1) \
		};

#define MAKE_TEXCOORD_ARRAY_90(N) \
		GLfloat texcoord_##N##90_release[] = { \
			BUTTON_TEXTURE_TEXCOORD_LT(N##_TEXCOORD_X), \
			BUTTON_TEXTURE_TEXCOORD_LT(N##_TEXCOORD_Y), \
			BUTTON_TEXTURE_TEXCOORD_LT(N##_TEXCOORD_X), \
			BUTTON_TEXTURE_TEXCOORD_RB(N##_TEXCOORD_Y), \
			BUTTON_TEXTURE_TEXCOORD_RB(N##_TEXCOORD_X), \
			BUTTON_TEXTURE_TEXCOORD_LT(N##_TEXCOORD_Y), \
			BUTTON_TEXTURE_TEXCOORD_RB(N##_TEXCOORD_X), \
			BUTTON_TEXTURE_TEXCOORD_RB(N##_TEXCOORD_Y) \
		}; \
		GLfloat texcoord_##N##90_press[] = { \
			BUTTON_TEXTURE_TEXCOORD_LT(N##_TEXCOORD_X), \
			BUTTON_TEXTURE_TEXCOORD_LT(N##_TEXCOORD_Y + 1), \
			BUTTON_TEXTURE_TEXCOORD_LT(N##_TEXCOORD_X), \
			BUTTON_TEXTURE_TEXCOORD_RB(N##_TEXCOORD_Y + 1), \
			BUTTON_TEXTURE_TEXCOORD_RB(N##_TEXCOORD_X), \
			BUTTON_TEXTURE_TEXCOORD_LT(N##_TEXCOORD_Y + 1), \
			BUTTON_TEXTURE_TEXCOORD_RB(N##_TEXCOORD_X), \
			BUTTON_TEXTURE_TEXCOORD_RB(N##_TEXCOORD_Y + 1) \
		};

#define MAKE_TEXCOORD_ARRAY_270(N) \
		GLfloat texcoord_##N##270_release[] = { \
			BUTTON_TEXTURE_TEXCOORD_RB(N##_TEXCOORD_X), \
			BUTTON_TEXTURE_TEXCOORD_RB(N##_TEXCOORD_Y), \
			BUTTON_TEXTURE_TEXCOORD_RB(N##_TEXCOORD_X), \
			BUTTON_TEXTURE_TEXCOORD_LT(N##_TEXCOORD_Y), \
			BUTTON_TEXTURE_TEXCOORD_LT(N##_TEXCOORD_X), \
			BUTTON_TEXTURE_TEXCOORD_RB(N##_TEXCOORD_Y), \
			BUTTON_TEXTURE_TEXCOORD_LT(N##_TEXCOORD_X), \
			BUTTON_TEXTURE_TEXCOORD_LT(N##_TEXCOORD_Y) \
		}; \
		GLfloat texcoord_##N##270_press[] = { \
			BUTTON_TEXTURE_TEXCOORD_RB(N##_TEXCOORD_X), \
			BUTTON_TEXTURE_TEXCOORD_RB(N##_TEXCOORD_Y + 1), \
			BUTTON_TEXTURE_TEXCOORD_RB(N##_TEXCOORD_X), \
			BUTTON_TEXTURE_TEXCOORD_LT(N##_TEXCOORD_Y + 1), \
			BUTTON_TEXTURE_TEXCOORD_LT(N##_TEXCOORD_X), \
			BUTTON_TEXTURE_TEXCOORD_RB(N##_TEXCOORD_Y + 1), \
			BUTTON_TEXTURE_TEXCOORD_LT(N##_TEXCOORD_X), \
			BUTTON_TEXTURE_TEXCOORD_LT(N##_TEXCOORD_Y + 1) \
		};
		MAKE_TEXCOORD_ARRAY(FORWARD)
		MAKE_TEXCOORD_ARRAY(BACKWARD)
		MAKE_TEXCOORD_ARRAY(LEFT)
		MAKE_TEXCOORD_ARRAY(RIGHT)
		MAKE_TEXCOORD_ARRAY(CLOSE)
		MAKE_TEXCOORD_ARRAY_90(ARROW)
		MAKE_TEXCOORD_ARRAY_270(ARROW)
		MAKE_TEXCOORD_ARRAY_270(PLAY)
		MAKE_TEXCOORD_ARRAY(STOP)
		buttons[GLWidget::ForwardButtonBuffer].buffer = load_button(BUTTON_WIDTH, BUTTON_WIDTH, texcoord_FORWARD_release, texcoord_FORWARD_press);
		buttons[GLWidget::BackwardButtonBuffer].buffer = load_button(BUTTON_WIDTH, BUTTON_WIDTH, texcoord_BACKWARD_release, texcoord_BACKWARD_press);
		buttons[GLWidget::LeftButtonBuffer].buffer = load_button(BUTTON_WIDTH, BUTTON_WIDTH, texcoord_LEFT_release, texcoord_LEFT_press);
		buttons[GLWidget::RightButtonBuffer].buffer = load_button(BUTTON_WIDTH, BUTTON_WIDTH, texcoord_RIGHT_release, texcoord_RIGHT_press);
		buttons[GLWidget::UpButtonBuffer].buffer = load_button(BUTTON_WIDTH, BUTTON_WIDTH, texcoord_ARROW90_release, texcoord_ARROW90_press);
		buttons[GLWidget::DownButtonBuffer].buffer = load_button(BUTTON_WIDTH, BUTTON_WIDTH, texcoord_ARROW270_release, texcoord_ARROW270_press);
		buttons[GLWidget::PlayButtonBuffer].buffer = load_button(BUTTON_WIDTH, BUTTON_WIDTH, texcoord_PLAY270_release, texcoord_PLAY270_press);
		buttons[GLWidget::GLWidget::StopButtonBuffer].buffer = load_button(BUTTON_WIDTH, BUTTON_WIDTH, texcoord_STOP_release, texcoord_STOP_press);
		buttons[CloseButtonBuffer].buffer = load_button(BUTTON_WIDTH, BUTTON_WIDTH, texcoord_CLOSE_release, texcoord_CLOSE_press);
#undef MAKE_TEXCOORD_ARRAY
#undef MAKE_TEXCOORD_ARRAY_90
#undef MAKE_TEXCOORD_ARRAY_270
}

void GLWidget::resizeGL(int w, int h)
{
		QGLWidget::makeCurrent();
    if(w <= 0)
        w = 1;
    if(h <= 0)
        h = 1;

    glViewport(0, 0, GLsizei(w), GLsizei(h));
}

void GLWidget::keyPressEvent(QKeyEvent *e)
{
    int key = e -> key();
    keyboardHandler(key, GL_TRUE, 0, 0);
}

void GLWidget::keyReleaseEvent(QKeyEvent *e)
{
    int key = e -> key();
    keyboardHandler(key, GL_FALSE, 0, 0);
}

void GLWidget::mousePressEvent(QMouseEvent *e)
{
		mousePressed = true;
    int button = e -> buttons();
    mouseClickHandler(button, GL_TRUE, e -> x(), e -> y());
    ox = e -> x();
    oy = e -> y();
}

void GLWidget::mouseReleaseEvent(QMouseEvent *e)
{
		mousePressed = false;
    int button = e -> buttons();
    mouseClickHandler(button, GL_FALSE, e -> x(), e -> y());
    ox = 0;
    oy = 0;
}

void GLWidget::wheelEvent(QWheelEvent *e)
{
    if(e -> delta() < 0 && scale < MAX_SCALE_LIMIT)
        scale = KARIN_MIN(scale + SCALE_UNIT, MAX_SCALE_LIMIT);
    else if(e -> delta() > 0 && scale > MIN_SCALE_LIMIT)
        scale = KARIN_MAX(scale - SCALE_UNIT, MIN_SCALE_LIMIT);
    else
        return;
		updateGL();
}

void GLWidget::mouseMoveEvent(QMouseEvent *e)
{
    int button = e -> button();
    int x = e -> x();
    int y = e -> y();
    int dx = x - ox;
    int dy = y - oy;
    ox = x;
    oy = y;
    mouseMotionHandler(button, mousePressed, x, y, dx, dy);

}

void GLWidget::idle()
{
	bool running = false;
	for(int i = 0; i < TotalPosition; i++)
		if(move[i])
		{
			running = true;
			break;
		}
	if(!running)
	{
		for(int i = 0; i < TotalOrientation; i++)
			if(turn[i])
			{
				running = true;
				break;
			}
	}
	if(!running)
	{
		running = (delta_x != 0 || delta_y != 0);
	}
	if(!running)
	{
		stop();
		updateGL();
		return;
	}

	if(turn[TurnUp])
		x_r -= TURN_UNIT;
	if(turn[TurnDown])
		x_r += TURN_UNIT;
	if(turn[TurnLeft])
		y_r -= _orientation == GLWidget::Landscape ? TURN_UNIT : -TURN_UNIT;
	if(turn[TurnRight])
		y_r += _orientation == GLWidget::Landscape ? TURN_UNIT : -TURN_UNIT;
	y_r = formatAngle(y_r);
	x_r = formatAngle(x_r);

	GLfloat xp = x_t;
	GLfloat yp = z_t;
	GLfloat zp = y_t;
	if(move[Forward])
	{
		GLfloat y = ator(y_r);
		GLfloat x = ator(x_r);
		xp -= cos(x) * sin(y) * MOVE_UNIT;
		yp += sin(x) * MOVE_UNIT;
		zp += cos(x) * cos(y) * MOVE_UNIT;
	}
	if(move[Backward])
	{
		GLfloat y = ator(y_r);
		GLfloat x = ator(x_r);
		xp += cos(x) * sin(y) * MOVE_UNIT;
		yp -= sin(x) * MOVE_UNIT;
		zp -= cos(x) * cos(y) * MOVE_UNIT;
	}
	if(move[Left])
	{
		GLfloat y = ator(y_r);
		GLfloat x = ator(x_r);
		xp += cos(x) * cos(y) * MOVE_UNIT;
		yp -= sin(x) * MOVE_UNIT;
		zp += cos(x) * sin(y) * MOVE_UNIT;
	}
	if(move[Right])
	{
		GLfloat y = ator(y_r);
		GLfloat x = ator(x_r);
		xp -= cos(x) * cos(y) * MOVE_UNIT;
		yp += sin(x) * MOVE_UNIT;
		zp -= cos(x) * sin(y) * MOVE_UNIT;
	}
	if(move[Up])
		yp -= _orientation == GLWidget::Landscape ? MOVE_UNIT : -MOVE_UNIT;
	if(move[Down])
		yp += _orientation == GLWidget::Landscape ? MOVE_UNIT : -MOVE_UNIT;
	xAxisRotate += delta_y * ROTATION_UNIT;
	yAxisRotate += delta_x * ROTATION_UNIT;
	delta_x = 0;
	delta_y = 0;
	x_t = xp;
	y_t = zp;
	z_t = yp;
	//if(!animationTimer || !animationTimer -> isActive())
		updateGL();
}

void GLWidget::shutdown()
{
		QGLWidget::makeCurrent();
		if(g_tex)
		{
			if(glIsTexture(g_tex -> texid))
				glDeleteTextures(1, &(g_tex -> texid));
			free_texture(g_tex);
		}
		int i;
		for(i = 0; i < TotalBuffer; i++)
		{
			if(glIsBuffer(buffers[i]))
				glDeleteBuffers(1, buffers + i);
			buffers[i] = 0;
		}
		for(i = 0; i < GLWidget::TotalBoneBuffer; i++)
		{
			if(glIsBuffer(boneBuffers[i]))
				glDeleteBuffers(1, boneBuffers + i);
			boneBuffers[i] = 0;
			boneCount[i] = 0;
		}
		free_mesh(mesh);
		free_anim(anim);
		mesh = 0;
    g_tex = 0;
		anim = 0;
}

void GLWidget::mouseClickHandler(int button, bool pressed, int x, int y)
{
    if(!pressed)
    {
        delta_x = 0;
        delta_y = 0;
    }
		GLuint index = _orientation == GLWidget::Landscape ? 0 : 1;
		if(X_COORD_IS_IN_RANGE(x, buttons[CloseButtonBuffer].xCoord[index], BUTTON_WIDTH) && Y_COORD_IS_IN_RANGE(y, buttons[CloseButtonBuffer].yCoord[index], BUTTON_WIDTH))
		{
			keyboardHandler(Qt::Key_C, pressed, 0, 0);
		}
		else if(X_COORD_IS_IN_RANGE(x, buttons[PlayButtonBuffer].xCoord[index], BUTTON_WIDTH) && Y_COORD_IS_IN_RANGE(y, buttons[PlayButtonBuffer].yCoord[index], BUTTON_WIDTH))
		{
			keyboardHandler(Qt::Key_R, pressed, 0, 0);
		}
		else if(X_COORD_IS_IN_RANGE(x, buttons[ForwardButtonBuffer].xCoord[index], BUTTON_WIDTH) && Y_COORD_IS_IN_RANGE(y, buttons[ForwardButtonBuffer].yCoord[index], BUTTON_WIDTH))
		{
			buttons[GLWidget::ForwardButtonBuffer].pressed = (GLboolean)pressed;
			keyboardHandler(Qt::Key_W, pressed, 0, 0);
		}
		else if(X_COORD_IS_IN_RANGE(x, buttons[BackwardButtonBuffer].xCoord[index], BUTTON_WIDTH) && Y_COORD_IS_IN_RANGE(y, buttons[BackwardButtonBuffer].yCoord[index], BUTTON_WIDTH))
		{
			buttons[GLWidget::BackwardButtonBuffer].pressed = (GLboolean)pressed;
			keyboardHandler(Qt::Key_S, pressed, 0, 0);
		}
		else if(X_COORD_IS_IN_RANGE(x, buttons[LeftButtonBuffer].xCoord[index], BUTTON_WIDTH) && Y_COORD_IS_IN_RANGE(y, buttons[LeftButtonBuffer].yCoord[index], BUTTON_WIDTH))
		{
			buttons[GLWidget::LeftButtonBuffer].pressed = (GLboolean)pressed;
			keyboardHandler(Qt::Key_A, pressed, 0, 0);
		}
		else if(X_COORD_IS_IN_RANGE(x, buttons[RightButtonBuffer].xCoord[index], BUTTON_WIDTH) && Y_COORD_IS_IN_RANGE(y, buttons[RightButtonBuffer].yCoord[index], BUTTON_WIDTH))
		{
			buttons[GLWidget::RightButtonBuffer].pressed = (GLboolean)pressed;
			keyboardHandler(Qt::Key_D, pressed, 0, 0);
		}
		else if(X_COORD_IS_IN_RANGE(x, buttons[UpButtonBuffer].xCoord[index], BUTTON_WIDTH) && Y_COORD_IS_IN_RANGE(y, buttons[UpButtonBuffer].yCoord[index], BUTTON_WIDTH))
		{
			buttons[GLWidget::UpButtonBuffer].pressed = (GLboolean)pressed;
			keyboardHandler(Qt::Key_E, pressed, 0, 0);
		}
		else if(X_COORD_IS_IN_RANGE(x, buttons[DownButtonBuffer].xCoord[index], BUTTON_WIDTH) && Y_COORD_IS_IN_RANGE(y, buttons[DownButtonBuffer].yCoord[index], BUTTON_WIDTH))
		{
			buttons[GLWidget::DownButtonBuffer].pressed = (GLboolean)pressed;
			keyboardHandler(Qt::Key_Q, pressed, 0, 0);
		}
}

void GLWidget::mouseMotionHandler(int button, bool pressed, int x, int y, int dx, int dy)
{
		if(!pressed)
			return;
		int lx = x - dx;
		int ly = y - dy;
		int st[] = {0, 0, 0, 0, 0, 0};
		GLuint index = _orientation == GLWidget::Landscape ? 0 : 1;
		if(X_COORD_IS_IN_RANGE(lx, buttons[ForwardButtonBuffer].xCoord[index], BUTTON_WIDTH) && Y_COORD_IS_IN_RANGE(ly, buttons[ForwardButtonBuffer].yCoord[index], BUTTON_WIDTH))
			st[0] |= 2;
		else if(X_COORD_IS_IN_RANGE(lx, buttons[BackwardButtonBuffer].xCoord[index], BUTTON_WIDTH) && Y_COORD_IS_IN_RANGE(ly, buttons[BackwardButtonBuffer].yCoord[index], BUTTON_WIDTH))
			st[1] |= 2;
		else if(X_COORD_IS_IN_RANGE(lx, buttons[LeftButtonBuffer].xCoord[index], BUTTON_WIDTH) && Y_COORD_IS_IN_RANGE(ly, buttons[LeftButtonBuffer].yCoord[index], BUTTON_WIDTH))
			st[2] |= 2;
		else if(X_COORD_IS_IN_RANGE(lx, buttons[RightButtonBuffer].xCoord[index], BUTTON_WIDTH) && Y_COORD_IS_IN_RANGE(ly, buttons[RightButtonBuffer].yCoord[index], BUTTON_WIDTH))
			st[3] |= 2;
		else if(X_COORD_IS_IN_RANGE(lx, buttons[UpButtonBuffer].xCoord[index], BUTTON_WIDTH) && Y_COORD_IS_IN_RANGE(ly, buttons[UpButtonBuffer].yCoord[index], BUTTON_WIDTH))
			st[4] |= 2;
		else if(X_COORD_IS_IN_RANGE(lx, buttons[DownButtonBuffer].xCoord[index], BUTTON_WIDTH) && Y_COORD_IS_IN_RANGE(ly, buttons[DownButtonBuffer].yCoord[index], BUTTON_WIDTH))
			st[5] |= 2;

		if(X_COORD_IS_IN_RANGE(x, buttons[ForwardButtonBuffer].xCoord[index], BUTTON_WIDTH) && Y_COORD_IS_IN_RANGE(y, buttons[ForwardButtonBuffer].yCoord[index], BUTTON_WIDTH))
			st[0] |= 1;
		else if(X_COORD_IS_IN_RANGE(x, buttons[BackwardButtonBuffer].xCoord[index], BUTTON_WIDTH) && Y_COORD_IS_IN_RANGE(y, buttons[BackwardButtonBuffer].yCoord[index], BUTTON_WIDTH))
			st[1] |= 1;
		else if(X_COORD_IS_IN_RANGE(x, buttons[LeftButtonBuffer].xCoord[index], BUTTON_WIDTH) && Y_COORD_IS_IN_RANGE(y, buttons[LeftButtonBuffer].yCoord[index], BUTTON_WIDTH))
			st[2] |= 1;
		else if(X_COORD_IS_IN_RANGE(x, buttons[RightButtonBuffer].xCoord[index], BUTTON_WIDTH) && Y_COORD_IS_IN_RANGE(y, buttons[RightButtonBuffer].yCoord[index], BUTTON_WIDTH))
			st[3] |= 1;
		else if(X_COORD_IS_IN_RANGE(x, buttons[UpButtonBuffer].xCoord[index], BUTTON_WIDTH) && Y_COORD_IS_IN_RANGE(y, buttons[UpButtonBuffer].yCoord[index], BUTTON_WIDTH))
			st[4] |= 1;
		else if(X_COORD_IS_IN_RANGE(x, buttons[DownButtonBuffer].xCoord[index], BUTTON_WIDTH) && Y_COORD_IS_IN_RANGE(y, buttons[DownButtonBuffer].yCoord[index], BUTTON_WIDTH))
			st[5] |= 1;

		if(st[0] == 1)
		{
			buttons[GLWidget::ForwardButtonBuffer].pressed = GL_TRUE;
			keyboardHandler(Qt::Key_W, true, 0, 0);
		}
		else if(st[1] == 1)
		{
			buttons[GLWidget::BackwardButtonBuffer].pressed = GL_TRUE;
			keyboardHandler(Qt::Key_S, true, 0, 0);
		}
		else if(st[2] == 1)
		{
			buttons[GLWidget::LeftButtonBuffer].pressed = GL_TRUE;
			keyboardHandler(Qt::Key_A, true, 0, 0);
		}
		else if(st[3] == 1)
		{
			buttons[GLWidget::RightButtonBuffer].pressed = GL_TRUE;
			keyboardHandler(Qt::Key_D, true, 0, 0);
		}
		else if(st[4] == 1)
		{
			buttons[GLWidget::UpButtonBuffer].pressed = GL_TRUE;
			keyboardHandler(Qt::Key_E, true, 0, 0);
		}
		else if(st[5] == 1)
		{
			buttons[GLWidget::DownButtonBuffer].pressed = GL_TRUE;
			keyboardHandler(Qt::Key_Q, true, 0, 0);
		}
		else if(st[0] == 2)
		{
			buttons[GLWidget::ForwardButtonBuffer].pressed = GL_FALSE;
			keyboardHandler(Qt::Key_W, false, 0, 0);
		}
		else if(st[1] == 2)
		{
			buttons[GLWidget::BackwardButtonBuffer].pressed = GL_FALSE;
			keyboardHandler(Qt::Key_S, false, 0, 0);
		}
		else if(st[2] == 2)
		{
			buttons[GLWidget::LeftButtonBuffer].pressed = GL_FALSE;
			keyboardHandler(Qt::Key_A, false, 0, 0);
		}
		else if(st[3] == 2)
		{
			buttons[GLWidget::RightButtonBuffer].pressed = GL_FALSE;
			keyboardHandler(Qt::Key_D, false, 0, 0);
		}
		else if(st[4] == 2)
		{
			buttons[GLWidget::UpButtonBuffer].pressed = GL_FALSE;
			keyboardHandler(Qt::Key_E, false, 0, 0);
		}
		else if(st[5] == 2)
		{
			buttons[GLWidget::DownButtonBuffer].pressed = GL_FALSE;
			keyboardHandler(Qt::Key_Q, false, 0, 0);
		}
		
		if(st[0] == 0 && st[1] == 0 && st[2] == 0 && st[3] == 0 && st[4] == 0 && st[5] == 0)
		{
			delta_x = dx;
			delta_y = dy;
			play();
		}
		else
		{
			delta_x = 0;
			delta_y = 0;
		}
}

void GLWidget::keyboardHandler(unsigned int key, bool pressed, int x, int y)
{
    Position p = TotalPosition;
    Orientation o = TotalOrientation;
    switch(key)
    {
        case Qt::Key_W:
            p = Forward;
            break;
        case Qt::Key_S:
            p = Backward;
            break;
        case Qt::Key_A:
            p = Left;
            break;
        case Qt::Key_D:
            p = Right;
            break;
        case Qt::Key_E:
            p = Up;
            break;
        case Qt::Key_Q:
            p = Down;
            break;
        case Qt::Key_Up:
            o = TurnUp;
            break;
        case Qt::Key_Down:
            o = TurnDown;
            break;
        case Qt::Key_Left:
            o = TurnLeft;
            break;
        case Qt::Key_Right:
            o = TurnRight;
        break;
    case Qt::Key_N:
        function[1] = (GLboolean)pressed;
        function[0] = GL_FALSE;
        break;
    case Qt::Key_P:
        function[0] = (GLboolean)pressed;
        function[1] = GL_FALSE;
        break;
    case Qt::Key_R:
        if(pressed)
            function[3] = !function[3];
        function[2] = GL_FALSE;
				if(anim)
				{
					if(function[3])
						playAnimation();
					else
					{
						updateGL();
						stopAnimation();
					}
				}
				break;
		case Qt::Key_T:
				if(pressed)
					function[2] = !function[2];
				function[3] = GL_FALSE;
				break;
		case Qt::Key_C:
				if(pressed)
				{
					this -> close();
					return;
				}

		default:
				return;
		}
		if(p != TotalPosition)
			move[p] = (GLboolean)pressed;
		if(o != TotalOrientation)
			turn[o] = (GLboolean)pressed;
		if((p != TotalPosition || o != TotalOrientation) && pressed)
			play();
}

void GLWidget::play()
{
	if(!timer)
	{
		timer = new QTimer(this);
		timer -> setSingleShot(false);
		connect(timer, SIGNAL(timeout()), this, SLOT(idle()));
	}
	if(timer -> isActive())
		updateGL();
	else
	{
		timer -> setInterval(playInterval);
		timer -> start();
	}
}

void GLWidget::stop()
{
	if(timer && timer -> isActive())
		timer -> stop();
}

GLWidget::Program GLWidget::initProgram(const char *files[])
{
	Program program;
	if(!files)
		return program;
	QGLWidget::makeCurrent();
	GLint linked;
	char *vShaderStr = glkLoadShaderSource(files[VertexShader]);
	char *fShaderStr = glkLoadShaderSource(files[FragmentShader]);
	program.shaders[GLWidget::VertexShader] = glkLoadShader(GL_VERTEX_SHADER, vShaderStr);
	program.shaders[GLWidget::FragmentShader] = glkLoadShader(GL_FRAGMENT_SHADER, fShaderStr);
	free(vShaderStr);
	free(fShaderStr);
	program.program = glCreateProgram();
	if(program.program == 0)
	{
		fprintf(stderr, "glCreateProgram() -> error");
		return Program();
	}
	glAttachShader(program.program, program.shaders[VertexShader]);
	glAttachShader(program.program, program.shaders[FragmentShader]);
	glLinkProgram(program.program);
	glGetProgramiv(program.program, GL_LINK_STATUS, &linked);
	if(!linked)
	{
		glkGetProgramLog(program.program, 0);
		glDeleteProgram(program.program);
		return Program();
	}
	return program;
}

void GLWidget::initBuffer()
{
	QGLWidget::makeCurrent();
	if(mesh)
	{
		buffers[GLWidget::VertexBuffer] = glkLoadBuffer(GL_ARRAY_BUFFER, GL_STATIC_DRAW, sizeof(Vertex) * mesh -> numVerts, (GLvoid *)mesh -> vertices);
		buffers[GLWidget::IndexBuffer] = glkLoadBuffer(GL_ELEMENT_ARRAY_BUFFER, GL_STATIC_DRAW, sizeof(GLushort) * mesh -> numIndices, (GLvoid *)mesh -> indices);
		buffers[GLWidget::AnimationVertexBuffer] = glkLoadBuffer(GL_ARRAY_BUFFER, GL_DYNAMIC_DRAW, sizeof(Vertex) * mesh -> numVerts, (GLvoid *)mesh -> vertices);

		GLfloat *bonePoints = (GLfloat *)malloc(mesh -> bone.numBones * 3 * sizeof(GLfloat));
		memset(bonePoints, 0, sizeof(GLfloat) * mesh -> bone.numBones * 3);
		for(int i = 0; i < mesh -> bone.numBones; i++)
		{
			Vec3<float> v(1.0f, 1.0f, 1.0f);
			Matrix44<float> tm = mesh -> bone.bones[i].origMatrix;
			v = v * tm;
			bonePoints[i * 3 + 0] = v.x;
			bonePoints[i * 3 + 1] = v.y;
			bonePoints[i * 3 + 2] = v.z;
		}
		boneBuffers[GLWidget::BonePointBuffer] = glkLoadBuffer(GL_ARRAY_BUFFER, GL_STATIC_DRAW, sizeof(GLfloat) * 3 * mesh -> bone.numBones, (GLvoid *)bonePoints);
		boneBuffers[GLWidget::AnimationBonePointBuffer] = glkLoadBuffer(GL_ARRAY_BUFFER, GL_DYNAMIC_DRAW, sizeof(GLfloat) * 3 * mesh -> bone.numBones, (GLvoid *)bonePoints);
		boneCount[GLWidget::BonePointBuffer] = mesh -> bone.numBones;

		size_t size = 0;
		for(int i = 0; i < mesh -> bone.numBones; i++)
		{
			for(int j = 0; j < mesh -> bone.numBones; j++)
			{
				if(mesh -> bone.bones[j].parent == i)
					size++;
			}
		}

		GLfloat *boneLines = (GLfloat *)malloc(size * 2 * 3 * sizeof(GLfloat));
		memset(boneLines, 0, sizeof(GLfloat) * size * 2 * 3);
		int c = 0;
		for(int i = 0; i < mesh -> bone.numBones; i++)
		{
			for(int j = 0; j < mesh -> bone.numBones; j++)
			{
				if(mesh -> bone.bones[j].parent == i)
				{
					boneLines[c * 6 + 0] = bonePoints[i * 3 + 0];
					boneLines[c * 6 + 1] = bonePoints[i * 3 + 1];
					boneLines[c * 6 + 2] = bonePoints[i * 3 + 2];
					boneLines[c * 6 + 3] = bonePoints[j * 3 + 0];
					boneLines[c * 6 + 4] = bonePoints[j * 3 + 1];
					boneLines[c * 6 + 5] = bonePoints[j * 3 + 2];
					c++;
				}
			}
		}
		boneBuffers[GLWidget::BoneLineBuffer] = glkLoadBuffer(GL_ARRAY_BUFFER, GL_STATIC_DRAW, sizeof(GLfloat) * 3 * 2 * size, (GLvoid *)boneLines);
		boneBuffers[GLWidget::AnimationBoneLineBuffer] = glkLoadBuffer(GL_ARRAY_BUFFER, GL_DYNAMIC_DRAW, sizeof(GLfloat) * 3 * 2 * size, (GLvoid *)boneLines);
		boneCount[GLWidget::BoneLineBuffer] = size * 2;
		free(boneLines);
		free(bonePoints);
	}
}

void GLWidget::drawModel(GLWidget::RenderType type)
{
	if(!mesh)
		return;
	QGLWidget::makeCurrent();

	glUseProgram(programs[GLWidget::TextureProgram].program);

	GLint v_ModelviewProjectionMatrix = glGetUniformLocation(programs[GLWidget::TextureProgram].program, V_MODELVIEWPROJECTIONMATRIX);
	GLint vPosition = glGetAttribLocation(programs[GLWidget::TextureProgram].program, VPOSITION);
	GLint vTexcoord = glGetAttribLocation(programs[GLWidget::TextureProgram].program, VTEXCOORD);
	GLint fTexture = glGetUniformLocation(programs[GLWidget::TextureProgram].program, FTEXTURE);
	GLint fHasTexture = glGetUniformLocation(programs[GLWidget::TextureProgram].program, FHASTEXTURE);

	glEnableVertexAttribArray(vPosition);
	glEnableVertexAttribArray(vTexcoord);

	Matrix44<GLfloat> modelviewProjectionMatrix = matrixs[GLWidget::ModelviewMatrix] * matrixs[GLWidget::ProjectionMatrix];
	glUniformMatrix4fv(v_ModelviewProjectionMatrix, 1, GL_FALSE, (GLfloat *)modelviewProjectionMatrix.x);

	glUniform1i(fTexture, 0);
	glUniform1i(fHasTexture, (GLboolean)(g_tex && glIsTexture(g_tex -> texid)));
	/*
		 for(int i = 0; i < sknHeader -> numMaterials; i++)
		 printf("%d ___ %d | %d\n", i, (glIsTexture(g_tex[i])), g_tex[i]);
		 */

	GLint attributes[] = {
		vPosition,
		vTexcoord
	};

	if(type == GLWidget::StaticModel)
	{
		GLuint mbuffers[] = {
			buffers[GLWidget::VertexBuffer],
			buffers[GLWidget::IndexBuffer]
		};
		drawSknBUFFER(mesh, mbuffers, attributes, g_tex);
	}
	else
	{
		GLuint mbuffers[] = {
			buffers[GLWidget::AnimationVertexBuffer],
			buffers[GLWidget::IndexBuffer]
		};
		drawAnmSknBUFFER(mesh, mbuffers, attributes, g_tex);
	}

	glDisableVertexAttribArray(vPosition);
	glDisableVertexAttribArray(vTexcoord);
}

void GLWidget::drawSkeleton(GLWidget::RenderType type)
{
	if(!mesh)
		return;
	QGLWidget::makeCurrent();

	glUseProgram(programs[GLWidget::FlatProgram].program);

	GLint v_ModelviewProjectionMatrix = glGetUniformLocation(programs[GLWidget::FlatProgram].program, V_MODELVIEWPROJECTIONMATRIX);
	GLint vPosition = glGetAttribLocation(programs[GLWidget::FlatProgram].program, VPOSITION);
	GLint vColor = glGetAttribLocation(programs[GLWidget::FlatProgram].program, VCOLOR);
	GLint vPointSize = glGetAttribLocation(programs[GLWidget::FlatProgram].program, VPOINTSIZE);

	glEnableVertexAttribArray(vPosition);

	Matrix44<GLfloat> modelviewProjectionMatrix = matrixs[GLWidget::ModelviewMatrix] * matrixs[GLWidget::ProjectionMatrix];
	glUniformMatrix4fv(v_ModelviewProjectionMatrix, 1, GL_FALSE, (GLfloat *)modelviewProjectionMatrix.x);

	GLint attributes[] = {
		vPosition,
		vColor,
		vPointSize
	};

	GLfloat color[2][4] = {
		{1.0f, 0.0f, 0.0f, 0.9f},
		{0.0f, 0.0f, 1.0f, 0.9f}
	};
	GLfloat size[] = {4.0f, 2.0f};

	if(type == GLWidget::StaticBone)
	{
		GLuint bbuffers[] = {
			boneBuffers[GLWidget::BonePointBuffer],
			boneBuffers[GLWidget::BoneLineBuffer]
		};
		drawBoneBUFFER(bbuffers, boneCount, attributes, color, size);
	}
	else
	{
		if(mesh)
		{
			GLuint bbuffers[] = {
				boneBuffers[GLWidget::AnimationBonePointBuffer],
				boneBuffers[GLWidget::AnimationBoneLineBuffer]
			};
			drawAnimationBoneBUFFER(&(mesh -> bone), bbuffers, boneCount, attributes, color, size);
		}
	}

	glDisableVertexAttribArray(vPosition);
}

QString GLWidget::championId() const
{
	return _championId;
}

QString GLWidget::skinId() const
{
	return _skinId;
}

GLWidget::RenderType GLWidget::renderType() const
{
	return _renderType;
}

void GLWidget::setRenderType(GLWidget::RenderType type)
{
	if(_renderType != type)
	{
		_renderType = type;
		emit renderTypeChanged(_renderType);
		if(mesh && anim)
			playAnimation();
		updateGL();
		QGLWidget::showFullScreen();
	}
}

void GLWidget::setChampionId(const QString &championId)
{
	if(_championId != championId)
	{
		_championId = championId;
		emit championIdChanged(_championId);
	}
}

void GLWidget::setSkinId(const QString &skinId)
{
	if(_skinId != skinId)
	{
		_skinId = skinId;
		emit skinIdChanged(_skinId);
	}
}

void GLWidget::setLoadMessage(const QString &msg)
{
	_loadMessage += msg + '\n';
#ifdef _KATARINA_DBG
	qDebug() << msg;
#endif
	emit loadMessageChanged(msg);
}

QString GLWidget::loadMessage() const
{
	return _loadMessage;
}

void GLWidget::closeEvent(QCloseEvent *e)
{
	updateGL();
	stop();
	stopAnimation();
	emit closing();
	QGLWidget::closeEvent(e);
}

void GLWidget::render2D()
{
	matrixs[GLWidget::ProjectionMatrix].makeIdentity();
	GLfloat w = QGLWidget::width();
	GLfloat h = QGLWidget::height();
	glkOrtho2D((GLfloat *)(matrixs[GLWidget::ProjectionMatrix].x), 0, w, 0, h);
	glDisable(GL_DEPTH_TEST);
}

void GLWidget::render3D()
{
	matrixs[GLWidget::ProjectionMatrix].makeIdentity();
	glkPerspective((GLfloat *)(matrixs[GLWidget::ProjectionMatrix].x), 45.0, (GLfloat)(QGLWidget::width()) / (GLfloat)(QGLWidget::height()), 10.0, 10000.0);
	glEnable(GL_DEPTH_TEST);
}

void GLWidget::hideEvent(QHideEvent *e)
{
	updateGL();
	stop();
	stopAnimation();
	QGLWidget::hideEvent(e);
}

void GLWidget::changeEvent(QEvent *e)
{
	if(e -> type() == QEvent::WindowStateChange)
		if(this -> windowState() == Qt::WindowMinimized)
		{
			updateGL();
			stop();
			stopAnimation();
		}
	QGLWidget::changeEvent(e);
}

void GLWidget::setAnimationList()
{
	_animationList.clear();
	if(anim)
	{
		for(int i = 0; i < anim -> numAnims; i++)
			_animationList.push_back(anim -> animations[i].name);
	}
	emit animationListChanged(_animationList);
}

QStringList GLWidget::animationList() const
{
	return _animationList;
}

void GLWidget::loadAnim(int index)
{
	if(!mesh || !anim)
	{
		index = -1;
		return;
	}
	//if(_animationIndex != index)
	{
		resetRender();
		stopAnimation();
		_animationIndex = index;
		emit animationIndexChanged(_animationIndex);
		if(mesh && anim)
		{
			_frame = 0;
			function[3] = GL_TRUE;
			//printf("%d____\n", (anim -> animations[_animationIndex].numBones));
			setLoadMessage(tr("Load animation") + " -> " + anim -> animations[_animationIndex].name + " (" + tr("Frame count") + " -> " + QString::number(anim -> animations[_animationIndex].animBones[0].numFrames) + ")");
			setLoadMessage(tr("Rendering"));
			QGLWidget::showFullScreen();
			updateGL();
			animationInterval = 1000 / anim -> animations[_animationIndex].fps;
			if(animationInterval == 0)
				animationInterval = DEFAULT_ANIMATION_INTERVAL;
			playAnimation();
			//qDebug()<<anim -> animations[_animationIndex].fps<<"__"<<anim -> animations[_animationIndex].duration<<(1000 / anim -> animations[_animationIndex].fps)<<"||"<<(anim->animations[_animationIndex].animBones[0].numFrames);
		}
	}
}

int GLWidget::animationIndex() const
{
	return _animationIndex;
}

void GLWidget::playAnimation()
{
	if(!animationTimer)
	{
		animationTimer = new QTimer(this);
		animationTimer -> setSingleShot(false);
		connect(animationTimer, SIGNAL(timeout()), this, SLOT(nextFrame()));
	}
	if(animationTimer -> isActive())
	{
		animationTimer -> setInterval(animationInterval);
		updateGL();
	}
	else
	{
		animationTimer -> setInterval(animationInterval);
		animationTimer -> start();
	}
}

void GLWidget::stopAnimation()
{
	if(animationTimer && animationTimer -> isActive())
		animationTimer -> stop();
}

void GLWidget::nextFrame()
{
	if(!anim)
	{
		_frame = -1;
		return;
	}
	//qDebug()<<_frame;
	if(_frame >= anim -> animations[_animationIndex].animBones[0].numFrames - 1)
		_frame = 0;
	else if(_frame < 0)
		_frame = 0;
	else
		_frame++;
	updateGL();
}

void GLWidget::draw2DScene()
{
	QGLWidget::makeCurrent();

	glUseProgram(programs[GLWidget::TextureProgram].program);

	GLint v_ModelviewProjectionMatrix = glGetUniformLocation(programs[GLWidget::TextureProgram].program, V_MODELVIEWPROJECTIONMATRIX);
	GLint vPosition = glGetAttribLocation(programs[GLWidget::TextureProgram].program, VPOSITION);
	GLint vTexcoord = glGetAttribLocation(programs[GLWidget::TextureProgram].program, VTEXCOORD);
	GLint fTexture = glGetUniformLocation(programs[GLWidget::TextureProgram].program, FTEXTURE);
	GLint fHasTexture = glGetUniformLocation(programs[GLWidget::TextureProgram].program, FHASTEXTURE);

	glEnableVertexAttribArray(vPosition);
	glEnableVertexAttribArray(vTexcoord);

	glUniform1i(fTexture, 0);
	glUniform1i(fHasTexture, (GLboolean)(button_tex && glIsTexture(button_tex -> texid)));
	if(button_tex && glIsTexture(button_tex -> texid))
	{
		glEnable(GL_TEXTURE_2D);
		glActiveTexture(GL_TEXTURE0);
		glBindTexture(GL_TEXTURE_2D, button_tex -> texid);
	}

	GLint attributes[] = {
		vPosition,
		vTexcoord,
		v_ModelviewProjectionMatrix
	};

	matrixs[GLWidget::ModelviewMatrix].makeIdentity();
	if(_orientation == GLWidget::Portrait)
	{
		Matrix44<GLfloat> translationMatrix;
		Vec3<GLfloat> translation(0.0f, -BUTTON_WIDTH, 0.0f);
		translationMatrix.translate(translation);
		matrixs[GLWidget::ModelviewMatrix] = translationMatrix;
	}

	Matrix44<GLfloat> wmatrixs[] = {
		matrixs[GLWidget::ModelviewMatrix],
		matrixs[GLWidget::ProjectionMatrix]
	};

	GLfloat angle = _orientation == GLWidget::Landscape ? 0.0f : 90.0f;
	GLuint index = _orientation == GLWidget::Landscape ? 0 : 1;

	for(int i = 0; i < GLWidget::CloseButtonBuffer; i++)
		draw_button(buttons[i].buffer, attributes, wmatrixs, buttons[i].xCoord[index], buttons[i].yCoord[index], buttons[i].pressed, angle);

	if(animationTimer && animationTimer -> isActive())
		draw_button(buttons[GLWidget::StopButtonBuffer].buffer, attributes, wmatrixs, buttons[GLWidget::StopButtonBuffer].xCoord[index], buttons[GLWidget::StopButtonBuffer].yCoord[index], buttons[GLWidget::StopButtonBuffer].pressed, angle);
	else
		draw_button(buttons[GLWidget::PlayButtonBuffer].buffer, attributes, wmatrixs, buttons[GLWidget::PlayButtonBuffer].xCoord[index], buttons[GLWidget::PlayButtonBuffer].yCoord[index], buttons[GLWidget::PlayButtonBuffer].pressed, angle);

		draw_button(buttons[GLWidget::CloseButtonBuffer].buffer, attributes, wmatrixs, buttons[GLWidget::CloseButtonBuffer].xCoord[index], buttons[GLWidget::CloseButtonBuffer].yCoord[index], buttons[GLWidget::CloseButtonBuffer].pressed, angle);

	glDisableVertexAttribArray(vPosition);
	glDisableVertexAttribArray(vTexcoord);

	if(button_tex && glIsTexture(button_tex -> texid))
	{
		glBindTexture(GL_TEXTURE_2D, 0);
		glDisable(GL_TEXTURE_2D);
	}
}

void GLWidget::setOrientation(GLWidget::ScreenOrientation o)
{
	if(_orientation != o)
	{
		_orientation = o;
    if(_orientation == GLWidget::Landscape)
			z_t -= 200.0f;
		else
			z_t += 200.0f;
		updateGL();
		emit orientationChanged(_orientation);
	}
}

GLWidget::ScreenOrientation GLWidget::orientation() const
{
	return _orientation;
}
