#!/bin/bash
#------------------------------------------------
# Author(s): Geaaru, geaaru@gmail.com
# $Id$
# License: GPL 2.0
#------------------------------------------------

# commons_psql_commons_psql_check_client
commons_psql_check_client () {

  if [ -z "$psql" ] ; then

    # POST: psql variable not set
    tmp=`which psql 2> /dev/null`
    var=$?

    if [ $var -eq 0 ] ; then

      [[ $DEBUG && $DEBUG == true ]] && echo -en "Use psql: $tmp\n"

      POSTGRESQL_CLIENT=$tmp

      unset tmp

    else

      error_generate "psql program not found"

      return 1

    fi

  else

    # POST: psql variable already set

    # Check if file is correct
    if [ -f "$psql" ] ; then

      [[ $DEBUG && $DEBUG == true ]] && echo -en "Use psql: $psql\n"

      POSTGRESQL_CLIENT=$psq

    else

      error_generate "$psql program invalid."

      return 1

    fi

  fi

  export POSTGRESQL_CLIENT

  return 0

}
# commons_psql_commons_psql_check_client_end

# commons_psql_commons_psql_check_client_dump
commons_psql_check_client_dump () {

  if [ -z "$pg_dump" ] ; then

    # POST: pg_dump variable not set
    tmp=`which pg_dump 2> /dev/null`
    var=$?

    if [ $var -eq 0 ] ; then

      [[ $DEBUG && $DEBUG == true ]] && echo -en "Use pg_dump: $tmp\n"

      POSTGRESQL_CLIENT_DUMP=$tmp

      unset tmp

    else

      error_generate "pg_dump program not found"

      return 1

    fi

  else

    # POST: pg_dump variable already set

    # Check if file is correct
    if [ -f "$pg_dump" ] ; then

      [[ $DEBUG && $DEBUG == true ]] && echo -en "Use pg_dump: $pg_dump\n"

      POSTGRESQL_CLIENT_DUMP=$pg_dump

    else

      error_generate "$pg_dump program invalid."

      return 1

    fi

  fi

  export POSTGRESQL_CLIENT_DUMP

  return 0

}
# commons_psql_commons_psql_check_client_dump_end

# commons_psql_commons_psql_check_vars
commons_psql_check_vars () {

  local commons_msg='variable on configuration file, through arguments or on current profile.'

  check_var "POSTGRESQL_USER" || error_handled "You must define POSTGRESQL_USER $commons_msg"
  check_var "POSTGRESQL_PWD"  || error_handled "You must define POSTGRESQL_PWD $commons_msg"
  check_var "POSTGRESQL_DB"   || error_handled "You must define POSTGRESQL_DB $commons_msg"
  check_var "POSTGRESQL_DIR"  || error_handled "You must define POSTGRESQL_DIR $commons_msg"

  return 0
}
# commons_psql_commons_psql_check_vars_end

# commons_psql_commons_psql_check_connection
commons_psql_check_connection () {

  if [ -z "$POSTGRESQL_CLIENT" ] ; then
    return 1
  fi

  if [ -z "$psql_auth" ] ; then
    return 1
  fi

  [[ $DEBUG && $DEBUG == true ]] && \
    echo -en "(commons_psql_check_connection) Try connection with $POSTGRESQL_EXTRA_OPTIONS $psql_auth.\n"

  $POSTGRESQL_CLIENT $POSTGRESQL_EXTRA_OPTIONS $psql_auth 2>&1 << EOF
\\q
EOF

  errorCode=$?
  if [ ${errorCode} -ne 0 ] ; then
    return 1
  fi

  unset errorCode

  [[ $DEBUG && $DEBUG == true ]] && echo "psql was connected successfully"

  return 0
}
# commons_psql_commons_psql_check_connection_end

# commons_psql_commons_psql_shell
commons_psql_shell () {

  local opts=""
  local errorCode=""

  if [ -z "$POSTGRESQL_CLIENT" ] ; then
    return 1
  fi

  if [ -z "$psql_auth" ] ; then
    return 1
  fi

  # Disable Pagination
  opts="-P pager=off"

  [[ $DEBUG && $DEBUG == true ]] && \
    echo -en "(commons_psql_shell) Try connection with $opts $POSTGRESQL_EXTRA_OPTIONS $psql_auth.\n"

  $POSTGRESQL_CLIENT $opts $POSTGRESQL_EXTRA_OPTIONS $psql_auth

  errorCode=$?
  if [ ${errorCode} -ne 0 ] ; then
    return 1
  fi

  unset errorCode

  return 0
}
# commons_psql_commons_psql_shell_end

# commons_psql_commons_psql_dump
commons_psql_dump () {

  local opts=""
  local targetfile="$1"
  local onlySchema="${2:-1}"
  local errorCode=""

  if [ -z "$POSTGRESQL_CLIENT_DUMP" ] ; then
    return 1
  fi

  if [ -z "$psql_auth" ] ; then
    return 1
  fi

  if [[ -n "$POSTGRESQL_SCHEMA" && ${onlySchema} -eq 1 ]] ; then
    opts="-n ${POSTGRESQL_SCHEMA}"
  fi

  [[ $DEBUG && $DEBUG == true ]] && \
    echo -en "(commons_psql_dump) Try connection with $opts $POSTGRESQL_EXTRA_OPTIONS $psql_auth.\n"

  $POSTGRESQL_CLIENT_DUMP $opts $POSTGRESQL_EXTRA_OPTIONS $psql_auth > ${targetfile}

  errorCode=$?
  if [ ${errorCode} -ne 0 ] ; then
    return 1
  fi

  unset errorCode

  return 0
}
# commons_psql_commons_psql_dump_end

# vim: syn=sh filetype=sh
