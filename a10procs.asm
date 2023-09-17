; *****************************************************************
;  Name: Christopher Rosado
;  NSHE_ID: 2001956343
;  Section: 1001
;  Assignment: 10
;  Description:  Write some assembly language functions.

;  Assignment #10
;  Support Functions -> Provided Template.

; -----
;  Function: getParams
;	Read, checks, and returns a, b, draw color and draw speed

;  Function plotLissajou()
;	Plots Lissajou function (as per provided algorithm).

; ---------------------------------------------------------
;	MACROS (if any) GO HERE

; ---------------------------------------------------------

section  .data

; -----
;  Define standard constants.

TRUE		equ	1
FALSE		equ	0

LF		equ	10
NULL		equ	0

SUCCESS		equ	0			; successful operation
NOSUCCESS	equ	1

STDIN		equ	0			; standard input
STDOUT		equ	1			; standard output
STDERR		equ	2			; standard error

SYS_read	equ	0			; code for read
SYS_write	equ	1			; code for write
SYS_open	equ	2			; code for file open
SYS_close	equ	3			; code for file close
SYS_fork	equ	57			; code for fork
SYS_exit	equ	60			; code for terminate
SYS_creat	equ	85			; code for file open/create
SYS_time	equ	201			; code for get time

; -----
;  OpenGL constants

GL_COLOR_BUFFER_BIT	equ	16384
GL_POINTS		equ	0
GL_POLYGON		equ	9
GL_PROJECTION		equ	5889

GLUT_RGB		equ	0
GLUT_SINGLE		equ	0

; -----
;  Local variables for getParams() function.

ABMIN		equ	1
ABMAX		equ	50
COLORMIN	equ	100
COLORMAX	equ	0x0ffffff
SPEEDMIN	equ	0
SPEEDMAX	equ	100

ddFour		dd	4
tmpNum		dd	0

; Used for comparison
Aplot		db	"-a", NULL
Bplot		db	"-b", NULL
DCplot		db	"-dc", NULL
DSplot		db	"-ds", NULL

errUsage	db	"Usage: lissajou -a <quaternaryNumber> "
		db	"-b <quaternaryNumber> -dc <quaternaryNumber> "
		db	"-ds <quaternaryNumber>", LF, NULL

errOptions	db	"Error, invalid command line options."
		db	LF, NULL

errASpec	db	"Error, invalid A value specifier."
		db	LF, NULL
errAValue	db	"Error, A Value out of range (1 - 302, base 4)."
		db	LF, NULL

errBSpec	db	"Error, invalid B value specifier."
		db	LF, NULL
errBValue	db	"Error, B value out of range (1 - 302, base 4)."
		db	LF, NULL

errDcSpec	db	"Error, invalid draw color specifier."
		db	LF, NULL
errDcValue	db	"Error, draw color value out of range (302 - 333333333333, base 4)."
		db	LF, NULL

errDsSpec	db	"Error, invalid draw speed specifier."
		db	LF, NULL
errDsValue	db	"Error, draw speed out value of range (1 - 1210, base 4)."
		db	LF, NULL

; -----
;  Local variables for plotLissajou() routine.

t		dq	0.0
x		dq	0.0
y		dq	0.0
lpMax		dq	0.0

fZero		dq	0.0
fTwo		dq	2.0
myPi		dq	3.14159365358979
circleDegrees	dq	36000.0

red		dq	0
green		dq	0
blue		dq	0

tStep		dq	0.0001			; t step
speed		dq	0.0			; circle deformation speed
scale		dq	10000.0			; scale factor for speed

a		dq	0.0
b		dq	0.0

; ------------------------------------------------------------

section  .text

; -----
;  Open GL routines.

extern glutInit, glutInitDisplayMode, glutInitWindowSize
extern glutInitWindowPosition
extern glutCreateWindow, glutMainLoop
extern glutDisplayFunc, glutIdleFunc, glutReshapeFunc, glutKeyboardFunc
extern glutSwapBuffers
extern gluPerspective
extern glClearColor, glClearDepth, glDepthFunc, glEnable, glShadeModel
extern glClear, glLoadIdentity, glMatrixMode, glViewport
extern glTranslatef, glRotatef, glBegin, glEnd, glVertex3f, glColor3f
extern glVertex2f, glVertex2i, glColor3ub, glOrtho, glFlush, glVertex2d
extern glutPostRedisplay

extern	cos, sin

; ******************************************************************
;  Generic function to display a string to the screen.
;  String must be NULL terminated.
;  Algorithm:
;	Count characters in string (excluding NULL)
;	Use syscall to output characters

;  Arguments:
;	1) address, string
;  Returns:
;	nothing

global	printString
printString:
	push	rbp
	mov	rbp, rsp
	push	rbx
	push	rsi
	push	rdi
	push	rdx

; -----
;  Count characters in string.

	mov	rbx, rdi			; str addr
	mov	rdx, 0
strCountLoop:
	cmp	byte [rbx], NULL
	je	strCountDone
	inc	rbx
	inc	rdx
	jmp	strCountLoop
strCountDone:

	cmp	rdx, 0
	je	prtDone

; -----
;  Call OS to output string.

	mov	rax, SYS_write			; system code for write()
	mov	rsi, rdi			; address of characters to write
	mov	rdi, STDOUT			; file descriptor for standard in
						; EDX=count to write, set above
	syscall					; system call

; -----
;  String printed, return to calling routine.

prtDone:
	pop	rdx
	pop	rdi
	pop	rsi
	pop	rbx
	pop	rbp
	ret

; ******************************************************************
;  Function getParams()
;	Get, check, convert, verify range, and return the
;	a value, b value, draw color, and draw speed.

;  Example HLL call:
;	stat = getParams(argc, argv, &aValue, &bValue,
;				&drawSpeed, &drawColor)

;  This routine performs all error checking, conversion of ASCII/quaternary
;  to integer, verifies legal range of each value.
;  For errors, applicable message is displayed and FALSE is returned.
;  For good data, all values are returned via addresses with TRUE returned.

;  Command line format (fixed order):
;	-a <quaternaryNumber> -b <quaternaryNumber> -dc <quaternaryNumber>
;				-ds <quaternaryNumber>

; -----
;  Arguments:
;	1) ARGC, value rdi
;	2) ARGV, address rsi
;	3) a value (dword), address rdx
;	4) b value (dword), address rcx
;	5) draw color (dword), address r8
;	6) draw speed (dword), address r9



;	YOUR CODE GOES HERE
global	getParams
getParams:
	push rbx ;argv
	push r12 ; argc
	push r13 ; incrementor through argv
	push r14 ; a value
	push r15 ; b value

	mov r14, rdx ; a value
	mov r15, rcx ; b value

	mov r13, 1
	mov r12, rdi ;	argc
	mov rbx, rsi ;	argv
	cmp r12, 1
	je UsageError
	cmp r12, 9	; should be 9
	jne IncorrectArgC

;	a spec

	mov rdi, errASpec
	mov rsi, Aplot
	mov rdx, qword [rbx + r13 * 8]
	call	StringCheck
	cmp rax, FALSE
	je GetParamsDone
	inc r13

	mov rcx, r15
	mov rdx, r14

	mov r14, rdx ; a value
	mov r15, rcx ; b value

;	a value
	mov rdi, errAValue
	mov rsi, qword [rbx + r13 * 8]
	mov rdx, ABMAX
	mov rcx, ABMIN
	call	ValCheck

	mov rdx, r14
	mov rcx, r15
	mov r14d, dword [tmpNum]
	mov dword [rdx], r14d
	cmp rax, FALSE
	je GetParamsDone
	inc r13

	mov r14, rdx ; a value

;	b spec

	mov rdi, errBSpec
	mov rsi, Bplot
	mov rdx, qword [rbx + r13 * 8]

	call	StringCheck
	mov rdx, r14
	cmp rax, FALSE
	je GetParamsDone
	inc r13
	mov r14, rdx ; a value
	mov r15, rcx ; b value

;	b value
	mov rdi, errBValue
	mov rsi, qword [rbx + r13 * 8]
	mov rdx, ABMAX
	mov rcx, ABMIN
	call	ValCheck

	mov rdx, r14
	mov rcx, r15

	mov r15d, dword [tmpNum]
	mov dword[rcx], r15d
	cmp rax, FALSE
	je GetParamsDone
	inc r13

	mov r14, rdx

;	dc spec
	mov rdi, errDcSpec
	mov rsi, DCplot
	mov rdx, qword [rbx + r13 * 8]
	call	StringCheck

	mov rdx, r14

	cmp rax, FALSE
	je GetParamsDone
	inc r13

	mov r14, rdx ; a value
	mov r15, rcx ; b value

;	dc value
	mov rdi, errDcValue
	mov rsi, qword [rbx + r13 * 8]
	mov rdx, COLORMAX
	mov rcx, ABMIN
	call	ValCheck
	
	mov rdx, r14
	mov rcx, r15

	cmp rax, FALSE
	je GetParamsDone
	mov r15d, dword [tmpNum]
	mov dword[r8], r15d
	inc r13

	mov r14, rdx ; a value

;	ds	spec
	mov rdi, errDsSpec
	mov rsi, DSplot
	mov rdx, qword [rbx +r13 * 8]
	call	StringCheck

	mov rdx, r14
	
	cmp rax, FALSE
	je GetParamsDone
	inc r13

	mov r14, rdx ; a value
	mov r15, rcx ; b value

;	ds value
	mov rdi, errDsValue
	mov rsi, qword [rbx + r13 * 8]
	mov rdx, SPEEDMAX
	mov rcx, SPEEDMIN
	call	ValCheck
	
	mov rdx, r14
	mov rcx, r15
	
	cmp rax, FALSE
	je GetParamsDone
	mov r15d, dword [tmpNum]
	mov dword[r9], r15d
	inc r13

jmp Correct
UsageError:
	mov rdi, errUsage
	call	printString
	mov rax, FALSE
	jmp GetParamsDone
IncorrectArgC:
	mov rdi, errOptions
	call 	printString
	mov rax, FALSE
	jmp GetParamsDone

Correct:
	mov rax, TRUE

GetParamsDone:

	pop r15
	pop r14
	pop r13
	pop r12
	pop rbx
ret
; ******************************************************************
;  Function: Check and convert ASCII/quaternary to integer
;	return false

;	1) list, addr - rdi
;	2) length, value - rsi
;	3) sum, addr - rdx
;	4) average, addr - rcx
;	5) minimum, addr - r8
;	6) maximum, addr - r9

;	rdi - errMsg
;	rsi - correct string addr
;	rdx - argv value
global StringCheck
StringCheck:
	push r12
	push r13
	push r14
	push rbx

	mov r12, 0
	mov r13, 0
	mov r14, 0

	CorrectStringLoop:
		cmp byte [rsi + r13], NULL
		je CountLoop
		inc r13 
		jmp CorrectStringLoop
	CountLoop:
		cmp	byte [rdx + r14], NULL
		je CmpLoop
		inc r14
		jmp CountLoop
	CmpLoop:
		cmp r14, r13 
		jne	Error
		mov bl, byte [rsi + r12]
		cmp byte [rdx + r12], bl
		jne Error
		inc r12
		cmp r12, r14
		je Complete
		jmp CmpLoop
	Error:
		call	printString
		mov rax, FALSE
	Complete:
	pop rbx
	pop r14
	pop r13
	pop r12	
ret

;	1) err message, addr - rdi
;	2) string with input, value - rsi
;	3) Max, value - rdx
;	4) Min, value - rcx
;	ddfour
;	tmpNum
global ValCheck
ValCheck:
	push r12 ; placeholder
	push r13 ; incrementor
	push r14
	mov r14, rdx
	mov rax, 0
	mov r13, 0
	Convert:
		mov r12, 0
		mov r12b, byte [rsi + r13]
		cmp r12b, NULL
		je Done
		cmp r12b, "0"
		jl OutOfRange
		cmp r12b, "3"
		jg OutOfRange
		sub r12b, 0x30
		mul dword [ddFour]
		add eax, r12d
		inc r13
		jmp Convert
	Done:
		mov rdx, r14
		cmp rax, rdx ; max value
		jg OutOfRange
		cmp rax, rcx
		jl OutOfRange
	mov dword [tmpNum], eax
	mov rax, TRUE
	jmp WithinRange
	OutOfRange:
	call	printString
	mov rax, FALSE
	jmp RangeDone
	WithinRange:
	mov rax, TRUE
	RangeDone:
	pop r14
	pop r13
	pop r12
ret
;  Example HLL Call:
;	stat = quat2int(qStr, &num);



;	YOUR CODE GOES HERE



; ******************************************************************
;  Plot Function.
;  Note, function is repeatedly called by openGL
;  Each call plots one image.  The animation is accomplished
;  via repeated calls to the plot function 


;  Compute and plot the points.
;	x = cos (((2.0 * Pi) / (a+speed)) * t)
;	y = sin (((2.0 * Pi) / b) * t)

; -----
;  Gloabal variables accessed.
;  Globals are set via provided main.

common	aValue		1:4			; A value
common	bValue		1:4			; B value
common	drawColor	1:4			; draw color
common	drawSpeed	1:4			; draw speed
common	stop		1:1			; stop boolean

global	plotLissajou
plotLissajou:
	push	rbp
; -----
; Prepare for drawing
;	glClear(GL_COLOR_BUFFER_BIT);

	mov	rdi, GL_COLOR_BUFFER_BIT
	call	glClear

	; glBegin(GL_POINTS);
	mov	rdi, GL_POINTS
	call	glBegin

; -----
;  set draw color(r,g,b)
;	uses glColor3ub(r,g,b)
mov rax, 0
mov eax, dword [drawColor]

mov rdx, 0
mov dl, al
mov rsi, 0
shr rax, 8
mov sil, al
shr rax, 8
mov rdi, 0
mov dil, al
call 	glColor3ub

; -----
;  Set speed based on user entered drawSpeed
;	speed = drawSpeed / scale

cvtsi2sd xmm0, dword [drawSpeed]
divsd xmm0, qword [scale]
movsd qword [speed], xmm0

; -----
;  Get and convert aValue and bValue from int to float.
cvtsi2sd xmm0, dword [aValue]
movsd qword [a], xmm0

cvtsi2sd xmm0, dword [bValue]
movsd qword [b], xmm0

; -----
;  Adjust a based on calculated speed value.

movsd xmm0, qword [a]
addsd xmm0, qword [speed]
movsd qword [a], xmm0

; -----
;  Check for animation stop (via stop boolean)
mov al, byte[stop]
cmp al, TRUE
jne boolFalse
mov r10, 0
cvtsi2sd xmm0, r10
movsd qword [t], xmm0
boolFalse:
; -----
;  Main plot loop.
;	OPTIONAL: find iterations -> ((max(a,b) * pi) / tStep)
;			as an integer (easier than float compare)
	mov eax, dword[aValue]
	cmp eax, dword[bValue]
	jge useA
	mov eax, dword[bValue]
useA:
	cvtsi2sd xmm0, eax
	mulsd xmm0, qword [myPi]
	divsd xmm0, qword [tStep]
	cvtsd2si r12, xmm0
PlotLoop:
;	y = sin (((2.0 * Pi) / b) * t)
movsd	xmm0, qword [fTwo]
mulsd	xmm0, qword [myPi]
divsd	xmm0, qword [b]
mulsd	xmm0, qword [t]

call	sin
movsd qword [y], xmm0
;	x = cos (((2.0 * Pi) / (a+speed)) * t)
movsd xmm0, qword [fTwo]
mulsd xmm0, qword [myPi]
movsd xmm1, qword [a]
addsd xmm1, qword [speed]
divsd xmm0, xmm1
mulsd xmm0, qword [t]

call	cos
movsd qword [x], xmm0

movsd xmm0, qword [x]
movsd xmm1, qword [y]
call	glVertex2d

movsd xmm0, qword [t]
addsd xmm0, qword [tStep]
movsd qword [t], xmm0
dec r12
cmp r12, 0
jne PlotLoop
; -----
;  plotting done, show image

	call	glEnd
	call	glFlush

	call	glutPostRedisplay

; -----
;  if t > circle degrees
;	resset t to 0.0

	movsd	xmm0, qword [t]
	movsd	xmm1, qword [myPi]
	mulsd	xmm1, qword [circleDegrees]
	ucomisd	xmm0, xmm1
	jb	plotDone
	movsd	xmm0, qword [fZero]
	movsd	qword [t], xmm0

; -----
;  done

plotDone:
	pop	rbp
	ret

; ******************************************************************

