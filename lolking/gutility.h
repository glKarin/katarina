#ifndef _G_UTILITY_H
#define _G_UTILITY_H

#include <math.h>
#include <stdio.h>

#define KARIN_MAX(t, u) (((t) > (u)) ? (t) : (u))
#define KARIN_MIN(t, u) (((t) < (u)) ? (t) : (u))
#define KARIN_ANGLE_TO_RADIAN(x) ((x) / 180.0 * M_PI)
#define KARIN_RADIAN_TO_ANGLE(x) ((x) / M_PI * 180)
#define KARIN_FLOAT_COLOR(c) ((GLfloat)(c) / 255.0f)

enum Position
{
	Up,
	Down,
	Left,
	Right,
	Forward,
	Backward,
	TotalPosition
};

enum Orientation
{
	TurnUp,
	TurnDown,
	TurnLeft,
	TurnRight,
	TotalOrientation
};

inline float formatAngle(float angle)
{
    int i = (int)angle;
	float f = angle - i;
	return i % 360 + f;
}

inline Orientation mouseMoveOrientation(int x, int y)
{
	//printf("u: %f, d: %f, l: %f, r: %f\n", atan2(1, 0) / M_PI * 180, atan2(-1, 0) / M_PI * 180, atan2(0, -1) / M_PI * 180, atan2(0, 1) / M_PI * 180);
	//printf("ul: %f, dl: %f, ur: %f, dr: %f\n", atan2(1, -1) / M_PI * 180, atan2(-1, -1) / M_PI * 180, atan2(1, 1) / M_PI * 180, atan2(-1, 1) / M_PI * 180);
    double v = atan2((double)y, (double)x) / M_PI * 180.0;
	//printf("%f, x: %d-y: %d\n", v, x, y);
	if(v >= -45 && v <= 45)
	{
		return TurnRight;
	}
	else if(v > 45 && v < 135)
	{
		return TurnUp;
	}
	else if((v >= 135 && v <= 180) || (v >= -180 && v <= -135))
	{
		return TurnLeft;
	}
	else if(v > -135 && v < -45)
	{
		return TurnDown;
	}
	else
	{
		return TotalOrientation;
	}
}

#endif
