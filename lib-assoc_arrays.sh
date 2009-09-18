#!/bin/bash

#------------------------------------------------------------------------------
# Arguments:
#   * Source array name
#   * Target array name
function copy_array_by_varnames() {
  local srcname="${1}"
  local varname="${2}"

  eval "${varname}=()"
  eval "local let ubound=\${#${srcname}[*]}"
  local i
  for (( i=0; ${i}<${ubound}; ++i )); do
    eval "${varname}[${i}]=\"\${${srcname}[${i}]}\""
  done
}
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Arguments:
#   * Element
#   * Array name
# Prints out: index of the array where the element is at or -1 if not found.
function index_in_array() {
  local element="${1}"
  local arrayname="${2}"

  eval "local let ubound=\${#${arrayname}[*]}"
  local i content
  for (( i=0; ${i}<${ubound}; ++i )); do
    eval "content=\"\${${arrayname}[${i}]}\""
    if [ "${element}" == "${content}" ]; then
      echo -n "${i}";
      return
    fi
  done
  echo -n "-1";
}
#------------------------------------------------------------------------------
