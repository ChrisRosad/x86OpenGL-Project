#include <cstdlib>
#include <iostream>
#include <GL/gl.h>
#include <GL/glut.h>
#include <GL/freeglut.h>

using	namespace	std;

// ----------------------------------------------------------------------
//  CS 218 -> Assignment #10
//  Lissajou Program.
//  Provided main...

//  Uses openGL (which must be installed).
//  openGL installation:
//	sudo apt-get update
//	sudo apt-get upgrade
//	sudo apt-get install libgl1-mesa-dev
//	sudo apt-get install freeglut3 freeglut3-dev
//	sudo apt-get install binutils-gold

//  Compilation:
//	g++ -g -c lissajou.cpp -lglut -lGLU -lGL -lm

// ----------------------------------------------------------------------
//  External functions (in seperate file).

extern "C" void plotLissajou();
extern "C" int getParams(int, char* [], int *, int *, int *, int *);

// ----------------------------------------------------------------------
//  Global variables
//	Must be accessible for openGL display routine, plotLissajou().

int	aValue;
int	bValue;
int	drawColor;			// draw color
int	drawSpeed;			// draw speed
bool	stop = false;

// ----------------------------------------------------------------------
//  Key handler function.
//	Terminates for 'x', 'q', or ESC key.
//	Flips boolean for 's'.
//	Ignores all other characters.

void	keyHandler(unsigned char key, int x, int y)
{
	if (key == 'x' || key == 'q' || key == 27) {
		glutLeaveMainLoop();
		exit(0);
	}
	if (key == 's')
		stop = !stop;
}

// ----------------------------------------------------------------------
//  Main routine.

int main(int argc, char* argv[])
{
	int	height = 500;
	int	width = 500;
	bool	stat;
	float	redBK, greenBK, blueBK;

	double	left = -1.25;
	double	right = 1.25;
	double	bottom = -1.25;
	double	top = 1.25;

	// read and check commmand line arguments
	stat = getParams(argc, argv, &aValue, &bValue,
				&drawColor, &drawSpeed);

	// Debug call for display function
	//plotLissajou();

	if (stat) {
		glutInit(&argc, argv);
		glutInitDisplayMode(GLUT_RGB | GLUT_SINGLE);
		glutInitWindowSize(width, height);
		glutInitWindowPosition(100, 100);
		glutCreateWindow("CS 218 Assignment #10 - Lissajou Program");

		glClearColor(0Xff, 0xff, 0xff, 0.0f);
		glClearColor(0.0, 0.0, 0.0, 0.0);
		glClear(GL_COLOR_BUFFER_BIT);
		glMatrixMode(GL_PROJECTION);
		glLoadIdentity();
		glOrtho(left, right, bottom, top, 0.0, 1.0);
	
		glutKeyboardFunc(keyHandler);
		glutDisplayFunc(plotLissajou);

		glutMainLoop();
	}

	return 0;
}

