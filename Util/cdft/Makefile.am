noinst_LTLIBRARIES = libpsrcdft.la

libpsrcdft_la_SOURCES = 2Dfftfit.f sepFFT.f cprof.f dchisqr_2D.f zbrent_2D.f twoDFFTfit_fitDM.f \
	tmplmatching-single.f initialguess.f mrqmin.f mrqcof.f gaussj.f \
       covsrt.f fit.f fscrunch.f wrap.f
#2Dtim_SOURCES = 2Dtim.c

#bin_PROGRAMS = 2Dtim

AM_FFLAGS = -ffixed-form -ffixed-line-length-none -std=legacy

include $(top_srcdir)/config/Makefile.include
