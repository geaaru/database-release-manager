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



# vim: syn=sh filetype=sh
