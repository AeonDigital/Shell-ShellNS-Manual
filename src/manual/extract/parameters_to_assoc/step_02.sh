#!/usr/bin/env bash

#
# It goes through the raw data of each parameter identified in the previous
# step and extracts from it another series of data that will be aggregated in
# the associative array.
#
# The following values are populated in this step:
# - paramPrefix_properties
# - paramPrefix_summary
# - paramPrefix_description
#
# @param assoc $1
# Name of the associative array.
#
# @return assoc
shellNS_manual_extract_parameters_to_assoc_step_02() {
  local -n assocExtractedData="${1}"

  local codeNL=$'\n'
  local strParamName=""
  local strParamRawData=""

  local k=""
  for k in "${!assocExtractedData[@]}"; do
    if [[ "${k}" == *"_raw" ]] && [ "${k%_raw}" != "param" ]; then
      strParamName="${k%_raw}"
      strParamRawData="${assocExtractedData[${k}]#*${codeNL}}"

      shellNS_manual_extract_subsections "" "${strParamRawData}"
      if [ "$?" != "0" ]; then return 1; fi

      assocExtractedData["${strParamName}_properties"]=$(shellNS_output_show "0" "1")
      assocExtractedData["${strParamName}_summary"]=$(shellNS_output_show "1" "1")
      assocExtractedData["${strParamName}_description"]=$(shellNS_output_show "2" "0")
    fi
  done
}