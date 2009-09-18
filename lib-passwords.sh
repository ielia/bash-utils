#!/bin/bash
#
# Required variables:
#   PASSWORD_PROMPTS
#   PASSWORD_VARIABLES
#

#------------------------------------------------------------------------------
function ask_pass() {
  local prompt="${1}"
  local pass
  read -sp "${prompt}" pass
  echo "${pass}"
}
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
function get_passwords() {
  local pass
  local same_pass='INVALID'
  while [ "${same_pass//[nNyY]/}" != "" ]; do
    read -p 'Same password for all? (Y/n): ' same_pass
  done
  if [ "${same_pass//[yY]/}" == "" ]; then
    let same_pass=1
    pass=$(ask_pass "Main password: ")
    echo
  else
    let same_pass=0
  fi

  local let i=0;
  while [ "${PASSWORD_VARIABLES[${i}]}" != "" ]; do
    if [ ${same_pass} -eq 0 ]; then
      pass=$(ask_pass "Password for ${PASSWORD_PROMPTS[${i}]}: ")
      echo
    fi
    eval "${PASSWORD_VARIABLES[${i}]}='${pass}'"
    let ++i;
  done
}
#------------------------------------------------------------------------------
