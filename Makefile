export ARCHS = armv7 armv7s arm64 arm64e
export TARGET = iphone:clang:11.2:10.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Lifeguard
Lifeguard_FILES = Tweak.xm

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += lifeguardprefs
include $(THEOS_MAKE_PATH)/aggregate.mk
