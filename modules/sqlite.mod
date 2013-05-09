#!/bin/bash

name="sqlite"
sqlite_authors="Geaaru"
sqlite_creation_date="August 26, 2008"
sqlite_version="0.1"
sqlite_hidden="0"

sqlite_version () {
  echo -en "Version: ${sqlite_version}\n"
}

sqlite_show_help () {
   echo -en "===========================================================================\n"
   echo -en "Module [sqlite]:\n"
   echo -en "---------------------------------------------------------------------------\n"
   echo -en "\tlong_help               Show long help informations\n"
   echo -en "\tcreate                  Create SQLite database.\n"
   echo -en "\tremove                  Remove SQLite database.\n"
   echo -en "\tquery                   Do a query to SQLite database.\n"
   echo -en "===========================================================================\n"
}

sqlite_long_help () {
   echo -en "===========================================================================\n"
   echo -en "Module [sqlite]:\n"
   echo -en "Author(s): ${sqlite_authors}\n"
   echo -en "Created: ${sqlite_creation_date}\n"
   echo -en "Version: ${sqlite_version}\n\n"
   echo -en "---------------------------------------------------------------------------\n"
   echo -en "\tlong_help               Show long help informations\n"
   echo -en "\tshow_help               Show command list.\n"
   echo -en "\tversion                 Show module version.\n"
   echo -en "\tcreate                  Create SQLite database to file:\n"
   if [[ -z "$SQLITEDB" ]] ; then
     echo -en "\t (ATTENTION: you must set SQLITEDB\n"
     echo -en "\t                        in your configuration file).\n"
   else
     echo -en "\t                        $SQLITEDB\n"
   fi
   echo -en "\tremove                  Remove SQLite database.\n"
   echo -en "\tquery                   Do a query to SQLite database.\n"
   echo -en "---------------------------------------------------------------------------\n"
   echo -en "===========================================================================\n"

}

# return 1 error
# return 0 ok
sqlite_create () {
  local result=1

  [[ $DEBUG ]] && echo -en "(sqlite_create args: $@)\n"

  # Shift first two input param
  shift 2

  _sqlite_create "$@"
  result=$?

  return $result
}

sqlite_query () {
  local result=1

  [[ $DEBUG ]] && echo -en "(sqlite_query args: $@)\n"

  # Shift first two input param
  shift 2

  _sqlite_query "$@"
  result=$?

  return $result
}

sqlite_remove () {
  local result=1

  [[ $DEBUG ]] && echo -en "(sqlite_remove args: $@)\n"

  # Shift first two input param
  shift 2

  _sqlite_remove "$@"
  result=$?

  return $result
}

#######################################################################
# Internal Functions                                                  #
#######################################################################

_sqlite_check_db () {
  if [[ ! -e "$SQLITEDB" ]] ; then
    echo -en "$SQLITEDB database doesn't exist.\n"
    exit 1
  fi
}

_sqlite_check_args () {
  [[ $DEBUG ]] && echo -en "(_sqlite_check_args args: $@)\n"

  # Reinitialize opt index position
  OPTIND=1
  while getopts "c:s:q:d:g:u:n:f:qD:S:L:t:" opts "$@" ; do
    case $opts in
      # sqlite_create params
      c) SQLITEDB="$OPTARG";;
      s) SQLITE_SCHEMA="$OPTARG";;

      # sqlite_query params
      q) SQLITE_QUERY="$OPTARG";;

      *) sqlite_help
          return 1
          ;;
    esac
  done


  return 0
}

_sqlite_remove () {
  local result=1

  _sqlite_check_args "$@"
  if [[ -z $SQLITEDB ]] ; then
    echo -en "_sqlite_remove: Missing parameters.\n"
    return 1
  fi

  _sqlite_check_db

  confirmation_question "Are you sure to remove file $SQLITEDB? [y/N]:"
  result=$?
  if [ $result -eq 0 ] ; then
    echo -en "Removing file $SQLITEDB..."
    $RM $SQLITEDB
    result=$?
    if [ $result -eq 0 ] ; then
      echo -en "OK\n"
    else
      echo -en "Error\n"
    fi
  else
    echo -en "Remove cancelled.\n"
  fi

  return $result
}

_sqlite_create () {
  local result=1

  _sqlite_check_args "$@"
  if [[ -z $SQLITEDB || -z $SQLITE_SCHEMA ]] ; then
    echo -en "_sqlite_create: Missing parameters.\n"
    return 1
  fi

  if [ -e $SQLITEDB ] ; then
    echo -en "File $SQLITEDB already exist.\n"
  else
    if [ -e "$SQLITE_SCHEMA" ] ; then
      echo -en "Creating database $SQLITEDB"
      sqlite3 "$SQLITEDB" < "$SQLITE_SCHEMA"
      result=$?
      if [ $result -ne 0 ] ; then
        echo -en "Error on initialize database.\n"
      else
        echo -en "..."
      fi
    else
      echo -en "No schema file found to $SQLITE_SCHEMA\n"
      return 1
    fi
  fi

  echo -en "OK\n"
  return 0

}

_sqlite_query () {
  local result=1
  local pragma="PRAGMA foreign_keys = ON; "

  [[ $DEBUG && $DEBUG == true ]] && echo -en "(_sqlite_query: $@)\n"

  _sqlite_check_args "$@" || error_handled ""

  #[[ $DEBUG ]] && echo -en "USE db: $SQLITEDB\n"
  #[[ $DEBUG ]] && echo -en "USE QUERY: $SQLITE_QUERY\n"

  _sqlite_check_db || error_handled ""

  if [[ ! -z "$SQLITEDB_INIT_SESSION" ]] ; then
    if [ "$SQLITEDB_INIT_SESSION" == " " ] ; then
      pragma=""
    else
      pragma="$SQLITEDB_INIT_SESSION"
    fi
  fi

  [[ $DEBUG && $DEBUG == true ]] && echo -en "(_sqlite_query execute: sqlite3 $SQLITEDB \"$pragma $SQLITE_QUERY\"\n"
  _sqlite_ans="$(sqlite3 $SQLITEDB "${pragma}${SQLITE_QUERY}")"
  result=$?

  [[ $DEBUG && $DEBUG == true ]] && echo -en "(_sqlite_query ans:\n$_sqlite_ans\n)\n"

  return $result
}

# vim: syn=sh filetype=sh

