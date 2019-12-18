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

DOCU_FOLDER="./../docs"
PREPARED_DOCU_FOLDER="./../prepared-docu"

CI_CD_FOLDER="./../ci-cd"


###################################################################################################
# DEFINES
###################################################################################################

DOCU_FOLDER_PATH="$(pwd)/${DOCU_FOLDER}"
PREPARED_DOCU_FOLDER_PATH="$(pwd)/${PREPARED_DOCU_FOLDER}"

PREPARE_DOCU_FOLDER="$(pwd)/${CI_CD_FOLDER}/prepare-docu"


###################################################################################################
# MAIN
###################################################################################################

echo "[INFO] preparing docu folder ..."
cd ${PREPARE_DOCU_FOLDER}

node app.js ${DOCU_FOLDER_PATH} ${PREPARED_DOCU_FOLDER_PATH}


echo "" && echo "[INFO] done."
