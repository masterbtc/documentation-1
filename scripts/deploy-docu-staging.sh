#!/bin/bash

# Copyright (C) 2019  Attila Aldemir <a_aldemir@hotmail.de>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
 

###################################################################################################
# CONFIGURATION
###################################################################################################

DOCU_PROJECT_PATH="git@github.com:atz3n"
DOCU_WIKI_NAME="blobaa-docu-staging.wiki"

PREPARED_DOCU_FOLDER="./../prepared-docu"


###################################################################################################
# DEFINES
###################################################################################################

PREPARED_DOCU_FOLDER_PATH="$(pwd)/${PREPARED_DOCU_FOLDER}"


###################################################################################################
# MAIN
###################################################################################################

if [ ! -d ${PREPARED_DOCU_FOLDER_PATH} ]; then
    ./prepare-docu.sh
fi


echo "[INFO] cloning documentation repository ..."
git clone ${DOCU_PROJECT_PATH}/${DOCU_WIKI_NAME}.git


echo "" && echo "[INFO] overwriting cloned repository ..."
rm -rf ${DOCU_WIKI_NAME}/*
cp -r ${PREPARED_DOCU_FOLDER}/* ./${DOCU_WIKI_NAME}


echo "" && echo "[INFO] committing changes ..."
cd ${DOCU_WIKI_NAME}
git add .
git commit -m "update $(date)"
git push


echo "" && echo "[INFO] cleaning up ..."
cd ..
rm -rf ${DOCU_WIKI_NAME}
rm -rf ${PREPARED_DOCU_FOLDER}


echo "" && echo "[INFO] done."
