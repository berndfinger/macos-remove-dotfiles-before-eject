#!/bin/bash

NUM_LINES=$(/sbin/mount | awk '/msdos/{$1="";$2="";gsub (" \\(", "\\"); print}' | wc -l)

if [[ ${NUM_LINES} -lt 1 ]]; then
   echo "Keine Karte gefunden. Exit".
   exit 1
fi

echo "${NUM_LINES} Karte(n) gefunden."
echo

NUM=${NUM_LINES}
while [[ ${NUM} -gt 0 ]]; do
   DIR=$(/sbin/mount | awk '/msdos/{$1="";$2="";gsub (" \\(", "\\"); print}' | awk 'BEGIN{NUM='"${NUM}"';FS="\\"}NR==NUM{gsub ("^  ", "");printf ("%s", $1)}')
   VOL=$(echo ${DIR} | awk '{gsub ("/Volumes/", ""); print}')

   echo "Aktuelle Karte: \"${VOL}\""
   cd "${DIR}"
   echo "Aktuelles Verzeichnis: \"${DIR}\""
   echo

   (
   echo Ueberfluessige Verzeichnisse:
   find . -fstype msdos -type d \( -name .Trashes -o -name .Spotlight-V100 -o -name .fseventsd \)

   echo
   echo Ueberfluessige Dateien:
   find . -fstype msdos -type f -name ".??*"
   ) | more

   echo
   echo "Bitte RETURN druecken, um ueberfluessige Verzeichnisse und Dateien zu loeschen:"
   read a
   find . -fstype msdos -type d \( -name .Trashes -o -name .Spotlight-V100 -o -name .fseventsd \) -exec rm -rf {} \; -print
   find . -fstype msdos -type f -name ".??*" -delete -print

   cd
   diskutil eject "${VOL}"
   echo "Bitte jetzt Speicherkarte \"${VOL}\" entnehmen."
   echo
   NUM=$((${NUM} - 1))
done
