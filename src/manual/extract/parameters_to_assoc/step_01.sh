#!/usr/bin/env bash

#
# From the complete documentation of a function populates an associative array
# with the data found for each identified parameter.
#
# Each parameter will gain its own prefix based on its position, being
# 'param_01' for the first, 'param_02' for the second, and so on.
#
# The following values are populated in this step:
# - paramPrefix       : $1, $2, $3 ...
# - paramPrefix_type  : mixed, int, string ...
# - paramPrefix_raw   : Full text of parameter definition.
#
# A special position will be created in the associative array to maintain the
# total count of parameters that have been identified. This field will have
# the identifier 'param_count'.
#
# Another special position is the 'param_raw' which contains the sum of all
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

  local rawLine=""
  local -a splitLine=()
  while IFS='' read -r rawLine || [[ -n "${rawLine}" ]]; do
    if [[ "${rawLine}" == \@return* ]]; then
      break
    fi

    # When find a new parameter setting...
    if [[ "${rawLine}" == \@param* ]]; then
      isInsideParameterSection="1"
      ((intParamPosition++))

      strParamName="param_${intParamPosition}"
      if [ "${intParamPosition}" -lt "10" ]; then
        strParamName="param_0${intParamPosition}"
      fi

      IFS=' ' read -r -a splitLine <<< "${rawLine}"
      assocExtractedData["${strParamName}"]="${splitLine[2]}"
      assocExtractedData["${strParamName}_type"]="${splitLine[1]}"

      if [ "${splitLine[1]}" != "" ]; then
        assocExtractedData["${strParamName}_raw"]+="@param ${splitLine[1]} \$${intParamPosition}\n"
        assocExtractedData["param_raw"]+="@param ${splitLine[1]} \$${intParamPosition}\n"
      else
        assocExtractedData["${strParamName}_type"]="mixed"

        assocExtractedData["${strParamName}_raw"]+="@param mixed \$${intParamPosition}\n"
        assocExtractedData["param_raw"]+="@param mixed \$${intParamPosition}\n"
      fi
    else
      if [ "${isInsideParameterSection}" == "1" ]; then
        assocExtractedData["${strParamName}_raw"]+="${rawLine}\n"
        assocExtractedData["param_raw"]+="${rawLine}\n"
      fi
    fi
  done <<< "${strFullDocumentation}"

  assocExtractedData["param_count"]="${intParamPosition}"
}