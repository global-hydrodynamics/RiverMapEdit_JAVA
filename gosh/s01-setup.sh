#!/bin/sh

# Prepare "Land Fraction (lndfrc)" and "Lake Fraction (lkfrc)" files.
# The files should be in Big Endian in JAVA environment.

# (1) convert grlndf & grz from Gtool to Plain Binary if needed
#gtwdir ../gtool/GTAXLOC.GGLA320    out:../grd/lat.grd        -r4
#gtwdir ../gtool/lndfrc.t213        out:../grd/lndfrc.grd     -r4
#gtwdir ../gtool/lkfrc.t213         out:../grd/lkfrc.grd      -r4

# (2) convert endian if needed
# input:   ../grd/grlndf.grd ../grd/lkfrc.grd
# output:  ../grd/grlndf.big ../grd/lkfrc.big

# ./src/conv_lndfrc_big

# ./src/conv_lndfrc_little

# (3) Prepare lndfrc and lkfrc files in java/data/ directory

cp -f ../grd/lndfrc.big ../java/data/
cp -f ../grd/lkfrc.big  ../java/data/

