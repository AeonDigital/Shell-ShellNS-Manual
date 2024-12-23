#!/usr/bin/env bash

#
# Extracts the manual described in the first comment block from the
# indicated file.
#
# @param fileExistentFullPath $1
# Full path to the target function script or its manual file.
#
# @param ?bool $2
# ::
#   - default : "1"
# ::
#
# If "1" will normalize the document.
#
# Normalization concatenates rows that must be contiguous, standardizes the
# sample of predefined blocks, and excludes non-renderable rows.
# 
# Will convert all character **\\** to **'SHELLNS_ASCII_x9D**.
#
# @return status+string
# See the description below for possible status codes.
#
# _,**Possible status codes**,_
#
# 10 : Invalid path to script file.  
# 11 : Empty documentation.
#
# 0  : Success
shellNS_manual_extract_raw_data() {
  #
  # Check param
  local scriptPath="${1}"
  shellNS_validate_param "${FUNCNAME[0]}" "fileExistentFullPath" "1" "" "" "" "${scriptPath}"
  if [ "$?" != "0" ]; then return 10; fi

  local boolNormalize="1"
  if [ "${2}" == "0" ]; then boolNormalize="0"; fi


  local codeNL=$'\n'
  local intReturn="0"
  local strReturn=""


  # if the file is a .man file, just return its content
  if [ "${scriptPath: -4}" == ".man" ]; then
    strReturn=$(<"${scriptPath}")
  else
    local isDocumentationLine="0"

    local strRawLine=""
    IFS=$'\n'
    while read -r strRawLine || [ -n "${strRawLine}" ]; do
      if [ "${isDocumentationLine}" == "0" ] && [ "${strReturn}" != "" ]; then
        break
      fi
      if [[ "${strRawLine}" == \#!* ]] || [[ ! "${strRawLine}" == \#* ]]; then
        isDocumentationLine="0"
        continue
      fi
      isDocumentationLine="1"


      if [ "${strRawLine:0:2}" == "# " ]; then
        strRawLine="${strRawLine:2}"
      elif [ "${strRawLine:0:1}" == "#" ]; then
        strRawLine="${strRawLine:1}"
      fi


      strReturn+="${strRawLine}${codeNL}"
    done < "${scriptPath}"
    unset IFS
  fi


  strReturn=$(shellNS_string_trim_raw "${strReturn}")

  if [ "${boolNormalize}" == "1" ]; then
    strReturn=$(shellNS_ansidown_normalize_escape "${strReturn}")
    strReturn=$(shellNS_ansidown_normalize_blocks "${strReturn}")
    strReturn=$(shellNS_ansidown_normalize_breakline "${strReturn}")
  fi

  if [ "${strReturn}" == "" ]; then
    intReturn="11"
  fi
  shellNS_output_set "${FUNCNAME[0]}" "${intReturn}" "${strReturn}"
  return "${intReturn}"
}