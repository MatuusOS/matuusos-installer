#!/usr/bin/env bash
# make a new window with kdialog with a language selection
# and then run the installer with the selected language
kdialog --title "Matuusos Installer" --menu "Choose your language" 0 0 0 \
"fi" "Finnish" \
"en" "English" \
"de" "German" \
"es" "Spanish" \
"fr" "French" 2> /tmp/lang.txt

# get the language from the file
LANG=$(cat /tmp/lang.txt)

# run the installer with the selected language
# change the language in the installer script
sed -i "s/LANG=.*/LANG=${LANG}/g" installer.sh

# run the installer
bash installer.sh