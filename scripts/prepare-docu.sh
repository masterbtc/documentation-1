#!/bin/bash


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
# npm install
node app.js ${DOCU_FOLDER_PATH} ${PREPARED_DOCU_FOLDER_PATH}


echo "" && echo "[INFO] done."
