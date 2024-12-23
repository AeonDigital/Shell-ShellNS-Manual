#!/usr/bin/env bash

if [[ "$(declare -p "SHELLNS_STANDALONE_LOAD_STATUS" 2> /dev/null)" != "declare -A"* ]]; then
  declare -gA SHELLNS_STANDALONE_LOAD_STATUS
fi
SHELLNS_STANDALONE_LOAD_STATUS["shellns_manual_standalone.sh"]="ready"
unset SHELLNS_STANDALONE_DEPENDENCIES
declare -gA SHELLNS_STANDALONE_DEPENDENCIES
shellNS_standalone_install_set_dependency() {
  local strDownloadFileName="shellns_${2,,}_standalone.sh"
  local strPkgStandaloneURL="https://raw.githubusercontent.com/AeonDigital/${1}/refs/heads/main/standalone/package.sh"
  SHELLNS_STANDALONE_DEPENDENCIES["${strDownloadFileName}"]="${strPkgStandaloneURL}"
}
shellNS_standalone_install_set_dependency "Shell-ShellNS-Types" "types"
shellNS_standalone_install_set_dependency "Shell-ShellNS-Output" "output"
declare -gA SHELLNS_DIALOG_TYPE_COLOR=(
  ["raw"]=""
  ["info"]="\e[1;34m"
  ["warning"]="\e[0;93m"
  ["error"]="\e[1;31m"
  ["question"]="\e[1;35m"
  ["input"]="\e[1;36m"
  ["ok"]="\e[20;49;32m"
  ["fail"]="\e[20;49;31m"
)
declare -gA SHELLNS_DIALOG_TYPE_PREFIX=(
  ["raw"]=" - "
  ["info"]="inf"
  ["warning"]="war"
  ["error"]="err"
  ["question"]=" ? "
  ["input"]=" < "
  ["ok"]=" v "
  ["fail"]=" x "
)
declare -g SHELLNS_DIALOG_PROMPT_INPUT=""
shellNS_standalone_install_dialog() {
  local strDialogType="${1}"
  local strDialogMessage="${2}"
  local boolDialogWithPrompt="${3}"
  local codeColorPrefix="${SHELLNS_DIALOG_TYPE_COLOR["${strDialogType}"]}"
  local strMessagePrefix="${SHELLNS_DIALOG_TYPE_PREFIX[${strDialogType}]}"
  if [ "${strDialogMessage}" != "" ] && [ "${codeColorPrefix}" != "" ] && [ "${strMessagePrefix}" != "" ]; then
    local strIndent="        "
    local strPromptPrefix="      > "
    local codeColorNone="\e[0m"
    local codeColorText="\e[0;49m"
    local codeColorHighlight="\e[1;49m"
    local tmpCount="0"
    while [[ "${strDialogMessage}" =~ "**" ]]; do
      ((tmpCount++))
      if (( tmpCount % 2 != 0 )); then
        strDialogMessage="${strDialogMessage/\*\*/${codeColorHighlight}}"
      else
        strDialogMessage="${strDialogMessage/\*\*/${codeColorNone}}"
      fi
    done
    local codeNL=$'\n'
    strDialogMessage=$(echo -ne "${strDialogMessage}")
    strDialogMessage="${strDialogMessage//${codeNL}/${codeNL}${strIndent}}"
    local strShowMessage=""
    strShowMessage+="[ ${codeColorPrefix}${strMessagePrefix}${codeColorNone} ] "
    strShowMessage+="${codeColorText}${strDialogMessage}${codeColorNone}\n"
    echo -ne "${strShowMessage}"
    if [ "${boolDialogWithPrompt}" == "1" ]; then
      SHELLNS_DIALOG_PROMPT_INPUT=""
      read -r -p "${strPromptPrefix}" SHELLNS_DIALOG_PROMPT_INPUT
    fi
  fi
  return 0
}
shellNS_standalone_install_dependencies() {
  if [[ "$(declare -p "SHELLNS_STANDALONE_DEPENDENCIES" 2> /dev/null)" != "declare -A"* ]]; then
    return 0
  fi
  if [ "${#SHELLNS_STANDALONE_DEPENDENCIES[@]}" == "0" ]; then
    return 0
  fi
  local pkgFileName=""
  local pkgSourceURL=""
  local pgkLoadStatus=""
  for pkgFileName in "${!SHELLNS_STANDALONE_DEPENDENCIES[@]}"; do
    pgkLoadStatus="${SHELLNS_STANDALONE_LOAD_STATUS[${pkgFileName}]}"
    if [ "${pgkLoadStatus}" == "" ]; then pgkLoadStatus="0"; fi
    if [ "${pgkLoadStatus}" == "ready" ] || [ "${pgkLoadStatus}" -ge "1" ]; then
      continue
    fi
    if [ ! -f "${pkgFileName}" ]; then
      pkgSourceURL="${SHELLNS_STANDALONE_DEPENDENCIES[${pkgFileName}]}"
      curl -o "${pkgFileName}" "${pkgSourceURL}"
      if [ ! -f "${pkgFileName}" ]; then
        local strMsg=""
        strMsg+="An error occurred while downloading a dependency.\n"
        strMsg+="URL: **${pkgSourceURL}**\n\n"
        strMsg+="This execution was aborted."
        shellNS_standalone_install_dialog "error" "${strMsg}"
        return 1
      fi
    fi
    chmod +x "${pkgFileName}"
    if [ "$?" != "0" ]; then
      local strMsg=""
      strMsg+="Could not give execute permission to script:\n"
      strMsg+="FILE: **${pkgFileName}**\n\n"
      strMsg+="This execution was aborted."
      shellNS_standalone_install_dialog "error" "${strMsg}"
      return 1
    fi
    SHELLNS_STANDALONE_LOAD_STATUS["${pkgFileName}"]="1"
  done
  if [ "${1}" == "1" ]; then
    for pkgFileName in "${!SHELLNS_STANDALONE_DEPENDENCIES[@]}"; do
      pgkLoadStatus="${SHELLNS_STANDALONE_LOAD_STATUS[${pkgFileName}]}"
      if [ "${pgkLoadStatus}" == "ready" ]; then
        continue
      fi
      . "${pkgFileName}"
      if [ "$?" != "0" ]; then
        local strMsg=""
        strMsg+="An unexpected error occurred while load script:\n"
        strMsg+="FILE: **${pkgFileName}**\n\n"
        strMsg+="This execution was aborted."
        shellNS_standalone_install_dialog "error" "${strMsg}"
        return 1
      fi
      SHELLNS_STANDALONE_LOAD_STATUS["${pkgFileName}"]="ready"
    done
  fi
}
shellNS_standalone_install_dependencies "1"
unset shellNS_standalone_install_set_dependency
unset shellNS_standalone_install_dependencies
unset shellNS_standalone_install_dialog
unset SHELLNS_STANDALONE_DEPENDENCIES
shellNS_array_get_key_by_value() {
  local -n arrayTargetData="${1}"
  local strSearchValue="${2}"
  local strKey=""
  echo -ne "${strKey}"
}
unset SHELLNS_MANUAL_SELECT_SHOW_SECTION
declare -gA SHELLNS_MANUAL_SELECT_SHOW_SECTION
SHELLNS_MANUAL_SELECT_SHOW_SECTION["a"]="all"
SHELLNS_MANUAL_SELECT_SHOW_SECTION["s"]="summary"
SHELLNS_MANUAL_SELECT_SHOW_SECTION["d"]="description"
SHELLNS_MANUAL_SELECT_SHOW_SECTION["p"]="parameters"
SHELLNS_MANUAL_SELECT_SHOW_SECTION["r"]="return"
unset SHELLNS_MANUAL_SELECT_SHOW_SUBSECTION
declare -gA SHELLNS_MANUAL_SELECT_SHOW_SUBSECTION
SHELLNS_MANUAL_SELECT_SHOW_SUBSECTION["a"]="all"
SHELLNS_MANUAL_SELECT_SHOW_SUBSECTION["s"]="summary"
SHELLNS_MANUAL_SELECT_SHOW_SUBSECTION["d"]="description"
SHELLNS_MANUAL_SELECT_SHOW_SUBSECTION["t"]="type"
SHELLNS_MANUAL_SELECT_SHOW_SUBSECTION["p"]="properties"
unset SHELLNS_MANUAL_COLOR_MAPPING_PLACEHOLDER
declare -gA SHELLNS_MANUAL_COLOR_MAPPING_PLACEHOLDER
SHELLNS_MANUAL_COLOR_MAPPING_PLACEHOLDER["{{NONE}}"]="\e[0m"
SHELLNS_MANUAL_COLOR_MAPPING_PLACEHOLDER["{{TEXT}}"]=""
SHELLNS_MANUAL_COLOR_MAPPING_PLACEHOLDER["{{CODE_BLOCK_SIGN}}"]=""
SHELLNS_MANUAL_COLOR_MAPPING_PLACEHOLDER["{{CODE_BLOCK_COMMENT}}"]=""
SHELLNS_MANUAL_COLOR_MAPPING_PLACEHOLDER["{{CODE_BLOCK_TEXT}}"]=""
SHELLNS_MANUAL_COLOR_MAPPING_PLACEHOLDER["{{LIST_BULLET}}"]=""
SHELLNS_MANUAL_COLOR_MAPPING_PLACEHOLDER["{{LIST_TEXT}}"]=""
SHELLNS_MANUAL_COLOR_MAPPING_PLACEHOLDER["{{SUBSECTION_AT}}"]=""
SHELLNS_MANUAL_COLOR_MAPPING_PLACEHOLDER["{{SUBSECTION_NAME}}"]=""
SHELLNS_MANUAL_COLOR_MAPPING_PLACEHOLDER["{{PARAM_DOLLAR}}"]=""
SHELLNS_MANUAL_COLOR_MAPPING_PLACEHOLDER["{{PARAM_NUMBER}}"]=""
SHELLNS_MANUAL_COLOR_MAPPING_PLACEHOLDER["{{PARAM_PROP_SIGN_BLOCK}}"]=""
SHELLNS_MANUAL_COLOR_MAPPING_PLACEHOLDER["{{PARAM_PROP_LIST_INDENT}}"]=""
SHELLNS_MANUAL_COLOR_MAPPING_PLACEHOLDER["{{PARAM_PROP_LIST_KEY}}"]=""
SHELLNS_MANUAL_COLOR_MAPPING_PLACEHOLDER["{{PARAM_PROP_LIST_COLON}}"]=""
SHELLNS_MANUAL_COLOR_MAPPING_PLACEHOLDER["{{PARAM_PROP_LIST_VALUE}}"]=""
SHELLNS_MANUAL_COLOR_MAPPING_PLACEHOLDER["{{TYPE_SIGN_SEPARATOR}}"]=""
SHELLNS_MANUAL_COLOR_MAPPING_PLACEHOLDER["{{TYPE_SIGN_NULLABLE}}"]=""
SHELLNS_MANUAL_COLOR_MAPPING_PLACEHOLDER["{{TYPE_SIGN_PLUS}}"]=""
SHELLNS_MANUAL_COLOR_MAPPING_PLACEHOLDER["{{TYPE_NAME}}"]=""
unset SHELLNS_MANUAL_PLACEHOLDER_NAME_COLLECTION
declare -ga SHELLNS_MANUAL_PLACEHOLDER_NAME_COLLECTION=()
for k in "${!SHELLNS_MANUAL_COLOR_MAPPING_PLACEHOLDER[@]}"; do
  SHELLNS_MANUAL_PLACEHOLDER_NAME_COLLECTION+=("${k}")
done
unset k
shellNS_manual_storage_restore() {
  local pathToFunctionManual="${1}"
  shellNS_validate_param "${FUNCNAME[0]}" "dirExistentFullPath" "1" "" "" "" "${pathToFunctionManual}"
  if [ "$?" != "0" ]; then return 10; fi
  local strAssocManualName="${2}"
  shellNS_validate_param "${FUNCNAME[0]}" "assoc" "2" "" "" "" "${strAssocManualName}"
  if [ "$?" != "0" ]; then return 11; fi
  local -n assocManual="${strAssocName}"
  local tmpKey=""
  for tmpKey in "${!assocManual[@]}"; do
    unset assocManual["${tmpKey}"]
  done
  local filePath=""
  local fileName=""
  local -a manualFiles=($(find "${pathToFunctionManual}" -maxdepth 1 -type f))
  for filePath in "${manualFiles[@]}"; do
    fileName="${filePath##*/}"
    assocManual["${fileName}"]=$(< "${filePath}")
  done
  return 0
}
shellNS_manual_storage_update() {
  local -A assocManual
  local -A assocManualColorized
  shellNS_manual_extract_documentation "${1}" "" "assocManual" "assocManualColorized"
  if [ "$?" != "0" ]; then return $?; fi
  local pathToStoreManual="${2}"
  local pathToStoreRawManual="${pathToStoreManual}/raw"
  local pathToStoreRawColorManual="${pathToStoreManual}/color"
  if [ -d "${pathToStoreManual}" ]; then
    find "${pathToStoreManual}" -type f -exec rm -f {} \;
  fi
  mkdir -p "${pathToStoreManual}"
  if [ ! -d "${pathToStoreManual}" ]; then return 20; fi
  mkdir -p "${pathToStoreRawManual}"
  if [ ! -d "${pathToStoreRawManual}" ]; then return 20; fi
  mkdir -p "${pathToStoreRawColorManual}"
  if [ ! -d "${pathToStoreRawColorManual}" ]; then return 20; fi
  local k=""
  for k in "${!assocManual[@]}"; do
    echo -n "${assocManual[${k}]}" > "${pathToStoreRawManual}/${k}"
    if [ "$?" != "0" ]; then return 21; fi
    echo -n "${assocManualColorized[${k}]}" > "${pathToStoreRawColorManual}/${k}"
    if [ "$?" != "0" ]; then return 21; fi
  done
  return 0
}
shellNS_manual_extract_raw_data() {
  local scriptPath="${1}"
  shellNS_validate_param "${FUNCNAME[0]}" "fileExistentFullPath" "1" "" "" "" "${scriptPath}"
  if [ "$?" != "0" ]; then return 10; fi
  local boolNormalize="1"
  if [ "${2}" == "0" ]; then boolNormalize="0"; fi
  local codeNL=$'\n'
  local intReturn="0"
  local strReturn=""
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
  local strPNull=""
  local strPType=""
  local strPName=""
  IFS=$'\n'
  while read -r strRawLine || [ -n "${strRawLine}" ]; do
    if [[ "${strRawLine}" == \@return* ]]; then
      break
    fi
    if [[ "${strRawLine}" == \@param* ]]; then
      isInsideParameterSection="1"
      ((intParamPosition++))
      strParamName="param_${intParamPosition}"
      if [ "${intParamPosition}" -lt "10" ]; then
        strParamName="param_0${intParamPosition}"
      fi
      shellNS_string_split "splitLine" " " "${strRawLine}" "0" "1"
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
      assocExtractedData["${strParamName}"]="${strPName}"
      assocExtractedData["${strParamName}_type"]="${strPType}"
      assocExtractedData["${strParamName}_raw"]+="@param ${strPNull}${strPType} \$${intParamPosition}  ${codeNL}"
      assocExtractedData["param_raw"]+="@param ${strPType} \$${intParamPosition}  ${codeNL}"
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
shellNS_manual_extract_parameters() {
  local strFullRawDocumentation="${2}"
  if [ "${2}" == "" ]; then
    shellNS_manual_extract_raw_data "${1}"
    if [ "$?" != "0" ]; then return $?; fi
    strFullRawDocumentation=$(shellNS_output_show)
  fi
  shellNS_manual_extract_parameters_to_assoc_step_01 "${3}" "${strFullRawDocumentation}"
  shellNS_manual_extract_parameters_to_assoc_step_02 "${3}"
}
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
shellNS_manual_extract_colorized() {
  local strAssocOriginalManual="${1}"
  shellNS_validate_param "${FUNCNAME[0]}" "assoc" "1" "" "" "" "${strAssocOriginalManual}"
  if [ "$?" != "0" ]; then return 1; fi
  local -n assocOriginalManual="${1}"
  local strAssocColorizedManual="${2}"
  shellNS_validate_param "${FUNCNAME[0]}" "assoc" "2" "" "" "" "${strAssocColorizedManual}"
  if [ "$?" != "0" ]; then return 1; fi
  local -n assocColorizedManual="${2}"
  local k=""
  for k in "${!assocOriginalManual[@]}"; do
    assocColorizedManual["${k}"]=$(shellNS_manual_extract_colorized_apply_color_markup "${assocOriginalManual[$k]}")
  done
  return 0
}
shellNS_manual_extract_colorized_apply_color_markup() {
  local strOriginal="${1}"
  if [ "${strOriginal}" == "" ]; then
    return 0
  fi
  local codeNL=$'\n'
  local strReturn=""
  local isIgnoreNextEmptyLines="0"
  local boolOpenBlockProperties="0"
  local boolOpenBlockList="0"
  local boolOpenBlockCode="0"
  local boolOpenBlockCodeCommentLine="0"
  local boolOpenBlockCodeCommentBlock="0"
  local -a splitLine=()
  local -a splitParam=()
  local strSubSectionName=""
  local boolTypeNull=""
  local strTypeName=""
  local strParamName=""
  local strTmpString01=""
  local strTmpString02=""
  local strNewLine=""
  local strRawLine=""
  local strTrimLine=""
  IFS=$'\n'
  while read -r strRawLine || [ -n "${strRawLine}" ]; do
    strNewLine=""
    strTrimLine=$(shellNS_string_trim_raw "${strRawLine}")
    if [ "${strTrimLine}" == "" ]; then
      boolOpenBlockList="0"
      strReturn+="${codeNL}"
      continue
    fi
    if [[ "${strTrimLine}" =~ ^@[a-zA-Z]+ ]]; then
      strSubSectionName=""
      shellNS_string_split "splitLine" " " "${strTrimLine}" "0" "1"
      strSubSectionName="${splitLine[0]:1}"
      if [ "${strSubSectionName}" == "param" ] || [ "${strSubSectionName}" == "return" ]; then
        boolTypeNull="0"
        strTypeName="${splitLine[1]}"
        strParamName="${splitLine[2]:1}"
        if [ "${strTypeName:0:1}" == "?" ]; then
          boolTypeNull="1"
          strTypeName="${splitLine[1]:1}"
        fi
        shellNS_string_split "splitParam" "|" "${strTypeName}" "0" "1"
        strTypeName=$(shellNS_array_join "{{TYPE_SIGN_SEPARATOR}}|{{NONE}}{{TYPE_NAME}}" "splitParam")
        if [[ "${strTypeName}" == *+* ]]; then
          strTmpString01="{{TYPE_SIGN_PLUS}}+{{NONE}}{{TYPE_NAME}}"
          strTypeName="${strTypeName//\+/${strTmpString01}}"
        fi
        strNewLine+="{{SUBSECTION_AT}}@{{NONE}}"
        strNewLine+="{{SUBSECTION_NAME}}${strSubSectionName}{{NONE}} "
        if [ "${boolTypeNull}" == "1" ]; then
          strNewLine+="{{TYPE_SIGN_NULLABLE}}?{{NONE}}"
        fi
        strNewLine+="{{TYPE_NAME}}${strTypeName}{{NONE}} "
        if [ "${strParamName}" != "" ]; then
          strNewLine+="{{PARAM_DOLLAR}}\${{NONE}}"
          strNewLine+="{{PARAM_NUMBER}}${strParamName}{{NONE}}"
        fi
        strReturn+="${strNewLine}  ${codeNL}"
        continue
      fi
      strNewLine+="{{SUBSECTION_AT}}@{{NONE}}"
      strNewLine+="{{SUBSECTION_NAME}}${strSubSectionName}{{NONE}}"
      strReturn+="${strNewLine}  ${codeNL}"
      continue
    fi
    if [ "${strTrimLine}" == "::" ]; then
      if [ "${boolOpenBlockProperties}" == "0" ]; then
        boolOpenBlockProperties="1"
        strReturn+="{{PARAM_PROP_SIGN_BLOCK}}::{{NONE}}  ${codeNL}"
      else
        boolOpenBlockProperties="0"
        strReturn+="{{PARAM_PROP_SIGN_BLOCK}}::{{NONE}}${codeNL}${codeNL}"
      fi
      isIgnoreNextEmptyLines="1"
      continue
    fi
    if [ "${boolOpenBlockProperties}" == "1" ]; then
      strReturn+="{{PARAM_PROP_LIST_INDENT}}"
      strReturn+="{{PARAM_PROP_LIST_KEY}}${strTrimLine%%\ :\ *}{{NONE}}"
      strReturn+="{{PARAM_PROP_LIST_COLON}} : {{NONE}}"
      strReturn+="{{PARAM_PROP_LIST_VALUE}}${strTrimLine#*\ :\ }{{NONE}}"
      strReturn+="  ${codeNL}"
      continue
    fi
    if [ "${strTrimLine:0:3}" == "\`\`\`" ]; then
      if [ "${boolOpenBlockCode}" == "0" ]; then
        boolOpenBlockCode="1"
        boolOpenBlockCodeCommentLine="0"
        boolOpenBlockCodeCommentBlock="0"
        strReturn+="{{CODE_BLOCK_SIGN}}${strTrimLine}{{NONE}}  ${codeNL}"
      else
        boolOpenBlockCode="0"
        strReturn+="{{CODE_BLOCK_SIGN}}\`\`\`{{NONE}}  ${codeNL}"
      fi
      continue
    fi
    if [ "${boolOpenBlockCode}" == "1" ]; then
      if [ "${strTrimLine:0:1}" == "#" ] || [ "${strTrimLine:0:2}" == "//" ]; then
        boolOpenBlockCodeCommentLine="1"
      fi
      if [ "${strTrimLine:0:2}" == "/*" ]; then
        boolOpenBlockCodeCommentBlock="1"
      fi
      strTrimLine=$(shellNS_string_trimR_raw "${strRawLine}")
      if [ "${boolOpenBlockCodeCommentLine}" == "0" ] && [ "${boolOpenBlockCodeCommentBlock}" == "0" ]; then
        strReturn+="{{CODE_BLOCK_TEXT}}${strTrimLine}{{NONE}}"
      else
        strReturn+="{{CODE_BLOCK_COMMENT}}${strTrimLine}{{NONE}}"
        boolOpenBlockCodeCommentLine="0"
        if [ "${strTrimLine: -2}" == "*/" ]; then
          boolOpenBlockCodeCommentBlock="0"
        fi
      fi
      strReturn+="  ${codeNL}"
      continue
    fi
    if [ "${#strTrimLine}" -ge "3" ] && [ "${strTrimLine:0:2}" == "- " ]; then
      boolOpenBlockList="1"
      strTrimLine=$(shellNS_string_trimR_raw "${strRawLine}")
      strTmpString01="${strTrimLine%%-*}"
      strTmpString02="${strTrimLine#*-\ }"
      strReturn+="${strTmpString01}"
      strReturn+="{{LIST_BULLET}}-{{NONE}} "
      strReturn+="{{LIST_TEXT}}${strTmpString02}{{NONE}}"
      strReturn+="  ${codeNL}"
      continue
    fi
    if [ "${boolOpenBlockList}" == "1" ]; then
      strTrimLine=$(shellNS_string_trimR_raw "${strRawLine}")
      strReturn+="{{LIST_TEXT}}${strTrimLine}{{NONE}}"
      strReturn+="  ${codeNL}"
      continue
    fi
    strReturn+="{{TEXT}}${strRawLine}{{NONE}}"
    strReturn+="${codeNL}"
  done <<< "${strOriginal}"
  unset IFS
  echo "${strReturn}"
}
shellNS_manual_extract_documentation() {
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
shellNS_manual_extract_subsections() {
  local strFullRawDocumentation="${2}"
  if [ "${2}" == "" ]; then
    shellNS_manual_extract_raw_data "${1}"
    if [ "$?" != "0" ]; then return $?; fi
    strFullRawDocumentation=$(shellNS_output_show)
  fi
  local codeNL=$'\n'
  local strSearchFor="properties"
  local boolOpenBlockProperties="0"
  local strSummary=""
  local strProperties=""
  local strDescription=""
  local strTrimLine=""
  local strTmpString01=""
  local strTmpString02=""
  local strRawLine=""
  IFS=$'\n'
  while read -r strRawLine || [ -n "${strRawLine}" ]; do
    if [[ "${strRawLine}" == \@* ]]; then
      break
    fi
    case "${strSearchFor}" in
      "properties")
        if [ "${boolOpenBlockProperties}" == "0" ] && [ "${strRawLine}" != "" ]; then
          if [ "${strRawLine:0:2}" == "::" ]; then
            strProperties+="::  ${codeNL}"
            boolOpenBlockProperties="1"
          else
            strSearchFor="summary"
            strSummary+="${strRawLine}${codeNL}"
          fi
          continue
        fi
        if [ "${boolOpenBlockProperties}" == "1" ]; then
          if [ "${strRawLine:0:2}" == "::" ]; then
            strProperties+="::${codeNL}${codeNL}"
            strSearchFor="summary"
            continue
          else
            strTrimLine=$(shellNS_string_trim_raw "${strRawLine}")
            if [ "${strTrimLine:0:2}" == "- " ] && [[ "${strTrimLine}" == *:* ]]; then
              strTrimLine="${strTrimLine:2}"
              strTmpString01=$(shellNS_string_trim_raw "${strTrimLine%%:*}")
              strTmpString02=$(shellNS_string_trim_raw "${strTrimLine#*:}")
              if [ "${strTmpString01}" == "list" ]; then
                strTmpString02=$(shellNS_manual_extract_subsections_properties_list_normalize "${strTmpString02}")
              fi
              strProperties+="  - ${strTmpString01} : ${strTmpString02}  ${codeNL}"
            fi
          fi
        fi
      ;;
      "summary")
        if [ "${strRawLine}" != "" ]; then
          strSummary+="${strRawLine}${codeNL}"
        else
          if [ "${strSummary}" != "" ]; then
            strSearchFor="description"
            continue
          fi
        fi
        ;;
      "description")
        strDescription+="${strRawLine}${codeNL}"
        ;;
    esac
  done <<< "${strFullRawDocumentation}"
  unset IFS
  shellNS_output_set "${FUNCNAME[0]}" "0" "${strProperties}" "${strSummary}" "${strDescription}"
  return 0
}
shellNS_manual_extract_return() {
  local strFullRawDocumentation="${2}"
  local -n assocExtractedData="${3}"
  if [ "${2}" == "" ]; then
    shellNS_manual_extract_raw_data "${1}"
    if [ "$?" != "0" ]; then return $?; fi
    strFullRawDocumentation=$(shellNS_output_show)
  fi
  local codeNL=$'\n'
  local isInsideReturnSection="0"
  local -a splitType=()
  local strReturnType=""
  local strReturnTypeNull=""
  local strRawLine=""
  IFS=$'\n'
  while read -r strRawLine || [ -n "${strRawLine}" ]; do
    if [[ "${strRawLine}" == \@return* ]]; then
      isInsideReturnSection="1"
      strReturnTypeNull=""
      strReturnType=$(shellNS_string_trim_raw "${strRawLine#\@return*}")
      if [ "${strReturnType}" == "" ]; then
        strReturnType="void"
      else
        if [[ "${strReturnType}" == *?* ]]; then
          strReturnTypeNull="?"
          strReturnType="${strReturnType//\?/}"
        fi
      fi
      shellNS_string_split "splitType" "|" "${strReturnType}" "0" "1"
      strReturnType=$(shellNS_array_join "|" "splitType")
      assocExtractedData["return_type"]="${strReturnTypeNull}${strReturnType}"
      assocExtractedData["return_summary"]=""
      assocExtractedData["return_description"]=""
      assocExtractedData["return_raw"]="@return ${strReturnTypeNull}${strReturnType}  ${codeNL}"
    else
      if [ "${isInsideReturnSection}" == "1" ]; then
        assocExtractedData["return_raw"]+="${strRawLine}${codeNL}"
      fi
    fi
  done <<< "${strFullRawDocumentation}"
  unset IFS
  local rawReturnDoc="${assocExtractedData["return_raw"]}"
  if [ "${rawReturnDoc}" != "" ]; then
    rawReturnDoc="${rawReturnDoc["return_raw"]#*${codeNL}}"
    shellNS_manual_extract_subsections "" "${rawReturnDoc}"
    if [ "$?" != "0" ]; then return $?; fi
    assocExtractedData["return_summary"]=$(shellNS_output_show "1" "1")
    assocExtractedData["return_description"]=$(shellNS_output_show "2" "0")
  fi
}
shellNS_manual_show() {
  local pathToFunctionManual="${1}"
  shellNS_validate_param "${FUNCNAME[0]}" "dirExistentFullPath" "1" "" "" "" "${pathToFunctionManual}"
  if [ "$?" != "0" ]; then return 10; fi
  local strSelectionSectionName=""
  if [ "${2}" != "" ]; then
    strSelectionSectionName="${2}"
    shellNS_validate_param "${FUNCNAME[0]}" "?string" "2" "SHELLNS_MANUAL_SELECT_SHOW_SECTION" "" "" "${strSelectionSectionName}"
    if [ "$?" != "0" ]; then return 11; fi
    strSelectionSectionName="${strSelectionSectionName:0:1}"
  fi
}
