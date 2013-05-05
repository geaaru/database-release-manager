#!/bin/bash
#------------------------------------------------
# Author(s): Geaaru, geaaru@gmail.com
# $Id$
# License: GPL 2.0
#------------------------------------------------

error_handled () {
   local result=$?
   if [ $result -ne 0 ] ; then
      echo -en "$1\n"
      exit 1
   fi
}

# return 0   yes
# return 1   no
# return 2   empty
confirmation_question () {
   echo -en "$1"
   read ans

   [[ $DEBUG ]] && echo -en "Answer: $ans\n"
   if [ -z $ans ]; then
      return 2
   fi

   if [[ x"$ans" == "xyes" || x"$ans" == "xY" || x"$ans" == "xy" || x"$ans" == "xYes" ]] ; then
      return 0
   fi

   return 1
}


