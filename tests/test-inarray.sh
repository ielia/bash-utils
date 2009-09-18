#!/bin/bash

. ../lib-assoc_arrays.sh

function test_inarray() {
  declare -a arr1 arr2
  local e i
  local x='chau cacho'

  arr1=('hola mundo' 'chau cacho')
  echo -n 'arr1 = ('
  for e in "${arr1[@]}"; do
    echo -n " '${e}'"
  done
  echo ' )'
  arr2=('adios roberto' 'hasta la vista')
  echo -n 'arr2 = ('
  for e in "${arr2[@]}"; do
    echo -n " '${e}'"
  done
  echo ' )'

  echo "x = ${x}"

  echo
  let i=$(index_in_array "${x}" arr1)
  echo "INDEX OF '${x}' IN arr1: ${i} (exp.: 1)"
  let i=$(index_in_array "${x}" arr2)
  echo "INDEX OF '${x}' IN arr2: ${i} (exp.: -1)"
  let i=$(index_in_array "${x}" arr1)
  echo "INDEX OF '${x}' IN arr1: ${i} (exp.: 1)"
  let i=$(index_in_array "${x}" arr2)
  echo "INDEX OF '${x}' IN arr2: ${i} (exp.: -1)"
}

test_inarray
