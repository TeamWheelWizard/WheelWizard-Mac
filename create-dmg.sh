#!/bin/sh

in_dir_name=$1
the_app_name=$2
out_dmg_name=$3
bg_image=$4

## https://github.com/create-dmg/create-dmg

create-dmg \
--icon-size 128 \
--text-size 16 \
--icon $the_app_name 200 150 \
--app-drop-link 450 150 \
--window-pos 200 200 \
--window-size 650 376 \
--background $bg_image \
--disk-image-size 150 \
$out_dmg_name.dmg $in_dir_name
