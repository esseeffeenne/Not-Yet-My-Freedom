#!/bin/bash

verbose=
  
while getopts ":hvq" option; do
  case $option in
    h) echo "usage: nymf.sh [-q|-v]"; exit ;;
    q) verbose=0 ;;
    v) verbose=1 ;;
    ?) echo "error: option -$OPTARG is not recognized"; exit ;;
  esac
done

(pacman -Qn && pacman -Qm) | cut -d' ' -f1 | sort > pkglist.txt
COLLISIONS=$(curl -s https://git.parabola.nu/blacklist.git/plain/blacklist.txt | cut -d':' -f1 - | sort | comm -1 -2 pkglist.txt -)
#REASONS=$(curl -s https://git.parabola.nu/blacklist.git/plain/blacklist.txt | cut -d'[' -f2 - | sed -e 's/]//g' | awk '{print "["$1"]", gensub(/^\s*(\S+\s+){1}/,"",1)}' -

for pkg in $COLLISIONS; do
    printf "\033[0;31m%s is not free\n" $pkg
done
