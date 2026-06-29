# SPDX-License-Identifier: LGPL-3.0-or-later
include $(TOPDIR)/rules.mk

PKG_NAME:=stfl
PKG_VERSION:=0.24
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/newsboat/stfl.git
PKG_SOURCE_DATE:=2024-12-24
PKG_SOURCE_VERSION:=bbb2404580e845df2556560112c8aefa27494d66
PKG_MIRROR_HASH:=c261c6be5775b760538cb3f4038ece132b3abff1ea1fd177e66395aca932bdb6

PKG_MAINTAINER:=Stan Grishin <stangri@melmac.ca>
PKG_LICENSE:=LGPL-3.0-or-later
PKG_LICENSE_FILES:=COPYING

PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/libstfl
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Structured Terminal Forms Language/Library
  URL:=https://github.com/newsboat/stfl
  DEPENDS:=+libncursesw
endef

define Package/libstfl/description
  STFL is a library which implements a curses-based widget set for text
  terminals. This is the Newsboat-maintained fork of the original STFL.
endef

# The STFL Makefile hardcodes "export CC = gcc -pthread" and appends to CFLAGS
# with "+=". A command-line assignment overrides the makefile's "=" for CC and
# disables its "+=" for CFLAGS, so we re-supply the flags STFL needs (-fPIC,
# -D_GNU_SOURCE, -I.) ourselves. LDLIBS is left to the makefile (-lncursesw).
MAKE_FLAGS += \
	CC="$(TARGET_CC) -pthread" \
	CFLAGS="$(TARGET_CFLAGS) -I. -Wall -Os -D_GNU_SOURCE -D_XOPEN_SOURCE_EXTENDED -fPIC" \
	prefix=/usr \
	libdir=lib

define Build/Compile
	$(call Build/Compile/Default,libstfl.a libstfl.so.$(PKG_VERSION) stfl.pc)
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_BUILD_DIR)/stfl.h $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/libstfl.a $(1)/usr/lib/
	$(CP) $(PKG_BUILD_DIR)/libstfl.so.$(PKG_VERSION) $(1)/usr/lib/
	$(LN) libstfl.so.$(PKG_VERSION) $(1)/usr/lib/libstfl.so
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/stfl.pc $(1)/usr/lib/pkgconfig/
endef

define Package/libstfl/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/libstfl.so.$(PKG_VERSION) $(1)/usr/lib/
	$(LN) libstfl.so.$(PKG_VERSION) $(1)/usr/lib/libstfl.so.0
endef

$(eval $(call BuildPackage,libstfl))
