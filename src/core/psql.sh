#!/bin/bash
#------------------------------------------------
# Author(s): Geaaru, geaaru@gmail.com
# $Id$
# License: GPL 2.0
#------------------------------------------------

# psql_set_auth_var
psql_set_auth_var () {

  local db=$1
  local user=$2
  local pwd=$3
  local host=$4
  local schema=$5
  local local=$6
  local v_host=""
  local v_schema=""

  if [ ! -z "$host" ] ; then
    v_host="-h $host"
  fi

  if [ ! -z "$schema" ] ; then
    v_schema="-v schema=${schema}"
  fi

  psql_auth="$v_host $v_schema"

  if [ -n "$user" ] ; then
    psql_auth="${psql_auth} -U $user"
  fi

  if [ -n "${pwd}" ] ; then
    export PGPASSWORD="$pwd"
    # TODO: handle ~/.pgpass file
  fi

  if [ -n "${db}" ] ; then
    psql_auth="${psql_auth} -w $db"
  fi

  [[ $DEBUG && $DEBUG == true ]] && echo "Use '$psql_auth'"

  return 0
}
# psql_set_auth_var_end

psql_file () {

  local var=$1
  local f=$2
  local opts=""
  local result=""

  if [ -z "$POSTGRESQL_CLIENT" ] ; then
    return 1
  fi

  if [ -z "$psql_auth" ] ; then
    return 1
  fi

  [[ $DEBUG && $DEBUG == true ]] && \
    echo -en "(psql_file) Try compile file $f with options $opts $POSTGRESQL_EXTRA_OPTIONS $psql_auth.\n"

  v=$(eval $POSTGRESQL_CLIENT $opts $POSTGRESQL_EXTRA_OPTIONS $psql_auth -f $f 2>&1)
  result=$?

  [[ $DEBUG && $DEBUG == true ]] && \
    echo -en "(psql_file) Compile $f => $v ($result).\n"

  eval "$var=\$v"

  return $result
}

# TODO: We could use row_to_json with jq for process data.
# psql_psql_cmd_4var
psql_cmd_4var () {

  set -f
  local var=$1
  local cmd="$2"
  local rm_lf=$3
  local avoid_tmz=$4
  local v=""
  local opts=""
  # Set separator
  opts="${opts} -P fieldsep=|"
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
# psql_psql_cmd_4var_end

# vim: syn=sh filetype=sh
