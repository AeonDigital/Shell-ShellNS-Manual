#!/usr/bin/env bash

#
# Extracts the subsections from a technical documentation.
#
# Properties
# Used only in cases of description of function parameters.
#
# These are special properties that aim to regulate the validation of a
# parameter or offer selection and filling options for the user.  
# If it is present in the documentation, it should be located immediately
# after the declaration of the parameter to which it is linked, starting with
# a line where it has only **::** and also ending when it finds a line with
# only **::**
#
# **Summary**
# Is identified as the first lines of text in the documentation going all the
# way to the first line in the database or the beginning of the first
# subsection of data.
#
# **Description**
# It is all the information that exists between the summary and the end of the
# documentation or the beginning of the next subsection or list of options.
#
#
# @param fileExistentFullPath $1
# Full path to the target function script.
#
# @param ?string $2
# If informed, it must contain all documentation already normalized for
# **ansidown**
#
# @return status+setoutput
# See the description below for possible status codes.
#
# _,**Possible status codes**,_
#
# 10 : Invalid path to script file.  
# 11 : Empty documentation.
#
# 0  : Success
#
# _,**Get results**,_
#
# shellNS_output_show 0 1 : Properties  
# shellNS_output_show 1 1 : Summary  
# shellNS_output_show 2 1 : Description
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

              while [ "${#strTmpString01}" -lt "7" ]; do
                strTmpString01+=" "
              done

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