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
#***

#****f* commons/error_generate
# FUNCTION
#   Print input message and exit with value 1.
# INPUTS
#   msg       - message to print in stdout.
#   exit_call - Possible values:
#                   0 -> not execute exit 1,
#                   1 -> execute. Default.
# SOURCE
error_generate () {

  local exit_call=${2:-1}

  echo -en "$1\n"

  if [[ $exit_call -eq 1 || $exit_call == "1" ]] ; then
    exit 1
  fi

}
#***

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
#***

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
#***

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
#***

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
#***

#****f* commons/push_spaces
# FUNCTION
#   Push spaces to stdout.
# INPUTS
#   n_spaces    Number of spaces to write.
# SOURCE
push_spaces () {

  local n_spaces=$1

  if [ $n_spaces -gt 0 ] ; then
    for ((i=0; i<$n_spaces; i++))
    do
      echo -en " "
    done
  fi

  return 0
}
#***

#****f* commons/get_spaces_str
# FUNCTION
#   Create a string with input "str" param at begin and N spaces
#   where N is equal to max_chars - ${#str}
# INPUTS
#   var_name     Name of variable where save string with spaces.
#   max_chars    Number of max chars of the string with spaces.
#   str          String to insert at begin of save string.
#   pre_spaces   Number of spaces to add before str. (Optional. default 0).
# RETURN
#   0 on success
#   1 on error
# SOURCE
get_space_str () {
  local var_name="$1"
  local max_chars="$2"
  local str="$3"
  local pre_spaces="$4"

  [[ -z "$max_chars" || -z "$var_name" ]] && return 1

  local n_spaces="$((${max_chars} - ${#str}))"

  if [ -n "${pre_spaces}" ] ; then
    for ((i=0; i<${pre_spaces}; i++)) ; do
      str=" ${str}"
    done
  fi

  if [ $n_spaces -gt 0 ] ; then
    for ((i=0; i<$n_spaces; i++)) ; do
      str="${str} "
    done
  fi

  eval "$var_name=\$str"

  return 0
}
#***

#****f* commons/commons_exists_prog
# FUNCTION
#   Check if a program is available on current PATH.
# INPUTS
#   program     Name of the program.
#   options     Override default (-v) option on check presence. Optional.
# RETURN VALUE
#   0 if program exists
#   1 if program doesn't exist or invalid input param.
# SOURCE
commons_exists_prog () {

  local prog="$1"
  local opts="$2"
  local check_opts="-v"
  local ans=0

  [ -z "${prog}" ] && return 1

  if [ -n "${opts}" ] ; then
    check_opts="${opts}"
  fi

  ${prog} ${check_opts} > /dev/null 2>&1
  if [ $? -ne 0 ] ; then
    ans=1
  fi

  return $ans
}
#***

# vim: syn=sh filetype=sh
