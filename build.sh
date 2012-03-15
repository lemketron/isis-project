#!/bin/bash

if [ -z "$QTDIR" ] ; then
   echo Error: QTDIR must be set to location of Qt source which was used to build the installed version of Qt.
   exit 1
fi

SRC="
npapi-headers
pbnjson
AdapterBase
WebKit
BrowserAdapter
BrowserServer
WebKitSupplemental
"

DEVELOPER=false
PROCCOUNT=1

build_usage()
{
   echo options:
   echo "	-d : enables developer mode. Code is checked out from github with read and write permissions"
   echo "	-j [Integer] : Enables multiprocess builds. Similar to make -j command"
}

while getopts dj: ARG
do
   case "$ARG" in
   d) DEVELOPER=true;;
   j) PROCCOUNT=$OPTARG;;
   [?]) build_usage
        exit -1;;
   esac
done

for CURRENT in $SRC ; do
   if [ ! -d ../$CURRENT ] ; then
      if [ $DEVELOPER = "true" ] ; then
         git checkout git@github.com:isis-project/$CURRENT.git ../$CURRENT
      else
         git https://github.com/isis-project/$CURRENT.git ../$CURRENT
      fi
   else
      echo found ../$CURRENT
   fi
done

cd ./scripts
for CURRENT in $SRC ; do
   if [ -x ./build_$CURRENT.sh ] ; then
      ./build_$CURRENT.sh $CURRENT $PROCCOUNT
      if [ "$?" != "0" ] ; then
         echo Failed to build: $CURRENT
         exit -1
      fi
   else
      echo No build script for $CURRENT
   fi
done
cd ..
