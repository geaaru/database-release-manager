#!/bin/bash
#------------------------------------------------
# Author(s): Geaaru, geaaru@gmail.com
# $Id$
# License: GPL 2.0
#------------------------------------------------


_dbm_ins_rel_help () {

  echo -en "[-n name]               Release Name.\n"
  echo -en "[-d YYYY-MM-DD]         Release Date. (Use now if not available)\n"
  echo -en "[-v version]            Release Version\n"
  echo -en "[-a adapter]            Release Adapter (default is Oracle).\n"
  echo -en "[-o id_order]           Release Id Order (optional).\n"
  echo -en "[-b id_branch]          Release Id Branch (default master branch {1}).\n"
  echo -en "[-dir directory]        Release directory (default is [.]).\n"
  echo -en "\n"

  return 0
}

_dbm_check_ins_rel_args () {

  [[ $DEBUG ]] && echo -en "(_dbm_check_ins_rel_args args: $@)\n"

  local short_options="n:d:v:o:a:b:h"
  local long_options="dir:"

  $(set -- $(getopt -u -q -a -o "$short_options" -l "$long_options" -- "$@")) || error_handled "Invalid parameters"

  if [ $# -lt 2 ] ; then
    _dbm_ins_rel_help
    return 1
  fi

  [[ $DEBUG && $DEBUG == true ]] && echo -en "(_dbm_check_ins_rel_args: Found $# params)\n"

  while [ $# -gt 0 ] ; do
    case "$1" in

      -n) DBM_REL_NAME="$2"    ;shift;;
      -d) DBM_REL_DATE="$2"    ;shift;;
      -v) DBM_REL_VERSION="$2" ;shift;;
      -o) DBM_REL_ORDER="$2"   ;shift;;
      -a) DBM_REL_ADAPTER="$2" ;shift;;
      -b) DBM_REL_BRANCH="$2"  ;shift;;
      --dir)
        DBM_REL_DIR="$2"
        shift
        ;;
      -h)
        _dbm_ins_rel_help
        return 1
        ;;
      --) ;;
      *)
        error_generate "Invalid parameter $1."
        ;;
    esac
    shift

  done

  if [ -z "$DBM_REL_NAME" ] ; then
    echo "Missing Release Name"
    return 1
  fi

  if [ -z "$DBM_REL_DATE" ] ; then
    DBM_REL_DATE="DATETIME('now')"
  else
    DBM_REL_DATE="'$DBM_REL_DATE'"
  fi

  if [ -z "$DBM_REL_ADAPTER" ] ; then
    DBM_REL_ADAPTER="oracle";
  fi

  if [ -z "$DBM_REL_DIR" ] ; then
    DBM_REL_DIR="."
  fi

  if [ -z "$DBM_REL_VERSION" ] ; then
    echo "Missing Release Verion"
    return 1
  fi

  return 0
}

# Args for insert branch command
_dbm_check_ins_bra_args () {

  [[ $DEBUG ]] && echo -en "(_dbm_check_ins_bra_args args: $@)\n"

  # Reinitialize opt index position
  OPTIND=1
  while getopts "n:d:v:o:a:b:h" opts "$@" ; do
    case $opts in

      n) DBM_BRA_NAME="$OPTARG";;
      d) DBM_BRA_DATE="$OPTARG";;
      h)
        echo -en "[-n name]               Branch Name.\n"
        echo -en "[-d YYYY-MM-DD]         Branch Date. (Use now if not available)\n"
        return 1
        ;;

    esac
  done

  if [ -z "$DBM_BRA_NAME" ] ; then
    echo "Missing Release Name"
    return 1
  fi

  if [ -z "$DBM_BRA_DATE" ] ; then
    DBM_BRA_DATE="DATETIME('now')"
  else
    DBM_BRA_DATE="'$DBM_REL_DATE'"
  fi

  return 0
}

_dbm_check_ins_script_type_args () {

  [[ $DEBUG ]] && echo -en "(_dbm_check_ins_script_type_args args: $@)\n"

  # Reinitialize opt index position
  OPTIND=1
  while getopts "c:d:h" opts "$@" ; do
    case $opts in

      c) DBM_SCRIPT_TYPE_CODE="$OPTARG";;
      d) DBM_SCRIPT_TYPE_DESCR="$OPTARG";;
      h)
        echo -en "[-c code]               Script Type Code.\n"
        echo -en "[-d description]        Script Type Description\n"
        return 1
        ;;

    esac
  done

  if [ -z "$DBM_SCRIPT_TYPE_CODE" ] ; then
    echo "Missing Script Type Code."
    return 1
  fi

  if [ -z "$DBM_SCRIPT_TYPE_DESCR" ] ; then
    echo "Missing Script Type Descr"
    return 1
  fi

  return 0
}

_dbm_check_ins_script_args () {

  [[ $DEBUG ]] && echo -en "(_dbm_check_ins_script_args args: $@)\n"

  # Reinitialize opt index position
  OPTIND=1
  while getopts "f:t:a:d:hr:n:v:o:" opts "$@" ; do
    case $opts in

      f) DBM_SCRIPT_FILENAME="$OPTARG";;
      t) DBM_SCRIPT_TYPE="$OPTARG";;
      a) DBM_SCRIPT_ACTIVE="$OPTARG";;
      d) DBM_SCRIPT_DIRECTORY="$OPTARG";;
      r) DBM_SCRIPT_ID_RELEASE="$OPTARG";;
      n) DBM_SCRIPT_REL_NAME="$OPTARG";;
      v) DBM_SCRIPT_REL_VERSION="$OPTARG";;
      o) DBM_SCRIPT_ID_ORDER="$OPTARG";;
      h)
        echo -en "[-f filename]           Script filename.\n"
        echo -en "[-n name]               Release Name.\n"
        echo -en "[-v version]            Release Version\n"
        echo -en "[-t script_type]        Script Type.\n"
        echo -en "[-a 0|1]                Set active flag. Default is 1 (active)\n"
        echo -en "[-d directory]          Directory of the script.\n"
        echo -en "[-o id_order]           Script Id Order (optional). Default is used MAX(id) of the same id_release.\n"
        echo -en "[-r id_release]         Id_release of the script. Use this instead of release name and version.\n"
        echo -en "[-h]                    Show this message.\n"
        return 1
        ;;

    esac
  done

  if [ -z "$DBM_SCRIPT_FILENAME" ] ; then
    echo "Missing Script Filename"
    return 1
  fi

  if [ -z "$DBM_SCRIPT_TYPE" ] ; then
    echo "Missing Script Type"
    return 1
  fi

  if [ -z "$DBM_SCRIPT_ID_RELEASE" ] ; then
    if [[ -z "$DBM_SCRIPT_REL_VERSION" || -z "$DBM_SCRIPT_REL_NAME" ]] ; then
      echo "Missing Release Version or Release Name or Id Release."
      return 1
    fi
  fi

  if [ -z "$DBM_SCRIPT_DIRECTORY" ] ; then
    echo "Missing Script Directory."
    return 1
  fi

  if [ -z "$DBM_SCRIPT_ACTIVE" ] ; then
    DBM_SCRIPT_ACTIVE="1"
  else
    if [[ x"$DBM_SCRIPT_ACTIVE" != x"1" && x"$DBM_SCRIPT_ACTIVE" != x"0" ]] ; then
      DBM_SCRIPT_ACTIVE="1"
    fi
  fi

  return 0
}


_dbm_check_rel_dep_args () {

  [[ $DEBUG ]] && echo -en "(_dbm_check_ins_rel_dep_args args: $@)\n"

  # Reinitialize opt index position
  OPTIND=1
  while getopts "n:t:f:h" opts "$@" ; do
    case $opts in

      n) DBM_REL_NAME="$OPTARG";;
      t) DBM_REL_VERSION_TO="$OPTARG";;
      f) DBM_REL_VERSION_FROM="$OPTARG";;
      h)
        echo -en "[-n name]               Release Name.\n"
        echo -en "[-t version_to]         Release version that has a dependency.\n"
        echo -en "[-f version_from]       Release version needed.\n"
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

  if [ "$DBM_REL_VERSION_FROM" == "$DBM_REL_VERSION_TO" ] ; then
    echo "Both version are equal. Error."
    return 1
  fi

  return 0
}

_dbm_check_upd_script_args () {

  [[ $DEBUG ]] && echo -en "(_dbm_check_upd_script_args args: $@)\n"

  # Reinitialize opt index position
  OPTIND=1
  while getopts "i:f:t:a:d:hr:n:v:o:" opts "$@" ; do
    case $opts in

      i) DBM_SCRIPT_ID="$OPTARG";;
      f) DBM_SCRIPT_FILENAME="$OPTARG";;
      t) DBM_SCRIPT_TYPE="$OPTARG";;
      a) DBM_SCRIPT_ACTIVE="$OPTARG";;
      d) DBM_SCRIPT_DIRECTORY="$OPTARG";;
      r) DBM_SCRIPT_ID_RELEASE="$OPTARG";;
      n) DBM_SCRIPT_REL_NAME="$OPTARG";;
      v) DBM_SCRIPT_REL_VERSION="$OPTARG";;
      o) DBM_SCRIPT_ID_ORDER="$OPTARG";;
      h)
        echo -en "[-i id_script]          Id Script.\n"
        echo -en "[-f filename]           Script filename.\n"
        echo -en "[-n name]               Release Name.\n"
        echo -en "[-v version]            Release Version\n"
        echo -en "[-t script_type]        Script Type.\n"
        echo -en "[-a 0|1]                Set active flag.\n"
        echo -en "[-d directory]          Directory of the script.\n"
        echo -en "[-o id_order]           Script Id Order (optional). Default is used MAX(id) of the same id_release.\n"
        echo -en "[-r id_release]         Id_release of the script. Use this instead of release name and version.\n"
        return 1
        ;;

    esac
  done

  if [ -z "$DBM_SCRIPT_ID" ] ; then
    echo "Missing Script Id."
    return 1
  fi

  if [ ! -z "$DBM_SCRIPT_ACTIVE" ] ; then
    if [[ x"$DBM_SCRIPT_ACTIVE" != x"1" && x"$DBM_SCRIPT_ACTIVE" != x"0" ]] ; then
      DBM_SCRIPT_ACTIVE="1"
    fi
  fi

  return 0
}

_dbm_check_rm_script_args () {

  [[ $DEBUG ]] && echo -en "(_dbm_check_rm_script_args args: $@)\n"

  # Reinitialize opt index position
  OPTIND=1
  while getopts "i:h" opts "$@" ; do
    case $opts in

      i) DBM_SCRIPT_ID="$OPTARG";;
      h)
        echo -en "[-i id_script]          Id Script of the script to remove.\n"
        return 1
        ;;

    esac
  done

  if [ -z "$DBM_SCRIPT_ID" ] ; then
    echo "Missing Script Id."
    return 1
  fi

  return 0
}

_dbm_upd_release_help () {

  echo -en "[-n name]               Release Name.\n"
  echo -en "[-d YYYY-MM-DD]         Release Date.\n"
  echo -en "[-v version]            Release Version\n"
  echo -en "[-a adapter]            Release Adapter.\n"
  echo -en "[-b id_branch]          Id Branch.\n"
  echo -en "[-i id_release]         Id Release to update.\n"
  echo -en "[--dir directory]       Directory to update.\n"
  echo -en "\n"

  return 0
}

_dbm_check_upd_release_args () {

  [[ $DEBUG && $DEBUG == true ]] && echo -en "(_dbm_check_upd_release_args: $@)\n"

  DBM_REL_NAME_UPD=0
  DBM_REL_DATE_UPD=0
  DBM_REL_VERSION_UPD=0
  DBM_REL_ADAPTER_UPD=0
  DBM_REL_BRANCH_UPD=0
  DBM_REL_DIR_UPD=0

  local short_options="b:n:d:a:v:i:h"
  local long_options="dir:"

  $(set -- $(getopt -u -q -a -o "$short_options" -l "$long_options" -- "$@")) || error_handled "Invalid parameters"

  if [ $# -lt 2 ] ; then
    _dbm_upd_release_help
    return 1
  fi

  [[ $DEBUG && $DEBUG == true ]] && echo -en "(_dbm_check_upd_release_args: Found $# params)\n"

  while [ $# -gt 0 ] ; do
    case $1 in

      -n)
        DBM_REL_NAME="$2"
        DBM_REL_NAME_UPD=1
        shift
        ;;
      -d)
        DBM_REL_DATE="$2"
        DBM_REL_DATE_UPD=1
        shift
        ;;
      -v)
        DBM_REL_VERSION="$2"
        DBM_REL_VERSION_UPD=1
        shift
        ;;
      -a)
        DBM_REL_ADAPTER="$2"
        DBM_REL_ADAPTER_UPD=1
        shift
        ;;
      -b)
        DBM_REL_BRANCH="$2"
        DBM_REL_BRANCH_UPD=1
        shift
        ;;
      -i)
        DBM_REL_ID="$2"
        shift
        ;;
      -h)
        _dbm_upd_release_help
        return 1
        ;;
      --)
        DBM_REL_DIR="$2"
        DBM_REL_DIR_UPD=1
        shift
        ;;
      *)
        error_generate "Invalid parameter $1."
        ;;

    esac

    shift

  done

  if [ -z "$DBM_REL_ID" ] ; then
    echo "Missing Release Id."
    return 1
  fi

  if [[ $DBM_REL_NAME_UPD -eq 0 && $DBM_REL_DATE_UPD -eq 0 &&
        $DBM_REL_VERSION_UPD -eq 0 && $DBM_REL_ADAPTER_UPD -eq 0 &&
        $DBM_REL_BRANCH_UPD -eq 0 && $DBM_REL_DIR_UPD -eq 0 ]] ; then

    echo -en "No fields to update.\n"
    return 1

  fi

  return 0
}

_dbm_check_move_release_args () {

  [[ $DEBUG && $DEBUG == true ]] && echo -en "(_dbm_check_ins_inhibit_script_args args: $@)\n"

  DBM_BEFORE=0
  DBM_AFTER=0

  # Reinitialize opt index position
  OPTIND=1
  while getopts "b:n:a:r:h" opts "$@" ; do
    case $opts in

      n) DBM_REL_NAME="$OPTARG";;
      b) DBM_BEFORE=1
         DBM_REL_VERSION_TO="$OPTARG";;
      a) DBM_AFTER=1
         DBM_REL_VERSION_TO="$OPTARG";;
      r) DBM_REL_VERSION_FROM="$OPTARG";;
      h)
        echo -en "[-r version_from]       Release version.\n"
        echo -en "[-n name]               Release Name.\n"
        echo -en "[-a version_to]         After release version_to.\n"
        echo -en "[-b version_to]         Before release version_to.\n"
        echo -en "\n"
        echo -en "Example: -n 'Project1' -r '0.1.1' -a '0.1.0' (Release 0.1.1 after release 0.1.0)\n"
        return 1
        ;;

    esac
  done

  if [ -z "$DBM_REL_NAME" ] ; then
    echo "Missing Release Name."
    return 1
  fi

  if [ -z "$DBM_REL_VERSION_FROM" ] ; then
    echo "Missing Release version."
    return 1
  fi

  if [[ $DBM_BEFORE == 1 && $DBM_AFTER == 1 ]] ; then
    echo "Both after and before are used. Error."
    return 1
  fi

  if [[ $DBM_BEFORE == 0 && $DBM_AFTER == 0 ]] ; then
    echo "Missing -a or -b parameter."
    return 1
  fi

  return 0

}

_dbm_check_inhibit_script_args () {

  [[ $DEBUG && $DEBUG == true ]] && echo -en "(_dbm_check_ins_inhibit_script_args args: $@)\n"

  # Reinitialize opt index position
  OPTIND=1
  while getopts "i:n:t:f:h" opts "$@" ; do
    case $opts in

      i) DBM_SCRIPT_ID="$OPTARG";;
      n) DBM_REL_NAME="$OPTARG";;
      t) DBM_REL_VERSION_TO="$OPTARG";;
      f) DBM_REL_VERSION_FROM="$OPTARG";;
      h)
        echo -en "[-n name]               Release Name.\n"
        echo -en "[-i id_script]          Script Id.\n"
        echo -en "[-t version_to]         Release version target of the installation.\n"
        echo -en "[-f version_from]       Release version source of the installation.\n"
        return 1
        ;;

    esac
  done

  if [ -z "$DBM_SCRIPT_ID" ] ; then
    echo "Missing Script Id."
    return 1
  fi

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

  if [ "$DBM_REL_VERSION_FROM" == "$DBM_REL_VERSION_TO" ] ; then
    echo "Both version are equal. Error."
    return 1
  fi

  return 0
}

_dbm_move_script_help () {

  echo -en "[-i id_script]          Id script of the script to move.\n"
  echo -en "[-a x]                  After script with id x.\n"
  echo -en "[-b x]                  Before script with id x.\n"
  echo -en "[-r id_release]         Id Release of the script to move.\n"

  return 0
}

_dbm_check_move_script_args () {

  [[ $DEBUG && $DEBUG == true ]] && echo -en "(_dbm_check_move_script_args: $@)\n"

  DBM_BEFORE=0
  DBM_AFTER=0

  # Reinitialize opt index position
  OPTIND=1
  while getopts "b:i:a:r:h" opts "$@" ; do
    case $opts in

      r) DBM_REL_ID="$OPTARG";;
      b) DBM_BEFORE=1
         DBM_SCRIPT_ID_FROM="$OPTARG";;
      a) DBM_AFTER=1
         DBM_SCRIPT_ID_TO="$OPTARG";;
      i) DBM_SCRIPT_ID="$OPTARG";;
      h)
        _dbm_move_script_help
        return 1
        ;;

    esac
  done

  if [ -z "$DBM_REL_NAME" ] ; then
    echo "Missing Release Name."
    return 1
  fi

  if [ -z "$DBM_REL_VERSION_FROM" ] ; then
    echo "Missing Release version."
    return 1
  fi

  if [[ $DBM_BEFORE == 1 && $DBM_AFTER == 1 ]] ; then
    echo "Both after and before are used. Error."
    return 1
  fi

  if [[ $DBM_BEFORE == 0 && $DBM_AFTER == 0 ]] ; then
    echo "Missing -a or -b parameter."
    return 1
  fi

  return 0




}




# vim: syn=sh filetype=sh
