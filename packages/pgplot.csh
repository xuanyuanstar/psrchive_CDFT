#!/bin/csh -ef

# packages/pgplot.csh.  Generated from pgplot.csh.in by configure.

setenv PGPLOT_DIR /aux/pc20162a/kliu/Soft//pgplot
setenv PGPLOT_SRC /aux/pc20162a/kliu/Soft//src/pgplot

mkdir -p /aux/pc20162a/kliu/Soft//src
cd /aux/pc20162a/kliu/Soft//src

if ( ! -f pgplot5.2.tar.gz ) then
  /usr/bin/wget ftp://ftp.astro.caltech.edu/pub/pgplot/pgplot5.2.tar.gz
endif

gunzip -c pgplot5.2.tar.gz | tar xvf -

cd pgplot/drivers
patch < /aux/pc20162a/kliu/Soft/psrchive_2D/packages/pndriv.patch

# make a gfortran configuration
# Apply patch to generate libcpgplot.so if --enable-shared is in use.
if ( no == yes ) then
  cd ..
  patch < /aux/pc20162a/kliu/Soft/psrchive_2D/packages/makemake.sharedcpg.patch
  cd sys_linux
  cp g77_gcc.conf psrchive.conf
else
  cd ../sys_linux
  cp g77_gcc_aout.conf psrchive.conf
endif
perl -pi -e "s/g77/f77/" psrchive.conf 

# remove the -u option from FFLAGC
perl -pi -e 's/-u //' psrchive.conf 

mkdir -p $PGPLOT_DIR
cd $PGPLOT_DIR

cp $PGPLOT_SRC/drivers.list .

# select PNG
perl -pi -e 's/! PNDRIV/  PNDRIV/' drivers.list

# select Postscript
perl -pi -e 's/! PSDRIV/  PSDRIV/' drivers.list

# select X windows
perl -pi -e 's/! XWDRIV/  XWDRIV/' drivers.list

$PGPLOT_SRC/makemake $PGPLOT_SRC linux psrchive

# remove the broken dependency on png.h, etc.
perl -pi -e 's/^pndriv\.o :/# /' makefile

make
make cpg
make pgxwin_server
make grfont.dat

echo
echo
echo "PGPLOT compilation completed"
echo
echo "To use the library, please set the environment variables"
echo
echo 'setenv PGPLOT_DIR /aux/pc20162a/kliu/Soft//pgplot'
echo 'setenv PGPLOT_FONT $PGPLOT_DIR/grfont.dat'
echo
echo "and then re-run the PSRCHIVE configure script"
echo

