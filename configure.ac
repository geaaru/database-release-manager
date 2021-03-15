# Project: database-release-manager
# Homepage: https://github.com/geaaru/database-release-manager
# Author(s): geaaru
# Version: $Id$
# License: GPL 2.0

AC_PREREQ([2.69])
AC_INIT([database-release-manager], [0.2.1], [geaaru@gmail.com])

AM_INIT_AUTOMAKE

DBRM_MAJOR_VERSION=0
DBRM_MINOR_VERSION=1
DBRM_EXTRA_VERSION=0

DBRM_VERSION=$DBRM_MAJOR_VERSION.$DBRM_MINOR_VERSION.$DBRM_EXTRA_VERSION

AC_SUBST(DBRM_MAJOR_VERSION)
AC_SUBST(DBRM_MINOR_VERSION)
AC_SUBST(DBRM_EXTRA_VERSION)
AC_SUBST(DBRM_VERSION)

AC_PREFIX_DEFAULT([/usr/local])

AC_ARG_WITH(configfile-path, AS_HELP_STRING([--with-configfile-path=[path]],
            [Default config file path. Default /etc/dbrm.conf.]),
            [CONFIG_FILE=$withval], [CONFIG_FILE='${prefix}/etc/dbrm.conf'])
AC_ARG_WITH(modules-dir, AS_HELP_STRING([--with-modules-dir=[mods_dir]],
            [Dbrm modules directory. Default PREFIX/share/dbrm/modules.]),
            [MODULES_DIR=$withval], [MODULES_DIR='${prefix}/share/dbrm/modules'])
AC_ARG_WITH(core-dir, AS_HELP_STRING([--with-modules-core-dir=[core_dir]],
            [Dbrm core script directory. Default PREFIX/share/dbrm/core/]),
            [CORE_DIR=$withval], [CORE_DIR='${prefix}/share/dbrm/core'])

# Checks for programs.
AC_PROG_AWK
AC_PATH_PROG(SQLITE3, sqlite3)
AC_PATH_PROG(RM, rm)
AC_PATH_PROG(CP, cp)
AC_PATH_PROG(MV, mv)
AC_PATH_PROG(LN, ln)
AC_PATH_PROG(MKDIR, mkdir)

AC_PATH_PROG(BASH_PATH, bash)
if [ test -z "$BASH_PATH" ]; then
  AC_MSG_ERROR("Bash program not found")
fi

AC_PATH_PROG(GETOPT, getopt)
if [ test -z "$GETOPT" ] ; then
  AC_MSG_ERROR("getopt program not found.")
fi

# Define share dir
SHAREDIR='${prefix}/share/dbrm'
# Define main config file dir
CONFIG_FILE_DIR=$(dirname $CONFIG_FILE)
CONFIG_FILE_NAME=$(basename $CONFIG_FILE)


AC_SUBST(RM)
AC_SUBST(MV)
AC_SUBST(CP)
AC_SUBST(LN)
AC_SUBST(CAT)
AC_SUBST(MKDIR)
AC_SUBST(CONFIG_FILE)
AC_SUBST(MODULES_DIR)
AC_SUBST(CORE_DIR)
AC_SUBST(BASH_PATH)
AC_SUBST(SQLITE3)
AC_SUBST(SHAREDIR)
AC_SUBST(CONFIG_FILE_DIR)
AC_SUBST(CONFIG_FILE_NAME)
AC_SUBST(prefix)

# Checks for library functions.
AC_CONFIG_FILES([
                 Makefile
                 etc/Makefile
                 etc/dbrm.conf.example
                 modules/Makefile
                 modules/dbm.mod
                 modules/install.mod
                 modules/logfile.mod
                 modules/mariadb.mod
                 modules/oracle.mod
                 modules/sql_handler.mod
                 modules/sqlite.mod
                 modules/out_handler.mod
                 modules/out_stdout.mod
                 modules/package.mod
                 modules/ssl.mod
                 modules/psql.mod
                 modules/mongo.mod
                 modules/sweeper.mod
                 src/Makefile
                 src/dbrm
                 src/core/Makefile
                 src/share/Makefile
                 docs/Makefile
                 docs/sphinx/Makefile
                 docs/sphinx/conf.py
                ])

AC_OUTPUT
