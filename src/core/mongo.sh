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
  mongo_auth="${host}/${db} --username $user --password ${pwd} ${mongo_auth}"

  [[ $DEBUG && $DEBUG == true ]] && echo "Use ${mongo_auth}"

  return 0
}
# mongo_mongo_set_auth_var_end

# vim: syn=sh filetype=sh
