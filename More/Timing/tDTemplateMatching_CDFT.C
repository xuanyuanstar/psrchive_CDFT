/***************************************************************************
 *
 *   Copyright (C) 2009 by Willem van Straten
 *   Licensed under the Academic Free License version 2.1
 *
 ***************************************************************************/

#include "Pulsar/tDTemplateMatching_CDFT.h"
#include "Pulsar/PulsarCalibrator.h"
#include "Pulsar/PolnProfileFit.h"
#include "Pulsar/Profile.h"
#include "Pulsar/Archive.h"
#include "Pulsar/Integration.h"

extern "C" void tdfftfit_(int *nchan,int *nbins,double *shift,double *eshift,double *dDM,double *edDM,double *D_0,double *freq,int *mfit, char *proftmp, char *tmpltmp, double *obs_wt_sub);

using namespace std;

Pulsar::tDTemplateMatching_CDFT::tDTemplateMatching_CDFT ()
{
  fs = 1;
  dmfit = 0;
}

Pulsar::tDTemplateMatching_CDFT::~tDTemplateMatching_CDFT ()
{

}

//! Set the frequency scrunch factor in preprocess
void Pulsar::tDTemplateMatching_CDFT::set_fscrunch_factor (unsigned fsfac)
{
  fs = fsfac;
}

//! Set if dm fit included
void Pulsar::tDTemplateMatching_CDFT::set_dmfit (unsigned dmsign)
{
  dmfit = dmsign;
}

//! Fequency scrunch before opertaion
void Pulsar::tDTemplateMatching_CDFT::preprocess (Archive* archive)
{
  archive->dedisperse();
  archive->fscrunch (fs);
  archive->pscrunch ();
  archive->remove_baseline ();
}

void Pulsar::tDTemplateMatching_CDFT::set_standard (const Archive* archive)
{
  standard = archive;
  std_freq = standard->get_centre_frequency();
  std_bw = standard->get_bandwidth();
  std_dm = standard->get_dispersion_measure();
  std_nbin = standard->get_nbin();
  std_nchan = standard->get_nchan();
  std_nsub = standard->get_nsubint();
}

//! Set the observation from which the arrival times will be derived
void Pulsar::tDTemplateMatching_CDFT::set_observation (const Archive* archive)
{
  observation = archive;
  obs_freq = observation->get_centre_frequency();
  obs_bw = observation->get_bandwidth();
  obs_dm = observation->get_dispersion_measure();  
  obs_nbin = observation->get_nbin();
  obs_nchan = observation->get_nchan();
}

//! get the arrival times for the specified sub-integration
void Pulsar::tDTemplateMatching_CDFT::get_toas (unsigned isub,
						std::vector<Tempo::toa>& toas)
{  
  ofstream outprof,outtmpl,outdm;
  const Integration* integration = observation->get_Integration (isub);
  const Integration* tmpl = standard->get_Integration (0);
  int mfit,nchan_s,nbin_s;
  double D,D0,Pt,obs_freq_sub[obs_nchan],obs_wt_sub[obs_nchan],offs,eoffs,dDM,edDM;
  unsigned i,j,nchan_eff;
  time_t t;
  int seq;
  char proftmp[22],tmpltmp[22],dmfile[16];
  MJD epoch = integration->get_epoch();

  //! Check if observing settings match
  if (obs_freq != std_freq)
    cout << "Warning: Central frequencies of profile and template do not match." << endl;
  if(obs_bw!=std_bw)
    {
      cout << "Bandwidths of profile and template do not match." << endl;
      exit(0);
    }
  if(obs_nchan!=std_nchan)
    {
      cout << "Channel numbers of profile and template do not match." << endl;
      exit(0);
    }
  if(obs_nbin!=std_nbin)
    {
      cout << "Bin numbers of profile and template do not match." << endl;
      exit(0);
    }
  if(obs_dm!=std_dm)
    {
      cerr << "Warning: DM values for preprocessing the profile and template are not the same." << endl;
    }
  if(std_nsub>1)
    {
      cout << "Warning: More than one subint in the template file. Use the first for fitting." << endl;
    }

  D = 1.0/2.41e-4; //Dispersion constant 
  Pt = integration->get_folding_period(); //Get period
  D0 = D*obs_nbin/Pt;

  //! Get central frequency of each channel, when weight not zero
  nchan_eff = 0; 
  for (i=0; i<obs_nchan; i++)
    {
      if(observation->get_Integration(isub)->get_weight(i))
	{
	  obs_freq_sub[nchan_eff]=integration->get_centre_frequency(i);
	  obs_wt_sub[nchan_eff]=observation->get_Integration(isub)->get_weight(i);
	  nchan_eff++;
	  //printf("%u %u %f\n",isub,i,obs_wt_sub[nchan_eff-1]);
	}
    }
  if(nchan_eff == 0) return

  //! Write profile and template to tmp files
  srand((unsigned) time(&t));
  seq = rand();
  if (dmfit)
    sprintf(dmfile,"dm_cdft.txt");
  sprintf(proftmp,"2Dprof.tmp.%010d",seq);
  sprintf(tmpltmp,"2Dtmpl.tmp.%010d",seq);
  outprof.open(proftmp, ios::out);
  outtmpl.open(tmpltmp, ios::out);
  for(i=0; i<obs_nchan; i++)
    {
      if(observation->get_Integration(isub)->get_weight(i))
	{
	  const float* iprof = integration->get_Profile(0,i)->get_amps();
	  const float* itmpl = tmpl->get_Profile(0,i)->get_amps();
	  for(j=0; j<obs_nbin; j++)
	    {
	      outprof << iprof[j] << "\n";
	      outtmpl << itmpl[j] << "\n";
	    }
	}
    }
  outprof.close();
  outtmpl.close(); 

  //! Number of parameters in fit
  mfit = nchan_eff + 1 + dmfit;

  //! Get phase shift and error in unit of bin
  nchan_s = (int)nchan_eff;
  nbin_s = (int)obs_nbin;
  tdfftfit_(&nchan_s,&nbin_s,&offs,&eoffs,&dDM,&edDM,&D0,obs_freq_sub,&mfit,proftmp,tmpltmp,obs_wt_sub);

  //! Pass to shift and dm (if) vector
  Estimate<double> shift = Estimate<double> (offs/obs_nbin, eoffs/obs_nbin*eoffs/obs_nbin);
  if (dmfit) {
    outdm.open(dmfile, ios::app);
    outdm << observation->get_filename() << " " << isub << " "
	 << epoch.printdays(20) << " "
	 << dDM << " "
	 << edDM << endl;
  }
  outdm.close();

  //! Get TOA
  Tempo::toa TOA = get_toa (shift, integration, 0);

  toas.push_back( TOA );

  //! Clean tmp files
  remove(proftmp);
  remove(tmpltmp);
}
