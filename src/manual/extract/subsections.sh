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
# a line where it has only '::' and also ending when it finds a line with
# only '::'
#
# Summary
# Is identified as the first lines of text in the documentation going all the
# way to the first line in the database or the beginning of the first
# subsection of data.
#
# Description
# It is all the information that exists between the summary and the end of the
# documentation or the beginning of the next subsection or list of options.
#
#
# @param fileExistentFullPath $1
# Full path to the target function script.
#
# @param ?string $2
# If informed, it must be the complete documentation from which the data will
# be extracted.
#
# @return status+setoutput
# See the description below for possible status codes.
#
# **Possible status codes**
#
# 10 : Inválid path to script file.
# 11 : Empty documentation.
#
# 0  : Success
#
# **Get results**
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