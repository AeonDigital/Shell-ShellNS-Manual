#!/usr/bin/env bash

#
# From the complete documentation of a function populates an associative array
# with the data found for each identified parameter.
#
# Each parameter will gain its own prefix based on its position, being
# **param_01** for the first, 'param_02' for the second, and so on.
#
# The following values are populated in this step:
# - paramPrefix       : $1, $2, $3 ...
# - paramPrefix_type  : mixed, int, string ...
# - paramPrefix_raw   : Full text of parameter definition.
#
# A special position will be created in the associative array to maintain the
# total count of parameters that have been identified. This field will have
# the identifier **param_count**.
#
# Another special position is the **param_raw** which contains the sum of all
# the data of all the parameters.
#
# @param assoc $1
# Name of the associative array.
#
# @param string $2
# The complete documentation from which the data will be extracted.
#
# @return assoc
shellNS_manual_extract_parameters_to_assoc_step_01() {
  local -n assocExtractedData="${1}"
  local strFullDocumentation="${2}"

  local isInsideParameterSection="0"

  local strParamName=""
  local intParamPosition="0"

  local strParamRawLine=""
  assocExtractedData["param_raw"]=""

  local codeNL=$'\n'
  local strRawLine=""
  local -a splitLine=()
  local -a splitParam=()
  local strPDef=""
  local strPNull=""
  local strPType=""
  local strPName=""
  IFS=$'\n'
  while read -r strRawLine || [ -n "${strRawLine}" ]; do
    if [[ "${strRawLine}" == \@return* ]]; then
      break
    fi

    # When find a new parameter setting...
    if [[ "${strRawLine}" == \@param* ]]; then
      isInsideParameterSection="1"
      ((intParamPosition++))

      strParamName="param_${intParamPosition}"
      if [ "${intParamPosition}" -lt "10" ]; then
        strParamName="param_0${intParamPosition}"
      fi


      shellNS_string_split "splitLine" " " "${strRawLine}" "0" "1"
      strPDef=""
      strPNull=""
      strPType="${splitLine[1]}"
      strPName="${splitLine[2]}"

      if [ "${strPType}" == "" ]; then
        strPType="mixed"
      else
        if [[ "${strPType}" == *?* ]]; then
          strPNull="?"
          strPType="${strPType//\?/}"
        fi
      fi
      shellNS_string_split "splitParam" "|" "${strPType}" "0" "1"
      strPType=$(shellNS_array_join "|" "splitParam")


      strPDef="@param ${strPNull}${strPType} \$${intParamPosition}  ${codeNL}"


      assocExtractedData["${strParamName}"]="${strPName}"
      assocExtractedData["${strParamName}_def"]="${strPDef}"
      assocExtractedData["${strParamName}_type"]="${strPNull}${strPType}"

      assocExtractedData["${strParamName}_raw"]+="${strPDef}"
      assocExtractedData["param_raw"]+="${strPDef}"
    else
      if [ "${isInsideParameterSection}" == "1" ]; then
        assocExtractedData["${strParamName}_raw"]+="${strRawLine}${codeNL}"
        assocExtractedData["param_raw"]+="${strRawLine}${codeNL}"
      fi
    fi
  done <<< "${strFullDocumentation}"
  unset IFS

  assocExtractedData["param_count"]="${intParamPosition}"
}