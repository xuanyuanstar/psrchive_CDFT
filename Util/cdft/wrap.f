C     Rotate profile by integer of bins

      subroutine wrap(tmpl,nchan,nbins,rbin)

      Integer i,j,nchan,nbins,rbin,id
      Real*8 tmpl(nchan,nbins),buf(nbins)

      do j=1,nchan
        do i=1,nbins
          id=i+rbin
          if(id.lt.1) then
            id=id+nbins
          endif
          if(id.gt.nbins) then
            id=id-nbins
          endif
          buf(id)=tmpl(j,i)
        enddo
        do i=1,nbins
          tmpl(j,i)=buf(i)
        enddo
      enddo

      return
      end

