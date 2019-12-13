#!/bin/bash


###################################################################################################
# CONFIGURATION
###################################################################################################

DOCU_PROJECT_PATH="git@github.com:somedotone"
DOCU_WIKI_NAME="attestation-protocol.wiki"

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
