c     Use 2D template and profile to calculate the relative phase shift and
c     DM difference

      Subroutine tmplmatch2(prof,tmpl,nchan,nbins,shift,eshift,
     +                            dDM,edDM,D_0,freq,mfit,wt)

      parameter (twopi=3.141592653589793*2)
      integer nchan,nbins,mfit,rmsbegin,i,j,jd,ct,rbin
      integer ia(mfit)
      real*8 prof(nchan,nbins),tmpl(nchan,nbins),kk
      real*8 amp_prof(nchan,nbins/2),pha_prof(nchan,nbins/2)
      real*8 amp_tmpl(nchan,nbins/2),pha_tmpl(nchan,nbins/2)
      real*8 readrms(nchan),sca(nchan),freq(nchan),wt(nchan)
      real*8 shift,eshift,shift_bg,dDM,edDM,dDM_bg,D_0,coef
      real*8 a(mfit),alpha(mfit,mfit),covar(mfit,mfit)
      real*8 alamda,chisq,ochisq,beta(mfit),shift0,eshift_bg
      real*8 Rchi

      fac=nbins/twopi
      shift0=0.0;

c     Initial guess when no DM fit
      if(mfit.eq.nchan+1) then
         call initialguessnoDM(prof,tmpl,nchan,nbins,shift_bg,eshift_bg,
     +   sca,wt)
c     write(*,*)"Initial guess:" 
c     write(*,*)"Shift in phase:",shift_bg/twopi,eshift_bg/twopi
c     write(*,*)"In microsec:",shift_bg/twopi*0.002946981889463*1.0d6,
c    +          eshift_bg/twopi*0.002946981889463*1.0d6
      end if

c     Initial guess when DM fit included
      if(mfit.eq.nchan+2) then
C     Obtain initial guess of the parameters,shift_bg in rad
         call initialguess(prof,tmpl,nchan,nbins,shift_bg,eshift_bg,
     +                     dDM_bg,edDM,sca,freq,D_0,coef)
c     write(*,*)"Initial guess:"
c     write(*,*)"Shift in phase:",shift_bg/twopi,eshift_bg/twopi
c     write(*,*)"dDM:",dDM_bg,edDM
c     write(*,*)"Coefficient:",coef
      end if

C     Make template more aligned to profile
      rbin=shift_bg/twopi*nbins
      shift0=dble(rbin)/nbins*twopi
      shift_bg=shift_bg-shift0
      call wrap(prof,nchan,nbins,-rbin)

c     Perform FFT to each individual band and fill in the phase and amplitude arrays
      call sepFFT(tmpl,nchan,nbins,amp_tmpl,pha_tmpl)
      call sepFFT(prof,nchan,nbins,amp_prof,pha_prof)

      rmsbegin=nbins/2/8*5
c     Calculate rms of individual channels from the high frequency harmonics
      do i=1,nchan
        readrms(i)=0.0
        do j=rmsbegin,nbins/2
          readrms(i)=readrms(i)+amp_prof(i,j)**2
        end do
        readrms(i)=sqrt(readrms(i)/(nbins/2-rmsbegin+1))
c       write(*,*)readrms(i)
c       readrms(1)=0.15551729582017640
c       readrms(2)=0.17413314476746058     
c       readrms(3)=0.18144244685305003     
c       readrms(4)=0.16557314485112190     
c       readrms(5)=0.18401485224820879     
c       readrms(6)=0.24807599238724765     
c       readrms(7)=0.27979888870514180     
c       readrms(8)=0.17581917163384378     
      end do
c     readrms(1)=readrms(1)*2.0

      Rchi=999999.0
C     Loop over different starting values
      do kk=-5.0,5.0,1

C     Initialize input for the LM routine
        do i=1,nchan
          a(i)=sca(i)
          ia(i)=1
        end do
c       a(1)=sca(1)*(1.0-kk/100.0)
c       a(2)=sca(2)*(1.0+kk/100.0)
c       a(3)=sca(3)*(1.0-kk/100.0)
c       a(4)=sca(4)*(1.0+kk/100.0)
c       a(5)=sca(5)*(1.0-kk/100.0)
c       a(6)=sca(6)*(1.0+kk/100.0)
c       a(7)=sca(7)*(1.0-kk/100.0)
c       a(8)=sca(8)*(1.0+kk/100.0)
        ia(nchan+1)=1
        a(nchan+1)=shift_bg+eshift_bg*kk
        if(mfit.eq.nchan+2) then
          ia(nchan+2)=1
          a(nchan+2)=dDM_bg
        end if
        alamda=-0.1
        jd=0      
        ct=0

c     write(*,*)"Loop",a(nchan+1)/twopi+shift0/twopi,kk
c     Call the hacked LM routine
 10     call mrqmin(amp_prof,pha_prof,amp_tmpl,pha_tmpl,readrms,nchan,
     +              nbins,a,ia,covar,alpha,beta,chisq,ochisq,alamda,
     +              freq,D_0,mfit,jd)

c     write(*,*)"Reduced chisq of fitting:",chisq/(nbins*nchan-1-mfit)
c     write(*,*)"New shift:", a(nchan+1)*fac/nbins+shift0*fac/nbins
        if(jd.lt.2) then
          ct=ct+1
          if(ct.gt.100) then
c           write(*,*)"Loop over 100"
            goto 100
          endif
          goto 10
        end if
      
 100    alamda=0.0d0
        call mrqmin(amp_prof,pha_prof,amp_tmpl,pha_tmpl,readrms,nchan,
     +              nbins,a,ia,covar,alpha,beta,chisq,ochisq,alamda,
     +              freq,D_0,mfit,jd)
c     write(*,*)"New:",chisq    
c       write(*,*)"New shift:", (a(nchan+1)*fac/nbins+shift0*fac/nbins
c    +            )*0.002946981889463*1.0d6

c        write(*,*)"Fitted shift in bin:"
c        write(*,*)a(nchan+1)*fac,sqrt(covar(nchan+1,nchan+1))*fac
        if(mfit.eq.nchan+2) then
c         write(*,*)"Fitted DM difference:"
c         write(*,*)a(nchan+2),sqrt(covar(nchan+2,nchan+2))
c         write(*,*)"Correlation coefficient:",covar(nchan+2,nchan+1)
c    +            /sqrt(covar(nchan+2,nchan+2)*covar(nchan+1,nchan+1))
        end if
c       write(*,*)"Reduced chisq of fitting:",chisq/(nbins*nchan-1-mfit)

c       Better value than before
        if(chisq/(nbins*nchan-1-mfit).lt.Rchi) then
           Rchi=chisq/(nbins*nchan-1-mfit)
           shift=a(nchan+1)*fac+shift0*fac
c          write(*,*)"Shift:",shift
c          if(shift/nbins.gt.0.5) then
c            shift=shift-dble(nbins)
c          endif
c          if(shift/nbins.lt.-0.5) then
c            shift=shift+dble(nbins)
c          endif

c      Times the variance from covariance matrix by reduced chi-square
c     eshift=sqrt(covar(nchan+1,nchan+1))*fac
           eshift=sqrt(covar(nchan+1,nchan+1)*Rchi)*fac
           if(mfit.eq.nchan+2) then
             dDM=a(nchan+2)
             edDM=sqrt(covar(nchan+2,nchan+2))
           endif
        endif
      enddo
c     write(*,*)"Reduced chisq of fitting:",Rchi

      return
      end

ccccccccccccccccccccccccccccccccccccccccccccccccccccccc
