#!/bin/sh

# (1) check flowdir error
# Loop and crossing errors are checked.
# Text river map (rivmap.txt) is generated
./src/check_flwdir ../java/data/flwdir.big

cp rivmap.txt ../gtool/

# if needed, convert from plain binary to Gtool
#ITEM='RIVMAP'
#IFILE='../grd/flwdir.grd'
#OFILE='../gtool/rivmap.gt'
#TITLE='river map'
#UNIT='-'
#
#gtrdir ${IFILE} out:tmp.gt -r4 x:GLON640 y:GGLA320 z:SFC1  
#gthead tmp.gt out:${OFILE} ITEM/"${ITEM}" FNUM/"1" DNUM/"1" TITLE/"${TITLE}" UNIT/"${UNIT}" TIME/"0" UTIM/"HOUR" DATE/"00000101 000000" TDUR/"0" DFMT/"UR4" DATE1/"00000101 000000" DATE2/"00000101 000000" 
#rm -f tmp.gt
