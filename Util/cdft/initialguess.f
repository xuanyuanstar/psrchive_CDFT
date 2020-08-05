C       Calculate the initial guess of phase shift bwteen profile and template
C       and DM

      subroutine initialguess(prof,tmpl,nchan,nbins,shift_bg,eshift,
     +                        dDM_bg,edDM,sca,freq,D_0,coef)
      parameter (twopi=3.141592653589793*2)
      Integer nchan,nbins,mwt
      real*8 prof(nchan,nbins),tmpl(nchan,nbins),sca(nchan) 
      real*8 shift_bg,eshift,dDM_bg,edDM,chisq,coef
      real*8 chan_prof(nbins),chan_tmpl(nbins),D_0,freq(nchan)
      real*8 buf_s,buf_es,buf_es2,scale,x(nchan),y(nchan),ey(nchan)

      do i=1,nchan
        do j=1,nbins
          chan_prof(j)=prof(i,j)
          chan_tmpl(j)=tmpl(i,j)
        end do
        call tmplmatch(chan_prof,chan_tmpl,nbins,buf_s,buf_es,buf_es2,
     +                 scale)
        if(buf_s.gt.twopi/2) then
          buf_s=buf_s-twopi
        end if
        sca(i)=scale
c       write(*,*)scale
        x(i)=D_0/freq(i)/freq(i)/nbins*twopi
        y(i)=buf_s
c       write(*,*)buf_s,freq(i)
        ey(i)=buf_es2
      end do

      mwt=1
      call fit(x,y,nchan,ey,mwt,shift_bg,dDM_bg,eshift,edDM,chisq,coef)

      return
      end

c     ****************************************************************
C     Calculate initial guess of phase shift when there is no DM fit
      subroutine initialguessnoDM(prof,tmpl,nchan,nbins,shift_bg,eshift,
     +     sca,wt)

      parameter (twopi=3.141592653589793*2)
      Integer nchan,nbins
      real*8 prof(nchan,nbins),tmpl(nchan,nbins),sca(nchan),wt(nchan)
      real*8 shift_bg,eshift,buf_s,buf_es,buf_es2
      real*8 chan_prof(nbins),chan_tmpl(nbins),scale,tot

c     Initial guess for scale
      do i=1,nchan
        do j=1,nbins
          chan_prof(j)=prof(i,j)
          chan_tmpl(j)=tmpl(i,j)
        end do
        call tmplmatch(chan_prof,chan_tmpl,nbins,buf_s,buf_es,buf_es2,
     +                 scale)
        sca(i)=scale
c       write(*,*)"Chan del (s):",buf_s/twopi*0.002946981889463*1.0d6, 
c    +            buf_es/twopi*0.002946981889463*1.0d6
      end do

c     Add in frequency
      tot=0.0
      do i=1,nbins
         chan_prof(i)=0.0
         chan_tmpl(i)=0.0
      end do
      do j=1,nchan
         do i=1,nbins
            chan_prof(i)=chan_prof(i)+prof(j,i)*wt(j)
            chan_tmpl(i)=chan_tmpl(i)+tmpl(j,i)
         end do
         tot=tot+wt(j)
      end do
      do i=1,nbins
         chan_prof(i)=chan_prof(i)/tot
         chan_tmpl(i)=chan_tmpl(i)/nchan
      end do

c     Run 1D template matching 
      call tmplmatch(chan_prof,chan_tmpl,nbins,buf_s,buf_es,buf_es2,
     +               scale)
      if(buf_s.gt.twopi/2) then
        buf_s=buf_s-twopi
      end if

      shift_bg=buf_s
      eshift=buf_es
      return
      end
