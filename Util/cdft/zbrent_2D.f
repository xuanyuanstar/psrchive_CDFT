	function zbrent_2D(x1,x2,f1,f2,tol,amp_prof,pha_prof,amp_tmpl,
     +                  pha_tmpl,nchan,nh,nsum)

C Brent's method root finding, calls dchisqr_2D function for fftfit
C Fit refined till output accuracy is tol

	parameter (itmax=100,eps=5.e-8)
	real*8 amp_prof(nchan,nh), pha_prof(nchan,nh)
        real*8 amp_tmpl(nchan,nh), pha_tmpl(nchan,nh)

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
	  zbrent_2D=b
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
	fb=dchisqr_2D(b,amp_prof,pha_prof,amp_tmpl,pha_tmpl,nchan,nh,nsum)
11	continue
	zbrent_2D=b
	return
	end
