#!/usr/bin/env bash

#
# Extracts the parameters described in the technical documentation from a
# script.
#
# Each piece of documentation will be allocated to the associative array
# provided in parameter **$3**.
#
# @param fileExistentFullPath $1
# Full path to the target function script.
#
# @param ?string $2
# If informed, it must contain all documentation already normalized for
# **ansidown**
#
# @param assoc $3
# Name of the associative array that will receive the processed information.
#
# @return status+assoc
# See the description below for possible status codes.
#
# _,**Possible status codes**,_
#
# 10 : Invalid path to script file.  
# 11 : Empty documentation.
#
# 0  : Success
shellNS_manual_extract_parameters() {
  local strFullRawDocumentation="${2}"

  if [ "${2}" == "" ]; then
    shellNS_manual_extract_raw_data "${1}"
    if [ "$?" != "0" ]; then return $?; fi

    strFullRawDocumentation=$(shellNS_output_show)
  fi


  shellNS_manual_extract_parameters_to_assoc_step_01 "${3}" "${strFullRawDocumentation}"
  shellNS_manual_extract_parameters_to_assoc_step_02 "${3}"
}