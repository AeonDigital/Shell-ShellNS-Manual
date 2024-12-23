#!/usr/bin/env bash

#
# Shows the manual or the part of it that was selected.
#
# @param dirExistentFullPath $1
# Full path to the target function manual.
#
# @param ?string $2
# Name of the section that should be shown.
#
# Select one of the following options:
# - s   : summary
# - d   : description
# - p   : parameters
# - r   : return
#
# If it is not defined, it will present the entire manual.
#
# @param ?int|string $3
# Parameter number or subsection name for the selected section at $2.
#
# Only used if '$2' is 'parameters' or 'return'.
#
# If 'parameters' set here the number of the parameter you want to see.
# If 'return' select one of the following options:
# - s : summary
# - d : description
# - t : type
#
# @param ?string $4
# Subsection of the selected parameter.
#
# Use only if $2 is 'parameters' and $3 is not empty.
# Select one of the following options:
# - s : summary
# - d : description
# - t : type
# - p : properties
#
# @return status+string
shellNS_manual_show() {
  #
  # Check param
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