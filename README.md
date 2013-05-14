tomahawk-debian-build
=====================

tomahawk nightly build LoL for making debian packages

Makefile to make it easier for building Debian packages of tomahawk.

Install dependencies listed at https://github.com/tomahawk-player/tomahawk
This script only takes care of fetching, and building

* libjreen
* libqtweetlib
* libechonest (as the one in experimental isn't new enough)

Rest should be available already in Debian's stable or experimental repositories. 

After these are installed, you can use build_tomahawk and install_tomahawk
goals to install tomahawk from built Debian packages.

## TODO ##

1. publish my nightly builds in an apt-repository near you
2. get it into debian as official package

## Thanks ##

Shamelessy inspired/stolen ubuntu's ppa tomahawk's debian/ stuff. 
https://launchpad.net/~tomahawk/+archive/ppa to build the .deb files.
