#!/bin/csh -ef

# packages/tempo2.csh.  Generated from tempo2.csh.in by configure.

if ( ! $?TEMPO2 ) setenv TEMPO2 /aux/pc20162a/kliu/Soft//tempo2

mkdir -p /aux/pc20162a/kliu/Soft//src
cd /aux/pc20162a/kliu/Soft//src

if ( ! -d tempo2 ) then

  echo "Downloading TEMPO2 source code"

  touch $HOME/.cvspass
  setenv TEMPO2_CVS anonymous@tempo2.cvs.sourceforge.net:/cvsroot/tempo2

  echo "When prompted for CVS password: <ENTER>"

  cvs -d :pserver:$TEMPO2_CVS login
  cvs -z3 -d:pserver:$TEMPO2_CVS co -P tempo2

endif

cd tempo2
cvs update

mkdir -p $TEMPO2
rsync -at T2runtime/* $TEMPO2

./bootstrap
./configure
make
make install

echo
echo
echo "TEMPO2 library installation completed"
echo
echo "To use the library, please set the environment variable"
echo
echo 'setenv TEMPO2 /aux/pc20162a/kliu/Soft//tempo2'
echo
echo "and then re-run the PSRCHIVE configure script"
echo
