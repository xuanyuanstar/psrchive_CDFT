C     Linear regression of data
C     USES gammq

      SUBROUTINE fit(x,y,ndata,sig,mwt,a,b,siga,sigb,chi2,coef)

      INTEGER mwt,ndata,i
      REAL*8 a,b,chi2,siga,sigb,sig(ndata),x(ndata),y(ndata)
      REAL*8 sigdat,ss,st2,sx,sxoss,sy,t,wt,coef

      sx=0.
      sy=0.
      st2=0.
      b=0.
      if(mwt.ne.0) then
        ss=0.
        do i=1,ndata 
          wt=1./(sig(i)**2)
          ss=ss+wt
          sx=sx+x(i)*wt
          sy=sy+y(i)*wt
        enddo
      else
        do i=1,ndata
          sx=sx+x(i)
          sy=sy+y(i)
        enddo
        ss=dble(ndata)
      endif

      sxoss=sx/ss
      if(mwt.ne.0) then
        do i=1,ndata
          t=(x(i)-sxoss)/sig(i)
          st2=st2+t*t
          b=b+t*y(i)/sig(i)
        enddo
      else
        do i=1,ndata
          t=x(i)-sxoss
          st2=st2+t*t
          b=b+t*y(i)
        enddo 
      endif

      b=b/st2
      a=(sy-sx*b)/ss
      siga=sqrt((1.+sx*sx/(ss*st2))/ss)
      sigb=sqrt(1./st2)
      chi2=0.
      coef=-sx/ss/st2/siga/sigb

      if(mwt.eq.0) then
        do i=1,ndata
          chi2=chi2+(y(i)-a-b*x(i))**2
        enddo
      sigdat=sqrt(chi2/(ndata-2))
      siga=siga*sigdat
      sigb=sigb*sigdat
      else
        do i=1,ndata
          chi2=chi2+((y(i)-a-b*x(i))/sig(i))**2
        enddo
      endif

      return
      END
