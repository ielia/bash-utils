#!/bin/bash

. ../lib-assoc_arrays.sh # Needed by lib-opts
. ../lib-opts.sh

# Configuration ---------------------------------------------------------------
OPT_PREFIX_AR='OPTS_AR_'
OPT_PREFIX_FN='opts_fn_'

OPTS_AR_branch=('branch')
OPTS_AR_build=('b' 'build')
OPTS_AR_help=('help')
OPTS_AR_noupdate=('n' 'dont-update')

OPTS=(build branch help noupdate)
OPTS_ARG=('directory' 'name' '' '')
OPTS_EXP=('Specify the build directory' 'Specify the branch name' \
	'This help' 'Do not perform any updates')
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
function opts_fn_() {
  if [ "${*}" != "" ]; then
    echo "The rest: ${*}"
  fi
}

function opts_fn_branch() {
  echo "Branch: ${1}"
}

function opts_fn_build() {
  echo "Build: ${1}"
}

function opts_fn_help() {
  get_opts_print_usage 1>&2
}

function opts_fn_noupdate() {
  echo "No Update"
}
#------------------------------------------------------------------------------

get_opts "${@}"
