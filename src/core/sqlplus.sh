#!/bin/bash
#------------------------------------------------
# Author(s): Geaaru, geaaru@gmail.com
# $Id$
# License: GPL 2.0
#------------------------------------------------

#****f* sqlplus/sqlplus_set_sqlplus_auth_var
# FUNCTION
#   Set sqlplus_auth variable with authentication string like: USER/PASSWD@TNSNAME.
# INPUTS
#   db    Schema to use.
#   user  User to use.
#   pwd   Password to use.
# SOURCE
sqlplus_set_sqlplus_auth_var () {

  local db=$1
  local user=$2
  local pwd=$3

  export sqlplus_auth="$user/$pwd@$db"

  [[ $DEBUG && $DEBUG == true ]] && echo "Use $sqlplus_auth"

}
#****

#****f* sqlplus/sqlplus_file
# FUNCTION
#   Compile a file and save output to input variable.
# INPUTS
#   var     Name of the variable where is saved output.
#   f       File to compile.
# RETURN VALUE
#   0 on success
#   1 on error
# SOURCES
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
#****

#****f* sqlplus/sqlplus_cmd_4var
# FUNCTION
#   Execute an input statement/command to configured schema.
# INPUTS
#   var       Name of the variable where is saved output command.
#   cmd       Command/statement to execute on configured schema.
#   rm_lf     If string length is not zero than from output command are remove LF.
#   feedback  Set feedback option value. If equal to empty string default value is "off".
sqlplus_cmd_4var() {

  set -f
  local var=$1
  local cmd="$2"
  local rm_lf=$3
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

  if [[ -n $rm_lf ]] ; then

    v=`echo $v | sed 's/\n//g'`

  fi

#  declare -x "$var"="$v"
  #read -r "$var" <<< "$v"
  eval "$var=\$v"

  set +f

  return $ans

}
#****


# vim: syn=sh filetype=sh
