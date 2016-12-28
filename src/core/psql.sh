#!/bin/bash
#------------------------------------------------
# Author(s): Geaaru, geaaru@gmail.com
# $Id$
# License: GPL 2.0
#------------------------------------------------

#****f* psql/psql_set_auth_var
# FUNCTION
#   Set psql_auth variable with
#   authentication string like: -u username --password=pwd database.
# INPUTS
#   db        Name of the schema to use.
#   user      User to use on authentication.
#   pwd       Password to use on authentication
#   host      Optionally host of the database server.
#   schema    Optionally schema of the database server.
# DESCRIPTION
#   Set psql_auth variable with arguments to use with psql client program.
# RETURN VALUE
#   0 always.
# SOURCE
psql_set_auth_var () {

  local db=$1
  local user=$2
  local pwd=$3
  local host=$4
  local schema=$5
  local v_host=""
  local v_schema=""

  if [ ! -z "$host" ] ; then
    v_host="-h $host"
  fi

  if [ ! -z "$schema" ] ; then
    v_schema="-v schema=${schema}"
  fi

  export PGPASSWORD="$pwd"
  # TODO: handle ~/.pgpass file

  psql_auth="$v_host $v_schema -U $user -w $db"

  [[ $DEBUG && $DEBUG == true ]] && echo "Use '$psql_auth'"

  return 0
}
#****


#****f* psql/psql_cmd_4var
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
#   * POSTGRESQL_IGNORE_TMZ: this variable is used as an alternative to set third parameter
#                         of the function and avoid set of timezone on session.
#   * POSTGRESQL_TMZ: timezone to use on session. Default is UTC.
#   * POSTGRESQL_SHOW_COLUMNS: if this variable is set then columns are visibile on output
#                              table. Default is hide columns.
#   * POSTGRESQL_CLIENT: Path of psql client.
#   * POSTGRESQL_FORMAT: Customize format options. Default is unaligned.
#   * POSTGRESQL_EXTRA_OPTIONS: Extra options for psql client.
# RETURN VALUE
#   0 on success
#   1 on error
# SOURCE
psql_cmd_4var () {

  set -f
  local var=$1
  local cmd="$2"
  local rm_lf=$3
  local avoid_tmz=$4
  local v=""
  local opts=""
  # Set separator
  opts="${opts} -P fieldsep='|'"
  # Disable footer
  opts="${opts} -P footer=off"
  # Tuple only
  opts="${opts} -t" # equals to -P tuples_only=true
  # Quiet mode
  # opts="${opts} -q"


  local tz="
\o /dev/null
SET timezone = '$POSTGRESQL_TMZ';
\o
"
  if [[ -n "$avoid_tmz" && x"$avoid_tmz" == x"1" ]] ; then
    tz=""
  fi
  if [[ ! -z "$POSTGRESQL_IGNORE_TMZ" && $POSTGRESQL_IGNORE_TMZ -eq 1 ]] ; then
    tz=""
  fi

  if [ -z "$POSTGRESQL_SHOW_COLUMNS" ] ; then
    # Disable columns as default
    opts="${opts} -P columns=off"
  fi

  if [ -z "${POSTGRESQL_FORMAT}" ] ; then
    # Format unaligned
    opts="${opts} -P format=unaligned"
  fi

  [[ $DEBUG && $DEBUG == true ]] && echo -en "Connection options: $POSTGRESQL_CLIENT $opts $POSTGRESQL_EXTRA_OPTIONS $psql_auth\n"

  v=$($POSTGRESQL_CLIENT $opts $POSTGRESQL_EXTRA_OPTIONS $psql_auth 2>&1 <<EOF
$tz
$cmd;
\q
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
