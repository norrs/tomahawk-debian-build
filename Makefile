SHELL := /bin/bash

BASEDIR=$(CURDIR)

DEBFULLNAME=Roy Sindre Norangshol (Rockj)
DEBEMAIL=roy.sindre@norangshol.no

CORES=8
ICECC_BIN=/usr/lib/icecc/bin
PATH := $(ICECC_BIN):${PATH}

ARCH=amd64

B=$(BASEDIR)/build

LIBQTWEET=libqtweetlib
LIBQTWEET_DIR=$(B)/$(LIBQTWEET)
LIBQTWEET_UPSTREAM_DIR=$(LIBQTWEET_DIR)/$(LIBQTWEET)-upstream

LIBJREEN=libjreen
LIBJREEN_DIR=$(B)/$(LIBJREEN)
LIBJREEN_RELEASE_URL=http://qutim.org/dwnl/44/libjreen-1.1.1.tar.bz2
LIBJREEN_RELEASE=libjreen-1.1.1

LIBECHONEST=libechonest
LIBECHONEST_DIR=$(B)/$(LIBECHONEST)
LIBECHONEST_RELEASE_URL=http://files.lfranchi.com/libechonest-2.0.3.tar.bz2
LIBECHONEST_RELEASE=libechonest_2.0.3
# why not tr -  _  thingie ? :((( Makefile newbie. 
LIBECHONEST_RELEASE_DIR=libechonest-2.0.3 
LIBECHONEST_DEBIAN_URL=http://ftp.de.debian.org/debian/pool/main/libe/libechonest/libechonest_2.0.1-1.debian.tar.gz
LIBECHONEST_DEBIAN=libechonest_2.0.1-1.debian
LIBECHONEST_VERSION=2.0.3

TOMAHAWK=tomahawk-player-nightly
TOMAHAWK_DIR=$(B)/$(TOMAHAWK)
TOMAHAWK_DEBIAN=$(TOMAHAWK)_$(NIGHTLY).orig.tar.gz
TOMAHAWK_UPSTREAM_DIR=$(TOMAHAWK_DIR)/$(TOMAHAWK)-upstream
TOMAHAWK_URL=https://github.com/tomahawk-player/tomahawk.git

SSH_HOST=localhost 
SSH_PORT=22
SSH_USER=foo
SSH_TARGET_DIR=/tmp
 
-include $(BASEDIR)/Makefile.local


ifeq ($(ARCH), i386)
	BPREFIX=linux32
else
	BPREFIX=
endif


NIGHTLY=$(shell date +'%Y.%m.%d.nightly')

help:
	@echo 'Makefile for tomahawk-player automation for Debian	'
	@echo '								'
	@echo 'Usage:							'
	@echo '   make fetch_libqtweet					'

##############
# libqtweetlib

fetch_libqtweet:
	test -d $(LIBQTWEET_DIR) || mkdir -p $(LIBQTWEET_DIR)
	test -d $(LIBQTWEET_UPSTREAM_DIR) || git clone https://github.com/minimoog/QTweetLib.git $(LIBQTWEET_UPSTREAM_DIR)
	cd $(LIBQTWEET_UPSTREAM_DIR) && git pull origin master && git checkout master 

nightly_libqtweet: fetch_libqtweet
	cd $(LIBQTWEET_DIR) && tar -czvf $(LIBQTWEET)-upstream.tar.gz $(shell basename $(LIBQTWEET_UPSTREAM_DIR)) --exclude .git --exclude "*.log"
	cd $(LIBQTWEET_DIR) && tar -zxf $(LIBQTWEET)-upstream.tar.gz --transform="s/$(LIBQTWEET)-upstream/$(LIBQTWEET)_$(NIGHTLY)/"
	cd $(LIBQTWEET_DIR) && tar -cvzf $(LIBQTWEET)_$(NIGHTLY).orig.tar.gz $(LIBQTWEET)_$(NIGHTLY)

build_libqtweet:
	[ -d $(LIBQTWEET_DIR)/$(LIBQTWEET)_$(NIGHTLY)/debian ] && rm -rf $(LIBQTWEET_DIR)/$(LIBQTWEET)_$(NIGHTLY)/debian || exit 0
	cp -r debian_$(LIBQTWEET) $(LIBQTWEET_DIR)/$(LIBQTWEET)_$(NIGHTLY)/debian
	cd $(LIBQTWEET_DIR)/$(LIBQTWEET)_$(NIGHTLY) && DEBFULLNAME="$(DEBFULLNAME)" DEBEMAIL="$(DEBEMAIL)" dch --create -v $(NIGHTLY) "Nightly build $(shell date)" --package libqtweetlib
	cd $(LIBQTWEET_DIR)/$(LIBQTWEET)_$(NIGHTLY) && $(BPREFIX) dpkg-buildpackage -a$(ARCH) -j$(CORES)
	#cd $(LIBQTWEET_DIR)/$(LIBQTWEET)_$(NIGHTLY) && dpkg-buildpackage -j$(CORES)

install_libqtweet:
	for deb_file in $(LIBQTWEET_DIR)/*.deb; do sudo dpkg -i $$deb_file; done

##########
# libjreen

fetch_libjreen:
	test -d $(LIBJREEN_DIR) || mkdir -p $(LIBJREEN_DIR)
	cd $(LIBJREEN_DIR) && test ! -f $(LIBJREEN_RELEASE).tar.bz2 && wget $(LIBJREEN_RELEASE_URL) || echo "Already have release file" && exit 0
	cd $(LIBJREEN_DIR) && tar xf $(LIBJREEN_RELEASE).tar.bz2

build_libjreen:
	cp -r debian_$(LIBJREEN) $(LIBJREEN_DIR)/$(LIBJREEN_RELEASE)/debian
	cd $(LIBJREEN_DIR)/$(LIBJREEN_RELEASE) && dpkg-buildpackage -j$(CORES)

install_libjreen:
	for deb_file in $(LIBJREEN_DIR)/*.deb; do sudo dpkg -i $$deb_file; done


#############
# libechonest

fetch_libechonest:
	test -d $(LIBECHONEST_DIR) || mkdir -p $(LIBECHONEST_DIR)
	cd $(LIBECHONEST_DIR) && test ! -f $(LIBECHONEST_RELEASE).tar.bz2 && wget $(LIBECHONEST_RELEASE_URL) -O $(LIBECHONEST_RELEASE).orig.tar.bz2 || echo "Already have release file" && exit 0
	cd $(LIBECHONEST_DIR) && test ! -f $(LIBECHONEST_DEBIAN).tar.gz && wget $(LIBECHONEST_DEBIAN_URL) || echo "Already have debian/ for $(LIBECHONEST)" && exit 0
	cd $(LIBECHONEST_DIR) && tar xf $(LIBECHONEST_RELEASE).orig.tar.bz2
	cd $(LIBECHONEST_DIR) && tar xf $(LIBECHONEST_DEBIAN).tar.gz && cp -r $(LIBECHONEST_DIR)/debian $(LIBECHONEST_DIR)/$(LIBECHONEST_RELEASE_DIR)

build_libechonest:
	cd $(LIBECHONEST_DIR)/$(LIBECHONEST_RELEASE_DIR) && DEBFULLNAME="$(DEBFULLNAME)" DEBEMAIL="$(DEBEMAIL)" dch "Automated build of $(LIBECHONEST_RELEASE)" -v $(LIBECHONEST_VERSION)-1
	cd $(LIBECHONEST_DIR)/$(LIBECHONEST_RELEASE_DIR) && dpkg-buildpackage -j$(CORES)

install_libechonest:
	for deb_file in $(LIBECHONEST_DIR)/*.deb; do sudo dpkg -i $$deb_file; done

###########
## TOMAHAWK

fetch_tomahawk:
	test -d $(TOMAHAWK_DIR) || mkdir -p $(TOMAHAWK_DIR)
	test -d $(TOMAHAWK_UPSTREAM_DIR) || git clone https://github.com/tomahawk-player/tomahawk.git $(TOMAHAWK_UPSTREAM_DIR)
	cd $(TOMAHAWK_UPSTREAM_DIR) && git pull origin master && git checkout master
	
build_tomahawk:
	cd $(TOMAHAWK_DIR) && tar -czvf $(TOMAHAWK)-upstream.tar.gz $(TOMAHAWK)-upstream --exclude .git --exclude "*.log"
	cd $(TOMAHAWK_DIR) && tar -zxf $(TOMAHAWK)-upstream.tar.gz --transform="s/$(TOMAHAWK)-upstream/$(TOMAHAWK)/"
	cd $(TOMAHAWK_DIR) && tar -cvzf $(TOMAHAWK)_$(NIGHTLY).orig.tar.gz $(TOMAHAWK)
	cp -r debian_$(TOMAHAWK) $(TOMAHAWK_DIR)/$(TOMAHAWK)/debian
	# This one is kinda stupid, should increase if it exist instead . yawn .
	test -f $(TOMAHAWK_DIR)/$(TOMAHAWK)/debian/changelog && rm $(TOMAHAWK_DIR)/$(TOMAHAWK)/debian/changelog || exit 0 
	cd $(TOMAHAWK_DIR)/$(TOMAHAWK) && DEBFULLNAME="$(DEBFULLNAME)" DEBEMAIL="$(DEBEMAIL)" dch --create --package $(TOMAHAWK) -v $(NIGHTLY) "Nightly build of $(TOMAHAWK)"
	cd $(TOMAHAWK_DIR)/$(TOMAHAWK) && dpkg-buildpackage -j$(CORES)

install_tomahawk:
	for deb_file in $(TOMAHAWK_DIR)/*.deb; do sudo dpkg -i $$deb_file; done

rsync_upload:
	rsync -e "ssh -p $(SSH_PORT)" -P -rvz --delete $(B)/*/*.{changes,dsc,deb,orig.tar.gz,debian.tar.gz} $(SSH_USER)@$(SSH_HOST):$(SSH_TARGET_DIR) --cvs-exclude


all: nightly_libqtweet fetch_libjreen fetch_libechonest fetch_tomahawk build_libqtweet build_libjreen build_libechonest install_libqtweet install_libjreen install_libechonest build_tomahawk install_tomahawk
