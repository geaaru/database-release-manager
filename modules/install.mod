#!/bin/bash
#------------------------------------------------
# Author(s): Geaaru, geaaru@gmail.com
# $Id$
# License: GPL 2.0
#------------------------------------------------

name="install"
install_authors="Geaaru"
install_creation_date="May 5, 2013"
install_version="0.1"

install_version () {
   echo -en "Version: ${install_version}\n"
   return 0
}

install_long_help () {

   echo -en "===========================================================================\n"
   echo -en "Module [install]:\n"
   echo -en "Author(s): ${install_authors}\n"
   echo -en "Created: ${install_creation_date}\n"
   echo -en "Version: ${install_version}\n"
   echo -en "---------------------------------------------------------------------------\n"
   echo -en "\tlong_help               Show long help informations\n"
   echo -en "\tshow_help               Show command list.\n"
   echo -en "\tversion                 Show module version.\n"
   echo -en "\tshow_installable        Show installable script between versions.\n"
   echo -en "---------------------------------------------------------------------------\n"
   echo -en "===========================================================================\n"

   return 0
}


install_show_help () {

   echo -en "===========================================================================\n"
   echo -en "Module [install]:\n"
   echo -en "---------------------------------------------------------------------------\n"
   echo -en "\tlong_help               Show long help informations\n"
   echo -en "\tshow_help               Show command list.\n"
   echo -en "\tversion                 Show module version.\n"
   echo -en "\tshow_installable        Show installable script between versions.\n"
   echo -en "---------------------------------------------------------------------------\n"
   echo -en "===========================================================================\n"

   return 0
}

install_show_installable () {

  local result=1
  local query=""
  local id_rel_query_to=""
  local id_rel_query_from=""

  # Shift first two input param
  shift 2

  _install_check_show_installable_args "$@" || return $result

  id_rel_query_to="(SELECT id_release FROM Releases WHERE name = '$DBM_REL_NAME' AND version = '$DBM_REL_VERSION_TO')"
  id_rel_query_from="(SELECT id_release FROM Releases WHERE name = '$DBM_REL_NAME' AND version = '$DBM_REL_VERSION_FROM')"

  query="SELECT id_script,filename,type,directory,id_release FROM Scripts \
    WHERE id_script NOT IN (\
      SELECT id_script FROM ScriptRelInhibitions \
      WHERE id_release_to = ${id_rel_query_to} \
    ) \
    AND ( \
      id_release = ${id_rel_query_to} \
      OR  id_release IN (\
        SELECT id_release_dep FROM ReleasesDependencies WHERE id_release = ${id_rel_query_to} \
      ) \
    ) AND active = 1 \
    ORDER BY id_release,id_order "

  _sqlite_query -c "$DRM_DB" -q "${query}" || error_handled "Unexpected error!"

  echo -en "======================================================================================\n"
  echo -en "\e[1;33mID\e[m\t"
  echo -en "\e[1;34mFILENAME\e[m\t\t"
  echo -en "\e[1;35mTYPE\e[m\t\t"
  echo -en "\e[1;31mDIRECTORY\e[m\t"
  echo -en "\e[1;37mID_RELEASE\e[m\n"
  echo -en "======================================================================================\n"

  IFS=$'\n'
  for row in $_sqlite_ans ; do

    #[[ $DEBUG ]] && echo "ROW = ${row}"

    id_script=`echo $row | awk '{split($0,a,"|"); print a[1]}'`
    filename=`echo $row | awk '{split($0,a,"|"); print a[2]}'`
    s_type=`echo $row | awk '{split($0,a,"|"); print a[3]}'`
    directory=`echo $row | awk '{split($0,a,"|"); print a[4]}'`
    id_release=`echo $row | awk '{split($0,a,"|"); print a[5]}'`

    if [ ${#filename} -lt 16 ] ; then
      filename_tab="\t\t"
    else
      filename_tab="\t"
    fi

    echo -en "\e[1;33m${id_script}\e[m\t"
    echo -en "\e[1;34m${filename}${filename_tab}\e[m"
    echo -en "\e[1;35m${s_type}\e[m\t"
    echo -en "\e[1;31m${directory}\e[m\t"
    echo -en "\e[1;37m${id_release}\e[m\n"

  done
  unset IFS

  return 0
}

##################################################################
# Internal functions
##################################################################


_install_check_show_installable_args () {

  [[ $DEBUG ]] && echo -en "(_install_check_show_installable_args args: $@)\n"

  # Reinitialize opt index position
  OPTIND=1
  while getopts "n:t:f:h" opts "$@" ; do
    case $opts in

      n) DBM_REL_NAME="$OPTARG";;
      t) DBM_REL_VERSION_TO="$OPTARG";;
      f) DBM_REL_VERSION_FROM="$OPTARG";;
      h)
        echo -en "[-n name]               Release Name.\n"
        echo -en "[-t version_to]         Release version target of the installation.\n"
        echo -en "[-f version_from]       Release version source of the installation.\n"
        return 1
        ;;

    esac
  done

  if [ -z "$DBM_REL_NAME" ] ; then
    echo "Missing Release Name."
    return 1
  fi

  if [ -z "$DBM_REL_VERSION_TO" ] ; then
    echo "Missing Release version that has a dependency."
    return 1
  fi

  if [ -z "$DBM_REL_VERSION_FROM" ] ; then
    echo "Missing Release version needed on target."
    return 1
  fi

  return 0
}


# vim: syn=sh filetype=sh
