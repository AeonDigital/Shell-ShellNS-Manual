#!/usr/bin/env bash

#
# Extracts technical documentation from a script in plain text format.
#
# This is the first block of comment within the target script file.
#
# @param fileExistentFullPath $1
# Full path to the target function script.
#
# @return string
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