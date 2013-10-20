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
   echo -en "\tshow_rel_ded_scripts    Show release dedicated scripts.\n"
   echo -en "\tinsert_inhibit_script   Insert a new inhibit script relationship.\n"
   echo -en "\tremove_inhibit_script   Remove an inhibit script relationship.\n"
   echo -en "\tinsert_ded_script       Insert a new release dedicated script relationship.\n"
   echo -en "\tremove_ded_script       Remove a release dedicated script relationship.\n"
   echo -en "\tinsert_release          Insert a new release.\n"
   echo -en "\tmove_release            Move release position.\n"
   echo -en "\tupdate_release          Update a release data.\n"
   echo -en "\tremove_release          Remove a release.\n"
   echo -en "\tinsert_script_type      Insert a new script type.\n"
   echo -en "\tinsert_rel_dep          Insert a new release dependency.\n"
   echo -en "\tremove_rel_dep          Remove release dependency.\n"
   echo -en "\tinsert_script           Insert a new script.\n"
   echo -en "\tupdate_script           Update a script by Id.\n"
   echo -en "\tremove_script           Remove script.\n"
   echo -en "\tmove_script             Move script.\n"
   echo -en "\tshow_branches           Show branches.\n"
   echo -en "\tinsert_branch           Insert a new branch.\n"
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
   echo -en "\tshow_rel_ded_scripts    Show release dedicated scripts.\n"
   echo -en "\tinsert_inhibit_script   Insert a new inhibit script relationship.\n"
   echo -en "\tremove_inhibit_script   Remove an inhibit script relationship.\n"
   echo -en "\tinsert_ded_script       Insert a new release dedicated script relationship.\n"
   echo -en "\tremove_ded_script       Remove a release dedicated script relationship.\n"
   echo -en "\tinsert_release          Insert a new release.\n"
   echo -en "\tmove_release            Move release position.\n"
   echo -en "\tupdate_release          Update a release data .\n"
   echo -en "\tremove_release          Remove a release.\n"
   echo -en "\tinsert_script_type      Insert a new script type.\n"
   echo -en "\tinsert_rel_dep          Insert a new release dependency.\n"
   echo -en "\tremove_rel_dep          Remove release dependency.\n"
   echo -en "\tinsert_script           Insert a new script.\n"
   echo -en "\tupdate_script           Update a script by Id.\n"
   echo -en "\tremove_script           Remove script.\n"
   echo -en "\tmove_script             Move script.\n"
   echo -en "\tshow_branches           Show branches.\n"
   echo -en "\tinsert_branch           Insert a new branch.\n"
    echo -en "===========================================================================\n"

   return 0
}

dbm_show_releases () {

  _sqlite_query -c "$DRM_DB" -q "SELECT COUNT(1) AS R FROM Releases" || error_handled "Unexpected error!"

  local n_rel=$_sqlite_ans
  local id_release=""
  local name=""
  local version=""
  local release_date=""
  local creation_date=""
  local update_date=""
  local id_order=""
  local db_adapter=""
  local id_branch=""
  local directory=""
  local query="
    SELECT id_release,name,version,release_date,
           creation_date,update_date,id_order,
           db_adapter,id_branch,directory
    FROM Releases ORDER BY id_order ASC"

  [[ $DEBUG ]] && echo -en "N. Releases: $n_rel\n"

  if [ x$n_rel != x0 ] ; then

    _sqlite_query -c "$DRM_DB" -q "$query" || error_handled "Unexpected error!"

    echo -en "==============================================================================================================================\n"
    echo -en "\e[1;33mID\e[m\t"
    echo -en "\e[1;34mRELEASE_DATE\e[m\t\t"
    echo -en "\e[1;35mVERSION\e[m\t"
    echo -en "\e[1;36mUPDATE_DATE\e[m\t\t"
    echo -en "\e[1;31mADAPTER\e[m\t\t"
    echo -en "\e[1;32mID_ORDER\e[m\t"
    echo -en "\e[1;38mBRANCH\e[m\t"
    echo -en "\e[1;33mDIRECTORY\e[m\t"
    echo -en "\e[1;37mNAME\e[m\n"
    echo -en "==============================================================================================================================\n"

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
      id_branch=`echo $row | awk '{split($0,a,"|"); print a[9]}'`
      directory=`echo $row | awk '{split($0,a,"|"); print a[10]}'`

      if [ ${#release_date} -eq 10 ] ; then
        release_date_tab="\t\t"
      else
        release_date_tab="\t"
      fi

      echo -en "\e[1;33m${id_release}\e[m\t"
      echo -en "\e[1;34m${release_date}${release_date_tab}\e[m"
      echo -en "\e[1;35m${version}\e[m\t"
      echo -en "\e[1;36m${update_date}\e[m\t"
      echo -en "\e[1;31m${db_adapter}\e[m\t\t"
      echo -en "\e[1;32m${id_order}\e[m\t\t"
      echo -en "\e[1;38m${id_branch}\e[m\t"
      echo -en "\e[1;33m${directory}\e[m\t\t"
      echo -en "\e[1;37m${name}\e[m\n"

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

    echo -en "===================================================================================================================================\n"
    echo -en "\e[1;33mID\e[m\t"
    echo -en "\e[1;35mTYPE\e[m\t\t"
    echo -en "\e[1;36mACTIVE\e[m\t"
    echo -en "\e[1;31mDIRECTORY\e[m\t\t"
    echo -en "\e[1;37mID_RELEASE\e[m\t"
    echo -en "\e[1;32mID_ORDER\e[m\t"
    echo -en "\e[1;33mUPDATE_DATE\e[m\t\t"
    echo -en "\e[1;34mFILENAME\e[m\n"
    echo -en "===================================================================================================================================\n"

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

      if [ ${#s_type} -lt 8 ] ; then
        type_tab="\t\t"
      else
        type_tab="\t"
      fi

      if [ ${#directory} -lt 15 ] ; then
        dir_tab="\t\t"
      else
        dir_tab="\t"
      fi

      echo -en "\e[1;33m${id_script}\e[m\t"
      echo -en "\e[1;35m${s_type}${type_tab}\e[m"
      echo -en "\e[1;36m${active}\e[m\t"
      echo -en "\e[1;31m${directory}${dir_tab}\e[m"
      echo -en "\e[1;37m${id_release}\e[m\t\t"
      echo -en "\e[1;32m${id_order}\e[m\t\t"
      echo -en "\e[1;33m${update_date}\e[m\t"
      echo -en "\e[1;34m${filename}\e[m\n"

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

dbm_show_rel_ded_scripts () {

  _sqlite_query -c "$DRM_DB" -q "SELECT COUNT(1) AS R FROM ScriptRelDedicated" || error_handled "Unexpected error!"

  local n_r=$_sqlite_ans

  [[ $DEBUG ]] && echo -en "N. ScriptRelDedicated: $n_r\n"

  if [ x$n_r != x0 ] ; then

    _sqlite_query -c "$DRM_DB" -q "SELECT id_script,id_release_from,id_release_to,creation_date FROM ScriptRelDedicated ORDER BY id_script,id_release_to,id_release_from ASC" || error_handled "Unexpected error!"

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

dbm_move_release () {

  local result=1
  local query=""
  local id_rel_to=""
  local id_rel_from=""
  local id_order=""
  local id_order_to=""
  local create_tmp_table=""
  local where_moved_record=""
  local insert2tmp=""
  local delete_rel=""

  # Shift first two input param
  shift 2

  _dbm_check_move_release_args "$@" || return $result

  _dbm_check_if_exist_rel "$DBM_REL_NAME" "$DBM_REL_VERSION_TO" || return $result
  _dbm_check_if_exist_rel "$DBM_REL_NAME" "$DBM_REL_VERSION_FROM" || return $result

  # Retrive id order of the release from
  _dbm_retrieve_field_rel "id_order" "$DBM_REL_NAME" "$DBM_REL_VERSION_FROM"
  id_order=$_sqlite_ans

  # Retrieve id order of the release to
  _dbm_retrieve_field_rel "id_order" "$DBM_REL_NAME" "$DBM_REL_VERSION_TO"
  id_order_to=$_sqlite_ans

  # Retrieve id release from
  _dbm_retrieve_field_rel "id_release" "$DBM_REL_NAME" "$DBM_REL_VERSION_FROM"
  id_rel_from=$_sqlite_ans

  # Retrieve id release to
  _dbm_retrieve_field_rel "id_release" "$DBM_REL_NAME" "$DBM_REL_VERSION_TO"
  id_rel_to=$_sqlite_ans

  _dbm_get_table_schema 'Releases'
  create_tmp_table="$(echo "$_sqlite_ans" | sed 's/TABLE Releases/TABLE ReleasesTemp/')"

  if [ $DBM_AFTER -eq 1 ] ; then

    if [ $id_order_to -lt $id_order ] ; then

      where_moved_record="WHERE ( id_order > $id_order_to AND id_order < $id_order )"

      insert2tmp="INSERT INTO ReleasesTemp
        SELECT id_release,name,version,release_date,creation_date,update_date,$id_order_to+1 as id_order,db_adapter,id_branch
        FROM Releases WHERE id_release = $id_rel_from ;
        INSERT INTO ReleasesTemp
        SELECT id_release,name,version,release_date,creation_date,update_date,id_order+1 as id_order,db_adapter,id_branch
        FROM Releases $where_moved_record "
      # POST: Move yet release_from to Temporary table

    else

      where_moved_record="WHERE id_order > $id_order "
      # POST: Move yet release_from to Temporary table

      insert2tmp="INSERT INTO ReleasesTemp
        SELECT id_release,name,version,release_date,creation_date,update_date,id_order-1 as id_order,db_adapter,id_branch
        FROM Releases WHERE id_order > $id_order AND id_order <= $id_order_to ;
        INSERT INTO ReleasesTemp
        SELECT id_release,name,version,release_date,creation_date,update_date,id_order as id_order,db_adapter,id_branch
        FROM Releases WHERE id_order > $id_order_to ;
        INSERT INTO ReleasesTemp
        SELECT id_release,name,version,release_date,creation_date,update_date,$id_order_to as id_order,db_adapter,id_branch
        FROM Releases WHERE id_release = $id_rel_from "

    fi

    t="after"

    result=0

  else

    if [ $id_order_to -lt $id_order ] ; then

      where_moved_record="WHERE id_order < $id_order AND id_order >= $id_order_to "

      insert2tmp="INSERT INTO ReleasesTemp
        SELECT id_release,name,version,release_date,creation_date,update_date,id_order+1 as id_order,db_adapter
        FROM Releases $where_moved_record ;
        INSERT INTO ReleasesTemp
        SELECT id_release,name,version,release_date,creation_date,update_date,$id_order_to as id_order,db_adapter
        FROM Releases WHERE id_release = $id_rel_from "
      # POST: Move yet release_from to Temporary table


    else

      where_moved_record="WHERE id_order < $id_order_to AND id_order > $id_order "

      insert2tmp="INSERT INTO ReleasesTemp
        SELECT id_release,name,version,release_date,creation_date,update_date,id_order-1 as id_order,db_adapter
        FROM Releases $where_moved_record ;
        INSERT INTO ReleasesTemp
        SELECT id_release,name,version,release_date,creation_date,update_date,$id_order_to-1 as id_order,db_adapter
        FROM Releases WHERE id_release = $id_rel_from "
      # POST: Move yet release_from to Temporary table

    fi

    t="before"
    result=0

  fi

  delete_rel="DELETE FROM Releases $where_moved_record OR id_order = $id_order"

  # Disable PRAGMA options
  SQLITEDB_INIT_SESSION=" "

  query="DROP TABLE IF EXISTS ReleasesTemp ;
    $create_tmp_table ;
    ${insert2tmp} ;
    ${delete_rel} ;
    INSERT INTO Releases SELECT id_release,name,version,release_date,creation_date,DATETIME('now'),id_order,db_adapter FROM ReleasesTemp;
    DROP TABLE ReleasesTemp "

  #  SELECT * FROM ReleasesTemp ;
  #  SELECT '-'  ;
  #  SELECT * FROM Releases ;
  _sqlite_query -c "$DRM_DB" -q "$query" || error_handled "Unexpected error on update id_order fields."

  # Re-enable PRAGMA options
  unset SQLITEDB_INIT_SESSION

  echo -en "Moved correctly $DBM_REL_NAME v.$DBM_REL_VERSION_FROM ${t} v.$DBM_REL_VERSION_TO.\n"

  return $result
}

dbm_update_release () {

  local result=1
  local query="UPDATE Releases SET "
  local count=0

  # Shift first two input param
  shift 2

  _dbm_check_upd_release_args "$@" || return $result

  if [ -n "$DBM_REL_NAME" ] ; then

    query="$query name = '${DBM_REL_NAME}'"
    let count++

  fi

  if [ -n "$DBM_REL_DATE" ] ; then

    if [ $count -eq 0 ] ; then
      query="$query release_date = '${DBM_REL_DATE}'"
    else
      query="$query , release_date = '${DBM_REL_DATE}'"
    fi
    let count++

  fi

  if [ -n "$DBM_REL_VERSION" ] ; then

    if [ $count -eq 0 ] ; then
      query="$query version = '${DBM_REL_VERSION}'"
    else
      query="$query , version = '${DBM_REL_VERSION}'"
    fi
    let count++

  fi

  if [ -n "$DBM_REL_ADAPTER" ] ; then

    if [ $count -eq 0 ] ; then
      query="$query db_adapter = '${DBM_REL_ADAPTER}'"
    else
      query="$query , db_adapter = '${DBM_REL_ADAPTER}'"
    fi
    let count++

  fi

  if [ -n "$DBM_REL_BRANCH" ] ; then

    if [ $count -eq 0 ] ; then
      query="$query id_branch = ${DBM_REL_BRANCH}"
    else
      query="$query , id_branch = ${DBM_REL_BRANCH}"
    fi
    let count++

  fi

  if [ -n "$DBM_REL_DIR" ] ; then

    if [ $count -eq 0 ] ; then
      query="$query directory = '${DBM_REL_DIR}'"
    else
      query="$query , directory = '${DBM_REL_DIR}'"
    fi
  fi

  query="$query WHERE id_release = $DBM_REL_ID"

  _sqlite_query -c "$DRM_DB" -q "$query" || error_handled "Error on update release $DBM_REL_ID."
  ans=$?

  if [ x"$ans" = x"0" ] ; then
    echo "Release $DBM_REL_ID updated correctly."
    result=0
  fi

  return $result
}

dbm_insert_release () {

  local result=1
  local query=""
  local id_branch=""

  # Shift first two input param
  shift 2

  _dbm_check_ins_rel_args "$@" || return $result

  if [ -z "$DBM_REL_BRANCH" ] ; then

    id_branch="(SELECT id_branch FROM Branches WHERE name = 'master')"

  else

    _dbm_check_if_exist_id_branch "$DBM_REL_BRANCH"
    id_branch="$DBM_REL_BRANCH"

  fi

  if [ -z "$DBM_REL_ORDER" ] ; then

    query="INSERT INTO Releases
      (name,version,release_date,db_adapter,creation_date,
       update_date,id_order, id_branch,directory)
      VALUES
      ('$DBM_REL_NAME', '$DBM_REL_VERSION' ,$DBM_REL_DATE,'$DBM_REL_ADAPTER',DATETIME('now'),
       DATETIME('now'),
       (SELECT T.ID FROM (
        SELECT MAX(ID_RELEASE)+1 AS ID, 1 AS T from Releases
        WHERE id_branch = $id_branch
        UNION SELECT 1 AS ID, 0 AS T
        ) T
       WHERE ID IS NOT NULL ORDER BY T.T DESC LIMIT 1),
       $id_branch, '$DBM_REL_DIR')"

  else
    query="INSERT INTO Releases
      (name,version,release_date,db_adapter,creation_date,
       update_date,id_order, id_branch,directory)
      VALUES
      ('$DBM_REL_NAME','$DBM_REL_VERSION',$DBM_REL_DATE,'$DBM_REL_ADAPTER',DATETIME('now'),
       DATETIME('now'), $DBM_REL_ORDER, $id_branch, '$DBM_REL_DIR')"
  fi

  _sqlite_query -c "$DRM_DB" -q "$query" || error_handled "Unexpected error!"
  ans=$?

  if [ x"$ans" = x"0" ] ; then
    echo "Release $DBM_REL_NAME v. $DBM_REL_VERSION insert correctly."
  fi

  result=$ans

  return $result
}

dbm_remove_release () {

  local result=1
  local query=""
  local id_branch=""
  local cnt=""

  # Shift first two input param
  shift 2

  _dbm_check_rem_rel_args "$@" || return $result

  # Retrive id branch of the release
  _dbm_retrieve_field_rel_byid "id_branch" "$DBM_REL_ID"
  id_branch=$_sqlite_ans

  # Check if there is some dependency with release
  query="SELECT count(1) AS CNT
    FROM ReleasesDependencies
    WHERE id_release_dep = $DBM_REL_ID"

  _sqlite_query -c "$DRM_DB" -q "$query" || error_handled "Unexpected error on check for dependencies"
  cnt=$_sqlite_ans

  if [ $cnt -ne 0 ] ; then

    error_handled "There are dependencies with release $DBM_REL_ID. You must remove these dependencies before remove release $DBM_REL_ID."

  fi

  _dbm_remove_all_scripts_rel_ded $DBM_REL_ID || error_handled "Unexpected error on remove all scripts from ScriptRelDedicated table"


  _dbm_remove_all_scripts_rel_inhib  $DBM_REL_ID || error_handled "Unexpected error on remove all scripts from ScriptRelInhibitions table"

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

dbm_insert_ded_script () {

  local result=1
  local query=""
  local id_rel_query_to=""
  local id_rel_query_from=""

  # Shift first two input param
  shift 2

  _dbm_check_inhibit_script_args "$@" || return $result

  id_rel_query_to="(SELECT id_release FROM Releases WHERE name = '$DBM_REL_NAME' AND version = '$DBM_REL_VERSION_TO')"
  id_rel_query_from="(SELECT id_release FROM Releases WHERE name = '$DBM_REL_NAME' AND version = '$DBM_REL_VERSION_FROM')"

  query="INSERT INTO ScriptRelDedicated (id_script,id_release_from,id_release_to,creation_date) \
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

dbm_remove_ded_script () {

  local result=1
  local query=1
  local id_rel_query_to=""
  local id_rel_query_from=""

  # Shift first two input param
  shift 2

  _dbm_check_inhibit_script_args "$@" || return $result

  id_rel_query_to="(SELECT id_release FROM Releases WHERE name = '$DBM_REL_NAME' AND version = '$DBM_REL_VERSION_TO')"
  id_rel_query_from="(SELECT id_release FROM Releases WHERE name = '$DBM_REL_NAME' AND version = '$DBM_REL_VERSION_FROM')"

  query="DELETE FROM ScriptRelDedicated \
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

dbm_show_branches () {

  _sqlite_query -c "$DRM_DB" -q "SELECT COUNT(1) AS R FROM Branches" || error_handled "Unexpected error!"

  local n_rec=$_sqlite_ans
  local creation_date=""
  local update_date=""

  [[ $DEBUG ]] && echo -en "N. Branches: $n_rec\n"

  if [ x$n_rec != x0 ] ; then

    _sqlite_query -c "$DRM_DB" -q "SELECT id_branch,name,creation_date,update_date FROM Branches ORDER BY id_branch ASC" || error_handled "Unexpected error!"

    echo -en "==============================================================================================================\n"
    echo -en "\e[1;33mID\e[m\t"
    echo -en "\e[1;34mCREATION_DATE\e[m\t\t"
    echo -en "\e[1;36mUPDATE_DATE\e[m\t\t"
    echo -en "\e[1;37mNAME\e[m\n"
    echo -en "==============================================================================================================\n"

    IFS=$'\n'
    for row in $_sqlite_ans ; do

      #[[ $DEBUG ]] && echo "ROW = ${row}"

      id_branch=`echo $row | awk '{split($0,a,"|"); print a[1]}'`
      name=`echo $row | awk '{split($0,a,"|"); print a[2]}'`
      creation_date=`echo $row | awk '{split($0,a,"|"); print a[3]}'`
      update_date=`echo $row | awk '{split($0,a,"|"); print a[4]}'`

      if [ ${#creation_date} -eq 10 ] ; then
        creation_date_tab="\t\t"
      else
        creation_date_tab="\t"
      fi

      if [ ${#update_date} -eq 10 ] ; then
        update_date_tab="\t\t"
      else
        update_date_tab="\t"
      fi

      echo -en "\e[1;33m${id_branch}\e[m\t"
      echo -en "\e[1;34m${creation_date}${creation_date_tab}\e[m"
      echo -en "\e[1;35m${update_date}${update_date_tab}\e[m"
      echo -en "\e[1;37m${name}\e[m\n"

    done
    unset IFS

  else
    echo -en "No branches available.\n"
  fi

  return 0
}

dbm_insert_branch () {

  local result=1
  local query=""

  # Shift first two input param
  shift 2

  _dbm_check_ins_bra_args "$@" || return $result

  query="INSERT INTO Branches (name,creation_date,update_date) \
         VALUES ('$DBM_BRA_NAME', DATETIME('now'),DATETIME('now'))"

  _sqlite_query -c "$DRM_DB" -q "$query" || error_handled "Unexpected error!"
  ans=$?

  if [ x"$ans" = x"0" ] ; then
    echo "Branches $DBM_BRA_NAME insert correctly."
  fi

  result=$ans

  return $result
}

dbm_move_script () {

  local result=1
  local id_order_from=""
  local id_order_to=""
  local create_tmp_table=""
  local move_others=""

  # Shift first two input param
  shift 2

  _dbm_check_move_script_args "$@" || return $result

  _dbm_check_if_exist_id_rel "$DBM_REL_ID" || return $result

  _dbm_check_if_exist_id_script "$DBM_SCRIPT_ID_FROM" "$DBM_REL_ID" || return $result

  _dbm_check_if_exist_id_script "$DBM_SCRIPT_ID_TO" "$DBM_REL_ID" || return $result

  _dbm_retrieve_field_script "id_order" "$DBM_SCRIPT_ID_FROM"
  id_order_from=$_sqlite_ans

  _dbm_retrieve_field_script "id_order" "$DBM_SCRIPT_ID_TO"
  id_order_to=$_sqlite_ans

  if [ $DBM_AFTER -eq 1 ] ; then

    if  [ $id_order_to -lt $id_order_from ] ; then

      where_moved_record="( id_order > $id_order_to AND id_order < $id_order_from )"

      insert2tmp="INSERT INTO ScriptsTemp
        SELECT id_script, filename, type, active,
               directory, id_release, $id_order_to+1 as id_order,
               creation_date, update_date
        FROM Scripts
        WHERE id_script = $DBM_SCRIPT_ID_FROM ;
        INSERT INTO ScriptsTemp
        SELECT id_script, filename, type, active,
               directory, id_release,id_order+1 as id_order,
               creation_date, update_date
        FROM Scripts
        WHERE $where_moved_record "

    else

      where_moved_record="id_order > $id_order_from "

      insert2tmp="INSERT INTO ScriptsTemp
        SELECT id_script, filename, type, active,
               directory, id_release, id_order-1 as id_order,
               creation_date, update_date
        FROM Scripts
        WHERE id_order > $id_order_from AND id_order <= $id_order_to ;
        INSERT INTO ScriptsTemp
        SELECT id_script, filename, type, active,
               directory, id_release, id_order,
               creation_date, update_date
        FROM Scripts
        WHERE id_order > $id_order_to ;
        INSERT INTO ScriptsTemp
        SELECT id_script, filename, type, active,
               directory, id_release, $id_order_to as id_order,
               creation_date, update_date
        FROM Scripts
        WHERE id_script = $DBM_SCRIPT_ID_FROM "

    fi

    t="after"

    result=0

  else

    if [ $id_order_to -lt $id_order_from ] ; then

      where_moved_record=" id_order < $id_order_from
        AND id_order >= $id_order_to AND id_release = $DBM_REL_ID "

      insert2tmp="INSERT INTO ScriptsTemp
        SELECT id_script, filename, type, active,
               directory, id_release, id_order+1 as id_order,
               creation_date, update_date
        FROM Scripts
        WHERE $where_moved_record ;
        INSERT INTO ScriptsTemp
        SELECT id_script, filename, type, active,
               directory, id_release, $id_order_to as id_order,
               creation_date, update_date
        FROM Scripts
        WHERE id_script = $DBM_SCRIPT_ID_FROM "

    else

      where_moved_record="id_order < $id_order_to
        AND id_order > $id_order_from AND id_release = $DBM_REL_ID "

      insert2tmp="INSERT INTO ScriptsTemp
        SELECT id_script, filename, type, active,
               directory, id_release, id_order-1 as id_order,
               creation_date, update_date
        FROM Scripts
        WHERE $where_moved_record ;
        INSERT INTO ScriptsTemp
        SELECT id_script, filename, type, active,
               directory, id_release, $id_order_to-1 as id_order,
               creation_date, update_date
        FROM Scripts
        WHERE id_script = $DBM_SCRIPT_ID_FROM "


    fi

    t="before"
    result=0

  fi

  # Create temporary table ddl for script move
  _dbm_get_table_schema "Scripts"
  create_tmp_table="$(echo "$_sqlite_ans" | sed 's/TABLE Scripts/TABLE ScriptsTemp/')"

  delete_scripts="DELETE FROM Scripts
    WHERE ($where_moved_record) OR
    (id_release = $DBM_REL_ID AND id_order = $id_order_from ) "

  # Disable PRAGMA options
  SQLITEDB_INIT_SESSION=" "

  query="DROP TABLE IF EXISTS ScriptsTemp ;
    $create_tmp_table
    ${insert2tmp} ;
    ${delete_scripts} ;
    INSERT INTO Scripts
    SELECT id_script, filename, type, active,
           directory, id_release, id_order,
           creation_date, DATETIME('now')
    FROM ScriptsTemp
    WHERE id_release = $DBM_REL_ID ;
    DROP TABLE ScriptsTemp "

  #  SELECT * FROM ScriptsTemp ;
  #  SELECT '-'  ;
  #  SELECT * FROM Scripts ;
  _sqlite_query -c "$DRM_DB" -q "$query" || error_handled "Unexpected error on update id_order fields."

  # Re-enable PRAGMA options
  unset SQLITEDB_INIT_SESSION

  echo -en "Moved correctly script $DBM_SCRIPT_ID_FROM of the release $DBM_REL_ID ${t} script $DBM_SCRIPT_ID_TO.\n"

  return $result
}


##################################################################
# Internal functions
##################################################################

_dbm_init() {

  # Load dbm module files
  for i in $DBRM_CORE_FILES_DIR/dbm/*.inc ; do
    . $i
  done

  return 0
}

_dbm_post_init () {

  # Check if exists DRM_DB
  [[ $DEBUG ]] && echo "(dbm_post_init: Check if is present sqlite internal db file: $DRM_DB)"
  if [[ ! -e $DRM_DB ]] ; then

    [[ $DEBUG ]] && echo "(dbm_post_init: Create sqlite internal db file: $DRM_DB)"
    _sqlite_create -c "$DRM_DB" -s "$dbm_schema" || error_handled "Error on create $DRM_DB file."

  fi

  # Check if is defined undo script path
  if [[ -z "$DBM_UNDO_SCRIPT" ]] ; then
      # Use default path
      DBM_UNDO_SCRIPT=$LOCAL_DIR/dbm_undo.sh
  else
    if [[ ! -e $DBM_UNDO_SCRIPT ]] ; then
      error_generate "Invalid DBM Undo script path defined."
    fi
  fi

  [[ $DEBUG ]] && echo "(dbm_post_init: Use undo script: $DBM_UNDO_SCRIPT.)"

  export DBM_UNDO_SCRIPT

}

# vim: syn=sh filetype=sh
