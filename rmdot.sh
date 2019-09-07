#!/bin/bash

NUM_LINES=$(/sbin/mount | awk '/msdos/{$1="";$2="";gsub (" \\(", "\\"); print}' | wc -l)

if [[ ${NUM_LINES} -lt 1 ]]; then
   echo "No removable media found. Exit".
   exit 1
fi

echo "Found ${NUM_LINES} removable media."
echo

NUM=${NUM_LINES}
while [[ ${NUM} -gt 0 ]]; do
   DIR=$(/sbin/mount | awk '/msdos/{$1="";$2="";gsub (" \\(", "\\"); print}' | awk 'BEGIN{NUM='"${NUM}"';FS="\\"}NR==NUM{gsub ("^  ", "");printf ("%s", $1)}')
   VOL=$(echo ${DIR} | awk '{gsub ("/Volumes/", ""); print}')

   echo "Current medium: \"${VOL}\""
   cd "${DIR}"
   echo "Current directory: \"${DIR}\""
   echo

   (
   echo "Superfluous directories:"
   find . -fstype msdos -type d \( -name .Trashes -o -name .Spotlight-V100 -o -name .fseventsd \)

   echo
   echo "Superfluous files:"
   find . -fstype msdos -type f -name ".??*"
   ) | more

   echo
   echo "Press RETURN to remove superfluous directories and files:"
   read a
   find . -fstype msdos -type d \( -name .Trashes -o -name .Spotlight-V100 -o -name .fseventsd \) -exec rm -rf {} \; -print
   find . -fstype msdos -type f -name ".??*" -delete -print

   cd
   diskutil eject "${VOL}"
   echo "Please now remove \"${VOL}\" ."
   echo
   NUM=$((${NUM} - 1))
done
