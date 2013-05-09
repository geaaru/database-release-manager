#!/bin/bash
#------------------------------------------------
# Author(s): Geaaru, geaaru@gmail.com
# $Id$
# License: GPL 2.0
#------------------------------------------------

name="oracle"
oracle_authors="Geaaru"
oracle_creation_date="May 6, 2013"
oracle_version="0.1"
oracle_status="0"

# Directory with custom oracle generation scripts
_oracle_scripts=$LOCAL_DIR/src/share/oracle/ # TODO to replace with placeholder for configure autotools

oracle_version() {
  echo -en "Version: ${oracle_version}\n"
  return 0
}

oracle_long_help () {

   echo -en "===========================================================================\n"
   echo -en "Module [oracle]:\n"
   echo -en "Author(s): ${oracle_authors}\n"
   echo -en "Created: ${oracle_creation_date}\n"
   echo -en "Version: ${oracle_version}\n"
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

oracle_show_help () {
   echo -en "===========================================================================\n"
   echo -en "Module [oracle]:\n"
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

oracle_test_connection () {

  local result=1

  # Shift first two input param
  shift 2

  _oracle_check_status

  _oracle_help_message="do_help"

  _oracle_connections_args "$@" || error_handled ""

  sqlplus_set_sqlplus_auth_var "$ORACLE_SID" "$ORACLE_USER" "$ORACLE_PWD"

  commons_oracle_check_connection || error_handled "SQLPlus was unable to connect the DB with the supplied credentials"

  echo -en "Connected to $ORACLE_SID with user $ORACLE_USER correctly.\n"

  return 0
}

oracle_compile () {

  local result=1

  # Shift first two input param
  shift 2

  _oracle_check_status

  _oracle_help_message="do_help"

  _oracle_connections_args "$@"

  _oracle_compile_args "$@" || error_handled ""

  sqlplus_set_sqlplus_auth_var "$ORACLE_SID" "$ORACLE_USER" "$ORACLE_PWD"

  commons_oracle_check_connection || error_handled "SQLPlus was unable to connect the DB with the supplied credentials"

  _oracle_compile || error_handled ""

  echo -en "Download operation successfull.\n"

  return 0
}

oracle_download () {

  local result=1

  # Shift first two input param
  shift 2

  _oracle_check_status

  _oracle_help_message="do_help"

  _oracle_connections_args "$@"

  _oracle_download_args "$@" || error_handled ""

  sqlplus_set_sqlplus_auth_var "$ORACLE_SID" "$ORACLE_USER" "$ORACLE_PWD"

  commons_oracle_check_connection || error_handled "SQLPlus was unable to connect the DB with the supplied credentials"

  _oracle_download || error_handled ""

  echo -en "Download operation successfull.\n"

  return 0
}


##################################################################
# Internal functions
##################################################################

_oracle_init () {

  if [[ ! -z "$SQLCA"  && "$SQLCA" =~ .*oracle.* ]] ; then

    [[ $DEBUG && $DEBUG == true ]] && echo -en "(_oracle_init: Check requirements of the oracle module.)\n"

    commons_oracle_check_tnsnames $LOCAL_DIR || error_handled "Invalid TNS_ADMIN variable"
    commons_oracle_check_sqlplus || error_handled ""

    check_var "ORACLE_USER" || error_handled "You must define ORACLE_USER variable on configuration file."
    check_var "ORACLE_PWD"  || error_handled "You must define ORACLE_PWD variable on configuration file."
    check_var "ORACLE_SID"  || error_handled "You must define ORACLE_SID variable on configuration file."
    check_var "ORACLE_DIR"  || error_handled "You must define ORACLE_DIR variable on configuration file."

    [[ $DEBUG && $DEBUG == true ]] && echo -en "(_oracle_init: All requirements are present. Continue my work.)\n"

    oracle_status="1"

  else

    [[ $DEBUG && $DEBUG == true ]] && echo -en "(_oracle_init: Nothing to do.)\n"

  fi

  return 0
}

_oracle_check_status () {

  if [ x"$oracle_status" = x"0" ] ; then
    error_generate "oracle is not enable. Enable it with SQLCA variable"
  fi

  return 0
}

_oracle_connections_args () {

  [[ $DEBUG && $DEBUG == true ]] && echo -en "(_oracle_connections_args args: $@)\n"

  local short_options="S:U:P:hD:t:"

  set -- `getopt -u -q -o "$short_options" -- "$@"` || error_handled "Invalid parameters"

  [ $# -lt 1 ] && return 0 # is there at least one param (--)

  while [ $# -gt 0 ] ; do
    case "$1" in

      -S) ORACLE_SID="$2";shift;;
      -P) ORACLE_PWD="$2";shift;;
      -U) ORACLE_USER="$2";shift;;
      -D) ORACLE_DIR="$2";shift;;
      -t) TNS_ADMIN="$2";shift;;
      -h)
        if [ ! -z "$_oracle_help_message" ] ; then
          echo -en "[-S oracle_sid]         Oracle SID (or set ORACLE_SID on configuration file).\n"
          echo -en "[-P oracle_pwd]         Oracle Password (or set ORACLE_PWD on configuration file).\n"
          echo -en "[-U oracle_user]        Oracle Username (or set ORACLE_USER on configuration file).\n"
          echo -en "[-t tnsadmin_path]      Override TNS_ADMIN variable with path of the file tnsnames.ora.\n"
          echo -en "[-D oracle_dir]         Directory where save/retrieve packages/views/functions, etc..\n"
          echo -en "                        (or set ORACLE_DIR on configuration file). \n"
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

_oracle_download_args () {

  [[ $DEBUG && $DEBUG == true ]] && echo -en "(_oracle_download_args args: $@)\n"

  local short_options="S:U:P:hD:t:"
  local long_options="all-packages all-triggers all-functions all-views all package: trigger: function: view:"

  set -- `getopt -u -q -a -o "$short_options" -l "$long_options" -- "$@"` || error_handled "Invalid parameters"

  ORACLE_DOWNLOAD_ALL=1

  if [ $# -lt 2 ] ; then # is there at least one param (--)
    echo -en "No params supply. I presume --all param.\n"
    return 0
  fi

  [[ $DEBUG && $DEBUG == true ]] && echo -en "(_oracle_download_args: Found $# params)\n"

  ORACLE_DOWNLOAD_ALL=0
  ORACLE_DOWNLOAD_ALL_PACKAGES=0
  ORACLE_DOWNLOAD_ALL_TRIGGERS=0
  ORACLE_DOWNLOAD_ALL_FUNCTIONS=0
  ORACLE_DOWNLOAD_ALL_VIEWS=0
  ORACLE_DOWNLOAD_PACKAGE=""
  ORACLE_DOWNLOAD_TRIGGER=""
  ORACLE_DOWNLOAD_FUNCTION=""
  ORACLE_DOWNLOAD_VIEW=""

  while [ $# -gt 0 ] ; do
    case "$1" in

      -S|-U|-P|-D)
        shift
        # do nothing
        ;;

      --all-packages)
        ORACLE_DOWNLOAD_ALL_PACKAGES=1
        ;;
      --all-triggers)
        ORACLE_DOWNLOAD_ALL_TRIGGERS=1
        ;;
      --all-functions)
        ORACLE_DOWNLOAD_ALL_FUNCTIONS=1
        ;;
      --all-views)
        ORACLE_DOWNLOAD_ALL_VIEWS=1
        ;;
      --all)
        ORACLE_DOWNLOAD_ALL=1
        ;;
      --package)
        ORACLE_DOWNLOAD_PACKAGE="$2"
        shift
        ;;
      --trigger)
        ORACLE_DOWNLOAD_TRIGGER="$2"
        shift
        ;;
      --function)
        ORACLE_DOWNLOAD_FUNCTION="$2"
        shift
        ;;
      --view)
        ORACLE_DOWNLOAD_VIEW="$2"
        shift
        ;;

      -h)
        echo -en "[--all-packages]        Download all packages.\n"
        echo -en "[--all-triggers]        Download all triggers.\n"
        echo -en "[--all-functions]       Download all functions.\n"
        echo -en "[--all-views]           Download all views.\n"
        echo -en "[--all]                 Download all.\n"
        echo -en "[--package name]        Download a particular package.\n"
        echo -en "[--trigger name]        Download a particular trigger.\n"
        echo -en "[--function name]       Download a particular function.\n"
        echo -en "[--view name]           Download a particular view.\n"
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

_oracle_compile_args () {

  [[ $DEBUG && $DEBUG == true ]] && echo -en "(_oracle_compile_args args: $@)\n"

  local short_options="S:U:P:hD:t:"
  local long_options="all-packages all-triggers id-script: file: all-functions all-views all package: trigger: function: view:"

  set -- `getopt -u -q -a -o "$short_options" -l "$long_options" -- "$@"` || error_handled "Invalid parameters"

  ORACLE_COMPILE_ALL=1

  if [ $# -lt 2 ] ; then # is there at least one param (--)
    _oracle_compile_help
    return 1
  fi

  [[ $DEBUG && $DEBUG == true ]] && echo -en "(_oracle_compile_args: Found $# params)\n"

  ORACLE_COMPILE_ALL=0
  ORACLE_COMPILE_ALL_PACKAGES=0
  ORACLE_COMPILE_ALL_TRIGGERS=0
  ORACLE_COMPILE_ALL_FUNCTIONS=0
  ORACLE_COMPILE_ALL_VIEWS=0
  ORACLE_COMPILE_PACKAGE=""
  ORACLE_COMPILE_TRIGGER=""
  ORACLE_COMPILE_FUNCTION=""
  ORACLE_COMPILE_VIEW=""
  ORACLE_COMPILE_ID_SCRIPT=""
  ORACLE_COMPILE_FILE=""
  ORACLE_COMPILE_FILES_EXCLUDED=""

  while [ $# -gt 0 ] ; do
    case "$1" in

      -S|-U|-P|-D)
        shift
        # do nothing
        ;;

      --all-packages)
        ORACLE_COMPILE_ALL_PACKAGES=1
        ;;
      --all-triggers)
        ORACLE_COMPILE_ALL_TRIGGERS=1
        ;;
      --all-functions)
        ORACLE_COMPILE_ALL_FUNCTIONS=1
        ;;
      --all-views)
        ORACLE_COMPILE_ALL_VIEWS=1
        ;;
      --all)
        ORACLE_COMPILE_ALL=1
        ;;
      --package)
        ORACLE_COMPILE_PACKAGE="$2"
        shift
        ;;
      --trigger)
        ORACLE_COMPILE_TRIGGER="$2"
        shift
        ;;
      --function)
        ORACLE_COMPILE_FUNCTION="$2"
        shift
        ;;
      --view)
        ORACLE_COMPILE_VIEW="$2"
        shift
        ;;
      --id-script)
        ORACLE_COMPILE_ID_SCRIPT="$2"
        shift
        ;;
      --file)
        ORACLE_COMPILE_FILE="$2"
        shift
        ;;
      --exclude)
        ORACLE_COMPILE_FILES_EXCLUDED="$ORACLE_COMPILE_FILES_EXCLUDED $2"
        shift
        ;;
      -h)
        _oracle_compile_help
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

_oracle_compile_help () {

  echo -en "[--all-packages]        Compile all packages present under ORACLE_DIR subdirectories.\n"
  echo -en "[--all-triggers]        Compile all triggers present under ORACLE_DIR subdirectories.\n"
  echo -en "[--all-functions]       Compile all functions present under ORACLE_DIR subdirectories.\n"
  echo -en "[--all-views]           Compile all views present on ORACLE_DIR subdirectories.\n"
  echo -en "[--all]                 Compile all packages, triggers, functions and views present under\n"
  echo -en "                        ORACLE_DIR subdirectories.\n"
  echo -en "[--package name]        Compile a particular package under ORACLE_DIR/packages directory.\n"
  echo -en "[--trigger name]        Compile a particular trigger under ORACLE_DIR/triggers directory.\n"
  echo -en "[--function name]       Compile a particular function under ORACLE_DIR/functions directory.\n"
  echo -en "[--view name]           Compile a particular view under ORACLE_DIR/views directory.\n"
  echo -en "[--exclude filename]    Exclude a particular file from compilation.\n"
  echo -en "                        (This option can be repeat and override ORACLE_COMPILE_FILES_EXCLUDED\n"
  echo -en "                         configuration variable).\n"
  echo -en "[--id-script id]        Compile a particular script registered under ORACLE_DIR/<directory>/.\n"
  echo -en "[--file file]           Compile a particular file. (Use ABS Path or relative path from current dir.)\n"
  echo -en "Note: For argument with value if it isn't passed value argument is ignored.\n"

  return 0
}

_oracle_compile () {

  local f=""

  [[ $DEBUG && $DEBUG == true ]] && echo -en "(_oracle_compile args: $@)\n"

  # Compile script file if available
  if [ ! -z "$ORACLE_COMPILE_ID_SCRIPT" ] ; then

    _oracle_compile_id_script || error_handled ""

    echo -en "Compiled script $ORACLE_COMPILE_ID_SCRIPT with file $DBM_SCRIPT_FILENAME correctly.\n"

  fi

  # Compile single file if available
  if [ ! -z "$ORACLE_COMPILE_FILE" ] ; then

    commons_oracle_compile_file "$ORACLE_COMPILE_FILE" "Compile file $DBM_SCRIPT_FILENAME." || error_handled "Error on compile file $ORACLE_COMPILE_FILE."

  fi


  if [ $ORACLE_COMPILE_ALL -eq 1 ] ; then

    commons_oracle_compile_all_packages "" || error_handled "Error on compile all packages."

    commons_oracle_compile_all_triggers "" || error_handled "Error on compile all triggers."

    commons_oracle_compile_all_functions "" || error_handled "Error on compile all functions."

    commons_oracle_compile_all_views "" || error_handled "Error on compile all functions."

  else

    # Check for all-packages or single package

    if [ $ORACLE_COMPILE_ALL_PACKAGES -eq 1 ] ; then

      commons_oracle_compile_all_packages "" || error_handled "Error on compile all packages."

    else

      if [ ! -z "$ORACLE_COMPILE_PACKAGE" ] ; then

        f="${ORACLE_COMPILE_PACKAGE/.sql/}"
        commons_oracle_compile_file "$ORACLE_DIR/packages/$f.sql" "" || error_handled "Error on compile file $f.sql"

      fi

    fi

    # Check for all-triggers or single trigger

    if [ $ORACLE_COMPILE_ALL_TRIGGERS -eq 1 ] ; then

      commons_oracle_compile_all_triggers "" || error_handled "Error on compile all triggers."

    else

      if [ ! -z "$ORACLE_COMPILE_TRIGGER" ] ; then

        f="${ORACLE_COMPILE_TRIGGER/.sql/}"
        commons_oracle_compile_file "$ORACLE_DIR/triggers/$f.sql" "" || error_handled "Error on compile file $f.sql"

      fi

    fi

    # Check for all-functions or single function

    if [ $ORACLE_COMPILE_ALL_FUNCTIONS -eq 1 ] ; then

      commons_oracle_compile_all_functions "" || error_handled "Error on compile all functions."

    else

      if [ ! -z "$ORACLE_COMPILE_FUNCTION" ] ; then

        f="${ORACLE_COMPILE_FUNCTION/.sql/}"
        commons_oracle_compile_file "$ORACLE_DIR/functions/$f.sql" "" || error_handled "Error on compile file $f.sql"

      fi

    fi

    # Check for all-views of single view

    if [ $ORACLE_COMPILE_ALL_VIEWS -eq 1 ] ; then

      commons_oracle_compile_all_views "" || error_handled "Error on compile all functions."

    else

      if [ ! -z "$ORACLE_COMPILE_VIEW" ] ; then

        f="${ORACLE_COMPILE_VIEW/.sql/}"
        commons_oracle_compile_file "$ORACLE_DIR/views/$f.sql" "" || error_handled "Error on compile file $f.sql"

      fi

    fi


  fi # end else ORACLE_COMPILE_ALL

  return 0
}

_oracle_download () {

  if [ $ORACLE_DOWNLOAD_ALL -eq 1 ] ; then

    commons_oracle_download_all_packages || error_handled "Error on download all packages."

    commons_oracle_download_all_triggers || error_handled "Error on download all triggers."

    commons_oracle_download_all_functions || error_handled "Error on download all functions."

    commons_oracle_download_all_views || error_handled "Error on download all functions."

  else

    # Check for all-packages or single package

    if [ $ORACLE_DOWNLOAD_ALL_PACKAGES -eq 1 ] ; then

      commons_oracle_download_all_packages || error_handled "Error on download all packages."

    else

      if [ ! -z "$ORACLE_DOWNLOAD_PACKAGE" ] ; then

        commons_oracle_download_package "$ORACLE_DOWNLOAD_PACKAGE" || error_handled "Error on download package $ORACLE_DOWNLOAD_PACKAGE."

      fi

    fi

    # Check for all-triggers or single trigger

    if [ $ORACLE_DOWNLOAD_ALL_TRIGGERS -eq 1 ] ; then

      commons_oracle_download_all_triggers || error_handled "Error on download all triggers."

    else

      if [ ! -z "$ORACLE_DOWNLOAD_TRIGGER" ] ; then

        commons_oracle_download_trigger "$ORACLE_DOWNLOAD_TRIGGER" || error_handled "Error on download trigger $ORACLE_DOWNLOAD_TRIGGER."

      fi

    fi

    # Check for all-functions or single function

    if [ $ORACLE_DOWNLOAD_ALL_FUNCTIONS -eq 1 ] ; then

      commons_oracle_download_all_functions || error_handled "Error on download all functions."

    else

      if [ ! -z "$ORACLE_DOWNLOAD_FUNCTION" ] ; then

        commons_oracle_download_function "$ORACLE_DOWNLOAD_FUNCTION" || error_handled "Error on download function $ORACLE_DOWNLOAD_FUNCTION."

      fi

    fi

    # Check for all-views of single view

    if [ $ORACLE_DOWNLOAD_ALL_VIEWS -eq 1 ] ; then

      commons_oracle_download_all_views || error_handled "Error on download all views."

    else

      if [ ! -z "$ORACLE_DOWNLOAD_VIEW" ] ; then

        commons_oracle_download_view "$ORACLE_DOWNLOAD_VIEW" || error_handled "Error on download view $ORACLE_DOWNLOAD_VIEW."

      fi

    fi

  fi # end else ORACLE_DOWNLOAD_ALL

  return 0
}

_oracle_compile_id_script () {

  local f=""
  local id_script="$ORACLE_COMPILE_ID_SCRIPT"

  _dbm_check_if_exist_id_script "$id_script" || error_handled ""

  _dbm_retrieve_script_data "$id_script" "1" || error_handled ""

  if [ x"$DBM_SCRIPT_ADAPTER" != x"oracle" ] ; then
    error_generate "Error: script $id_script isn't connect to oracle adapter."
  fi

  f="$ORACLE_DIR/$DBM_SCRIPT_DIRECTORY/$DBM_SCRIPT_FILENAME"

  commons_oracle_compile_file "$f" "Compile file $DBM_SCRIPT_FILENAME for release $DBM_SCRIPT_REL_NAME v.$DBM_SCRIPT_REL_VERSION" || error_handled "Error on compile file $f."


  return 0
}


# vim: syn=sh filetype=sh
