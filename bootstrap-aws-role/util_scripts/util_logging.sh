#!/usr/bin/env bash

################################################################ Logging Util functions ################################
prefix() { echo "${log_prefix_str:-""}"; }

#nested_spacing() { echo "${nested_spacing_str:-""}"; }
nested_spacing() {
  local spaces=""
  for _ in "${FUNCNAME[@]:6}"; do
    spaces="${spaces}  "
  done
  echo "$spaces"
}

define_colors_for_logging() {
  header="\e[0;33m"
  info="\e[1;37;42m"
  highlight="\e[1;33;46m"
  prefix_color="\e[1;37;41m"
  err="\e[48;5;1m"
  reset="\e[0m"
  COLUMNS=5
}
define_colors_for_logging

check_mark() {
  printf '\342\234\224\n' | iconv -f UTF-8
}

cross_mark() {
  printf '\342\235\214\n' | iconv -f UTF-8
}

timestamp() {
  echo ""
  #  date "+%H:%M:%S";
}

log_simple() { printf "%b\n" "$(printf "%b" "${*}" | sed -n "s/.*/$(nested_spacing)&/p")"; }
log_debug() { if [ -n "$debug" ]; then log_info_inline "$@"; fi; }
log_info() { printf "\n$(timestamp)$(nested_spacing)${prefix_color}$(prefix)${reset}: ${info}%b${reset}\n\n" "$(printf "%b" "${*}" | sed -n "s/.*/$(nested_spacing)&/p")"; }
log_info_inline() { printf "$(nested_spacing)${reset}${info}%b${reset}\n" "$(printf "%b" "${*}" | sed -n "s/.*/$(nested_spacing)&/p")"; }

display_header() { printf "\n$(timestamp) $(nested_spacing)${prefix_color}$(prefix)${reset}:${header}$(hr)%b$(hr)${reset}\n" "${*}"; }
highlight_red() { printf "${err}%b${reset}" "${*}"; }
highlight() { printf "$(timestamp) $(nested_spacing)${prefix_color}$(prefix)${reset}: ${highlight} \t %b ${reset}\n" "${*}"; }
hr() { printf '%*b\n' "10" '' | tr ' ' '-'; }

func_common_start() {
  local calling_func_name="${1:-${FUNCNAME[1]}}"
  old_nested_spacing_str="${nested_spacing_str}"
  old_log_prefix_str="${log_prefix_str}"

  if [ -n "$debug" ]; then
    log_simple "\n\n\n"
    display_header "Start: ${calling_func_name}" >&2
  fi
  nested_spacing_str="${nested_spacing_str}\t\t"
  log_prefix_str="${log_prefix_str}::${calling_func_name}"
}

func_common_end() {
  local calling_func_name="${1:-${FUNCNAME[1]}}"
  nested_spacing_str="${old_nested_spacing_str}"
  log_prefix_str="${old_log_prefix_str}"
  if [ -n "$debug" ]; then
    display_header "Finished ${calling_func_name}" >&2
    log_simple "\n\n\n"
  fi
}

log_prefix_str=${1:-""}
nested_spacing_str=""

debug=${debug:-""}
#######################################################################################################################
