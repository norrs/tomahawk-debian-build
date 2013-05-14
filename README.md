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

## INSTALL ##

These instructions should get you going quickly. 

Fetch \*.deb's from http://absint.online.ntnu.no/~norangsh/tomahawk/ for now.
(these are my builds, updated whenever I feel for it ;-))

Set default release in */etc/apt/apt.conf.d/99user* to: `APT::Default-Release "wheezy";` 
Replace wheezy with your release-name if using testing (jenny) as aof May 14 2013 for example.

Add experimental and jessie/sid to your APT sources. (required for libattica0.4 liblastfm1 libquazip0)

`
 deb http://ftp.no.debian.org/debian jenny main contrib non-free
 deb-src http://ftp.no.debian.org/debian jenny main contrib non-free
 deb http://ftp.no.debian.org/debian experimental main contrib non-free
 deb-src http://ftp.no.debian.org/debian experimental main contrib non-free
`

* apt-get update
* apt-get install -t experimental libattica0.4 liblastfm1
* apt-get install -t jessie libquazip0


* dpkg -i tomahawk-player\*.deb
* apt-get install -f  (if needed.)


## TODO ##

1. publish my nightly builds in an apt-repository near you
2. get it into debian as official package

## Thanks ##

Shamelessy inspired/stolen ubuntu's ppa tomahawk's debian/ stuff. 
https://launchpad.net/~tomahawk/+archive/ppa to build the .deb files.
