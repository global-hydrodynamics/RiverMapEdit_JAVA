#!/bin/sh

# (1) Prepare Initial River Map: flwdir.bin (it should be plain binary, and in Big Endian).
# -- note:   endian conversion option available in Fortran90 code (./src/set_basin.F90)
# -- format: flow direction should be (1:N, 2:NE, 3:E, 4:SE, 5:S, 6:SW, 7:W, 8:NW,  0:Mouth, -1:Inland Termination, -9: Ocean)

# River Basin ID file (basin.big) and Basin color file (color.bin) are generated.

./src/set_basin ../java/data/flwdir.big ../java/data/lndfrc.big

# (2) Prepare flwdir, color, basin files in java/data/ directory

cp -f ../grd/flwdir.big ../java/data/
cp -f ../grd/basin.big  ../java/data/
cp -f ../grd/color.big  ../java/data/