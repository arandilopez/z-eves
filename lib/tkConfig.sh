# tkConfig.sh --
# 
# This shell script (for sh) is generated automatically by Tk's
# configure script.  It will create shell variables for most of
# the configuration options discovered by the configure script.
# This script is intended to be included by the configure scripts
# for Tk extensions so that they don't have to figure this all
# out for themselves.  This file does not duplicate information
# already provided by tclConfig.sh, so you may need to use that
# file in addition to this one.
#
# The information in this file is specific to a single platform.
#
# RCS: @(#) $Id: tkConfig.sh.in,v 1.6 1998/09/14 18:23:55 stanton Exp $

# Tk's version number.
TK_VERSION='8.0'
TK_MAJOR_VERSION='8'
TK_MINOR_VERSION='0'
TK_PATCH_LEVEL='.5'

# -D flags for use with the C compiler.
TK_DEFS=' -DHAVE_UNISTD_H=1 -DHAVE_LIMITS_H=1 -DSTDC_HEADERS=1 -DHAVE_SYS_TIME_H=1 -DTIME_WITH_SYS_TIME=1 '

# Flag, 1: we built a shared lib, 0 we didn't
TK_SHARED_BUILD=0

# This indicates if Tk was build with debugging symbols
TK_DBGX=

# The name of the Tk library (may be either a .a file or a shared library):
TK_LIB_FILE='libtk8.0${TK_DBGX}.a'

# Additional libraries to use when linking Tk.
TK_LIBS='-lX11 -ldl  -lm'

# Top-level directory in which Tcl's platform-independent files are
# installed.
TK_PREFIX='/opt/Z'

# Top-level directory in which Tcl's platform-specific files (e.g.
# executables) are installed.
TK_EXEC_PREFIX='/opt/Z'

# -I switch(es) to use to make all of the X11 include files accessible:
TK_XINCLUDES='# no special path needed'

# Linker switch(es) to use to link with the X11 library archive.
TK_XLIBSW='-lX11'

# -l flag to pass to the linker to pick up the Tcl library
TK_LIB_FLAG='-ltk8.0${TK_DBGX}'

# String to pass to linker to pick up the Tk library from its
# build directory.
TK_BUILD_LIB_SPEC='-L/opt/Z/tk8.0.5/unix -ltk8.0${TK_DBGX}'

# String to pass to linker to pick up the Tk library from its
# installed directory.
TK_LIB_SPEC='-L/opt/Z/lib -ltk8.0${TK_DBGX}'

# Location of the top-level source directory from which Tk was built.
# This is the directory that contains a README file as well as
# subdirectories such as generic, unix, etc.  If Tk was compiled in a
# different place than the directory containing the source files, this
# points to the location of the sources, not the location where Tk was
# compiled.
TK_SRC_DIR='/opt/Z/tk8.0.5'

# Needed if you want to make a 'fat' shared library library
# containing tk objects or link a different wish.
TK_CC_SEARCH_FLAGS=''
TK_LD_SEARCH_FLAGS=''

