#!/bin/bash
#------------------------------------------------
# Author(s): Geaaru, geaaru@gmail.com
# $Id$
# License: GPL 2.0
#------------------------------------------------

# Set mysql_auth variable with
# authentication string like: -u username --password=pwd database
mysql_set_auth_var () {

  local db=$1
  local user=$2
  local pwd=$3
  local host=$4
  local v_host=""

  if [ ! -z "$host" ] ; then
    v_host="--host $host"
  fi

  export mysql_auth="$v_host -u $user --password=$pwd $db"

  [[ $DEBUG && $DEBUG == true ]] && echo "Use '$mysql_auth'"

  return 0
}

# Compile a file
# and save output to input variable
# $1 => Variable name where is save output
# $2 => File to compile
#
# return 0 on success
# return 1 on error
mysql_file () {

  local var=$1
  local f=$2
  local avoid_tmz=$3
  local v=""
  local opts="-N"

  local tz="SET time_zone = '$MARIADB_TMZ';"
  if [[ ! -z "$avoid_tmz" && x"$avoid_tmz" == x"1" ]] ; then
    tz=""
  fi
  if [[ ! -z "$MARIADB_IGNORE_TMZ" && $MARIADB_IGNORE_TMZ -eq 1 ]] ; then
    tz=""
  fi
  local sql="$(cat $f | sed -e 's:`DB_NAME`:`'$MARIADB_DB'`:g' )"

  [[ $DEBUG && $DEBUG == true ]] && echo -en "Execute sql:\n$sql\n"


  if [ -n "$MARIADB_SHOW_COLUMNS" ] ; then
    opts=""
  fi

  v=$($MARIADB_CLIENT -A $opts $MARIADB_EXTRA_OPTIONS $mysql_auth 2>&1 <<EOF
$tz
$sql;
EOF
)

  local ans=$?

  [[ $DEBUG && $DEBUG == true ]] && echo -en "Compile $f ==> $v ($ans)\n"

  eval "$var=\$v"
  #read -r "$var" <<< "$v"

  return $ans

}


# Compile a file
# and save output to input variable
# $1 => Variable name where is save output
# $2 => File to compile
#
# return 0 on success
# return 1 on error
mysql_source_file () {

  local var=$1
  local f=$2
  local avoid_tmz=$3
  local v=""
  local opts="-N"

  local tz="SET time_zone = '$MARIADB_TMZ';"
  if [[ ! -z "$avoid_tmz" && x"$avoid_tmz" == x"1" ]] ; then
    tz=""
  fi
  local sql="$(cat $f)"

  [[ $DEBUG && $DEBUG == true ]] && echo -en "Execute sql:\n$sql\n"


  if [ -n "$MARIADB_SHOW_COLUMNS" ] ; then
    opts=""
  fi

  v=$($MARIADB_CLIENT -A $opts $MARIADB_EXTRA_OPTIONS $mysql_auth 2>&1 <<EOF
$tz
source $f;
EOF
)

  local ans=$?

  [[ $DEBUG && $DEBUG == true ]] && echo -en "Compile $f ==> $v ($ans)\n"

  eval "$var=\$v"
  #read -r "$var" <<< "$v"

  return $ans

}


mysql_cmd_4var () {

  set -f
  local var=$1
  local cmd="$2"
  local rm_ln=$3
  local avoid_tmz=$4
  local v=""
  local opts="-N"

  local tz="SET time_zone = '$MARIADB_TMZ';"
  if [[ -n "$avoid_tmz" && x"$avoid_tmz" == x"1" ]] ; then
    tz=""
  fi

  if [ -n "$MARIADB_SHOW_COLUMNS" ] ; then
    opts=""
  fi

  [[ $DEBUG && $DEBUG == true ]] && echo -en "Connection options: $MARIADB_CLIENT -A $opts $MARIADB_EXTRA_OPTIONS $mysql_auth\n"

  v=$($MARIADB_CLIENT -A $opts $MARIADB_EXTRA_OPTIONS $mysql_auth 2>&1 <<EOF
$tz
$cmd;
EOF
)

  local ans=$?

  [[ $DEBUG && $DEBUG == true ]] && echo -en "$cmd ==> $v ($ans)\n"

  if [[ $ans -eq 0 && -n "$v" ]] ; then

    if [[ -n $rm_ln ]] ; then

      v=`echo $v | sed 's/\n//g'`

    fi

  fi

#  declare -x "$var"="$v"
  #read -r "$var" <<< "$v"
  eval "$var=\$v"

  set +f

  return $ans
}


# vim: syn=sh filetype=sh
