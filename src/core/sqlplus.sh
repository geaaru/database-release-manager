#!/bin/bash
#------------------------------------------------
# Author(s): Geaaru, geaaru@gmail.com
# $Id$
# License: GPL 2.0
#------------------------------------------------

# sqlplus_set_sqlplus_auth_var
sqlplus_set_sqlplus_auth_var () {

  local db=$1
  local user=$2
  local pwd=$3
  local role=$4

  if [ -n "$role" ] ; then
    export sqlplus_auth="$user/$pwd@$db as $role"
  else
    export sqlplus_auth="$user/$pwd@$db"
  fi

  [[ $DEBUG && $DEBUG == true ]] && echo "Use $sqlplus_auth"

  return 0
}
# sqlplus_set_sqlplus_auth_var_end

# sqlplus_sqlplus_file
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

  [[ $DEBUG && $DEBUG == true ]] && echo -en "Compile $f ==> $v ($ans)\n"

  #v=`echo $v | sed 's/\n/\r/g'`
  eval "$var=\$v"
  #read -r "$var" <<< "$v"

  return $ans
}
# sqlplus_sqlplus_file_end

# sqlplus_sqlplus_cmd_4var
sqlplus_cmd_4var() {

  set -f
  local var=$1
  local cmd="$2"
  local rm_lf=$3
  local v=""
  local feedback="$4"
  local custom_opts="$5"
  local empty_res_valid="${6:-0}"
  local as_array="$7"
  local opts=""

  if [[ -n "${custom_opts}" ]] ; then

    opts="${custom_opts}; "

  else

    if [[ $feedback == '' ]] ; then
      feedback="off"
    fi

    opts="set echo off heading off feedback $feedback;"
  fi

  [[ $DEBUG && $DEBUG == true ]] && echo "(sqlplus: opts = $opts)"

  v=$($SQLPLUS -S -l $sqlplus_auth 2>&1 <<EOF
$opts
$cmd;
exit;
EOF
)

  local ans=$?

  [[ $DEBUG && $DEBUG == true ]] && echo "$cmd ==> $v ($ans)"

  if [[ $ans -eq 0 && -z $v && $empty_res_valid = "0" ]] ; then
    return 1
  fi

  if [[ -n $rm_lf ]] ; then
    v=`echo $v | sed 's/\n//g'`
  fi

#  declare -x "$var"="$v"
  #read -r "$var" <<< "$v"
  if [ -n "${as_array}" ] ; then
    eval "$var=( \$v )"
  else
    eval "$var=\$v"
  fi

  set +f

  return $ans

}
# sqlplus_sqlplus_cmd_4var_end

# vim: syn=sh filetype=sh
