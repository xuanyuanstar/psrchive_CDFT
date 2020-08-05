C     Numerical receipt Fortran 77, 1986-1992
C     Uses covsrt,gaussj,mrqcof

      Subroutine mrqmin(prof_amp,prof_pha,tmpl_amp,tmpl_pha,sig,nchan,
     +                  nbins,a,ia,covar,alpha,beta,chisq,ochisq,alamda,
     +                  freq,D_0,mfit,jd)

      INTEGER nchan,nbins,j,k,l,mfit,jd
      INTEGER ia(mfit)
      REAL*8 prof_pha(nchan,nbins/2),prof_amp(nchan,nbins/2)
      REAL*8 tmpl_amp(nchan,nbins/2),tmpl_pha(nchan,nbins/2)
      REAL*8 alamda,chisq,a(mfit),alpha(mfit,mfit)
      REAL*8 covar(mfit,mfit),sig(nchan),beta(mfit)
      REAL*8 ochisq,atry(mfit),da(mfit),freq(nchan),D_0

      if(alamda.lt.0.)then
        alamda=1.0d-3        
        call mrqcof_2Dfftfit_fitDM(prof_amp,prof_pha,tmpl_amp,
     +     tmpl_pha,sig,a,ia,alpha,beta,chisq,nchan,nbins,freq,D_0,mfit)
        ochisq=chisq
c       write(*,*)"Initial reduced chisq:",ochisq/(nchan*nbins-1-mfit)
        do 12 j=1,mfit
          atry(j)=a(j)
12      continue
      endif

c     Get next tried delta a and matrix
      do 14 j=1,mfit
           do 13 k=1,mfit
                covar(j,k)=alpha(j,k)
 13        continue
           covar(j,j)=alpha(j,j)*(1.+alamda)
           da(j)=beta(j)
 14   continue

C     Matrix solution
      call gaussj(covar,mfit,mfit,da,1,1)

C     Once converged, evaluate covariance matrix
      if(alamda.eq.0.)then
         call covsrt(covar,mfit,mfit,ia,mfit)
         call covsrt(alpha,mfit,mfit,ia,mfit)
         return
      endif

C     Calculate the achieved chisq with the next solution
      j=0
      do 15 l=1,mfit
        if(ia(l).ne.0) then
          j=j+1
          atry(l)=a(l)+da(j)
        endif
15    continue
      call mrqcof_2Dfftfit_fitDM(prof_amp,prof_pha,tmpl_amp,
     +    tmpl_pha,sig,atry,ia,covar,da,chisq,nchan,nbins,freq,D_0,mfit)

C     If new solution better, accept new solution and update fitted parameters,
C     alpha and beta
      if(chisq.lt.ochisq) then
C       Chi-square decrease by a small amount
        if(ochisq-chisq.lt.1.0d-4) then
          jd=jd+1
        end if
        alamda=alamda*1.0d-1
        ochisq=chisq
        do 17 j=1,mfit
             do 16 k=1,mfit
                  alpha(j,k)=covar(j,k)          
 16          continue
             beta(j)=da(j)             
 17     continue
        do l=1,mfit
          a(l)=atry(l)
        enddo
C     Failure, increase alamda
      else
        alamda=alamda*1.0d1
        chisq=ochisq
      endif

      return
      END
