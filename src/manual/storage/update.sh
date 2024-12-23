#!/usr/bin/env bash

#
# Process and saves the most current version of the manual.
#
# @param fileExistentFullPath $1
# Full path to the target function script or its manual.
#
# @param dirFullPath $2
# Full path to the location where the manual should be saved.
#
# @param string $3
# Name of the function.
#
# @return status
# See the description below for possible status codes.
#
# _,**Possible status codes**,_
#
# `10` : Invalid path to script file.  
# `11` : Empty documentation.  
# `12` : Invalid function name.
# `20` : Unable to make changes in storage directories.  
# `21` : Unable to create one or more manual files.
#
# `0 ` : Success
shellNS_manual_storage_update() {
  local -A assocManual
  local -A assocManualColorized
  shellNS_manual_extract_documentation "${1}" "" "assocManual" "assocManualColorized"
  if [ "$?" != "0" ]; then return $?; fi


  local pathToStoreManual="${2}"
  local pathToStoreRawManual="${pathToStoreManual}/raw"
  local pathToStoreRawColorManual="${pathToStoreManual}/color"

  local strFunctionName="${3}"
  if [ "${strFunctionName}" == "" ]; then return 12; fi
  assocManual["name"]="${strFunctionName}"
  assocManualColorized["name"]="${strFunctionName}"


  #
  # If exists, remove all documents from current storage directory
  if [ -d "${pathToStoreManual}" ]; then
    find "${pathToStoreManual}" -type f -exec rm -f {} \;
  fi

  mkdir -p "${pathToStoreManual}"
  if [ ! -d "${pathToStoreManual}" ]; then return 20; fi

  mkdir -p "${pathToStoreRawManual}"
  if [ ! -d "${pathToStoreRawManual}" ]; then return 20; fi

  mkdir -p "${pathToStoreRawColorManual}"
  if [ ! -d "${pathToStoreRawColorManual}" ]; then return 20; fi



  local k=""
  for k in "${!assocManual[@]}"; do
    echo -n "${assocManual[${k}]}" > "${pathToStoreRawManual}/${k}"
    if [ "$?" != "0" ]; then return 21; fi

    echo -n "${assocManualColorized[${k}]}" > "${pathToStoreRawColorManual}/${k}"
    if [ "$?" != "0" ]; then return 21; fi
  done

  return 0
}