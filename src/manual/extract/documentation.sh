#!/usr/bin/env bash

#
# Extracts all technical documentation from a script.
#
# Each piece of documentation will be allocated to the associative array
# provided in parameter **$3**.
#
# @param fileExistentFullPath $1
# Full path to the target function script or its manual file.
#
# @param ?string $2
# If informed, it must contain all documentation already normalized for
# **ansidown**
#
# @param assoc $3
# Name of the associative array that will receive the processed information.
#
# @param ?assoc $4
# Name of the associative array that will receive the colorized version of
# the manual data.
#
# @return status+assoc
# See the description below for possible status codes.
#
# _,**Possible status codes**,_
#
# 10 : Invalid path to script file.  
# 11 : Empty documentation.  
# 12 : Invalid assoc name.
#
# 0  : Success
shellNS_manual_extract_documentation() {
  #
  # Check parans
  local fileScriptPath="${1}"
  shellNS_validate_param "${FUNCNAME[0]}" "?fileExistentFullPath" "1" "" "" "" "${fileScriptPath}"
  if [ "$?" != "0" ]; then return 10; fi

  local strFullRawDocumentation="${2}"
  if [ "${fileScriptPath}" == "" ]; then
    shellNS_validate_param "${FUNCNAME[0]}" "string" "2" "" "" "" "${strFullRawDocumentation}"
    if [ "$?" != "0" ]; then return 11; fi
  fi

  local strAssocExtractedData="${3}"
  shellNS_validate_param "${FUNCNAME[0]}" "assoc" "3" "" "" "" "${strAssocExtractedData}"
  if [ "$?" != "0" ]; then return 12; fi
  local -n assocExtractedData="${3}"

  local strAssocExtractedDataColorized="${4}"
  shellNS_validate_param "${FUNCNAME[0]}" "?assoc" "4" "" "" "" "${strAssocExtractedDataColorized}"
  if [ "$?" != "0" ]; then return 12; fi
  local -n assocExtractedDataColorized="${4}"



  if [ "${strFullRawDocumentation}" == "" ]; then
    shellNS_manual_extract_raw_data "${fileScriptPath}"
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


  local k=""
  local v=""
  local code_x9D="${SHELLNS_ASCII_x9D/\\/\'}"
  for k in "${!assocExtractedData[@]}"; do
    v=$(shellNS_string_trim_raw "${assocExtractedData[$k]}")
    v="${v//${code_x9D}/\\\\}"

    assocExtractedData["${k}"]="${v}"
  done

  if [ "${strAssocExtractedDataColorized}" != "" ]; then
    shellNS_manual_extract_colorized "${strAssocExtractedData}" "${strAssocExtractedDataColorized}"
  fi

  return 0
}