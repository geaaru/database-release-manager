#!/bin/bash
#------------------------------------------------
# Author(s): Geaaru, geaaru@gmail.com
# $Id$
# License: GPL 2.0
#------------------------------------------------


# return 0 on success (show $_sqlite_ans variable for number)
# return 1 on error
_dbm_how_many_profiles () {

  local query=""

  _sqlite_query -c "$DRM_DB" -q "SELECT COUNT(1) AS P FROM Profiles" || return 1

  return 0
}

_dbm_get_profile_by_name () {

  local query=""
  local name="$1"

  check_var "DRM_PROFILES_PATH" || error_handled "You must define DRM_PROFILES_PATH variable on configuration file"

  query="
    SELECT conf_file
    FROM Profiles
    WHERE profile_name = '$profile_name'"

  _sqlite_query -c "$DRM_DB" -q "$query" || return 1
  if [ x"$_sqlite_ans" == x"" ] ; then
    return 1
  fi

  DRM_PROFILE_FILE="$DRM_PROFILES_PATH/$_sqlite_ans"

  if [ ! -f $DRM_PROFILE_FILE ] ; then
    error_generate "Profile file $DRM_PROFILE_FILE not found."
  fi

  export DRM_PROFILE_FILE

  return 0

}

_dbm_get_default_profile_filepath () {

  local query=""

  check_var "DRM_PROFILES_PATH" || error_handled "You must define DRM_PROFILES_PATH variable on configuration file"

  query="
    SELECT conf_file
    FROM Profiles
    WHERE default_profile = 1
    LIMIT 1"

  _sqlite_query -c "$DRM_DB" -q "$query" || return 1
  if [ x"$_sqlite_ans" == x"" ] ; then
    return 1
  fi

  DRM_PROFILE_FILE="$DRM_PROFILES_PATH/$_sqlite_ans"

  if [ ! -f $DRM_PROFILE_FILE ] ; then
    error_generate "Profile file $DRM_PROFILE_FILE not found."
  fi

  export DRM_PROFILE_FILE

  return 0
}

# return 0 if exists
# return 1 if not exists
_dbm_check_if_exist_prof_byid () {

  local id_profile="$1"

  local query="
    SELECT COUNT(1)
    FROM Profiles
    WHERE id_profile = $id_profile"

  _sqlite_query -c "$DRM_DB" -q "$query" || error_handled "Unexpected error!"

  if [ x"$_sqlite_ans" != x"1" ] ; then
    error_generate "Invalid id_profile $id_profile."
  fi

  return 0
}

# return 0 if exists
# return 1 if not exists
_dbm_check_if_exist_prof_byname () {

  local profile_name="$1"

  local query="
    SELECT COUNT(1)
    FROM Profiles
    WHERE profile_name = '$profile_name'"

  _sqlite_query -c "$DRM_DB" -q "$query" || error_handled "Unexpected error!"

  if [ x"$_sqlite_ans" != x"1" ] ; then
    error_generate "Invalid profile_name $profile_name."
  fi

  return 0
}

# return 0 if exists
# return 1 if not exists
_dbm_check_if_exist_rel () {

  local rel_name="$1"
  local rel_version="$2"

  local query="SELECT COUNT(1) AS res FROM Releases WHERE name = '$rel_name' AND version = '$rel_version'"

  _sqlite_query -c "$DRM_DB" -q "$query" || error_handled "Unexpected error!"

  if [ x"$_sqlite_ans" != x"1" ] ; then
    error_generate "Invalid version $rel_version."
  fi

  return 0
}

_dbm_retrieve_script_data () {

  local id_script="$1"
  local set_variables="$2"

  local query="
    SELECT s.id_script,s.filename,s.type,
           s.active,s.directory,s.id_release,
           s.id_order,
           r.name,
           r.version,
           r.db_adapter,
           s.creation_date,s.update_date
    FROM Scripts s, Releases r
    WHERE id_script = $id_script
    AND s.id_release = r.id_release"

  _sqlite_query -c "$DRM_DB" -q "$query" || error_generate "Unexpected error on retrieve data of the script $id_script"

  if [ x"$_sqlite_ans" != x"1" ] ; then
    error_generate "Error on retrive data of the script $id_script."
  fi

  if [ ! -z "$set_variables" ] ; then

    DBM_SCRIPT_ID=`echo $_sqlite_ans | awk '{split($0,a,"|"); print a[1]}'`
    DBM_SCRIPT_FILENAME=`echo $_sqlite_ans | awk '{split($0,a,"|"); print a[2]}'`
    DBM_SCRIPT_TYPE=`echo $_sqlite_ans | awk '{split($0,a,"|"); print a[3]}'`
    DBM_SCRIPT_ACTIVE=`echo $_sqlite_ans | awk '{split($0,a,"|"); print a[4]}'`
    DBM_SCRIPT_DIR=`echo $_sqlite_ans | awk '{split($0,a,"|"); print a[5]}'`
    DBM_SCRIPT_ID_RELEASE=`echo $_sqlite_ans | awk '{split($0,a,"|"); print a[6]}'`
    DBM_SCRIPT_ID_ORDER=`echo $_sqlite_ans | awk '{split($0,a,"|"); print a[7]}'`
    DBM_SCRIPT_REL_NAME=`echo $_sqlite_ans | awk '{split($0,a,"|"); print a[8]}'`
    DBM_SCRIPT_REL_VERSION=`echo $_sqlite_ans | awk '{split($0,a,"|"); print a[9]}'`
    DBM_SCRIPT_ADAPTER=`echo $_sqlite_ans | awk '{split($0,a,"|"); print a[10]}'`

  fi

  return 0
}

_dbm_retrieve_first_release () {

  local name="$1"

  local query="
    SELECT r.id_release,
           r.version
    FROM Releases r
    WHERE r.name = '$name'
    ORDER BY r.id_order
    LIMIT 1
  "

  _sqlite_query -c "$DRM_DB" -q "$query" || error_generate "Unexpected error on retrieve first release for project $name"

  if [ -z "$_sqlite_ans" ] ; then
    error_generate "No release found for project $name"
  fi

  DBM_REL_ID_RELEASE=`echo $_sqlite_ans | awk '{split($0,a,"|"); print a[1]}'`
  DBM_REL_VERSION=`echo $_sqlite_ans | awk '{split($0,a,"|"); print a[2]}'`

  return 0
}

# return 0 if exists
# return 1 if not exists
_dbm_check_if_exist_id_script () {

  local id_script="$1"
  local id_release="$2"
  local query="SELECT COUNT(1) AS res FROM Scripts WHERE id_script = $id_script"

  if [ -n "$id_release" ] ; then

    query=$query" AND id_release = $id_release"
  fi

  _sqlite_query -c "$DRM_DB" -q "$query" || error_handled "Unexpected error!"

  if [ x"$_sqlite_ans" != x"1" ] ; then
    error_generate "Invalid id_script $id_script."
  fi

  return 0
}

# return 0 if exists
# generate error if doesn't exits.
_dbm_check_if_exist_id_branch () {

  local id_branch="$1"
  local query="SELECT COUNT(1) AS res FROM Branches WHERE id_branch = $id_branch"

  _sqlite_query -c "$DRM_DB" -q "$query" || error_handled "Unexpected error!"

  if [ x"$_sqlite_ans" != x"1" ] ; then
    error_generate "Invalid id_branch $id_branch."
  fi

  return 0
}

# return 0 if exists
# generate error if doesn't exits.
_dbm_check_if_exist_id_rel () {

  local id_release="$1"
  local query="SELECT COUNT(1) AS res FROM Releases WHERE id_release = $id_release"

  _sqlite_query -c "$DRM_DB" -q "$query" || error_handled "Unexpected error!"

  if [ x"$_sqlite_ans" != x"1" ] ; then
    error_generate "Invalid id_release $id_release."
  fi

  return 0
}

_dbm_retrieve_field_rel () {

  local field="$1"
  local rel_name="$2"
  local rel_version="$3"

  local query="SELECT $field FROM Releases WHERE name = '$rel_name' AND version = '$rel_version'"

  _sqlite_query -c "$DRM_DB" -q "$query" || error_handled "Unexpected error!"

  if [ x"$_sqlite_ans" == x"" ] ; then
    [[ $DEBUG && $DEBUG == true ]] && \
      echo -en "Error on retrieve field $field for release $rel_name and version $rel_version\n"
    error_generate "Invalid version $rel_version."
  fi

  return 0
}

_dbm_retrieve_field_rel_byid () {

  local field="$1"
  local id_release="$2"

  local query="SELECT $field FROM Releases WHERE id_release = $id_release "

  _sqlite_query -c "$DRM_DB" -q "$query" || error_handled "Unexpected error!"

  if [ x"$_sqlite_ans" == x"" ] ; then
    [[ $DEBUG && $DEBUG == true ]] && \
      echo -en "Error on retrieve field $field for release id $id_release.\n"
    error_generate "Invalid version $id_release."
  fi

  return 0
}


_dbm_retrieve_field_script () {

  local field="$1"
  local id_script="$2"

  local query="SELECT $field FROM Scripts WHERE id_script = $id_script"

  _sqlite_query -c "$DRM_DB" -q "$query" || error_handled "Unexpected error!"

  if [ x"$_sqlite_ans" == x"" ] ; then
    [[ $DEBUG && $DEBUG == true ]] && \
      echo -en "Error on retrieve field $field for script with id $id_script\n"
    error_generate "Invalid id_script $id_script"
  fi

  return 0
}

_dbm_get_table_schema () {

  local table="$1"

  local query=".schema $table"

  _sqlite_query -c "$DRM_DB" -t "$table" || error_handled ""

  return 0
}

_dbm_remove_all_scripts_rel_inhib () {

  local id_release="$1"

  local query=""
  local id_script=""
  local release_from=""
  local release_to=""
  local creation_date=""
  local name=""

  # Check if there are record
  query="
    SELECT COUNT(1) AS CNT
    FROM ScriptRelInhibitions
    WHERE id_release_from = $id_release
    OR    id_release_to = $id_release"

  _sqlite_query -c "$DRM_DB" -q "$query" || error_handled "Unexpected error!"

  if [ $_sqlite_ans -ne 0 ] ; then
    query="
      SELECT R.name,
             SRI.id_script,
             R.version AS rel_from,
             R2.version AS rel_to
      FROM ScriptRelInhibitions SRI,
           Releases R,
           Releases R2
      WHERE R.id_release = SRI.id_release_from
      AND R2.id_release = SRI.id_release_to
      AND (
          SRI.id_release_from = $id_release
          OR SRI.id_release_to = $id_release
      )"

    # TODO permit to set creation_date on insert script_inhibition_rel record.
    #      SRI.creation_date

    _sqlite_query -c "$DRM_DB" -q "$query" || error_handled "Unexpected error!"


    IFS=$'\n'
    for row in $_sqlite_ans ; do

      #[[ $DEBUG ]] && echo "ROW = ${row}"

      name=`echo $row | awk '{split($0,a,"|"); print a[1]}'`
      id_script=`echo $row | awk '{split($0,a,"|"); print a[2]}'`
      release_from=`echo $row | awk '{split($0,a,"|"); print a[3]}'`
      release_to=`echo $row | awk '{split($0,a,"|"); print a[4]}'`

      _dbm_save2undo "dbrm dbm insert_inhibit_script -n \"$name\" -i $id_script -t $release_to -f $release_from "

    done
    unset IFS

    # Create undo script for every record
    query="
      DELETE FROM ScriptRelInhibitions
      WHERE id_release_from = $id_release
      OR    id_release_to = $id_release"

      _sqlite_query -c "$DRM_DB" -q "$query" || error_handled "Unexpected error!"

      if [ x"$_sqlite_ans" == x"" ] ; then
        [[ $DEBUG && $DEBUG == true ]] && \
          echo -en "Error on field $field for release id $id_release.\n"
        error_generate "Invalid version $id_release."
      fi

  fi

  return 0
}

_dbm_remove_release () {

  local id_release="$1"

  local query=""
  local name=""
  local version=""
  local release_date=""
  local id_order=""
  local db_adapter=""
  local id_branch=""
  local directory=""

  # Retrieve release data
  query="
    SELECT name, version, release_date, id_order, db_adapter,
           id_branch, directory
    FROM Releases
    WHERE id_release = $id_release"

  _sqlite_query -c "$DRM_DB" -q "$query" || error_handled "Unexpected error!"

  IFS=$'\n'
  for row in $_sqlite_ans ; do

    #[[ $DEBUG ]] && echo "ROW = ${row}"

    name=`echo $row | awk '{split($0,a,"|"); print a[1]}'`
    version=`echo $row | awk '{split($0,a,"|"); print a[2]}'`
    release_date=`echo $row | awk '{split($0,a,"|"); print a[3]}' | awk '{split($0,a," "); print a[1]}'`
    id_order=`echo $row | awk '{split($0,a,"|"); print a[4]}'`
    db_adapter=`echo $row | awk '{split($0,a,"|"); print a[5]}'`
    id_branch=`echo $row | awk '{split($0,a,"|"); print a[6]}'`
    directory=`echo $row | awk '{split($0,a,"|"); print a[7]}'`

    _dbm_save2undo "dbrm dbm insert_release -n \"$name\" -d \"$release_date\" -v \"$version\" -a $db_adapter -b $id_branch --dir \"$directory\" "

  done
  unset IFS

  query="DELETE FROM Releases WHERE id_release = $id_release"

  _sqlite_query -c "$DRM_DB" -q "$query" || error_handled "Unexpected error on remove release $id_release!"

  return 0
}

_dbm_update_idorder () {

  local id_branch="$1"
  local idx=0
  local id_release=""
  local query="
    SELECT id_release
    FROM Releases
    WHERE id_branch = $id_branch
    ORDER BY id_order
  "

  _sqlite_query -c "$DRM_DB" -q "$query" || error_handled "Unexpected error on retrieve list of id_release!"

  declare -a list_id_rels

  IFS=$'\n'
  for row in $_sqlite_ans ; do
    id_release=`echo $row | awk '{split($0,a,"|"); print a[1]}'`
    list_id_rels[$idx]=$id_release
    let idx++
  done
  unset IFS

  # Update list of id
  id_order=1
  idx=0

  for e in ${!list_id_rels[@]}
  do

    id_release=${list_id_rels[$e]}

    query="
      UPDATE Releases
      SET id_order = $id_order
      WHERE id_release = $id_release
    "

    _sqlite_query -c "$DRM_DB" -q "$query" || error_handled "Unexpected error on update id_release $id_release"

    let id_order++

  done

  unset list_id_rels

  return 0
}

_dbm_remove_all_scripts_rel_ded () {

  local id_release="$1"

  local query=""
  local id_script=""
  local release_from=""
  local release_to=""
  local creation_date=""
  local name=""

  # Check if there are record
  query="
    SELECT COUNT(1) AS CNT
    FROM ScriptRelDedicated
    WHERE id_release_from = $id_release
    OR    id_release_to = $id_release"

  _sqlite_query -c "$DRM_DB" -q "$query" || error_handled "Unexpected error!"

  if [ $_sqlite_ans -ne 0 ] ; then
    query="
      SELECT R.name,
             SRD.id_script,
             R.version AS rel_from,
             R2.version AS rel_to
      FROM ScriptRelDedicated SRD,
           Releases R,
           Releases R2
      WHERE R.id_release = SRD.id_release_from
      AND R2.id_release = SRD.id_release_to
      AND (
          SRD.id_release_from = $id_release
          OR SRD.id_release_to = $id_release
      )"

    # TODO permit to set creation_date on insert script_dedicated_rel record.
    #      SRI.creation_date

    _sqlite_query -c "$DRM_DB" -q "$query" || error_handled "Unexpected error!"


    IFS=$'\n'
    for row in $_sqlite_ans ; do

      #[[ $DEBUG ]] && echo "ROW = ${row}"

      name=`echo $row | awk '{split($0,a,"|"); print a[1]}'`
      id_script=`echo $row | awk '{split($0,a,"|"); print a[2]}'`
      release_from=`echo $row | awk '{split($0,a,"|"); print a[3]}'`
      release_to=`echo $row | awk '{split($0,a,"|"); print a[4]}'`

      _dbm_save2undo "dbrm dbm insert_ded_script -n \"$name\" -i $id_script -t $release_to -f $release_from "

    done
    unset IFS

    # Create undo script for every record
    query="
      DELETE FROM ScriptRelDedicated
      WHERE id_release_from = $id_release
      OR    id_release_to = $id_release"

      _sqlite_query -c "$DRM_DB" -q "$query" || error_handled "Unexpected error!"

      if [ x"$_sqlite_ans" == x"" ] ; then
        [[ $DEBUG && $DEBUG == true ]] && \
          echo -en "Error on field $field for release id $id_release.\n"
        error_generate "Invalid version $id_release."
      fi

  fi

  return 0
}

_dbm_save2undo () {

    local msg="$1"

    echo "$msg" >> $DBM_UNDO_SCRIPT

}

_dbm_save2history () {

    local msg="$1"

    echo "$msg" >> $DBM_HISTORY

}

# vim: syn=sh filetype=sh
