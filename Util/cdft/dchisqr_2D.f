c       Derivative of chi square in 2D individual channel template matching

	function dchisqr_2D(tau,amp_prof,pha_prof,amp_tmpl,pha_tmpl,nchan,nh,nsum)

	real*8 amp_prof(nchan,nh), pha_prof(nchan,nh)
        real*8 amp_tmpl(nchan,nh), pha_tmpl(nchan,nh)
        real*8 b(nchan)

c       calculate scaling factor b_i for individual channel
        do i=1,nchan
          s1=0.0
          s2=0.0
          do j=1,nsum
            s1=s1+amp_prof(i,j)*amp_tmpl(i,j)
     +         *cos(pha_tmpl(i,j)-pha_prof(i,j)+tau*j)
            s2=s2+amp_tmpl(i,j)**2
          end do
          b(i)=s1/s2
        end do

c       calculate the global dchi^2/dtau
	s=0.0
        do i=1,nchan
          s3=0.0
          do j=1,nsum
            s3=s3+j*amp_prof(i,j)*amp_tmpl(i,j)
     +         *sin(pha_tmpl(i,j)-pha_prof(i,j)+tau*j)
          end do
          s=s+b(i)*s3
c         s=s+s3
        end do

	dchisqr_2D=s

	return
	end
