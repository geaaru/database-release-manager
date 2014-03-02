#!/bin/bash
#------------------------------------------------
# Author(s): Geaaru, geaaru@gmail.com
# $Id$
# License: GPL 2.0
#------------------------------------------------



#****f* commons_mariadb/commons_mariadb_check_client
# FUNCTION
#   Check if mysql client program is present on system.
#   If present MARIADB_CLIENT variable with abs path is set.
# DESCRIPTION
#   Function check if it is set "mysql" variable:
#   * if it is not set then try to find path through 'which' program
#   * if it is set then check if path is correct and program exists.
# RETURN VALUE
#   0 on success
#   1 on error
# SOURCE
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
#****

#****f* commons_mariadb/commons_mariadb_check_connection
# FUNCTION
#   Check connection to database.
# RETURN VALUE
#   0 when connection is ok
#   1 on error
# SOURCE
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
#***

#****f* commons_mariadb/commons_mariadb_compile_file
# FUNCTION
#   Compile file on database.
# DESCRIPTION
#   Output of the compilation is saved on MYSQL_OUTPUT variable.
# INPUTS
#   f        - path of the file to compile
#   msg      - message to insert on logging file relative to input file.
# RETURN VALUE
#   0 on success
#   1 on error
# SEE ALSO
#   mysql_file
# SOURCE
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
#***

#****f* commons_mariadb/commons_mariadb_compile_all_procedures
# FUNCTION
#   Compile all files under MARIADB_DIR/procedures directory.
# INPUTS
#   msg      - message to insert on logging file relative to input file.
# RETURN VALUE
#   0 on success
#   1 on error
# SEE ALSO
#   commons_mariadb_compile_all_from_dir
# SOURCE
commons_mariadb_compile_all_procedures () {

  local msg="$1"
  local directory="$MARIADB_DIR/procedures"

  commons_mariadb_compile_all_from_dir "$directory" "of all procedures" "$msg" || return 1

  return 0
}
#***

#****f* commons_mariadb/commons_mariadb_compile_all_triggers
# FUNCTION
#   Compile all files under MARIADB_DIR/triggers directory.
# INPUTS
#   msg      - message to insert on logging file relative to input file.
# RETURN VALUE
#   0 on success
#   1 on error
# SEE ALSO
#   commons_mariadb_compile_all_from_dir
# SOURCE
commons_mariadb_compile_all_triggers () {

  local msg="$1"
  local directory="$MARIADB_DIR/triggers"

  commons_mariadb_compile_all_from_dir "$directory" "of all triggers" "$msg" || return 1

  return 0
}
#***

#****f* commons_mariadb/commons_mariadb_compile_all_functions
# FUNCTION
#   Compile all files under MARIADB_DIR/functions directory.
# INPUTS
#   msg      - message to insert on logging file relative to input file.
# RETURN VALUE
#   0 on success
#   1 on error
# SEE ALSO
#   commons_mariadb_compile_all_from_dir
# SOURCE
commons_mariadb_compile_all_functions () {

  local msg="$1"
  local directory="$MARIADB_DIR/functions"

  commons_mariadb_compile_all_from_dir "$directory" "of all functions" "$msg" || return 1

  return 0
}
#***

#****f* commons_mariadb/commons_mariadb_compile_all_views
# FUNCTION
#   Compile all files under MARIADB_DIR/views directory.
# INPUTS
#   msg      - message to insert on logging file relative to input file.
# RETURN VALUE
#   0 on success
#   1 on error
# SEE ALSO
#   commons_mariadb_compile_all_from_dir
# SOURCE
commons_mariadb_compile_all_views () {

  local msg="$1"
  local directory="$MARIADB_DIR/views"

  commons_mariadb_compile_all_from_dir "$directory" "of all views" "$msg" || return 1

  return 0
}
#***

#****f* commons_mariadb/commons_mariadb_compile_all_from_dir
# FUNCTION
#   Compile all files from input directory with .sql extension.
# INPUTS
#   directory   - Directory where there are files to compile.
#   msg_head    - Title message insert on logfile before compile files.
#   msg         - message insert on logfile before compile files.
# RETURN VALUE
#   0 on success
#   1 on error
# SEE ALSO
#   commons_mariadb_compile_file
# SOURCE
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
#***

#****f* commons_mariadb/commons_mariadb_count_procedures
# FUNCTION
#   Count number of procedures present on database.
# RETURN VALUE
#   number of procedures found.
# SEE ALSO
#   mysql_cmd_4var
# SOURCE
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
#***

#****f* commons_mariadb/commons_mariadb_count_functions
# FUNCTION
#   Count number of functions present on schema.
# RETURN VALUE
#   number of functions found on schema.
# SEE ALSO
#   mysql_cmd_4var
# SOURCE
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
#***

#****f* commons_mariadb/commons_mariadb_count_triggers
# FUNCTION
#   Count number of triggers defined on schema.
# RETURN VALUE
#   number of triggers found on schema.
# SEE ALSO
#   mysql_cmd_4var
# SOURCE
commons_mariadb_count_triggers () {

  local cmd="
    SELECT COUNT(1) AS CNT
    FROM INFORMATION_SCHEMA.TRIGGERS
    WHERE TRIGGER_SCHEMA = '$MARIADB_DB'
    AND ACTION_TIMING IN ('BEFORE', 'AFTER')
    AND EVENT_MANIPULATION IN ('INSERT', 'UPDATE')
    AND ACTION_STATEMENT IS NOT NULL;"

  mysql_cmd_4var "MYSQL_OUTPUT" "$cmd" || error_handled ""

  if [ -z "$MYSQL_OUTPUT" ] ; then
    error_generate "Error on count triggers."
  fi

  return $MYSQL_OUTPUT
}
#***

#****f* commons_mariadb/commons_mariadb_count_views
# FUNCTION
#   Count number of views present on schema.
# RETURN VALUE
#   Number of views available on schema.
# SEE ALSO
#   mysql_cmd_4var
# SOURCE
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
#***

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

#****f* commmons_mariadb/commons_mariadb_check_if_exist_function
# FUNCTION
#   Check if exists function with name in input on schema.
# RETURN VALUE
#   1 if not exists
#   0 if exists
# SEE ALSO
#   mysql_cmd_4var
# SOURCE
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
#***

#****f* commmons_mariadb/commons_mariadb_check_if_exist_view
# FUNCTION
#   Check if exists view with name in input on schema.
# RETURN VALUE
#   1 if not exists
#   0 if exists
# SEE ALSO
#   mysql_cmd_4var
# SOURCE
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
#***


#****f* commmons_mariadb/commons_mariadb_get_triggers_list
# FUNCTION
#   Save on _mariadb_ans variable list of triggers defined on schema.
# RETURN VALUE
#   1 on error
#   0 on success
# SEE ALSO
#   mysql_cmd_4var
# SOURCE
commons_mariadb_get_triggers_list () {

  local result=1
  local cmd="
    SELECT TRIGGER_NAME, EVENT_OBJECT_TABLE, ACTION_TIMING, EVENT_MANIPULATION
    FROM INFORMATION_SCHEMA.TRIGGERS
    WHERE TRIGGER_SCHEMA = '$MARIADB_DB'
    AND ACTION_TIMING IN ('BEFORE', 'AFTER')
    AND EVENT_MANIPULATION IN ('INSERT', 'UPDATE')
    AND ACTION_STATEMENT IS NOT NULL
    ORDER BY EVENT_OBJECT_TABLE, ACTION_ORDER;"

  mysql_cmd_4var "_mariadb_ans" "$cmd" || return $result

  return 0
}
#***

#****f* commmons_mariadb/commons_mariadb_get_procedures_list
# FUNCTION
#   Save on _mariadb_ans variable list of procedures defined on schema.
# RETURN VALUE
#   1 on error
#   0 on success
# SEE ALSO
#   mysql_cmd_4var
# SOURCE
commons_mariadb_get_procedures_list () {

  local cmd="
    SELECT ROUTINE_NAME
    FROM INFORMATION_SCHEMA.ROUTINES
    WHERE ROUTINE_SCHEMA = '$MARIADB_DB'
    AND ROUTINE_TYPE = 'PROCEDURE';"

  mysql_cmd_4var "_mariadb_ans" "$cmd" || return 1

  return 0
}
#***

#****f* commmons_mariadb/commons_mariadb_get_functions_list
# FUNCTION
#   Save on _mariadb_ans variable list of functions defined on schema.
# RETURN VALUE
#   1 on error
#   0 on success
# SEE ALSO
#   mysql_cmd_4var
# SOURCE
commons_mariadb_get_functions_list () {

  local cmd="
    SELECT ROUTINE_NAME
    FROM INFORMATION_SCHEMA.ROUTINES
    WHERE ROUTINE_SCHEMA = '$MARIADB_DB'
    AND ROUTINE_TYPE = 'FUNCTION';"

  mysql_cmd_4var "_mariadb_ans" "$cmd" || return 1

  return 0
}
#***

#****f* commmons_mariadb/commons_mariadb_get_views_list
# FUNCTION
#   Save on _mariadb_ans variable list of views defined on schema.
# RETURN VALUE
#   1 on error
#   0 on success
# SEE ALSO
#   mysql_cmd_4var
# SOURCE
commons_mariadb_get_views_list () {

  local cmd="
    SELECT TABLE_NAME, IS_UPDATABLE
    FROM INFORMATION_SCHEMA.VIEWS
    WHERE TABLE_SCHEMA = '$MARIADB_DB';"

  mysql_cmd_4var "_mariadb_ans" "$cmd" || return 1

  return 0
}
#***

#****f* commmons_mariadb/commons_mariadb_check_if_exist_trigger
# FUNCTION
#   Check if exists a trigger with name in input on schema.
# RETURN VALUE
#   1 if not exists
#   0 if exists
# SEE ALSO
#   mysql_cmd_4var
# SOURCE
commons_mariadb_check_if_exist_trigger () {

  local result=1
  local name="$1"
  local errmsg="Error on check if exists trigger $name."
  local cmd="
    SELECT COUNT(1) AS CNT
    FROM INFORMATION_SCHEMA.TRIGGERS
    WHERE TRIGGER_SCHEMA = '$MARIADB_DB'
    AND TRIGGER_NAME = '$name' 
    AND ACTION_TIMING IN ('BEFORE', 'AFTER')
    AND EVENT_MANIPULATION IN ('INSERT', 'UPDATE')
    AND ACTION_STATEMENT IS NOT NULL;"

  mysql_cmd_4var "MYSQL_OUTPUT" "$cmd" || return $result

  if [ -z "$MYSQL_OUTPUT" ] ; then
    error_generate "$errmsg"
  fi

  if [ x"$MYSQL_OUTPUT" == x"1" ] ; then
    result=0
  fi

  return $result
}
#***

#****f* commmons_mariadb/commons_mariadb_download_procedure
# FUNCTION
#   Download a procedure to MARIADB_DIR/procedures directory.
# INPUTS
#   name    - name of the procedure to download.
# RETURN VALUE
#   1 on error
#   0 on success
# SEE ALSO
#   commons_mariadb_check_if_exist_procedure
#   mysql_cmd_4var
# SOURCE
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
#***

#****f* commmons_mariadb/commons_mariadb_download_function
# FUNCTION
#   Download a function to MARIADB_DIR/functions directory.
# INPUTS
#   name    - name of the function to download.
# RETURN VALUE
#   1 on error
#   0 on success
# SEE ALSO
#   commons_mariadb_check_if_exist_function
#   mysql_cmd_4var
# SOURCE
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
#***

#****f* commmons_mariadb/commons_mariadb_download_trigger
# FUNCTION
#   Download a trigger to MARIADB_DIR/triggers directory.
# INPUTS
#   name    - name of the trigger to download.
# RETURN VALUE
#   1 on error
#   0 on success
# SEE ALSO
#   commons_mariadb_check_if_exist_trigger
#   mysql_cmd_4var
# SOURCE
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
#***

#****f* commmons_mariadb/commons_mariadb_download_view
# FUNCTION
#   Download a view to MARIADB_DIR/views directory.
# INPUTS
#   name    - name of the view to download.
# RETURN VALUE
#   1 on error
#   0 on success
# SEE ALSO
#   commons_mariadb_check_if_exist_view
#   mysql_cmd_4var
# SOURCE
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
$MYSQL_OUTPUT
"

  unset MYSQL_BODY

  echo -en "$out" > $f

  return 0
}
#***

#****f* commmons_mariadb/commons_mariadb_download_all_views
# FUNCTION
#   Download all views to MARIADB_DIR/views directory.
# RETURN VALUE
#   1 on error
#   0 on success
# SEE ALSO
#   commons_mariadb_get_views_list
#   mysql_cmd_4var
# SOURCE
commons_mariadb_download_all_views () {

  local n_rec=0
  local name=""

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
      IFS=$'\n'

    done
    unset IFS


  fi

  return 0
}
#***

#****f* commmons_mariadb/commons_mariadb_download_all_procedures
# FUNCTION
#   Download all procedures to MARIADB_DIR/procedures directory.
# RETURN VALUE
#   1 on error
#   0 on success
# SEE ALSO
#   commons_mariadb_get_procedures_list
#   commons_mariadb_download_procedure
# SOURCE
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
#***

#****f* commmons_mariadb/commons_mariadb_download_all_functions
# FUNCTION
#   Download all functions to MARIADB_DIR/functions directory.
# RETURN VALUE
#   1 on error
#   0 on success
# SEE ALSO
#   commons_mariadb_get_functions_list
#   commons_mariadb_download_function
# SOURCE
commons_mariadb_download_all_functions () {

  local n_rec=0

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
      IFS=$'\n'

    done
    unset IFS

  fi

  return 0
}
#***

#****f* commmons_mariadb/commons_mariadb_download_all_triggers
# FUNCTION
#   Download all triggers to MARIADB_DIR/triggers directory.
# RETURN VALUE
#   1 on error
#   0 on success
# SEE ALSO
#   commons_mariadb_count_triggers
#   commons_mariadb_download_trigger
# SOURCE
commons_mariadb_download_all_triggers () {

  local n_rec=0
  local name=""

  commons_mariadb_count_triggers
  n_rec=$?

  if [ $n_rec -gt 0 ] ; then

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
      IFS=$'\n'

    done
    unset IFS

  fi

  return 0
}
#***


# vim: syn=sh filetype=sh
