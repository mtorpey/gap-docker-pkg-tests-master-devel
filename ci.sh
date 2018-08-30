#!/usr/bin/env bash

set -e

SRCDIR=${SRCDIR:-$PWD}
PKG_NAME="$(cut -d'/' -f2 <<< ${REPO_NAME})"

echo SRCDIR    : $SRCDIR
echo REPO_NAME : $REPO_NAME
echo PKG_NAME  : $PKG_NAME

git clone https://github.com/${REPO_NAME}

cd ${PKG_NAME}

###############################################################################
#

# The next block is borrowed from 
# https://github.com/gap-system/gap/blob/master/bin/BuildPackages.sh
#
# build this package, if necessary
#
# We want to know if this is an autoconf configure script
# or not, without actually executing it!
if [[ -f autogen.sh && ! -f configure ]]
then
  ./autogen.sh
fi
if [[ -f "configure" ]]
then
  if grep Autoconf ./configure > /dev/null
  then
    ./configure --with-gaproot=/home/gap/inst/${GAPDIRNAME}
  else
    ./configure /home/gap/inst/${GAPDIRNAME}
  fi
  make
else
  notice "No building required for $PKG"
fi

# set up a custom GAP root containing only this package, so that
# we can force GAP to load the correct version of this package
mkdir -p gaproot/pkg/
ln -s $PWD gaproot/pkg/

###############################################################################

# start GAP with custom GAP root, to ensure correct package version is loaded
GAP="/home/gap/inst/${GAPDIRNAME}/bin/gap.sh -l $PWD/gaproot; --quitonbreak -q"

# Run package test
$GAP <<GAPInput
Read("/home/gap/travis/ci.g");
if TestOnePackage(LowercaseString("$PKG_NAME")) <> true then
    FORCE_QUIT_GAP(1);
fi;
QUIT_GAP(0);
GAPInput
