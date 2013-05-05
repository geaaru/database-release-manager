#!/bin/bash
#------------------------------------------------
# Author(s): Geaaru, geaaru@gmail.com
# $Id$
# License: GPL 2.0
#------------------------------------------------

name="sql_handler"
sql_handler_authors="Geaaru"
sql_handler_creation_date="August 26, 2008"
sql_handler_version="0.1"

sql_handler_version () {
   echo -en "Version: ${sql_handler_version}\n"
}

sql_handler_show_help () {
   echo -en "===========================================================================\n"
   echo -en "Module [sql_handler]:\n"
   echo -en "---------------------------------------------------------------------------\n"
   echo -en "\tlong_help               Show long help informations\n"
   echo -en "\tquery                   Do a query to database.\n"
   echo -en "===========================================================================\n"
}

sql_handler_long_help () {
   echo -en "===========================================================================\n"
   echo -en "Module [sql_handler]:\n"
   echo -en "Author(s): ${sql_handler_authors}\n"
   echo -en "Created: ${sql_handler_creation_date}\n"
   echo -en "Version: ${sql_handler_version}\n\n"
   echo -en "Command                 Description\n"
   echo -en "---------------------------------------------------------------------------\n"
   echo -en "\tlong_help               Show long help informations\n"
   echo -en "\tshow_help               Show command list.\n"
   echo -en "\tversion                 Show module version.\n"
   echo -en "\tquery                   Do a query to database.\n"
   echo -en "\n"
   echo -en "Args                    Description\n"
   echo -en "---------------------------------------------------------------------------\n"
   echo -en "[-d DIR]                Directory where found server data\n"
   echo -en "                        Default directory is $DIR.(Use absolute path)\n"
   echo -en "[-u]                    user permission. Default is $USER.\n"
   echo -en "[-g]                    group permission. Default is $GROUP.\n"
   echo -en "[-n name]               name of the server tree. Possible values\n"
   echo -en "                        could be still all|default|minimal\n"
   echo -en "===========================================================================\n"

}

sql_handler_query () {
   local result=1
   local directmode=0
   _sql_handler_ans=""

   [[ $DEBUG ]] && echo -en "\n(sql_handler_query args: $@)\n"

   _sql_handler_check_env

   if [ $# -ne 1 ] ; then
      shift 2
      directmode=1
   fi
   if type -t ${SQLCA}_be_query > /dev/null ; then
      ${SQLCA}_be_query "$@"
      result=$?
      if [ $result -ne 0 ] ; then
         return 1
      else
         _sql_handler_ans=$_sqlite_ans
      fi
   else
      echo -en "Invalid SQL Connector Adapter: $SQLCA\n";
   exit 1
   fi

   [[ $directmode -eq 1 ]] && echo -en "Answer:\n$_sql_handler_ans\n"
   return 0
}

#######################################################################
# Internal Functions                                                  #
#######################################################################

_sql_handler_check_env () {
   [[ $DEBUG ]] && echo -en "(_sql_handler_check_env args: $@)\n"

   [[ $DEBUG ]] && echo -en "Check if SQLCA variable is set...\n"

   if [[ -z "$SQLCA" ]] ; then
      echo -en "Error: SQLCA variable isn't set.\n"
      exit 1
   fi
}

# vim: syn=sh filetype=sh
