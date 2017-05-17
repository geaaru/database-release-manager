# Project: database-release-manager
# Author(s): Geaaru geaaru<at>gmail.com
# $Id$
# License: GPL 2.0

EXTRA_DIST = \
				 dbm.mod.in \
				 install.mod.in \
				 logfile.mod.in \
				 mariadb.mod.in \
				 oracle.mod.in \
				 sql_handler.mod.in \
				 sqlite.mod.in \
				 out_handler.mod.in \
				 out_stdout.mod.in \
				 ssl.mod.in \
				 package.mod.in \
				 psql.mod.in \
				 mongo.mod.in \
				 sweeper.mod.in

modules = \
			 dbm.mod \
			 install.mod \
			 logfile.mod \
			 mariadb.mod \
			 oracle.mod \
			 sql_handler.mod \
			 sqlite.mod \
			 out_handler.mod \
			 out_stdout.mod \
			 ssl.mod \
			 package.mod \
			 psql.mod \
			 mongo.mod \
			 sweeper.mod

DISTCLEANFILES = $(modules)
CLEANFILES = $(modules)

modulesdir = $(MODULES_DIR)
dist_modules_DATA = $(modules)


