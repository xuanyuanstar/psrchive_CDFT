//-*-C++-*-
/***************************************************************************
 *
 *   Copyright (C) 2009 by Willem van Straten
 *   Licensed under the Academic Free License version 2.1
 *
 ***************************************************************************/

/* $Source: /cvsroot/psrchive/psrchive/More/Timing/Pulsar/MatrixTemplateMatching.h,v $
   $Revision: 1.2 $
   $Date: 2009/10/02 03:40:50 $
   $Author: straten $ */

#ifndef __Pulsar_tDTemplateMatching_CDFT_h
#define __Pulsar_tDTemplateMatching_CDFT_h

#include "Pulsar/ArrivalTime.h"

namespace Pulsar {

  //! Estimates phase shift in Fourier domain using 2D cdft template matching
  class tDTemplateMatching_CDFT : public ArrivalTime
  {

  public:

    tDTemplateMatching_CDFT ();
    ~tDTemplateMatching_CDFT ();

    //! Set the frequency scrunch factor in preprocess     
    void set_fscrunch_factor (unsigned fsfac);

    //! Set dm fit sign
    void set_dmfit (unsigned dmfit);

    //! Preprocess before TOA calculation
    void preprocess (Archive* archive);

    //! Set the observation from which the arrival times will be derived
    void set_observation (const Archive*);

    //! Set the standard/template to which observation will be matched
    void set_standard (const Archive*);

  protected:

    //! Get the arrival times for the specified sub-integration
    void get_toas (unsigned subint, std::vector<Tempo::toa>& toas);

  private:

    //! Fscrunch factor and dm fit sign
    unsigned fs,dmfit,std_nbin,std_nchan,obs_nbin,obs_nchan,std_nsub;
    double std_freq,std_bw,std_dm,obs_freq,obs_bw,obs_dm;
  };

}


#endif
