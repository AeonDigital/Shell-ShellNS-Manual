#!/usr/bin/env bash

#
# Handles the value of the special **list** property ensuring that its
# attributes are present and valid.
#
# Any attribute set with an invalid value will revert to the default.
#
# @param string $1
# List propertie definition.
#
# @return string
shellNS_manual_extract_subsections_properties_list_normalize() {
  local strListPropNameComplete=""

  local -a arrPropListParts=()
  shellNS_string_split "arrPropListParts" " " "${1}" "0" "1"
  local intTotalPropNameParts="${#arrPropListParts[@]}"

  local strPropListAssoc="${arrPropListParts[0]}"
  local strPropListType="c"
  local strPropListCase="ci"
  local strPropListMin="1"
  local strPropListMax="1"

  local -n assocPropList="${strPropListAssoc}"
  local intTotalListOptions="${#assocPropList[@]}"


  if [ "${intTotalPropNameParts}" -ge "2" ] && [ "${arrPropListParts[1]}" == "o" ]; then
    strPropListType="o"
  fi

  if [ "${intTotalPropNameParts}" -ge "3" ] && [ "${arrPropListParts[2]}" == "cs" ]; then
    strPropListCase="cs"
  fi

  if [ "${intTotalPropNameParts}" -ge "4" ] && [[ "${arrPropListParts[3]}" =~ ^[0-9]+$ ]]; then
    strPropListMin="${arrPropListParts[3]}"
    if [ "${arrPropListParts[3]}" -ge "1" ]; then
      strPropListMax="${arrPropListParts[3]}"
    fi
  fi

  if [ "${intTotalPropNameParts}" -ge "5" ] && [[ "${arrPropListParts[4]}" =~ ^[0-9]+$ ]]; then
    if [ "${arrPropListParts[4]}" == "0" ]; then
      if [ "${strPropListType}" == "o" ]; then
        strPropListMax="0"
      fi
    else
      if [ "${arrPropListParts[4]}" -gt "${strPropListMin}" ] && [ "${arrPropListParts[4]}" -le "${intTotalListOptions}" ]; then
        strPropListMax="${arrPropListParts[4]}"
      fi
    fi
  fi

  echo -ne "${strPropListAssoc} ${strPropListType} ${strPropListCase} ${strPropListMin} ${strPropListMax}"
}