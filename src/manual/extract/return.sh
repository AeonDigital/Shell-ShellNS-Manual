#!/usr/bin/env bash

#
# Extracts the return data from the technical documentation of a script.
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
shellNS_manual_extract_return() {
  local strFullRawDocumentation="${2}"
  local -n assocExtractedData="${3}"

  if [ "${2}" == "" ]; then
    shellNS_manual_extract_raw_data "${1}"
    if [ "$?" != "0" ]; then return $?; fi

    strFullRawDocumentation=$(shellNS_output_show)
  fi


  local codeNL=$'\n'
  local isInsideReturnSection="0"

  local -a splitType=()
  local strReturnType=""
  local strReturnTypeDef=""
  local strReturnTypeNull=""
  local strRawLine=""
  IFS=$'\n'
  while read -r strRawLine || [ -n "${strRawLine}" ]; do
    if [[ "${strRawLine}" == \@return* ]]; then
      isInsideReturnSection="1"
      strReturnTypeNull=""

      strReturnType=$(shellNS_string_trim_raw "${strRawLine#\@return*}")
      if [ "${strReturnType}" == "" ]; then
        strReturnType="void"
      else
        if [[ "${strReturnType}" == *\?* ]]; then
          strReturnTypeNull="?"
          strReturnType="${strReturnType//\?/}"
        fi
      fi
      shellNS_string_split "splitType" "|" "${strReturnType}" "0" "1"
      strReturnType=$(shellNS_array_join "|" "splitType")


      strReturnTypeDef="@return ${strReturnTypeNull}${strReturnType}  ${codeNL}"

      assocExtractedData["return_def"]="${strReturnTypeDef}"
      assocExtractedData["return_type"]="${strReturnTypeNull}${strReturnType}"
      assocExtractedData["return_summary"]=""
      assocExtractedData["return_description"]=""
      assocExtractedData["return_raw"]="${strReturnTypeDef}"
    else
      if [ "${isInsideReturnSection}" == "1" ]; then
        assocExtractedData["return_raw"]+="${strRawLine}${codeNL}"
      fi
    fi
  done <<< "${strFullRawDocumentation}"
  unset IFS


  local rawReturnDoc=$(shellNS_string_trim_raw "${assocExtractedData["return_raw"]}")
  if [ "${rawReturnDoc}" != "" ]; then
    shellNS_manual_extract_subsections "" "${rawReturnDoc}"
    if [ "$?" != "0" ]; then return $?; fi

    assocExtractedData["return_summary"]=$(shellNS_output_show "1" "1")
    assocExtractedData["return_description"]=$(shellNS_output_show "2" "0")
  fi
}