#!/usr/bin/env bash

#
# Prepares the property information of a parameter in a way that facilitates
# its future use in an associative array.
#
# @param string $1
# Properties that will be organized.
#
# @return string
shellNS_manual_extract_subsections_properties_convert_to_assoc() {
  local strReturn=""
  local strProperties="${1}"
  local -gA tmpAssocProprierties

  if [ "${strProperties}" != "" ]; then
    local -a arrPropRaw=()
    local strPropName=""
    local strPropValue=""

    local -a arrAllowedPropertyNames=("default" "min" "max")

    local rawLine=""
    local strPropLine=""

    local strRawLine=""
    IFS=$'\n'
    while read -r strRawLine || [ -n "${strRawLine}" ]; do
      if [ "${strRawLine:0:1}" == "-" ] && [[ "${strRawLine}" == *:* ]]; then
        strPropLine="${strRawLine:1}"
        strPropName=$(shellNS_string_trim_raw "${strPropLine%%:*}")
        strPropValue=$(shellNS_string_trim_raw "${strPropLine#*:}")

        if [ "${strPropValue}" != "" ]; then
          if [ $(shellNS_array_has_value "arrAllowedPropertyNames" "${strPropName}") == "1" ]; then
            tmpAssocProprierties["${strPropName}"]="${strPropValue}"
          else
            if [ "${strPropName}" == "list" ]; then
              strPropValue=$(shellNS_manual_extract_subsections_properties_list_normalize "${strPropValue}")
              tmpAssocProprierties["${strPropName}"]="${strPropValue}"
            fi
          fi
        fi
      fi
    done <<< "${strProperties}"
    unset IFS
  fi

  shellNS_array_export "tmpAssocProprierties"
}