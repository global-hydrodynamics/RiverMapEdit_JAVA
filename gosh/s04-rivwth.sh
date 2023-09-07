#!/bin/sh

# (1) Prepare runoff climatology file (same grid coodinate as river map, units in mm/year)

# convert runoff grd2gt
#./src/conv_runoff
#
#ITEM='runoff'
#IFILE='./tmp.grd'
#OFILE='../gtool/runoff_1deg.gt'
#TITLE='runoff'
#UNIT='mm/year'
#
#gtrdir ${IFILE} out:tmp.gt -r4 x:GLON360M y:GLAT180IM z:SFC1  
#gthead tmp.gt out:${OFILE} ITEM/"${ITEM}" FNUM/"1" DNUM/"1" TITLE/"${TITLE}" UNIT/"${UNIT}" TIME/"0" UTIM/"HOUR" DATE/"00000101 000000" TDUR/"0" DFMT/"UR4" DATE1/"00000101 000000" DATE2/"00000101 000000" 
#rm -f tmp.gt
#
## resolution conversion
#IFILE='../gtool/runoff_1deg.gt'
#OFILE='../gtool/runoff_t213.gt'
#GRDFILE='../grd/runoff_t213.grd'
#
#gtintrp ${IFILE} out:${OFILE} x:GLON640 y:GGLA320
#
#gtwdir ${OFILE} out:${GRDFILE} -r4



# (2) calculate river width from flow direction and runoff
# input should be flow direction, latitude of grid centers, runoff. Output are river width and mean river discharge
./src/calc_rivwth ../grd/flwdir.grd ../grd/lat.grd ../grd/runoff_t213.grd ../grd/rivwth.grd

## mv tmp.bin ../grd/rivout.grd
## 
## # congert grd2gt
## ITEM='RIVWTH'
## IFILE='../grd/rivwth.grd'
## OFILE='../gtool/rivwth.gt'
## TITLE='river width'
## UNIT='m'
## 
## gtrdir ${IFILE} out:tmp.gt -r4 x:GLON640 y:GGLA320 z:SFC1  
## gthead tmp.gt out:${OFILE} ITEM/"${ITEM}" FNUM/"1" DNUM/"1" TITLE/"${TITLE}" UNIT/"${UNIT}" TIME/"0" UTIM/"HOUR" DATE/"00000101 000000" TDUR/"0" DFMT/"UR4" DATE1/"00000101 000000" DATE2/"00000101 000000" 
## 
## rm -f tmp.gt
## 
## ## COMPILE change_header using big90, instead of m90 ###
## echo ""
## echo "### NOTE: Compile change_header.f90 using big90, instead of m90 "
## ./src/change_header ../gtool/rivwth.gt tmp.gt
## mv tmp.gt ../gtool/rivwth.gt
