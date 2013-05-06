#!/bin/bash
#------------------------------------------------
# Author(s): Geaaru, geaaru@gmail.com
# $Id$
# License: GPL 2.0
#------------------------------------------------

# Set sqlplus_auth variable with
# authentication string like: USER/PASSWD@TNSNAME
sqlplus_set_sqlplus_auth_var () {

  local db=$1
  local user=$2
  local pwd=$3

  export sqlplus_auth="$user/$pwd@$db"

  [[ $DEBUG && $DEBUG == true ]] && echo "Use $sqlplus_auth"

}

# Compile a file
# and save output to input variable
# $1 => Variable name where is save output
# $2 => File to compile
#
# return 0 on success
# return 1 on error
sqlplus_file() {

  local var=$1
  local f=$2
  local v=""

  v=$($SQLPLUS -S -l $sqlplus_auth 2>&1 <<EOF
@$f;
exit;
EOF
)

  local ans=$?

  [[ $DEBUG && $DEBUG == true ]] && echo "Compile $f ==> $v ($ans)"

  #v=`echo $v | sed 's/\n/\r/g'`
  eval "$var=\$v"
  #read -r "$var" <<< "$v"

  return $ans
}

sqlplus_cmd_4var() {

  set -f
  local var=$1
  local cmd="$2"
  local rm_ln=$3
  local v=""
  local feedback="$4"

  if [[ $feedback == '' ]] ; then
    feedback="off"
  fi

  v=$($SQLPLUS -S -l $sqlplus_auth 2>&1 <<EOF
set echo off heading off feedback $feedback;
$cmd;
exit;
EOF
)

  local ans=$?

  [[ $DEBUG && $DEBUG == true ]] && echo "$cmd ==> $v ($ans)"

  if [[ $ans -eq 0 && -z $v ]] ; then
    return 1
  fi

  if [[ -n $rm_ln ]] ; then

    v=`echo $v | sed 's/\n//g'`

  fi

#  declare -x "$var"="$v"
  #read -r "$var" <<< "$v"
  eval "$var=\$v"

  set +f

  return $ans

}


# vim: syn=sh filetype=sh
