#!/bin/csh -ef

# packages/tempo.csh.  Generated from tempo.csh.in by configure.

mkdir -p /aux/pc20162a/kliu/Soft//src
cd /aux/pc20162a/kliu/Soft//src

mkdir -p tempo
cd tempo

if ( ! -f tempo11.010.tar.gz ) then
  echo "Downloading TEMPO source code"
  /usr/bin/wget ftp://ftp.atnf.csiro.au/pub/people/man082/tempo11.010.tar.gz
endif

if ( ! -f DE200.1950.2050.gz ) then
  echo "Downloading DE200"
  /usr/bin/wget ftp://ftp.atnf.csiro.au/pub/people/rmanches/DE200.1950.2050.gz
endif

if ( ! -f DE405.1950.2050.gz ) then
  echo "Downloading DE405"
  /usr/bin/wget ftp://ftp.atnf.csiro.au/pub/people/rmanches/DE405.1950.2050.gz
endif

if ( ! -f TDB.1950.2050.gz ) then
  echo "Downloading TDB"
  /usr/bin/wget ftp://ftp.atnf.csiro.au/pub/people/rmanches/TDB.1950.2050.gz
endif

gunzip -c tempo11.010.tar.gz | tar xvf -

cd src
make
mkdir -p /aux/pc20162a/kliu/Soft//bin
mv tempo /aux/pc20162a/kliu/Soft//bin
cd ..

mkdir -p /aux/pc20162a/kliu/Soft//tempo

cp -R clock obsys.dat tempo.cfg tempo.hlp tzpar /aux/pc20162a/kliu/Soft//tempo

mkdir -p /aux/pc20162a/kliu/Soft//tempo/tempo_ephem

cp DE200.1950.2050.gz /aux/pc20162a/kliu/Soft//tempo/tempo_ephem
cp DE405.1950.2050.gz /aux/pc20162a/kliu/Soft//tempo/tempo_ephem
cp TDB.1950.2050.gz   /aux/pc20162a/kliu/Soft//tempo/tempo_ephem

cd /aux/pc20162a/kliu/Soft//tempo

perl -pi -e "s|/pulsar/psr/runtime|/aux/pc20162a/kliu/Soft/|" tempo.cfg

cd tempo_ephem

gunzip DE200.1950.2050.gz
gunzip DE405.1950.2050.gz
gunzip TDB.1950.2050.gz

