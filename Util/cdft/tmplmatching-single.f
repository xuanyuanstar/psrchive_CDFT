c     tmpl matching to calculate sigma_TOA, for rms calu both assuming re-chi^2=1 and from baseline in frequency domain

      subroutine tmplmatch(profile,template,nbins,shift,eshift,
     +                     eshift2,scale)

      implicit none

      integer nbins
      real*8 profile(nbins),template(nbins)
      real*8 eshift, shift, snr, esnr,eshift2,scale
      real*8 amp(nbins/2), pha(nbins/2)

      call makeFtempl(amp,pha,template,nbins) 

c-----Do the frequency domain template fit, get shift in rad
      call fftfit(profile,amp,pha,nbins,shift,eshift,snr,esnr,
     +            eshift2,scale)

c     if(snr<5.0) write(*,*)"Warning: individual channel SNR low"

      return      
      end

ccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      subroutine makeFtempl(amp,pha,da,nbins)
      
C     Converts a standard profile into normalized harmonic-squared form
c
c     based on a subroutine by AW
c     
      
      implicit none
      
      integer maxsam,i,nh,ipos, nbins
      real*8 fixoff, twopi,da,amp,pha,pmax
      
      parameter (MAXSAM=4096,twopi=3.141592653589793*2,fixoff=0.0)

      dimension da(nbins),amp(MAXSAM/2),pha(MAXSAM/2)

      complex cstd(0:MAXSAM/2)
      
      nh=nbins/2
      
c-------Computefrequency-domaintemplate
      call cprof_old(da,nbins,nh,cstd,amp,pha)
      
      end

ccccccccccccccccccccccccccccccccccccccccccccccccccccccc
	subroutine cprof_old(y,nmax,nh,c,amp,pha)

C  Compute FFT of profile in array y(nmax), and return amplitude and phase
C  in arrays amp(nh) and pha(nh).  Note that nh=nmax/2, and that the DC term
C  is returned in c(0), fundamental in c(1), ..., Nyquist freq in c(nh).

	parameter(MAXSAM=4096)
	real*8 y(nmax),amp(nh),pha(nh)
	complex c(0:nh),temp(MAXSAM)

	do 10 i=1,nh
10	 temp(i)=cmplx(y(2*i-1),y(2*i))
	call ffft_cdft(temp,nmax,1,1)
	c(0)=temp(1)
	do 20 i=1,nh
	 c(i)=temp(i+1)
	 amp(i)=cabs(c(i))
	 pha(i)=0.
20	if(amp(i).gt.0.) pha(i)=aimag(clog(c(i)))
	return
	end
ccccccccccccccccccccccccccccccccccccccccccccccccccccccc
	subroutine fftfit(prof,s,phi,nmax,shift,eshift,snr,esnr,eshift2,scale)

C  Fourier transform domain routine for determining pulse TOAs.
C  Input data:
C	prof(nmax)	profile
C	s(nh)		standard profile amplitude
C	phi(nh)	standard profile phase
C	nmax		length of prof

C  Outputs:
C	shift		shift required to align std with prof, in bins
C	eshift	uncertainty in shift
C	snr		signal to noise ratio of prof
C	esnr		uncertainty in snr

C  Method:
C  It is assumed that prof(j)=a + b*std(j-tau) + noise(j), where the
C  (j-tau) subscript is supposed to mean that the time-shift between the
C  observed and standard profiles need not be an integer number of bins.
C  The algorithm is a straightforward Chi-squared minimization with respect
C  to a, b, and tau.  (The result for a, being of no physical or instrumental
C  interest, is not actually evaluated -- though it easily could be.)
C  First and second partial derivatives of Chisqr with respect to b and tau
C  are computed, and used to evaluate s, snr, and their "standard errors,"
C  or one-sigma uncertainties.  The only special trick is that the expression
C  for the best-fit value of tau defines it implicitly, and cannot be solved
C  analytically.  It is solved numerically instead, finding the minimum of
C  Chisqr near a best guess from a CCF at 32 lags done in the Fourier domain.

C  Also note that it may
C  be desirable to return the scale factor b relating prof to std, instead
C  of snr.  In that case you could also return the noise estimate rms.
c
c  Changed a lower bound to iterate the transcendental equation from 5 to 4,
c  in accord with changing nprof from 64 to 32 in fccf32.f.
c  AW, March 1992.

	parameter (twopi=3.141592653589793*2,MAXSAM=4096)
	real*8 prof(MAXSAM),p(MAXSAM/2),theta(MAXSAM/2)
	real*8 s(MAXSAM/2),phi(MAXSAM/2),r(MAXSAM/2),tmp(MAXSAM/2)
        real*8 shift,eshift,snr,esnr,eshift2,scale
	complex cp(0:MAXSAM/2)
	logical low,high

c       if (phi(1).ne.0) then
c	  write (0,*) ' Phase of fundamental not zero, check .hm file'
c	  stop
c	end if

	nh=nmax/2
	call cprof_old(prof,nmax,nh,cp,p,theta)

        rmsbegin =nh/8*5
c       calculate rms from the high frequency harmonics
        readrms=0.0
        do i=rmsbegin,nh
           readrms=readrms+(p(i))**2
        end do
        readrms=sqrt(readrms/(nh-rmsbegin+1))

c-------DefineTOAsuch that phase of fundamental = 0
c       do i=1,nh
c        theta(i)=mod(theta(i)-float(i)*theta(1),twopi)	
c       enddo

	do 10 k=1,nh
	 tmp(k)=p(k)*s(k)
10	 r(k)=theta(k)-phi(k)

        fac=nmax/twopi

	call fccf_cdft(tmp,r,shift)

C  The "DO 60" loop solves the transcendental equation yielding the best-fit
C  value of tau.  Here the number starts at 16 (number used in CCF)
C  and increases by factors of 2, at each step finding the function
C  zero closest to the starting point from the previous iteration.

 	tau=shift

	do 60 isum=4,99
	 nsum=2.0**isum
	 if(nsum.gt.nh) go to 70
	 dtau=twopi/(nsum*5)
	 edtau=1./(2.*nsum+1.)
         if (nsum.gt.(nh/2.+.5)) edtau=1.e-5

	 ntries=0
	 low=.false.
	 high=.false.
50	 ftau=dchisqr(tau,tmp,r,nsum)
	 ntries=ntries+1
	 if(ftau.lt.0.0) then
	   a=tau
	   fa=ftau
	   tau=tau+dtau
	   low=.true.
	 else
	   b=tau
	   fb=ftau
	   tau=tau-dtau
	   high=.true.
	 end if
	 if (ntries.gt.10) then
	   shift=0.
	   eshift=999.
	   snr=0.
	   esnr=0.
	   return
	 end if
	 if (low.neqv.high) go to 50
	 tau=zbrent(a,b,fa,fb,edtau,tmp,r,nsum)
60	continue

70	s1=0.
	s2=0.
	s3=0.
	do 80 k=1,nh
	 cosfac=cos(-r(k)+k*tau)
	 s1=s1 + tmp(k)*cosfac
	 s2=s2 + s(k)**2
80	 s3=s3 + k**2 *tmp(k)*cosfac
	b=s1/s2
	s1=0.
	do 90 k=1,nh
	 sq=p(k)**2-2.*b*p(k)*s(k)*cos(r(k)-k*tau)+(b*s(k))**2
90	 if(s(k).ne.0.) s1=s1+sq
	rms=sqrt(s1/nh)
	errb=rms/sqrt(2.0*s2)
	errtau=rms/sqrt(2.0*b*s3)
	snr=2.0*sqrt(2.0*nh)*b/rms

	shift=tau
	eshift=errtau
	esnr=snr*errb/b
        scale=b

c       new eshift from readrms
	errtau=readrms/sqrt(2.0*b*s3)
        eshift2=errtau

        rchisq = (s1/readrms**2)/(nh-3)
c       write(*,*)"rms (re chi^2=1):",rms," real:",readrms,
c    +  " re chi^2:",rchisq

	return
	end
ccccccccccccccccccccccccccccccccccccccccccccccccccccccc
	subroutine fccf_cdft(amp,pha,shift)

C  Calculates CCF in Fourier domain using 8 harmonics of amp and pha arrays
C  amp=p*s,pha=theta-phi.  Finds maximum of CCF at 32 lags over the pulsar
C  period, and returns value of shift in radians.
c
c  Changed nprof from 64 to 32 (and all the appropriate hardwired constants)
c  to deal with 32-point profiles.  AW -- March 1992

	parameter (nprof=32,nprof1=nprof-1)
	parameter (MAXSAM=4096,twopi=3.141592653589793*2)
	real*8 amp(MAXSAM/2),pha(MAXSAM/2),shift
	complex ccf(0:nprof1)

	nh=nprof/2
	ccf(0)=(0.,0.)
	do 10 i=1,nh/2
	 ccf(i)=cmplx(amp(i)*cos(pha(i)),amp(i)*sin(pha(i)))
10	 ccf(nprof-i)=conjg(ccf(i))
	do 20 i=nh/2+1,nh
	 ccf(i)=(0.,0.)
20	 ccf(nprof-i)=(0.,0.)
	call ffft_cdft(ccf,nprof,-1,0)
	cmax=-1.e30
	do 30 i=0,nprof1
	 rc=real(ccf(i))
	 if (rc.gt.cmax) then
	   cmax=rc
	   imax=i
	 end if
30	continue

	fb=cmax
	ia=imax-1
	if(ia.eq.-1) ia=nprof-1
	fa=real(ccf(ia))
	ic=imax+1
	if(ic.eq.nprof) ic=0
	fc=real(ccf(ic))
	if ((2*fb-fc-fa).ne.0) then
	  shift=imax+0.5*(fa-fc)/(2*fb-fc-fa)
	else
	  shift=imax
	end if
c	if(shift.gt.nh) shift=shift-nprof
	shift=shift*twopi/nprof

	return
	end
ccccccccccccccccccccccccccccccccccccccccccccccccccccccc
	function zbrent(x1,x2,f1,f2,tol,tmp,pha,nsum)

C Brent's method root finding, calls dchisqr(x,tmp,r,nsum) function for fftfit
C Fit refined till output accuracy is tol

	parameter (itmax=100,eps=6.e-8,MAXSAM=4096)
	real*8 tmp(MAXSAM/2),pha(MAXSAM/2)

	a=x1
	b=x2
	fa=f1
	fb=f2
	fc=fb
	do 11 iter=1,itmax
	if(fb*fc.gt.0.) then
	  c=a
	  fc=fa
	  d=b-a
	  e=d
	end if
	if(abs(fc).lt.abs(fb)) then
	  a=b
	  b=c
	  c=a
	  fa=fb
	  fb=fc
	  fc=fa
	end if
	tol1=2.*eps*abs(b)+0.5*tol
	xm=.5*(c-b)
	if(abs(xm).le.tol1 .or. fb.eq.0.) then
	  zbrent=b
	  return
	end if
	if(abs(e).ge.tol1 .and. abs(fa).gt.abs(fb)) then
	  s=fb/fa
	  if(a.eq.c) then
	    p=2.*xm*s
	    q=1.-s
	  else
	    q=fa/fc
	    r=fb/fc
	    p=s*(2.*xm*q*(q-r)-(b-a)*(r-1.))
	    q=(q-1.)*(r-1.)*(s-1.)
	  end if
	  if(p.gt.0.) q=-q
	  p=abs(p)
	  if(2.*p .lt. min(3.*xm*q-abs(tol1*q),abs(e*q))) then
	    e=d
	    d=p/q
	  else
	    d=xm
	    e=d
	  end if
	else
	  d=xm
	  e=d
	end if
	a=b
	fa=fb
	if(abs(d) .gt. tol1) then
	  b=b+d
	else
	  b=b+sign(tol1,xm)
	end if
	fb=dchisqr(b,tmp,pha,nsum)
11	continue
	zbrent=b
	return
	end

	function dchisqr(tau,tmp,r,nsum)

	parameter (MAXSAM=8192)
	real*8 tmp(MAXSAM/2),r(MAXSAM/2)

	s=0.
	do 40 k=1,nsum
40	 s=s+k*tmp(k)*sin(-r(k)+k*tau)
	dchisqr=s
	return
	end

ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
 
