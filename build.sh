echo Building curses.js

echo Removing folders
rm -rf out/*
rm -rf dist/*
rm -rf demos/*

echo Copy BMP files in demos/ folder
cp *.bmp demos/

echo Copy files in dist/ folder
cp *.bmp dist/
cp pdcurses34/curses.h dist/
cp pdcurses34/term.h dist/

echo
echo BUILDING pdcurses/
echo ------------------

# this should recurse -.-
for I in pdcurses34/pdcurses/*.c; do
	echo Building $I 
	emcc -O $I -o out/$(basename --suffix=.c $I).bc -I pdcurses34/ -I pdcurses34/pdcurses/
	PDCURSES_BINARIES="${PDCURSES_BINARIES} out/$(basename --suffix=.c $I).bc"
done
echo "binary list: $PDCURSES_BINARIES "


echo
echo BUILDING sdl1/
echo ---------------
for I in pdcurses34/sdl1/*.c; do 
	echo Building $I
	emcc -O pdcurses34/sdl1/$(basename $I) -o out/$(basename --suffix=.c $I).bc -I ./ -I pdcurses34/ -I pdcurses34/pdcurses/ -I pdcurses34/sdl1/
	PDCURSES_BINARIES="$PDCURSES_BINARIES out/$(basename --suffix=.c $I).bc"
done

echo
echo Building library using...
echo $PDCURSES_BINARIES
emcc -O $PDCURSES_BINARIES -o dist/libcurses.o

echo
echo BUILDING demos/
echo ---------------
for I in pdcurses34/demos/*.c; do
	echo Building $I
	emcc -O pdcurses34/demos/$(basename $I) -o out/$(basename --suffix=.c $I).bc -I pdcurses34/ -I pdcurses34/pdcurses/ -I pdcurses34/sdl1/ -I pdcurses34/demos/
	cd demos/
	emcc -s ASYNCIFY=1 --emrun -O3 ../dist/libcurses.o ../out/$(basename --suffix=.c $I).bc -o $(basename --suffix=.c $I).html --preload-file pdcfont.bmp --preload-file pdcicon.bmp
	cd ..
done	

echo FINISHED
