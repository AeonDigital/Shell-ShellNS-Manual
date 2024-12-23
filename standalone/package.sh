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
shellNS_string_split() {
  if [ "$#" -ge "3" ]; then
    declare -n arrTargetArray="${1}"
    arrTargetArray=()
    local strSeparator="${2}"
    local strString="${3}"
    local strSubStr=""
    local boolRemoveEmpty=$(shellNS_get_default "${4}" "0" "0 1")
    local boolTrimElements=$(shellNS_get_default "${5}" "0" "0 1")
    local mseLastChar=""
    while [ "${strString}" != "" ]; do
      if [[ "${strString}" != *"${strSeparator}"* ]]; then
        if [ "${boolTrimElements}" == "1" ]; then
          strString=$(shellNS_string_trim "${strString}")
        fi
        arrTargetArray+=("${strString}")
        break
      else
        strSubStr="${strString%%${strSeparator}*}"
        if [ "${strSubStr}" == "" ] && [ "${strSeparator}" == " " ]; then
          strSubStr=" "
        fi
        mseLastChar="${strString: -1}"
        if [ "${boolTrimElements}" == "1" ]; then
          strSubStr=$(shellNS_string_trim "${strSubStr}")
        fi
        if [ "${strSubStr}" != "" ] || [ "${boolRemoveEmpty}" == "0" ]; then
          arrTargetArray+=("${strSubStr}")
        fi
        strString="${strString#*${strSeparator}}"
        if [ "${strString}" == "" ] && [ "${mseLastChar}" == "${strSeparator}" ] && [ "${boolRemoveEmpty}" == "0" ]; then
          arrTargetArray+=("")
        fi
      fi
    done
  fi
}
shellNS_string_normalize() {
  local strNormalized="${1//'\0'/}" # remove all null characters
  strNormalized=$(echo -ne "${strNormalized}")
  local -A assocStringCommands
  assocStringCommands['\\n']=$'\n'  # New Line
  assocStringCommands['\\t']=$'\t'  # Tab Horizontal
  assocStringCommands['\\r']=$'\r'  # Carriage Return
  assocStringCommands['\\b']=$'\b'  # Backspace
  assocStringCommands['\\a']=$'\a'  # Alert
  assocStringCommands['\\v']=$'\v'  # Tab Vertical
  assocStringCommands['\\f']=$'\f'  # Form Feed
  local strCmd=""
  local realCmd=""
  for strCmd in "${!assocStringCommands[@]}"; do
    realCmd="${assocStringCommands[${strCmd}]}"
    strNormalized="${strNormalized//${realCmd}/${strCmd}}"
  done
  echo -ne "${strNormalized}"
}
shellNS_string_trimR() {
  local strReturn="${1}"
  strReturn="${strReturn%"${strReturn##*[![:space:]]}"}" # trim R
  echo -ne "${strReturn}"
}
shellNS_script_get_documentation() {
  local scriptPath="${1}"
  if [ ! -f "${scriptPath}" ]; then
    return 1
  fi
  local strDocumentation=""
  local isDocumentationLine="0"
  local rawLine=""
  local useLine=""
  while IFS='' read -r rawLine || [[ -n "${rawLine}" ]]; do
    if [[ "${rawLine}" == \#!* ]]; then
      continue
    fi
    if [[ "${rawLine}" == \#* ]]; then
      isDocumentationLine="1"
      if [ "${rawLine}" == "#" ]; then
        rawLine=""
      fi
      useLine=$(shellNS_string_trimR "${rawLine}")
      strDocumentation+="${useLine/\# /}\n"
    else
      isDocumentationLine="0"
    fi
    if [ "${isDocumentationLine}" == "0" ] && [ "${strDocumentation}" != "" ] && [ "${rawLine}" != "" ]; then
      break
    fi
  done < "${scriptPath}"
  echo -e "${strDocumentation}"
  return 0
}
shellNS_get_default() {
  local strCurrentValue="${1}"
  local strDefaultValueIfEmptyOrInvalid="${2}"
  IFS=$'\n'
  local tmpCode="local -a arrValidOptions=("${3}")"
  eval "${tmpCode}"
  IFS=$' \t\n'
  local strReturn="${strDefaultValueIfEmptyOrInvalid}"
  if [ "${#arrValidOptions[@]}" == "0" ] && [ "${strCurrentValue}" != "" ]; then
    strReturn="${strCurrentValue}"
  fi
  if [ "${#arrValidOptions[@]}" -gt "0" ]; then
    local value=""
    for value in "${arrValidOptions[@]}"; do
      if [ "${strCurrentValue}" == "${value}" ]; then
        strReturn="${strCurrentValue}"
        break
      fi
    done
  fi
  echo -ne "${strReturn}"
}
shellNS_array_export() {
  local str=""
  local -n arrayToExport="${1}"
  local sep=$'\n'
  local k=""
  local v=""
  for k in "${!arrayToExport[@]}"; do
    v=$(shellNS_string_normalize "${arrayToExport[$k]}")
    str+="${k}=${v}${sep}"
  done
  if [ "${str}" != "" ]; then
    echo -n "${str:0: -1}"
  fi
}
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
  shellNS_manual_extract_documentation "${1}" "" "assocManual"
  if [ "$?" != "0" ]; then return $?; fi
  local pathToFunctionManual="${2}"
  if [ -d "${pathToFunctionManual}" ]; then
    find "${pathToFunctionManual}" -type f -exec rm -f {} \;
  fi
  if [ ! -d "${pathToFunctionManual}" ]; then
    mkdir -p "${pathToFunctionManual}"
  fi
  if [ ! -d "${pathToFunctionManual}" ]; then
    return 20
  fi
  local docKey=""
  local pathToDocKey=""
  for docKey in "${!assocManual[@]}"; do
    pathToDocKey="${pathToFunctionManual}/${docKey}"
    echo -n "${assocManual["${docKey}"]}" > "${pathToDocKey}"
    if [ "$?" != "0" ]; then
      return 21
    fi
  done
  return 0
}
shellNS_manual_extract_raw_data() {
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
shellNS_manual_extract_parameters_to_assoc_step_02() {
  local -n assocExtractedData="${1}"
  local strParamName=""
  local strParamRawData=""
  local k=""
  for k in "${!assocExtractedData[@]}"; do
    if [[ "${k}" == *"_raw" ]]; then
      strParamName="${k%_raw}"
      strParamRawData=$(echo -e "${assocExtractedData[${k}]}")
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
  local rawLine=""
  local -a splitLine=()
  while IFS='' read -r rawLine || [[ -n "${rawLine}" ]]; do
    if [[ "${rawLine}" == \@return* ]]; then
      break
    fi
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
shellNS_manual_extract_documentation() {
  local strFullRawDocumentation="${2}"
  local -n assocExtractedData="${3}"
  if [ "${2}" == "" ]; then
    shellNS_manual_extract_raw_data "${1}"
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
  return 0
}
shellNS_manual_extract_subsections() {
  local strFullRawDocumentation="${2}"
  if [ "${2}" == "" ]; then
    shellNS_manual_extract_raw_data "${1}"
    if [ "$?" != "0" ]; then return $?; fi
    strFullRawDocumentation=$(shellNS_output_show)
  fi
  local inProperties="0"
  local strProperties=""
  local strSummary=""
  local strDescription=""
  local searchFor="properties"
  local rawLine=""
  while IFS='' read -r rawLine || [[ -n "${rawLine}" ]]; do
    case "${searchFor}" in
      "properties")
        if [ "${inProperties}" == "0" ] && [ "${rawLine}" != "" ]; then
          if [ "${rawLine}" == "::" ]; then
            inProperties="1"
          else
            searchFor="summary"
            strSummary+="${rawLine}\n"
          fi
          continue
        fi
        if [ "${inProperties}" == "1" ]; then
          if [ "${rawLine}" == "::" ]; then
            searchFor="summary"
            continue
          else
            if [ "${rawLine}" != "" ]; then
              strProperties+=$(shellNS_string_trim "${rawLine}")
              strProperties+="\n"
            fi
          fi
        fi
      ;;
      "summary")
        if [ "${rawLine}" != "" ]; then
          strSummary+="${rawLine}\n"
        else
          if [ "${strSummary}" != "" ]; then
            searchFor="description"
          fi
        fi
        ;;
      "description")
        if [[ "${rawLine}" == \@* ]]; then
          break
        fi
        strDescription+="${rawLine}\n"
        ;;
    esac
  done <<< "${strFullRawDocumentation}"
  strProperties=$(shellNS_manual_extract_subsections_properties_convert_to_assoc "${strProperties}")
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
  local isInsideReturnSection="0"
  local rawLine=""
  local -a splitLine=()
  while IFS='' read -r rawLine || [[ -n "${rawLine}" ]]; do
    if [[ "${rawLine}" == \@return* ]]; then
      isInsideReturnSection="1"
      IFS=' ' read -r -a splitLine <<< "${rawLine}"
      assocExtractedData["return_type"]="${splitLine[1]}"
      assocExtractedData["return_summary"]=""
      assocExtractedData["return_description"]=""
      assocExtractedData["return_raw"]=""
    else
      if [ "${isInsideReturnSection}" == "1" ]; then
        assocExtractedData["return_raw"]+="${rawLine}\n"
      fi
    fi
  done <<< "${strFullRawDocumentation}"
  local rawReturnDoc=$(echo -e "${assocExtractedData[return_raw]}")
  if [ "${rawReturnDoc}" != "" ]; then
    shellNS_manual_extract_subsections "" "${rawReturnDoc}"
    if [ "$?" != "0" ]; then return 1; fi
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
    local -a arrAllowedSections=("s" "summary" "d" "description" "p" "parameters" "r" "return")
    strSelectionSectionName="${2}"
    shellNS_validate_param "${FUNCNAME[0]}" "?string" "2" "arrAllowedSections" "" "" "${strSelectionSectionName}"
    if [ "$?" != "0" ]; then return 11; fi
    strSelectionSectionName="${strSelectionSectionName:0:1}"
  fi
  local intSelectionParameterPosition=""
  local strSelectionParameterSubSection=""
  if [ "${strSelectionSectionName}" == "p" ] && [ "${3}" != "" ]; then
    intSelectionParameterPosition="${3}"
    shellNS_validate_param "${FUNCNAME[0]}" "?int" "3" "" "" "" "${intSelectionParameterPosition}"
    if [ "$?" != "0" ]; then return 13; fi
    if [ "${4}" != "" ]; then
      local -a arrAllowedParametersSubSections=("s" "summary" "d" "description" "t" "type" "p" "properties")
      strSelectionParameterSubSection="${4}"
      shellNS_validate_param "${FUNCNAME[0]}" "?string" "4" "arrAllowedParametersSubSections" "" "" "${strSelectionParameterSubSection}"
      if [ "$?" != "0" ]; then return 14; fi
      strSelectionParameterSubSection="${strSelectionParameterSubSection:0:1}"
    fi
  fi
  local strSelectionReturnSubSection=""
  if [ "${strSelectionSectionName}" == "r" ] && [ "${3}" != "" ]; then
    local -a arrAllowedReturnSubSections=("s" "summary" "d" "description" "t" "type")
    strSelectionReturnSubSection="${3}"
    shellNS_validate_param "${FUNCNAME[0]}" "?string" "3" "arrAllowedReturnSubSections" "" "" "${strSelectionReturnSubSection}"
    if [ "$?" != "0" ]; then return 15; fi
    strSelectionReturnSubSection="${strSelectionReturnSubSection:0:1}"
  fi
  local -a arrTargetDataFiles=()
  if [ "${strSelectionSectionName}" == "" ]; then
    arrTargetDataFiles+=("${pathToFunctionManual}/raw")
  else
    case "${strSelectionSectionName}" in
      "s")
        arrTargetDataFiles+=("${pathToFunctionManual}/summary")
        ;;
      "d")
        arrTargetDataFiles+=("${pathToFunctionManual}/description")
        ;;
      "p")
        if [ "${intSelectionParameterPosition}" == "" ]; then
          arrTargetDataFiles+=("${pathToFunctionManual}/param_raw")
        else
          local strParamFile="param_0${intSelectionParameterPosition}"
          if [ "${intSelectionParameterPosition}" -ge "10" ]; then
            strParamFile="param_${intSelectionParameterPosition}"
          fi
          case "${strSelectionParameterSubSection}" in
            "")
              strParamFile+="_raw"
              ;;
            "s")
              strParamFile+="_summary"
              ;;
            "d")
              strParamFile+="_description"
              ;;
            "p")
              strParamFile+="_properties"
              ;;
          esac
          arrTargetDataFiles+=("${pathToFunctionManual}/${strParamFile}")
        fi
        ;;
      "r")
        local strReturnFile="return_raw"
        if [ "${strSelectionReturnSubSection}" != "" ]; then
          local strReturnFile="return"
          case "${strSelectionReturnSubSection}" in
            "s")
              strReturnFile+="_summary"
              ;;
            "d")
              strReturnFile+="_description"
              ;;
            "t")
              strReturnFile+="_type"
              ;;
          esac
        fi
        arrTargetDataFiles+=("${pathToFunctionManual}/${strReturnFile}")
        ;;
    esac
  fi
  local strFilePath=""
  local strManualContent=""
  for strFilePath in "${arrTargetDataFiles[@]}"; do
    if [ ! -f "${strFilePath}" ]; then
      return 20
    fi
    strManualContent=$(< "${strFilePath}")
  done
  echo -ne "${strManualContent}"
}
