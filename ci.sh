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
# https://github.com/gap-packages/example/blob/master/scripts/build_pkg.sh
#
# build this package, if necessary
if [[ -x autogen.sh ]]; then
    ./autogen.sh
    ./configure --with-gaproot=/home/gap/inst/${GAPDIRNAME}
    make -j4 V=1
elif [[ -x configure ]]; then
    ./configure /home/gap/inst/${GAPDIRNAME}
    make -j4
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
if TestOnePackage(LowercaseString(GetNameFromPackageInfo("PackageInfo.g"))) <> true then
    FORCE_QUIT_GAP(1);
fi;
QUIT_GAP(0);
GAPInput
