#!/usr/bin/env bash

#
# Extracts the return data from the technical documentation of a script.
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
shellNS_manual_extract_return() {
  local strFullRawDocumentation="${2}"
  local -n assocExtractedData="${3}"

  if [ "${2}" == "" ]; then
    shellNS_manual_extract_raw_data "${1}"
    if [ "$?" != "0" ]; then return $?; fi

    strFullRawDocumentation=$(shellNS_output_show)
  fi



  local isInsideReturnSection="0"

  local rawLine=""
  local -a splitLine=()
  while IFS='' read -r rawLine || [[ -n "${rawLine}" ]]; do
    if [[ "${rawLine}" == \@return* ]]; then
      isInsideReturnSection="1"

      IFS=' ' read -r -a splitLine <<< "${rawLine}"
      assocExtractedData["return_type"]="${splitLine[1]}"
      assocExtractedData["return_summary"]=""
      assocExtractedData["return_description"]=""
      assocExtractedData["return_raw"]=""
    else
      if [ "${isInsideReturnSection}" == "1" ]; then
        assocExtractedData["return_raw"]+="${rawLine}\n"
      fi
    fi
  done <<< "${strFullRawDocumentation}"



  local rawReturnDoc=$(echo -e "${assocExtractedData[return_raw]}")
  if [ "${rawReturnDoc}" != "" ]; then
    shellNS_manual_extract_subsections "" "${rawReturnDoc}"
    if [ "$?" != "0" ]; then return 1; fi

    assocExtractedData["return_summary"]=$(shellNS_output_show "1" "1")
    assocExtractedData["return_description"]=$(shellNS_output_show "2" "0")
  fi
}