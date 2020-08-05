#!/bin/csh -ef

# packages/psrcat.csh.  Generated from psrcat.csh.in by configure.

mkdir -p /aux/pc20162a/kliu/Soft//src
cd /aux/pc20162a/kliu/Soft//src

if ( ! -f psrcat.tar.gz ) then
  /usr/bin/wget http://www.atnf.csiro.au/people/pulsar/psrcat/psrcat_pkg.tar.gz
endif

gunzip -c psrcat_pkg.tar.gz | tar xvf -
cd psrcat_tar

csh makeit

mkdir -p /aux/pc20162a/kliu/Soft//bin
mv psrcat /aux/pc20162a/kliu/Soft//bin

mkdir -p /aux/pc20162a/kliu/Soft//psrcat

mv psrcat.db /aux/pc20162a/kliu/Soft//psrcat

echo
echo
echo "PSRCAT installation completed"
echo
echo "To use psrcat, please set the environment variable"
echo
echo 'setenv PSRCAT_FILE /aux/pc20162a/kliu/Soft//psrcat/psrcat.db'
echo
echo
