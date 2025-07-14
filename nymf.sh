#!/bin/bash

verbose=
RED="\033[31m"
GREEN="\033[32m"
WHITE="\033[37m"

while getopts ":hvqc" option; do
  case $option in
      h) printf "usage:
\t"$0" {-v --verbose}\n
\t"$0" {-c --no-color}\n"; exit ;;
      v) verbose=1 ;;
      c) RED="";GREEN="";WHITE="" ;;
      ?) printf "error: option -$OPTARG is not recognized"; exit ;;
  esac
done

echo "Fetching FSF-endorsed blacklist..."
curl -s https://git.parabola.nu/blacklist.git/plain/blacklist.txt | sort | sed -e 's/:/\n/1;s/:/\n/1;s/:/\n/1;s/:/\n/1' > blacklist.txt
echo "Fetching local packages..."
(pacman -Qn && pacman -Qm) | cut -d' ' -f1 | sort > pkglist.txt
COLLISIONS=$(awk '{if(NR%5==1) print $1}' blacklist.txt | sort | comm -1 -2 pkglist.txt -)

for pkg in $COLLISIONS; do
    printf $RED"%s is not free\n" $pkg
    if [[ 1 -eq $verbose ]]; then
	N_LINE=$(grep -n -x -F $pkg blacklist.txt | head -1 | cut -d':' -f1)
	ALT=$(awk "NR==$(($N_LINE + 1)){print;exit;}" blacklist.txt)
	REPO=$(awk "NR==$(($N_LINE + 2)){print;exit;}" blacklist.txt)
	REA=$(awk "NR==$(($N_LINE + 4)){print;exit;}" blacklist.txt)
	if [[ $ALT ]]; then
	    REPO="(from repo: "$REPO")"
	else
	    REPO="N/a"
	fi	
	printf $GREEN"Libre alternative: %s %s\n"$WHITE"Reason: %s\n\n" "${ALT}" "${REPO}" "${REA}"
    fi
done

rm blacklist.txt pkglist.txt
