#!/usr/bin/env bash
# shellcheck disable=SC2154

set -o errexit   # Fail fast if an error is encountered
set -o pipefail  # Look at all commands in a pipeline to detect failure, not just the last
set -o nounset   # Fail if an undeclared var is used
set -o functrace # Allow tracing of function calls
set -E           # Allow ERR signal to always be fired

err="\e[48;5;1m"
reset="\e[0m"

log_error() {
  printf "\n$(date "+%H:%M:%S") ${reset}:${err}%b${reset}\n\n" "${*}" >&2
  die 1
}

die() {
  local skip_frames="${1:-0}"
  # shellcheck disable=SC2124
  local extra_info="${@:2}"
  local frame=$skip_frames

  printf "%s\n" "***************** Stack Trace: ************" >&2
  (while caller "$frame"; do
    caller "$frame" | while read -r line_no function_name file_name; do echo -e "\t$(basename "$file_name"):$line_no\t$function_name"; done >&2
    ((frame++))
  done) || true

  echo "-- $extra_info --" >&2
  printf "%s\n" "***************** END Stack Trace: ************" >&2
  exit 1
}

failure() {
  local lineno=${1}
  local msg=${2}
  printf "\n$(timestamp) ${prefix_color}$(prefix)${reset}:  ${err} %b ${reset}\n\n" "Failed at ${lineno}: ${msg}. Killing script." >&2

  kill -9 $$
}

trap 'failure ${LINENO} "${BASH_COMMAND}"' ERR
