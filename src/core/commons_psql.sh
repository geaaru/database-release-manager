#!/bin/bash
#------------------------------------------------
# Author(s): Geaaru, geaaru@gmail.com
# $Id$
# License: GPL 2.0
#------------------------------------------------


#****f* commons_psql/commons_psql_check_client
# FUNCTION
#   Check if psql client program is present on system.
#   If present POSTGRESQL_CLIENT variable with abs path is set.
# DESCRIPTION
#   Function check if it is set "psql" variable:
#   * if it is not set then try to find path through 'which' program
#   * if it is set then check if path is correct and program exists.
# RETURN VALUE
#   0 on success
#   1 on error
# SOURCE
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

      POSTGRESQL_CLIENT=$psql

    else

      error_generate "$psql program invalid."

      return 1

    fi

  fi

  export POSTGRESQL_CLIENT

  return 0

}
#****

#****f* commons_psql/commons_psql_check_vars
# FUNCTION
#   Check if are present mandatary psql environment variables.
# RETURN VALUE
#   0 all mandatary variables are present.
#   1 on error
# SOURCE
commons_psql_check_vars () {

  local commons_msg='variable on configuration file, through arguments or on current profile.'

  check_var "POSTGRESQL_USER" || error_handled "You must define POSTGRESQL_USER $commons_msg"
  check_var "POSTGRESQL_PWD"  || error_handled "You must define POSTGRESQL_PWD $commons_msg"
  check_var "POSTGRESQL_DB"   || error_handled "You must define POSTGRESQL_DB $commons_msg"
  check_var "POSTGRESQL_DIR"  || error_handled "You must define POSTGRESQL_DIR $commons_msg"

  return 0
}
#****


#****f* commons_psql/commons_psql_check_connection
# FUNCTION
#   Check connection to database.
# RETURN VALUE
#   0 when connection is ok
#   1 on error
# SOURCE
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
#***

#****f* commons_psql/commons_psql_shell
# FUNCTION
#   Enter on command line shell of Postgresql server.
# RETURN VALUE
#   0 when connection is ok
#   1 on error
# SOURCE
commons_psql_shell () {

  local opts=""

  if [ -z "$POSTGRESQL_CLIENT" ] ; then
    return 1
  fi

  if [ -z "$psql_auth" ] ; then
    return 1
  fi

  # TODO: Enable -A options through a variable option.
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
#***

# vim: syn=sh filetype=sh
