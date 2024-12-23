#!/usr/bin/env bash

#
# Shows the manual or the part of it that was selected.
#
#
# @param dirExistentFullPath $1
# full path to the target manual directory.
#
# @param bool $2
# Enter **1** to show the manual with color.
#
# @param ?string[,] $3
# ::
# - default : "*"
# - list    : SHELLNS_MANUAL_SELECT_SHOW_SECTION
# ::
# Name of the sections that should be shown.
#
#
# @param ?int[,] $4
# ::
# - default : "*"
# ::
# Number of the parameter position to be shown.
#
# Used only if **$3** has **parameters** in section selected list.
#
#
# @param ?string[,] $5
# ::
# - default : "*"
# - list    : SHELLNS_MANUAL_SELECT_SHOW_SUBSECTION
# ::
# Subsections names for the selected section at **$3**.
#
# Used only if **$3** has **parameters** or **return**.
#
# @return status+string
# See the description below for possible status codes.
#
# _,**Possible status codes**,_
#
# - `10` : Invalid path to manual directory.
# - `11` : Invalid selection.
# - `20` : Unable to create the storage directory.
# - `21` : Unable to create one or more manual files.
#
# - `0` : Success
shellNS_manual_show() {
  #
  # Check parans.
  # If documentation exists, and its integrity is valid
  local pathToFunctionManual="${1}/raw"
  shellNS_validate_param "${FUNCNAME[0]}" "dirExistentFullPath" "1" "" "" "" "${pathToFunctionManual}"
  if [ "$?" != "0" ]; then return 10; fi


  local boolShowWithColor="0"
  if [ "${2}" == "1" ]; then
    boolShowWithColor="1"

    pathToFunctionManual="${1}/color"
    shellNS_validate_param "${FUNCNAME[0]}" "dirExistentFullPath" "1" "" "" "" "${pathToFunctionManual}"
    if [ "$?" != "0" ]; then return 10; fi
  fi

  shellNS_validate_param "${FUNCNAME[0]}" "fileExistentFullPath" "1" "" "" "" "${pathToFunctionManual}/name"
  if [ "$?" != "0" ]; then return 10; fi



  local strSelectionedSections="${3}"
  local -a arraySelectionedSectionNames=()
  if [ "${strSelectionedSections}" == "" ]; then
    strSelectionedSections="*"
  fi

  local intSelectionParameterPositions="${4}"
  local -a arraySelectionedParameters=()
  if [ "${intSelectionParameterPositions}" == "" ]; then
    intSelectionParameterPositions="*"
  fi

  local strSelectionedSubsections="${5}"
  local -a arraySelectionedSubsectionNames=()
  if [ "${strSelectionedSubsections}" == "" ]; then
    strSelectionedSubsections="*"
  fi



  #
  # Check section selection.
  shellNS_validate_param "${FUNCNAME[0]}" "?string[,]" "3" "SHELLNS_MANUAL_SELECT_SHOW_SECTION" "" "" "${strSelectionedSections}"
  if [ "$?" != "0" ]; then return 11; fi

  arraySelectionedSectionNames=("${SHELLNS_TYPES_LAST_VALIDATE_VALUES_LIST[@]}")



  local it="0"
  local functionName=$(< "${pathToFunctionManual}/name")
  local totalParamCount=$(< "${pathToFunctionManual}/param_count")
  local boolSelectedParameter=$(shellNS_array_has_value "arraySelectionedSectionNames" "p")
  local boolSelectedReturn=$(shellNS_array_has_value "arraySelectionedSectionNames" "r")



  #
  # Check parameter selection.
  if [ "${boolSelectedParameter}" == "1" ]; then
    local -a arrAllowedSelectionedParans=()
    for ((it=1; it<=totalParamCount; it++)); do
      arrAllowedSelectionedParans+=("${it}")
    done

    shellNS_validate_param "${FUNCNAME[0]}" "?int[,]" "4" "arrAllowedSelectionedParans" "1" "${totalParamCount}" "${intSelectionParameterPositions}"
    if [ "$?" != "0" ]; then return 11; fi

    arraySelectionedParameters=("${SHELLNS_TYPES_LAST_VALIDATE_VALUES_LIST[@]}")
  fi



  #
  # Check subsection selection.
  if [[ "${boolSelectedParameter}" == "1" || "${boolSelectedReturn}" == "1" ]]; then
    shellNS_validate_param "${FUNCNAME[0]}" "?string[,]" "5" "SHELLNS_MANUAL_SELECT_SHOW_SUBSECTION" "" "" "${strSelectionedSubsections}"
    if [ "$?" != "0" ]; then return 11; fi

    arraySelectionedSubsectionNames=("${SHELLNS_TYPES_LAST_VALIDATE_VALUES_LIST[@]}")
  fi



  #
  # Select files to create presentation
  local strTmpContent=""

  local strType=""
  local strSummary=""
  local strDescription=""
  local strProperties=""

  local -a arrayContentManual=()
  local strManualHeader=""
  local strManualFooter=""
  if [ "${boolShowWithColor}" == "0" ]; then
    strManualHeader="** :: ${functionName} :: **"
    strManualFooter="** --- --- --- --- --- **"
  else
    strManualHeader="{{HEADER}} :: ${functionName} :: {{NONE}}"
    strManualFooter="{{FOOTER}} --- --- --- --- --- {{NONE}}"
  fi
  arrayContentManual+=("${strManualHeader}")


  if [ $(shellNS_array_has_value "arraySelectionedSectionNames" "s") == "1" ]; then
    strTmpContent=$(< "${pathToFunctionManual}/summary")
    strTmpContent=$(shellNS_string_trim_raw "${strTmpContent}")
    if [ "${strTmpContent}" != "" ]; then
      arrayContentManual+=("${strTmpContent}")
    fi
  fi

  if [ $(shellNS_array_has_value "arraySelectionedSectionNames" "d") == "1" ]; then
    strTmpContent=$(< "${pathToFunctionManual}/description")
    strTmpContent=$(shellNS_string_trim_raw "${strTmpContent}")
    if [ "${strTmpContent}" != "" ]; then
      arrayContentManual+=("${strTmpContent}")
    fi
  fi


  if [ $(shellNS_array_has_value "arraySelectionedSectionNames" "p") == "1" ]; then
    local pos=""
    local strPos=""

    for it in "${arraySelectionedParameters[@]}"; do
      if [ "${it}" -lt "10" ]; then pos="0${it}"; fi
      strTmpContent=""

      strPos="\$${it}"
      strType=""
      strSummary=""
      strDescription=""
      strProperties=""


      if [ $(shellNS_array_has_value "arraySelectionedSubsectionNames" "t") == "1" ]; then
        strType+=$(< "${pathToFunctionManual}/param_${pos}_def")
        strType+="\n"
      fi


      if [ $(shellNS_array_has_value "arraySelectionedSubsectionNames" "p") == "1" ]; then
        strProperties+=$(< "${pathToFunctionManual}/param_${pos}_properties")
        if [ "${strProperties}" != "" ]; then
          strProperties+="\n"
        fi
      fi


      if [ $(shellNS_array_has_value "arraySelectionedSubsectionNames" "s") == "1" ]; then
        strSummary+=$(< "${pathToFunctionManual}/param_${pos}_summary")
        if [ "${strSummary}" != "" ]; then
          strSummary+="\n"
        fi
      fi


      if [ $(shellNS_array_has_value "arraySelectionedSubsectionNames" "d") == "1" ]; then
        strDescription+=$(< "${pathToFunctionManual}/param_${pos}_description")
        if [ "${strDescription}" != "" ]; then
          strDescription+="\n"
        fi
      fi

      strTmpContent+="${strType}${strProperties}${strSummary}${strDescription}"
      strTmpContent=$(shellNS_string_trim_raw "${strTmpContent}")
      if [ "${strTmpContent}" != "" ]; then
        arrayContentManual+=("${strTmpContent}")
      fi
    done
  fi


  if [ $(shellNS_array_has_value "arraySelectionedSectionNames" "r") == "1" ]; then
    strTmpContent=""

    strType=""
    strSummary=""
    strDescription=""

    if [ $(shellNS_array_has_value "arraySelectionedSubsectionNames" "t") == "1" ]; then
      strType+=$(< "${pathToFunctionManual}/return_def")
      strType+="\n"
    fi

    if [ $(shellNS_array_has_value "arraySelectionedSubsectionNames" "s") == "1" ]; then
      strSummary+=$(< "${pathToFunctionManual}/return_summary")
      if [ "${strSummary}" != "" ]; then
        strSummary+="\n"
      fi
    fi

    if [ $(shellNS_array_has_value "arraySelectionedSubsectionNames" "d") == "1" ]; then
      if [ "${strSummary}" != "" ]; then
        strSummary+="\n"
      fi
      strDescription+=$(< "${pathToFunctionManual}/return_description")
      if [ "${strDescription}" != "" ]; then
        strDescription+="\n"
      fi
    fi

    strTmpContent+="${strType}${strSummary}${strDescription}"
    strTmpContent=$(shellNS_string_trim_raw "${strTmpContent}")
    if [ "${strTmpContent}" != "" ]; then
      arrayContentManual+=("${strTmpContent}")
    fi
  fi





  local strSep="\n\n"
  local strManualContent=$(shellNS_array_join "${strSep}" "arrayContentManual")
  strManualContent+="\n${strManualFooter}\n"

  local code_BlockCodeOpenClose="{{BLOCK_CODE_OPEN_CLOSE}}"
  strManualContent="${strManualContent//\`\`\`/${code_BlockCodeOpenClose}}"
  strManualContent=$(shellNS_string_parse_to_ansidown "${strManualContent}" "SHELLNS_MANUAL_COLOR_MAPPING_FONT_REPLACE")
  strManualContent="${strManualContent//${code_BlockCodeOpenClose}/\`\`\`}"

  if [ "${boolShowWithColor}" == "1" ]; then
    local ph=""
    local phcolor=""

    for ph in "${!SHELLNS_MANUAL_COLOR_MAPPING_PLACEHOLDER[@]}"; do
      phcolor="${SHELLNS_MANUAL_COLOR_MAPPING_PLACEHOLDER[${ph}]}"
      strManualContent="${strManualContent//${ph}/${phcolor}}"
    done
  fi

  echo -ne "${strManualContent}"
  return "0"
}