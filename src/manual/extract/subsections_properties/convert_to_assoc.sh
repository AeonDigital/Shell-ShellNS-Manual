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
  local strProperties=$(echo -e "${1}")
  local -gA tmpAssocProprierties

  if [ "${strProperties}" != "" ]; then
    local -a arrPropRaw=()
    local strPropName=""
    local strPropValue=""

    local -a arrAllowedPropertyNames=("default" "min" "max")

    local rawLine=""
    local strPropLine=""
    while IFS='' read -r rawLine || [[ -n "${rawLine}" ]]; do
      if [ "${rawLine:0:1}" == "-" ] && [[ "${rawLine}" == *:* ]]; then
        strPropLine="${rawLine:1}"
        strPropName=$(shellNS_string_trim "${strPropLine%%:*}")
        strPropValue=$(shellNS_string_trim "${strPropLine#*:}")

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
  fi

  shellNS_array_export "tmpAssocProprierties"
}