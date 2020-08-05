#!/bin/csh -ef

# packages/fftw.csh.  Generated from fftw.csh.in by configure.

mkdir -p /aux/pc20162a/kliu/Soft//src
cd /aux/pc20162a/kliu/Soft//src

set fftw="fftw-3.2.2"

if ( ! -f ${fftw}.tar.gz ) then
  /usr/bin/wget http://www.fftw.org/${fftw}.tar.gz 
endif

gunzip -c ${fftw}.tar.gz | tar xvf -
cd $fftw

./configure --enable-shared --enable-float --enable-sse --disable-dependency-tracking --prefix=/aux/pc20162a/kliu/Soft/

make clean
make
make install

