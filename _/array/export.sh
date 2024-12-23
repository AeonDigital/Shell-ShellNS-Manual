#!/usr/bin/env bash

#
# Converts the keys and values of the indicated array to string format.
#
# All values will be stored in a 'normalized' format, i.e. command characters
# such as '\n', '\r' and so on will be converted into a visible format to be
# printed and retrieved later.
#
# Each key/value set will be defined on its own row. So the output of this
# function will be a multiline string.
#
# @param array|assoc $1
# Array Name.
#
# @return string
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