#!/usr/bin/env bash

#
# Eliminates any blank space at the end of the indicated string.
#
# @param string $1
# String that will be changed.
#
# @return string
shellNS_string_trimR() {
  local strReturn="${1}"
  strReturn="${strReturn%"${strReturn##*[![:space:]]}"}" # trim R
  echo -ne "${strReturn}"
}
