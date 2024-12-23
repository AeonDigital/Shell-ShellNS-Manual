#!/usr/bin/env bash

#
# Get path to the manuals directory.
SHELLNS_TMP_PATH_TO_DIR_MANUALS="$(tmpPath=$(dirname "${BASH_SOURCE[0]}"); realpath "${tmpPath}/src-manuals/${SHELLNS_CONFIG_INTERFACE_LOCALE}")"


#
# Mapp function to manual.
SHELLNS_MAPP_FUNCTION_TO_MANUAL["shellNS_manual_extract_colorized"]="${SHELLNS_TMP_PATH_TO_DIR_MANUALS}/manual/extract/colorized.man"
SHELLNS_MAPP_FUNCTION_TO_MANUAL["shellNS_manual_extract_documentation"]="${SHELLNS_TMP_PATH_TO_DIR_MANUALS}/manual/extract/documentation.man"
SHELLNS_MAPP_FUNCTION_TO_MANUAL["shellNS_manual_extract_parameters"]="${SHELLNS_TMP_PATH_TO_DIR_MANUALS}/manual/extract/parameters.man"
SHELLNS_MAPP_FUNCTION_TO_MANUAL["shellNS_manual_extract_parameters_to_assoc_step_01"]="${SHELLNS_TMP_PATH_TO_DIR_MANUALS}/manual/extract/parameters_to_assoc/step_01.man"
SHELLNS_MAPP_FUNCTION_TO_MANUAL["shellNS_manual_extract_parameters_to_assoc_step_02"]="${SHELLNS_TMP_PATH_TO_DIR_MANUALS}/manual/extract/parameters_to_assoc/step_02.man"
SHELLNS_MAPP_FUNCTION_TO_MANUAL["shellNS_manual_extract_raw_data"]="${SHELLNS_TMP_PATH_TO_DIR_MANUALS}/manual/extract/raw_data.man"
SHELLNS_MAPP_FUNCTION_TO_MANUAL["shellNS_manual_extract_return"]="${SHELLNS_TMP_PATH_TO_DIR_MANUALS}/manual/extract/return.man"
SHELLNS_MAPP_FUNCTION_TO_MANUAL["shellNS_manual_extract_subsections"]="${SHELLNS_TMP_PATH_TO_DIR_MANUALS}/manual/extract/subsections.man"
SHELLNS_MAPP_FUNCTION_TO_MANUAL["shellNS_manual_extract_subsections_properties_convert_to_assoc"]="${SHELLNS_TMP_PATH_TO_DIR_MANUALS}/manual/extract/subsections_properties/convert_to_assoc.man"
SHELLNS_MAPP_FUNCTION_TO_MANUAL["shellNS_manual_extract_subsections_properties_list_normalize"]="${SHELLNS_TMP_PATH_TO_DIR_MANUALS}/manual/extract/subsections_properties/list_normalize.man"
SHELLNS_MAPP_FUNCTION_TO_MANUAL["shellNS_manual_show"]="${SHELLNS_TMP_PATH_TO_DIR_MANUALS}/manual/show.man"
SHELLNS_MAPP_FUNCTION_TO_MANUAL["shellNS_manual_storage_restore"]="${SHELLNS_TMP_PATH_TO_DIR_MANUALS}/manual/storage/restore.man"
SHELLNS_MAPP_FUNCTION_TO_MANUAL["shellNS_manual_storage_update"]="${SHELLNS_TMP_PATH_TO_DIR_MANUALS}/manual/storage/update.man"
SHELLNS_MAPP_FUNCTION_TO_MANUAL["shellNS_manual_storage_update_all"]="${SHELLNS_TMP_PATH_TO_DIR_MANUALS}/manual/storage/update_all.man"


#
# Mapp namespace to function.
SHELLNS_MAPP_NAMESPACE_TO_FUNCTION["manual.extract.colorized"]="shellNS_manual_extract_colorized"
SHELLNS_MAPP_NAMESPACE_TO_FUNCTION["manual.extract.documentation"]="shellNS_manual_extract_documentation"
SHELLNS_MAPP_NAMESPACE_TO_FUNCTION["manual.extract.parameters"]="shellNS_manual_extract_parameters"
SHELLNS_MAPP_NAMESPACE_TO_FUNCTION["manual.extract.parameters.to.assoc.step.01"]="shellNS_manual_extract_parameters_to_assoc_step_01"
SHELLNS_MAPP_NAMESPACE_TO_FUNCTION["manual.extract.parameters.to.assoc.step.02"]="shellNS_manual_extract_parameters_to_assoc_step_02"
SHELLNS_MAPP_NAMESPACE_TO_FUNCTION["manual.extract.raw.data"]="shellNS_manual_extract_raw_data"
SHELLNS_MAPP_NAMESPACE_TO_FUNCTION["manual.extract.return"]="shellNS_manual_extract_return"
SHELLNS_MAPP_NAMESPACE_TO_FUNCTION["manual.extract.subsections"]="shellNS_manual_extract_subsections"
SHELLNS_MAPP_NAMESPACE_TO_FUNCTION["manual.extract.subsections.properties.convert.to.assoc"]="shellNS_manual_extract_subsections_properties_convert_to_assoc"
SHELLNS_MAPP_NAMESPACE_TO_FUNCTION["manual.extract.subsections.properties.list.normalize"]="shellNS_manual_extract_subsections_properties_list_normalize"
SHELLNS_MAPP_NAMESPACE_TO_FUNCTION["manual.show"]="shellNS_manual_show"
SHELLNS_MAPP_NAMESPACE_TO_FUNCTION["manual.storage.restore"]="shellNS_manual_storage_restore"
SHELLNS_MAPP_NAMESPACE_TO_FUNCTION["manual.storage.update"]="shellNS_manual_storage_update"
SHELLNS_MAPP_NAMESPACE_TO_FUNCTION["manual.storage.update.all"]="shellNS_manual_storage_update_all"





unset SHELLNS_TMP_PATH_TO_DIR_MANUALS