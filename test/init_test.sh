#!/bin/bash
# Author:  Geaaru

# Include and initialize all variables to use dbrm module.
testdir=`dirname $0`

modulesdir="${testdir}/../modules"
coredir="${testdir}/../src/core"
etcdir="${testdir}/../etc"
SQLCA="sqlite"
LOCAL_DIR="${testdir}"
DRM_DB="$LOCAL_DIR/dbm_test.db"
DBRM_CORE_FILES_DIR="${coredir}"

load_core_scripts () {

  # Load core scripts
  for f in $coredir/*.sh ; do
    . $f
  done

}

load_modules () {
   # Load modules

   modules2load="logfile.mod \
      out_handler.mod \
      out_stdout.mod \
      sqlite.mod \
      sql_handler.mod"

   for mod in $modules2load ; do
      . $modulesdir/$mod
      if type -t _${name}_init > /dev/null ; then

         [[ $DEBUG && $DEBUG == true ]] && echo "Call init method of the module $name"
         _${name}_init
      fi
      if type -t ${name}_version > /dev/null ; then
        version=`${name}_version`
      else
        version="N.A."
      fi
      [[ $DEBUG && $DEBUG == true ]] && echo "Loaded module $name $version"
      modules="$modules $name"
   done

   . $modulesdir/dbm.mod

   modules="$modules dbm"

   # Export modules variable so every modules can known
   # what modules are installed.
   export modules

   # Override dbm_schema
   dbm_schema=${etcdir}/dbm_sqlite_schema.sql

   # Initialize dbm module
   _dbm_init

   # Call post_init function of all modules
   for name in $modules ; do
     if type -t _${name}_post_init > /dev/null ; then

         [[ $DEBUG ]] && echo "Call post_init method of the module $name"
         _${name}_post_init

     fi
   done
}

unload_modules () {

   # Check if there is a deinit method
   for i in $modules ; do
      if type -t ${i}_deinit > /dev/null ; then
         [[ $DEBUG ]] && echo "Call deinit method of the module $i"
         ${i}_deinit
      fi
   done

}

remove_dbm_db () {

  if [ -f $DRM_DB ] ; then
    rm -f $DRM_DB
  fi

}

# vim: ts=2 sw=2 expandtab filetype=sh
