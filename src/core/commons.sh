#!/bin/bash
#------------------------------------------------
# Author(s): Geaaru, geaaru@gmail.com
# $Id$
# License: GPL 2.0
#------------------------------------------------

#****f* commons/error_handled
# FUNCTION
#   Check if last command result. If result is not equal to 0 then
#   print a message to stdout and exit with value 1.
# INPUTS
#   msg       - message to print if result is not equal to zero.
# SOURCE
error_handled () {
   local result=$?
   if [ $result -ne 0 ] ; then
      echo -en "$1\n"
      exit 1
   fi
}
#****

#****f* commons/error_generate
# FUNCTION
#   Print input message and exit with value 1.
# INPUTS
#   msg       - message to print in stdout.
# SOURCE
error_generate () {

  echo -en "$1\n"
  exit 1

}
#****

#****f* commons/check_var
# FUNCTION
#   Check if variable with name in input contains a string or not.
# INPUT
#   var       Name of the variable to check.
# RETURN VALUE
#   1 length of the variable is zero.
#   0 length of the variable is not zero.
# SOURCE
check_var () {

  local var=$1

  eval v=\$$var

  if [ -z $v ] ; then
    return 1
  fi

  return 0
}
#****

#****f* commons/escape_var
# FUNCTION
#   Escape content of the variable with input name.
# INPUT
#   var       Name of the variable to check.
# RETURN VALUE
#   0 always
# SOURCE
escape_var () {

  local name="$1"

  eval v=\$$name

  v="$(echo "$v" | sed -e 's/\//\\\//g' -e 's:\\:\\\\:g' -e 's/\&/\\\&/g' -e 's:`:\\\`:g' )"

  eval "$name=\$v"

  return 0
}
#****

escape2oct_var () {

  local name="$1"

  eval v=\$$name

  # TODO: Handle replace through input params selection
  v="$(echo "$v" | sed -e 's:\/:\\057:g' -e 's:`:\\0140:g' )"
  #v="$(echo "$v" | sed -e 's:\\n:\\012:g' -e 's:\/:\\057:g' -e 's:\\:\\0134:g' -e 's:`:\\0140:g' )"
  #v="$(echo "$v" | sed -e 's:\\n:\\012:g' -e 's:\/:\\057:g' -e 's:\\:\\0134:g' -e 's:`:\\0140:g' )"

  eval "$name=\$v"

  return 0
}

#****f* commons/confirmation_question
# FUNCTION
#   Use to generate an input question and manage response.
# INPUTS
#   msg         - message with question for user.
# RETURN VALUE
#   0   if user answer is yes.
#   1   if user answer is no.
#   2   if user answer empty.
# SOURCE
confirmation_question () {
   echo -en "$1"
   read ans

   [[ $DEBUG ]] && echo -en "Answer: $ans\n"
   if [ -z $ans ]; then
      return 2
   fi

   if [[ x"$ans" == "xyes" || x"$ans" == "xY" || x"$ans" == "xy" || x"$ans" == "xYes" ]] ; then
      return 0
   fi

   return 1
}
#****

# vim: syn=sh filetype=sh
