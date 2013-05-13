BASEDIR=$(CURDIR)

DEBFULLNAME=Roy Sindre Norangshol
DEBEMAIL=roy.sindre@norangshol.no


LIBQTWEET=libqtweetlib
LIBQTWEET_DIR=$(BASEDIR)/$(LIBQTWEET)
LIBQTWEET_UPSTREAM_DIR=$(LIBQTWEET_DIR)/$(LIBQTWEET)-upstream

NIGHTLY=$(shell date +'%Y.%m.%d.nightly')

help:
	@echo 'Makefile for tomahawk-player automation for Debian	'
	@echo '								'
	@echo 'Usage:							'
	@echo '   make fetch_libqtweet					'

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
	cp -r debian_$(LIBQTWEET) $(LIBQTWEET_DIR)/$(LIBQTWEET)_$(NIGHTLY)/debian
	cd $(LIBQTWEET_DIR)/$(LIBQTWEET)_$(NIGHTLY) && DEBFULLNAME="$(DEBFULLNAME)" DEBEMAIL="$(DEBEMAIL)" dch --create -v $(NIGHTLY) "Nightly build $(shell date)" --package libqtweetlib
	cd $(LIBQTWEET_DIR)/$(LIBQTWEET)_$(NIGHTLY) && dpkg-buildpackage -j4

install_libqtweet:
	for deb_file in $(LIBQTWEET_DIR)/$(LIBQTWEET); sudo dpkg -i $$deb_file; done



