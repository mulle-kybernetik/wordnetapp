# wnlib.subproj
# $Id: GNUmakefile,v 1.1 2003-11-03 15:17:30 znek Exp $


ifeq "$(GNUSTEP_SYSTEM_ROOT)" ""
  include Makefile
else

include $(GNUSTEP_MAKEFILES)/common.make


SUBPROJECT_NAME = wnlib.subproj


wnlib.subproj_C_FILES = \
binsrch.c  search.c   wnglobal.c wnrtl.c \
morph.c    setutil.c  wnhelp.c   wnutil.c


wnlib.subproj_HEADER_FILES = \
license.h  wn.h       wnglobal.h wnrtl.h \
setutil.h  wnconsts.h wnhelp.h   wntypes.h


include ../../GNUstepBuild

-include GNUmakefile.preamble

include $(GNUSTEP_MAKEFILES)/subproject.make

-include GNUmakefile.postamble

endif
