#!/usr/bin/env bash

#
# Extracts all technical documentation from a script.
#
# Each piece of documentation will be allocated to the associative array
# provided in parameter $3.
#
# @param fileExistentFullPath $1
# Full path to the target function script.
#
# @param ?string $2
# If informed, it must be the complete documentation from which the data
# will be extracted.
#
# @param assoc $3
# Name of the associative array that will receive the processed information.
#
# @return status+assoc
# See the description below for possible status codes.
#
# **Possible status codes**
#
# 10 : Inválid path to script file.
# 11 : Empty documentation.
#
# 0  : Success
shellNS_manual_extract_documentation() {
  local strFullRawDocumentation="${2}"
  local -n assocExtractedData="${3}"

  if [ "${2}" == "" ]; then
    shellNS_manual_extract_raw_data "${1}"
    if [ "$?" != "0" ]; then return $?; fi

    strFullRawDocumentation=$(shellNS_output_show)
  fi
  assocExtractedData["raw"]="${strFullRawDocumentation}"



  shellNS_manual_extract_subsections "" "${strFullRawDocumentation}"
  if [ "$?" != "0" ]; then return $?; fi

  assocExtractedData["summary"]=$(shellNS_output_show "1" "1")
  assocExtractedData["description"]=$(shellNS_output_show "2" "0")


  shellNS_manual_extract_parameters "" "${strFullRawDocumentation}" "${3}"
  if [ "$?" != "0" ]; then return $?; fi

  shellNS_manual_extract_return "" "${strFullRawDocumentation}" "${3}"
  if [ "$?" != "0" ]; then return $?; fi

  return 0
}