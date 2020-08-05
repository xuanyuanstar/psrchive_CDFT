//For input of profile and template archive files, perform template matching to fit for TOA and DM (if required)
//Frequency scrunch by a factor of fs first
//Sign_DM=0 for phase only, =1 for both phase and DM
//Reference DM (DM0) is DM in the template

#include<stdio.h>
#include<string.h>
#include<stdlib.h>
#include<math.h>

extern void tdfftfit_(int *nchan,int *nbins,double *shift,double *eshift,double *dDM,double *edDM,double *D_0,double *freq,int *mfit);

extern void tmplmatch_(double *prof_1D,double *tmpl_1D,int *nbin,double *off_1D,double *eoff_1D,double *eoff2_1D,double *scale);

void get_toa_2D(char *fprof, char *ftmpl, char *toa, double *etoa, double *DM, double *eDM, int fs, int sign_DM)
{

  double Pt,t0_f,shift_1D,shift,eshift,dDM,edDM,D_0,D,bw_p,bw_t,freq_p,freq_t,DM_p,DM_t;
  int nchan_p,nchan_t,nbin_p,nbin_t,mfit,t0_i;
  unsigned long x;

  D=1.0/2.41e-4; //Dispersion constant
  mfit=nchan+1+sign_DM; //Number of parameter in fit

  //Get frequency, bandwdith, bin number and channel number of profle and template
  freq_p=get_frequency(fprof);//??
  freq_t=get_frequency(ftmpl);//??
  bw_p=get_bw(fprof);//??
  bw_t=get_bw(ftmpl);//??
  nchan_p=get_nchan(fprof);//??
  nchan_t=get_nchan(ftmpl);//??
  nbin_p=get_nbin(fprof);//??
  nbin_t=get_nbin(ftmpl);//??
  DM_p=get_dm(fprof); //??
  DM_t=get_dm(ftmpl); //??

  double freq_sub[nchan_p];

  //Check if observational setting matches
  if(freq_p!=freq_t) 
    {
      //Return error in array?
      printf("Central frequencies of profile and template do not match.\n");
      exit(0);
    }
  if(bw_p!=bw_t)
    {
      //Return error in array?
      printf("Bandwidths of profile and template do not match.\n");
      exit(0);
    }
  if(nchan_p!=nchan_t)
    {
      //Return error in array? 
      printf("Channel numbers of profile and template do not match.\n");
      exit(0);
    }
  if(nbin_p!=nbin_t)
    {
      //Return error in array?
      printf("Bin numbers of profile and template do not match.\n");
      exit(0);
    }
  if(DM_p!=DM_t)
    {
      //Return error in array? 
      printf("DM values for preprocessing the profile and template are not the same.\n");
      printf("Modify the header to fix it.\n");
      exit(0);
    }

  //Get period at the MJD of the profile in second
  Pt=get_period(fprof); //??
  D_0=D*nbin/Pt;

  //Get frequency info for channels after scrunching
  freq_sub=get_frequency(); //??

  //Produce ASCII file for 2D template and profile
  //Called 2Dtmpl.tmp and 2Dprof.tmp
  //e.g.: sprintf(cmd,"pdv -Tp -t %s |awk '{if(($1)!=\"File:\") print $4}' > 2Dprof.tmp",filename);
  //      system(cmd);

  //Get phase offset (in unit of bin) and DM difference (in standard unit)
  tdfftfit_(&nchan_p,&nbin_p,&shift,&eshift,&dDM,&edDM,&D_0,freq_sub,&mfit);

  //Get TOA
  t0_f+=(shift_2D/nbin_p)*Pt/86400.0;
  if(t0_f>=1.0)
    {
      t0_f-=1.0;
      t0_i+=1;
    }
  if(t0_f<0.0)
    {
      t0_f+=1.0;
      t0_i-=1;
    }
  etoa=eshift/nbin_p*Pt*1.0e6;
  x=toa_f*1.0e15;
  sprintf(toa,"%i.%015lu",t0_i,x);

  //Get DM
  DM=DM_t+dDM;
  eDM=edDM;
}
