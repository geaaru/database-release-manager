#!/bin/bash
#------------------------------------------------
# Author(s): Geaaru, geaaru@gmail.com
# $Id$
# License: GPL 2.0
#------------------------------------------------


# commons_assertNot
assertNot () {
  local result=$1
  local inv_res=$2
   if [ $result -eq $inv_res ] ; then
      echo -en "$3\n"
      exit 1
   fi
}
# commons_assertNot_end

# commons_error_handled
error_handled () {
   local result=$?
   if [ $result -ne 0 ] ; then
      echo -en "$1\n"
      exit 1
   fi
}
# commons_error_handled_end

# commons_error_generate
error_generate () {

  local exit_call=${2:-1}

  echo -en "$1\n"

  if [[ $exit_call -eq 1 || $exit_call == "1" ]] ; then
    exit 1
  fi

}
# commons_error_generate_end

# commons_check_var
check_var () {

  local var=$1

  eval v=\$$var

  if [ -z $v ] ; then
    return 1
  fi

  return 0
}
# commons_check_var_end

# commons_escape_var
escape_var () {

  local name="$1"

  eval v=\$$name

  v="$(echo "$v" | sed -e 's/\//\\\//g' -e 's:\\:\\\\:g' -e 's/\&/\\\&/g' -e 's:`:\\\`:g' )"

  eval "$name=\$v"

  return 0
}
# commons_escape_var_end

# commons_escape2oct_var
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
# commons_escape2oct_var_end

# commons_confirmation_question
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
# commons_confirmation_question_end

# commons_push_spaces
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
# commons_push_spaces_end

# commons_get_spaces_str
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
# commons_get_spaces_str_end

# commons_commons_exists_prog
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
# commons_commons_exists_prog_end

# vim: syn=sh filetype=sh
