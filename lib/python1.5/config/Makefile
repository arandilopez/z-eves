# Generated automatically from Makefile.pre by makesetup.
# Generated automatically from Makefile.pre.in by configure.
# META-NOTE: this note is different from the note in the other Makefiles!
# NOTE: Makefile.pre.in is converted into Makefile.pre by the configure
# script in the toplevel directory or by ../config.status.
# Makefile.pre is converted into Makefile by running the makesetup
# script in the source directory.  Once Makefile exists, it can be
# brought up to date by running "make Makefile".  (The makesetup also
# creates config.c from config.c.in in the source directory.)

# === Variables set by makesetup ===

MODOBJS=	  threadmodule.o  regexmodule.o regexpr.o  pcremodule.o pypcre.o  posixmodule.o  signalmodule.o  arraymodule.o  cmathmodule.o  mathmodule.o  stropmodule.o  structmodule.o  timemodule.o  operator.o  fcntlmodule.o  pwdmodule.o  grpmodule.o  selectmodule.o  socketmodule.o  errnomodule.o  md5module.o md5c.o  shamodule.o  _tkinter.o tkappinit.o  rotormodule.o  newmodule.o  binascii.o  parsermodule.o  cStringIO.o  cPickle.o
MODLIBS=	$(LOCALMODLIBS) $(BASEMODLIBS)

# === Variables set by configure ===

VERSION=	1.5
srcdir=		.

CCC= g++
CC=		gcc
RANLIB=		ranlib
AR=		ar

OPT=		-g -O2
LDFLAGS=	
LDLAST=		
SGI_ABI=	

DEFS=		-DHAVE_CONFIG_H
LIBS=		-lieee -ldl  -lpthread
LIBM=		-lm
LIBC=		

# Machine-dependent subdirectories
MACHDEP=	linux2

# Install prefix for architecture-independent files
prefix=		/opt/Z

# Install prefix for architecture-dependent files
exec_prefix=	/opt/Z

# Expanded directories
BINDIR=		$(exec_prefix)/bin
LIBDIR=		$(exec_prefix)/lib
MANDIR=		$(prefix)/man
INCLUDEDIR=	$(prefix)/include
SCRIPTDIR=	$(prefix)/lib

# Detailed destination directories
BINLIBDEST=	$(LIBDIR)/python$(VERSION)
LIBDEST=	$(SCRIPTDIR)/python$(VERSION)
INCLUDEPY=	$(INCLUDEDIR)/python$(VERSION)
LIBP=		$(LIBDIR)/python$(VERSION)

# Symbols used for using shared libraries
SO=		.so
LDSHARED=	gcc -shared
CCSHARED=	-fpic
LINKFORSHARED=	-Xlinker -export-dynamic
DESTSHARED=	$(BINLIBDEST)/lib-dynload

# Portable install script (configure doesn't always guess right)
INSTALL=	./../install-sh -c
INSTALL_PROGRAM=${INSTALL} -m 755
INSTALL_DATA=	${INSTALL} -m 644
# Shared libraries must be installed with executable mode on some systems;
# rather than figuring out exactly which, we always give them executable mode.
# Also, making them read-only seems to be a good idea...
INSTALL_SHARED=	${INSTALL} -m 555

# === Variables that are customizable by hand or by inclusion in Setup ===

LINKCC=		$(PURIFY) $(CC)
INCLDIR=	$(srcdir)/../Include
CONFIGINCLDIR=	..
CFLAGS=		$(OPT) -I$(INCLDIR) -I$(CONFIGINCLDIR) $(DEFS)

MKDEP=		mkdep
SHELL=		/bin/sh

MAKESETUP=	$(srcdir)/makesetup

# (The makesetup script inserts all variable definitions
# found in the Setup file just below the following line.
# This means that the Setup file can override any of the definitions
# given before this point, but not any given below.
# The script insert the definitions in reverse order,
# for the benefits of independent extensions.)
# === Definitions added by makesetup ===

LOCALMODLIBS=                      -L/opt/Z/lib -ltk8.0 -ltcl8.0 -L/usr/X11R6/lib -lX11      
BASEMODLIBS=
TKPATH=:lib-tk
GLHACK=-Dclear=__GLclear
PYTHONPATH=$(COREPYTHONPATH)
COREPYTHONPATH=$(DESTPATH)$(SITEPATH)$(TESTPATH)$(MACHDEPPATH)$(STDWINPATH)$(TKPATH)
MACHDEPPATH=:plat-$(MACHDEP)
TESTPATH=
SITEPATH=
DESTPATH=
MACHDESTLIB=$(BINLIBDEST)
DESTLIB=$(LIBDEST)


# === Fixed definitions ===

FIXOBJS=	config.o getpath.o main.o getbuildinfo.o
OBJS=		$(MODOBJS) $(FIXOBJS)

MAINOBJ=	python.o

SYSLIBS=	$(LIBM) $(LIBC)

LIBRARY=	../libpython$(VERSION).a
LDLIBRARY=	../libpython$(VERSION).a

# === Rules ===

all:		$(OBJS)

# This target is used by the master Makefile to add the objects to the library.
# To deal with the conflict between signalmodule.o and
# sigcheck.o+intrcheck.o, we remove the latter two if we have the former.
add2lib:	$(OBJS)
		-if test -f hassignal; \
		then echo removing sigcheck.o intrcheck.o; \
		     $(AR) d $(LIBRARY) sigcheck.o intrcheck.o 2>/dev/null; \
		else echo leaving sigcheck.o intrcheck.o in; fi
		$(AR) cr $(LIBRARY) $(OBJS)
		touch add2lib

# Use ``EXE=.exe'' for Unix emulations on DOS/Windows
EXE=

# This target is used by the master Makefile to link the final binary.
link:		$(MAINOBJ)
		$(LINKCC) $(LDFLAGS) $(LINKFORSHARED) $(MAINOBJ) \
		  $(LDLIBRARY) $(MODLIBS) $(LIBS) $(SYSLIBS) -o python $(LDLAST)
		mv python$(EXE) ../python$(EXE)

clean:
		-rm -f *.o python$(EXE) core *~ [@,#]* *.old *.orig *.rej
		-rm -f add2lib hassignal

clobber:	clean
		-rm -f *.a tags TAGS config.c Makefile.pre
		-rm -f *.so *.sl so_locations

getpath.o:	getpath.c Makefile
		$(CC) -c $(CFLAGS) -DPYTHONPATH='"$(PYTHONPATH)"' \
		      -DPREFIX='"$(prefix)"' \
		      -DEXEC_PREFIX='"$(exec_prefix)"' \
		      -DVERSION='"$(VERSION)"' \
		      -DVPATH='"$(VPATH)"' \
		      $(srcdir)/getpath.c

# When the configuration changes, we remove the library, so that it
# gets remade from scratch; this ensures to remove modules that are no
# longer pertinent (but that were in a previous configuration).
config.c Makefile: Makefile.pre config.c.in $(MAKESETUP)
config.c Makefile: Setup.thread Setup Setup.local
config.c Makefile:
		-rm -f $(LIBRARY)
		$(SHELL) $(MAKESETUP) Setup.thread Setup.local Setup

hassignal:
		-rm -f hassignal
		-for i in $(OBJS); do \
		    if test "$$i" = "signalmodule.o"; then \
		       echo yes >hassignal; break; \
		    fi; \
		done

Setup:
		cp $(srcdir)/Setup.in Setup

Setup.local:
		echo "# Edit this file for local setup changes" >Setup.local

Makefile.pre:	Makefile.pre.in ../config.status
		(cd ..; CONFIG_FILES=Modules/Makefile.pre CONFIG_HEADERS= \
		$(SHELL) config.status)

depend:
		$(MKDEP) $(CFLAGS) `echo $(OBJS) | tr ' ' '\012' | \
					sed 's|\(.*\)\.o|$(srcdir)/\1.c|'`

.PRECIOUS:	../python$(EXE)

glmodule.c:	$(srcdir)/cgen.py $(srcdir)/cstubs
		python $(srcdir)/cgen.py <$(srcdir)/cstubs >glmodule.c

almodule.o: almodule.c
arraymodule.o: arraymodule.c
audioop.o: audioop.c
cdmodule.o: cdmodule.c
cgensupport.o: cgensupport.c
clmodule.o: clmodule.c
dbmmodule.o: dbmmodule.c
errnomodule.o: errnomodule.c
fcntlmodule.o: fcntlmodule.c
flmodule.o: flmodule.c
fmmodule.o: fmmodule.c
glmodule.o: glmodule.c
imageop.o: imageop.c
imgfile.o: imgfile.c
main.o: main.c
mathmodule.o: mathmodule.c
md5c.o: md5c.c
md5module.o: md5module.c
mpzmodule.o: mpzmodule.c
nismodule.o: nismodule.c
operator.o: operator.c
parsermodule.o: parsermodule.c
posixmodule.o: posixmodule.c
pwdmodule.o: pwdmodule.c
regexmodule.o: regexmodule.c
regexpr.o: regexpr.c
resource.o: resource.c
rgbimgmodule.o: rgbimgmodule.c
rotormodule.o: rotormodule.c
selectmodule.o: selectmodule.c
sgimodule.o: sgimodule.c
socketmodule.o: socketmodule.c
stdwinmodule.o: stdwinmodule.c
stropmodule.o: stropmodule.c
structmodule.o: structmodule.c
sunaudiodev.o: sunaudiodev.c
svmodule.o: svmodule.c
threadmodule.o: threadmodule.c
timemodule.o: timemodule.c
timingmodule.o: timingmodule.c
xxmodule.o: xxmodule.c
yuvconvert.o: yuvconvert.c

# Rules to build and install all shared modules
sharedmods:	$(SHAREDMODS)
sharedinstall:	$(DESTSHARED) $(SHAREDMODS)
		-for i in X $(SHAREDMODS); do \
			if test $$i != X; \
			then $(INSTALL_SHARED) $$i $(DESTSHARED)/$$i; \
			fi; \
		done

DESTDIRS=	$(exec_prefix) $(LIBDIR) $(BINLIBDEST) $(DESTSHARED)

$(DESTSHARED): 
		@for i in $(DESTDIRS); \
		do \
			if test ! -d $$i; then \
				echo "Creating directory $$i"; \
				mkdir $$i; \
				chmod 755 $$i; \
			else	true; \
			fi; \
		done

# Stuff is appended here by makesetup and make depend

# Rules appended by makedepend

threadmodule.o: $(srcdir)/threadmodule.c; $(CC)  $(CFLAGS) -c $(srcdir)/threadmodule.c
threadmodule$(SO):  threadmodule.o; $(LDSHARED)  threadmodule.o  -o threadmodule$(SO)
regexmodule.o: $(srcdir)/regexmodule.c; $(CC)  $(CFLAGS) -c $(srcdir)/regexmodule.c
regexpr.o: $(srcdir)/regexpr.c; $(CC)  $(CFLAGS) -c $(srcdir)/regexpr.c
regexmodule$(SO):  regexmodule.o regexpr.o; $(LDSHARED)  regexmodule.o regexpr.o  -o regexmodule$(SO)
pcremodule.o: $(srcdir)/pcremodule.c; $(CC)  $(CFLAGS) -c $(srcdir)/pcremodule.c
pypcre.o: $(srcdir)/pypcre.c; $(CC)  $(CFLAGS) -c $(srcdir)/pypcre.c
pcre$(SO):  pcremodule.o pypcre.o; $(LDSHARED)  pcremodule.o pypcre.o  -o pcre$(SO)
posixmodule.o: $(srcdir)/posixmodule.c; $(CC)  $(CFLAGS) -c $(srcdir)/posixmodule.c
posixmodule$(SO):  posixmodule.o; $(LDSHARED)  posixmodule.o  -o posixmodule$(SO)
signalmodule.o: $(srcdir)/signalmodule.c; $(CC)  $(CFLAGS) -c $(srcdir)/signalmodule.c
signalmodule$(SO):  signalmodule.o; $(LDSHARED)  signalmodule.o  -o signalmodule$(SO)
arraymodule.o: $(srcdir)/arraymodule.c; $(CC)  $(CFLAGS) -c $(srcdir)/arraymodule.c
arraymodule$(SO):  arraymodule.o; $(LDSHARED)  arraymodule.o  -o arraymodule$(SO)
cmathmodule.o: $(srcdir)/cmathmodule.c; $(CC)  $(CFLAGS) -c $(srcdir)/cmathmodule.c
cmathmodule$(SO):  cmathmodule.o; $(LDSHARED)  cmathmodule.o  -o cmathmodule$(SO)
mathmodule.o: $(srcdir)/mathmodule.c; $(CC)  $(CFLAGS) -c $(srcdir)/mathmodule.c
mathmodule$(SO):  mathmodule.o; $(LDSHARED)  mathmodule.o  -o mathmodule$(SO)
stropmodule.o: $(srcdir)/stropmodule.c; $(CC)  $(CFLAGS) -c $(srcdir)/stropmodule.c
stropmodule$(SO):  stropmodule.o; $(LDSHARED)  stropmodule.o  -o stropmodule$(SO)
structmodule.o: $(srcdir)/structmodule.c; $(CC)  $(CFLAGS) -c $(srcdir)/structmodule.c
structmodule$(SO):  structmodule.o; $(LDSHARED)  structmodule.o  -o structmodule$(SO)
timemodule.o: $(srcdir)/timemodule.c; $(CC)  $(CFLAGS) -c $(srcdir)/timemodule.c
timemodule$(SO):  timemodule.o; $(LDSHARED)  timemodule.o  -o timemodule$(SO)
operator.o: $(srcdir)/operator.c; $(CC)  $(CFLAGS) -c $(srcdir)/operator.c
operator$(SO):  operator.o; $(LDSHARED)  operator.o  -o operator$(SO)
fcntlmodule.o: $(srcdir)/fcntlmodule.c; $(CC)  $(CFLAGS) -c $(srcdir)/fcntlmodule.c
fcntlmodule$(SO):  fcntlmodule.o; $(LDSHARED)  fcntlmodule.o  -o fcntlmodule$(SO)
pwdmodule.o: $(srcdir)/pwdmodule.c; $(CC)  $(CFLAGS) -c $(srcdir)/pwdmodule.c
pwdmodule$(SO):  pwdmodule.o; $(LDSHARED)  pwdmodule.o  -o pwdmodule$(SO)
grpmodule.o: $(srcdir)/grpmodule.c; $(CC)  $(CFLAGS) -c $(srcdir)/grpmodule.c
grpmodule$(SO):  grpmodule.o; $(LDSHARED)  grpmodule.o  -o grpmodule$(SO)
selectmodule.o: $(srcdir)/selectmodule.c; $(CC)  $(CFLAGS) -c $(srcdir)/selectmodule.c
selectmodule$(SO):  selectmodule.o; $(LDSHARED)  selectmodule.o  -o selectmodule$(SO)
socketmodule.o: $(srcdir)/socketmodule.c; $(CC)  $(CFLAGS) -c $(srcdir)/socketmodule.c
socketmodule$(SO):  socketmodule.o; $(LDSHARED)  socketmodule.o  -o socketmodule$(SO)
errnomodule.o: $(srcdir)/errnomodule.c; $(CC)  $(CFLAGS) -c $(srcdir)/errnomodule.c
errnomodule$(SO):  errnomodule.o; $(LDSHARED)  errnomodule.o  -o errnomodule$(SO)
md5module.o: $(srcdir)/md5module.c; $(CC)  $(CFLAGS) -c $(srcdir)/md5module.c
md5c.o: $(srcdir)/md5c.c; $(CC)  $(CFLAGS) -c $(srcdir)/md5c.c
md5module$(SO):  md5module.o md5c.o; $(LDSHARED)  md5module.o md5c.o  -o md5module$(SO)
shamodule.o: $(srcdir)/shamodule.c; $(CC)  $(CFLAGS) -c $(srcdir)/shamodule.c
shamodule$(SO):  shamodule.o; $(LDSHARED)  shamodule.o  -o shamodule$(SO)
_tkinter.o: $(srcdir)/_tkinter.c; $(CC)  -DWITH_APPINIT -I/opt/Z/include -I/usr/X11/include $(CFLAGS) -c $(srcdir)/_tkinter.c
tkappinit.o: $(srcdir)/tkappinit.c; $(CC)  -DWITH_APPINIT -I/opt/Z/include -I/usr/X11/include $(CFLAGS) -c $(srcdir)/tkappinit.c
_tkinter$(SO):  _tkinter.o tkappinit.o; $(LDSHARED)  _tkinter.o tkappinit.o  -L/opt/Z/lib -ltk8.0 -ltcl8.0 -L/usr/X11R6/lib -lX11 -o _tkinter$(SO)
rotormodule.o: $(srcdir)/rotormodule.c; $(CC)  $(CFLAGS) -c $(srcdir)/rotormodule.c
rotormodule$(SO):  rotormodule.o; $(LDSHARED)  rotormodule.o  -o rotormodule$(SO)
newmodule.o: $(srcdir)/newmodule.c; $(CC)  $(CFLAGS) -c $(srcdir)/newmodule.c
newmodule$(SO):  newmodule.o; $(LDSHARED)  newmodule.o  -o newmodule$(SO)
binascii.o: $(srcdir)/binascii.c; $(CC)  $(CFLAGS) -c $(srcdir)/binascii.c
binascii$(SO):  binascii.o; $(LDSHARED)  binascii.o  -o binascii$(SO)
parsermodule.o: $(srcdir)/parsermodule.c; $(CC)  $(CFLAGS) -c $(srcdir)/parsermodule.c
parsermodule$(SO):  parsermodule.o; $(LDSHARED)  parsermodule.o  -o parsermodule$(SO)
cStringIO.o: $(srcdir)/cStringIO.c; $(CC)  $(CFLAGS) -c $(srcdir)/cStringIO.c
cStringIO$(SO):  cStringIO.o; $(LDSHARED)  cStringIO.o  -o cStringIO$(SO)
cPickle.o: $(srcdir)/cPickle.c; $(CC)  $(CFLAGS) -c $(srcdir)/cPickle.c
cPickle$(SO):  cPickle.o; $(LDSHARED)  cPickle.o  -o cPickle$(SO)
