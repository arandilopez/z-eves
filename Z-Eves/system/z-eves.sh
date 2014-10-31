#!/bin/sh
#
# Command file for running Z/EVES
#
# Copy this file to one named "z-eves". In z-eves, set zevesdir to your Z/EVES
# root directory, move the z-eves file to a directory on your search path, and
# make it executable.

zevesdir=/opt/Z/Z-Eves/

lispdir=$zevesdir/system
zsysdir=$zevesdir/system
zlibdir=$zevesdir/library/
zeves=$zsysdir/z-eves-pc-linux-cmucl.core

exec $lispdir/lisp -core $zeves -- -libs $zlibdir "$@"
