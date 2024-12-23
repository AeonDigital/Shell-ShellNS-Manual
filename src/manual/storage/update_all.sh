#!/usr/bin/env bash

#
# Process and save all manuals registered in 'SHELLNS_MAPP_FUNCTION_TO_MANUAL'
# assoc array.
#
# @param dirFullPath $2
# Full path to the location where the manuals should be saved.
#
# @param ?bool $2
# If "1" will run silently, without success messages.
#
# @return void
shellNS_manual_storage_update_all() {
  local strFullPathToStoreProcessedManuals="${1}/${SHELLNS_CONFIG_INTERFACE_LOCALE}"

  if [ -d "${strFullPathToStoreProcessedManuals}" ]; then
    rm -rf "${strFullPathToStoreProcessedManuals}"

    if [ -d "${strFullPathToStoreProcessedManuals}" ]; then
      shellNS_standalone_install_dialog "error" "Error on delete '"${strFullPathToStoreProcessedManuals}"' directory."
    fi
  fi

  mkdir -p "${strFullPathToStoreProcessedManuals}"
  if [ ! -d "${strFullPathToStoreProcessedManuals}" ]; then
    shellNS_standalone_install_dialog "error" "Error on create '"${strFullPathToStoreProcessedManuals}"' directory."
    return 1
  fi



  #local functionNS=""
  local functionName=""
  local pathToFileManual=""
  local relativePathToFileManual=""
  local pathToProcessedManual=""

  for functionName in "${!SHELLNS_MAPP_FUNCTION_TO_MANUAL[@]}"; do
    pathToFileManual="${SHELLNS_MAPP_FUNCTION_TO_MANUAL[${functionName}]}"
    relativePathToFileManual="${pathToFileManual#*/src-manuals/${SHELLNS_CONFIG_INTERFACE_LOCALE}/}"
    pathToProcessedManual="${strFullPathToStoreProcessedManuals}/${relativePathToFileManual:: -4}"
    
    shellNS_manual_storage_update "${pathToFileManual}" "${pathToProcessedManual}" "${functionName}"
    local intReturn="$?"
    if [ "${intReturn}" != "0" ]; then
      shellNS_output_set "${FUNCNAME[0]}" "0" "" --dialog "error" "Error on export '"${funcName}"' manual."
      shellNS_output_show
      return "${intReturn}"
    fi

    if [ "${2}" != "1" ]; then
      shellNS_output_set "${FUNCNAME[0]}" "0" "" --dialog "ok"  "Manual of '"${functionName}"' exported successfully."
      shellNS_output_show
    fi
  done

  return 0
}