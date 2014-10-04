@ECHO OFF
SETLOCAL ENABLEDELAYEDEXPANSION

CLS

ECHO Building curses.js

ECHO Removing folders
RD /Q /S out\
MD out\

RD /Q /S dist\
MD dist\

RD /Q /S demos\
MD demos\

ECHO Copy BMP files in demos\ folder
COPY *.bmp demos\

ECHO Copy files in dist\ folder
COPY *.bmp dist\ 
COPY pdcurses34\curses.h dist\
COPY pdcurses34\term.h dist\

ECHO.
ECHO BUILDING pdcurses\
ECHO ------------------

SET "PDCURSES_BINARIES="
FOR /R %%I IN (pdcurses34\pdcurses\*.c) DO (
	ECHO Building %%~nI%%~xI
	CMD /C emcc -Oz pdcurses34\pdcurses\%%~nI%%~xI -o out\%%~nI.bc -I pdcurses34\ -I pdcurses34\pdcurses\
	SET "PDCURSES_BINARIES=!PDCURSES_BINARIES! out\%%~nI.bc"
)	

ECHO.
ECHO BUILDING sdl1\
ECHO ---------------
FOR /R %%I IN (pdcurses34\sdl1\*.c) DO (
	ECHO Building %%~nI%%~xI
	CMD /C emcc -Oz pdcurses34\sdl1\%%~nI%%~xI -o out\%%~nI.bc -I .\ -I pdcurses34\ -I pdcurses34\pdcurses\ -I pdcurses34\sdl1\
	SET "PDCURSES_BINARIES=!PDCURSES_BINARIES! out\%%~nI.bc"
)

ECHO.
ECHO Building library using...
ECHO %PDCURSES_BINARIES%
CMD /C emcc -Oz %PDCURSES_BINARIES% -o dist\libcurses.o

ECHO.
ECHO BUILDING demos\
ECHO ---------------
FOR /R %%I IN (pdcurses34\demos\*.c) DO (
	ECHO Building %%~nI%%~xI
	CMD /C emcc -Oz pdcurses34\demos\%%~nI%%~xI -o out\%%~nI.bc -I pdcurses34\ -I pdcurses34\pdcurses\ -I pdcurses34\sdl1\ -I pdcurses34\demos\
	CD demos/
	CMD /C emcc -s ASYNCIFY=1 --emrun -O3 ..\dist\libcurses.o ..\out\%%~nI.bc -o %%~nI.html --preload-file pdcfont.bmp --preload-file pdcicon.bmp --shell-file ../template.html
	CD ..
)	

ECHO FINISHED