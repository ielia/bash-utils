#!/bin/bash

#------------------------------------------------------------------------------
# Arguments:
#   * Source files specification.
#   * Target directory.
#   * Global password.
#   * Host specs, along with their login passwords
#     (format: "[user@]host[:individual-pass]")
# Overriden variables: REMOTESTATUS
# Returns: Amount of failed copy tries.
function copy_remote() {
  local filespec="${1}"
  local target_dir="${2}"
  local global_password="${3}"
  shift 3

  esc_filespec="${filespec//\$/\\\$}"
  esc_target_dir="${target_dir//\\/\\\\}"
  esc_target_dir="${esc_target_dir//\$/\\\$}"
  esc_target_dir="${esc_target_dir//\"/\\\"}"

  local let rv=0
  REMOTESTATUS=()
  local let i=0
  local hostspec_and_pass
  for hostspec_and_pass in "${@}"; do
    local hostspec="${hostspec_and_pass%%:*}"
    if [ "${hostspec}" == "localhost" ]; then
      cp -a ${filespec} "${target_dir}"
    else
      local pass="${hostspec_and_pass#*:}"
      if [ "${pass}" == "${hostspec_and_pass}" ]; then
        pass="${global_password}"
      fi
      if [ -z "${pass}" ]; then
        scp ${filespec} "${hostspec}:${target_dir}"
      else
        expect -c \
        	"spawn scp ${esc_filespec} \"${hostspec}:${esc_target_dir}\"; \
        	 set authentic 0; \
        	 expect \"assword:\" {send \"${pass}\\n\"; set authentic 1;} \
        	 	\"(yes/no)?\" {send \"yes\\n\";}; \
        	 if {\$authentic==0} \
        	 	{expect \"assword:\" {send \"${pass}\\n\"};}; \
        	 interact; \
        	 exit [lindex [wait] 3];"
      fi
    fi
    let REMOTESTATUS[${i}]=${?}
    if [ ${REMOTESTATUS[${i}]} -ne 0 ]; then
      let ++rv
    fi
    let ++i
  done
}
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Arguments:
#   * Commands string.
#   * Global password.
#   * Host specs, along with their login passwords
#     (format: "[user@]host[:individual-pass]").
# Overriden variables: REMOTESTATUS
# Returns: Amount of failed command blocks.
function exec_remote() {
  local commands="${1}"
  local global_password="${2}"
  shift 2

  esc_commands="${commands//\\/\\\\}"
  esc_commands="${esc_commands//\$/\\\$}"
  esc_commands="${esc_commands//\"/\\\"}"

  local let rv=0
  REMOTESTATUS=()
  local let i=0
  local hostspec_and_pass
  for hostspec_and_pass in "${@}"; do
    local hostspec="${hostspec_and_pass%%:*}"
    if [ "${hostspec}" == "localhost" ]; then
      bash -c "${commands}"
    else
      local pass="${hostspec_and_pass#*:}"
      if [ "${pass}" == "${hostspec_and_pass}" ]; then
        pass="${global_password}"
      fi
      if [ -z "${pass}" ]; then
        ssh ${hostspec} "${commands}"
      else
        expect -c \
        	"spawn ssh ${hostspec} \"${esc_commands}\"; \
        	 set authentic 0; \
        	 expect \"assword:\" {send \"${pass}\\n\"; set authentic 1;} \
        	 	\"(yes/no)?\" {send \"yes\\n\";}; \
        	 if {\$authentic==0} \
        	 	{expect \"assword:\" {send \"${pass}\\n\"};}; \
        	 interact; \
        	 exit [lindex [wait] 3];"
      fi
    fi
    let REMOTESTATUS[${i}]=${?}
    if [ ${REMOTESTATUS[${i}]} -ne 0 ]; then
      let ++rv
    fi
    let ++i
  done

  return ${rv}
}
#------------------------------------------------------------------------------
