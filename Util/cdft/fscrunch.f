C     Frequency scrunch the profile by given factor and save in new buffer

      Subroutine fscrunch(prof,nchan,nbins,prof_alt,fac)

      integer fac,nchan,nbins,nchan_alt,i,j,k
      real*8 prof(nchan,nbins),prof_alt(nchan/fac,nbins)

      nchan_alt=nchan/fac

C     Fold
      do j=1,nchan_alt
        do i=1,nbins
          prof_alt(j,i)=0.0
          do k=1,fac
            prof_alt(j,i)=prof_alt(j,i)+prof(j*fac+1-k,i)
          end do
          prof_alt(j,i)=prof_alt(j,i)/fac 
        end do
      end do

      return

      end
