#!/bin/bash
#
# Required libraries:
#   * lib-ascii
#
# Optional variables:
#   * PS3
#   * PS5

#------------------------------------------------------------------------------
# Arguments:
#   * List of menu items
function print_menu() {
  local choice=0
  local string
  for string in "${@}"; do
    let ++choice
    printf "$(chr $((${choice}+96)))) %s\n" "${string}"
  done
}
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Arguments:
#   * Number of choices
function get_choice_number() {
  local choices=${1}
  local choice
  read -p "${PS3}" -N 1 choice
  local choice_number=$(($(ord ${choice})-97))
  if [ ${choice_number} -lt 0 ]; then
    let choice_number+=32
  fi
  echo
  if [ ${choice_number} -ge 0 -a ${choice_number} -le ${choices} ]; then
    return ${choice_number}
  else
    echo "${PS5}${choice}"
    return 65535
  fi
}
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Arguments:
#   * List of menu items
function select_letter() {
  local choice=
  local choice_strings=("${@}")
  local choices=${#choice_strings[@]}
  local choice_number=65535
  while [ ${choice_number} -lt 0 -o ${choice_number} -ge ${choices} ]; do
    print_menu "${choice_strings[@]}"
    get_choice_number ${choices}
    let choice_number=${?}
  done
  return ${choice_number}
}
#------------------------------------------------------------------------------
