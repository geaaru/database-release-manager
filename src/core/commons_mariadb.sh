#!/bin/bash
#------------------------------------------------
# Author(s): Geaaru, geaaru@gmail.com
# $Id$
# License: GPL 2.0
#------------------------------------------------

# commons_mariadb_commons_mariadb_check_client
commons_mariadb_check_client () {

  if [ -z "$mysql" ] ; then

    # POST: mysql variable not set
    tmp=`which mysql 2> /dev/null`
    var=$?

    if [ $var -eq 0 ] ; then

      [[ $DEBUG && $DEBUG == true ]] && echo -en "Use mysql: $tmp\n"

      MARIADB_CLIENT=$tmp

      unset tmp

    else

      error_generate "mysql program not found"

      return 1

    fi

  else

    # POST: mysql variable set

    # Check if file is correct
    if [ -f "$mysql" ] ; then

      [[ $DEBUG && $DEBUG == true ]] && echo -en "Use mysql: $mysql\n"

      MARIADB_CLIENT=$mysql

    else

      error_generate "$mysql program invalid."

      return 1

    fi

  fi

  export MARIADB_CLIENT

  return 0

}
# commons_mariadb_commons_mariadb_check_client_end

# commons_mariadb_commons_mariadb_check_vars
commons_mariadb_check_vars () {

  local commons_msg='variable on configuration file, through arguments or on current profile.'

  check_var "MARIADB_USER" || error_handled "You must define MARIADB_USER $commons_msg"
  check_var "MARIADB_PWD"  || error_handled "You must define MARIADB_PWD $commons_msg"
  check_var "MARIADB_DB"   || error_handled "You must define MARIADB_DB $commons_msg"
  check_var "MARIADB_DIR"  || error_handled "You must define MARIADB_DIR $commons_msg"


  return 0
}
# commons_mariadb_commons_mariadb_check_vars_end

# commons_mariadb_commons_mariadb_check_connection
commons_mariadb_check_connection () {

  if [ -z "$MARIADB_CLIENT" ] ; then
    return 1
  fi

  if [ -z "$mysql_auth" ] ; then
    return 1
  fi

  [[ $DEBUG && $DEBUG == true ]] && \
    echo -en "(commons_mariadb_check_connection) Try connection with -A $MARIADB_EXTRA_OPTIONS $mysql_auth.\n"

  $MARIADB_CLIENT -A $MARIADB_EXTRA_OPTIONS $mysql_auth 2>&1 << EOF
exit
EOF

  errorCode=$?
  if [ ${errorCode} -ne 0 ] ; then
    return 1
  fi

  unset errorCode

  [[ $DEBUG && $DEBUG == true ]] && echo "mysql was connected successfully"

  return 0
}
# commons_mariadb_commons_mariadb_check_connection_end

# commons_mariadb_commons_mariadb_shell
commons_mariadb_shell () {

  local opts=""

  if [ -z "$MARIADB_CLIENT" ] ; then
    return 1
  fi

  if [ -z "$mysql_auth" ] ; then
    return 1
  fi

  if [[ -n "$MARIADB_ENABLE_COMMENTS" && x"$MARIADB_ENABLE_COMMENTS" == x"1" ]] ; then
    opts="$opts -c"
  fi

  # TODO: Enable -A options through a variable option.
  [[ $DEBUG && $DEBUG == true ]] && echo -en "(commons_mariadb_shell) Try connection with $opts $MARIADB_EXTRA_OPTIONS $mysql_auth.\n"

  $MARIADB_CLIENT $opts $MARIADB_EXTRA_OPTIONS $mysql_auth

  errorCode=$?
  if [ ${errorCode} -ne 0 ] ; then
    return 1
  fi

  unset errorCode

  return 0
}
# commons_mariadb_commons_mariadb_shell_end

# commons_mariadb_commons_mariadb_compile_file
commons_mariadb_compile_file () {

  local f=$1
  local msg=$2
  local f_base=$(basename "$f")

  if [ ! -e $f ] ; then
    _logfile_write "(mariadb) File $f not found." || return 1
    return 1
  fi

  _logfile_write "(mariadb) Start compilation (file $f_base): $msg" || return 1

  echo "(mariadb) Start compilation (file $f_base): $msg"

  MYSQL_OUTPUT=""

  mysql_file "MYSQL_OUTPUT" "$f"
  local ans=$?

  _logfile_write "\n$MYSQL_OUTPUT" || return 1

  _logfile_write "(mariadb) End compilation (file $f_base, result => $ans): $msg" || return 1

  echo -en "(mariadb) End compilation (file $f_base, result => $ans): $msg\n"

  return $ans

}
# commons_mariadb_commons_mariadb_compile_file_end

# commons_mariadb_commons_mariadb_source_file
commons_mariadb_source_file () {

  local f=$1
  local msg=$2
  local f_base=$(basename "$f")

  if [ ! -e $f ] ; then
    _logfile_write "(mariadb) File $f not found." || return 1
    return 1
  fi

  _logfile_write "(mariadb) Start compilation/source (file $f_base): $msg" || return 1

  echo "(mariadb) Start compilation/source (file $f_base): $msg"

  MYSQL_OUTPUT=""

  mysql_source_file "MYSQL_OUTPUT" "$f"
  local ans=$?

  _logfile_write "\n$MYSQL_OUTPUT" || return 1

  _logfile_write "(mariadb) End compilation/source (file $f_base, result => $ans): $msg" || return 1

  echo -en "(mariadb) End compilation/source (file $f_base, result => $ans): $msg\n"

  return $ans

}
# commons_mariadb_commons_mariadb_source_file_end

# commons_mariadb_commons_mariadb_compile_fkey
commons_mariadb_compile_fkey () {

  local f=$1
  local msg=$2
  local force="$3"
  local fk_table="$4"
  local f_base=$(basename "$f")
  local fk_dir=$(dirname "$f")
  local fk_str="${f_base/.sql/}"
  local fk=""
  local fk_is_present=1
  local fktname=""

  # Try to check if is present table name from filename
  fktname=$(echo $fk_str | awk 'match($0, /[a-zA-Z_]+/) { print substr($0, RSTART, RLENGTH) }')
  fk=$(echo $fk_str | awk 'match($0, /[-]/) { print substr($0, RSTART + 1) }')

  [[ $DEBUG && $DEBUG == true ]] && echo -en \
    "(commons_mariadb_compile_fkey: f = ${f}, force = ${force}, fk_table"\
    " = ${fk_table}, fktname = ${fktname}, fk = ${fk}, fk_str = ${fk_str}.\n"

  if [ -z "${fk_table}" ] ; then

    [ -n "${fktname}" ] && fk_table="${fktname}"

  elif [[ -n "${fk_table}" && -n "${fk}" ]] ; then
    # POST: fk_str contains both fk key name and fk key table.
    #       I check if fk_table in input is equal to fktname (string catch from fr_str)
    if [ "${fk_table}" != "${fktname}" ] ; then
      _logfile_write "(mariadb) Foreign key ${fk_str} is not related with table ${fk_table}." || return 1

      error_generate "Foreign key ${fk_str} is not related with table ${fk_table}."
    fi

  fi

  [ -z "${fk}" ] && fk="${fk_str}"

  # Check if foreign key already present
  commons_mariadb_check_if_exist_fkey "${fk}" "${fk_table}"
  fk_is_present=$?

  # If fktname is empty and fk_table is not available and foreign key is present
  # I try to retrieve table name
  if [[ -z "${fk_table}" && $fk_is_present -eq 0 ]] ; then

    commons_mariadb_get_fkeys_list "" "KCU.CONSTRAINT_NAME, KCU.TABLE_NAME" "${fk}" || \
      error_handled "Error on get data of foreign key $fk."

    fk_table=`echo $_mariadb_ans | awk '{split($0,a,"|"); print a[2]}'`
  fi

  [[ $DEBUG && $DEBUG == true ]] && echo -en \
    "( commons_mariadb_compile_fkey: (${fk_str}) I use fkey ${fk} for table ${fk_table} (${fktname}) (force = ${force}))\n"

  [ ! -e "${f}" ] && f=${fk_dir}/${fk_table}-${fk}.sql

  if [ ! -e "${f}" ] ; then
    _logfile_write "(mariadb) File $f not found." || return 1
    [[ $DEBUG && $DEBUG == true ]] && echo -en "(mariadb) File $f not found.\n"
    return 1
  fi

  [[ $DEBUG && $DEBUG == true ]] && echo -en \
    "( commons_mariadb_compile_fkey: Try to compile foreign key ${fk} for table ${fk_table} (${force})...)\n"

  if [[ $fk_is_present -eq 0 && x"${force}" == x"1" ]] ; then
    # POST: foreign is is present and force is equal to 1.

    commons_mariadb_drop_fkey "${fk}" "" "${fk_table}" || return 1

    commons_mariadb_compile_file "$f" "$msg" || return 1

  elif [ $fk_is_present -eq 0 ] ; then

    [[ $DEBUG && $DEBUG == true ]] && \
      echo -en "( commons_mariadb_compile_fkey: foreign key ${fk} for table ${fk_table} is already present. Nothing to do.)\n"

    _logfile_write "(mariadb) Foreign key ${fk} is already present. Nothing to do." || return 1

  elif [ $fk_is_present -eq 2 ] ; then

    [[ $DEBUG && $DEBUG == true ]] && \
      echo -en "( commons_mariadb_compile_fkey: foreign key ${fk} exists for different tables.\nSet table param.)\n"

    _logfile_write "(mariadb) Foreign key ${fk} exists for different tables. Set table param for compilation." || return 1

  else

    # POST: foreign key not present. I compile it.
    commons_mariadb_compile_file "$f" "$msg" || return 1

  fi

  return 0
}
# commons_mariadb_commons_mariadb_compile_fkey_end

# commons_mariadb_commons_mariadb_compile_idx
commons_mariadb_compile_idx () {

  local f=$1
  local msg=$2
  local force="$3"
  local idx_table="$4"
  local f_base=$(basename "$f")
  local idx_dir=$(dirname "$f")
  local idx_str="${f_base/.sql/}"
  local idx=""
  local idx_is_present=1
  local idxtname=""

  # Try to check if is present table name from filename
  # TODO: show how handle table with "-" on name.
  idxtname=$(echo $idx_str | awk 'match($0, /[a-zA-Z_]+/) { print substr($0, RSTART, RLENGTH) }')
  idx=$(echo $idx_str | awk 'match($0, /[-]/) { print substr($0, RSTART + 1) }')

  if [ -z "${idx_table}" ] ; then

    [ -n "${idxtname}" ] && idx_table="${idxtname}"

  elif [[ -n "${idx_table}" && -n "${idx}" ]] ; then
    # POST: idx_str contains both index name and index table.
    #       I check if idx_table in input is equal to idxtname (string catch from idx_str)
    if [ "${idx_table}" != "${idxtname}" ] ; then
      _logfile_write "(mariadb) Index ${idx_str} is not related with table ${idx_table}." || return 1

      error_generate "Index ${idx_str} is not related with table ${idx_table}."
    fi

  fi

  [ -z "${idx}" ] && idx="${idx_str}"

  # Check if foreign key already present
  commons_mariadb_check_if_exist_index "${idx}" "${idx_table}"
  idx_is_present=$?

  # If idxtname is empty and idx_table is not available and index is present
  # I try to retrieve table name
  if [[ -z "${idx_table}" && $idx_is_present -eq 0 ]] ; then

    commons_mariadb_get_indexes_list "not_primary" "S.INDEX_NAME, S.TABLE_NAME" "${idx}" || \
      error_handled "Error on get data of index $idx."

    idx_table=`echo $_mariadb_ans | awk '{split($0,a,"|"); print a[2]}'`
  fi

  [[ $DEBUG && $DEBUG == true ]] && echo -en \
    "( commons_mariadb_compile_idx: (${idx_str}) I use index ${idx} for table ${idx_table} (${idxtname}) (force = ${force}))\n"

  [ ! -e "${f}" ] && f=${idx_dir}/${idx_table}-${idx}.sql

  if [ ! -e "${f}" ] ; then
    _logfile_write "(commons_mariadb_compile_idx) File $f not found." || return 1
    [[ $DEBUG && $DEBUG == true ]] && echo -en "(mariadb) File $f not found.\n"
    return 1
  fi

  [[ $DEBUG && $DEBUG == true ]] && echo -en \
    "( commons_mariadb_compile_idx: Try to compile index ${idx} for table ${idx_table} (${force})...)\n"

  if [[ $idx_is_present -eq 0 && x"${force}" == x"1" ]] ; then
    # POST: index is present and force is equal to 1.

    commons_mariadb_drop_index "${idx}" "${idx_table}" || return 1

    commons_mariadb_compile_file "$f" "$msg" || return 1

  elif [ $idx_is_present -eq 0 ] ; then

    [[ $DEBUG && $DEBUG == true ]] && \
      echo -en "( commons_mariadb_compile_idx: index ${idx} for table ${idx_table} is already present. Nothing to do.)\n"

    _logfile_write "(mariadb) Index ${idx} is already present. Nothing to do." || return 1

  elif [ $idx_is_present -eq 2 ] ; then

    [[ $DEBUG && $DEBUG == true ]] && \
      echo -en "( commons_mariadb_compile_idx: index ${idx} exists for different tables.\nSet table param.)\n"

    _logfile_write "(mariadb) Index ${idx} exists for different tables. Set table param for compilation." || return 1

  else

    # POST: index not present. I compile it.
    commons_mariadb_compile_file "$f" "$msg" || return 1

  fi

  return 0
}
# commons_mariadb_commons_mariadb_compile_idx_end


# commons_mariadb_commons_mariadb_compile_all_procedures
commons_mariadb_compile_all_procedures () {

  local msg="$1"
  local directory="$MARIADB_DIR/procedures"

  commons_mariadb_compile_all_from_dir "$directory" "of all procedures" "$msg" || return 1

  return 0
}
# commons_mariadb_commons_mariadb_compile_all_procedures_end

# commons_mariadb_commons_mariadb_compile_all_triggers
commons_mariadb_compile_all_triggers () {

  local msg="$1"
  local directory="$MARIADB_DIR/triggers"

  commons_mariadb_compile_all_from_dir "$directory" "of all triggers" "$msg" || return 1

  return 0
}
# commons_mariadb_commons_mariadb_compile_all_triggers_end

# commons_mariadb_commons_mariadb_compile_all_functions
commons_mariadb_compile_all_functions () {

  local msg="$1"
  local directory="$MARIADB_DIR/functions"

  commons_mariadb_compile_all_from_dir "$directory" "of all functions" "$msg" || return 1

  return 0
}
# commons_mariadb_commons_mariadb_compile_all_functions_end

# commons_mariadb_commons_mariadb_compile_all_views
commons_mariadb_compile_all_views () {

  local msg="$1"
  local directory="$MARIADB_DIR/views"

  commons_mariadb_compile_all_from_dir "$directory" "of all views" "$msg" || return 1

  return 0
}
# commons_mariadb_commons_mariadb_compile_all_views_end

# commons_mariadb_commons_mariadb_compile_all_fkeys
commons_mariadb_compile_all_fkeys () {

  local msg="$1"
  local force="$2"
  local directory="$MARIADB_DIR/foreign_keys"

  commons_mariadb_compile_all_from_dir "$directory" "of all foreign keys" "$msg" "fkey" "${force}" || \
    return 1

  return 0
}
# commons_mariadb_commons_mariadb_compile_all_fkeys_end

# commons_mariadb_commons_mariadb_compile_all_idxs
commons_mariadb_compile_all_idxs () {

  local msg="$1"
  local force="$2"
  local directory="$MARIADB_DIR/indexes"

  commons_mariadb_compile_all_from_dir "$directory" "of all indexes" "$msg" "idx" "${force}" || \
    return 1

  return 0
}
# commons_mariadb_commons_mariadb_compile_all_idxs_end

# commons_mariadb_commons_mariadb_compile_all_events
commons_mariadb_compile_all_events () {

  local msg="$1"
  local directory="$MARIADB_DIR/schedulers"

  commons_mariadb_compile_all_from_dir "$directory" "of all events" "$msg" || return 1

  return 0
}
# commons_mariadb_commons_mariadb_compile_all_events_end


# commons_mariadb_commons_mariadb_compile_all_from_dir
commons_mariadb_compile_all_from_dir () {

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

  _logfile_write "(mariadb) Start compilation $msg_head: $msg" || return 1

  for i in $directory/*.sql ; do

    if [ ! -f "${i}" ]  ; then
      continue
    fi

    fk_is_present=1
    exc=0

    fb=`basename $i`
    f="${fb/.sql/}"

    # Check if file is excluded
    if [ ! -z "$MARIADB_COMPILE_FILES_EXCLUDED" ] ; then

      for e in $MARIADB_COMPILE_FILES_EXCLUDED ; do

        ex_f=`basename $e`
        ex_f="${ex_f/.sql/}"

        if [ "$ex_f" == "$f" ] ; then
          exc=1

          _logfile_write "(mariadb) Exclude file $fb for user request."

          break
        fi

      done # end for exclueded

    fi

    # If file is excluded go to the next
    [ $exc -eq 1 ] && continue

    [[ $DEBUG && $DEBUG == true ]] && echo -en \
      "(commons_mariadb_compile_all_from_dir: compile file [$i].\n"

    if [[ -n "$dtype" && x"$dtype" == x"fkey" ]] ; then

      commons_mariadb_compile_fkey "$i" "$msg" "${closure}"

    else

      if [[ -n "$dtype" && x"$dtype" == x"idx" ]] ; then

        commons_mariadb_compile_idx "$i" "$msg" "${closure}"

      else

        commons_mariadb_compile_file "$i" "$msg"

      fi

    fi

    # POST: on error go to next file

  done # end for

  _logfile_write "(mariadb) End compilation $msg_head: $msg" || return 1

  return 0

}
# commons_mariadb_commons_mariadb_compile_all_from_dir_end

# commons_mariadb_commons_mariadb_count_fkeys
commons_mariadb_count_fkeys () {

  local tname=$1
  local mode=$2
  local andwhere=""

  if [[ -n "$tname" && -z "$mode" || -n "$tname" && "$mode" == "in" ]] ; then
    andwhere="AND TS.TABLE_NAME = '$tname'"
  else
    if [[ -n "$tname" && "$mode" == "ref" ]] ; then
      andwhere="AND KCU.REFERENCED_TABLE_NAME = '$tname'"
    fi
  fi

  local cmd="
    SELECT COUNT(1) AS CNT
    FROM (
      SELECT
      KCU.CONSTRAINT_NAME,
      KCU.TABLE_NAME,
      GROUP_CONCAT(KCU.COLUMN_NAME ORDER BY KCU.ORDINAL_POSITION) AS COLUMN_NAME,
      KCU.REFERENCED_TABLE_NAME,
      GROUP_CONCAT(KCU.REFERENCED_COLUMN_NAME ORDER BY KCU.ORDINAL_POSITION) AS REFERENCED_COLUMN_NAME,
      RC.UPDATE_RULE,
      RC.DELETE_RULE
    FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS TS,
         INFORMATION_SCHEMA.KEY_COLUMN_USAGE KCU,
         INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS RC
    WHERE TS.TABLE_SCHEMA = TS.CONSTRAINT_SCHEMA
    AND TS.CONSTRAINT_SCHEMA = KCU.TABLE_SCHEMA
    AND KCU.TABLE_SCHEMA = '$MARIADB_DB'
    AND RC.CONSTRAINT_SCHEMA = KCU.TABLE_SCHEMA
    AND TS.CONSTRAINT_TYPE = 'FOREIGN KEY'
    AND TS.CONSTRAINT_NAME = KCU.CONSTRAINT_NAME
    AND RC.CONSTRAINT_NAME = TS.CONSTRAINT_NAME
    AND RC.UNIQUE_CONSTRAINT_SCHEMA = KCU.TABLE_SCHEMA
    AND KCU.REFERENCED_TABLE_NAME IS NOT NULL
    $andwhere
    GROUP BY KCU.CONSTRAINT_NAME
    ORDER BY TS.TABLE_NAME, TS.CONSTRAINT_NAME 
    ) TMP;"

  mysql_cmd_4var "MYSQL_OUTPUT" "$cmd" "" "1" || error_handled ""

  if [ -z "$MYSQL_OUTPUT" ] ; then
    error_generate "Error on count foreign keys."
  fi

  return $MYSQL_OUTPUT
}
# commons_mariadb_commons_mariadb_count_fkeys_end

# commons_mariadb_commons_mariadb_count_procedures
commons_mariadb_count_procedures () {

  local cmd="
    SELECT COUNT(1) AS CNT
    FROM INFORMATION_SCHEMA.ROUTINES
    WHERE ROUTINE_SCHEMA = '$MARIADB_DB'
    AND ROUTINE_TYPE = 'PROCEDURE';"

  mysql_cmd_4var "MYSQL_OUTPUT" "$cmd" "" "1" || error_handled ""

  if [ -z "$MYSQL_OUTPUT" ] ; then
    error_generate "Error on count procedures."
  fi

  return $MYSQL_OUTPUT
}
# commons_mariadb_commons_mariadb_count_procedures_end

# commons_mariadb_commons_mariadb_count_functions
commons_mariadb_count_functions () {

  local cmd="
    SELECT COUNT(1) AS CNT
    FROM INFORMATION_SCHEMA.ROUTINES
    WHERE ROUTINE_SCHEMA = '$MARIADB_DB'
    AND ROUTINE_TYPE = 'FUNCTION';"

  mysql_cmd_4var "MYSQL_OUTPUT" "$cmd" || error_handled ""

  if [ -z "$MYSQL_OUTPUT" ] ; then
    error_generate "Error on count functions."
  fi

  return $MYSQL_OUTPUT
}
# commons_mariadb_commons_mariadb_count_functions_end

# commons_mariadb_commons_mariadb_count_triggers
commons_mariadb_count_triggers () {

  local cmd="
    SELECT COUNT(1) AS CNT
    FROM INFORMATION_SCHEMA.TRIGGERS
    WHERE TRIGGER_SCHEMA = '$MARIADB_DB'
    AND ACTION_TIMING IN ('BEFORE', 'AFTER')
    AND EVENT_MANIPULATION IN ('INSERT', 'UPDATE', 'DELETE')
    AND ACTION_STATEMENT IS NOT NULL;"

  mysql_cmd_4var "MYSQL_OUTPUT" "$cmd" || error_handled ""

  if [ -z "$MYSQL_OUTPUT" ] ; then
    error_generate "Error on count triggers."
  fi

  return $MYSQL_OUTPUT
}
# commons_mariadb_commons_mariadb_count_triggers_end

# commons_mariadb_commons_mariadb_count_views
commons_mariadb_count_views () {

  local cmd="
    SELECT COUNT(1) AS CNT
    FROM INFORMATION_SCHEMA.VIEWS
    WHERE TABLE_SCHEMA = '$MARIADB_DB';"

  mysql_cmd_4var "MYSQL_OUTPUT" "$cmd" "" "1" || error_handled ""

  if [ -z "$MYSQL_OUTPUT" ] ; then
    error_generate "Error on count views."
  fi

  return $MYSQL_OUTPUT
}
# commons_mariadb_commons_mariadb_count_views_end

# commons_mariadb_commons_mariadb_count_events
commons_mariadb_count_events () {

  local cmd="
    SELECT COUNT(1) AS CNT
    FROM INFORMATION_SCHEMA.EVENTS
    WHERE EVENT_SCHEMA = '$MARIADB_DB';"

  mysql_cmd_4var "MYSQL_OUTPUT" "$cmd" "" "1" || error_handled ""

  if [ -z "$MYSQL_OUTPUT" ] ; then
    error_generate "Error on count events."
  fi

  return $MYSQL_OUTPUT
}
# commons_mariadb_commons_mariadb_count_events_end

# commons_mariadb_commons_mariadb_count_indexes
commons_mariadb_count_indexes () {

  local tname=$1
  local idx_types="$2"
  local andwhere=""
  local andWhere_type=""

  if [ -n "$tname" ] ; then
    andwhere="AND TABLE_NAME = '$tname'"
  fi

  if [ -n "$idx_types" ] ; then
    if [ x"$idx_types" == x"primary" ] ; then
      andWhere_type="AND INDEX_NAME = 'PRIMARY'"
    else
      if [ x"$idx_types" == x"not_primary" ] ; then
        andWhere_type="AND INDEX_NAME <> 'PRIMARY'"
      fi
    fi
  fi

  local cmd="
    SELECT COUNT(1) AS CNT
    FROM (
      SELECT *
      FROM (
        SELECT TABLE_NAME, INDEX_NAME
        FROM  INFORMATION_SCHEMA.STATISTICS S
        WHERE S.TABLE_SCHEMA = '$MARIADB_DB'
        ${andWhere_type}
        ${andwhere}
        GROUP BY S.TABLE_NAME, S.INDEX_NAME
        ORDER BY S.TABLE_NAME, S.INDEX_NAME
      ) IDX
      WHERE IDX.INDEX_NAME NOT IN (
            SELECT TC.CONSTRAINT_NAME AS INDEX_NAME
            FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS TC
            WHERE TC.TABLE_SCHEMA = '$MARIADB_DB'
            AND TC.CONSTRAINT_SCHEMA = TC.TABLE_SCHEMA
            AND TC.CONSTRAINT_TYPE = 'FOREIGN KEY'
      )
    ) TMP
  "

  mysql_cmd_4var "MYSQL_OUTPUT" "$cmd" "" "1" || error_handled ""

  if [ -z "$MYSQL_OUTPUT" ] ; then
    error_generate "Error on count indexes."
  fi

  return $MYSQL_OUTPUT
}
# commons_mariadb_commons_mariadb_count_indexes_end

# commmons_mariadb_commons_mariadb_check_if_exist_procedure
commons_mariadb_check_if_exist_procedure () {

  local result=1
  local name="$1"
  local errmsg="Error on check if exists procedure $name."
  local cmd="
    SELECT COUNT(1) AS CNT
    FROM INFORMATION_SCHEMA.ROUTINES
    WHERE ROUTINE_SCHEMA = '$MARIADB_DB'
    AND ROUTINE_TYPE = 'PROCEDURE'
    AND ROUTINE_NAME = '$name' ;"

  mysql_cmd_4var "MYSQL_OUTPUT" "$cmd" || return $result

  if [ -z "$MYSQL_OUTPUT" ] ; then
    error_generate "$errmsg"
  fi

  if [ x"$MYSQL_OUTPUT" == x"1" ] ; then
    result=0
  fi

  return $result
}
# commmons_mariadb_commons_mariadb_check_if_exist_procedure_end

# commmons_mariadb_commons_mariadb_check_if_exist_function
commons_mariadb_check_if_exist_function () {

  local result=1
  local name="$1"
  local errmsg="Error on check if exists function $name."
  local cmd="
    SELECT COUNT(1) AS CNT
    FROM INFORMATION_SCHEMA.ROUTINES
    WHERE ROUTINE_SCHEMA = '$MARIADB_DB'
    AND ROUTINE_TYPE = 'FUNCTION'
    AND ROUTINE_NAME = '$name'"

  mysql_cmd_4var "MYSQL_OUTPUT" "$cmd" || return $result

  if [ -z "$MYSQL_OUTPUT" ] ; then
    error_generate "$errmsg"
  fi

  if [ x"$MYSQL_OUTPUT" == x"1" ] ; then
    result=0
  fi

  return $result
}
# commmons_mariadb_commons_mariadb_check_if_exist_function_end

# commmons_mariadb_commons_mariadb_check_if_exist_view
commons_mariadb_check_if_exist_view () {

  local result=1
  local name="$1"
  local errmsg="Error on check if exists view $name."
  local cmd="
    SELECT COUNT(1) AS CNT
    FROM INFORMATION_SCHEMA.VIEWS
    WHERE TABLE_SCHEMA = '$MARIADB_DB'
    AND TABLE_NAME = '$name' ;"

  mysql_cmd_4var "MYSQL_OUTPUT" "$cmd" || return $result

  if [ -z "$MYSQL_OUTPUT" ] ; then
    error_generate "$errmsg"
  fi

  if [ x"$MYSQL_OUTPUT" == x"1" ] ; then
    result=0
  fi

  return $result
}
# commmons_mariadb_commons_mariadb_check_if_exist_view_end

# commmons_mariadb_commons_mariadb_check_if_exist_fkey
commons_mariadb_check_if_exist_fkey () {

  local result=1
  local name="$1"
  local tname="$2"
  local errmsg="Error on check if exists foreign key with $name."
  local cmd=""
  local andWhere=""

  if [ -n "${tname}" ] ; then
    andWhere="AND TABLE_NAME = '${tname}'"
  fi

  cmd="
    SELECT COUNT(1) AS CNT
    FROM
    (
      SELECT CONSTRAINT_NAME, TABLE_NAME
      FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
      WHERE TABLE_SCHEMA = '$MARIADB_DB'
      AND CONSTRAINT_TYPE = 'FOREIGN KEY'
      AND CONSTRAINT_SCHEMA = '$MARIADB_DB'
      AND CONSTRAINT_NAME = '$name'
      ${andWhere}
      GROUP BY CONSTRAINT_NAME, TABLE_NAME
     ) TMP "

  mysql_cmd_4var "MYSQL_OUTPUT" "$cmd" || return $result

  if [ -z "$MYSQL_OUTPUT" ] ; then
    error_generate "$errmsg"
  fi

  if [ x"$MYSQL_OUTPUT" == x"1" ] ; then
    result=0
  elif [ x"$MYSQL_OUTPUT" == x"2" ] ; then
    result=2
  fi

  return $result
}
# commmons_mariadb_commons_mariadb_check_if_exist_fkey_end

# commmons_mariadb_commons_mariadb_check_if_exist_index
commons_mariadb_check_if_exist_index () {

  local result=1
  local name="$1"
  local tname="$2"
  local errmsg="Error on check if exists index key with $name on table $tname."
  local cmd="
    SELECT COUNT(1) AS CNT
    FROM (
       SELECT TABLE_NAME, INDEX_NAME
      FROM  INFORMATION_SCHEMA.STATISTICS
      WHERE TABLE_SCHEMA = '$MARIADB_DB'
      AND INDEX_NAME NOT IN (
          SELECT TC.CONSTRAINT_NAME
          FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS TC
          WHERE TC.TABLE_SCHEMA = '$MARIADB_DB'
          AND TC.CONSTRAINT_SCHEMA = TC.TABLE_SCHEMA
          AND TC.CONSTRAINT_TYPE = 'FOREIGN KEY'
      )
      AND TABLE_NAME = '${tname}'
      AND INDEX_NAME = '${name}'
      GROUP BY TABLE_NAME, INDEX_NAME
      ORDER BY TABLE_NAME, INDEX_NAME
    ) T"

  mysql_cmd_4var "MYSQL_OUTPUT" "$cmd" || return $result

  if [ -z "$MYSQL_OUTPUT" ] ; then
    error_generate "$errmsg"
  fi

  if [ x"$MYSQL_OUTPUT" == x"1" ] ; then
    result=0
  fi

  return $result
}
# commmons_mariadb_commons_mariadb_check_if_exist_index_end

# commmons_mariadb_commons_mariadb_get_triggers_list
commons_mariadb_get_triggers_list () {

  local result=1
  local cmd="
    SELECT TRIGGER_NAME, EVENT_OBJECT_TABLE, ACTION_TIMING, EVENT_MANIPULATION
    FROM INFORMATION_SCHEMA.TRIGGERS
    WHERE TRIGGER_SCHEMA = '$MARIADB_DB'
    AND ACTION_TIMING IN ('BEFORE', 'AFTER')
    AND EVENT_MANIPULATION IN ('INSERT', 'UPDATE', 'DELETE')
    AND ACTION_STATEMENT IS NOT NULL
    ORDER BY EVENT_OBJECT_TABLE, ACTION_ORDER;"

  mysql_cmd_4var "_mariadb_ans" "$cmd" || return $result

  return 0
}
# commmons_mariadb_commons_mariadb_get_triggers_list_end

# commmons_mariadb_commons_mariadb_count_tables
commons_mariadb_count_tables () {

  local cmd="
    SELECT COUNT(1) AS CNT
    FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_SCHEMA = '$MARIADB_DB';"

  mysql_cmd_4var "MYSQL_OUTPUT" "$cmd" "" "1" || error_handled ""

  if [ -z "$MYSQL_OUTPUT" ] ; then
    error_generate "Error on count tables."
  fi

  return $MYSQL_OUTPUT
}
# commmons_mariadb_commons_mariadb_count_tables_end

# commmons_mariadb_commons_mariadb_get_fkeys_list
commons_mariadb_get_fkeys_list () {

  local all="$1"
  local custom_column="$2"
  local fkey_name="$3"
  local tname="$4"
  local mode="$5"
  local all_column=""
  local fk_name=""
  local ext_custom_column=""
  local ext_all_columns=""

  # NOTE: Currently if all is not an empty string
  #       I think that custom_column is not used.

  if [ -n "$all" ] ; then
    all_column="
      KCU.CONSTRAINT_NAME,
      KCU.TABLE_NAME,
      GROUP_CONCAT(KCU.COLUMN_NAME ORDER BY KCU.ORDINAL_POSITION) AS COLUMN_NAME,
      KCU.REFERENCED_TABLE_NAME,
      GROUP_CONCAT(KCU.REFERENCED_COLUMN_NAME ORDER BY KCU.ORDINAL_POSITION) AS REFERENCED_COLUMN_NAME,
      RC.UPDATE_RULE,
      RC.DELETE_RULE
    "
    # KCU.POSITION_IN_UNIQUE_CONSTRAINT

    # RC.MATCH_OPTION,
    # For now only possible value for this field is None.
    # See: http://dev.mysql.com/doc/refman/5.7/en/referential-constraints-table.html

    ext_all_columns="
      TMP.CONSTRAINT_NAME,
      TMP.TABLE_NAME,
      TMP.COLUMN_NAME,
      TMP.REFERENCED_TABLE_NAME,
      TMP.REFERENCED_COLUMN_NAME,
      TMP.UPDATE_RULE,
      TMP.DELETE_RULE
    "

  else

    # TODO: Currently replace only KCU table.
    ext_custom_column=${custom_column//KCU./TMP.}

  fi

  if [ -n "${fkey_name}" ] ; then
    fk_name="AND TS.CONSTRAINT_NAME = '${fkey_name}'"
  fi

  if [[ -n "$tname" && -z "$mode" || -n "$tname" && "$mode" == "in" ]] ; then
    andwhere="AND TS.TABLE_NAME = '$tname'"
  else
    if [[ -n "$tname" && "$mode" == "ref" ]] ; then
      andwhere="AND KCU.REFERENCED_TABLE_NAME = '$tname'"
    fi
  fi

  local cmd="
    SELECT CONCAT_WS('|', ${ext_all_columns} ${ext_custom_column}) AS ANS
    FROM (
      SELECT ${all_column} ${custom_column}
      FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS TS,
           INFORMATION_SCHEMA.KEY_COLUMN_USAGE KCU,
           INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS RC
      WHERE TS.TABLE_SCHEMA = '$MARIADB_DB'
      AND TS.CONSTRAINT_SCHEMA = '$MARIADB_DB'
      AND KCU.TABLE_SCHEMA = '$MARIADB_DB'
      AND RC.CONSTRAINT_SCHEMA = KCU.TABLE_SCHEMA
      AND TS.CONSTRAINT_TYPE = 'FOREIGN KEY'
      AND TS.CONSTRAINT_NAME = KCU.CONSTRAINT_NAME
      AND RC.CONSTRAINT_NAME = TS.CONSTRAINT_NAME
      AND RC.UNIQUE_CONSTRAINT_SCHEMA = KCU.TABLE_SCHEMA
      AND KCU.REFERENCED_TABLE_NAME IS NOT NULL
      ${fk_name}
      ${andwhere}
      GROUP BY KCU.CONSTRAINT_NAME
      ORDER BY TS.TABLE_NAME, TS.CONSTRAINT_NAME
    ) TMP
  "

  mysql_cmd_4var "_mariadb_ans" "$cmd" || return 1

  return 0
}
# commmons_mariadb_commons_mariadb_get_fkeys_list_end

# commmons_mariadb_commons_mariadb_get_indexes_list
commons_mariadb_get_indexes_list () {

  local idx_types="$1"
  local custom_column="$2"
  local tname="$3"
  local iname="$4"
  local all_column=""
  local andWhere_name=""
  local andWhere_type=""
  local ext_custom_column=""
  local ext_all_columns=""

  if [ -z "$custom_column" ] ; then
    all_column="
      S.TABLE_NAME,
      S.NON_UNIQUE,
      S.INDEX_NAME,
      GROUP_CONCAT(S.COLUMN_NAME ORDER BY S.SEQ_IN_INDEX) AS KEY_COLUMNS,
      S.INDEX_TYPE,
      S.COMMENT,
      S.INDEX_COMMENT
    "
    # On Mysql 5.1 INDEX_COMMENT is not available.

    ext_all_columns="
      TMP.TABLE_NAME,
      TMP.NON_UNIQUE,
      TMP.INDEX_NAME,
      TMP.KEY_COLUMNS,
      TMP.INDEX_TYPE,
      TMP.COMMENT,
      TMP.INDEX_COMMENT
    "
  else

    # TODO: Currently replace only KCU table.
    ext_custom_column=${custom_column//S./TMP.}

  fi

  if [ -n "$idx_types" ] ; then
    if [ x"$idx_types" == x"primary" ] ; then
      andWhere_type="AND S.INDEX_NAME = 'PRIMARY'"
    else
      if [ x"$idx_types" == x"not_primary" ] ; then
        andWhere_type="AND S.INDEX_NAME <> 'PRIMARY'"
      fi
    fi
  fi

  if [ -n "${tname}" ] ; then
    andWhere_name="AND S.TABLE_NAME = '${tname}'"
  fi

  if [ -n "${iname}" ] ; then
    andWhere_iname="AND S.INDEX_NAME = '${iname}'"
  fi

  local cmd="
    SELECT CONCAT_WS('|', ${ext_all_columns} ${ext_custom_column}) AS ANS
    FROM (
      SELECT *
      FROM (
        SELECT ${all_column} ${custom_column}
        FROM  INFORMATION_SCHEMA.STATISTICS S
        WHERE S.TABLE_SCHEMA = '$MARIADB_DB'
        ${andWhere_name}
        ${andWhere_iname}
        ${andWhere_type}
        GROUP BY S.TABLE_NAME, S.INDEX_NAME
        ORDER BY S.TABLE_NAME, S.INDEX_NAME
      ) IDX
      WHERE IDX.INDEX_NAME NOT IN (
            SELECT TC.CONSTRAINT_NAME AS INDEX_NAME
            FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS TC
            WHERE TC.TABLE_SCHEMA = '$MARIADB_DB'
            AND TC.CONSTRAINT_SCHEMA = TC.TABLE_SCHEMA
            AND TC.CONSTRAINT_TYPE = 'FOREIGN KEY'
      )
    ) TMP
  "

  mysql_cmd_4var "_mariadb_ans" "$cmd" || return 1

  return 0
}
# commmons_mariadb_commons_mariadb_get_indexes_list_end

# commmons_mariadb_commons_mariadb_get_tables_list
commons_mariadb_get_tables_list () {

  local all="$1"
  local custom_column="$2"
  local tname="$3"
  local all_column=""
  local andwhere=""

  if [ -n "$all" ] ; then
    all_column=",T.ENGINE,T.TABLE_ROWS,T.DATA_LENGTH,CCSA.CHARACTER_SET_NAME,T.CREATE_TIME,T.UPDATE_TIME"
  fi

  if [ -n "$tname" ] ; then
    andwhere="AND T.TABLE_NAME = '${tname}'"
  fi

  local cmd="
    SELECT T.TABLE_NAME ${all_column} ${custom_column}
    FROM INFORMATION_SCHEMA.TABLES T,
         INFORMATION_SCHEMA.COLLATION_CHARACTER_SET_APPLICABILITY CCSA
    WHERE T.TABLE_SCHEMA = '$MARIADB_DB'
      AND T.TABLE_COLLATION = CCSA.COLLATION_NAME
      ${andwhere}
    ORDER BY TABLE_NAME;"

  mysql_cmd_4var "_mariadb_ans" "$cmd" || return 1

  return 0
}
# commmons_mariadb_commons_mariadb_get_tables_list_end

# commmons_mariadb_commons_mariadb_desc_table
commons_mariadb_desc_table () {

  local tname="$1"
  local custom_column="$2"
  local cname="$3"
  local andwhere=""
  local all_column=""

  if [ -n "$cname" ] ; then
    andWhere="AND COLUMN_NAME = '$cname'"
  fi

  if [ -z "$custom_column" ] ; then
    all_column="CONCAT_WS('|',
       COLUMN_NAME,
       IS_NULLABLE,
       UPPER(COLUMN_TYPE),
       COLUMN_KEY,
       UPPER(EXTRA)) AS C,
       '|' AS S,
       COLUMN_DEFAULT
    "
  fi

  local cmd="
    SELECT ${all_column} ${custom_column}
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = '$MARIADB_DB'
    AND TABLE_NAME = '$tname'
    ${andWhere}
    ORDER BY ORDINAL_POSITION;"

  mysql_cmd_4var "_mariadb_ans" "$cmd" || return 1

  return 0
}
# commmons_mariadb_commons_mariadb_desc_table_end

# commmons_mariadb_commons_mariadb_exist_table
commons_mariadb_exist_table () {

  local tname="$1"
  local result=1

  local cmd="
    SELECT COUNT(1)
    FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_SCHEMA = '$MARIADB_DB'
    AND TABLE_NAME = '$tname'"

  mysql_cmd_4var "MYSQL_OUTPUT" "$cmd" || return 1

  if [ x"$MYSQL_OUTPUT" == x"1" ] ; then
    result=0
  fi

  return $result
}
# commmons_mariadb_commons_mariadb_exist_table_end

# commmons_mariadb_commons_mariadb_exist_event
commons_mariadb_exist_event () {

  local ename="$1"
  local result=1

  local cmd="
    SELECT COUNT(1)
    FROM INFORMATION_SCHEMA.EVENTS
    WHERE EVENT_SCHEMA = '$MARIADB_DB'
    AND EVENT_NAME = '$ename'"

  mysql_cmd_4var "MYSQL_OUTPUT" "$cmd" || return 1

  if [ x"$MYSQL_OUTPUT" == x"1" ] ; then
    result=0
  fi

  return $result
}
# commmons_mariadb_commons_mariadb_exist_event_end

# commmons_mariadb_commons_mariadb_get_procedures_list
commons_mariadb_get_procedures_list () {

  local all=$1
  local all_column=""

  if [ -n "$all" ] ; then
    all_column=",DEFINER, CREATED, LAST_ALTERED"
  fi

  local cmd="
    SELECT ROUTINE_NAME $all_column
    FROM INFORMATION_SCHEMA.ROUTINES
    WHERE ROUTINE_SCHEMA = '$MARIADB_DB'
    AND ROUTINE_TYPE = 'PROCEDURE';"

  mysql_cmd_4var "_mariadb_ans" "$cmd" || return 1

  return 0
}
# commmons_mariadb_commons_mariadb_get_procedures_list_end

# commmons_mariadb_commons_mariadb_get_functions_list
commons_mariadb_get_functions_list () {

  local all=$1
  local all_column=""

  if [ -n "$all" ] ; then
    all_column=",DEFINER, CREATED, LAST_ALTERED"
  fi

  local cmd="
    SELECT ROUTINE_NAME $all_column
    FROM INFORMATION_SCHEMA.ROUTINES
    WHERE ROUTINE_SCHEMA = '$MARIADB_DB'
    AND ROUTINE_TYPE = 'FUNCTION';"

  mysql_cmd_4var "_mariadb_ans" "$cmd" || return 1

  return 0
}
# commmons_mariadb_commons_mariadb_get_functions_list_end

# commmons_mariadb_commons_mariadb_get_events_list
commons_mariadb_get_events_list () {

  local opt=$1
  local ename=$2
  local add_columns=""
  local and_where=""

  if [ -n "$opt" ] ; then
    if [[ "${opt}" == 'all' ]] ; then
      add_columns="
        ,
        DEFINER,
        TIME_ZONE,
        EVENT_TYPE,
        COALESCE(EXECUTE_AT, ''),
        COALESCE(INTERVAL_VALUE, ''),
        COALESCE(INTERVAL_FIELD, ''),
        COALESCE(STARTS, ''),
        COALESCE(ENDS, ''),
        STATUS,
        ON_COMPLETION,
        CREATED,
        LAST_ALTERED,
        COALESCE(LAST_EXECUTED, ''),
        COALESCE(EVENT_COMMENT)
      "
    else
      add_columns="
        ,
        DEFINER,
        TIME_ZONE,
        EVENT_TYPE,
        STATUS,
        CREATED,
        COALESCE(LAST_EXECUTED, '')
      "
    fi
  fi

  if [ -n "${ename}" ] ; then
    and_where="AND EVENT_NAME = '${ename}'"
  fi

  local cmd="
    SELECT CONCAT_WS('|', EVENT_NAME ${add_columns}) AS ANS
    FROM INFORMATION_SCHEMA.EVENTS
    WHERE EVENT_SCHEMA = '$MARIADB_DB'
    ${and_where}
  "

  mysql_cmd_4var "_mariadb_ans" "$cmd" || return 1

  return 0
}
# commmons_mariadb_commons_mariadb_get_events_list_end

# commmons_mariadb_commons_mariadb_get_views_list
commons_mariadb_get_views_list () {

  local cmd="
    SELECT TABLE_NAME, IS_UPDATABLE
    FROM INFORMATION_SCHEMA.VIEWS
    WHERE TABLE_SCHEMA = '$MARIADB_DB';"

  mysql_cmd_4var "_mariadb_ans" "$cmd" || return 1

  return 0
}
# commmons_mariadb_commons_mariadb_get_views_list_end

# commmons_mariadb_commons_mariadb_check_if_exist_trigger
commons_mariadb_check_if_exist_trigger () {

  local result=1
  local name="$1"
  local tname="$2"
  local errmsg="Error on check if exists trigger $name."
  local whereCond=""

  if [ -n "${tname}" ] ; then
    whereCond="AND EVENT_OBJECT_TABLE = '${tname}'"
  fi

  local cmd="
    SELECT COUNT(1) AS CNT
    FROM INFORMATION_SCHEMA.TRIGGERS
    WHERE TRIGGER_SCHEMA = '$MARIADB_DB'
    AND TRIGGER_NAME = '$name' 
    AND ACTION_TIMING IN ('BEFORE', 'AFTER')
    AND EVENT_MANIPULATION IN ('INSERT', 'UPDATE', 'DELETE')
    AND ACTION_STATEMENT IS NOT NULL
    ${whereCond}
  "

  mysql_cmd_4var "MYSQL_OUTPUT" "$cmd" || return $result

  if [ -z "$MYSQL_OUTPUT" ] ; then
    error_generate "$errmsg"
  fi

  if [ x"$MYSQL_OUTPUT" == x"1" ] ; then
    result=0
  fi

  return $result
}
# commmons_mariadb_commons_mariadb_check_if_exist_trigger_end

# commmons_mariadb_commons_mariadb_download_procedure
commons_mariadb_download_procedure () {

  local name="${1/.sql/}"
  name=`basename $name`
  local proceduresdir="${MARIADB_DIR}/procedures"
  local f="$proceduresdir/$name.sql"

  commons_mariadb_check_if_exist_procedure "$name" || error_handled "Procedure $name not found."

  if [ ! -e "$proceduresdir" ] ; then
    mkdir "$proceduresdir"
  fi

  [ -f "$f" ] && rm -f "$f"

  local query="
    SELECT CONCAT('CREATE PROCEDURE \`$name\` (', param_list, ')',
                  CASE R.IS_DETERMINISTIC WHEN 'NO' THEN '' ELSE '\nDETERMINISTIC' END
           ) AS SCRIPT
    FROM mysql.proc M,
         INFORMATION_SCHEMA.ROUTINES R
    WHERE name = '$name' AND db = '$MARIADB_DB'
    AND R.ROUTINE_NAME = name
    AND R.ROUTINE_SCHEMA = db;"

  mysql_cmd_4var "MYSQL_OUTPUT" "$query" || return $result

  if [ -z "$MYSQL_OUTPUT" ] ; then
    error_generate "Error on download procedure params of the procedure $name."
  fi

  query="
    SELECT body
    FROM mysql.proc
    WHERE name = '$name' AND db = '$MARIADB_DB';"

  mysql_cmd_4var "PROCEDURE_BODY" "$query" || return $result

  #escape_var "PROCEDURE_BODY"

  local out="
-- \$Id\$
USE \`DB_NAME\`;
DROP PROCEDURE IF EXISTS \`$name\`;

DELIMITER \$\$
USE \`DB_NAME\`\$\$
$MYSQL_OUTPUT
$PROCEDURE_BODY
"

  unset PROCEDURE_BODY

  echo -en "$out" > $f

  return 0
}
# commmons_mariadb_commons_mariadb_download_procedure_end

# commmons_mariadb_commons_mariadb_download_function
commons_mariadb_download_function () {

  local result=1
  local name="${1/.sql/}"
  name=`basename $name`

  local functionsdir="${MARIADB_DIR}/functions"
  local f="$functionsdir/$name.sql"

  commons_mariadb_check_if_exist_function "$name" || error_handled "Function $name not found."

  if [ ! -e "$functionsdir" ] ; then
    mkdir "$functionsdir"
  fi

  [ -f "$f" ] && rm -f "$f"

  local query="
    SELECT CONCAT('CREATE FUNCTION \`$name\` (', param_list, ') RETURNS ', returns,
                  CASE R.IS_DETERMINISTIC WHEN 'NO' THEN '' ELSE '\nDETERMINISTIC' END
           ) AS SCRIPT
    FROM mysql.proc M,
         INFORMATION_SCHEMA.ROUTINES R
    WHERE name = '$name'
    AND db = '$MARIADB_DB'
    AND R.ROUTINE_NAME = name
    AND R.ROUTINE_SCHEMA = db;"

  mysql_cmd_4var "MYSQL_OUTPUT" "$query" || return $result

  if [ -z "$MYSQL_OUTPUT" ] ; then
    error_generate "Error on download function params of the function $name."
  fi

  query="
    SELECT body
    FROM mysql.proc
    WHERE name = '$name' AND db = '$MARIADB_DB';"

  mysql_cmd_4var "FUNCTION_BODY" "$query" || return $result

  #escape_var "FUNCTION_BODY"

  local out="
-- \$Id\$
USE \`DB_NAME\`;
DROP FUNCTION IF EXISTS \`$name\`;

DELIMITER \$\$
USE \`DB_NAME\`\$\$
$MYSQL_OUTPUT
$FUNCTION_BODY
"

  unset FUNCTION_BODY

  echo -en "$out" > $f

  return 0
}
# commmons_mariadb_commons_mariadb_download_function_end

# commmons_mariadb_commons_mariadb_download_trigger
commons_mariadb_download_trigger () {

  local result=1
  local name="${1/.sql/}"
  name=`basename $name`

  local triggersdir="${MARIADB_DIR}/triggers"
  local f="$triggersdir/$name.sql"

  commons_mariadb_check_if_exist_trigger "$name" || error_handled "Trigger $name not found or not supported."

  if [ ! -e "$triggersdir" ] ; then
    mkdir "$triggersdir"
  fi

  [ -f "$f" ] && rm -f "$f"

  local query="
    SELECT CONCAT('CREATE TRIGGER \`$name\`',
           ACTION_TIMING, ' ', EVENT_MANIPULATION, ' ON \`', EVENT_OBJECT_TABLE,
           '\`\nFOR EACH ROW\n',
           ACTION_STATEMENT, ';')
    FROM INFORMATION_SCHEMA.TRIGGERS
    WHERE TRIGGER_NAME = '$name' AND TRIGGER_SCHEMA = '$MARIADB_DB';"

  mysql_cmd_4var "MYSQL_OUTPUT" "$query" || return $result

  if [ -z "$MYSQL_OUTPUT" ] ; then
    error_generate "Error on download trigger params of the trigger $name."
  fi

  local out="
-- \$Id\$
USE \`DB_NAME\`;
DROP TRIGGER IF EXISTS \`$name\`;

DELIMITER \$\$
USE \`DB_NAME\`\$\$
$MYSQL_OUTPUT
"

  unset MYSQL_BODY

  echo -en "$out" > $f

  return 0
}
# commmons_mariadb_commons_mariadb_download_trigger_end

# commmons_mariadb_commons_mariadb_download_event
commons_mariadb_download_event () {

  local result=1
  local name="${1/.sql/}"
  local with_tz="$2"
  name=`basename $name`

  local eventsdir="${MARIADB_DIR}/schedulers"
  local f="$eventsdir/$name.sql"

  commons_mariadb_exist_event "$name" || error_handled "Event $name not found."

  if [ ! -e "$eventsdir" ] ; then
    mkdir "$eventsdir"
  fi

  [ -f "$f" ] && rm -f "$f"

  # Retrieve event data
  commons_mariadb_get_events_list "all" "${name}" || \
    error_handled "Error on get data of event ${name}."

  local row=$_mariadb_ans
  local def=`echo $row | awk '{split($row,a,"|"); print a[2]}'`
  local tzone=`echo $row | awk '{split($row,a,"|"); print a[3]}'`
  local etype=`echo $row | awk '{split($row,a,"|"); print a[4]}'`
  local exec_at=`echo $row | awk '{split($row,a,"|"); print a[5]}'`
  local int_field=`echo $row | awk '{split($row,a,"|"); print a[7]}'`
  local int_value=`echo $row | awk '{split($row,a,"|"); print a[6]}'`
  local starts=`echo $row | awk '{split($row,a,"|"); print a[8]}'`
  local ends=`echo $row | awk '{split($row,a,"|"); print a[9]}'`
  local status=`echo $row | awk '{split($row,a,"|"); print a[10]}'`
  local on_completion=`echo $row | awk '{split($row,a,"|"); print a[11]}'`
  local comment=`echo $row | awk '{split($row,a,"|"); print a[15]}'`

  [[ $DEBUG && $DEBUG == true ]] && \
    echo -en "(commons_mariadb_download_event: def = '${def}', tzone = '${tzone}', " \
      "etype = '${etype}', exec_at = '${exec_at}', int_field = '${int_field}', " \
      "int_value = '${int_value}', starts = '${starts}', ends = '${ends}', " \
      "status = '${status}', on_completion = '${on_completion}', comment = '${comment}'.\n"


  local query="
    SELECT EVENT_DEFINITION
    FROM INFORMATION_SCHEMA.EVENTS
    WHERE EVENT_NAME = '$name' AND EVENT_SCHEMA = '$MARIADB_DB';"

  mysql_cmd_4var "MYSQL_OUTPUT" "$query" || return $result

  if [ -z "$MYSQL_OUTPUT" ] ; then
    error_generate "Error on download data of the event $name."
  fi

  local at_row=""
  local starts_row=""
  local ends_row=""
  local every_row=""
  local comm_row=""
  local status_row=""
  local on_compl_row=""

  if [ -n "${exec_at}" ] ; then
    at_row="AT '${exec_at}'"
  fi
  if [[ -n "${int_field}" && -n "${int_value}" ]] ; then
    if [ -n "${at_row}" ] ; then
      every_row="\n  EVERY ${int_value} ${int_field}"
    else
      every_row="EVERY ${int_value} ${int_field}"
    fi
  fi
  if [[ -n "${on_completion}" && ${on_completion} != "NOT PRESERVE" ]] ; then
    on_compl_row="\n  ON COMPLETION PRESERVE"
  fi
  if [ -n "${starts}" ] ; then
    starts_row="\n  STARTS '${starts}'"
  fi
  if [ -n "${ends}" ] ; then
    ends_row="\n  ENDS '${ends}'"
  fi
  if [[ -n "${status}" ]] ; then
    if [ "${status}" == "ENABLED" ] ; then
      status_row="ENABLE"
    else
      if [ "${status}" == 'SLAVESIDE_DISABLED' ] ; then
        status_row="DISABLE SLAVE"
      else # DISABLED
        status_row="DISABLE"
      fi
    fi
  fi

  if [[ -n "${comment}" ]] ; then
    comm_row="\n  COMMENT '${comment}'"
  fi

  local set_tz=""
  if [[ -n "${with_tz}" && "${with_tz}" == "1" ]] ; then
    set_tz="SET time_zone = '${tzone}' \$\$"
  fi

  # TODO: check if add IF NOT EXISTS.

  local out="
-- \$Id\$

DELIMITER \$\$
USE \`DB_NAME\`\$\$

${set_tz}
CREATE EVENT
  \`${name}\`
  ON SCHEDULE
  ${at_row}${every_row}${starts_row}${ends_row}${on_compl_row}
  ${status_row}${comm_row}
  DO
    $MYSQL_OUTPUT
  \$\$

DELIMITER ;
"

  unset MYSQL_BODY

  echo -en "$out" > $f

  return 0
}
# commmons_mariadb_commons_mariadb_download_event_end


# commmons_mariadb_commons_mariadb_download_view
commons_mariadb_download_view () {

  local result=1
  local name="${1/.sql/}"
  name=`basename $name`

  local viewsdir="${MARIADB_DIR}/views"
  local f="$viewsdir/$name.sql"

  commons_mariadb_check_if_exist_view "$name" || error_handled "View $name not found or not supported."

  if [ ! -e "$viewsdir" ] ; then
    mkdir "$viewsdir"
  fi

  [ -f "$f" ] && rm -f "$f"

  local query="
    SELECT CONCAT('CREATE OR REPLACE VIEW \`$name\`\nAS ',
           VIEW_DEFINITION,
           ';\n')
    FROM INFORMATION_SCHEMA.VIEWS
    WHERE TABLE_NAME = '$name' AND TABLE_SCHEMA = '$MARIADB_DB';"

  mysql_cmd_4var "MYSQL_OUTPUT" "$query" || return $result

  if [ -z "$MYSQL_OUTPUT" ] ; then
    error_generate "Error on download views data of the view $name."
  fi

  local out="
-- \$Id\$
$MYSQL_OUTPUT
"

  unset MYSQL_BODY

  echo -en "$out" > $f

  return 0
}
# commmons_mariadb_commons_mariadb_download_view_end

# commmons_mariadb_commons_mariadb_download_all_views
commons_mariadb_download_all_views () {

  local n_rec=0
  local name=""
  local i=1

  commons_mariadb_count_views
  n_rec=$?

  if [ $n_rec -gt 0 ] ; then

    commons_mariadb_get_views_list || error_handled "Error on get views name list."

    IFS=$'\n'
    for row in $_mariadb_ans ; do

      name=`echo $row | awk '{split($0,a," "); print a[1]}'`

      unset IFS
      commons_mariadb_download_view "$name"
      if [ $? -ne 0 ] ; then
        echo -en "Error on download view $name ($i of $n_rec).\n"
      else
        echo -en "Download view $name ($i of $n_rec).\n"
      fi
      let i++
      IFS=$'\n'

    done
    unset IFS


  fi

  return 0
}
# commmons_mariadb_commons_mariadb_download_all_views_end

# commmons_mariadb_commons_mariadb_download_all_procedures
commons_mariadb_download_all_procedures () {

  local n_rec=0
  local i=1

  commons_mariadb_count_procedures
  n_rec=$?

  if [ $n_rec -gt 0 ] ; then

    commons_mariadb_get_procedures_list || error_handled "Error on get procedures name list."

    IFS=$'\n'
    for row in $_mariadb_ans ; do

      unset IFS
      commons_mariadb_download_procedure "$row"
      if [ $? -ne 0 ] ; then
        echo -en "Error on download procedure $row ($i of $n_rec).\n"
      else
        echo -en "Download procedure $row correctly ($i of $n_rec).\n"
      fi
      let i++
      IFS=$'\n'

    done
    unset IFS

  fi

  return 0
}
# commmons_mariadb_commons_mariadb_download_all_procedures_end

# commmons_mariadb_commons_mariadb_download_all_functions
commons_mariadb_download_all_functions () {

  local n_rec=0
  local i=1

  commons_mariadb_count_functions
  n_rec=$?

  if [ $n_rec -gt 0 ] ; then

    commons_mariadb_get_functions_list || error_handled "Error on get functions name list."

    IFS=$'\n'
    for row in $_mariadb_ans ; do

      unset IFS
      commons_mariadb_download_function "$row"
      if [ $? -ne 0 ] ; then
        echo -en "Error on download function $row ($i of $n_rec).\n"
      else
        echo -en "Download function $row correctly ($i of $n_rec).\n"
      fi
      let i++
      IFS=$'\n'

    done
    unset IFS

  fi

  return 0
}
# commmons_mariadb_commons_mariadb_download_all_functions_end

# commmons_mariadb_commons_mariadb_download_all_triggers
commons_mariadb_download_all_triggers () {

  local n_rec=0
  local name=""
  local i=1

  commons_mariadb_count_triggers
  n_rec=$?

  [[ $DEBUG && $DEBUG == true ]] && echo -en "(_commons_mariadb_count_triggers: Found $n_rec triggers.\n"

  if [ $n_rec -gt 0 ] ; then

    commons_mariadb_get_triggers_list || error_handled "Error on get triggers name list."

    IFS=$'\n'
    for row in $_mariadb_ans ; do

      name=`echo $row | awk '{split($0,a," "); print a[1]}'`

      unset IFS
      commons_mariadb_download_trigger "$name"
      if [ $? -ne 0 ] ; then
        echo -en "Error on download trigger $name ($i of $n_rec).\n"
      else
        echo -en "Download trigger $name ($i of $n_rec).\n"
      fi
      let i++
      IFS=$'\n'

    done
    unset IFS

  fi

  return 0
}
# commmons_mariadb_commons_mariadb_download_all_triggers_end

# commmons_mariadb_commons_mariadb_download_all_events
commons_mariadb_download_all_events () {

  local n_rec=0
  local name=""
  local i=1
  local with_tz="$1"

  commons_mariadb_count_events
  n_rec=$?

  [[ $DEBUG && $DEBUG == true ]] && \
    echo -en "(_commons_mariadb_download_all_events: Found $n_rec events.\n"

  if [ $n_rec -gt 0 ] ; then

    commons_mariadb_get_events_list "view" || error_handled "Error on get events name list."

    IFS=$'\n'
    for row in $_mariadb_ans ; do

      name=`echo $row | awk '{split($0,a,"|"); print a[1]}'`

      unset IFS
      commons_mariadb_download_event "$name" "${with_tz}"
      if [ $? -ne 0 ] ; then
        echo -en "Error on download event $name ($i of $n_rec).\n"
      else
        echo -en "Download event $name ($i of $n_rec).\n"
      fi
      let i++
      IFS=$'\n'

    done
    unset IFS

  fi

  return 0
}
# commmons_mariadb_commons_mariadb_download_all_events_end

# commmons_mariadb_commons_mariadb_download_fkey
commons_mariadb_download_fkey () {

  local name="${1/.sql/}"
  local table="${2}"
  name=`basename $name`
  local fkeysdir="${MARIADB_DIR}/foreign_keys"
  local f=""
  local cname=""
  local rtable=""
  local rcname=""
  local ur=""
  local dr=""
  local on_delete=""
  local on_update=""
  local res=""

  commons_mariadb_check_if_exist_fkey "$name" "${table}"
  res=$?
  assertNot "$res" "2" "No table name supply and found more of one foreign key with name ${name}. Set table name."
  assertNot "$res" "1" "Foreign key ${name} not found."

  if [ ! -e "$fkeysdir" ] ; then
    mkdir "$fkeysdir"
  fi

  # Retrieve data about foreign key
  commons_mariadb_get_fkeys_list "1" "" "$name" "${table}" || \
    error_handled "Error on retrieve data about foreign key $name."

  table=`echo $_mariadb_ans | awk '{split($0,a,"|"); print a[2]}'`
  cname=`echo $_mariadb_ans | awk '{split($0,a,"|"); print a[3]}'`
  rtable=`echo $_mariadb_ans | awk '{split($0,a,"|"); print a[4]}'`
  rcname=`echo $_mariadb_ans | awk '{split($0,a,"|"); print a[5]}'`
  ur=`echo $_mariadb_ans | awk '{split($0,a,"|"); print a[6]}'`
  dr=`echo $_mariadb_ans | awk '{split($0,a,"|"); print a[7]}'`

  if [ x"${dr}" != x"RESTRICT" ] ; then
    on_delete="ON DELETE ${dr}"
  fi

  if [ x"${ur}" != x"RESTRICT" ] ; then
    on_update="ON UPDATE ${dr}"
  fi

  # TODO: Check if create a [index_name] field automatically
  #       See: http://dev.mysql.com/doc/refman/5.6/en/create-table-foreign-keys.html
  local out="
-- \$Id\$ --
USE \`DB_NAME\`;
ALTER TABLE \`${table}\`
  ADD CONSTRAINT \`${name}\`
  FOREIGN KEY
    (${cname})
  REFERENCES \`${rtable}\`
    (${rcname})
  ${on_delete}
  ${on_update}
  ;
"

  f="${fkeysdir}/${table}-${name}.sql"
  [ -f "$f" ] && rm -f "$f"

  echo -en "$out" > $f

  return 0
}
# commmons_mariadb_commons_mariadb_download_fkey_end

# commmons_mariadb_commons_mariadb_download_all_fkeys
commons_mariadb_download_all_fkeys () {

  local n_rec=0
  local name=""
  local tname=""
  local i=1

  commons_mariadb_count_fkeys
  n_rec=$?

  [[ $DEBUG && $DEBUG == true ]] && echo -en "(commons_mariadb_download_all_fkeys: Found $n_rec foreign keys.\n"

  if [ $n_rec -gt 0 ] ; then

    commons_mariadb_get_fkeys_list "" "KCU.CONSTRAINT_NAME, KCU.TABLE_NAME" || \
      error_handled "Error on get foreign key name list."

    IFS=$'\n'
    for row in $_mariadb_ans ; do

      name=`echo $row | awk '{split($0,a,"|"); print a[1]}'`
      tname=`echo $row | awk '{split($0,a,"|"); print a[2]}'`

      unset IFS
      commons_mariadb_download_fkey "$name" "${tname}"
      if [ $? -ne 0 ] ; then
        echo -en "Error on download foreign key $name of table ${tname} ($i of $n_rec).\n"
      else
        echo -en "Download foreign key $name of table ${tname} ($i of $n_rec).\n"
      fi
      let i++
      IFS=$'\n'

    done
    unset IFS

  fi

  return 0
}
# commmons_mariadb_commons_mariadb_download_all_fkeys_end

# commmons_mariadb_commons_mariadb_drop_fkey
commons_mariadb_drop_fkey () {

  local is_present=1
  local name="$1"
  local avoid_warn="$2"
  local fk_tname=""
  local fk=""
  local tname="$3"
  local cmd=""

  _logfile_write "(mariadb) Start drop foreign key: $name" || return 1

  # Try to check if is present table name from filename
  fktname=$(echo $name | awk 'match($0, /[a-zA-Z]+/) { print substr($0, RSTART, RLENGTH ) }')
  fk=$(echo $name | awk 'match($0, /[-]/) { print substr($0, RSTART + 1) }')

  if [ -z "${tname}" ] ; then

    [ -n "${fktname}" ] && tname="${fktname}"

  elif [[ -n "${tname}" && -n "${fk}" ]] ; then
    # POST: fk_str contains both fk key name and fk key table.
    #       I check if tname in input is equal to fktname (string catch from fr_str)
    if [ "${tname}" != "${fktname}" ] ; then
      _logfile_write "(mariadb) WARNING: Foreign key ${name} is not related with table ${tname}." || return 1

      fk="${name}"
      # error_generate "Foreign key ${name} is not related with table ${tname}."
    fi
  fi

  [ -z "${fk}" ] && fk="${name}"

  commons_mariadb_check_if_exist_fkey "$fk" "${tname}"
  is_present=$?

  # If fktname is empty and fk_table is not available and foreign key is present
  # I try to retrieve table name
  if [[ -z "${tname}" && $fk_is_present -eq 0 ]] ; then

    commons_mariadb_get_fkeys_list "" "KCU.CONSTRAINT_NAME, KCU.TABLE_NAME" "${fk}" || \
      error_handled "Error on get data of foreign key $fk."

    tname=`echo $_mariadb_ans | awk '{split($0,a,"|"); print a[2]}'`
  fi

  [[ $DEBUG && $DEBUG == true ]] && \
    echo -en "(commons_mariadb_drop: Dropping foreign key $fk of table ${tname} (is_present = $is_present).\n"

  if [ $is_present -eq 0 ] ; then

    cmd="
      USE \`${MARIADB_DB}\` ;
      ALTER TABLE \`${tname}\`
        DROP FOREIGN KEY \`${name}\`
    "

    mysql_cmd_4var "MYSQL_OUTPUT" "$cmd"
    local ans=$?

    _logfile_write "Result = $ans\n$MYSQL_OUTPUT" || return 1

  elif [ $is_present -eq 2 ] ; then

    _logfile_write \
      "Table name not set and found more of one foreign key with name ${name}.\nSet table name and try again." || return 1

  else

    if [ -z "$avoid_warn" ] ; then
      _logfile_write "\nWARNING: Foreign key $name not present." || return 1
    fi

  fi

  _logfile_write "(mariadb) End drop foreign key: $name" || return 1

  return 0
}
# commmons_mariadb_commons_mariadb_drop_fkey_end


# commmons_mariadb_commons_mariadb_download_index
commons_mariadb_download_index () {

  local name="${1/.sql/}"
  local tname="${2}"
  name=`basename $name`
  local indexesdir="${MARIADB_DIR}/indexes"
  local f="${indexesdir}/${tname}-${name}.sql"
  local table=""
  local not_unique=""
  local keys=""
  local itype=""
  local comment=""
  local icomment=""
  local iname=""
  local out=""

  commons_mariadb_check_if_exist_index "$name" "${tname}" || \
    error_handled "Index key $name on table ${tname} not found."

  if [ ! -e "${indexesdir}" ] ; then
    mkdir "${indexesdir}"
  fi

  [ -f "$f" ] && rm -f "$f"

  # Retrieve data about index key
  commons_mariadb_get_indexes_list "all" "" "${tname}" "$name" || \
    error_handled "Error on retrieve data about index key $name on table ${tname}."

  # TODO: add support to comment and index comment
  table=`echo $_mariadb_ans | awk '{split($0,a,"|"); print a[1]}'`
  not_unique=`echo $_mariadb_ans | awk '{split($0,a,"|"); print a[2]}'`
  iname=`echo $_mariadb_ans | awk '{split($0,a,"|"); print a[3]}'`
  keys=`echo $_mariadb_ans | awk '{split($0,a,"|"); print a[4]}'`
  itype=`echo $_mariadb_ans | awk '{split($0,a,"|"); print a[5]}'`

  if [ "${iname}" == 'PRIMARY' ] ; then

    # TODO: check if customize index_name
    #       See http://dev.mysql.com/doc/refman/5.6/en/alter-table.html
    out="
-- \$Id\$
USE \`DB_NAME\`;
ALTER TABLE \`${table}\`
  ADD PRIMARY KEY
    (${keys})
;
"

  else

    local itype_string=""

    if [ "${not_unique}" == "0" ] ; then
      itype_string="UNIQUE"
    else

      if [[ "${itype}" == 'FULLTEXT' || "${itype}" == 'SPATIAL' ]] ; then
        itype_string="${itype}"
      fi

    fi

    out="
-- \$Id\$
USE \`DB_NAME\`;
ALTER TABLE \`${table}\`
  ADD ${itype_string} INDEX \`${name}\`
    (${keys})
;
"

  fi

  echo -en "$out" > $f

  return 0
}
# commmons_mariadb_commons_mariadb_download_index_end

# commmons_mariadb_commons_mariadb_download_all_indexes
commons_mariadb_download_all_indexes () {

  local with_pk="$1"
  local n_rec=0
  local tname=""
  local iname=""
  local i=1
  local itypes="not_primary"

  if [ -n "${with_pk}" ] ; then
    itypes="all"
  fi

  commons_mariadb_count_indexes "" "${itypes}"
  n_rec=$?

  [[ $DEBUG && $DEBUG == true ]] && echo -en "(commons_mariadb_download_all_indexes: Found $n_rec indexes.\n"

  if [ $n_rec -gt 0 ] ; then

    commons_mariadb_get_indexes_list "${itypes}" "S.TABLE_NAME,S.INDEX_NAME" || \
      error_handled "Error on get indexes name list."

    IFS=$'\n'
    for row in $_mariadb_ans ; do

      tname=`echo $row | awk '{split($0,a,"|"); print a[1]}'`
      iname=`echo $row | awk '{split($0,a,"|"); print a[2]}'`

      unset IFS
      commons_mariadb_download_index "${iname}" "${tname}"
      if [ $? -ne 0 ] ; then
        echo -en "Error on download data of index $iname of table ${tname} ($i of $n_rec).\n"
      else
        echo -en "Download index $iname of table ${tname} ($i of $n_rec).\n"
      fi
      let i++
      IFS=$'\n'

    done
    unset IFS

  fi

  return 0
}
# commmons_mariadb_commons_mariadb_download_all_indexes_end

# commmons_mariadb_commons_mariadb_drop_index
commons_mariadb_drop_index () {

  local is_present=1
  local name="$1"
  local tname="$2"
  local avoid_warn="$3"
  local cmd=""
  local keys=""
  local extra=""
  local ctype=""
  local is_nullable=""
  local null=""

  _logfile_write "(mariadb) Start drop index: $name (table ${tname}) " || return 1

  commons_mariadb_check_if_exist_index "${name}" "${tname}"
  is_present=$?

  [[ $DEBUG && $DEBUG == true ]] && \
    echo -en "(commons_mariadb_drop: Dropping index $name from table ${tname} (is_present = $is_present).\n"

  if [ $is_present -eq 0 ] ; then

    if [ "${name}" == 'PRIMARY' ] ; then

      commons_mariadb_get_indexes_list "all" "" "${tname}" "${name}" || \
        error_handled "Error on get index data."

      keys=`echo $_mariadb_ans | awk '{split($0,a,"|"); print a[4]}' | tr "," " "`
      karr=($keys)

      for k in ${!karr[@]} ; do

        commons_mariadb_desc_table "${tname}" "UPPER(COLUMN_TYPE),IS_NULLABLE,UPPER(EXTRA)" "${karr[$k]}" || \
          error_handled "Error on get column data of column ${arr[$k]}."

        ctype=`echo $_mariadb_ans | awk '{split($0,a," "); print a[1]}'`
        is_nullable=`echo $_mariadb_ans | awk '{split($0,a," "); print a[2]}'`
        extra=`echo $_mariadb_ans | awk '{split($0,a," "); print a[3]}'`

        if [ "$extra" == 'AUTO_INCREMENT' ] ; then

          _logfile_write "(mariadb) Modify column ${karr[$k]} for remove AUTO_INCREMENT and permit drop of primary key." || return 1

          if [ "$is_nullable" == 'NO' ] ; then
            null="NOT NULL"
          else
            null="NULL"
          fi

          cmd="
            USE \`${MARIADB_DB}\` ;
            ALTER TABLE \`${tname}\`
            CHANGE \`${karr[$k]}\` \`${karr[$k]}\` ${ctype} ${null}
          "

          mysql_cmd_4var "MYSQL_OUTPUT" "$cmd" || \
            error_handled "Error on remove AUTO_INCREMENT from column ${karr[$k]} of table ${tname}."

        fi

      done # end for k ..

      # Check if keys contains AUTO_INCREMENT column.

      cmd="
        USE \`${MARIADB_DB}\` ;
        ALTER TABLE \`${tname}\`
          DROP PRIMARY KEY
      "
    else
      cmd="
        USE \`${MARIADB_DB}\` ;
        ALTER TABLE \`${tname}\`
          DROP INDEX \`${name}\`
      "
    fi

    mysql_cmd_4var "MYSQL_OUTPUT" "$cmd"
    local ans=$?

    _logfile_write "Result = $ans\n$MYSQL_OUTPUT" || return 1

  else

    if [ -z "$avoid_warn" ] ; then
      _logfile_write "\nWARNING: Index $name on table ${tname} not present." || return 1
    fi

  fi

  _logfile_write "(mariadb) End drop index: $name (table ${tname})" || return 1

  return 0
}
# commmons_mariadb_commons_mariadb_drop_index_end

# commmons_mariadb_commons_mariadb_create_fkey_file
commons_mariadb_create_fkey_file () {

  local name="$1"
  local table="$2"
  local cname="$3"
  local rtable="$4"
  local rcname="$5"
  local is_present=1
  local content=""
  local fkeysdir="${MARIADB_DIR}/foreign_keys"
  local f="${fkeysdir}/${table}-${name}.sql"

  # Check if exists foreign_keys or create it
  if [[ ! -d ${fkeysdir} ]] ; then
    mkdir -p ${fkeysdir} || error_generate "Error on create directory ${fkeysdir}."
  fi

  commons_mariadb_check_if_exist_fkey "${name}"
  is_present=$?

  if [ $is_present -eq 0 ] ; then
    error_generate "A foreign key with name ${name} is already present."
  fi

  content="
-- \$Id\$ --
USE \`DB_NAME\`;
ALTER TABLE \`${table}\`
  ADD CONSTRAINT \`${name}\`
  FOREIGN KEY
    (${cname})
  REFERENCES \`${rtable}\`
    (${rcname})
    ;
"

  echo -en "$content" > $f || error_generate "Error on write file $f."

  _logfile_write "(mariadb) Create foreign key $name (file ${f})" || return 1

  return 0
}
# commmons_mariadb_commons_mariadb_create_fkey_file_end

# commmons_mariadb_commons_mariadb_create_index_file
commons_mariadb_create_index_file () {

  local name="$1"
  local table="$2"
  local keys="$3"
  local itype="$4"
  local content=""
  local indexesdir="${MARIADB_DIR}/indexes"
  local f="${indexesdir}/${table}-${name}.sql"

  # Check if exists indexes or create it
  if [[ ! -d ${indexesdir} ]] ; then
    mkdir -p ${indexesdir} || error_generate "Error on create directory ${indexesdir}."
  fi

  commons_mariadb_check_if_exist_index "${name}" "${table}"
  is_present=$?

  if [ $is_present -eq 0 ] ; then
    error_generate "An index with name ${name} on table ${table} is already present."
  fi

  content="
-- \$Id\$ --
USE \`DB_NAME\`;
ALTER TABLE \`${table}\`
  ADD ${itype} INDEX \`${name}\`
    (${keys})
    ;
"

  echo -en "$content" > $f || error_generate "Error on write file $f."

  _logfile_write "(mariadb) Create index ${name} on table ${table} (file ${f})" || \
    return 1

  return 0
}
# commmons_mariadb_commons_mariadb_create_index_file_end

# commmons_mariadb_commons_mariadb_get_table_def
commons_mariadb_get_table_def () {

  local tname="$1"
  local def="CREATE TABLE IF NOT EXISTS \`${tname}\` (\n"
  local row_cname=""
  local row_is_nullable=""
  local row_ctype=""
  local row_ckey=""
  local row_cextra=""
  local row_default=""
  local cname=""
  local is_nullable=""
  local ctype=""
  local cextra=""
  local default=""
  local counter=0
  local min_col_size=19
  local pre_spaces=4
  local engine=""
  local charset=""
  local has_pk=0

  commons_mariadb_exist_table "$tname"
  is_present=$?

  if [ $is_present -eq 1 ] ; then
    return 1
  fi

  commons_mariadb_desc_table "$tname" || return 1

  IFS=$'\n'
  for row in $_mariadb_ans ; do

    row_name[${counter}]=`echo $row | awk '{split($0,a,"|"); print a[1]}'`
    row_is_nullable[${counter}]=`echo $row | awk '{split($0,a,"|"); print a[2]}'`
    row_ctype[${counter}]=`echo $row | awk '{split($0,a,"|"); print a[3]}'`
    row_ckey[${counter}]=`echo $row | awk '{split($0,a,"|"); print a[4]}'`
    row_cextra[${counter}]=`echo $row | awk '{split($0,a,"|"); print a[5]}' | xargs`
    row_default[${counter}]=`echo $row | awk '{split($0,a,"|"); print a[6]}' | xargs`

    if [ ${#row_name[${counter}]} -ge $min_col_size ] ; then
      min_col_size=$((${#row_name[${counter}]}+1))
    fi

    let counter++

  done
  unset IFS

  # Check if is present a primary key
  commons_mariadb_count_indexes "${tname}" "primary"
  has_pk=$?

  for row_id in ${!row_name[@]} ; do

    let counter--

    cname="${row_name[${row_id}]}"
    is_nullable="${row_is_nullable[${row_id}]}"
    ctype="${row_ctype[${row_id}]}"
    ckey="${row_ctype[${row_id}]}"
    cextra="${row_cextra[${row_id}]}"
    default="${row_default[${row_id}]}"

    local cname_str=""

    get_space_str "cname_str" "${min_col_size}" "${cname}" "${pre_spaces}"
    def="${def}${cname_str} ${ctype}"

    # Set NOT NULL section if column is not nullable
    if [ "${is_nullable}" == "NO" ] ; then
      def="${def} NOT NULL"
    fi

    # Set default section
    if [ "${default}" != "NULL" ] ; then
      if [ "${default}" == "CURRENT_TIMESTAMP" ] ; then
        def="${def} DEFAULT ${default}"
      else
        def="${def} DEFAULT '${default}'"
      fi
    fi

    if [ -n "${cextra}" ] ; then
      def="${def} ${cextra}"
    fi

    if [ $counter -gt 0 ] ; then
      def="${def},\n"
    else
      def="${def}"
    fi

    # Clean field values
    row_name[${row_id}]=""
    row_is_nullable[${row_id}]=""
    row_ctype[${row_id}]=""
    row_ckey[${row_id}]=""
    row_cextra[${row_id}]=""
    row_default[${row_id}]=""

  done

  # Add primary key
  if [ $has_pk -eq 1 ] ; then

    def="${def},\n"
    commons_mariadb_get_indexes_list "primary" "" "${tname}"
    local keys=`echo $_mariadb_ans | awk '{split($0,a,"|"); print a[4]}'`
    local pkey=""

    get_space_str "pkey" "0" "" "${pre_spaces}"
    pkey="${pkey}PRIMARY KEY(${keys})"

    def="${def}${pkey}\n"
  else
    def="${def}\n"
  fi

  # Add close round bracket and engine
  commons_mariadb_get_tables_list "1" "" "${tname}" || \
    error_handled "Error on retrieve table data"
  engine=`echo $_mariadb_ans | awk '{split($0,a," "); print a[2]}'`
  charset=`echo $_mariadb_ans | awk '{split($0,a," "); print a[5]}'`

  def="${def}) ENGINE=${engine} DEFAULT CHARSET=${charset};\n"

  TABLE_DEF="${def}"

  unset row_name
  unset row_is_nullable
  unset row_ctype
  unset row_ckey
  unset row_cextra
  unset row_default

  return 0
}
# commmons_mariadb_commons_mariadb_get_table_def_end

# commmons_mariadb_commons_mariadb_download_all_tables
commons_mariadb_download_all_tables () {

  local f="$1"
  local tname="$2"
  local is_present=0
  local n_tables=0
  local out=""
  local counter=0
  local tname_list=""
  local name=""
  local tb_added=0
  local file_exists=false
  local table_is_present=0

  [[ -z "$f" ]] && return 1

  # Check if file exists
  if [[ -f "$f" ]] ; then
    file_exists=true
  fi

  # Check if directory must be created
  if [[ ! -d "$(dirname ${f})" ]] ; then
    # Try to create directory
    mkdir -p $(dirname ${f}) || error_generate "Error on create directory $(dirname ${f})."
  fi

  [[ $DEBUG && $DEBUG == true ]] && \
    echo -en "(commons_mariadb_download_all_tables: File $f exists: $file_exists.)\n"

  if [[ -z "${tname}" ]] ; then

    commons_mariadb_count_tables
    n_tables=$?

    if [ "$n_tables" -eq 0 ] ; then

      echo -en "No tables available.\n"

    else

      commons_mariadb_get_tables_list "1" || \
        error_handled "Error on retrieve list of tables."

      IFS=$'\n'
      for row in $_mariadb_ans ; do

        tname_list[${counter}]=`echo $row | awk '{split($0,a," "); print a[1]}'`

        let counter++

      done
      unset IFS

      for t_id in ${!tname_list[@]} ; do

        name="${tname_list[${t_id}]}"
        [[ $DEBUG && $DEBUG == true ]] && echo -en "Table $t_id: ${name}.\n"

        if [[ $file_exists && $file_exists == true ]] ; then
          # Check if table definition is already present.

          table_is_present=$(cat $f | grep "CREATE TABLE IF NOT EXISTS \`${name}\`" | wc -l)
          [[ $DEBUG && $DEBUG == true ]] && echo -en "Table ${name} is present: ${table_is_present}."

          if [[ $table_is_present -eq 0 ]] ; then

            commons_mariadb_get_table_def "${name}" || \
              error_handled "Error on retrieve definition of table ${name}."

            out="${out}${TABLE_DEF}\n"

            let tb_added++

          fi

        else

            commons_mariadb_get_table_def "${name}" || \
              error_handled "Error on retrieve definition of table ${name}."

            out="${out}${TABLE_DEF}\n"

            let tb_added++

        fi

      done

      if [[ $file_exists && $file_exists == true ]] ; then

        if [[ $tb_added -eq 0 ]] ; then

          echo -en "All tables are already present on file $f. Nothing to do.\n"

        else

          echo -en "$out" >> $f
          echo -en "Added ${tb_added} tables to file $f.\n"

        fi

      else

        out="
-- \$Id\$ --

${out}"
        echo -en "$out" > $f

      fi

    fi

  else

    commons_mariadb_get_table_def "${tname}" || \
      error_handled "Error on create definition of table ${tname}."

    out="
-- \$Id\$ --

${TABLE_DEF}
"
    echo -en "$out" > $f

  fi

  return 0

}
# commmons_mariadb_commons_mariadb_download_all_tables_end

# commmons_mariadb_commons_mariadb_drop_trigger
commons_mariadb_drop_trigger () {

  local is_present=1
  local name="$1"
  local tname="$2"
  local avoid_warn="$3"
  local cmd=""

  local keys=""
  local extra=""
  local ctype=""
  local is_nullable=""
  local null=""

  _logfile_write "(mariadb) Start drop trigger: $name (table ${tname}) " || return 1

  commons_mariadb_check_if_exist_trigger "${name}" "${tname}"
  is_present=$?

  [[ $DEBUG && $DEBUG == true ]] && \
    echo -en "(commons_mariadb_drop_trigger: Dropping trigger $name from table ${tname} (is_present = $is_present).\n"

  if [ $is_present -eq 0 ] ; then

    cmd="
      USE \`${MARIADB_DB}\` ;
      DROP TRIGGER \`${name}\`
    "
    mysql_cmd_4var "MYSQL_OUTPUT" "$cmd"
    local ans=$?

    _logfile_write "Result = $ans\n$MYSQL_OUTPUT" || return 1

  else

    if [ -z "$avoid_warn" ] ; then
      _logfile_write "\nWARNING: Trigger $name on table ${tname} not present." || return 1
    fi

  fi

  _logfile_write "(mariadb) End drop trigger: $name (table ${tname})" || return 1

  return 0
}
# commmons_mariadb_commons_mariadb_drop_trigger_end

# commmons_mariadb_commons_mariadb_drop_event
commons_mariadb_drop_event () {

  local is_present=1
  local ename="$1"
  local avoid_warn="$2"
  local cmd=""

  _logfile_write "(mariadb) Start drop event: $ename " || return 1

  commons_mariadb_exist_event "${ename}"
  is_present=$?

  [[ $DEBUG && $DEBUG == true ]] && \
    echo -en "(commons_mariadb_drop_event: Dropping event $ename (is_present = $is_present).\n"

  if [ $is_present -eq 0 ] ; then

    cmd="
      USE \`${MARIADB_DB}\` ;
      DROP EVENT \`${ename}\`
    "
    mysql_cmd_4var "MYSQL_OUTPUT" "$cmd"
    local ans=$?

    _logfile_write "Result = $ans\n$MYSQL_OUTPUT" || return 1

  else

    if [ -z "$avoid_warn" ] ; then
      _logfile_write "\nWARNING: Event $ename is not present." || return 1
    fi

  fi

  _logfile_write "(mariadb) End drop event: $ename." || return 1

  return 0
}
# commmons_mariadb_commons_mariadb_drop_event_end

# commmons_mariadb_commons_mariadb_show_gvars
commons_mariadb_show_gvars () {

  local filter="$1"
  local cmd=""
  local and_where=""

  if [ -n "${filter}" ] ; then
    and_where="
     WHERE LOWER(VARIABLE_NAME)
     LIKE CONCAT('%', LOWER('${filter}'), '%')"
  fi

  local cmd="
    SELECT CONCAT_WS('|', LOWER(VARIABLE_NAME),COALESCE(VARIABLE_VALUE, ''))
    FROM INFORMATION_SCHEMA.GLOBAL_VARIABLES
    ${and_where}
  "

  mysql_cmd_4var "_mariadb_ans" "$cmd" || return 1

  return 0
}
# commmons_mariadb_commons_mariadb_show_gvars_end

# vim: syn=sh filetype=sh
