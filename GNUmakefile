# WordNet.app
# $Id: GNUmakefile,v 1.1 2003-11-03 15:17:29 znek Exp $


ifeq "$(GNUSTEP_SYSTEM_ROOT)" ""
  include Makefile
else

include $(GNUSTEP_MAKEFILES)/common.make


GNUSTEP_INSTALLATION_DIR=$(GNUSTEP_LOCAL_ROOT)


APP_NAME = WordNet


ifneq ($(findstring darwin, $(GNUSTEP_HOST_OS)),)
  GORM_EXT = nib
  GMODEL_EXT = nib
  ICON_EXT = icns
else
  GORM_EXT = gorm
  GMODEL_EXT = gmodel
  ICON_EXT = tiff
endif


WordNet_OBJC_FILES = \
Constants.m                             WNSearchWindowController.m \
EDApplication.m                         WNTextView.m \
WNAppController.m                       WordNet_main.m \
WNPrefPanelController.m


WordNet_PRINCIPAL_CLASS = EDApplication
WordNet_APPLICATION_ICON = WordNet.$(ICON_EXT)
WordNet_MAIN_MODEL_FILE = WordNet.$(GMODEL_EXT)
WordNet_LANGUAGES = English


WordNet_RESOURCE_FILES = \
FactoryDefaults.plist \
WordNet.$(ICON_EXT)


WordNet_LOCALIZED_RESOURCE_FILES = \
Credits.rtf \
WordNet.$(GORM_EXT) \
SearchWindow.$(GORM_EXT) \
Preferences.$(GORM_EXT) \
License.$(GMODEL_EXT)


WordNet_SUBPROJECTS = WordNetAccess.subproj


ADDITIONAL_INCLUDE_DIRS = -IWordNetAccess.subproj -IWordNetAccess.subproj/wnlib.subproj


include GNUstepBuild


include Version
MAJOR_VERSION = $(CURRENT_PROJECT_VERSION)


-include GNUmakefile.preamble

#include $(GNUSTEP_MAKEFILES)/aggregate.make
include $(GNUSTEP_MAKEFILES)/application.make

-include GNUmakefile.postamble

endif
