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
#   * Number of letters per choice
#   * List of menu items
function print_menu() {
  local letters=${1}
  shift
  let --letters
  local choice=()
  local i
  for ((i=0; $i<=${letters}; ++i)) {
    choice[${i}]=32
  }
  choice[${letters}]=96
  local string
  let i=${letters}
  for string in "${@}"; do
    let ++choice[${i}]
    while [ ${choice[${i}]} -gt 122 ]; do
      choice[${i}]=97
      let --i
      if [ ${choice[${i}]} -lt 97 ]; then
        let choice[${i}]=97
      else
        let ++choice[${i}]
      fi
    done
    let i=${letters}
    for char in ${choice[*]}; do
      echo -n "$(chr ${char})"
    done
    echo ") ${string}"
  done
}
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Arguments:
#   * Number of letters per choice
#   * Number of choices
function get_choice_number() {
  local letters_per_choice=${1}
  local choices=${2}
  local choice
  read -e -p "${PS3}" -n ${letters_per_choice} choice
  local letters=${#choice}
  local choice_number=-1
  local choice_numbers=()
  local i=0
  for ((i=0; ${i}<${letters}; ++i)) {
    local choice_numbers[${i}]=$(($(ord ${choice:${i}:1})-97))
    if [ ${choice_numbers[${i}]} -lt 0 ]; then
      let choice_numbers[${i}]+=32
    fi
    let ++choice_number
    let choice_number*=26
    let choice_number+=choice_numbers[${i}]
  }
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
  local letters_per_choice=$(echo -e "scale=0\nl(${choices}-1)/l(26)+1" | bc -l)
  let letters_per_choice=${letters_per_choice%%.*}
  while [ ${choice_number} -lt 0 -o ${choice_number} -ge ${choices} ]; do
    print_menu ${letters_per_choice} "${choice_strings[@]}"
    get_choice_number ${letters_per_choice} ${choices}
    let choice_number=${?}
  done
  return ${choice_number}
}
#------------------------------------------------------------------------------
