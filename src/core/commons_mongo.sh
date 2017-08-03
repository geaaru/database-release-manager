#!/bin/bash
#------------------------------------------------
# Author(s): Geaaru, geaaru@gmail.com
# $Id$
# License: GPL 2.0
#------------------------------------------------

# commons_mongo_commons_mongo_check_client
commons_mongo_check_client () {

  if [ -z "$mongo" ] ; then

    # POST: mongo variable not set
    tmp=`which mongo 2> /dev/null`
    var=$?

    if [ $var -eq 0 ] ; then

      [[ $DEBUG && $DEBUG == true ]] && echo -en "Use mongo: $tmp\n"

      MONGO_CLIENT=$tmp

      unset tmp

    else

      error_generate "mongo program not found"

      return 1

    fi

  else

    # POST: mongo variable already set

    # Check if file is correct
    if [ -f "$mongo" ] ; then

      [[ $DEBUG && $DEBUG == true ]] && echo -en "Use mongo: $mongo\n"

      MONGO_CLIENT=$psq

    else

      error_generate "$mongo program invalid."

      return 1

    fi

  fi

  export MONGO_CLIENT

  return 0

}
# commons_mongo_commons_mongo_check_client_end

# commons_mongo_commons_mongo_check_vars
commons_mongo_check_vars () {

  local commons_msg='variable on configuration file, through arguments or on current profile.'

  check_var "MONGO_USER" || error_handled "You must define MONGO_USER $commons_msg"
  check_var "MONGO_PWD"  || error_handled "You must define MONGO_PWD $commons_msg"
  check_var "MONGO_DB"   || error_handled "You must define MONGO_DB $commons_msg"
  check_var "MONGO_DIR"  || error_handled "You must define MONGO_DIR $commons_msg"

  return 0
}
# commons_mongo_commons_mongo_check_vars_end

# commons_mongo_commons_mongo_check_connection
commons_mongo_check_connection () {

  local opts="--quiet"

  if [ -z "$MONGO_CLIENT" ] ; then
    return 1
  fi

  if [ -z "$mongo_auth" ] ; then
    return 1
  fi

  [[ $DEBUG && $DEBUG == true ]] && \
    echo -en "(commons_mongo_check_connection) Try connection with $MONGO_CLIENT $mongo_auth $MONGO_EXTRA_OPTIONS $opts.\n"

  eval $MONGO_CLIENT $mongo_auth $MONGO_EXTRA_OPTIONS $opts $2>&1 <<EOF
exit
EOF

  errorCode=$?
  if [ ${errorCode} -ne 0 ] ; then
    return 1
  fi

  unset errorCode

  [[ $DEBUG && $DEBUG == true ]] && echo "mongo was connected successfully"

  return 0
}
# commons_mongo_commons_mongo_check_connection_end

# commons_mongo_commons_mongo_shell
commons_mongo_shell () {

  local opts=""
  local errorCode=""

  if [ -z "$MONGO_CLIENT" ] ; then
    return 1
  fi

  if [ -z "$mongo_auth" ] ; then
    return 1
  fi

  [[ $DEBUG && $DEBUG == true ]] && \
    echo -en "(commons_mongo_shell) Try connection with $opts $MONGO_EXTRA_OPTIONS $mongo_auth.\n"

  eval $MONGO_CLIENT $opts $MONGO_EXTRA_OPTIONS $mongo_auth

  errorCode=$?
  if [ ${errorCode} -ne 0 ] ; then
    return 1
  fi

  unset errorCode

  return 0
}
# commons_mongo_commons_mongo_shell_end

# commons_mongo_commons_mongo_compile_file
commons_mongo_compile_file () {

  local f=$1
  local msg=$2
  local use_initrc=${3:-1}
  local f_base=$(basename "$f")

  if [ ! -e $f ] ; then
    _logfile_write "(mongo) File $f not found." || return 1
    return 1
  fi

  _logfile_write "(mongo) Start compilation (file $f_base): $msg" || return 1

  echo "(mongo) Start compilation (file $f_base): $msg"

  MONGO_OUTPUT=""

  if [ $use_initrc -eq 0 ] ; then
    mongo_file "MONGO_OUTPUT" "$f"
  else
    mongo_file_initrc "MONGO_OUTPUT" "$f" "${MONGO_INITRC}"
  fi
  local ans=$?

  _logfile_write "\n$MONGO_OUTPUT" || return 1

  _logfile_write "(mongo) End compilation (file $f_base, result => $ans): $msg" || return 1

  echo -en "(mongo) End compilation (file $f_base, result => $ans): $msg\n"

  return $ans
}
# commons_mongo_commons_mongo_compile_file_end

# vim: syn=sh filetype=sh

