#!/bin/bash
# Author: Geaaru
# Description: Script to fix html pages generate by sphinx.
#              FWIS it seems that directories with underscore
#              as first character are not visible.

staticdir='./_static'
projectdir='.'

fix_sources() {

   files=(
     $(grep _sources  _static/  -r -H  -l --color=none)
   )

   for f in ${!files[@]} ; do

      echo "Fixing file ${files[$f]}..."
      sed -e 's:_sources/:sources/:g' -i ${files[$f]}

   done

   return 0
}

fix_static() {

   files=(
     $(grep _static  ${projectdir}/*  -r -H   --color=none --exclude=fix_sphinx2gh-pages.sh --exclude-dir=css --exclude-dir=sources -l)
   )

   for f in ${!files[@]} ; do
      echo "Fixing file ${files[$f]}..."
      sed -e 's:_static/:static/:g'  -i ${files[$f]}
   done

   return 0
}

main() {

   fix_sources || return 1

   fix_static || return 1

   return 0
}

main
exit $?

# vim: ts=3 sw=3 expandtab
