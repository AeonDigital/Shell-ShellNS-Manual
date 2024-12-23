#!/usr/bin/env bash

#
# Converts the manual's associative array to a version containing the
# placeholders needed for its color presentation.
#
# Use the associative array obtained with the
# **shellNS_manual_extract_documentation** function.
#
# @param assoc $1
# Associative array containing the original manual.
#
# @param assoc $1
# Associative array that will receive the manual with the coloring markings.
#
# @return assoc
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
    if [ "${k}" == "param_count" ]; then
      assocColorizedManual["param_count"]="${assocOriginalManual[$k]}"
      continue
    fi
    assocColorizedManual["${k}"]=$(shellNS_manual_extract_colorized_apply_color_markup "${assocOriginalManual[$k]}")
  done

  return 0
}



#
# Applies the coloring markings to the target string.
#
# @param string $1
# Original string.
#
# @return string
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
  local intOpenBlockCodeLength="0"

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


    #
    # empty line
    if [ "${strTrimLine}" == "" ]; then
      boolOpenBlockList="0"

      strReturn+="${codeNL}"
      continue
    fi


    #
    # subsection definition line
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


    #
    # properties block ini/end
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
    #
    # propertie definition line
    if [ "${boolOpenBlockProperties}" == "1" ]; then
      local strPropLine="${strTrimLine:2}"
      local strPropName="${strPropLine%%\ :\ *}"
      local strPropValue="${strPropLine#*\ :\ }"

      strReturn+="{{PARAM_PROP_LIST_INDENT}}"
      strReturn+="{{PARAM_PROP_LIST_BULLET}}-{{NONE}} "
      strReturn+="{{PARAM_PROP_LIST_KEY}}${strPropName}{{NONE}}"
      strReturn+="{{PARAM_PROP_LIST_COLON}} : {{NONE}}"
      strReturn+="{{PARAM_PROP_LIST_VALUE}}${strPropValue}{{NONE}}"

      strReturn+="  ${codeNL}"
      continue
    fi


    #
    # code block ini/end
    if [ "${strTrimLine:0:3}" == "\`\`\`" ]; then
      if [ "${boolOpenBlockCode}" == "0" ]; then
        local strLang=$(shellNS_string_trim_raw "${strTrimLine:3}")
        ((intOpenBlockCodeLength=${#strLang}+3))

        boolOpenBlockCode="1"
        boolOpenBlockCodeCommentLine="0"
        boolOpenBlockCodeCommentBlock="0"
        strReturn+="{{CODE_BLOCK_SIGN}}\`\`\` {{NONE}}"
        strReturn+="{{CODE_BLOCK_LANG}} ${strLang} {{NONE}}  ${codeNL}"
      else
        local strCloseBlockPadding=""
        for ((i=0; i<${intOpenBlockCodeLength}; i++)); do
          strCloseBlockPadding+=" "
        done
        boolOpenBlockCode="0"
        strReturn+="{{CODE_BLOCK_SIGN}}\`\`\`${strCloseBlockPadding}{{NONE}}  ${codeNL}"
      fi
      continue
    fi
    #
    # code line
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


    #
    # list item line
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
    #
    # list line
    if [ "${boolOpenBlockList}" == "1" ]; then
      strTrimLine=$(shellNS_string_trimR_raw "${strRawLine}")
      strReturn+="{{LIST_TEXT}}${strTrimLine}{{NONE}}"

      strReturn+="  ${codeNL}"
      continue
    fi


    if [ "${strRawLine: -2}" == "  " ]; then
      strReturn+="{{TEXT}}${strRawLine:0: -2}{{NONE}}  "
    else
      strReturn+="{{TEXT}}${strRawLine}{{NONE}}"
    fi
    strReturn+="${codeNL}"
  done <<< "${strOriginal}"
  unset IFS


  echo "${strReturn}"
}