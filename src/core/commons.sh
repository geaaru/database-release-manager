#!/bin/bash
#------------------------------------------------
# Author(s): Geaaru, geaaru@gmail.com
# $Id$
# License: GPL 2.0
#------------------------------------------------

error_handled () {
   local result=$?
   if [ $result -ne 0 ] ; then
      echo -en "$1\n"
      exit 1
   fi
}

error_generate () {

  echo -en "$1\n"
  exit 1

}

check_var () {

  local var=$1

  eval v=\$$var

  if [ -z $v ] ; then
    return 1
  fi

  return 0
}

escape_var () {

  local name="$1"

  eval v=\$$name

  v="$(echo "$v" | sed -e 's/\/\\\//g' -e 's/\&/\\\&/g' -e 's/\`/\\\`/g' )"

  echo "----"
  echo "$v"
  echo "----"

  set -f
  eval "$name=\$v"a
  set +f

  return 0
}


# return 0   yes
# return 1   no
# return 2   empty
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

# vim: syn=sh filetype=sh
