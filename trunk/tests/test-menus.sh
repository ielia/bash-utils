#!/bin/bash

. ../lib-ascii.sh
. ../lib-menus.sh

CMDS=($(seq 0 100) 'quit')
PS3="Choose: "
PS5="Invalid option: "
choice=0 # Set it to a valid index != quit
while [ "${CMDS[${choice}]}" != "quit" ]; do
  select_letter "${CMDS[@]}"
  choice=${?}
  echo ${CMDS[${choice}]}
done
