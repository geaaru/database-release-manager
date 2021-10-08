#!/bin/bash
#------------------------------------------------
# Author(s): Geaaru, geaaru@gmail.com
# $Id$
# License: GPL 2.0
#------------------------------------------------

# dbm__dbm_exts_check_extensions
_dbm_exts_check_extensions () {

  local ans=0
  local v=""
  local i=""
  local quiet=${1:-0}

  for i in $modules ; do

    eval v=\$${i}_version

    [[ x"${quiet}" != x"0" ]] && \
      out_handler_print "Check if extension $i is present..."

    _dbm_exts_is_present "$i"
    if [ $? -eq 0 ] ; then

      [[ x"${quiet}" != x"0" ]] && \
        out_handler_print "Extension $i is already present."

      # Check if version is equal to current extensions.
      if [ "$v" != "${_ext_version}" ] ; then
        [[ x"${quiet}" != x"0" ]] && \
          out_handler_print "New version of $i module. I check for upgrade function."

        if [ "$i" != "dbm" ] ; then
          if type -t ${i}_upgrade > /dev/null ; then
            ${i}_upgrade "$v" || error_handled \
              "(_dbm_exts_check_extensions): Error on upgrade extension $i."
          fi
        fi

        _dbm_exts_update_extension "$i" "$v" || error_handled ""
      fi
      ans=0

    else

      # Install extension row.
      [[ x"${quiet}" != x"0" ]] && \
        out_handler_print "Extension $i is not present. I add it."
      _dbm_exts_inst_extension "$i" "$v" || error_handled ""

    fi

  done

  return $ans
}
# dbm__dbm_exts_check_extensions_end

# dbm__dbm_exts_is_present
_dbm_exts_is_present () {

  local ext="$1"

  query="
    SELECT version
    FROM Extensions
    WHERE ext_name = '$ext'
  "

  _sqlite_query -c "$DRM_DB" -q "$query" || return 1

  if [[ x"$_sqlite_ans" == x"\ " || x"$_sqlite_ans" == x"" ]] ; then
    # Extension is not present.
    return 1
  fi

  _ext_version="$_sqlite_ans"

  return 0
}
# dbm__dbm_exts_is_present_end

# dbm__dbm_exts_inst_extension
_dbm_exts_inst_extension () {

  local ename="$1"
  local eversion="$2"

  if [[ -z "$ename" || -z "$eversion" ]] ; then
    return 1
  fi

  local query="
    INSERT INTO Extensions
    (ext_name,
     version,
     creation_date,
     update_date)
    VALUES (
      '$ename',
      '$eversion',
      DATETIME('now'),
      DATETIME('now')
    );
  "

  _sqlite_query -c "$DRM_DB" -q "$query" || error_handled \
    "(_dbm_exts_inst_extension): Error on insert extension $ename (version $eversion)."

  return 0
}
# dbm__dbm_exts_inst_extension_end

# dbm__dbm_exts_update_extension
_dbm_exts_update_extension () {

  local ename="$1"
  local eversion="$2"

  if [[ -z "$ename" || -z "$eversion" ]] ; then
    return 1
  fi

  local query="
    UPDATE Extensions
    SET version = '${eversion}',
        update_date = DATETIME('now')
    WHERE ext_name = '${ename}'
  "

  _sqlite_query -c "$DRM_DB" -q "$query" || error_handled \
    "(_dbm_exts_inst_extension): Error on update extension $ename (version $eversion)."

  return 0
}
# dbm__dbm_exts_update_extension_end

# dbm__dbm_exts_check_dbm
_dbm_exts_check_dbm () {

  if _sqlite_exists_table -c "$DRM_DB" -t "Extensions" ; then
    return 1
  fi

  _dbm_exts_is_present "dbm" || return 1

  cmp=$(_dbm_semver_compare_version "${dbm_version}" "${_ext_version}")
  [[ $DEBUG ]] && echo "Compare versions: ${dbm_version} ${_ext_version} - $cmp"
  if [ "${cmp}" == "1" ] ; then
    return 1
  fi

  return 0
}
# dbm__dbm_exts_check_dbm_end

# vim: syn=sh filetype=sh
