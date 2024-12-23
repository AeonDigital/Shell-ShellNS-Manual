#!/usr/bin/env bash

#
# Extracts documentation from the script that defines a function in
# plain text format.
#
# @param fileExistentFullPath $1
# Full path to the target function script.
#
# @return status+setoutput
# See the description below for possible status codes.
#
# **Possible status codes**
#
# 10 : Inválid path to script file.
# 11 : Empty documentation.
#
# 0  : Success
shellNS_manual_extract_raw_data() {
  #
  # Check param
  local scriptPath="${1}"
  shellNS_validate_param "${FUNCNAME[0]}" "fileExistentFullPath" "1" "" "" "" "${scriptPath}"
  if [ "$?" != "0" ]; then return 10; fi


  local strReturn+=$(shellNS_script_get_documentation "${scriptPath}")
  local intReturn="0"
  if [ "${strReturn}" == "" ]; then
    intReturn="11"
  fi
  shellNS_output_set "${FUNCNAME[0]}" "${intReturn}" "${strReturn}"
  return "${intReturn}"
}