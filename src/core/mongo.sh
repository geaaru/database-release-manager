#!/bin/bash
#------------------------------------------------
# Author(s): Geaaru, geaaru@gmail.com
# $Id$
# License: GPL 2.0
#------------------------------------------------

# mongo_mongo_set_auth_var
mongo_set_auth_var () {

  local db=$1
  local user=$2
  local pwd=$3
  local host=$4
  local auth_db=$5

  # TODO: check if use --host and --port instead of host:port/db


  if [ -n "${auth_db}" ] ; then
    mongo_auth="${mongo_auth} --authenticationDatabase ${auth_db}"
  fi

  # TODO: Check of pass username and password with single quote
  mongo_auth="${host}/${db} --username=$user --password=${pwd} ${mongo_auth}"

  [[ $DEBUG && $DEBUG == true ]] && echo "Use ${mongo_auth}"

  return 0
}
# mongo_mongo_set_auth_var_end

# mongo_mongo_file
mongo_file () {

  local var=$1
  local f=$2
  local opts=""
  local result=""

  if [ -z "$MONGO_CLIENT" ] ; then
    return 1
  fi

  if [ -z "$mongo_auth" ] ; then
    return 1
  fi

  [[ $DEBUG && $DEBUG == true ]] && \
    echo -en "(mongo_file) Try compile file $f with options $opts $MONGO_EXTRA_OPTIONS $mongo_auth.\n"

  v=$(eval $MONGO_CLIENT $opts $MONGO_EXTRA_OPTIONS $mongo_auth $f 2>&1)
  result=$?

  [[ $DEBUG && $DEBUG == true ]] && \
    echo -en "(mongo_file) Compile $f => $v ($result).\n"

  eval "$var=\$v"

  return $result
}
# mongo_mongo_file_end

# mongo_mongo_file_initrc
mongo_file_initrc () {

  local var=$1
  local f=$2
  local initrc=$3
  local opts=""
  local result=""
  local init_commands=""
  local commands=""

  if [ -z "$MONGO_CLIENT" ] ; then
    return 1
  fi

  if [ -z "$mongo_auth" ] ; then
    return 1
  fi

  if [ -n "$initrc" ] ; then
    init_commands="$(cat $initrc)"
  fi

  commands="$(cat $f)"

  [[ $DEBUG && $DEBUG == true ]] && \
    echo -en "(mongo_file) Try compile file $f with options $opts $MONGO_EXTRA_OPTIONS $mongo_auth.\n"

  v=$($MONGO_CLIENT $opts $MONGO_EXTRA_OPTIONS $mongo_auth 2>&1 <<EOF
$init_commands
$commands
EOF
)
  result=$?

  [[ $DEBUG && $DEBUG == true ]] && \
    echo -en "(mongo_file) Compile $f => $v ($result).\n"

  eval "$var=\$v"

  return $result
}
# mongo_mongo_file_initrc_end

# vim: syn=sh filetype=sh
