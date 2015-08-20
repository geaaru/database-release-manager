#!/bin/bash
#------------------------------------------------
# Author(s): Geaaru, geaaru@gmail.com
# $Id$
# License: GPL 2.0
#------------------------------------------------

#****f* mysql/mysql_set_auth_var
# FUNCTION
#   Set mysql_auth variable with
#   authentication string like: -u username --password=pwd database.
# INPUTS
#   db        Name of the schema to use.
#   user      User to use on authentication.
#   pwd       Password to use on authentication
#   host      Optionally host of the database server.
# DESCRIPTION
#   Set mysql_auth variable with arguments to use with mysql client program.
# RETURN VALUE
#   0 always.
# SOURCE
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
#****

#****f* mysql/mysql_file
# FUNCTION
#   Compile a file and save output to input variable
# INPUTS
#   $1      Name of the variable where is save output command.
#   $2      File to compile.
#   $3      Flag to avoid set of timezone on session (1 to avoid, 0 to leave default).
#           (Optional)
# DESCRIPTION
#   Inside function are used these external variables:
#   * MARIADB_IGNORE_TMZ: this variable is used as an alternative to set third parameter
#                         of the function and avoid set of timezone on session.
#   * MARIADB_TMZ: timezone to use on session. Default is UTC.
#   * MARIADB_SHOW_COLUMNS: if this variable is set remove '-N' option from mysql client
#                           command to print column data.
#   * MARIADB_CLIENT: Path of mysql client.
#   * MARIADB_EXTRA_OPTIONS: Extra options for mysql client.
#   * MARIADB_DB: name of the schema to use.
#   * MARIADB_ENABLE_COMMENTS: With value 0 (disable) or 1 (enable) insert of comments
#                              in compilation. Default is 0.
#   NOTE: This command try to replace string `DB_NAME` with name of the schema
#         defined on MARIADB_DB variable.
# RETURN VALUE
#   0 on success
#   1 on error
# SOURCE
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
#****

#****f* mysql/mysql_source_file
# FUNCTION
#   Compile a file and save output to input variable.
#   This command is an alternative to mysql_file function that use source command.
# INPUTS
#   $1      Name of the variable where is save output command.
#   $2      File to compile.
#   $3      Flag to avoid set of timezone on session (1 to avoid, 0 to leave default).
#           (Optional)
# DESCRIPTION
#   Inside function are used these external variables:
#   * MARIADB_IGNORE_TMZ: this variable is used as an alternative to set third parameter
#                         of the function and avoid set of timezone on session.
#   * MARIADB_TMZ: timezone to use on session. Default is UTC.
#   * MARIADB_SHOW_COLUMNS: if this variable is set remove '-N' option from mysql client
#                           command to print column data.
#   * MARIADB_CLIENT: Path of mysql client.
#   * MARIADB_EXTRA_OPTIONS: Extra options for mysql client.
#   * MARIADB_ENABLE_COMMENTS: With value 0 (disable) or 1 (enable) insert of comments
#                              in compilation. Default is 0.
# RETURN VALUE
#   0 on success
#   1 on error
# SOURCE
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
  local sql="$(cat $f)"


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
#****

#****f* mysql/mysql_cmd_4var
# FUNCTION
#   Execute an input statement on configured schema.
# INPUTS
#   var       Name of the variable where is save output command.
#   cmd       Command to execute.
#   rm_lf     If string length is not zero than from output command are remove LF.
#   avoid_tmz Flag to avoid set of timezone on session (1 to avoid, 0 to leave default).
#             (Optional)
# DESCRIPTION
#   Inside function are used these external variables:
#   * MARIADB_IGNORE_TMZ: this variable is used as an alternative to set third parameter
#                         of the function and avoid set of timezone on session.
#   * MARIADB_TMZ: timezone to use on session. Default is UTC.
#   * MARIADB_SHOW_COLUMNS: if this variable is set remove '-N' option from mysql client
#                           command to print column data.
#   * MARIADB_CLIENT: Path of mysql client.
#   * MARIADB_EXTRA_OPTIONS: Extra options for mysql client.
#   * MARIADB_ENABLE_COMMENTS: With value 0 (disable) or 1 (enable) insert of comments
#                              in compilation. Default is 0.
# RETURN VALUE
#   0 on success
#   1 on error
# SOURCE
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
#****

# vim: syn=sh filetype=sh
