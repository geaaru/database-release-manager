#!/bin/bash
#------------------------------------------------
# Author(s): Geaaru, geaaru@gmail.com
# $Id$
# License: GPL 2.0
#------------------------------------------------

# return 0 on success
# return 1 on error
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

# return 0 on success
# return 1 on error
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

# return 0 on when connection is ok
# return 1 on error
commons_oracle_check_connection () {

  if [ -z $SQLPLUS ] ; then
    return 1
  fi

  if [ -z $sqlplus_auth ] ; then
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

# vim: syn=sh filetype=sh
