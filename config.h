/* config.h.  Generated from config.h.in by configure.  */
/* config.h.in.  Generated from configure.ac by autoheader.  */

/* Define if building universal (internal helper macro) */
/* #undef AC_APPLE_UNIVERSAL_BUILD */

/* Define to dummy `main' function (if any) required to link to the Fortran
   libraries. */
/* #undef F77_DUMMY_MAIN */

/* Define to a macro mangling the given C identifier (in lower and upper
   case), which must not contain underscores, for linking with Fortran. */
#define F77_FUNC(name,NAME) name ## _

/* As F77_FUNC, but for C identifiers containing underscores. */
#define F77_FUNC_(name,NAME) name ## _

/* Define if F77 and FC dummy `main' functions are identical. */
/* #undef FC_DUMMY_MAIN_EQ_F77 */

/* define if the compiler finds best partial specialization */
#define HAVE_BEST_PARTIAL_SPECIALIZATION /**/

/* Define if the CFITSIO library is present */
#define HAVE_CFITSIO 1

/* define if complex template is good */
#define HAVE_COMPLEX_TEMPLATE 1

/* Define to 1 if you have the CULA library */
/* #undef HAVE_CULA */

/* define if partial specialization accepts default template arg */
/* #undef HAVE_DEFAULT_PARTIAL_SPECIALIZATION */

/* Define to 1 if you have the <dlfcn.h> header file. */
#define HAVE_DLFCN_H 1

/* Define if the FFTW3 library is installed */
#define HAVE_FFTW3 1

/* Define to 1 if you have the <getopt.h> header file. */
#define HAVE_GETOPT_H 1

/* Define to 1 if you have the `getopt_long' function. */
#define HAVE_GETOPT_LONG 1

/* Define to 1 if you have the GSL library */
#define HAVE_GSL 1

/* Define to 1 if you have the HEALPix library */
/* #undef HAVE_HEALPIX */

/* Define to 1 if you have the <inttypes.h> header file. */
#define HAVE_INTTYPES_H 1

/* Define if IPP library is installed */
/* #undef HAVE_IPP */

/* Define to 1 if you have the `m' library (-lm). */
#define HAVE_LIBM 1

/* Define to 1 if you have the <malloc.h> header file. */
#define HAVE_MALLOC_H 1

/* Define to 1 if you have the <memory.h> header file. */
#define HAVE_MEMORY_H 1

/* Define if the old Intel Math Kernel Library is present */
/* #undef HAVE_MKL */

/* Define if the Intel Math Kernel Library DFTI is present */
/* #undef HAVE_MKL_DFTI */

/* Define if a Message Passing Interface library is present */
/* #undef HAVE_MPI */

/* Define to 1 if you have the <openssl/sha.h> header file. */
#define HAVE_OPENSSL_SHA_H 1

/* Define to 1 if you have the PGPLOT library */
#define HAVE_PGPLOT 1

/* Define if PSRCAT is installed */
#define HAVE_PSRCAT 1

/* Define to 1 if you have the PSRXML library */
/* #undef HAVE_PSRXML */

/* Define if you have POSIX threads libraries and header files. */
#define HAVE_PTHREAD 1

/* Define to 1 if you have the PUMA library */
/* #undef HAVE_PUMA */

/* Define if PGPLOT library has Qt driver */
/* #undef HAVE_QTDRIV */

/* Define to 1 if GNU readline is installed */
#define HAVE_READLINE 1

/* Define to 1 if you have the <stdint.h> header file. */
#define HAVE_STDINT_H 1

/* Define to 1 if you have the <stdlib.h> header file. */
#define HAVE_STDLIB_H 1

/* Define to 1 if you have the <strings.h> header file. */
#define HAVE_STRINGS_H 1

/* Define to 1 if you have the <string.h> header file. */
#define HAVE_STRING_H 1

/* Define to 1 if you have the <sys/mount.h> header file. */
#define HAVE_SYS_MOUNT_H 1

/* Define to 1 if you have the <sys/statvfs.h> header file. */
#define HAVE_SYS_STATVFS_H 1

/* Define to 1 if you have the <sys/stat.h> header file. */
#define HAVE_SYS_STAT_H 1

/* Define to 1 if you have the <sys/types.h> header file. */
#define HAVE_SYS_TYPES_H 1

/* Define to 1 if you have the <sys/vfs.h> header file. */
#define HAVE_SYS_VFS_H 1

/* Define to 1 if you have <sys/wait.h> that is POSIX.1 compatible. */
#define HAVE_SYS_WAIT_H 1

/* Define to 1 if you have the TEMPO2 library */
#define HAVE_TEMPO2 1

/* Define to 1 if you have the <unistd.h> header file. */
#define HAVE_UNISTD_H 1

/* Define to the sub-directory where libtool stores uninstalled libraries. */
#define LT_OBJDIR ".libs/"

/* Name of package */
#define PACKAGE "psrchive"

/* Define to the address where bug reports for this package should be sent. */
#define PACKAGE_BUGREPORT "psrchive-developers@lists.sourceforge.net"

/* Define to the full name of this package. */
#define PACKAGE_NAME "PSRCHIVE"

/* Define to the full name and version of this package. */
#define PACKAGE_STRING "PSRCHIVE 2012-12+"

/* Define to the one symbol short name of this package. */
#define PACKAGE_TARNAME "psrchive"

/* Define to the home page for this package. */
#define PACKAGE_URL ""

/* Define to the version of this package. */
#define PACKAGE_VERSION "2012-12+"

/* Define to necessary symbol if this constant uses a non-standard name on
   your system. */
/* #undef PTHREAD_CREATE_JOINABLE */

/* Define to 1 if you have the ANSI C header files. */
#define STDC_HEADERS 1

/* Version number of package */
#define VERSION "2012-12+"

/* Define WORDS_BIGENDIAN to 1 if your processor stores words with the most
   significant byte first (like Motorola and SPARC, unlike Intel). */
#if defined AC_APPLE_UNIVERSAL_BUILD
# if defined __BIG_ENDIAN__
#  define WORDS_BIGENDIAN 1
# endif
#else
# ifndef WORDS_BIGENDIAN
/* #  undef WORDS_BIGENDIAN */
# endif
#endif

/* Define to 1 if the X Window System is missing or not being used. */
/* #undef X_DISPLAY_MISSING */

/* Enable large inode numbers on Mac OS X 10.5.  */
#ifndef _DARWIN_USE_64_BIT_INODE
# define _DARWIN_USE_64_BIT_INODE 1
#endif

/* Number of bits in a file offset, on hosts where this is settable. */
/* #undef _FILE_OFFSET_BITS */

/* Define for large files, on AIX-style hosts. */
/* #undef _LARGE_FILES */

/* enable POSIX C99 format macros */
#define __STDC_FORMAT_MACROS 1
