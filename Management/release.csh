#! /bin/csh -f

# Management/release.csh.  Generated from release.csh.in by configure.

set tarfile = psrchive-2012-12+.tar.gz

if ( ! -f $tarfile ) then
  echo "$tarfile not found"
  echo "Please run 'make dist' first"
  exit
endif

# determine the SourceForge user name from the Git configuration

set server = `git config --get remote.origin.url`

if ( $server =~ git://* ) then
  echo 'ERROR: this command can be run only by a developer'
  exit -1
endif

set SFUSER = `echo $server | awk -F// '{print $2}' | awk -F@ '{print $1}'`

# the sourceforge file release system details
set frslogin = ${SFUSER},psrchive@frs.sourceforge.net
set frspath = /home/frs/project/p/ps/psrchive/psrchive/

echo
echo "This script will install the public release of $tarfile as $SFUSER"
echo "Please hit <Enter> to continue or <Ctrl-C> to abort"
$<

mkdir -p 2012-12+
cp $tarfile 2012-12+/

rsync -e ssh -r 2012-12+ ${frslogin}:${frspath}

echo PSRCHIVE 2012-12+ released

