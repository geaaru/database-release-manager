#!/bin/bash
#------------------------------------------------
# Author(s): Geaaru, geaaru@gmail.com
# $Id$
# License: GPL 2.0
#------------------------------------------------

name="dbm"
dbm_authors="Geaaru"
dbm_creation_date="May 5, 2013"
dbm_version="0.1"

dbm_schema=/home/geaaru/Projects/database-release-manager/etc/dbm_sqlite_schema.sql # TODO Replace this with a placeholder for configure/autotools

dbm_version() {
   echo -en "Version: ${dbm_version}\n"

   return 0
}

dbm_long_help () {

   echo -en "===========================================================================\n"
   echo -en "Module [dbm]:\n"
   echo -en "Author(s): ${dbm_authors}\n"
   echo -en "Created: ${dbm_creation_date}\n"
   echo -en "Version: ${dbm_version}\n"
   echo -en "---------------------------------------------------------------------------\n"
   echo -en "\tlong_help               Show long help informations\n"
   echo -en "\tshow_help               Show command list.\n"
   echo -en "\tversion                 Show module version.\n"
   echo -en "\tshow_releases           Show releases.\n"
   echo -en "\tshow_adapters           Show database adapters\n"
   echo -en "\tshow_script_types       Show script types.\n"
   echo -en "\tshow_scripts            Show scripts.\n"
   echo -en "\tshow_rel_dep            Show release dependencies.\n"
   echo -en "\tshow_inhibit_scripts    Show inhibited scripts.\n"
   echo -en "\tinsert_inhibit_script   Insert a new inhibit script relationship.\n"
   echo -en "\tremove_inhibit_script   Remove an inhibit script relationship.\n"
   echo -en "\tinsert_release          Insert a new release.\n"
   echo -en "\tinsert_script_type      Insert a new script type.\n"
   echo -en "\tinsert_rel_dep          Insert a new release dependency.\n"
   echo -en "\tremove_rel_dep          Remove release dependency.\n"
   echo -en "\tinsert_script           Insert a new script.\n"
   echo -en "\tupdate_script           Update a script by Id.\n"
   echo -en "\tremove_script           Remove script.\n"
   echo -en "---------------------------------------------------------------------------\n"
   echo -en "===========================================================================\n"

   return 0
}


dbm_show_help () {

   echo -en "===========================================================================\n"
   echo -en "Module [dbm]:\n"
   echo -en "---------------------------------------------------------------------------\n"
   echo -en "\tlong_help               Show long help informations\n"
   echo -en "\tshow_releases           Show releases.\n"
   echo -en "\tshow_adapters           Show database adapters\n"
   echo -en "\tshow_script_types       Show script types.\n"
   echo -en "\tshow_scripts            Show scripts.\n"
   echo -en "\tshow_rel_dep            Show release dependencies.\n"
   echo -en "\tshow_inhibit_scripts    Show inhibited scripts.\n"
   echo -en "\tinsert_inhibit_script   Insert a new inhibit script relationship.\n"
   echo -en "\tremove_inhibit_script   Remove an inhibit script relationship.\n"
   echo -en "\tinsert_release          Insert a new release.\n"
   echo -en "\tinsert_script_type      Insert a new script type.\n"
   echo -en "\tinsert_rel_dep          Insert a new release dependency.\n"
   echo -en "\tremove_rel_dep          Remove release dependency.\n"
   echo -en "\tinsert_script           Insert a new script.\n"
   echo -en "\tupdate_script           Update a script by Id.\n"
   echo -en "\tremove_script           Remove script.\n"
   echo -en "===========================================================================\n"

   return 0
}

dbm_show_releases () {

  _sqlite_query -c "$DRM_DB" -q "SELECT COUNT(1) AS R FROM Releases" || error_handled "Unexpected error!"

  local n_rel=$_sqlite_ans

  [[ $DEBUG ]] && echo -en "N. Releases: $n_rel\n"

  if [ x$n_rel != x0 ] ; then

    _sqlite_query -c "$DRM_DB" -q "SELECT id_release,name,version,release_date,creation_date,update_date,id_order,db_adapter FROM Releases ORDER BY id_order ASC" || error_handled "Unexpected error!"

    echo -en "======================================================================================\n"
    echo -en "\e[1;33mID\e[m\t"
    echo -en "\e[1;34mRELEASE_DATE\e[m\t\t"
    echo -en "\e[1;35mVERSION\e[m\t"
    echo -en "\e[1;36mUPDATE_DATE\e[m\t\t"
    echo -en "\e[1;31mADAPTER\e[m\t"
    echo -en "\e[1;37mNAME\e[m\n"
    echo -en "======================================================================================\n"

    IFS=$'\n'
    for row in $_sqlite_ans ; do

      #[[ $DEBUG ]] && echo "ROW = ${row}"

      id_release=`echo $row | awk '{split($0,a,"|"); print a[1]}'`
      name=`echo $row | awk '{split($0,a,"|"); print a[2]}'`
      version=`echo $row | awk '{split($0,a,"|"); print a[3]}'`
      release_date=`echo $row | awk '{split($0,a,"|"); print a[4]}'`
      creation_date=`echo $row | awk '{split($0,a,"|"); print a[5]}'`
      update_date=`echo $row | awk '{split($0,a,"|"); print a[6]}'`
      id_order=`echo $row | awk '{split($0,a,"|"); print a[7]}'`
      db_adapter=`echo $row | awk '{split($0,a,"|"); print a[8]}'`

      if [ ${#release_date} -eq 10 ] ; then
        release_date_tab="\t\t"
      else
        release_date_tab="\t"
      fi

      echo -en "\e[1;33m${id_release}\e[m\t"
      echo -en "\e[1;34m${release_date}${release_date_tab}"
      echo -en "\e[m\e[1;35m${version}\e[m\t"
      echo -en "\e[1;36m${update_date}\e[m\t"
      echo -en "\e[1;31m${db_adapter}\e[m"
      echo -en "\t\e[1;37m${name}\e[m\n"

    done
    unset IFS

  else
    echo -en "No releases available.\n"
  fi

  return 0
}

dbm_show_scripts () {

  _sqlite_query -c "$DRM_DB" -q "SELECT COUNT(1) AS R FROM Scripts" || error_handled "Unexpected error!"

  local n_s=$_sqlite_ans

  [[ $DEBUG ]] && echo -en "N. Scripts: $n_s\n"

  if [ x$n_s != x0 ] ; then

    _sqlite_query -c "$DRM_DB" -q "SELECT id_script,filename,type,active,directory,id_release,id_order,creation_date,update_date FROM Scripts ORDER BY id_release,id_order ASC" || error_handled "Unexpected error!"

    echo -en "======================================================================================\n"
    echo -en "\e[1;33mID\e[m\t"
    echo -en "\e[1;34mFILENAME\e[m\t\t"
    echo -en "\e[1;35mTYPE\e[m\t\t"
    echo -en "\e[1;36mACTIVE\e[m\t\t"
    echo -en "\e[1;31mDIRECTORY\e[m\t"
    echo -en "\e[1;37mID_RELEASE\e[m\t"
    echo -en "\e[1;32mID_ORDER\e[m\t"
    echo -en "\e[1;33mUPDATE_DATE\e[m\n"
    echo -en "======================================================================================\n"

    IFS=$'\n'
    for row in $_sqlite_ans ; do

      #[[ $DEBUG ]] && echo "ROW = ${row}"

      id_script=`echo $row | awk '{split($0,a,"|"); print a[1]}'`
      filename=`echo $row | awk '{split($0,a,"|"); print a[2]}'`
      s_type=`echo $row | awk '{split($0,a,"|"); print a[3]}'`
      active=`echo $row | awk '{split($0,a,"|"); print a[4]}'`
      directory=`echo $row | awk '{split($0,a,"|"); print a[5]}'`
      id_release=`echo $row | awk '{split($0,a,"|"); print a[6]}'`
      id_order=`echo $row | awk '{split($0,a,"|"); print a[7]}'`
      creation_date=`echo $row | awk '{split($0,a,"|"); print a[8]}'`
      update_date=`echo $row | awk '{split($0,a,"|"); print a[9]}'`

      if [ ${#filename} -lt 16 ] ; then
        filename_tab="\t\t"
      else
        filename_tab="\t"
      fi

      echo -en "\e[1;33m${id_script}\e[m\t"
      echo -en "\e[1;34m${filename}${filename_tab}\e[m"
      echo -en "\e[1;35m${s_type}\e[m\t"
      echo -en "\e[1;36m${active}\e[m\t\t"
      echo -en "\e[1;31m${directory}\e[m\t"
      echo -en "\e[1;37m${id_release}\e[m\t\t"
      echo -en "\e[1;32m${id_order}\e[m\t\t"
      echo -en "\e[1;33m${update_date}\e[m\n"

    done
    unset IFS

  else
    echo -en "No scripts available.\n"
  fi

  return 0
}

dbm_show_script_types () {

  _sqlite_query -c "$DRM_DB" -q "SELECT COUNT(1) AS R FROM ScriptTypes" || error_handled "Unexpected error!"

  local n_st=$_sqlite_ans

  [[ $DEBUG ]] && echo -en "N. ScriptTypes: $n_st\n"

  if [ x$n_st != x0 ] ; then

    _sqlite_query -c "$DRM_DB" -q "SELECT code,descr FROM ScriptTypes ORDER BY code ASC" || error_handled "Unexpected error!"

    echo -en "======================================================================================\n"
    echo -en "\e[1;33mCODE\e[m\t\t\e[1;34mDESCRIPTION\e[m\n"
    echo -en "======================================================================================\n"

    IFS=$'\n'
    for row in $_sqlite_ans ; do

      #[[ $DEBUG ]] && echo "ROW = ${row}"

      code=`echo $row | awk '{split($0,a,"|"); print a[1]}'`
      descr=`echo $row | awk '{split($0,a,"|"); print a[2]}'`

      if [ ${#code} -gt 7 ] ; then
        code_tab="\t"
      else
        code_tab="\t\t"
      fi

      echo -en "\e[1;33m${code}\e[m${code_tab}\e[1;34m${descr}\e[m\n"

    done
    unset IFS

  else

    echo -en "No script types available.\n"
  fi

  return 0
}

dbm_show_rel_dep () {

  _sqlite_query -c "$DRM_DB" -q "SELECT COUNT(1) AS R FROM ReleasesDependencies" || error_handled "Unexpected error!"

  local n_rd=$_sqlite_ans

  [[ $DEBUG ]] && echo -en "N. ReleasesDependencies: $n_rd\n"

  if [ x$n_rd != x0 ] ; then

    _sqlite_query -c "$DRM_DB" -q "SELECT id_release,id_release_dep,creation_date FROM ReleasesDependencies ORDER BY id_release,id_release_dep ASC" || error_handled "Unexpected error!"

    echo -en "======================================================================================\n"
    echo -en "\e[1;33mID_RELEASE\e[m\t"
    echo -en "\e[1;32mDEPENDENCY\e[m\t"
    echo -en "\e[1;34mCREATION_DATE\e[m\n"
    echo -en "======================================================================================\n"

    IFS=$'\n'
    for row in $_sqlite_ans ; do

      #[[ $DEBUG ]] && echo "ROW = ${row}"

      id_release=`echo $row | awk '{split($0,a,"|"); print a[1]}'`
      id_release_dep=`echo $row | awk '{split($0,a,"|"); print a[2]}'`
      creation_date=`echo $row | awk '{split($0,a,"|"); print a[3]}'`

      echo -en "\e[1;33m${id_release}\e[m\t\t"
      echo -en "\e[1;32m${id_release_dep}\e[m\t\t"
      echo -en "\e[1;34m${creation_date}\e[m\n"

    done
    unset IFS

  else

    echo -en "No release dependencies available.\n"

  fi

  return 0
}

dbm_show_inhibit_scripts () {

  _sqlite_query -c "$DRM_DB" -q "SELECT COUNT(1) AS R FROM ScriptRelInhibitions" || error_handled "Unexpected error!"

  local n_r=$_sqlite_ans

  [[ $DEBUG ]] && echo -en "N. ScriptRelInhibitions: $n_r\n"

  if [ x$n_r != x0 ] ; then

    _sqlite_query -c "$DRM_DB" -q "SELECT id_script,id_release_from,id_release_to,creation_date FROM ScriptRelInhibitions ORDER BY id_script,id_release_to,id_release_from ASC" || error_handled "Unexpected error!"

    echo -en "======================================================================================\n"
    echo -en "\e[1;33mID_SCRIPT\e[m\t"
    echo -en "\e[1;32mID_RELEASE_FROM\e[m\t\t"
    echo -en "\e[1;31mID_RELEASE_TO\e[m\t"
    echo -en "\e[1;34mCREATION_DATE\e[m\n"
    echo -en "======================================================================================\n"

    IFS=$'\n'
    for row in $_sqlite_ans ; do

      #[[ $DEBUG ]] && echo "ROW = ${row}"

      id_script=`echo $row | awk '{split($0,a,"|"); print a[1]}'`
      id_release_from=`echo $row | awk '{split($0,a,"|"); print a[2]}'`
      id_release_to=`echo $row | awk '{split($0,a,"|"); print a[3]}'`
      creation_date=`echo $row | awk '{split($0,a,"|"); print a[4]}'`

      echo -en "\e[1;33m${id_script}\e[m\t\t"
      echo -en "\e[1;32m${id_release_from}\e[m\t\t\t"
      echo -en "\e[1;31m${id_release_to}\e[m\t\t"
      echo -en "\e[1;34m${creation_date}\e[m\n"

    done
    unset IFS

  else

    echo -en "No scripts available.\n"

  fi

  return 0
}


dbm_show_adapters  () {

  _sqlite_query -c "$DRM_DB" -q "SELECT COUNT(1) AS R FROM DatabaseAdapters" || error_handled "Unexpected error!"

  local n_st=$_sqlite_ans

  [[ $DEBUG ]] && echo -en "N. ScriptTypes: $n_st\n"

  if [ x$n_st != x0 ] ; then

    _sqlite_query -c "$DRM_DB" -q "SELECT adapter,descr FROM DatabaseAdapters ORDER BY adapter ASC" || error_handled "Unexpected error!"

    echo -en "======================================================================================\n"
    echo -en "\e[1;33mADAPTER\e[m\t\t\e[1;34mDESCRIPTION\e[m\n"
    echo -en "======================================================================================\n"

    IFS=$'\n'
    for row in $_sqlite_ans ; do

      adapter=`echo $row | awk '{split($0,a,"|"); print a[1]}'`
      descr=`echo $row | awk '{split($0,a,"|"); print a[2]}'`

      if [ ${#code} -gt 7 ] ; then
        adapter_tab="\t"
      else
        adapter_tab="\t\t"
      fi

      echo -en "\e[1;33m${adapter}\e[m${adapter_tab}\e[1;34m${descr}\e[m\n"

    done
    unset IFS

  else

    echo -en "No adapters available.\n"
  fi

  return 0
}


dbm_insert_release () {

  local result=1
  local query=""

  # Shift first two input param
  shift 2

  _dbm_check_ins_rel_args "$@" || return $result

  if [ -z "$DBM_REL_ORDER" ] ; then

    query="INSERT INTO Releases (name,version,release_date,db_adapter,creation_date,update_date,id_order) \
      VALUES ('$DBM_REL_NAME', '$DBM_REL_VERSION' ,$DBM_REL_DATE,'$DBM_REL_ADAPTER',DATETIME('now'),DATETIME('now'), \
      (SELECT T.ID FROM (SELECT MAX(ID_RELEASE)+1 AS ID, 1 AS T from Releases UNION SELECT 1 AS ID, 0 AS T) T WHERE ID IS NOT NULL ORDER BY T.T DESC LIMIT 1))"

  else
    query="INSERT INTO Releases (name,version,release_date,db_adapter,creation_date,update_date,id_order) \
      VALUES ('$DBM_REL_NAME','$DBM_REL_VERSION',$DBM_REL_DATE,'$DBM_REL_ADAPTER',DATETIME('now'),DATETIME('now'), $DBM_REL_ORDER) "
  fi

  _sqlite_query -c "$DRM_DB" -q "$query" || error_handled "Unexpected error!"
  ans=$?

  if [ x"$ans" = x"0" ] ; then
    echo "Release $DBM_REL_NAME v. $DBM_REL_VERSION insert correctly."
  fi

  result=$ans

  return $result
}

dbm_remove_script () {

  local result=1
  local query=""

  # Shift first two input param
  shift 2

  _dbm_check_rm_script_args "$@" || return $result

  query="DELETE FROM ScriptRelInhibitions WHERE id_script = $DBM_SCRIPT_ID; DELETE FROM Scripts WHERE id_script = $DBM_SCRIPT_ID"

  _sqlite_query -c "$DRM_DB" -q "$query" || error_handled "Unexpected error!"
  ans=$?

  if [ x"$ans" = x"0" ] ; then
    echo "Script $DBM_SCRIPT_ID removed correctly."
  fi

  result=$ans

  return $result
}

dbm_update_script () {

  local result=1
  local query=""
  local query_sub=""
  local upd_elems=0

  # Shift first two input param
  shift 2

  _dbm_check_upd_script_args "$@" || return $result

  if [ ! -z "$DBM_SCRIPT_FILENAME" ] ; then

    if [ $upd_elems -eq 0 ] ; then
      query_sub="SET filename = '$DBM_SCRIPT_FILENAME'"
    else
      query_sub="${query_sub}, filename = '$DBM_SCRIPT_FILENAME'"
    fi

    let upd_elems++

  fi

  if [ ! -z "$DBM_SCRIPT_TYPE" ] ; then

    if [ $upd_elems -eq 0 ] ; then
      query_sub="SET type = '$DBM_SCRIPT_TYPE'"
    else
      query_sub="${query_sub}, type = '$DBM_SCRIPT_TYPE'"
    fi

    let upd_elems++

  fi

  if [ ! -z "$DBM_SCRIPT_ACTIVE" ] ; then

    if [ $upd_elems -eq 0 ] ; then
      query_sub="SET active = '$DBM_SCRIPT_ACTIVE'"
    else
      query_sub="${query_sub}, active = '$DBM_SCRIPT_ACTIVE'"
    fi

    let upd_elems++

  fi

  if [ ! -z "$DBM_SCRIPT_DIRECTORY" ] ; then

    if [ $upd_elems -eq 0 ] ; then
      query_sub="SET directory = '$DBM_SCRIPT_DIRECTORY'"
    else
      query_sub="${query_sub}, directory = '$DBM_SCRIPT_DIRECTORY'"
    fi

    let upd_elems++

  fi

  if [ -z "$DBM_SCRIPT_ID_RELEASE" ] ; then

    if [[ ! -z "$DBM_SCRIPT_REL_VERSION" && ! -z "$DBM_SCRIPT_REL_NAME" ]] ; then

      id_rel_query="(SELECT id_release FROM Releases \
        WHERE name = '$DBM_SCRIPT_REL_NAME' AND version = '$DBM_SCRIPT_REL_VERSION')"
      if [ $upd_elems -eq 0 ] ; then
        query_sub="SET id_release = $id_rel_query"
      else
        query_sub="${query_sub}, id_release = $id_rel_query"
      fi

      let upd_elems++

    fi

  else

    if [ $upd_elems -eq 0 ] ; then
      query_sub="SET id_release = '$DBM_SCRIPT_ID_RELEASE'"
    else
      query_sub="${query_sub}, id_release = '$DBM_SCRIPT_ID_RELEASE'"
    fi

    let upd_elems++

  fi

  if [ ! -z "$DBM_SCRIPT_ID_ORDER" ] ; then

    if [ $upd_elems -eq 0 ] ; then
      query_sub="SET id_order = '$DBM_SCRIPT_ID_ORDER'"
    else
      query_sub="${query_sub}, id_order = '$DBM_SCRIPT_ID_ORDER'"
    fi

    let upd_elems++

  fi

  if [ $upd_elems -gt 0 ] ; then

    query="UPDATE Scripts ${query_sub}, update_date = DATETIME('now') WHERE id_script = $DBM_SCRIPT_ID"
    _sqlite_query -c "$DRM_DB" -q "$query" || error_handled "Unexpected error!"
    ans=$?

    if [ x"$ans" = x"0" ] ; then
      echo "Script $DBM_SCRIPT_ID updated correctly."
    fi

    result=$ans

  else

    echo -en "No elements to update for script $DBM_SCRIPT_ID.\n"

  fi

  return $result
}

dbm_insert_script () {

  local result=1
  local query=""
  local id_rel_query=""

  # Shift first two input param
  shift 2

  _dbm_check_ins_script_args "$@" || return $result

  if [ -z "$DBM_SCRIPT_ID_RELEASE" ] ; then
    id_rel_query="(SELECT id_release FROM Releases WHERE name = '$DBM_SCRIPT_REL_NAME' AND version = '$DBM_SCRIPT_REL_VERSION')"
  else
    id_rel_query="$DBM_SCRIPT_ID_RELEASE"
  fi

  query="INSERT INTO Scripts (filename,type,active,directory,id_release,creation_date,update_date,id_order) \
    VALUES ('$DBM_SCRIPT_FILENAME', '$DBM_SCRIPT_TYPE' ,$DBM_SCRIPT_ACTIVE,'$DBM_SCRIPT_DIRECTORY', \
    $id_rel_query, DATETIME('now'),DATETIME('now'),"

  if [ -z "$DBM_SCRIPT_ID_ORDER" ] ; then

    query="${query} (SELECT T.ID FROM \
      ( \
      SELECT MAX(ID_ORDER)+1 AS ID, 1 AS T FROM Scripts \
      WHERE ID_RELEASE = $id_rel_query \
      UNION SELECT 1 AS ID, 0 AS T \
      ) T WHERE ID IS NOT NULL ORDER BY T.T DESC LIMIT 1))"

  else

    query="${query} ${DBM_SCRIPT_ID_ORDER})"

  fi

  _sqlite_query -c "$DRM_DB" -q "$query" || error_handled "Unexpected error!"
  ans=$?

  if [ x"$ans" = x"0" ] ; then
    echo "Script $DBM_SCRIPT_FILENAME insert correctly."
  fi

  result=$ans

  return $result
}

dbm_insert_script_type () {

  local result=1
  local query=""

  # Shift first two input param
  shift 2

  _dbm_check_ins_script_type_args "$@" || return $result

  query="INSERT INTO ScriptTypes (code,descr) VALUES ('$DBM_SCRIPT_TYPE_CODE', '$DBM_SCRIPT_TYPE_DESCR')";

  _sqlite_query -c "$DRM_DB" -q "$query" || error_handled "Unexpected error!"
  ans=$?

  if [ x"$ans" = x"0" ] ; then
    echo "Script Type $DBM_SCRIPT_TYPE_CODE insert correctly."
  fi

  result=$ans

  return $result
}

dbm_insert_rel_dep () {

  local result=1
  local query=""
  local id_rel_query_to=""
  local id_rel_query_from=""

  # Shift first two input param
  shift 2

  _dbm_check_rel_dep_args "$@" || return $result

  id_rel_query_to="(SELECT id_release FROM Releases WHERE name = '$DBM_REL_NAME' AND version = '$DBM_REL_VERSION_TO')"
  id_rel_query_from="(SELECT id_release FROM Releases WHERE name = '$DBM_REL_NAME' AND version = '$DBM_REL_VERSION_FROM')"

  query="INSERT INTO ReleasesDependencies (id_release,id_release_dep,creation_date) \
    VALUES (${id_rel_query_to}, ${id_rel_query_from}, DATETIME('now'))"

  _sqlite_query -c "$DRM_DB" -q "$query" || error_handled "Unexpected error!"
  ans=$?

  if [ x"$ans" = x"0" ] ; then
    echo "Insert release dependencty to $DBM_REL_NAME v.$DBM_REL_VERSION_TO correctly."
  fi

  result=$ans

  return $result
}

dbm_remove_rel_dep () {

  local result=1
  local query=""
  local id_rel_query_to=""
  local id_rel_query_from=""

  # Shift first two input param
  shift 2

  _dbm_check_rel_dep_args "$@" || return $result

  id_rel_query_to="(SELECT id_release FROM Releases WHERE name = '$DBM_REL_NAME' AND version = '$DBM_REL_VERSION_TO')"
  id_rel_query_from="(SELECT id_release FROM Releases WHERE name = '$DBM_REL_NAME' AND version = '$DBM_REL_VERSION_FROM')"

  query="DELETE FROM ReleasesDependencies \
    WHERE id_release = ${id_rel_query_to} AND id_release_dep = ${id_rel_query_from}"

  _sqlite_query -c "$DRM_DB" -q "$query" || error_handled "Unexpected error!"
  ans=$?

  if [ x"$ans" = x"0" ] ; then
    echo "Remove release dependencty to $DBM_REL_NAME v.$DBM_REL_VERSION_TO with $DBM_REL_VERSION_FROM correctly."
  fi

  result=$ans

  return $result
}

dbm_insert_inhibit_script () {

  local result=1
  local query=""
  local id_rel_query_to=""
  local id_rel_query_from=""

  # Shift first two input param
  shift 2

  _dbm_check_inhibit_script_args "$@" || return $result

  id_rel_query_to="(SELECT id_release FROM Releases WHERE name = '$DBM_REL_NAME' AND version = '$DBM_REL_VERSION_TO')"
  id_rel_query_from="(SELECT id_release FROM Releases WHERE name = '$DBM_REL_NAME' AND version = '$DBM_REL_VERSION_FROM')"

  query="INSERT INTO ScriptRelInhibitions (id_script,id_release_from,id_release_to,creation_date) \
    VALUES ($DBM_SCRIPT_ID, ${id_rel_query_from}, ${id_rel_query_to}, DATETIME('now'))"

  _sqlite_query -c "$DRM_DB" -q "$query" || error_handled "Unexpected error!"
  ans=$?

  if [ x"$ans" = x"0" ] ; then
    echo "Record insert correctly."
  fi

  result=$ans

  return $result
}

dbm_remove_inhibit_script () {

  local result=1
  local query=1
  local id_rel_query_to=""
  local id_rel_query_from=""

  # Shift first two input param
  shift 2

  _dbm_check_inhibit_script_args "$@" || return $result

  id_rel_query_to="(SELECT id_release FROM Releases WHERE name = '$DBM_REL_NAME' AND version = '$DBM_REL_VERSION_TO')"
  id_rel_query_from="(SELECT id_release FROM Releases WHERE name = '$DBM_REL_NAME' AND version = '$DBM_REL_VERSION_FROM')"

  query="DELETE FROM ScriptRelInhibitions \
    WHERE id_script = $DBM_SCRIPT_ID \
    AND id_release_from = ${id_rel_query_from} \
    AND id_release_to = ${id_rel_query_to}"

  _sqlite_query -c "$DRM_DB" -q "$query" || error_handled "Unexpected error!"
  ans=$?

  if [ x"$ans" = x"0" ] ; then
    echo "Record removed correctly."
  fi

  result=$ans

  return $result
}



##################################################################
# Internal functions
##################################################################

_dbm_check_ins_rel_args () {

  [[ $DEBUG ]] && echo -en "(_dbm_check_ins_rel_args args: $@)\n"

  # Reinitialize opt index position
  OPTIND=1
  while getopts "n:d:v:o:ha:" opts "$@" ; do
    case $opts in

      n) DBM_REL_NAME="$OPTARG";;
      d) DBM_REL_DATE="$OPTARG";;
      v) DBM_REL_VERSION="$OPTARG";;
      o) DBM_REL_ORDER="$OPTARG";;
      a) DBM_REL_ADAPTER="$OPTARG";;
      h)
        echo -en "[-n name]               Release Name.\n"
        echo -en "[-d YYYY-MM-DD]         Release Date. (Use now if not available)\n"
        echo -en "[-v version]            Release Version\n"
        echo -en "[-a adapter]            Release Adapter (default is Oracle).\n"
        echo -en "[-o id_order]           Release Id Order (optional).\n"
        return 1
        ;;

    esac
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

  if [ -z "$DBM_REL_VERSION" ] ; then
    echo "Missing Release Verion"
    return 1
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

_dbm_check_inhibit_script_args () {

  [[ $DEBUG ]] && echo -en "(_dbm_check_ins_inhibit_script_args args: $@)\n"

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

#_dbm_init() {
#}

_dbm_post_init () {

  # Check if exists DRM_DB
  [[ $DEBUG ]] && echo "(dbm_post_init: Check if is present sqlite internal db file: $DRM_DB)"
  if [[ ! -e $DRM_DB ]] ; then

    [[ $DEBUG ]] && echo "(dbm_post_init: Create sqlite internal db file: $DRM_DB)"
    _sqlite_create -c "$DRM_DB" -s "$dbm_schema" || error_handled "Error on create $DRM_DB file."

  fi

}

# vim: syn=sh filetype=sh
