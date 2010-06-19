#!/bin/sh

path=$(dirname $1)
name=$(basename $1)
thumb="thumb_${name%.???}.png"
hover="thumb2_${name%.???}.png"
mask="mask_${name%.???}.png"
title="${name%.???}"

convert $path/$name \
    -scale 200x200 \
    -mattecolor '#75757575' \
    -frame 10x10+0+0 \
    $path/$hover

convert $path/$name \
    -gaussian-blur 5x5 \
    -resize 200x200 \
    -mattecolor '#757575' \
    -frame 10x10+0+0 \
    -modulate 115,0,100 \
    $path/$mask


composite -compose CopyOpacity $path/$mask $path/$hover $path/$thumb
rm $path/$mask

convert -size 100x14 xc:none -gravity center \
    -stroke black -strokewidth 2 -annotate 0 $title \
    -background none -shadow 200x3+0+0 +repage \
    -stroke none -fill white -annotate 0 $title \
    $path/$hover +swap -gravity south -geometry +0-3 \
    -composite $path/$hover

