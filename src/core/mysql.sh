#!/bin/bash
#------------------------------------------------
# Author(s): Geaaru, geaaru@gmail.com
# $Id$
# License: GPL 2.0
#------------------------------------------------

# mysql_mysql_set_auth_var
mysql_set_auth_var () {

  local db=$1
  local user=$2
  local pwd=$3
  local host=$4
  local v_host=""

  if [ ! -z "$host" ] ; then
    v_host="--host $host"
  fi

  if [ -n "MYSQL5_6_ENV_PWD" ] ; then

    export MYSQL_PWD="$pwd"
    mysql_auth="$v_host -u $user $db"

  else

    mysql_auth="$v_host -u $user --password=$pwd $db"

  fi

  [[ $DEBUG && $DEBUG == true ]] && echo "Use '$mysql_auth'"

  return 0
}
# mysql_mysql_set_auth_var_end

# mysql_mysql_file
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

  if [ -n "$MARIADB_SHOW_COLUMNS" ] ; then
    opts=""
  fi

  if [[ -n "$MARIADB_ENABLE_COMMENTS" && x"$MARIADB_ENABLE_COMMENTS" == x"1" ]] ; then
    opts="$opts -c"
  fi

  [[ $DEBUG && $DEBUG == true ]] && \
    echo -en "Execute $MARIADB_CLIENT -A $opts $MARIADB_EXTRA_OPTIONS $mysql_auth for sql command:\n$sql\n"

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
# mysql_mysql_file_end

# mysql_mysql_source_file
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
  if [[ ! -z "$MARIADB_IGNORE_TMZ" && $MARIADB_IGNORE_TMZ -eq 1 ]] ; then
    tz=""
  fi

  if [ -n "$MARIADB_SHOW_COLUMNS" ] ; then
    opts=""
  fi

  if [[ -n "$MARIADB_ENABLE_COMMENTS" && x"$MARIADB_ENABLE_COMMENTS" == x"1" ]] ; then
    opts="$opts -c"
  fi

  [[ $DEBUG && $DEBUG == true ]] && \
    echo -en "Execute $MARIADB_CLIENT -A $opts $MARIADB_EXTRA_OPTIONS $mysql_auth for sql command:\n$sql\n"

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
# mysql_mysql_source_file_end

# mysql_mysql_cmd_4var
mysql_cmd_4var () {

  set -f
  local var=$1
  local cmd="$2"
  local rm_lf=$3
  local avoid_tmz=$4
  local v=""
  local opts="-N"

  local tz="SET time_zone = '$MARIADB_TMZ';"
  if [[ -n "$avoid_tmz" && x"$avoid_tmz" == x"1" ]] ; then
    tz=""
  fi
  if [[ ! -z "$MARIADB_IGNORE_TMZ" && $MARIADB_IGNORE_TMZ -eq 1 ]] ; then
    tz=""
  fi

  if [ -n "$MARIADB_SHOW_COLUMNS" ] ; then
    opts=""
  fi

  if [[ -n "$MARIADB_ENABLE_COMMENTS" && x"$MARIADB_ENABLE_COMMENTS" == x"1" ]] ; then
    opts="$opts -c"
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

    if [[ -n $rm_lf ]] ; then

      v=`echo $v | sed 's/\n//g'`

    fi

  fi

#  declare -x "$var"="$v"
  #read -r "$var" <<< "$v"
  eval "$var=\$v"

  set +f

  return $ans
}
# mysql_mysql_cmd_4var_end

# vim: syn=sh filetype=sh
