#!/bin/bash

. ../lib-assoc_arrays.sh # Needed by lib-opts
. ../lib-opts.sh

# Configuration ---------------------------------------------------------------
GET_OPTS_PREFIX_AR='OPTS_AR_'
GET_OPTS_PREFIX_FN='opts_fn_'

GET_OPTS=(build branch help noupdate)
GET_OPTS_ARG=('directory' 'name' '' '')
GET_OPTS_EXP=('Specify the build directory' 'Specify the branch name' \
	'This help' 'Do not perform any updates')

OPTS_AR_branch=('branch')
OPTS_AR_build=('b' 'build')
OPTS_AR_help=('help')
OPTS_AR_noupdate=('n' 'dont-update')
#------------------------------------------------------------------------------

# Globals ---------------------------------------------------------------------
let used_opts=0
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
function opts_fn_() {
  if [ "${*}" != "" ]; then
    echo "The rest: ${*}"
  elif [ ${used_opts} -eq 0 ]; then
    get_opts_print_usage 1>&2
  fi
}

function opts_fn_branch() {
  let ++used_opts
  echo "Branch: ${1}"
}

function opts_fn_build() {
  let ++used_opts
  echo "Build: ${1}"
}

function opts_fn_help() {
  let ++used_opts
  get_opts_print_usage 1>&2
}

function opts_fn_noupdate() {
  let ++used_opts
  echo "No Update"
}
#------------------------------------------------------------------------------

get_opts "${@}"
