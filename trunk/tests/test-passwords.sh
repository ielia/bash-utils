#!/bin/bash

PASS1=''
PASS2=''
PASSWORD_PROMPTS=('P1' 'P2')
PASSWORD_VARIABLES=(PASS1 PASS2)

. ../lib-passwords.sh

get_passwords

echo "PASS1=${PASS1}"
echo "PASS2=${PASS2}"
