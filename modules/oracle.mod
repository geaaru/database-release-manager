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
   echo -en "\ttest_connection         Test connection\n"
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
   echo -en "\ttest_connection         Test connection\n"
   echo -en "---------------------------------------------------------------------------\n"
   echo -en "===========================================================================\n"

   return 0
}

oracle_test_connection () {

  local result=1

  # Shift first two input param
  shift 2

  _oracle_connections_args "$@"


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

    [[ $DEBUG && $DEBUG == true ]] && echo -en "(_oracle_init: All requirements are present. Continue my work.)\n"

  else

    [[ $DEBUG && $DEBUG == true ]] && echo -en "(_oracle_init: Nothing to do.)\n"

  fi

  return 0
}

_oracle_connections_args () {

  [[ $DEBUG && $DEBUG == true ]] && echo -en "(_oracle_connections_args args: $@)\n"

  # Reinitialize opt index position
  #OPTIND=1
  #while getopts "s:u:p:h" opts "$@" ; do
    #case $opts in

      #s) ORACLE_SID="$OPTARG";;
      #p) ORACLE_PWD="$OPTARG";;
      #u) ORACLE_USER="$OPTARG";;
      #h)
        #if [ -z "$_oracle_help_message" ] ; then
        #echo -en "[-s oracle_sid]         Oracle SID.\n"
        #echo -en "[-i id_script]          Script Id.\n"
        #echo -en "[-t version_to]         Release version target of the installation.\n"
        #echo -en "[-f version_from]       Release version source of the installation.\n"
        #return 1
        #;;

    #esac
  #done


}

# vim: syn=sh filetype=sh
