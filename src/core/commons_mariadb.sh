#!/bin/bash
#------------------------------------------------
# Author(s): Geaaru, geaaru@gmail.com
# $Id$
# License: GPL 2.0
#------------------------------------------------



# return 0 on success
# return 1 on error
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

      error_generate "sqlplus program not found"

      return 1

    fi

  else

    # POST: sqlplus variable set

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

# return 0 on when connection is ok
# return 1 on error
commons_mariadb_check_connection () {

  if [ -z "$MARIADB_CLIENT" ] ; then
    return 1
  fi

  if [ -z "$mysql_auth" ] ; then
    return 1
  fi

  [[ $DEBUG && $DEBUG == true ]] && echo -en "(oracle) Try connection with -A $MARIADB_EXTRA_OPTIONS $mysql_auth.\n"

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

# return 1 on error
# return 0 on success
commons_mariadb_compile_file () {

  local f=$1
  local msg=$2

  echo "FILE = $f"

  if [ ! -e $f ] ; then
    _logfile_write "(mariadb) File $f not found." || return 1
    return 1
  fi

  _logfile_write "(mariadb) Start compilation: $msg" || return 1

  echo "(mariadb) Start compilation: $msg"

  MYSQL_OUTPUT=""

  mysql_file "MYSQL_OUTPUT" "$f"
  local ans=$?

  _logfile_write "\n$MYSQL_OUTPUT" || return 1

  _logfile_write "(mariadb) End compilation (result => $ans): $msg" || return 1

  echo -en "(mariadb) End compilation (result => $ans): $msg\n"

  return $ans

}

# return 1 on error
# return 0 on success
commons_mariadb_compile_all_procedures () {

  local msg="$1"
  local directory="$MARIADB_DIR/procedures"

  commons_mariadb_compile_all_from_dir "$directory" "of all procedures" "$msg" || return 1

  return 0
}

commons_mariadb_compile_all_triggers () {

  local msg="$1"
  local directory="$MARIADB_DIR/triggers"

  commons_mariadb_compile_all_from_dir "$directory" "of all triggers" "$msg" || return 1

  return 0
}

commons_mariadb_compile_all_functions () {

  local msg="$1"
  local directory="$MARIADB_DIR/functions"

  commons_mariadb_compile_all_from_dir "$directory" "of all functions" "$msg" || return 1

  return 0
}


commons_mariadb_compile_all_views () {

  local msg="$1"
  local directory="$MARIADB_DIR/views"

  commons_mariadb_compile_all_from_dir "$directory" "of all views" "$msg" || return 1

  return 0
}

# return 1 on error
# return 0 on success
commons_mariadb_compile_all_from_dir () {

  local directory="$1"
  local msg_head="$2"
  local msg="$3"
  local f=""
  local fb=""
  local ex_f=""
  local exc=0

  _logfile_write "(mariadb) Start compilation $msg_head: $msg" || return 1

  for i in $directory/*.sql ; do

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

    commons_mariadb_compile_file "$i" "$msg"
    # POST: on error go to next file


  done # end for

  _logfile_write "(mariadb) End compilation $msg_head: $msg" || return 1

  return 0

}

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

commons_mariadb_count_triggers () {

  local cmd="
    SELECT COUNT(1) AS CNT
    FROM INFORMATION_SCHEMA.TRIGGERS
    WHERE TRIGGERS_SCHEMA = '$MARIADB_DB';"

  mysql_cmd_4var "MYSQL_OUTPUT" "$cmd" || error_handled ""

  if [ -z "$MYSQL_OUTPUT" ] ; then
    error_generate "Error on count triggers."
  fi

  return $MYSQL_OUTPUT
}


# return 1 if not exists
# return 0 if exists
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

# return 1 if not exists
# return 0 if exists
commons_mariadb_check_if_exist_function () {

  local result=1
  local name="$1"
  local errmsg="Error on check if exists function $name."
  local cmd="
    SELECT COUNT(1) AS CNT
    FROM INFORMATION_SCHEMA.ROUTINES
    WHERE ROUTINE_SCHEMA = '$MARIADB_DB'
    AND ROUTINE_TYPE = 'FUNCTION'
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


# return 1 if not exists
# return 0 if exists
commons_mariadb_check_if_exist_trigger () {

  local result=1
  local name="$1"
  local errmsg="Error on check if exists trigger $name."
  local cmd="
    SELECT COUNT(1) AS CNT
    FROM INFORMATION_SCHEMA.TRIGGERS
    WHERE TRIGGERS_SCHEMA = '$MARIADB_DB'
    AND TRIGGER_NAME = '$name' ;"

  mysql_cmd_4var "MYSQL_OUTPUT" "$cmd" || return $result

  if [ -z "$MYSQL_OUTPUT" ] ; then
    error_generate "$errmsg"
  fi

  if [ x"$MYSQL_OUTPUT" == x"1" ] ; then
    result=0
  fi

  return $result
}

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
    SELECT CONCAT('CREATE PROCEDURE \`$name\` (', param_list, ')')
    FROM mysql.proc
    WHERE name = '$name' AND db = '$MARIADB_DB';"

  mysql_cmd_4var "MYSQL_OUTPUT" "$query" || return $result

  if [ -z "$MYSQL_OUTPUT" ] ; then
    error_generate "Error on download procedure params of the procedure $name."
  fi

  query="
    SELECT body
    FROM mysql.proc
    WHERE name = '$name' AND db = '$MARIADB_DB';"

  mysql_cmd_4var "PROCEDURE_BODY" "$query" || return $result

  escape_var "PROCEDURE_BODY"

  local out="
USE \`DB_NAME\`;
DROP 'PROCEDURE' IF EXISTS \`$name\`;

DELIMITER \$\$
USE \`DB_NAME\`\$\$
$MYSQL_OUTPUT
$PROCEDURE_BODY"

  unset PROCEDURE_BODY

  echo -en "$out" > $f

  return 0
}

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
    SELECT CONCAT('CREATE FUNCTION \`$name\` (', param_list, ') RETURNS ', returns)
    FROM mysql.proc
    WHERE name = '$name' AND db = '$MARIADB_DB';"

  mysql_cmd_4var "MYSQL_OUTPUT" "$query" || return $result

  if [ -z "$MYSQL_OUTPUT" ] ; then
    error_generate "Error on download function params of the function $name."
  fi

  query="
    SELECT body
    FROM mysql.proc
    WHERE name = '$name' AND db = '$MARIADB_DB';"

  mysql_cmd_4var "FUNCTION_BODY" "$query" || return $result

  escape_var "FUNCTION_BODY"

  local out="
USE \`DB_NAME\`;
DROP 'FUNCTION' IF EXISTS `$name`;

DELIMITER \$\$
USE \`DB_NAME\`\$\$
$MYSQL_OUTPUT
$FUNCTION_BODY"

  unset FUNCTION_BODY

  echo -en "$out" > $f

  return 0
}

commons_mariadb_download_trigger () {

  local result=1
  local name="${1/.sql/}"
  name=`basename $name`

  local triggersdir="${MARIADB_DIR}/triggers"
  local f="$triggersdir/$name.sql"

  commons_mariadb_check_if_exist_trigger "$name" || error_handled "Function $name not found."

  if [ ! -e "$functionsdir" ] ; then
    mkdir "$functionsdir"
  fi

  [ -f "$f" ] && rm -f "$f"

  local query="
    SELECT CONCAT('CREATE FUNCTION \`$name\` (', param_list, ') RETURNS ', returns)
    FROM mysql.proc
    WHERE name = '$name' AND db = '$MARIADB_DB';"

  mysql_cmd_4var "MYSQL_OUTPUT" "$query" || return $result

  if [ -z "$MYSQL_OUTPUT" ] ; then
    error_generate "Error on download trigger params of the trigger $name."
  fi

  query="
    SELECT body
    FROM mysql.proc
    WHERE name = '$name' AND db = '$MARIADB_DB';"

  mysql_cmd_4var "TRIGGER_BODY" "$query" || return $result

  escape_var "TRIGGER_BODY"

  local out="
USE \`DB_NAME\`;
DROP 'FUNCTION' IF EXISTS `$name`;

DELIMITER \$\$
USE \`DB_NAME\`\$\$
$MYSQL_OUTPUT
$TRIGGER_BODY"

  unset TRIGGER_BODY

  echo -en "$out" > $f

  return 0
}


# vim: syn=sh filetype=sh
