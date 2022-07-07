#!/usr/bin/env bash
# shellcheck disable=SC2154

check_binary_on_path() {
  local binary_name="$1"
  command -v "$binary_name" >/dev/null 2>&1 || {
    log_error "$(cross_mark) $binary_name not found on PATH. Try re-running after installing $binary_name" >&2
    exit 1
  }
  log_info_inline "$(check_mark) Found $binary_name on PATH"
}

check_env_var() {
  local env_var_name="$1"
  #  log_simple "Checking if ${env_var_name} is set"

  if [ "${!env_var_name-}" == "" ]; then
    log_simple "$(cross_mark) ${env_var_name} is not set. Please set and re-run script."
    exit 1
  else
    log_simple "$(check_mark) ${env_var_name} is set."
  fi
}

# This function takes 2 or more arguments
# The first argument is always the name of another function
# The rest of the arguments are treated as a list of args each causing that function to be executed once
# The list of args could be a mix-and-match of comma separated lists or individual args
#     E.g.:
#     Any of these
#       exec_func_for_each_arg "foo" "arg1" "arg2,arg3" OR,
#       exec_func_for_each_arg "foo" "arg1,arg2,arg3" OR,
#       exec_func_for_each_arg "foo" "arg1" "arg2 "arg3"
#
#     will result in the following calls:
#             foo  "arg1"
#             foo  "arg2"
#             foo  "arg3"
exec_func_for_each_arg() {
  local arg_list funcname
  funcname="$1"
  shift
  arg_list=("$@")

  for arg in "${arg_list[@]}"; do
    IFS=',' read -ra arg_to_arr <<<"$arg" #Split each arg on comma delimiter

    for elem in "${arg_to_arr[@]}"; do
      $funcname "$elem"
    done

  done
}

execute_function_if_defined() {
  local funcname="$1"
  func_common_start "$funcname"

  shift
  local args=("$@")

  if [ "$(type -t "$funcname")" = 'function' ]; then
    "$funcname" "${args[@]}"
  else
    log_simple "$funcname does not exist"
  fi

  func_common_end "$funcname"
}

execute_function() {
  local funcname="$1"
  shift
  local args=("$@")

  func_common_start "$funcname"
  "$funcname" "${args[@]}"
  func_common_end "$funcname"
}

call_aws_api() {
  local cmd="$1"
  local optional_jquery_expression="${2:-""}"
  local output output_filtered

  log_info "Executing: $1" >&2
  if output="$($cmd --output json 2>&1)"; then
    log_info "Result:\n$output" >&2
    if [ -n "$optional_jquery_expression" ]; then
      if output_filtered="$(jq -c -e -r "$optional_jquery_expression" <<<"$output" 2>&1)"; then
        output="$output_filtered"
      else
        log_error "Error while applying\n$optional_jquery_expression\nto\n$output\nOutput:\n$output_filtered"
      fi
    fi

    printf "%s" "$output"
  else
    log_error "Error while executing\n$cmd\n\nOutput:\n$output\n"
    exit 1
  fi
  exit
}

check_prerequisites() {
  local __required_binaries_list="${required_binaries_list:-""}"
  log_simple "Checking ${__required_binaries_list[*]} is on PATH for ${__base}.sh"

  if [ -n "$__required_binaries_list" ]; then
    exec_func_for_each_arg "check_binary_on_path" "$__required_binaries_list"
  else
    log_simple "required_binaries_list is empty. Skipping pre-requisites check"
  fi
}

validate_env() {
  local account_id
  display_header "Checking that AWS env vars are present"
  exec_func_for_each_arg "check_env_var" "AWS_ACCESS_KEY_ID,AWS_SECRET_ACCESS_KEY,AWS_DEFAULT_REGION" "${required_env_args:-""}"
  log_info "Required AWS env vars are present"

  display_header "Validating AWS Creds for API Calls"
  if account_id="$(call_aws_api "aws sts get-caller-identity" ".Account")"; then
    log_info "Successfully validated AWS creds for Account Id: $account_id"
  else
    log_error "Error validating AWS creds"
  fi
}
