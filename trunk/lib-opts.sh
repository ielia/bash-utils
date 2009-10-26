#!/bin/bash
#
# Required variables:
#   * OPT_PREFIX_AR (prefix for the option variables)
#   * OPT_PREFIX_FN (prefix for the option functions)
#   * OPTS (option names array)
#   * OPTS_ARG (option arguments array, sorted by OPTS)
#   * OPTS_EXP (option descriptions array, sorted by OPTS)
#   * ${OPT_PREFIX_AR}_${OPTS[@]} (command line options arrays per
#     	functionality)
#
# Required functions:
#   * copy_array_by_varnames (lib-assoc_arrays.sh)
#   * index_in_array (lib-assoc_arrays.sh)
#   * ${OPT_PREFIX_FN}_${OPTS[@]} (option functions)
#   * ${OPT_PREFIX_FN}_ (option function for the rest of the command line)
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
  if [ ${?} -ne 0 ]; then
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
    while [ ! -z "${OPTS[${i}]}" ]; do
      local let idx=$(index_in_array "${opt_stripped}" \
      	"${OPT_PREFIX_AR}${OPTS[${i}]}")
      if [ ${idx} -ge 0 ]; then
        found=1
        if [ -z "${OPTS_ARG[${i}]}" ]; then
          eval "${OPT_PREFIX_FN}${OPTS[${i}]}"
          shift
        else
          eval "${OPT_PREFIX_FN}${OPTS[${i}]} \"\${next}\""
          shift 2
        fi
        break
      fi
      let ++i
    done
    if [ ${found} -eq 0 ]; then
      echo "Invalid option: ${opt}" 1>&2
      echo 1>&2
      get_opts_print_usage 1>&2
      return -2
    fi
  done
  eval "${OPT_PREFIX_FN} \"\${*}\""
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
  while [ ! -z "${OPTS[${i}]}" ]; do
    local opt
    local opts_subarray
    copy_array_by_varnames "${OPT_PREFIX_AR}${OPTS[${i}]}" opts_subarray
    local let j=0
    while [ ! -z "${opts_subarray[${j}]}" ]; do
      local opt="${opts_subarray[${j}]}"
      local opt_merged="${opt}"
      if [ ! -z "${OPTS_ARG[${i}]}" ]; then
        if [ ${printargs} -eq 0 ]; then
          opt_merged="${opt_merged}:"
        else
          opt_merged="${opt_merged} <${OPTS_ARG[${i}]}>"
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
  while [ "${OPTS[${i}]}" ]; do
    local options=''
    declare -a op
    copy_array_by_varnames "${OPT_PREFIX_AR}${OPTS[${i}]}" op
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
    if [ -z "${OPTS_ARG[${i}]}" ]; then
      opt_specs[${i}]=$(printf '    %s' "${options}")
    else
      opt_specs[${i}]=$(printf '    %s %s' "${options}" "<${OPTS_ARG[${i}]}>")
    fi
    COLUMNS=${COLUMNS:-80}
    comments[${i}]=$(echo "${OPTS_EXP[${i}]}" | \
    	fold -s -w $((${COLUMNS}-${#opt_specs[${i}]}-3)) | sed -e 's/^/\t/g')
    echo "${opt_specs[${i}]}"
    echo "${comments[${i}]}"
    let ++i
  done
}
#------------------------------------------------------------------------------
