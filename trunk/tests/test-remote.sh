#!/bin/bash

. ../lib-remote.sh

HOSTS=('www-data@ztest01' 'root@ztest01')
LHOST='dev064'

LOCALHOST_PASS=''

function test_copy_remote() {
  local FILESPEC='/tmp/hola.txt /tmp/chau.txt'
  local TARGET_DIR='/tmp'
  echo 'hola' > /tmp/hola.txt
  echo 'chau' > /tmp/chau.txt

  echo "First COPY test: ${HOSTS[@]}"
  copy_remote "${FILESPEC}" "${TARGET_DIR}" '' "${HOSTS[@]}"
  rv=${?}
  echo "RV = ${rv}, REMOTESTATUS = (${REMOTESTATUS[*]})"

  mkdir -p "${TARGET_DIR}/out"

  echo
  echo 'Second COPY test: localhost with global password'
  copy_remote "${FILESPEC}" "${TARGET_DIR}/out" "${LOCALHOST_PASS}" "localhost"
  rv=${?}
  echo "RV = ${rv}, REMOTESTATUS = (${REMOTESTATUS[*]})"
  echo
  echo 'Third COPY test: localhost with individual password'
  copy_remote "${FILESPEC}" "${TARGET_DIR}/out" '' "localhost:${LOCALHOST_PASS}"
  rv=${?}
  echo "RV = ${rv}, REMOTESTATUS = (${REMOTESTATUS[*]})"
  echo
  echo "Fourth COPY test: ${LHOST} with global password"
  copy_remote "${FILESPEC}" "${TARGET_DIR}/out" "${LOCALHOST_PASS}" "${LHOST}"
  rv=${?}
  echo "RV = ${rv}, REMOTESTATUS = (${REMOTESTATUS[*]})"
  echo
  echo "Fifth COPY test: ${LHOST} with individual password"
  copy_remote "${FILESPEC}" "${TARGET_DIR}/out" '' "${LHOST}:${LOCALHOST_PASS}"
  rv=${?}
  echo "RV = ${rv}, REMOTESTATUS = (${REMOTESTATUS[*]})"

  #rm ${FILESPEC}
  #rm -rf "${TARGET_DIR}/out"
}

function test_exec_remote() {
  local COMMAND='hostname; echo ${USER}; pwd; false'
  echo "First EXEC test: ${HOSTS[@]}"
  exec_remote "${COMMAND}" '' "${HOSTS[@]}"
  rv=${?}
  echo "RV = ${rv}, REMOTESTATUS = (${REMOTESTATUS[*]})"
  echo
  echo 'Second EXEC test: localhost with global password'
  exec_remote "${COMMAND}" "${LOCALHOST_PASS}" "localhost"
  rv=${?}
  echo "RV = ${rv}, REMOTESTATUS = (${REMOTESTATUS[*]})"
  echo
  echo 'Third EXEC test: localhost with individual password'
  exec_remote "${COMMAND}" '' "localhost:${LOCALHOST_PASS}"
  rv=${?}
  echo "RV = ${rv}, REMOTESTATUS = (${REMOTESTATUS[*]})"
  echo
  get_pass
  echo
  echo "Fourth EXEC test: ${LHOST} with global password"
  exec_remote "${COMMAND}" "${LOCALHOST_PASS}" "${LHOST}"
  rv=${?}
  echo "RV = ${rv}, REMOTESTATUS = (${REMOTESTATUS[*]})"
  echo
  echo "Fifth EXEC test: ${LHOST} with individual password"
  exec_remote "${COMMAND}" '' "${LHOST}:${LOCALHOST_PASS}"
  rv=${?}
  echo "RV = ${rv}, REMOTESTATUS = (${REMOTESTATUS[*]})"
}

function get_pass() {
  read -sp 'Password for localhost: ' LOCALHOST_PASS
}

test_exec_remote
echo
test_copy_remote
