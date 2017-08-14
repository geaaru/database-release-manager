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

# commons_mongo_commons_mongo_get_indexes_list
commons_mongo_get_indexes_list () {

  local single_collection="$1"
  local pos=0
  local cmd=""

  if [ -z "${single_collection}" ] ; then
    cmd="
db.getCollectionNames().forEach(function(n){
  print( JSON.stringify(db[n].getIndexSpecs()));
})"

  else

    cmd="JSON.stringify(db['${single_collection}'].getIndexSpecs());"

  fi

  mongo_cmd_4var "_mongo_ans" "$cmd" || return 1

  # Create array as result with an array for every entry
  # with column:
  # - collection
  # - key name
  # - keys
  # - n_keys
  # - keys_complete

  declare -g -A mongo_indexes

  # Reset array and declare it
  mongo_indexes=()

  IFS=$'\n'
  for row in $_mongo_ans ; do

    local n_indexes=$(echo $row | jq 'length')
    local i=0

    for ((i=0; i<${n_indexes};i++)) ; do

      local kname=$(echo $row | jq -r -M .[$i].name )
      local kcoll=$(echo $row | jq -r -M .[$i].ns | cut -d'.' -f 2)
      local n_keys=$(echo $row | jq ".[$i].key | keys | length")
      local keys=($(echo $row | jq -r -M ".[$i].key | keys | .[]"))
      keys=$(echo ${keys[@]} | tr " " \,)

      local keys_complete=$(echo $row | jq -r -M -c ".[$i].key")

      [[ $DEBUG && $DEBUG == true ]] && echo -en \
        "(commons_mongo_get_indexes_list) kname = $kname, kcoll =$kcoll, n_keys=$n_keys, keys=$keys_complete.\n"

      mongo_indexes[$pos, 0]=${kcoll}
      mongo_indexes[$pos, 1]=${kname}
      mongo_indexes[$pos, 2]=${keys}
      mongo_indexes[$pos, 3]=${n_keys}
      mongo_indexes[$pos, 4]=${keys_complete}

      let pos++

    done

  done
  unset IFS

  [[ $DEBUG && $DEBUG == true ]] && echo -en \
    "(commons_mongo_get_indexes_list) Found ${#mongo_indexes[@]} ($pos) indexes.\n"

  return 0
}
# commons_mongo_commons_mongo_get_indexes_list_end

# vim: syn=sh filetype=sh

