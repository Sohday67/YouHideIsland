TARGET := iphone:clang:latest:14.0
INSTALL_TARGET_PROCESSES = YouTube

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = YouHideIsland
YouHideIsland_FILES = Tweak.xm
YouHideIsland_CFLAGS = -fobjc-arc
YouHideIsland_FRAMEWORKS = UIKit MediaPlayer

include $(THEOS_MAKE_PATH)/tweak.mk
