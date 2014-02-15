#!/bin/bash
#------------------------------------------------
# Author(s): Geaaru, geaaru@gmail.com
# $Id$
# License: GPL 2.0
#------------------------------------------------

#****f* commons_oracle/commons_oracle_check_tnsnames
# FUNCTION
#   Check and set TNS_ADMIN variable.
# RETURN VALUE
#   0 on success
#   1 on error
# SOURCE
commons_oracle_check_tnsnames () {

  local packagedir=$1

  if [ -f "$packagedir/etc/tnsnames.ora" ] ; then
    export TNS_ADMIN="$packagedir/etc/"
  else
    if [ -z "$TNS_ADMIN" ] ; then
      return 1
    else
      if [ ! -e "$TNS_ADMIN/tnsnames.ora" ] ; then
        echo "Missing tnsnames.ora file."
        return 1;
      fi

      # Export TNS_ADMIN if is not global (probably it isn't needed)
      export TNS_ADMIN
    fi
  fi

  return 0

}
#***

#****f* commons_oracle/commons_oracle_check_sqlplus
# FUNCTION
#   Check and set SQLPLUS variable with path of the
#   sqlplus program.
# RETURN VALUE
#   0 on success
#   1 on error
# SOURCE
commons_oracle_check_sqlplus () {

  if [ -z "$sqlplus" ] ; then

    # POST: sqlplus variable not set
    tmp=`which sqlplus 2> /dev/null`
    var=$?

    if [ $var -eq 0 ] ; then

      [[ $DEBUG && $DEBUG == true ]] && echo -en "Use sqlplus: $tmp\n"

      SQLPLUS=$tmp

      unset tmp

    else

      error_generate "sqlplus program not found"

      return 1

    fi

  else

    # POST: sqlplus variable set

    # Check if file is correct
    if [ -f "$sqlplus" ] ; then

      [[ $DEBUG && $DEBUG == true ]] && echo -en "Use sqlplus: $sqlplus\n"

      SQLPLUS=$sqlplus

    else

      error_generate "$sqlplus program invalid"

      return 1

    fi

  fi

  export SQLPLUS

  return 0

}
#***

#****f* commons_oracle/commons_oracle_check_connection
# FUNCTION
#   Check that SQLPLUS and sqlplus_auth variables are set
#   and try to do a connection to database.
# RETURN VALUE
#   0 when connection is ok.
#   1 on error
# SOURCE
commons_oracle_check_connection () {

  if [ -z "$SQLPLUS" ] ; then
    return 1
  fi

  if [ -z "$sqlplus_auth" ] ; then
    return 1
  fi

  $SQLPLUS -S -l $sqlplus_auth >/dev/null 2>&1 << EOF

exit
EOF

  errorCode=$?
  if [ ${errorCode} -ne 0 ] ; then
    return 1
  fi

  unset errorCode

  [[ $DEBUG && $DEBUG == true ]] && echo "SQLPlus was connected successfully"

  return 0
}
#***

#****f* commons_oracle/commons_oracle_download_all_packages
# FUNCTION
#   Download all packages to ORACLE_DIR/package directory.
# RETURN VALUE
#   1 on error
#   0 on success
# SEE ALSO
#   commons_oracle_download_create_export_packages
#   sqlplus_file
# SOURCE
commons_oracle_download_all_packages() {

  local packagesdir=${ORACLE_DIR}/package
  local export_packages_sql=${packagesdir}/export_packages.sql

  _logfile_write "Start download of all packages." || return 1

  commons_oracle_download_create_export_packages

  SQLPLUS_OUTPUT=""

  sqlplus_file "SQLPLUS_OUTPUT" "${export_packages_sql}"
  ans=$?

  _logfile_write "$SQLPLUS_OUTPUT" || return 1

  _logfile_write "End download of all packages." || return 1

  return $ans
}
#***

#****f* commons_oracle/commons_oracle_download_create_export_packages
# FUNCTION
#   Create export_packages_file script used for download all packages.
# DESCRIPTION
#   If script is present and creation date has less of 7200 seconds
#   then this function do nothing.
# RETURN VALUE
#   1 on error
#   0 on success
# SEE ALSO
#   sqlplus_file
# SOURCE
commons_oracle_download_create_export_packages() {

  local packagesdir=${ORACLE_DIR}/package
  local export_packages_sql=${packagesdir}/export_packages.sql
  local export_packages_file=${packagesdir}/export_packages_gen.sql

  local expire_time_sec="7200"
  local ans=0

  if [[ ! -e ${export_packages_file} || ! -e ${export_packages_sql} || "$(( $(date +"%s") - $(stat -c "%Y" $export_packages_file) ))" -gt ${expire_time_sec} ]] ; then

    _logfile_write "Start creation of the ${export_packages_sql} file." || return 1

    # Create export_packages.sql file
    _logfile_write "sed -e 's:PACKAGES_DIR:'${packagesdir}/':g' \
      \"$_oracle_scripts/export_packages_gen.sql.in\" > \"${export_packages_file}\""
    sed -e 's:PACKAGES_DIR:'${packagesdir}'/:g' "$_oracle_scripts/export_packages_gen.sql.in" > "${export_packages_file}"

    SQLPLUS_OUTPUT=""

    sqlplus_file "SQLPLUS_OUTPUT" "${export_packages_file}"
    ans=$?

    _logfile_write "End creation of the ${export_packages_sql} file." || return 1

  else

    _logfile_write "${export_packages_file} is updated." || return 1

  fi

  return $ans

}
#***

#****f* commons_oracle/commons_oracle_download_create_export_package
# FUNCTION
#   Create export_packages_file script used for download a particular
#   package.
# DESCRIPTION
#   If script is present and creation date has less of 7200 seconds
#   then this function do nothing.
# INPUTS
#   package-name    - name of the package to insert on export script.
# RETURN VALUE
#   1 on error
#   0 on success
# SEE ALSO
#   sqlplus_file
# SOURCE
commons_oracle_download_create_export_package() {

  local packagename=${1/.sql/}

  local packagesdir=${ORACLE_DIR}/package
  local export_package_sql=${packagesdir}/export_package_${packagename}.sql
  local export_package_file=${packagesdir}/export_packages_gen_${packagename}.sql

  local expire_time_sec="7200"
  local ans=0

  if [[ ! -e ${export_package_file} || ! -e ${export_package_sql} || "$(( $(date +"%s") - $(stat -c "%Y" $export_package_file) ))" -gt ${expire_time_sec} ]] ; then

    _logfile_write "Start creation of the ${export_package_sql} file." || return 1

    # Create export_package_${packagename}.sql file
    _logfile_write "sed -e 's:PACKAGES_DIR:'${packagesdir}/':g' \
      \"$_oracle_scripts/export_package_gen.sql.in\" > \"${export_package_file}\""
    sed -e 's:PACKAGES_DIR:'${packagesdir}'/:g' "$_oracle_scripts/export_package_gen.sql.in" > "${export_package_file}"

    # Replace PACKAGE_NAME string
    _logfile_write "sed -i -e 's:PACKAGE_NAME:'${packagename}':g' \"${export_package_file}\""
    sed -i -e 's:PACKAGE_NAME:'${packagename}':g' "${export_package_file}"

    SQLPLUS_OUTPUT=""

    sqlplus_file "SQLPLUS_OUTPUT" "${export_package_file}"
    ans=$?

    _logfile_write "End creation of the ${export_package_sql} file." || return 1

  else

    _logfile_write "${export_package_file} is updated." || return 1

  fi

  return $ans

}
#***

#****f* commons_oracle/commons_oracle_download_package
# FUNCTION
#   Download a particular package to ORACLE_DIR/package directory.
# INPUTS
#   package-name    - name of the package to download.
# RETURN VALUE
#   1 on error
#   0 on success
# SEE ALSO
#   commons_oracle_download_create_export_package
#   sqlplus_file
# SOURCE
commons_oracle_download_package() {

  local packagename=${1/.sql/}
  local packagesdir=${ORACLE_DIR}/package
  local export_package_sql=${packagesdir}/export_package_${packagename}.sql

  _logfile_write "Start download of the package ${packagename}." || return 1

  commons_oracle_download_create_export_package $packagename

  SQLPLUS_OUTPUT=""

  sqlplus_file "SQLPLUS_OUTPUT" "${export_package_sql}"
  ans=$?

  _logfile_write "$SQLPLUS_OUTPUT" || return 1

  _logfile_write "End download of the package ${packagename}." || return 1

  return $ans
}
#***

#****f* commons_oracle/commons_oracle_download_all_functions
# FUNCTION
#   Download all functions from schema to ORACLE_DIR/functions directory.
# RETURN VALUE
#   1 on error
#   0 on success
# SEE ALSO
#   commons_oracle_download_create_export_functions
#   sqlplus_file
# SOURCE
commons_oracle_download_all_functions() {

  local functionsdir=${ORACLE_DIR}/functions
  local export_functions_sql=${functionsdir}/export_function.sql

  _logfile_write "Start download of all functions." || return 1

  commons_oracle_download_create_export_functions

  SQLPLUS_OUTPUT=""

  sqlplus_file "SQLPLUS_OUTPUT" "${export_functions_sql}"
  ans=$?

  _logfile_write "$SQLPLUS_OUTPUT" || return 1

  _logfile_write "End download of all functions." || return 1

  return $ans
}
#***

#****f* commons_oracle/commons_oracle_download_create_export_functions
# FUNCTION
#   Create export_function_file script used for download all functions.
# DESCRIPTION
#   If script is present and creation date has less of 7200 seconds
#   then this function do nothing.
# RETURN VALUE
#   1 on error
#   0 on success
# SEE ALSO
#   sqlplus_file
# SOURCE
commons_oracle_download_create_export_functions() {

  local functionsdir=${ORACLE_DIR}/functions
  local export_functions_sql=${functionsdir}/export_function.sql
  local export_functions_file=${functionsdir}/export_function_gen.sql

  local expire_time_sec="7200"
  local ans=0

  if [[ ! -e ${export_functions_file} || ! -e ${export_functions_sql} || "$(( $(date +"%s") - $(stat -c "%Y" $export_functions_file) ))" -gt ${expire_time_sec} ]] ; then

    _logfile_write "Start creation of the ${export_functions_sql} file." || return 1

    # Create export_function.sql file
    _logfile_write "sed -e 's:FUNCTIONS_DIR:'${functionsdir}/':g' \
      \"$_oracle_scripts/export_functions_gen.sql.in\" > \"${export_functions_file}\""
    sed -e 's:FUNCTIONS_DIR:'${functionsdir}'/:g' "$_oracle_scripts/export_functions_gen.sql.in" > "${export_functions_file}"

    SQLPLUS_OUTPUT=""

    sqlplus_file "SQLPLUS_OUTPUT" "${export_functions_file}"
    ans=$?

    _logfile_write "End creation of the ${export_functions_sql} file." || return 1

  else

    _logfile_write "${export_functions_file} is updated." || return 1

  fi

  return $ans

}
#***

#****f* commons_oracle/commons_oracle_download_function
# FUNCTION
#   Download a particular function to ORACLE_DIR/functions directory.
# INPUTS
#   function-name    - name of the function to download.
# RETURN VALUE
#   1 on error
#   0 on success
# SEE ALSO
#   commons_oracle_download_create_export_function
#   sqlplus_file
# SOURCE
commons_oracle_download_function() {

  local functionname=${1/.sql/}
  local functionsdir=${ORACLE_DIR}/functions
  local export_function_sql=${functionsdir}/export_function_${functionname}.sql

  _logfile_write "Start download of the function ${functionname}." || return 1

  commons_oracle_download_create_export_function $functionname

  SQLPLUS_OUTPUT=""

  sqlplus_file "SQLPLUS_OUTPUT" "${export_function_sql}"
  ans=$?

  _logfile_write "$SQLPLUS_OUTPUT" || return 1

  _logfile_write "End download of the function ${functionname}." || return 1

  return $ans
}
#***

#****f* commons_oracle/commons_oracle_download_create_export_function
# FUNCTION
#   Create export_function_file script used for download a particular
#   function.
# DESCRIPTION
#   If script is present and creation date has less of 7200 seconds
#   then this function do nothing.
# INPUTS
#   function-name    - name of the function to insert on export script.
# RETURN VALUE
#   1 on error
#   0 on success
# SEE ALSO
#   sqlplus_file
# SOURCE
commons_oracle_download_create_export_function() {

  local functionname=${1/.sql/}

  local functionsdir=${ORACLE_DIR}/functions
  local export_function_sql=${functionsdir}/export_function_${functionname}.sql
  local export_function_file=${functionsdir}/export_functions_gen_${functionname}.sql

  local expire_time_sec="7200"
  local ans=0

  if [[ ! -e ${export_function_file} || ! -e ${export_function_sql} || "$(( $(date +"%s") - $(stat -c "%Y" $export_function_file) ))" -gt ${expire_time_sec} ]] ; then

    _logfile_write "Start creation of the ${export_function_sql} file." || return 1

    # Create export_function_${functionname}.sql file
    _logfile_write "sed -e 's:FUNCTIONS_DIR:'${functionsdir}/':g' \
      \"$_oracle_scripts/export_function_gen.sql.in\" > \"${export_function_file}\""
    sed -e 's:FUNCTIONS_DIR:'${functionsdir}'/:g' "$_oracle_scripts/export_function_gen.sql.in" > "${export_function_file}"

    # Replace FUNCTION_NAME string
    _logfile_write "sed -i -e 's:FUNCTION_NAME:'${functionname}':g' \"${export_function_file}\""
    sed -i -e 's:FUNCTION_NAME:'${functionname}':g' "${export_function_file}"

    SQLPLUS_OUTPUT=""

    sqlplus_file "SQLPLUS_OUTPUT" "${export_function_file}"
    ans=$?

    _logfile_write "End creation of the ${export_function_sql} file." || return 1

  else

    _logfile_write "${export_function_file} is updated." || return 1

  fi

  return $ans

}
#***

#****f* commons_oracle/commons_oracle_download_all_views
# FUNCTION
#   Download all functions from schema to ORACLE_DIR/views directory.
# RETURN VALUE
#   1 on error
#   0 on success
# SEE ALSO
#   commons_oracle_download_create_export_views
#   sqlplus_file
# SOURCE
commons_oracle_download_all_views() {

  local viewsdir=${ORACLE_DIR}/views
  local export_views_sql=${viewsdir}/export_view.sql

  _logfile_write "Start download of all views." || return 1

  commons_oracle_download_create_export_views

  SQLPLUS_OUTPUT=""

  sqlplus_file "SQLPLUS_OUTPUT" "${export_views_sql}"
  ans=$?

  _logfile_write "$SQLPLUS_OUTPUT" || return 1

  _logfile_write "End download of all views." || return 1

  return $ans
}
#***

#****f* commons_oracle/commons_oracle_download_create_export_views
# FUNCTION
#   Create export_views_file script used for download all views.
# DESCRIPTION
#   If script is present and creation date has less of 7200 seconds
#   then this function do nothing.
# RETURN VALUE
#   1 on error
#   0 on success
# SEE ALSO
#   sqlplus_file
# SOURCE
commons_oracle_download_create_export_views() {

  local viewsdir=${ORACLE_DIR}/views
  local export_views_sql=${viewsdir}/export_view.sql
  local export_views_file=${viewsdir}/export_view_gen.sql

  local expire_time_sec="7200"
  local ans=0

  if [[ ! -e ${export_views_file} || ! -e ${export_views_sql} || "$(( $(date +"%s") - $(stat -c "%Y" $export_views_file) ))" -gt ${expire_time_sec} ]] ; then

    _logfile_write "Start creation of the ${export_views_sql} file." || return 1

    # Create export_view.sql file
    _logfile_write "sed -e 's:VIEWS_DIR:'${viewsdir}/':g' \
      \"$_oracle_scripts/export_views_gen.sql.in\" > \"${export_views_file}\""
    sed -e 's:VIEWS_DIR:'${viewsdir}'/:g' "$_oracle_scripts/export_views_gen.sql.in" > "${export_views_file}"

    SQLPLUS_OUTPUT=""

    sqlplus_file "SQLPLUS_OUTPUT" "${export_views_file}"
    ans=$?

    _logfile_write "End creation of the ${export_views_sql} file." || return 1

  else

    _logfile_write "${export_views_file} is updated." || return 1

  fi

  return $ans

}
#***

#****f* commons_oracle/commons_oracle_download_view
# FUNCTION
#   Download a particular view to ORACLE_DIR/views directory.
# INPUTS
#   view-name    - name of the view to download.
# RETURN VALUE
#   1 on error
#   0 on success
# SEE ALSO
#   commons_oracle_download_create_export_view
#   sqlplus_file
# SOURCE
commons_oracle_download_view() {

  local viewname=${1/.sql/}
  local viewsdir=${ORACLE_DIR}/views
  local export_view_sql=${viewsdir}/export_view_${viewname}.sql

  _logfile_write "Start download of the view ${viewname}." || return 1

  commons_oracle_download_create_export_view $viewname

  SQLPLUS_OUTPUT=""

  sqlplus_file "SQLPLUS_OUTPUT" "${export_view_sql}"
  ans=$?

  _logfile_write "$SQLPLUS_OUTPUT" || return 1

  _logfile_write "End download of the view ${viewname}." || return 1

  return $ans
}
#***

#****f* commons_oracle/commons_oracle_download_create_export_view
# FUNCTION
#   Create export_view_file script used for download a particular
#   view.
# DESCRIPTION
#   If script is present and creation date has less of 7200 seconds
#   then this function do nothing.
# INPUTS
#   view-name       - name of the view to insert on export script.
# RETURN VALUE
#   1 on error
#   0 on success
# SEE ALSO
#   sqlplus_file
# SOURCE
commons_oracle_download_create_export_view() {

  local viewname=${1/.sql/}

  local viewsdir=${ORACLE_DIR}/views
  local export_view_sql=${viewsdir}/export_view_${viewname}.sql
  local export_view_file=${viewsdir}/export_views_gen_${viewname}.sql

  local expire_time_sec="7200"
  local ans=0

  if [[ ! -e ${export_view_file} || ! -e ${export_view_sql} || "$(( $(date +"%s") - $(stat -c "%Y" $export_view_file) ))" -gt ${expire_time_sec} ]] ; then

    _logfile_write "Start creation of the ${export_view_sql} file." || return 1

    # Create export_view_${viewname}.sql file
    _logfile_write "sed -e 's:VIEWS_DIR:'${viewsdir}/':g' \
      \"$_oracle_scripts/export_view_gen.sql.in\" > \"${export_view_file}\""
    sed -e 's:VIEWS_DIR:'${viewsdir}'/:g' "$_oracle_scripts/export_view_gen.sql.in" > "${export_view_file}"

    # Replace VIEW_NAME string
    _logfile_write "sed -i -e 's:VIEW_NAME:'${viewname}':g' \"${export_view_file}\""
    sed -i -e 's:VIEW_NAME:'${viewname}':g' "${export_view_file}"

    SQLPLUS_OUTPUT=""

    sqlplus_file "SQLPLUS_OUTPUT" "${export_view_file}"
    ans=$?

    _logfile_write "End creation of the ${export_view_sql} file." || return 1

  else

    _logfile_write "${export_view_file} is updated." || return 1

  fi

  return $ans

}
#***

#****f* commons_oracle/commons_oracle_download_all_triggers
# FUNCTION
#   Download all triggers from schema to ORACLE_DIR/triggers directory.
# RETURN VALUE
#   1 on error
#   0 on success
# SEE ALSO
#   commons_oracle_download_create_export_triggers
#   sqlplus_file
# SOURCE
commons_oracle_download_all_triggers() {

  local triggersdir=${ORACLE_DIR}/triggers
  local export_triggers_sql=${triggersdir}/export_trigger.sql

  _logfile_write "Start download of all triggers." || return 1

  commons_oracle_download_create_export_triggers

  SQLPLUS_OUTPUT=""

  sqlplus_file "SQLPLUS_OUTPUT" "${export_triggers_sql}"
  ans=$?

  _logfile_write "$SQLPLUS_OUTPUT" || return 1

  _logfile_write "End download of all triggers." || return 1

  return $ans
}
#***

#****f* commons_oracle/commons_oracle_download_create_export_triggers
# FUNCTION
#   Create export_trigger_file script used for download all triggers.
# DESCRIPTION
#   If script is present and creation date has less of 7200 seconds
#   then this function do nothing.
# RETURN VALUE
#   1 on error
#   0 on success
# SEE ALSO
#   sqlplus_file
# SOURCE
commons_oracle_download_create_export_triggers() {

  local triggersdir=${ORACLE_DIR}/triggers
  local export_triggers_sql=${triggersdir}/export_trigger.sql
  local export_triggers_file=${triggersdir}/export_trigger_gen.sql

  local expire_time_sec="7200"
  local ans=0

  if [[ ! -e ${export_triggers_file} || ! -e ${export_triggers_sql} || "$(( $(date +"%s") - $(stat -c "%Y" $export_triggers_file) ))" -gt ${expire_time_sec} ]] ; then

    _logfile_write "Start creation of the ${export_triggers_sql} file." || return 1

    # Create export_trigger.sql file
    _logfile_write "sed -e 's:TRIGGERS_DIR:'${triggersdir}/':g' \
      \"$_oracle_scripts/export_triggers_gen.sql.in\" > \"${export_triggers_file}\""
    sed -e 's:TRIGGERS_DIR:'${triggersdir}'/:g' "$_oracle_scripts/export_triggers_gen.sql.in" > "${export_triggers_file}"

    SQLPLUS_OUTPUT=""

    sqlplus_file "SQLPLUS_OUTPUT" "${export_triggers_file}"
    ans=$?

    _logfile_write "End creation of the ${export_triggers_sql} file." || return 1

  else

    _logfile_write "${export_triggers_file} is updated." || return 1

  fi

  return $ans

}
#***

#****f* commons_oracle/commons_oracle_download_trigger
# FUNCTION
#   Download a particular trigger to ORACLE_DIR/triggers directory.
# INPUTS
#   trigger-name    - name of the trigger to download.
# RETURN VALUE
#   1 on error
#   0 on success
# SEE ALSO
#   commons_oracle_download_create_export_trigger
#   sqlplus_file
# SOURCE
commons_oracle_download_trigger() {

  local triggername=${1/.sql/}
  local triggersdir=${ORACLE_DIR}/triggers
  local export_trigger_sql=${triggersdir}/export_trigger_${triggername}.sql

  _logfile_write "Start download of the trigger ${triggername}." || return 1

  commons_oracle_download_create_export_trigger $triggername

  SQLPLUS_OUTPUT=""

  sqlplus_file "SQLPLUS_OUTPUT" "${export_trigger_sql}"
  ans=$?

  _logfile_write "$SQLPLUS_OUTPUT" || return 1

  _logfile_write "End download of the trigger ${triggername}." || return 1

  return $ans
}
#***

#****f* commons_oracle/commons_oracle_download_create_export_trigger
# FUNCTION
#   Create export_trigger_file script used for download a particular
#   trigger.
# DESCRIPTION
#   If script is present and creation date has less of 7200 seconds
#   then this function do nothing.
# INPUTS
#   trigger-name       - name of the trigger to insert on export script.
# RETURN VALUE
#   1 on error
#   0 on success
# SEE ALSO
#   sqlplus_file
# SOURCE
commons_oracle_download_create_export_trigger() {

  local triggername=${1/.sql/}

  local triggersdir=${ORACLE_DIR}/triggers
  local export_trigger_sql=${triggersdir}/export_trigger_${triggername}.sql
  local export_trigger_file=${triggersdir}/export_triggers_gen_${triggername}.sql

  local expire_time_sec="7200"
  local ans=0

  if [[ ! -e ${export_trigger_file} || ! -e ${export_trigger_sql} || "$(( $(date +"%s") - $(stat -c "%Y" $export_trigger_file) ))" -gt ${expire_time_sec} ]] ; then

    _logfile_write "Start creation of the ${export_trigger_sql} file." || return 1

    # Create export_trigger_${triggername}.sql file
    _logfile_write "sed -e 's:TRIGGERS_DIR:'${triggersdir}/':g' \
      \"$_oracle_scripts/export_trigger_gen.sql.in\" > \"${export_trigger_file}\""
    sed -e 's:TRIGGERS_DIR:'${triggersdir}'/:g' "$_oracle_scripts/export_trigger_gen.sql.in" > "${export_trigger_file}"

    # Replace TRIGGER_NAME string
    _logfile_write "sed -i -e 's:TRIGGER_NAME:'${triggername}':g' \"${export_trigger_file}\""
    sed -i -e 's:TRIGGER_NAME:'${triggername}':g' "${export_trigger_file}"

    SQLPLUS_OUTPUT=""

    sqlplus_file "SQLPLUS_OUTPUT" "${export_trigger_file}"
    ans=$?

    _logfile_write "End creation of the ${export_trigger_sql} file." || return 1

  else

    _logfile_write "${export_trigger_file} is updated." || return 1

  fi

  return $ans

}
#***

#****f* commons_oracle/commons_oracle_compile_file
# FUNCTION
#   Compile a file to current oracle schema.
# INPUTS
#   file         - file to compile.
#   msg          - message to write on logfile before and after
#                  compilation.
# RETURN VALUE
#   1 on error
#   0 on success
# SEE ALSO
#   sqlplus_file
# SOURCE
commons_oracle_compile_file() {

  local f=$1
  local msg=$2
  local f_base=$(basename "$f")

  if [ ! -e $f ] ; then
    _logfile_write "(oracle) File $f not found." || return 1
    return 1
  fi

  _logfile_write "(oracle) Start compilation (file $f_base): $msg" || return 1

  echo "(oracle) Start compilation (file $f_base): $msg"

  SQLPLUS_OUTPUT=""

  sqlplus_file "SQLPLUS_OUTPUT" "$f"
  local ans=$?

  _logfile_write "$SQLPLUS_OUTPUT" || return 1

  _logfile_write "(oracle) End compilation (file $f_base, result => $ans): $msg" || return 1

  echo -en "(oracle) End compilation (file $f_base, result => $ans): $msg\n"

  return $ans

}
#***

#****f* commons_oracle/commons_oracle_compile_all_packages
# FUNCTION
#   Compile all packages under ORACLE_DIR/packages directory.
# INPUTS
#   msg          - message to write on logfile before and after
#                  compilation.
# RETURN VALUE
#   1 on error
#   0 on success
# SEE ALSO
#   sqlplus_file
# SOURCE
commons_oracle_compile_all_packages () {

  local msg="$1"
  local directory="$ORACLE_DIR/packages"

  commons_oracle_compile_all_from_dir "$directory" "of all packages" "$msg" || return 1

  return 0
}
#***

#****f* commons_oracle/commons_oracle_compile_all_triggers
# FUNCTION
#   Compile all triggers under ORACLE_DIR/triggers directory.
# INPUTS
#   msg          - message to write on logfile before and after
#                  compilation.
# RETURN VALUE
#   1 on error
#   0 on success
# SEE ALSO
#   sqlplus_file
#   commons_oracle_compile_all_from_dir
# SOURCE
commons_oracle_compile_all_triggers () {

  local msg="$1"
  local directory="$ORACLE_DIR/triggers"

  commons_oracle_compile_all_from_dir "$directory" "of all triggers" "$msg" || return 1

  return 0
}
#***

#****f* commons_oracle/commons_oracle_compile_all_functions
# FUNCTION
#   Compile all functions under ORACLE_DIR/functions directory.
# INPUTS
#   msg          - message to write on logfile before and after
#                  compilation.
# RETURN VALUE
#   1 on error
#   0 on success
# SEE ALSO
#   sqlplus_file
#   commons_oracle_compile_all_from_dir
# SOURCE
commons_oracle_compile_all_functions () {

  local msg="$1"
  local directory="$ORACLE_DIR/functions"

  commons_oracle_compile_all_from_dir "$directory" "of all functions" "$msg" || return 1

  return 0
}
#***

#****f* commons_oracle/commons_oracle_compile_all_views
# FUNCTION
#   Compile all views under ORACLE_DIR/views directory.
# INPUTS
#   msg          - message to write on logfile before and after
#                  compilation.
# RETURN VALUE
#   1 on error
#   0 on success
# SEE ALSO
#   sqlplus_file
#   commons_oracle_compile_all_from_dir
# SOURCE
commons_oracle_compile_all_views () {

  local msg="$1"
  local directory="$ORACLE_DIR/views"

  commons_oracle_compile_all_from_dir "$directory" "of all views" "$msg" || return 1

  return 0
}
#***

#****f* commons_oracle/commons_oracle_compile_all_from_dir
# FUNCTION
#   Compile all files with .sql extension from input directory
# DESCRIPTION
#   It is possible some .sql file through
#   ORACLE_COMPILE_FILES_EXCLUDED variable.
# INPUTS
#   directory    - directory where found .sql files to compile
#   msg_head     - message header to insert on logfile.
#   msg          - message to write on logfile before and after
#                  compilation.
# RETURN VALUE
#   1 on error
#   0 on success
# SEE ALSO
#   sqlplus_file
#   commons_oracle_compile_all_from_dir
# SOURCE
commons_oracle_compile_all_from_dir () {

  local directory="$1"
  local msg_head="$2"
  local msg="$3"
  local f=""
  local fb=""
  local ex_f=""
  local exc=0

  _logfile_write "(oracle) Start compilation $msg_head: $msg" || return 1

  for i in $directory/*.sql ; do

    exc=0

    fb=`basename $i`
    f="${fb/.sql/}"

    # Check if file is excluded
    if [ ! -z "$ORACLE_COMPILE_FILES_EXCLUDED" ] ; then

      for e in $ORACLE_COMPILE_FILES_EXCLUDED ; do

        ex_f=`basename $e`
        ex_f="${ex_f/.sql/}"

        if [ "$ex_f" == "$f" ] ; then
          exc=1

          _logfile_write "(oracle) Exclude file $fb for user request."

          break
        fi

      done # end for exclueded

    fi

    # If file is excluded go to the next
    [ $exc -eq 1 ] && continue

    commons_oracle_compile_file "$i" "$msg"
    # POST: on error go to next file


  done # end for

  _logfile_write "(oracle) End compilation $msg_head: $msg" || return 1

  return 0

}
#***

# vim: syn=sh filetype=sh
