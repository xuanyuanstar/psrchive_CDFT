#!/bin/csh -ef

# packages/cfitsio.csh.  Generated from cfitsio.csh.in by configure.

mkdir -p /aux/pc20162a/kliu/Soft//src
cd /aux/pc20162a/kliu/Soft//src

set cfitsio=cfitsio3350

if ( ! -f ${cfitsio}.tar.gz ) then
  /usr/bin/wget ftp://heasarc.gsfc.nasa.gov/software/fitsio/c/${cfitsio}.tar.gz
endif

gunzip -c ${cfitsio}.tar.gz | tar xvf -
cd cfitsio

./configure --prefix=/aux/pc20162a/kliu/Soft/

make clean
make
make shared
make install

