#!/bin/bash
#------------------------------------------------
# Author(s): Geaaru, geaaru@gmail.com
# $Id$
# License: GPL 2.0
#------------------------------------------------

# commons_oracle_commons_oracle_check_tnsnames
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
        return 1
      fi

      # Export TNS_ADMIN if is not global (probably it isn't needed)
      export TNS_ADMIN
    fi
  fi

  return 0

}
# commons_oracle_commons_oracle_check_tnsnames_end

# commons_oracle_commons_oracle_check_sqlplus
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
# commons_oracle_commons_oracle_check_sqlplus_end

# commons_oracle_commons_oracle_check_vars
commons_oracle_check_vars () {

  local commons_msg='variable on configuration file, through arguments or on current profile.'

  check_var "ORACLE_USER" || error_handled "You must define ORACLE_USER $commons_msg"
  check_var "ORACLE_PWD"  || error_handled "You must define ORACLE_PWD $commons_msg"
  check_var "ORACLE_SID"  || error_handled "You must define ORACLE_SID $commons_msg"
  check_var "ORACLE_DIR"  || error_handled "You must define ORACLE_DIR $commons_msg"

  commons_oracle_check_tnsnames $LOCAL_DIR || error_handled "Invalid TNS_ADMIN variable"

  return 0
}
# commons_oracle_commons_oracle_check_vars_end


# commons_oracle_commons_oracle_check_connection
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
# commons_oracle_commons_oracle_check_connection_end

# commons_oracle_commons_oracle_shell
commons_oracle_shell () {

  if [ -z "$SQLPLUS" ] ; then
    return 1
  fi

  if [ -z "$sqlplus_auth" ] ; then
    return 1
  fi

  $SQLPLUS -L $sqlplus_auth

  return $?
}
# commons_oracle_commons_oracle_shell_end
#
# commons_oracle_commons_oracle_download_all_tables
commons_oracle_download_all_tables() {

  local export_single_file=${1}
  local tablesdir=${ORACLE_DIR}/tables
  local export_tables_sql=${tablesdir}/export_tables.sql

  _logfile_write "Start download of all tables." || return 1

  commons_oracle_download_create_export_tables ${export_single_file}

  SQLPLUS_OUTPUT=""

  sqlplus_file "SQLPLUS_OUTPUT" "${export_tables_sql}"
  ans=$?

  _logfile_write "$SQLPLUS_OUTPUT" || return 1

  _logfile_write "End download of all tables." || return 1

  return $ans
}
# commons_oracle_commons_oracle_download_all_tables_end
#
# commons_oracle_commons_oracle_download_create_export_tables
commons_oracle_download_create_export_tables() {
  
  local export_single_file=${1}
  local tablesdir=${ORACLE_DIR}/tables
  local export_tables_sql=${tablesdir}/export_tables.sql
  local export_tables_file=${tablesdir}/export_tables_gen.sql

  local expire_time_sec="7200"
  local ans=0


  if [[ ! -e ${export_tables_file} || ! -e ${export_tables_sql} || "$(( $(date +"%s") - $(stat -c "%Y" $export_tables_file) ))" -gt ${expire_time_sec} ]] ; then

    _logfile_write "Start creation of the ${export_tables_sql} file." || return 1

    # Create export_tables.sql file
    _logfile_write "sed -e 's:TABLES_DIR:'${tablesdir}/':g' \
      \"$_oracle_scripts/export_tables_gen.sql.in\" > \"${export_tables_file}\""
    sed -e 's:TABLES_DIR:'${tablesdir}'/:g' -e 's:EXECONEFILE:'${export_single_file}':g' "$_oracle_scripts/export_tables_gen.sql.in" > "${export_tables_file}"

    SQLPLUS_OUTPUT=""

    sqlplus_file "SQLPLUS_OUTPUT" "${export_tables_file}"
    ans=$?

    _logfile_write "End creation of the ${export_tables_sql} file." || return 1

  else

    _logfile_write "${export_tables_file} is updated." || return 1

  fi

  return $ans

}
# commons_oracle_commons_oracle_download_create_export_tables_end

# commons_oracle_commons_oracle_download_table
commons_oracle_download_table() {

  local tablename=${1/.sql/}
  local tablesdir=${ORACLE_DIR}/tables
  local export_table_sql=${tablesdir}/export_table_${tablename}.sql

  _logfile_write "Start download of the table ${tablename}." || return 1

  commons_oracle_download_create_export_table $tablename

  SQLPLUS_OUTPUT=""

  sqlplus_file "SQLPLUS_OUTPUT" "${export_table_sql}"
  ans=$?

  _logfile_write "$SQLPLUS_OUTPUT" || return 1

  _logfile_write "End download of the table ${tablename}." || return 1

  return $ans
}
# commons_oracle_commons_oracle_download_table_end

# commons_oracle_commons_oracle_download_create_export_table
commons_oracle_download_create_export_table() {

  local tablename=${1/.sql/}

  local tablesdir=${ORACLE_DIR}/tables
  local export_table_sql=${tablesdir}/export_table_${tablename}.sql
  local export_table_file=${tablesdir}/export_tables_gen_${tablename}.sql

  local expire_time_sec="7200"
  local ans=0

  if [[ ! -e ${export_table_file} || ! -e ${export_table_sql} || "$(( $(date +"%s") - $(stat -c "%Y" $export_table_file) ))" -gt ${expire_time_sec} ]] ; then

    _logfile_write "Start creation of the ${export_table_sql} file." || return 1

    # Create export_table_${tablename}.sql file
    _logfile_write "sed -e 's:TABLES_DIR:'${tablesdir}/':g' \
      \"$_oracle_scripts/export_table_gen.sql.in\" > \"${export_table_file}\""
    sed -e 's:TABLES_DIR:'${tablesdir}'/:g' "$_oracle_scripts/export_table_gen.sql.in" > "${export_table_file}"

    # Replace TBL_NAME string
    _logfile_write "sed -i -e 's:TBL_NAME:'${tablename}':g' \"${export_table_file}\""
    sed -i -e 's:TBL_NAME:'${tablename}':g' "${export_table_file}"

    SQLPLUS_OUTPUT=""

    sqlplus_file "SQLPLUS_OUTPUT" "${export_table_file}"
    ans=$?

    _logfile_write "End creation of the ${export_table_sql} file." || return 1

  else

    _logfile_write "${export_table_file} is updated." || return 1

  fi

  return $ans

}
# commons_oracle_commons_oracle_download_create_export_table_end

# commons_oracle_commons_oracle_download_all_sequences
commons_oracle_download_all_sequences() {

  local export_single_file=${1}
  local sequencesdir=${ORACLE_DIR}/sequences
  local export_sequences_sql=${sequencesdir}/export_sequences.sql

  _logfile_write "Start download of all sequences." || return 1

  commons_oracle_download_create_export_sequences ${export_single_file}

  SQLPLUS_OUTPUT=""

  sqlplus_file "SQLPLUS_OUTPUT" "${export_sequences_sql}"
  ans=$?

  _logfile_write "$SQLPLUS_OUTPUT" || return 1

  _logfile_write "End download of all sequences." || return 1

  return $ans
}
# commons_oracle_commons_oracle_download_all_sequences_end
#
# commons_oracle_commons_oracle_download_create_export_sequences
commons_oracle_download_create_export_sequences() {
  
  local export_single_file=${1}
  local sequencesdir=${ORACLE_DIR}/sequences
  local export_sequences_sql=${sequencesdir}/export_sequences.sql
  local export_sequences_file=${sequencesdir}/export_sequences_gen.sql

  local expire_time_sec="7200"
  local ans=0


  if [[ ! -e ${export_sequences_file} || ! -e ${export_sequences_sql} || "$(( $(date +"%s") - $(stat -c "%Y" $export_sequences_file) ))" -gt ${expire_time_sec} ]] ; then

    _logfile_write "Start creation of the ${export_sequences_sql} file." || return 1

    # Create export_sequences.sql file
    _logfile_write "sed -e 's:SEQS_DIR:'${sequencesdir}/':g' \
      \"$_oracle_scripts/export_sequences_gen.sql.in\" > \"${export_sequences_file}\""
    sed -e 's:SEQS_DIR:'${sequencesdir}'/:g' -e 's:EXECONEFILE:'${export_single_file}':g' "$_oracle_scripts/export_sequences_gen.sql.in" > "${export_sequences_file}"

    SQLPLUS_OUTPUT=""

    sqlplus_file "SQLPLUS_OUTPUT" "${export_sequences_file}"
    ans=$?

    _logfile_write "End creation of the ${export_sequences_sql} file." || return 1

  else

    _logfile_write "${export_sequences_file} is updated." || return 1

  fi

  return $ans

}
# commons_oracle_commons_oracle_download_create_export_sequences_end

# commons_oracle_commons_oracle_download_sequence
commons_oracle_download_sequence() {

  local sequencename=${1/.sql/}
  local sequencesdir=${ORACLE_DIR}/sequences
  local export_sequence_sql=${sequencesdir}/export_sequence_${sequencename}.sql

  _logfile_write "Start download of the sequence ${sequencename}." || return 1

  commons_oracle_download_create_export_sequence $sequencename

  SQLPLUS_OUTPUT=""

  sqlplus_file "SQLPLUS_OUTPUT" "${export_sequence_sql}"
  ans=$?

  _logfile_write "$SQLPLUS_OUTPUT" || return 1

  _logfile_write "End download of the sequence ${sequencename}." || return 1

  return $ans
}
# commons_oracle_commons_oracle_download_sequence_end

# commons_oracle_commons_oracle_download_create_export_sequence
commons_oracle_download_create_export_sequence() {

  local sequencename=${1/.sql/}

  local sequencesdir=${ORACLE_DIR}/sequences
  local export_sequence_sql=${sequencesdir}/export_sequence_${sequencename}.sql
  local export_sequence_file=${sequencesdir}/export_sequences_gen_${sequencename}.sql

  local expire_time_sec="7200"
  local ans=0

  if [[ ! -e ${export_sequence_file} || ! -e ${export_sequence_sql} || "$(( $(date +"%s") - $(stat -c "%Y" $export_sequence_file) ))" -gt ${expire_time_sec} ]] ; then

    _logfile_write "Start creation of the ${export_sequence_sql} file." || return 1

    # Create export_sequence_${sequencename}.sql file
    _logfile_write "sed -e 's:SEQS_DIR:'${sequencesdir}/':g' \
      \"$_oracle_scripts/export_sequence_gen.sql.in\" > \"${export_sequence_file}\""
    sed -e 's:SEQS_DIR:'${sequencesdir}'/:g' "$_oracle_scripts/export_sequence_gen.sql.in" > "${export_sequence_file}"

    # Replace TBL_NAME string
    _logfile_write "sed -i -e 's:SEQ_NAME:'${sequencename}':g' \"${export_sequence_file}\""
    sed -i -e 's:SEQ_NAME:'${sequencename}':g' "${export_sequence_file}"

    SQLPLUS_OUTPUT=""

    sqlplus_file "SQLPLUS_OUTPUT" "${export_sequence_file}"
    ans=$?

    _logfile_write "End creation of the ${export_sequence_sql} file." || return 1

  else

    _logfile_write "${export_sequence_file} is updated." || return 1

  fi

  return $ans

}
# commons_oracle_commons_oracle_download_create_export_sequence_end

# commons_oracle_commons_oracle_download_all_foreigns
commons_oracle_download_all_foreigns() {

  local export_single_file=${1}
  local foreignsdir=${ORACLE_DIR}/foreigns
  local export_foreigns_sql=${foreignsdir}/export_foreigns.sql

  _logfile_write "Start download of all foreigns." || return 1

  commons_oracle_download_create_export_foreigns ${export_single_file}

  SQLPLUS_OUTPUT=""

  sqlplus_file "SQLPLUS_OUTPUT" "${export_foreigns_sql}"
  ans=$?

  _logfile_write "$SQLPLUS_OUTPUT" || return 1

  _logfile_write "End download of all foreigns." || return 1

  return $ans
}
# commons_oracle_commons_oracle_download_all_foreigns_end

# commons_oracle_commons_oracle_download_create_export_foreigns
commons_oracle_download_create_export_foreigns() {
  
  local export_single_file=${1}
  local foreignsdir=${ORACLE_DIR}/foreigns
  local export_foreigns_sql=${foreignsdir}/export_foreigns.sql
  local export_foreigns_file=${foreignsdir}/export_foreigns_gen.sql

  local expire_time_sec="7200"
  local ans=0


  if [[ ! -e ${export_foreigns_file} || ! -e ${export_foreigns_sql} || "$(( $(date +"%s") - $(stat -c "%Y" $export_foreigns_file) ))" -gt ${expire_time_sec} ]] ; then

    _logfile_write "Start creation of the ${export_foreigns_sql} file." || return 1

    # Create export_foreigns.sql file
    _logfile_write "sed -e 's:FKS_DIR:'${foreignsdir}/':g' \
      \"$_oracle_scripts/export_foreigns_gen.sql.in\" > \"${export_foreigns_file}\""
    sed -e 's:FKS_DIR:'${foreignsdir}'/:g' -e 's:EXECONEFILE:'${export_single_file}':g' "$_oracle_scripts/export_foreigns_gen.sql.in" > "${export_foreigns_file}"

    SQLPLUS_OUTPUT=""

    sqlplus_file "SQLPLUS_OUTPUT" "${export_foreigns_file}"
    ans=$?

    _logfile_write "End creation of the ${export_foreigns_sql} file." || return 1

  else

    _logfile_write "${export_foreigns_file} is updated." || return 1

  fi

  return $ans

}
# commons_oracle_commons_oracle_download_create_export_foreigns_end

# commons_oracle_commons_oracle_download_foreign
commons_oracle_download_foreign() {

  local foreignname=${1/.sql/}
  local foreignsdir=${ORACLE_DIR}/foreigns
  local export_foreign_sql=${foreignsdir}/export_foreign_${foreignname}.sql

  _logfile_write "Start download of the foreign ${foreignname}." || return 1

  commons_oracle_download_create_export_foreign $foreignname

  SQLPLUS_OUTPUT=""

  sqlplus_file "SQLPLUS_OUTPUT" "${export_foreign_sql}"
  ans=$?

  _logfile_write "$SQLPLUS_OUTPUT" || return 1

  _logfile_write "End download of the foreign ${foreignname}." || return 1

  return $ans
}
# commons_oracle_commons_oracle_download_foreign_end

# commons_oracle_commons_oracle_download_create_export_foreign
commons_oracle_download_create_export_foreign() {

  local foreignname=${1/.sql/}

  local foreignsdir=${ORACLE_DIR}/foreigns
  local export_foreign_sql=${foreignsdir}/export_foreign_${foreignname}.sql
  local export_foreign_file=${foreignsdir}/export_foreigns_gen_${foreignname}.sql

  local expire_time_sec="7200"
  local ans=0

  if [[ ! -e ${export_foreign_file} || ! -e ${export_foreign_sql} || "$(( $(date +"%s") - $(stat -c "%Y" $export_foreign_file) ))" -gt ${expire_time_sec} ]] ; then

    _logfile_write "Start creation of the ${export_foreign_sql} file." || return 1

    # Create export_foreign_${foreignname}.sql file
    _logfile_write "sed -e 's:FKS_DIR:'${foreignsdir}/':g' \
      \"$_oracle_scripts/export_foreign_gen.sql.in\" > \"${export_foreign_file}\""
    sed -e 's:FKS_DIR:'${foreignsdir}'/:g' "$_oracle_scripts/export_foreign_gen.sql.in" > "${export_foreign_file}"

    # Replace TBL_NAME string
    _logfile_write "sed -i -e 's:FK_NAME:'${foreignname}':g' \"${export_foreign_file}\""
    sed -i -e 's:FK_NAME:'${foreignname}':g' "${export_foreign_file}"

    SQLPLUS_OUTPUT=""

    sqlplus_file "SQLPLUS_OUTPUT" "${export_foreign_file}"
    ans=$?

    _logfile_write "End creation of the ${export_foreign_sql} file." || return 1

  else

    _logfile_write "${export_foreign_file} is updated." || return 1

  fi

  return $ans

}
# commons_oracle_commons_oracle_download_create_export_foreign_end

# commons_oracle_commons_oracle_download_all_types
commons_oracle_download_all_types() {

  local export_single_file=${1}
  local typesdir=${ORACLE_DIR}/types
  local export_types_sql=${typesdir}/export_types.sql

  _logfile_write "Start download of all types." || return 1

  commons_oracle_download_create_export_types ${export_single_file}

  SQLPLUS_OUTPUT=""

  sqlplus_file "SQLPLUS_OUTPUT" "${export_types_sql}"
  ans=$?

  _logfile_write "$SQLPLUS_OUTPUT" || return 1

  _logfile_write "End download of all types." || return 1

  return $ans
}
# commons_oracle_commons_oracle_download_all_types_end

# commons_oracle_commons_oracle_download_create_export_types
commons_oracle_download_create_export_types() {
  
  local export_single_file=${1}
  local typesdir=${ORACLE_DIR}/types
  local export_types_sql=${typesdir}/export_types.sql
  local export_types_file=${typesdir}/export_types_gen.sql

  local expire_time_sec="7200"
  local ans=0


  if [[ ! -e ${export_types_file} || ! -e ${export_types_sql} || "$(( $(date +"%s") - $(stat -c "%Y" $export_types_file) ))" -gt ${expire_time_sec} ]] ; then

    _logfile_write "Start creation of the ${export_types_sql} file." || return 1

    # Create export_types.sql file
    _logfile_write "sed -e 's:TYPES_DIR:'${typesdir}/':g' \
      \"$_oracle_scripts/export_types_gen.sql.in\" > \"${export_types_file}\""
    sed -e 's:TYPES_DIR:'${typesdir}'/:g' -e 's:EXECONEFILE:'${export_single_file}':g' "$_oracle_scripts/export_types_gen.sql.in" > "${export_types_file}"

    SQLPLUS_OUTPUT=""

    sqlplus_file "SQLPLUS_OUTPUT" "${export_types_file}"
    ans=$?

    _logfile_write "End creation of the ${export_types_sql} file." || return 1

  else

    _logfile_write "${export_types_file} is updated." || return 1

  fi

  return $ans

}
# commons_oracle_commons_oracle_download_create_export_types_end

# commons_oracle_commons_oracle_download_type
commons_oracle_download_type() {

  local typename=${1/.sql/}
  local typesdir=${ORACLE_DIR}/types
  local export_type_sql=${typesdir}/export_type_${typename}.sql

  _logfile_write "Start download of the type ${typename}." || return 1

  commons_oracle_download_create_export_type $typename

  SQLPLUS_OUTPUT=""

  sqlplus_file "SQLPLUS_OUTPUT" "${export_type_sql}"
  ans=$?

  _logfile_write "$SQLPLUS_OUTPUT" || return 1

  _logfile_write "End download of the type ${typename}." || return 1

  return $ans
}
# commons_oracle_commons_oracle_download_type_end

# commons_oracle_commons_oracle_download_create_export_type
commons_oracle_download_create_export_type() {

  local typename=${1/.sql/}

  local typesdir=${ORACLE_DIR}/types
  local export_type_sql=${typesdir}/export_type_${typename}.sql
  local export_type_file=${typesdir}/export_types_gen_${typename}.sql

  local expire_time_sec="7200"
  local ans=0

  if [[ ! -e ${export_type_file} || ! -e ${export_type_sql} || "$(( $(date +"%s") - $(stat -c "%Y" $export_type_file) ))" -gt ${expire_time_sec} ]] ; then

    _logfile_write "Start creation of the ${export_type_sql} file." || return 1

    # Create export_type_${typename}.sql file
    _logfile_write "sed -e 's:TYPES_DIR:'${typesdir}/':g' \
      \"$_oracle_scripts/export_type_gen.sql.in\" > \"${export_type_file}\""
    sed -e 's:TYPES_DIR:'${typesdir}'/:g' "$_oracle_scripts/export_type_gen.sql.in" > "${export_type_file}"

    # Replace TBL_NAME string
    _logfile_write "sed -i -e 's:TP_NAME:'${typename}':g' \"${export_type_file}\""
    sed -i -e 's:TP_NAME:'${typename}':g' "${export_type_file}"

    SQLPLUS_OUTPUT=""

    sqlplus_file "SQLPLUS_OUTPUT" "${export_type_file}"
    ans=$?

    _logfile_write "End creation of the ${export_type_sql} file." || return 1

  else

    _logfile_write "${export_type_file} is updated." || return 1

  fi

  return $ans

}
# commons_oracle_commons_oracle_download_create_export_type_end

# commons_oracle_commons_oracle_download_all_packages
commons_oracle_download_all_packages() {

  local packagesdir=${ORACLE_DIR}/packages
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
# commons_oracle_commons_oracle_download_all_packages_end

# commons_oracle_commons_oracle_download_create_export_packages
commons_oracle_download_create_export_packages() {

  local packagesdir=${ORACLE_DIR}/packages
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
# commons_oracle_commons_oracle_download_create_export_packages_end

# commons_oracle_commons_oracle_download_create_export_package
commons_oracle_download_create_export_package() {

  local packagename=${1/.sql/}

  local packagesdir=${ORACLE_DIR}/packages
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
# commons_oracle_commons_oracle_download_create_export_package_end

# commons_oracle_commons_oracle_download_package
commons_oracle_download_package() {

  local packagename=${1/.sql/}
  local packagesdir=${ORACLE_DIR}/packages
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
# commons_oracle_commons_oracle_download_package_end

##########################

# commons_oracle_commons_oracle_download_all_tests
commons_oracle_download_all_tests() {

  local testsdir=${ORACLE_DIR}/tests
  local export_tests_sql=${testsdir}/export_tests.sql

  _logfile_write "Start download of all tests." || return 1

  commons_oracle_download_create_export_tests

  SQLPLUS_OUTPUT=""

  sqlplus_file "SQLPLUS_OUTPUT" "${export_tests_sql}"
  ans=$?

  _logfile_write "$SQLPLUS_OUTPUT" || return 1

  _logfile_write "End download of all tests." || return 1

  return $ans
}
# commons_oracle_commons_oracle_download_all_tests_end

# commons_oracle_commons_oracle_download_create_export_tests
commons_oracle_download_create_export_tests() {

  local testsdir=${ORACLE_DIR}/tests
  local export_tests_sql=${testsdir}/export_tests.sql
  local export_tests_file=${testsdir}/export_tests_gen.sql

  local expire_time_sec="7200"
  local ans=0

  if [[ ! -e ${export_tests_file} || ! -e ${export_tests_sql} || "$(( $(date +"%s") - $(stat -c "%Y" $export_tests_file) ))" -gt ${expire_time_sec} ]] ; then

    _logfile_write "Start creation of the ${export_tests_sql} file." || return 1

    # Create export_tests.sql file
    _logfile_write "sed -e 's:TESTS_DIR:'${testsdir}/':g' \
      \"$_oracle_scripts/export_tests_gen.sql.in\" > \"${export_tests_file}\""
    sed -e 's:TESTS_DIR:'${testsdir}'/:g' "$_oracle_scripts/export_tests_gen.sql.in" > "${export_tests_file}"

    SQLPLUS_OUTPUT=""

    sqlplus_file "SQLPLUS_OUTPUT" "${export_tests_file}"
    ans=$?

    _logfile_write "End creation of the ${export_tests_sql} file." || return 1

  else

    _logfile_write "${export_tests_file} is updated." || return 1

  fi

  return $ans

}
# commons_oracle_commons_oracle_download_create_export_tests_end

# commons_oracle_commons_oracle_download_create_export_test
commons_oracle_download_create_export_test() {

  local testname=${1/.sql/}

  local testsdir=${ORACLE_DIR}/tests
  local export_test_sql=${testsdir}/export_test_${testname}.sql
  local export_test_file=${testsdir}/export_tests_gen_${testname}.sql

  local expire_time_sec="7200"
  local ans=0

  if [[ ! -e ${export_test_file} || ! -e ${export_test_sql} || "$(( $(date +"%s") - $(stat -c "%Y" $export_test_file) ))" -gt ${expire_time_sec} ]] ; then

    _logfile_write "Start creation of the ${export_test_sql} file." || return 1

    # Create export_test_${testname}.sql file
    _logfile_write "sed -e 's:TESTS_DIR:'${testsdir}/':g' \
      \"$_oracle_scripts/export_test_gen.sql.in\" > \"${export_test_file}\""
    sed -e 's:TESTS_DIR:'${testsdir}'/:g' "$_oracle_scripts/export_test_gen.sql.in" > "${export_test_file}"

    # Replace TEST_NAME string
    _logfile_write "sed -i -e 's:TEST_NAME:'${testname}':g' \"${export_test_file}\""
    sed -i -e 's:TEST_NAME:'${testname}':g' "${export_test_file}"

    SQLPLUS_OUTPUT=""

    sqlplus_file "SQLPLUS_OUTPUT" "${export_test_file}"
    ans=$?

    _logfile_write "End creation of the ${export_test_sql} file." || return 1

  else

    _logfile_write "${export_test_file} is updated." || return 1

  fi

  return $ans

}
# commons_oracle_commons_oracle_download_create_export_test_end

# commons_oracle_commons_oracle_download_test
commons_oracle_download_test() {

  local testname=${1/.sql/}
  local testsdir=${ORACLE_DIR}/tests
  local export_test_sql=${testsdir}/export_test_${testname}.sql

  _logfile_write "Start download of the test ${testname}." || return 1

  commons_oracle_download_create_export_test $testname

  SQLPLUS_OUTPUT=""

  sqlplus_file "SQLPLUS_OUTPUT" "${export_test_sql}"
  ans=$?

  _logfile_write "$SQLPLUS_OUTPUT" || return 1

  _logfile_write "End download of the test ${testname}." || return 1

  return $ans
}
# commons_oracle_commons_oracle_download_test_end


##########################



# commons_oracle_commons_oracle_download_all_functions
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
# commons_oracle_commons_oracle_download_all_functions_end

# commons_oracle_commons_oracle_download_create_export_functions
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
# commons_oracle_commons_oracle_download_create_export_functions_end

# commons_oracle_commons_oracle_download_function
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
# commons_oracle_commons_oracle_download_function_end

# commons_oracle_commons_oracle_download_create_export_function
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
# commons_oracle_commons_oracle_download_create_export_function_end

# commons_oracle_commons_oracle_download_all_views
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
# commons_oracle_commons_oracle_download_all_views_end

# commons_oracle_commons_oracle_download_create_export_views
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
# commons_oracle_commons_oracle_download_create_export_views_end

# commons_oracle_commons_oracle_download_view
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
# commons_oracle_commons_oracle_download_view_end

# commons_oracle_commons_oracle_download_create_export_view
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
# commons_oracle_commons_oracle_download_create_export_view_end

# commons_oracle_commons_oracle_download_all_jobs
commons_oracle_download_all_jobs() {

  local jobsdir=${ORACLE_DIR}/jobs
  local export_jobs_sql=${jobsdir}/export_job.sql

  _logfile_write "Start download of all jobs." || return 1

  commons_oracle_download_create_export_jobs

  SQLPLUS_OUTPUT=""

  sqlplus_file "SQLPLUS_OUTPUT" "${export_jobs_sql}"
  ans=$?

  _logfile_write "$SQLPLUS_OUTPUT" || return 1

  _logfile_write "End download of all jobs." || return 1

  return $ans
}
# commons_oracle_commons_oracle_download_all_jobs_end

# commons_oracle_commons_oracle_download_create_export_jobs
commons_oracle_download_create_export_jobs() {

  local jobsdir=${ORACLE_DIR}/jobs
  local export_jobs_sql=${jobsdir}/export_job.sql
  local export_jobs_file=${jobsdir}/export_job_gen.sql

  local expire_time_sec="7200"
  local ans=0

  if [[ ! -e ${export_jobs_file} || ! -e ${export_jobs_sql} || "$(( $(date +"%s") - $(stat -c "%Y" $export_jobs_file) ))" -gt ${expire_time_sec} ]] ; then

    _logfile_write "Start creation of the ${export_jobs_sql} file." || return 1

    # Create export_job.sql file
    _logfile_write "sed -e 's:JOBS_DIR:'${jobsdir}/':g' \
      \"$_oracle_scripts/export_jobs_gen.sql.in\" > \"${export_jobs_file}\""
    sed -e 's:JOBS_DIR:'${jobsdir}'/:g' "$_oracle_scripts/export_jobs_gen.sql.in" > "${export_jobs_file}"

    SQLPLUS_OUTPUT=""

    sqlplus_file "SQLPLUS_OUTPUT" "${export_jobs_file}"
    ans=$?

    _logfile_write "End creation of the ${export_jobs_sql} file." || return 1

  else

    _logfile_write "${export_jobs_file} is updated." || return 1

  fi

  return $ans
}
# commons_oracle_commons_oracle_download_create_export_jobs_end

# commons_oracle_commons_oracle_download_job
commons_oracle_download_job() {

  local jobname=${1/.sql/}
  local jobsdir=${ORACLE_DIR}/jobs
  local export_job_sql=${jobsdir}/export_job_${jobname}.sql

  _logfile_write "Start download of the job ${jobname}." || return 1

  commons_oracle_download_create_export_job $jobname

  SQLPLUS_OUTPUT=""

  sqlplus_file "SQLPLUS_OUTPUT" "${export_job_sql}"
  ans=$?

  _logfile_write "$SQLPLUS_OUTPUT" || return 1

  _logfile_write "End download of the job ${jobname}." || return 1

  return $ans
}
# commons_oracle_commons_oracle_download_job_end

# commons_oracle_commons_oracle_download_create_export_job
commons_oracle_download_create_export_job() {

  local jobname=${1/.sql/}

  local jobsdir=${ORACLE_DIR}/jobs
  local export_job_sql=${jobsdir}/export_job_${jobname}.sql
  local export_job_file=${jobsdir}/export_jobs_gen_${jobname}.sql

  local expire_time_sec="7200"
  local ans=0

  if [[ ! -e ${export_job_file} || ! -e ${export_job_sql} || "$(( $(date +"%s") - $(stat -c "%Y" $export_job_file) ))" -gt ${expire_time_sec} ]] ; then

    _logfile_write "Start creation of the ${export_job_sql} file." || return 1

    # Create export_job_${jobname}.sql file
    _logfile_write "sed -e 's:JOBS_DIR:'${jobsdir}/':g' \
      \"$_oracle_scripts/export_job_gen.sql.in\" > \"${export_job_file}\""
    sed -e 's:JOBS_DIR:'${jobsdir}'/:g' "$_oracle_scripts/export_job_gen.sql.in" > "${export_job_file}"

    # Replace JOB_NAME string
    _logfile_write "sed -i -e 's:JOB_NAME:'${jobname}':g' \"${export_job_file}\""
    sed -i -e 's:JOB_NAME:'${jobname}':g' "${export_job_file}"

    SQLPLUS_OUTPUT=""

    sqlplus_file "SQLPLUS_OUTPUT" "${export_job_file}"
    ans=$?

    _logfile_write "End creation of the ${export_job_sql} file." || return 1

  else

    _logfile_write "${export_job_file} is updated." || return 1

  fi

  return $ans

}
# commons_oracle_commons_oracle_download_create_export_job_end

# commons_oracle_commons_oracle_download_all_procedures
commons_oracle_download_all_procedures() {

  local proceduresdir=${ORACLE_DIR}/procedures
  local export_procedures_sql=${proceduresdir}/export_procedures.sql

  _logfile_write "Start download of all procedures." || return 1

  commons_oracle_download_create_export_procedures

  SQLPLUS_OUTPUT=""

  sqlplus_file "SQLPLUS_OUTPUT" "${export_procedures_sql}"
  ans=$?

  _logfile_write "$SQLPLUS_OUTPUT" || return 1

  _logfile_write "End download of all procedures." || return 1

  return $ans
}
# commons_oracle_commons_oracle_download_all_procedures_end

# commons_oracle_commons_oracle_download_create_export_procedures
commons_oracle_download_create_export_procedures() {

  local proceduresdir=${ORACLE_DIR}/procedures
  local export_procedures_sql=${proceduresdir}/export_procedures.sql
  local export_procedures_file=${proceduresdir}/export_procedures_gen.sql

  local expire_time_sec="7200"
  local ans=0

  if [[ ! -e ${export_procedures_file} || ! -e ${export_procedures_sql} || "$(( $(date +"%s") - $(stat -c "%Y" $export_procedures_file) ))" -gt ${expire_time_sec} ]] ; then

    _logfile_write "Start creation of the ${export_procedures_sql} file." || return 1

    # Create export_procedure.sql file
    _logfile_write "sed -e 's:PROCS_DIR:'${proceduresdir}/':g' \
      \"$_oracle_scripts/export_procedures_gen.sql.in\" > \"${export_procedures_file}\""
    sed -e 's:PROCS_DIR:'${proceduresdir}'/:g' "$_oracle_scripts/export_procedures_gen.sql.in" > "${export_procedures_file}"

    SQLPLUS_OUTPUT=""

    sqlplus_file "SQLPLUS_OUTPUT" "${export_procedures_file}"
    ans=$?

    _logfile_write "End creation of the ${export_procedures_sql} file." || return 1

  else

    _logfile_write "${export_procedures_file} is updated." || return 1

  fi

  return $ans
}
# commons_oracle_commons_oracle_download_create_export_procedures_end

# commons_oracle_commons_oracle_download_procedure
commons_oracle_download_procedure() {

  local procedurename=${1/.sql/}
  local proceduresdir=${ORACLE_DIR}/procedures
  local export_procedure_sql=${proceduresdir}/export_procedure_${procedurename}.sql

  _logfile_write "Start download of the procedure ${procedurename}." || return 1

  commons_oracle_download_create_export_procedure $procedurename

  SQLPLUS_OUTPUT=""

  sqlplus_file "SQLPLUS_OUTPUT" "${export_procedure_sql}"
  ans=$?

  _logfile_write "$SQLPLUS_OUTPUT" || return 1

  _logfile_write "End download of the procedure ${procedurename}." || return 1

  return $ans
}
# commons_oracle_commons_oracle_download_procedure_end

# commons_oracle_commons_oracle_download_create_export_procedure
commons_oracle_download_create_export_procedure() {

  local procedurename=${1/.sql/}

  local proceduresdir=${ORACLE_DIR}/procedures
  local export_procedure_sql=${proceduresdir}/export_procedure_${procedurename}.sql
  local export_procedure_file=${proceduresdir}/export_procedures_gen_${procedurename}.sql

  local expire_time_sec="7200"
  local ans=0

  if [[ ! -e ${export_procedure_file} || ! -e ${export_procedure_sql} || "$(( $(date +"%s") - $(stat -c "%Y" $export_procedure_file) ))" -gt ${expire_time_sec} ]] ; then

    _logfile_write "Start creation of the ${export_procedure_sql} file." || return 1

    # Create export_procedure_${procedurename}.sql file
    _logfile_write "sed -e 's:PROCS_DIR:'${proceduresdir}/':g' \
      \"$_oracle_scripts/export_procedure_gen.sql.in\" > \"${export_procedure_file}\""
    sed -e 's:PROCS_DIR:'${proceduresdir}'/:g' "$_oracle_scripts/export_procedure_gen.sql.in" > "${export_procedure_file}"

    # Replace PROC_NAME string
    _logfile_write "sed -i -e 's:PROC_NAME:'${procedurename}':g' \"${export_procedure_file}\""
    sed -i -e 's:PROC_NAME:'${procedurename}':g' "${export_procedure_file}"

    SQLPLUS_OUTPUT=""

    sqlplus_file "SQLPLUS_OUTPUT" "${export_procedure_file}"
    ans=$?

    _logfile_write "End creation of the ${export_procedure_sql} file." || return 1

  else

    _logfile_write "${export_procedure_file} is updated." || return 1

  fi

  return $ans

}
# commons_oracle_commons_oracle_download_create_export_procedure_end


# commons_oracle_commons_oracle_download_all_schedules
commons_oracle_download_all_schedules() {

  local schedulesdir=${ORACLE_DIR}/schedules
  local export_schedules_sql=${schedulesdir}/export_schedule.sql

  _logfile_write "Start download of all schedules." || return 1

  commons_oracle_download_create_export_schedules

  SQLPLUS_OUTPUT=""

  sqlplus_file "SQLPLUS_OUTPUT" "${export_schedules_sql}"
  ans=$?

  _logfile_write "$SQLPLUS_OUTPUT" || return 1

  _logfile_write "End download of all schedules." || return 1

  return $ans
}
# commons_oracle_commons_oracle_download_all_schedules_end

# commons_oracle_commons_oracle_download_create_export_schedules
commons_oracle_download_create_export_schedules() {

  local schedulesdir=${ORACLE_DIR}/schedules
  local export_schedules_sql=${schedulesdir}/export_schedule.sql
  local export_schedules_file=${schedulesdir}/export_schedule_gen.sql

  local expire_time_sec="7200"
  local ans=0

  if [[ ! -e ${export_schedules_file} || ! -e ${export_schedules_sql} || "$(( $(date +"%s") - $(stat -c "%Y" $export_schedules_file) ))" -gt ${expire_time_sec} ]] ; then

    _logfile_write "Start creation of the ${export_schedules_sql} file." || return 1

    # Create export_schedule.sql file
    _logfile_write "sed -e 's:SCHEDULES_DIR:'${schedulesdir}/':g' \
      \"$_oracle_scripts/export_schedules_gen.sql.in\" > \"${export_schedules_file}\""
    sed -e 's:SCHEDULES_DIR:'${schedulesdir}'/:g' "$_oracle_scripts/export_schedules_gen.sql.in" > "${export_schedules_file}"

    SQLPLUS_OUTPUT=""

    sqlplus_file "SQLPLUS_OUTPUT" "${export_schedules_file}"
    ans=$?

    _logfile_write "End creation of the ${export_schedules_sql} file." || return 1

  else

    _logfile_write "${export_schedules_file} is updated." || return 1

  fi

  return $ans

}
# commons_oracle_commons_oracle_download_create_export_schedules_end

# commons_oracle_commons_oracle_download_schedule
commons_oracle_download_schedule() {

  local schedulename=${1/.sql/}
  local schedulesdir=${ORACLE_DIR}/schedules
  local export_schedule_sql=${schedulesdir}/export_schedule_${schedulename}.sql

  _logfile_write "Start download of the schedule ${schedulename}." || return 1

  commons_oracle_download_create_export_schedule $schedulename

  SQLPLUS_OUTPUT=""

  sqlplus_file "SQLPLUS_OUTPUT" "${export_schedule_sql}"
  ans=$?

  _logfile_write "$SQLPLUS_OUTPUT" || return 1

  _logfile_write "End download of the schedule ${schedulename}." || return 1

  return $ans
}
# commons_oracle_commons_oracle_download_schedule_end

# commons_oracle_commons_oracle_download_create_export_schedule
commons_oracle_download_create_export_schedule() {

  local schedulename=${1/.sql/}

  local schedulesdir=${ORACLE_DIR}/schedules
  local export_schedule_sql=${schedulesdir}/export_schedule_${schedulename}.sql
  local export_schedule_file=${schedulesdir}/export_schedules_gen_${schedulename}.sql

  local expire_time_sec="7200"
  local ans=0

  if [[ ! -e ${export_schedule_file} || ! -e ${export_schedule_sql} || "$(( $(date +"%s") - $(stat -c "%Y" $export_schedule_file) ))" -gt ${expire_time_sec} ]] ; then

    _logfile_write "Start creation of the ${export_schedule_sql} file." || return 1

    # Create export_schedule_${schedulename}.sql file
    _logfile_write "sed -e 's:SCHEDULES_DIR:'${schedulesdir}/':g' \
      \"$_oracle_scripts/export_schedule_gen.sql.in\" > \"${export_schedule_file}\""
    sed -e 's:SCHEDULES_DIR:'${schedulesdir}'/:g' "$_oracle_scripts/export_schedule_gen.sql.in" > "${export_schedule_file}"

    # Replace SCHEDULE_NAME string
    _logfile_write "sed -i -e 's:SCHEDULE_NAME:'${schedulename}':g' \"${export_schedule_file}\""
    sed -i -e 's:SCHEDULE_NAME:'${schedulename}':g' "${export_schedule_file}"

    SQLPLUS_OUTPUT=""

    sqlplus_file "SQLPLUS_OUTPUT" "${export_schedule_file}"
    ans=$?

    _logfile_write "End creation of the ${export_schedule_sql} file." || return 1

  else

    _logfile_write "${export_schedule_file} is updated." || return 1

  fi

  return $ans

}
# commons_oracle_commons_oracle_download_create_export_schedule_end

# commons_oracle_commons_oracle_download_all_triggers
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
# commons_oracle_commons_oracle_download_all_triggers_end

# commons_oracle_commons_oracle_download_create_export_triggers
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
# commons_oracle_commons_oracle_download_create_export_triggers_end

# commons_oracle_commons_oracle_download_trigger
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
# commons_oracle_commons_oracle_download_trigger_end

# commons_oracle_commons_oracle_download_create_export_trigger
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
# commons_oracle_commons_oracle_download_create_export_trigger_end

# commons_oracle_commons_oracle_compile_file
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
# commons_oracle_commons_oracle_compile_file_end

# commons_oracle_commons_oracle_compile_all_packages
commons_oracle_compile_all_packages () {

  local msg="$1"
  local directory="$ORACLE_DIR/packages"

  commons_oracle_compile_all_from_dir "$directory" "of all packages" "$msg" || return 1

  return 0
}
# commons_oracle_commons_oracle_compile_all_packages_end

# commons_oracle_commons_oracle_compile_all_triggers
commons_oracle_compile_all_triggers () {

  local msg="$1"
  local directory="$ORACLE_DIR/triggers"

  commons_oracle_compile_all_from_dir "$directory" "of all triggers" "$msg" || return 1

  return 0
}
# commons_oracle_commons_oracle_compile_all_triggers_end

# commons_oracle_commons_oracle_compile_all_functions
commons_oracle_compile_all_functions () {

  local msg="$1"
  local directory="$ORACLE_DIR/functions"

  commons_oracle_compile_all_from_dir "$directory" "of all functions" "$msg" || return 1

  return 0
}
# commons_oracle_commons_oracle_compile_all_functions_end

# commons_oracle_commons_oracle_compile_all_views
commons_oracle_compile_all_views () {

  local msg="$1"
  local directory="$ORACLE_DIR/views"

  commons_oracle_compile_all_from_dir "$directory" "of all views" "$msg" || return 1

  return 0
}
# commons_oracle_commons_oracle_compile_all_views_end

# commons_oracle_commons_oracle_compile_all_jobs
commons_oracle_compile_all_jobs () {

  local msg="$1"
  local directory="$ORACLE_DIR/jobs"

  commons_oracle_compile_all_from_dir "$directory" "of all jobs" "$msg" || return 1

  return 0
}
# commons_oracle_commons_oracle_compile_all_jobs_end

# commons_oracle_commons_oracle_compile_all_procedures
commons_oracle_compile_all_procedures () {

  local msg="$1"
  local directory="$ORACLE_DIR/procedures"

  commons_oracle_compile_all_from_dir "$directory" "of all procedures" "$msg" || return 1

  return 0
}
# commons_oracle_commons_oracle_compile_all_procedures_end


# commons_oracle_commons_oracle_compile_all_schedules
commons_oracle_compile_all_schedules () {

  local msg="$1"
  local directory="$ORACLE_DIR/schedules"

  commons_oracle_compile_all_from_dir "$directory" "of all schedules" "$msg" || return 1

  return 0
}
# commons_oracle_commons_oracle_compile_all_schedules_end

# commons_oracle_commons_oracle_compile_all_tests
commons_oracle_compile_all_tests () {

  local msg="$1"
  local directory="$ORACLE_DIR/tests"

  commons_oracle_compile_all_from_dir "$directory" "of all tests" "$msg" || return 1

  return 0
}
# commons_oracle_commons_oracle_compile_all_tests_end


# commons_oracle_commons_oracle_compile_all_from_dir
commons_oracle_compile_all_from_dir () {

  local directory="$1"
  local msg_head="$2"
  local msg="$3"
  local f=""
  local fb=""
  local ex_f=""
  local exc=0

  _logfile_write "(oracle) Start compilation $msg_head: $msg" || return 1
  
  [[ $DEBUG && $DEBUG == true ]] && echo -en "ORACLE_COMPILE_FILES_EXCLUDED: $ORACLE_COMPILE_FILES_EXCLUDED\n"

  for i in $directory/*.sql ; do

    exc=0

    fb=`basename $i`
    f="${fb/.sql/}"

    # Check if file is excluded
    if [ ! -z "$ORACLE_COMPILE_FILES_EXCLUDED" ] ; then

      for e in $ORACLE_COMPILE_FILES_EXCLUDED ; do

        is_regex=$(echo $e | grep "\*" | wc -l)

        if [ $is_regex -eq 1 ]; then

            if [[ "$f" =~ ${e} ]] ; then

              exc=1

              _logfile_write "(oracle) Exclude file $fb for user request." || return 1

              break

            fi

        else

            ex_f=`basename $e`
            ex_f="${ex_f/.sql/}"

            if [ "$ex_f" == "$f" ] ; then
              exc=1

              _logfile_write "(oracle) Exclude file $fb for user request." || return 1

              break
            fi
        
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
# commons_oracle_commons_oracle_compile_all_from_dir_end

# commons_oracle_commons_oracle_show_tables
commons_oracle_show_tables () {

  local columns="${1:-"D.TABLE_NAME||'|'||D.NUM_ROWS||'|'||D.BLOCKS||'|'||D.AVG_ROW_LEN||'|'||NVL(TMP.N_PART, 0)||'|'||NVL(TMP.N_SUBPART, 0)||'|'||NVL(TO_CHAR(TMP.LAST_UPDATE, 'YYYY-MM-DD HH24:MI'), 'N.A.')"}"
  local filter="${2}"

  local cmd="
    SELECT ${columns}
    FROM (
      SELECT AT.table_name, S.NUM_ROWS, S.BLOCKS, S.AVG_ROW_LEN
      FROM all_tables AT,
          ALL_TAB_STATISTICS S
     WHERE AT.owner = '${ORACLE_USER}'
     AND S.OWNER = '${ORACLE_USER}'
     AND S.PARTITION_NAME IS NULL
     AND AT.table_name  = S.TABLE_NAME ${filter}
    ) D
    LEFT JOIN (
        SELECT TABLE_NAME,
               MAX(STATS_UPDATE_TIME) LAST_UPDATE,
              COUNT(PARTITION_NAME) AS N_PART,
              COUNT(SUBPARTITION_NAME) AS N_SUBPART
        FROM ALL_TAB_STATS_HISTORY
        GROUP BY TABLE_NAME
    ) TMP
    ON  TMP.TABLE_NAME = D.TABLE_NAME
    ORDER by D.table_name
  "

  local sqlopts="set echo off heading off feedback off pages 50000"
  sqlplus_cmd_4var "ORACLE_ANS" "${cmd}" "" "" "${sqlopts}" "1" || return 1

  return 0
}
# commons_oracle_commons_oracle_show_tables_end

# commons_oracle_commons_oracle_show_indexes
commons_oracle_show_indexes () {

  #   SELECT TMP.TABLE_NAME,
  #       TMP.INDEX_NAME,
  #       TMP.INDEX_TYPE,
  #       TMP.UNIQUE_IDX,
  #       TMP.COMPRESSION,
  #       TMP.TABLESPACE_NAME,
  #       TMP.CONSTRAINT_TYPE,
  #       TMP.STATUS,
  #       TMP.COLUMNS,
  #       TMP.LOGGING,
  #       TMP.CONSTRAINT_NAME,
  #       TMP.BLEVEL,
  #       TMP.AVG_DATA_BLOCKS_PER_KEY,
  #       TMP.NUM_ROWS,
  #       TMP.SAMPLE_SIZE,
  #       TMP.LAST_ANALYZED
  local ret_columns="${1:-"TMP.TABLE_NAME||'|'||TMP.INDEX_NAME||'|'||TMP.INDEX_TYPE||'|'||TMP.UNIQUE_IDX||'|'||TMP.COMPRESSION||'|'||TMP.TABLESPACE_NAME||'|'||TMP.CONSTRAINT_TYPE||'|'||TMP.STATUS||'|'||TMP.COLUMNS||'|'||TMP.LOGGING||'|'||TMP.CONSTRAINT_NAME||'|'||TMP.BLEVEL||'|'||TMP.AVG_DATA_BLOCKS_PER_KEY||'|'||TMP.NUM_ROWS||'|'||TMP.SAMPLE_SIZE||'|'||NVL(TO_CHAR(TMP.LAST_ANALYZED, 'YYYY-MM-DD HH24:MI'), 'N.A')"}"
  local filter="${2}"

  local cmd="SELECT ${ret_columns}
  FROM (
    SELECT
          AI.TABLE_NAME,
          AI.INDEX_NAME,
          AI.INDEX_TYPE,
          CASE WHEN AI.UNIQUENESS = 'UNIQUE' THEN 'Y' ELSE 'N' END AS UNIQUE_IDX,
          AC.CONSTRAINT_TYPE,
          AC.CONSTRAINT_NAME,
          (
           SELECT LISTAGG(COLUMN_NAME, ',')
                 WITHIN GROUP (ORDER BY COLUMN_NAME) \"ALL_CONS_COLUMNS\"
          FROM ALL_CONS_COLUMNS
          WHERE TABLE_NAME = AI.TABLE_NAME
          AND CONSTRAINT_NAME = AC.CONSTRAINT_NAME
          ) AS COLUMNS,
          CASE WHEN AI.COMPRESSION = 'DISABLED' THEN 'N' ELSE 'Y' END AS COMPRESSION,
          AI.TABLESPACE_NAME,
          AI.LOGGING,
          AI.BLEVEL,
          AI.AVG_DATA_BLOCKS_PER_KEY,
          AI.STATUS,
          AI.NUM_ROWS,
          AI.SAMPLE_SIZE,
          AI.LAST_ANALYZED,
          AI.INDEXING
    FROM ALL_INDEXES  AI,
         ALL_CONSTRAINTS AC
    WHERE AI.OWNER = '${ORACLE_USER}'
    AND AC.INDEX_NAME = AI.INDEX_NAME ${filter}
    ORDER BY AI.TABLE_NAME, AI.INDEX_NAME
  ) TMP
"

  local sqlopts="set echo off heading off feedback off pages 50000 lines 5000"
  sqlplus_cmd_4var "ORACLE_ANS" "${cmd}" "" "" "${sqlopts}" "1" || return 1

  return 0
}
# commons_oracle_commons_oracle_show_indexes_end


# vim: syn=sh filetype=sh
