# Project: database-release-manager
# Author(s): Geaaru geaaru<at>gmail.com
# $Id$
# License: GPL 2.0

EXTRA_DIST = dbrm.conf.example.in dbm_sqlite_schema.sql
DISTCLEANFILES = dbrm.conf.example @CONFIG_FILE_NAME@
CLEANFILES = dbrm.conf.example @CONFIG_FILE_NAME@

sharedir = $(SHAREDIR)
dist_share_DATA = \
						dbrm.conf.example
						dbm_sqlite_schema.sql

etcdir = $(CONFIG_FILE_DIR)
dist_etc_DATA = @CONFIG_FILE_NAME@

@CONFIG_FILE_NAME@:
	cp dbrm.conf.example @CONFIG_FILE_NAME@

dbrm.conf.example: @CONFIG_FILE_NAME@
	sed -i \
		-e 's/^MODULES_DIR=/#MODULES_DIR=/' \
		-e 's/^LOCAL_DIR=/#LOCAL_DIR=/' \
		-e 's/^LOCAL_CONFIG_FILE=/#LOCAL_CONFIG_FILE=/' \
		-e 's/^DRM_DB=/#DBRM_DB=/' $@

