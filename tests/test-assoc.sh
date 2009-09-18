#!/bin/bash

. ../lib-assoc_arrays.sh

function test_assoc() {
  declare -a arr src1 src2
  local x

  src1=('hola mundo' 'chau cacho')
  src2=('adios roberto' 'hasta la vista')

  copy_array_by_varnames src1 arr
  echo -n 'arr=src1=('
  for x in "${arr[@]}"; do
    echo -n " '${x}'"
  done
  echo ' )'

  copy_array_by_varnames src2 arr
  echo -n 'arr=src2=('
  for x in "${arr[@]}"; do
    echo -n " '${x}'"
  done
  echo ' )'

  echo "These below have to be empty:"
  echo "i = ${i}"
  echo "ubound = ${ubound}"
}

test_assoc
echo "These below have to be empty:"
echo "arr = ${arr[@]}"
echo "src1 = ${src1[@]}"
echo "src2 = ${src2[@]}"
