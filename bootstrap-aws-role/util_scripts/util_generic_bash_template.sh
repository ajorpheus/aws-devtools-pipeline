#!/usr/bin/env bash
##### This script is only ever meant to be sourced ######

####### General bash settings to allow easier debugging of this script#####
# Set magic variables for current file, directory, etc.
#shellcheck disable=SC2154
__file="${__dir}/$(basename "${BASH_SOURCE[1]}")"
__base="$(basename "${__file}" .sh)"
readonly __file
readonly __base
##########################################################################

source_helpers() {
  # shellcheck source-path=SCRIPTDIR
  source "${__dir}/util_scripts/util_logging.sh" "${__base}.sh"

  # shellcheck source-path=SCRIPTDIR
  source "${__dir}/util_scripts/util_error_handling.sh"

  # shellcheck source-path=SCRIPTDIR
  source "${__dir}/util_scripts/util_common_functions.sh"
}

init() {
  source_helpers
  execute_function_if_defined "__script_init_vars" "$@"
  execute_function_if_defined "check_prerequisites"
  execute_function_if_defined "validate_env"
}

main() {
  init "$@"
  execute_function_if_defined "__execute_script_core_logic" "$@"
}

# Call the main function only if the script is sourced
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
  main "$@"
fi
