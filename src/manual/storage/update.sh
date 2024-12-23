#!/usr/bin/env bash

#
# Saves the most current version of the manual.
#
# @param fileExistentFullPath $1
# Full path to the target function script.
#
# @param dirFullPath $2
# Full path to the location where the manual should be saved.
#
# @return status
# See the description below for possible status codes.
#
# **Possible status codes**
#
# 10 : Inválid path to script file.
# 11 : Empty documentation.
# 20 : Unable to create the storage directory.
# 21 : Unable to create one or more manual files.
#
# 0  : Success
shellNS_manual_storage_update() {
  local -A assocManual
  shellNS_manual_extract_documentation "${1}" "" "assocManual"
  if [ "$?" != "0" ]; then return $?; fi


  local pathToFunctionManual="${2}"
  #
  # If exists, remove all documents from current storage directory
  if [ -d "${pathToFunctionManual}" ]; then
    find "${pathToFunctionManual}" -type f -exec rm -f {} \;
  fi
  #
  # If not exists, create the storage directory
  if [ ! -d "${pathToFunctionManual}" ]; then
    mkdir -p "${pathToFunctionManual}"
  fi
  if [ ! -d "${pathToFunctionManual}" ]; then
    return 20
  fi


  local docKey=""
  local pathToDocKey=""
  for docKey in "${!assocManual[@]}"; do
    pathToDocKey="${pathToFunctionManual}/${docKey}"
    echo -n "${assocManual["${docKey}"]}" > "${pathToDocKey}"
    if [ "$?" != "0" ]; then
      return 21
    fi
  done


  return 0
}