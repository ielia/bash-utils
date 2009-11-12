#!/bin/bash
#
# Required variables:
#   * GET_OPTS_PREFIX_AR (prefix for the option variables)
#   * GET_OPTS_PREFIX_FN (prefix for the option functions)
#   * GET_OPTS (option names array)
#   * GET_OPTS_ARG (option arguments array, sorted by GET_OPTS)
#   * GET_OPTS_EXP (option descriptions array, sorted by GET_OPTS)
#   * ${GET_OPTS_PREFIX_AR}_${GET_OPTS[@]} (command line options arrays per
#     	functionality)
#
# Required functions:
#   * copy_array_by_varnames (lib-assoc_arrays.sh)
#   * index_in_array (lib-assoc_arrays.sh)
#   * ${GET_OPTS_PREFIX_FN}_${GET_OPTS[@]} (option functions)
#   * ${GET_OPTS_PREFIX_FN}_ (option function for the rest of the command line)
#
# Provided:
#   * get_opts (commonly used as get_opts "${@}")
#   * get_opts_print_usage

#------------------------------------------------------------------------------
function get_opts() {
  # Build long and short options for getopt arguments
  local opts_short
  local opts_long
  get_opts_str_arguments opts_short '' opts_long ',' 0

  # Execute option gathering functions
  local args
  args=$(getopt -o "${opts_short}" -l "${opts_long}" -- "${@}")
  if (( ${?} )); then
    echo 1>&2
    get_opts_print_usage 1>&2
    return -1
  fi
  eval set -- "${args}"
  while [ true ]; do
    local let found=0
    local opt="${1}"
    local next="${2}"
    if [ "${opt}" == "--" ]; then
      shift
      break
    fi
    local opt_stripped="${opt#-}"
    opt_stripped="${opt_stripped#-}"
    local let i=0
    while [ ! -z "${GET_OPTS[${i}]}" ]; do
      local let idx=$(index_in_array "${opt_stripped}" \
      	"${GET_OPTS_PREFIX_AR}${GET_OPTS[${i}]}")
      if [ ${idx} -ge 0 ]; then
        found=1
        if [ -z "${GET_OPTS_ARG[${i}]}" ]; then
          eval "${GET_OPTS_PREFIX_FN}${GET_OPTS[${i}]}"
          shift
        else
          eval "${GET_OPTS_PREFIX_FN}${GET_OPTS[${i}]} \"\${next}\""
          shift 2
        fi
        break
      fi
      let ++i
    done
    if (( ! ${found} )); then
      echo "Invalid option: ${opt}" 1>&2
      echo 1>&2
      get_opts_print_usage 1>&2
      return -2
    fi
  done
  eval "${GET_OPTS_PREFIX_FN} \"\${*}\""
  return 0
}
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
function get_opts_str_arguments() {
  local short="${1}"
  local ssep="${2}"
  local long="${3}"
  local lsep="${4}"
  local printargs="${5}"

  eval "${short}=''"
  eval "${long}=''"
  local let i=0
  while [ ! -z "${GET_OPTS[${i}]}" ]; do
    local opt
    local opts_subarray
    copy_array_by_varnames "${GET_OPTS_PREFIX_AR}${GET_OPTS[${i}]}" \
    	opts_subarray
    local let j=0
    while [ ! -z "${opts_subarray[${j}]}" ]; do
      local opt="${opts_subarray[${j}]}"
      local opt_merged="${opt}"
      if [ ! -z "${GET_OPTS_ARG[${i}]}" ]; then
        if (( ! ${printargs} )); then
          opt_merged="${opt_merged}:"
        else
          opt_merged="${opt_merged} <${GET_OPTS_ARG[${i}]}>"
        fi
      fi
      if [ "${#opt}" -gt 1 ]; then
        eval "${long}=\"\${${long}}${lsep}${opt_merged}\""
      else
        eval "${short}=\"\${${short}}${ssep}${opt_merged}\""
      fi
      let ++j
    done
    let ++i
  done
  eval "${short}=\"\${${short}:${#ssep}}\""
  eval "${long}=\"\${${long}:${#lsep}}\""
}
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
function get_opts_print_usage() {
  local usage="${*}"

  #local opts_short
  #local opts_long
  #get_opts_str_arguments opts_short ' -' opts_long ' --' 1
  echo "Usage:"
  echo
  #echo "${0} -${opts_short} --${opts_long}" | fold -s
  if [ -z "${usage}" ]; then
    echo "${0} [OPTION]..."
  else
    echo "${usage}"
  fi
  echo

  echo "Options:"

  declare -a opt_specs comments
  local let i=0
  while [ "${GET_OPTS[${i}]}" ]; do
    local options=''
    declare -a op
    copy_array_by_varnames "${GET_OPTS_PREFIX_AR}${GET_OPTS[${i}]}" op
    local let j=0
    while [ ! -z "${op[${j}]}" ]; do
      if [ ${#op[${j}]} -gt 1 ]; then
        options="${options}, --${op[${j}]}"
      else
        options="${options}, -${op[${j}]}"
      fi
      let ++j
    done
    options="${options:2}"
    if [ -z "${GET_OPTS_ARG[${i}]}" ]; then
      opt_specs[${i}]=$(printf '    %s' "${options}")
    else
      opt_specs[${i}]=$(printf '    %s %s' "${options}" "<${GET_OPTS_ARG[${i}]}>")
    fi
    COLUMNS=${COLUMNS:-80}
    comments[${i}]=$(echo "${GET_OPTS_EXP[${i}]}" | \
    	fold -s -w $((${COLUMNS}-${#opt_specs[${i}]}-3)) | sed -e 's/^/\t/g')
    echo "${opt_specs[${i}]}"
    echo "${comments[${i}]}"
    let ++i
  done
}
#------------------------------------------------------------------------------
