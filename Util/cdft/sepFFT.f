c  For given 2-D profile, perform FFT to each channel and fill in the 2-D phase and amplitude arrays
        subroutine sepFFT(prof,nchan,nbins,amp,pha)

        integer nchan,nbins,j,i
        real*8 prof(nchan,nbins)
        real*8 amp(nchan,nbins/2),pha(nchan,nbins/2)
        real*8 dat(nbins),dat_amp(nbins/2),dat_pha(nbins/2)

        do j=1,nchan
          do i=1,nbins
            dat(i)=prof(j,i)
          end do 
          call cprof(dat,nbins,dat_amp,dat_pha)
          do i=1,nbins/2
            amp(j,i)=dat_amp(i)
            pha(j,i)=dat_pha(i)
          end do
        enddo

        return
        end
