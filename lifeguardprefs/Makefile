include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = LifeguardPrefs
LifeguardPrefs_FILES = LGUARDRootListController.m
LifeguardPrefs_INSTALL_PATH = /Library/PreferenceBundles
LifeguardPrefs_FRAMEWORKS = UIKit
LifeguardPrefs_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/LifeguardPrefs.plist$(ECHO_END)
