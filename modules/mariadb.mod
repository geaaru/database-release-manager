#!/bin/bash
#------------------------------------------------
# Author(s): Geaaru, geaaru@gmail.com
# $Id$
# License: GPL 2.0
#------------------------------------------------

name="mariadb"
mariadb_authors="Geaaru"
mariadb_creation_date="May 6, 2013"
mariadb_version="0.1"
mariadb_status="0"


mariadb_version() {
  echo -en "Version: ${mariadb_version}\n"
  return 0
}

mariadb_long_help () {

   echo -en "===========================================================================\n"
   echo -en "Module [mariadb]:\n"
   echo -en "Author(s): ${mariadb_authors}\n"
   echo -en "Created: ${mariadb_creation_date}\n"
   echo -en "Version: ${mariadb_version}\n"
   echo -en "---------------------------------------------------------------------------\n"
   echo -en "\tlong_help               Show long help informations\n"
   echo -en "\tshow_help               Show command list.\n"
   echo -en "\tversion                 Show module version.\n"
   echo -en "\ttest_connection         Test connection versus database.\n"
   echo -en "\tdownload                Download packages/triggers/views/etc.\n"
   echo -en "\tcompile                 Compile packages/triggers/views/etc.\n"
   echo -en "---------------------------------------------------------------------------\n"
   echo -en "===========================================================================\n"

   return 0
}

mariadb_show_help () {
   echo -en "===========================================================================\n"
   echo -en "Module [mariadb]:\n"
   echo -en "---------------------------------------------------------------------------\n"
   echo -en "\tlong_help               Show long help informations\n"
   echo -en "\tshow_help               Show command list.\n"
   echo -en "\tversion                 Show module version.\n"
   echo -en "\ttest_connection         Test connection versus database.\n"
   echo -en "\tdownload                Download packages/triggers/views/etc.\n"
   echo -en "\tcompile                 Compile packages/triggers/views/etc.\n"
   echo -en "---------------------------------------------------------------------------\n"
   echo -en "===========================================================================\n"

   return 0
}

mariadb_test_connection () {

  local result=1

  # Shift first two input param
  shift 2

  _mariadb_check_status

  _mariadb_help_message="print_help"

  _mariadb_connections_args "$@" || error_handled ""

  mysql_set_auth_var "$MARIADB_DB" "$MARIADB_USER" "$MARIADB_PWD" "$MARIADB_HOST"

  commons_mariadb_check_connection || error_handled "MySQL client was unable to connect to DB with supplied credentials."

  echo -en "Connected to $MARIADB_DB with user $MARIADB_USER correctly.\n"

  return 0
}

mariadb_compile () {

  # Shift first two input param
  shift 2

  _mariadb_check_status

  _mariadb_help_message="print_help"

  _mariadb_connections_args "$@"

  _mariadb_compile_args "$@" || error_handled ""

  mysql_set_auth_var "$MARIADB_DB" "$MARIADB_USER" "$MARIADB_PWD" "$MARIADB_HOST"

  commons_mariadb_check_connection || error_handled "MySQL client was unable to connect to DB with supplied credentials."

  _mariadb_compile || error_handled ""

  echo -en "Compile operation successfull.\n"

  return 0
}

mariadb_download () {

  # Shift first two input param
  shift 2

  _mariadb_check_status

  _mariadb_help_message="print_help"

  _mariadb_connections_args "$@"

  _mariadb_download_args "$@" || error_handled ""

  mysql_set_auth_var "$MARIADB_DB" "$MARIADB_USER" "$MARIADB_PWD" "$MARIADB_HOST"

  commons_mariadb_check_connection || error_handled "MySQL client was unable to connect to DB with supplied credentials."

  _mariadb_download || error_handled ""

  echo -en "Download operation successfull.\n"

  return 0
}

##################################################################
# Internal functions
##################################################################

_mariadb_init () {

  if [[ ! -z "$SQLCA"  && "$SQLCA" =~ .*mariadb.* ]] ; then

    [[ $DEBUG && $DEBUG == true ]] && echo -en "(_mariadb_init: Check requirements of the mariadb module.)\n"

    commons_mariadb_check_client || error_handled ""

    check_var "MARIADB_USER" || error_handled "You must define MARIADB_USER variable on configuration file."
    check_var "MARIADB_PWD"  || error_handled "You must define MARIADB_PWD variable on configuration file."
    check_var "MARIADB_DB"   || error_handled "You must define MARIADB_DB variable on configuration file."
    check_var "MARIADB_DIR"  || error_handled "You must define MARIADB_DIR variable on configuration file."

    if [ -z $MARIADB_TMZ ] ; then
      MARIADB_TMZ='UTC'
    fi

    [[ $DEBUG && $DEBUG == true ]] && echo -en "(_mariadb_init: All requirements are present. Continue my work.)\n"

    mariadb_status="1"

  else

    [[ $DEBUG && $DEBUG == true ]] && echo -en "(_mariadb_init: Nothing to do.)\n"

  fi

  return 0
}

_mariadb_check_status () {

  if [ x"$mariadb_status" = x"0" ] ; then
    error_generate "mariadb is not enable. Enable it with SQLCA variable"
  fi

  return 0
}

_mariadb_connections_args () {

  [[ $DEBUG && $DEBUG == true ]] && echo -en "(_mariadb_connections_args args: $@)\n"

  local short_options="d:U:P:hH:D:t:"
  local long_options="database: timezone: conn-options:"

  set -- `getopt -u -q -o "$short_options" -l "$long_options" -- "$@"` || error_handled "Invalid parameters"

  [ $# -lt 1 ] && return 0 # is there at least one param (--)

  local MARIADB_EXTRAS_ENABLE=0

  while [ $# -gt 0 ] ; do
    case "$1" in

      -U) MARIADB_USER="$2";shift;;
      -P) MARIADB_PWD="$2";shift;;
      -D) MARIADB_DIR="$2";shift;;
      -H) MARIADB_HOST="$2";shift;;
      --database)
        MARIADB_DB="$2"
        shift
        ;;
      --timezone)
        MARIADB_TMZ="$2"
        shift
        ;;
      --conn-options)
        if [ $MARIADB_EXTRAS_ENABLE -eq 0 ] ; then
          MARIADB_EXTRAS_ENABLE=1
          MARIADB_EXTRA_OPTIONS="$2"
        else
          MARIADB_EXTRA_OPTIONS="$MARIADB_EXTRA_OPTIONS $2"
        fi
        shift
        ;;
      -h)
        if [ ! -z "$_mariadb_help_message" ] ; then
          _mariadb_connection_help
        fi
        return 1
        ;;
      *)
        ;;

    esac

    shift

  done

  return 0
}

_mariadb_compile_args () {

  [[ $DEBUG && $DEBUG == true ]] && echo -en "(_mariadb_compile_args args: $@)\n"

  local short_options="d:U:P:hH:D:t:"
  local long_options="database: timezone: conn-options:" # connection long options
  long_options="$long_options all-triggers id-script: file: all-functions all-procedures all-views all trigger: function: view: procedure:"

  set -- `getopt -u -q -a -o "$short_options" -l "$long_options" -- "$@"` || error_handled "Invalid parameters"

  MARIADB_COMPILE_ALL=1

  if [ $# -lt 2 ] ; then # is there at least one param (--)
    _mariadb_compile_help
    return 1
  fi

  [[ $DEBUG && $DEBUG == true ]] && echo -en "(_mariadb_compile_args: Found $# params)\n"

  MARIADB_COMPILE_ALL=0
  MARIADB_COMPILE_ALL_TRIGGERS=0
  MARIADB_COMPILE_ALL_FUNCTIONS=0
  MARIADB_COMPILE_ALL_PROCEDURES=0
  MARIADB_COMPILE_ALL_VIEWS=0
  MARIADB_COMPILE_PROCEDURE=""
  MARIADB_COMPILE_TRIGGER=""
  MARIADB_COMPILE_FUNCTION=""
  MARIADB_COMPILE_VIEW=""
  MARIADB_COMPILE_ID_SCRIPT=""
  MARIADB_COMPILE_FILE=""
  local MARIADB_COMPILE_EXC_RCVD=0

  while [ $# -gt 0 ] ; do
    case "$1" in

      -S|-U|-P|-D|--database|--timezone|--conn-options)
        shift
        # do nothing
        ;;

      --all-procedures)
        MARIADB_COMPILE_ALL_PROCEDURES=1
        ;;
      --all-triggers)
        MARIADB_COMPILE_ALL_TRIGGERS=1
        ;;
      --all-functions)
        MARIADB_COMPILE_ALL_FUNCTIONS=1
        ;;
      --all-views)
        MARIADB_COMPILE_ALL_VIEWS=1
        ;;
      --all)
        MARIADB_COMPILE_ALL=1
        ;;
      --procedure)
        MARIADB_COMPILE_PROCEDURE="$2"
        shift
        ;;
      --trigger)
        MARIADB_COMPILE_TRIGGER="$2"
        shift
        ;;
      --function)
        MARIADB_COMPILE_FUNCTION="$2"
        shift
        ;;
      --view)
        MARIADB_COMPILE_VIEW="$2"
        shift
        ;;
      --id-script)
        MARIADB_COMPILE_ID_SCRIPT="$2"
        shift
        ;;
      --file)
        MARIADB_COMPILE_FILE="$2"
        shift
        ;;
      --exclude)
        if [ $MARIADB_COMPILE_EXC_RCVD -eq 0 ] ; then
          MARIADB_COMPILE_FILES_EXCLUDED="$2"
          MARIADB_COMPILE_EXC_RCVD=1
        else
          MARIADB_COMPILE_FILES_EXCLUDED="$MARIADB_COMPILE_FILES_EXCLUDED $2"
        fi
        shift
        ;;
      -h)
        _mariadb_compile_help
        return 1
        ;;
      --)
        ;;
      *)
        error_generate "Invalid parameter $1."
        ;;

    esac

    shift
  done

  return 0

}

_mariadb_download_args () {

  [[ $DEBUG && $DEBUG == true ]] && echo -en "(_mariadb_download_args args: $@)\n"

  local short_options="d:U:P:hH:D:t:"
  local long_options="database: timezone: conn-options:" # connection long options
  long_options="$long_options all-triggers id-script: file: all-functions all-procedures all-views all trigger: function: view: procedure:"

  set -- `getopt -u -q -a -o "$short_options" -l "$long_options" -- "$@"` || error_handled "Invalid parameters"

  MARIADB_DOWNLOAD_ALL=1

  if [ $# -lt 2 ] ; then # is there at least one param (--)
    echo -en "No params supply. I presume --all param.\n"
    return 0
  fi

  [[ $DEBUG && $DEBUG == true ]] && echo -en "(_mariadb_download_args: Found $# params)\n"

  MARIADB_DOWNLOAD_ALL=0
  MARIADB_DOWNLOAD_ALL_PROCEDURES=0
  MARIADB_DOWNLOAD_ALL_TRIGGERS=0
  MARIADB_DOWNLOAD_ALL_FUNCTIONS=0
  MARIADB_DOWNLOAD_ALL_VIEWS=0
  MARIADB_DOWNLOAD_PROCEDURE=""
  MARIADB_DOWNLOAD_TRIGGER=""
  MARIADB_DOWNLOAD_FUNCTION=""
  MARIADB_DOWNLOAD_VIEW=""

  while [ $# -gt 0 ] ; do
    case "$1" in

      -S|-U|-P|-D)
        shift
        # do nothing
        ;;

      --all-packages)
        MARIADB_DOWNLOAD_ALL_PACKAGES=1
        ;;
      --all-triggers)
        MARIADB_DOWNLOAD_ALL_TRIGGERS=1
        ;;
      --all-functions)
        MARIADB_DOWNLOAD_ALL_FUNCTIONS=1
        ;;
      --all-views)
        MARIADB_DOWNLOAD_ALL_VIEWS=1
        ;;
      --all)
        MARIADB_DOWNLOAD_ALL=1
        ;;
      --procedure)
        MARIADB_DOWNLOAD_PROCEDURE="$2"
        shift
        ;;
      --trigger)
        MARIADB_DOWNLOAD_TRIGGER="$2"
        shift
        ;;
      --function)
        MARIADB_DOWNLOAD_FUNCTION="$2"
        shift
        ;;
      --view)
        MARIADB_DOWNLOAD_VIEW="$2"
        shift
        ;;

      -h)
        echo -en "[--all-procedure]        Download all procedures.\n"
        echo -en "[--all-triggers]         Download all triggers.\n"
        echo -en "[--all-functions]        Download all functions.\n"
        echo -en "[--all-views]            Download all views.\n"
        echo -en "[--all]                  Download all.\n"
        echo -en "[--procedure name]       Download a particular procedure.\n"
        echo -en "[--trigger name]         Download a particular trigger.\n"
        echo -en "[--function name]        Download a particular function.\n"
        echo -en "[--view name]            Download a particular view.\n"
        echo -en "Note: For argument with value if it isn't passed value argument is ignored.\n"
        return 1
        ;;
      --)
        ;;
      *)
        error_generate "Invalid parameter $1."
        ;;

    esac

    shift
  done

  return 0
}

_mariadb_compile_help () {

  echo -en "[--all-procedures]       Compile all procedures present under MARIADB_DIR subdirectories.\n"
  echo -en "[--all-triggers]         Compile all triggers present under MARIADB_DIR subdirectories.\n"
  echo -en "[--all-functions]        Compile all functions present under MARIADB_DIR subdirectories.\n"
  echo -en "[--all-views]            Compile all views present on MARIADB_DIR subdirectories.\n"
  echo -en "[--all]                  Compile all procedures, triggers, functions and views present under\n"
  echo -en "                         MARIADB_DIR subdirectories.\n"
  echo -en "[--procedure name]       Compile a particular package under MARIADB_DIR/packages directory.\n"
  echo -en "[--trigger name]         Compile a particular trigger under MARIADB_DIR/triggers directory.\n"
  echo -en "[--function name]        Compile a particular function under MARIADB_DIR/functions directory.\n"
  echo -en "[--view name]            Compile a particular view under MARIADB_DIR/views directory.\n"
  echo -en "[--exclude filename]     Exclude a particular file from compilation.\n"
  echo -en "                         (This option can be repeat and override MARIADB_COMPILE_FILES_EXCLUDED\n"
  echo -en "                          configuration variable).\n"
  echo -en "[--id-script id]         Compile a particular script registered under MARIADB_DIR/<directory>/.\n"
  echo -en "[--file file]            Compile a particular file. (Use ABS Path or relative path from current dir.)\n"
  echo -en "Note: For argument with value if it isn't passed value argument is ignored.\n"

  return 0

}

_mariadb_connection_help () {

  echo -en "[-P mariadb_pwd]         Override MARIADB_PWD variable.\n"
  echo -en "[-U mariadb_user]        Override MARIADB_USER with username of the connection.\n"
  echo -en "[-H mariadb_host]        Override MARIADB_HOST with host of the database.\n"
  echo -en "[-D mariadb_dir]         Override MARIADB_DIR directory where save/retrieve script/functions, etc.\n"
  echo -en "[--database db]          Override MARIADB_DB variable for database name.\n"
  echo -en "[--timezone tmz]         Override MARIADB_TMZ variable for set timezone on connection session.\n"
  echo -en "[--conn-options opts]    Override MARIADB_EXTRA_OPTIONS variable for enable extra connection options.\n"

  return 0
}

_mariadb_compile () {

  local f=""

  [[ $DEBUG && $DEBUG == true ]] && echo -en "(_mariadb_compile args: $@)\n"

  # Compile script file if available
  if [ ! -z "$MARIADB_COMPILE_ID_SCRIPT" ] ; then

    _mariadb_compile_id_script || error_handled ""

    echo -en "Compiled script $MARIADB_COMPILE_ID_SCRIPT with file $DBM_SCRIPT_FILENAME correctly.\n"

  fi

  # Compile single file if available
  if [ ! -z "$MARIADB_COMPILE_FILE" ] ; then

    commons_mariadb_compile_file "$MARIADB_COMPILE_FILE" "File $MARIADB_COMPILE_FILE" || error_handled "Error on compile file $MARIADB_COMPILE_FILE."

  fi

  if [ $MARIADB_COMPILE_ALL -eq 1 ] ; then

    commons_mariadb_compile_all_procedures "" || error_handled "Error on compile all procedures."
    commons_mariadb_compile_all_triggers "" || error_handled "Error on compile all triggers."
    commons_mariadb_compile_all_functions "" || error_handled "Error on compile all functions."
    commons_mariadb_compile_all_views "" || error_handled "Error on compile all functions."

  else

    # Check for all-procedures or single procedure
    if [ $MARIADB_COMPILE_ALL_PROCEDURES -eq 1 ] ; then

      commons_mariadb_compile_all_procedures "" || error_handled "Error on compile all procedures."

    else

      if [ ! -z "$MARIADB_COMPILE_PROCEDURE" ] ; then

        f="${MARIADB_COMPILE_PROCEDURE/.sql/}"
        commons_mariadb_compile_file "$MARIADB_DIR/procedures/$f.sql" "" || error_handled "Error on compile file $f.sql"

      fi

    fi

    # Check for all-triggers or single trigger
    if [ $MARIADB_COMPILE_ALL_TRIGGERS -eq 1 ] ; then

      commons_mariadb_compile_all_triggers "" || error_handled "Error on compile all triggers."

    else

      if [ ! -z "$MARIADB_COMPILE_TRIGGER" ] ; then

        f="${MARIADB_COMPILE_TRIGGER/.sql/}"
        commons_mariadb_compile_file "$MARIADB_DIR/procedures/$f.sql" "" || error_handled "Error on compile file $f.sql"

      fi

    fi

    # Check for all-functions or single function

    if [ $MARIADB_COMPILE_ALL_FUNCTIONS -eq 1 ] ; then

      commons_mariadb_compile_all_functions "" || error_handled "Error on compile all functions."

    else

      if [ ! -z "$MARIADB_COMPILE_FUNCTION" ] ; then

        f="${MARIADB_COMPILE_FUNCTION/.sql/}"
        commons_mariadb_compile_file "$MARIADB_DIR/functions/$f.sql" "" || error_handled "Error on compile file $f.sql"

      fi

    fi

    # Check for all-views of single view

    if [ $MARIADB_COMPILE_ALL_VIEWS -eq 1 ] ; then

      commons_mariadb_compile_all_views "" || error_handled "Error on compile all views."

    else

      if [ ! -z "$MARIADB_COMPILE_VIEW" ] ; then

        f="${MARIADB_COMPILE_VIEW/.sql/}"
        commons_mariadb_compile_file "$MARIADB_DIR/views/$f.sql" "" || error_handled "Error on compile file $f.sql"

      fi

    fi


  fi # end if $MARIADB_COMPILE_ALL

  return 0
}

_mariadb_compile_id_script () {

  local f=""
  local id_script="$MARIADB_COMPILE_ID_SCRIPT"

  _dbm_check_if_exist_id_script "$id_script" || error_handled ""

  _dbm_retrieve_script_data "$id_script" "1" || error_handled ""

  if [ x"$DBM_SCRIPT_ADAPTER" != x"mariadb" ] ; then
    error_generate "Error: script $id_script isn't connect to mariadb adapter."
  fi

  f="$MARIADB_DIR/$DBM_SCRIPT_DIRECTORY/$DBM_SCRIPT_FILENAME"

  commons_mariadb_compile_file "$f" "Compile file $DBM_SCRIPT_FILENAME for release $DBM_SCRIPT_REL_NAME v.$DBM_SCRIPT_REL_VERSION" || error_handled "Error on compile file $f."


  return 0
}

_mariadb_download () {

  local n=0

  if [ $MARIADB_DOWNLOAD_ALL -eq 1 ] ; then

    commons_mariadb_download_all_procedures || error_handled "Error on download all procedures."

    commons_mariadb_download_all_triggers || error_handled "Error on download all triggers."

    commons_mariadb_download_all_functions || error_handled "Error on download all functions."

    commons_mariadb_download_all_views || error_handled "Error on download all views."

  else

    # Check for all procedures

    if [ $MARIADB_DOWNLOAD_ALL_PROCEDURES -eq 1 ] ; then

      commons_mariadb_download_all_procedures || error_handled "Error on download all procedures."

    else

      if [ -n "$MARIADB_DOWNLOAD_PROCEDURE" ] ; then

        commons_mariadb_download_procedure "$MARIADB_DOWNLOAD_PROCEDURE" || error_handled "Error on download procedures $MARIADB_DOWNLOAD_PROCEDURE."

      fi

    fi

    # Check for all-triggers or single trigger

    if [ $MARIADB_DOWNLOAD_ALL_TRIGGERS -eq 1 ] ; then

      commons_mariadb_download_all_triggers || error_handled "Error on download all triggers."

    else

      if [ -n "$MARIADB_DOWNLOAD_TRIGGER" ] ; then

        commons_mariadb_download_trigger "$MARIADB_DOWNLOAD_TRIGGER" || error_handled "Error on download trigger $MARIADB_DOWNLOAD_TRIGGER."

      fi

    fi

    # Check for all-functions or single function

    if [ $MARIADB_DOWNLOAD_ALL_FUNCTIONS -eq 1 ] ; then

      commons_mariadb_download_all_functions || error_handled "Error on download all functions."

    else

      if [ -n "$MARIADB_DOWNLOAD_FUNCTION" ] ; then

        commons_mariadb_download_function "$MARIADB_DOWNLOAD_FUNCTION" || error_handled "Error on download function $MARIADB_DOWNLOAD_FUNCTION."

      fi

    fi

    # Check for all-views or single view

    if [ $MARIADB_DOWNLOAD_ALL_VIEWS -eq 1 ] ; then

      commons_mariadb_download_all_views || error_handled "Error on download all views."

    else

      if [ -n "$MARIADB_DOWNLOAD_VIEW" ] ; then

        commons_mariadb_download_view "$MARIADB_DOWNLOAD_VIEW" || error_handled "Error on download view."

      fi

    fi

  fi # end $MARIADB_DOWNLOAD_ALL

  return 0
}

# vim: syn=sh filetype=sh
