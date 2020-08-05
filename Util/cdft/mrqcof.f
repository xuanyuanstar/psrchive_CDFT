C     Numerical receipt Fortran 77, 1986-1992
C     Modified to adopt 2-D complex model, by calculating beta and alpha from chi^2 directly

      SUBROUTINE mrqcof_2Dfftfit_fitDM(prof_amp,prof_pha,tmpl_amp,
     +tmpl_pha,sig,a,ia,alpha,beta,chisq,nchan,nbins,freq,D_0,mfit)

      parameter (twopi=3.141592653589793*2)
      INTEGER nchan,nbins,i,j,k,mfit
      INTEGER ia(mfit)
      REAL*8 prof_pha(nchan,nbins/2),prof_amp(nchan,nbins/2)
      REAL*8 tmpl_amp(nchan,nbins/2),tmpl_pha(nchan,nbins/2)
      REAL*8 chisq,a(mfit),alpha(mfit,mfit),beta(mfit)
      REAL*8 sc1,sc2,sig(nchan),freq(nchan),D_0,tau_DM(nchan)

      do i=1,nchan
        tau_DM(i)=D_0*a(nchan+2)/freq(i)**2/nbins*twopi
      end do

C     Calculate nchan*nchan elements of alpha and nchan elements of beta 
C     from chi^2, and chi^2
C     All summed to nbins/2 and then times by 2
      sc1=0.
      sc2=0.
      do j=1,nchan
        beta(j)=0.0
        do k=1,nbins/2
          sc1=sc1+(prof_amp(j,k)**2+(a(j)*tmpl_amp(j,k))**2)/sig(j)**2
          sc2=sc2+2.0*a(j)/sig(j)**2*prof_amp(j,k)*tmpl_amp(j,k)
     +        *cos(tmpl_pha(j,k)-prof_pha(j,k)+(tau_DM(j)+a(nchan+1))*k)
          beta(j)=beta(j)+2.0*a(j)/(sig(j)**2)*tmpl_amp(j,k)**2
     +         -2.0/sig(j)**2*prof_amp(j,k)*tmpl_amp(j,k)*
     +         cos(tmpl_pha(j,k)-prof_pha(j,k)+(tau_DM(j)+a(nchan+1))*k)
        end do
        beta(j)=-beta(j)*0.5*2
        do i=1,j
          if(i.eq.j) then
            alpha(j,i)=0.0
            do k=1,nbins/2
              alpha(j,i)=alpha(j,i)+2.0*(tmpl_amp(j,k)/sig(j))**2
            end do
            alpha(j,i)=alpha(j,i)*0.5*2
          else
            alpha(j,i)=0.0
          end if
        end do
      end do
      chisq=(sc1-sc2)*2

C     Calculate the rest elements of alpha,beta
      beta(nchan+1)=0.0
      alpha(nchan+1,nchan+1)=0.0
      if(mfit.eq.nchan+2) then
        beta(nchan+2)=0.0
        alpha(nchan+2,nchan+1)=0.0
        alpha(nchan+2,nchan+2)=0.0
      endif
      do j=1,nchan
        alpha(nchan+1,j)=0.0
        if(mfit.eq.nchan+2) then
          alpha(nchan+2,j)=0.0
        end if
        do k=1,nbins/2
          alpha(nchan+1,nchan+1)=alpha(nchan+1,nchan+1)+
     +                          2.0*(a(j)*tmpl_amp(j,k)*k/sig(j))**2
          beta(nchan+1)=beta(nchan+1)+2.0*a(j)/(sig(j)**2)*k
     +                 *prof_amp(j,k)*tmpl_amp(j,k)*sin(tmpl_pha(j,k)
     +                 -prof_pha(j,k)+(tau_DM(j)+a(nchan+1))*k)

          if(mfit.eq.nchan+2) then

            beta(nchan+2)=beta(nchan+2)+2.0*a(j)/sig(j)**2*D_0*k
     +        /freq(j)**2/nbins*twopi*prof_amp(j,k)*tmpl_amp(j,k)
     +        *sin(tmpl_pha(j,k)-prof_pha(j,k)+(tau_DM(j)+a(nchan+1))*k)

            alpha(nchan+2,nchan+2)=alpha(nchan+2,nchan+2)
     +                           +2.0*(a(j)*tmpl_amp(j,k)/sig(j))**2
     +                           *(D_0*k/(freq(j)**2)/nbins*twopi)**2

            alpha(nchan+2,nchan+1)=alpha(nchan+2,nchan+1)
     +                            +2.0*(a(j)*tmpl_amp(j,k)/sig(j))**2
     +                            *D_0*(k/freq(j))**2/nbins*twopi
          end if
        end do
      end do
      beta(nchan+1)=-beta(nchan+1)*0.5*2
      alpha(nchan+1,nchan+1)=alpha(nchan+1,nchan+1)*0.5*2
      if(mfit.eq.nchan+2) then
        beta(nchan+2)=-beta(nchan+2)*0.5*2
        alpha(nchan+2,nchan+1)=alpha(nchan+2,nchan+1)*0.5*2
        alpha(nchan+2,nchan+2)=alpha(nchan+2,nchan+2)*0.5*2
      end if

C     Fill in the symmetric side of alpha
      do 18 j=2,mfit
        do 17 k=1,j-1
          alpha(k,j)=alpha(j,k)
17      continue
18    continue

      return
      END
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
