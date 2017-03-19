# Project: database-release-manager
# Author(s): Geaaru geaaru<at>gmail.com
# $Id$
# License: GPL 2.0

SUBDIRS = sphinx
DIST_SUBDIRS = sphinx

ROOTDIR = $(srcdir)/..
SPHINXCONFDIR = $(ROOTDIR)/docs/sphinx
SPHINXSRCDIR = $(ROOTDIR)/docs/sources
SPHINXBUILDDIR = $(ROOTDIR)/docs/_build
SPHINXOPTS = -d $(SPHINXBUILDDIR)/doctrees -b html -c $(SPHINXCONFDIR)

.PHONY: predoc
predoc:
		@echo "ROOTDIR = $(ROOTDIR)"
		-@if [ ! -e $(SPHINXSRCDIR)/src ] ; then \
				ln -s $(ROOTDIR)/../src $(SPHINXSRCDIR) ;\
		fi
		-@if [ ! -e $(SPHINXSRCDIR)/modules ] ; then \
				ln -s $(ROOTDIR)/../modules $(SPHINXSRCDIR) ;\
		fi

.PHONY: docs
docs: predoc
		@echo "Processing documentation...."
		sphinx-build $(SPHINXOPTS) $(SPHINXSRCDIR) $(SPHINXBUILDDIR)

