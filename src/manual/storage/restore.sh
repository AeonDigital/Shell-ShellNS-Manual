#!/usr/bin/env bash

#
# Loads the manual information to the indicated associative array.
#
# @param dirExistentFullPath $1
# Full path to the target function manual.
#
# @param assoc $2
# Name of the associative array that will be populated.
#
# @return status+assoc
# See the description below for possible status codes.
#
# _,**Possible status codes**,_
#
# 10 : Invalid path to manual directory.  
# 11 : Invalid assoc object name.
#
# 0  : Success
shellNS_manual_storage_restore() {
  #
  # Check param
  local pathToFunctionManual="${1}"
  shellNS_validate_param "${FUNCNAME[0]}" "dirExistentFullPath" "1" "" "" "" "${pathToFunctionManual}"
  if [ "$?" != "0" ]; then return 10; fi

  local strAssocManualName="${2}"
  shellNS_validate_param "${FUNCNAME[0]}" "assoc" "2" "" "" "" "${strAssocManualName}"
  if [ "$?" != "0" ]; then return 11; fi



  #
  # Fully cleans the associative array.
  local -n assocManual="${strAssocManualName}"
  local tmpKey=""
  for tmpKey in "${!assocManual[@]}"; do
    unset assocManual["${tmpKey}"]
  done


  #
  # Reads all files and fills in the associative array with the
  # value of each part of the manual
  local filePath=""
  local fileName=""
  local -a manualFiles=($(find "${pathToFunctionManual}" -maxdepth 1 -type f))
  for filePath in "${manualFiles[@]}"; do
    fileName="${filePath##*/}"
    assocManual["${fileName}"]=$(< "${filePath}")
  done

  return 0
}