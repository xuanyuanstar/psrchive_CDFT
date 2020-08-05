      subroutine tdfftfit(nchan,nbins,shift,eshift,dDM,
     +               edDM,D_0,freq,mfit,proftmp,tmpltmp,wt)

      implicit none

      integer i,j,nbins,nchan,mfit,twopi
      parameter (twopi=3.141592653589793*2)
      real*8 prof(nchan,nbins),tmpl(nchan,nbins),freq(nchan),wt(nchan)
      real*8 shift,eshift,dDM,edDM,D_0
      character*22 proftmp,tmpltmp 

      open(10,file=proftmp,status="old")
      open(20,file=tmpltmp,status="old")
       do j=1,nchan
        do i=1,nbins
          read(10,*)prof(j,i)
          read(20,*)tmpl(j,i)
        end do
      end do
      close(10)
      close(20)

c     Call the 2D template matching routine to calculate dtau,dDM and the errors
c     dtau in unit of bin
      call tmplmatch2(prof,tmpl,nchan,nbins,shift,eshift,dDM,edDM,
     +                      D_0,freq,mfit,wt)
  
      return
      end

ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
