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
  local filter_keyname="$2"
  local ignore_id_=${3:-0}
  local pos=0
  local cmd=""

  [[ $DEBUG && $DEBUG == true ]] && echo -en \
    "(commons_mongo_get_indexes_list) args: collection '${single_collection}', filter = '${filter_keyname}', ignore_id_='${ignore_id_}'\n"

  if [ -z "${single_collection}" ] ; then
    cmd="
db.getCollectionNames().forEach(function(n){
  print( JSON.stringify(db[n].getIndexSpecs()));
})"

  else

    cmd="JSON.stringify(db['${single_collection}'].getIndexSpecs())"

  fi


  # Retrieve stats data for index
  commons_mongo_stats "${single_collection}" "index" || return 1

  mongo_cmd_4var "_mongo_ans" "$cmd" || return 1

  # Create associative array for every entry
  # with column:
  # - collection
  # - key name
  # - keys
  # - n_keys
  # - keys_complete
  # - index size
  # - index options

  unset mongo_indexes
  declare -g -A mongo_indexes

  # Reset array and declare it
  mongo_indexes=()

  IFS=$'\n'
  for row in $_mongo_ans ; do

    local n_indexes=$(echo $row | jq 'length')
    local i=0

    for ((i=0; i<${n_indexes};i++)) ; do

      local kname=$(echo $row | jq -r -M .[$i].name )

      if [[ -n "${filter_keyname}" && "${kname}" != ${filter_keyname} ]] ; then
        continue
      fi

      if [[ ${ignore_id_} -eq 1 && "${kname}" == "_id_" ]] ; then
        continue
      fi

      local kcoll=$(echo $row | jq -r -M .[$i].ns | cut -d'.' -f 2)
      local n_keys=$(echo $row | jq ".[$i].key | keys | length")
      local keys=($(echo $row | jq -r -M ".[$i].key | keys | .[]"))
      keys=$(echo ${keys[@]} | tr " " \,)
      local index_size=${mongo_stats[${kcoll}, ${kname}]}

      local keys_complete=$(echo $row | jq -M -c ".[$i].key")

      local key_options=($(echo $row | jq -r -M ".[$i] | keys | .[]"))
      local opts_json="{"

      local opt=""
      for opt in ${key_options[@]} ; do

        local opt_val=""
        case $opt in
          v|key|ns|name)
            ;;
          *)
            opt_val=$(echo $row | jq -M ".[$i].$opt")

            if [ ${#opts_json} -eq 1 ] ; then
              opts_json="${opts_json} \"${opt}\" : ${opt_val}"
            else
              opts_json="${opts_json}, \"${opt}\" : ${opt_val}"
            fi
            ;;
        esac

      done

      if [ ${#opts_json} -eq 1 ] ; then
        opts_json=""
      else
        opts_json="${opts_json} }"
      fi

      # echo -e $(printf '%q' $opts_json) | jq
      [[ $DEBUG && $DEBUG == true ]] && echo -en \
        "(commons_mongo_get_indexes_list) kname = $kname, kcoll =$kcoll, n_keys=$n_keys, keys=$keys_complete.\n"

      mongo_indexes[$pos, 0]=${kcoll}
      mongo_indexes[$pos, 1]=${kname}
      mongo_indexes[$pos, 2]=${keys}
      mongo_indexes[$pos, 3]=${n_keys}
      mongo_indexes[$pos, 4]=${keys_complete}
      mongo_indexes[$pos, 5]=${index_size:-"N.A"}
      mongo_indexes[$pos, 6]=${opts_json}

      let pos++

    done

  done
  unset IFS

  [[ $DEBUG && $DEBUG == true ]] && echo -en \
    "(commons_mongo_get_indexes_list) Found ${#mongo_indexes[@]} ($pos) indexes.\n"

  return 0
}
# commons_mongo_commons_mongo_get_indexes_list_end

# commons_mongo_commons_mongo_stats
commons_mongo_stats () {

  local scale=1024
  local cmd=""
  local pos=0
  local i=0
  # Contains collection name.
  local single_collection="$1"
  # target values are: collection | index | custom
  local target="$2"
  # Custom content permit to customize filter for
  # jq parser and return JSON to process.
  local custom_content="$3"

  [[ $DEBUG && $DEBUG == true ]] && echo -en \
    "(commons_mongo_mongo_stats) args: $@.\n"

  if [ -z "${single_collection}" ] ; then
    cmd="
db.getCollectionNames().forEach(function(n) {
  print( JSON.stringify(db[n].stats({scale: ${scale}})) );
})"
  else
    cmd="JSON.stringify(db['${single_collection}'].stats({scale: ${scale}}))"
  fi

  mongo_cmd_4var "_mongo_stats" "$cmd" || return 1

  unset mongo_stats
  declare -g -A mongo_stats
  mongo_stats=()

  IFS=$'\n'
  for row in $_mongo_stats ; do

    local row_coll=$(echo $row | jq -r -M .ns | cut -d'.' -f 2)

    case "${target}" in
      collection)

        # Create associative array with columns (number index):
        # - collection
        # - storageSize
        # - sharded
        # - primary
        # - count
        # - nindexes
        # - totalIndexSize
        # - capped
        # - average object size
        # - size
        # - sharded nodes
        local storageSize=""
        local sharded=""
        local primary=""
        local count=""
        local nindexes=""
        local totalIndexSize=""
        local capped=""
        local avgObjSize=""
        local size=""
        local shardedNodes=""

        storageSize=$(echo $row | jq -r -M .storageSize)
        sharded=$(echo $row | jq -r -M .sharded)

        count=$(echo $row | jq -r -M .count)
        nindexes=$(echo $row | jq -r -M .nindexes)
        totalIndexSize=$(echo $row | jq -r -M .totalIndexSize)
        capped=$(echo $row | jq -r -M .capped)
        avgObjSize=$(echo $row | jq -r -M .avgObjSize)
        size=$(echo $row | jq -r -M .size)

        mongo_stats[$pos, 0]=${row_coll}
        mongo_stats[$pos, 1]=${storageSize}

        if [ "${sharded}" = "false" ] ; then
          mongo_stats[$pos, 2]=0
          primary=$(echo $row | jq -r -M .primary)
          shardedNodes="-"
        else
          mongo_stats[$pos, 2]=1
          primary="-"
          shardedNodes=($(echo $row | jq -r -M ".shards | keys | .[]"))
          shardedNodes=$(echo ${shardedNodes[@]} | tr " " \,)
        fi
        mongo_stats[$pos, 3]=${primary}
        mongo_stats[$pos, 4]=${count}
        mongo_stats[$pos, 5]=${nindexes}
        mongo_stats[$pos, 6]=${totalIndexSize}
        if [ "${capped}" = "false" ] ; then
          mongo_stats[$pos, 7]=0
        else
          mongo_stats[$pos, 7]=1
        fi
        mongo_stats[$pos, 8]=${avgObjSize}
        mongo_stats[$pos, 9]=${size}
        mongo_stats[$pos, 10]=${shardedNodes}
        ;;

      index)

        # Create associative array with columns (key is collection, index name):
        # - index size
        local indexSize=""
        local nkeys=$(echo $row | jq -r -M ".indexSizes | length")

        if [ ${nkeys} -gt 0 ] ; then

          local keys=($(echo $row | jq -r -M ".indexSizes | keys | .[]"))

          for key in ${keys[@]} ; do

            indexSizes=$(echo $row | jq -r -M ".indexSizes.${key}")
            mongo_stats[${row_coll}, ${key}]=${indexSizes}

          done # end for key

        fi

        ;;

      custom)
        # Create associative array with columns for collection (number index):
        # - collection
        # - custom json
        local custom_json=$(echo $row | jq -M "${custom_content}")

        mongo_stats[$pos, 0]=${row_coll}
        mongo_stats[$pos, 1]=${custom_json}

        ;;
    esac

    let pos++

  done # end for
  unset IFS

  [[ $DEBUG && $DEBUG == true ]] && echo -en \
    "(commons_mongo_stats) Found ${#mongo_stats[@]} ($pos) data.\n"

  return 0
}
# commons_mongo_commons_mongo_stats_end

# commons_mongo_commons_mongo_create_index_file
commons_mongo_create_index_file () {

  local coll="$1"
  local name="$2"
  local keys="$3"
  local opts="$4"

  local indexesdir="${MONGO_DIR}/indexes"
  local f="${indexesdir}/${coll}.${name}.js"

  [[ $DEBUG && $DEBUG == true ]] && echo -en \
    "(commons_mongo_create_index_file): coll='${coll}' name='${name}' keys='${keys}' opts='${opts}, f=${f}'.\n"


  # Check if exists indexes or create it
  if [[ ! -d ${indexesdir} ]] ; then
    mkdir -p ${indexesdir} || error_generate "Error on create directory ${indexesdir}."
  fi

  # TODO: check if key is already present on database
  #       also with a different name.
  # TODO: add header to index file as comment (through MONGO_HEADER variable)

  [ -z "${opts}" ] && opts="{}"

  opts=$(echo -e $(printf '%s' $opts) | jq --arg name $name '. + { name: $name}')

  #echo -e '{ }' | jq --arg name prova '. + { name: $name}'
  content="
db.${coll}.createIndex(${keys} ,
${opts} );

"

  [[ $DEBUG && $DEBUG == true ]] && echo -en \
    "(commons_mongo_create_index_file) content =\n$content\n"

  echo -en "$content" > $f || error_generate "Error on write file $f."

  _logfile_write "(mongo) Created index ${name} for collection ${coll} (file ${f})" || \
    return 1

  return 0

}
# commons_mongo_commons_mongo_create_index_file_end

# commons_mongo_commons_mongo_download_index
commons_mongo_download_index () {

  local coll="$1"
  local kname="$2"
  # optional: set with position of mongo_indexes array if already
  #           initialized.
  local arr_pos=$3
  local keys=""
  local opts=""

  [[ $DEBUG && $DEBUG == true ]] && echo -en \
    "(commons_mongo_download_index): coll='${coll}' kname='${kname}' pos=${arr_pos}.\n"

  if [ -z "${arr_pos}" ] ; then

    commons_mongo_get_indexes_list "${coll}" "${kname}" || \
      error_generate "Error retrieve index data"

    [ ${#mongo_indexes[@]} -eq 0 ] && \
      error_generate "No index ${kname} for collection ${coll} found."

    arr_pos=0

  fi

  keys=${mongo_indexes[$arr_pos, 4]}
  opts=${mongo_indexes[$arr_pos, 6]}

  [[ $DEBUG && $DEBUG == true ]] && \
    echo -en "(commons_mongo_download_index): Found keys='${keys}', opts='${opts}'.\n"

  commons_mongo_create_index_file "${coll}" "${kname}" "${keys}" "${opts}" || \
    error_generate "Error on create index file."

  return 0
}
# commons_mongo_commons_mongo_download_index_end

# commons_mongo_commons_mongo_download_all_indexes
commons_mongo_download_all_indexes () {

  local i=0
  local n_indexes=0
  local collection="$1"
  local include_id_=${2:-0}
  local counter=0
  local kcoll=""
  local kname=""

  commons_mongo_get_indexes_list "${collection}" "" || \
    error_handled "Error on retrieve indexes list."

  n_indexes=${#mongo_indexes[@]}

  [[ $DEBUG && $DEBUG == true ]] && \
    echo -en "(commons_mongo_download_all_indexes): Found ${n_indexes} indexes.\n"

  if [ ${n_indexes} -gt 0 ] ; then

    n_indexes=$((n_indexes/7))

    for ((i=0; i<${n_indexes}; i++)) ; do

      kcoll=${mongo_indexes[$i, 0]}
      kname=${mongo_indexes[$i, 1]}

      local idx=$((i+1))

      # TODO: show if use out_handler_print instead of echo

      if [[ ${include_id_} -gt 0 && "${kname}" == "_id_" ]] ; then
        echo -en "Ignored index ${kname} of collection ${kcoll} ($idx of ${n_indexes}).\n"
        continue
      fi

      commons_mongo_download_index "${kcoll}" "${kname}" $i

      if [ $? -ne 0 ] ; then
        echo -en \
          "Error on download index data for collection ${kcoll} and index ${kname} ($idx of ${n_indexes}).\n"
      else
        echo -en "Downloaded index ${kname} of collection ${kcoll} ($idx of ${n_indexes}).\n"
      fi

    done # end for i

  else

    out_handler_print "No indexes found."

  fi

  return 0
}
# commons_mongo_commons_mongo_download_all_indexes_end

# commons_mongo_commons_mongo_drop_index
commons_mongo_drop_index () {

  local cmd=""
  local coll="$1"
  local kname="$2"
  local msgprefix=""
  local out=""
  local ok=""
  local errmsg=""
  local ans=""

  if [ -n "${kname}" ] ; then
    msgprefix="drop index: ${kname} "
  else
    msgprefix="drop all indexes: "
  fi

  _logfile_write "(mongo) Start ${msgprefix}(collection ${coll})" || return 1

  [[ $DEBUG && $DEBUG == true ]] && echo -en \
    "(commons_mongo_drop_index: Dropping index kname='${kname}', coll='${coll}'\n"

  if [ -n "${kname}" ] ; then
    cmd="db.${coll}.dropIndex('${kname}')"
  else
    cmd="db.${coll}.dropIndexes()"
  fi

  mongo_cmd_4var "_mongo_drop" "$cmd"
  ans=$?

  out=$(echo "$_mongo_drop" | sed -e 's/.lastOpTime.*//g' -e 's/.electionId.*//g')

  [[ $DEBUG && $DEBUG == true ]] && echo -en \
    "(commons_mongo_drop_index: (out)\n${out}\n"

  ok=$(echo "${out}" | jq .ok)

  if [ "${ok}" = "1" ] ; then
    _logfile_write "OK ($ans)" || return 1
    ans=0
  else

    errmsg=$(echo ${out} | jq .errmsg)
    _logfile_write "KO ($ans) - ${errmsg}" || return 1
    ans=1

    out_handler_print "Error on ${msgprefix} for collection ${coll}: ${errmsg}"

  fi

  _logfile_write "(mongo) End ${msgprefix}(collection ${coll})" || return 1

  return $ans
}
# commons_mongo_commons_mongo_drop_index_end

# commons_mongo_commons_mongo_compile_idx
commons_mongo_compile_idx () {

  local f=$1
  local msg=$2
  # TODO: force option 3 support
  local force="$3"
  local f_base=$(basename "$f")
  local idx_dir=$(dirname "$f")
  local idx_str="${f_base/.js/}"
  local coll=$(echo ${idx_str} | cut -d'.' -f1)
  local kname=$(echo ${idx_str} | cut -d'.' -f2)

  [[ $DEBUG && $DEBUG == true ]] && echo -en \
    "(commons_mongo_compile_idx): coll='${coll}' kname='${kname}' f=${f}.\n"

  [ -z "${f}" ] && error_generate "(commons_mongo_compile_idx) Invalid argument"

  if [ ! -e "${f}" ] ; then
    local log="File $f not found."
    _logfile_write "(mongo) ${log}" || return 1

    out_handler_print "${log}"

    [[ $DEBUG && $DEBUG == true ]] && echo -en \
      "(commons_mongo_compile_idx) File $f not found.\n"
    return 1
  fi

  # Check if index is already present.
  commons_mongo_get_indexes_list "${coll}" "${kname}" || \
    error_handled "Error on check if index ${coll}.${kname} already exists."

  local n_indexes=${#mongo_indexes[@]}

  if [ $n_indexes -gt 0 ] ; then

    local log="Index ${coll}.${kname} is already present. Nothing to do."
    out_handler_print "${log}"

    _logfile_write "(mongo) ${log}"

  else

    commons_mongo_compile_file "${f}" "$msg" "1" || return 1

  fi

  return 0
}
# commons_mongo_commons_mongo_compile_idx_end

# commons_mongo_commons_mongo_compile_all_from_dir
commons_mongo_compile_all_from_dir () {

  local directory="$1"
  local msg_head="$2"
  local msg="$3"
  local dtype="$4"
  local closure="$5"
  local f=""
  local fb=""
  local ex_f=""
  local fk_is_present=1
  local exc=0

  _logfile_write "(mongo) Start compilation $msg_head: $msg" || return 1

  for i in $directory/*.js ; do

    if [ ! -f "${i}" ]  ; then
      continue
    fi

    fk_is_present=1
    exc=0

    fb=`basename $i`
    f="${fb/.js/}"

    # Check if file is excluded
    if [ ! -z "$MONGO_COMPILE_FILES_EXCLUDED" ] ; then

      for e in $MONGO_COMPILE_FILES_EXCLUDED ; do

        ex_f=`basename $e`
        ex_f="${ex_f/.js/}"

        if [ "$ex_f" == "$f" ] ; then
          exc=1

          _logfile_write "(mongo) Exclude file $fb for user request."

          break
        fi

      done # end for exclueded

    fi

    # If file is excluded go to the next
    [ $exc -eq 1 ] && continue

    [[ $DEBUG && $DEBUG == true ]] && echo -en \
      "(commons_mongo_compile_all_from_dir: compile file [$i].\n"

    if [[ -n "$dtype" && x"$dtype" == x"idx" ]] ; then

      commons_mongo_compile_idx "$i" "$msg" "${closure}"

    else

      commons_mongo_compile_file "$i" "$msg" "1"

    fi

    # POST: on error go to next file

  done # end for

  _logfile_write "(mongo) End compilation $msg_head: $msg" || return 1

  return 0

}
# commons_mongo_commons_mongo_compile_all_from_dir_end

# commons_mongo_commons_mongo_compile_all_idxs
commons_mongo_compile_all_idxs () {

  local msg="$1"
  local force="$2"
  local directory="$MONGO_DIR/indexes"

  commons_mongo_compile_all_from_dir "$directory" "of all indexes" "$msg" "idx" "${force}" || \
    return 1

  return 0
}
# commons_mongo_commons_mongo_compile_all_idxs_end

# vim: syn=sh filetype=sh
