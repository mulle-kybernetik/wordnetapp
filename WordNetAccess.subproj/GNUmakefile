# WordNetAccess.subproj
# $Id: GNUmakefile,v 1.1 2003-11-03 15:17:30 znek Exp $


ifeq "$(GNUSTEP_SYSTEM_ROOT)" ""
  include Makefile
else

include $(GNUSTEP_MAKEFILES)/common.make


SUBPROJECT_NAME = WordNetAccess.subproj


ADDITIONAL_INCLUDE_DIRS = -I.. -Iwnlib.subproj


WordNetAccess.subproj_OBJC_FILES = \
WNController.m  WNResult.m


WordNetAccess.subproj_HEADER_FILES = \
WNController.h  WNResult.h      WordNetAccess.h


WordNetAccess.subproj_HAS_RESOURCE_BUNDLE = yes

WordNetAccess.subproj_RESOURCE_FILES = \
SearchTypes.strings


WordNetAccess.subproj_SUBPROJECTS = wnlib.subproj


include ../GNUstepBuild

-include GNUmakefile.preamble

include $(GNUSTEP_MAKEFILES)/subproject.make

-include GNUmakefile.postamble

endif
