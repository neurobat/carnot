/***********************************************************************
 * This file is part of the CARNOT Blockset.
 * Copyright (c) 1998-2015, Solar-Institute Juelich of the FH Aachen.
 * Additional Copyright for this file see list auf authors.
 * All rights reserved.
 * Redistribution and use in source and binary forms, with or without 
 * modification, are permitted provided that the following conditions are 
 * met:
 * 1. Redistributions of source code must retain the above copyright notice, 
 *    this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright 
 *    notice, this list of conditions and the following disclaimer in the 
 *    documentation and/or other materials provided with the distribution.
 * 3. Neither the name of the copyright holder nor the names of its 
 *    contributors may be used to endorse or promote products derived from 
 *    this software without specific prior written permission.
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE 
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF 
 * THE POSSIBILITY OF SUCH DAMAGE.
 * $Revision$
 * $Author$
 * $Date$
 * $HeadURL$
 ***********************************************************************
 *  M O D E L    O R    F U N C T I O N
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * collector mex file for multi-input, single-output state-space system.
 *
 * This MEX-file performs the model of a flat plate collector based on a
 * model that includes thermal capacity of the collector, the incidence 
 * angle modifier.
 *
 *     Syntax  [sys, x0] = unicol(t,x,u,flag,x(1),x(2),x(3),x0)
 *
 * Author list
 *  Bernd Hafner -> hf
 *  Gaelle Faure -> gf
 *
 * Version  Author  Changes                                     Date
 * 3.1.0    hf      created                                     20dec2008
 * 4.1.0    hf      correction of ELongwave - sigma             15feb2009
 *                  (was ELongwave * sigma)
 * 4.1.1    gf      add call to mdlCheckParamter in             10fev11
 *                  mdlInitializeSizes
 * 4.1.2    hf      remove storing TOUT in RWork                31jan2012
 * 6.1.0    hf      name changed from coll12975uni.c            20oct2013
 *                  to solarcollector12975.c
 * 6.1.1    hf      access to Tini in mdlInitializeConditions   06sep2014
 * 6.1.2	aw		SimStateCompliance and						24jul2015
 *					upportsMultipleExecInstances
 *					enabled
 *					RWork replaced by DWork
 * 6.1.3    aw      unused functionmdlUpdate deleted            10sep2015
 * 6.1.4    pk      error in ELong = -100
 *                  used Tsky for longwave radiation            28sep2016
 * Copyright (c) Bernd Hafner 2008
 * 
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *  D E S C R I P T I O N
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * The energy-balance for every node is a differential equation:
 *
 *  mdot cp (Tout-Tin) /A = 
 *      F'(TauAlfa) Kdir Idir 
 *      + F'(TauAlfa) Kdfu Idfu 
 *      - c6 v_wind Iglb 
 *      - c1 (Tm-Tamb) 
 *      - c2 (Tm-Tamb)^2 
 *      - c3 v_wind (Tm-Ta) 
 *      + c4 (sigmaSB*(Tsky+273.15)^4 - sigmaSB*(Tamb+273.15)^4) 
 *      - c5 dTm/dt
 *
 * with the incidence angle modifier Kdir 
 *  Kdir: vector from 0 to 90 degree in 10 degree steps
 *
 *  symbol      used for                                                        unit
 *   bo         constant for the calculation of the incident angle modifier
 *   c1         heat loss coefficient at (Tm - Ta)=0                            Wm-2K-1
 *   c2         temperature dependence of the heat loss coefficient             Wm-2K-2
 *   c3         wind speed dependence of the heat loss coefficient              Jm-3K-1
 *   c4         sky temperature dependence of the heat loss coefficient         Wm-2K-1
 *   c5         effective thermal capacity                                      J m-2K-1
 *   c6         wind dependence in the zero loss efficiency                     sm-1 
 *   F'         collector efficiency factor
 *   TauAlfa    effective transmittance-absorptance product for direct solar radiation at normal incidence
 *   teta       incidence angle of the direct radiation on the collecor         radian
 *   Tm         temperature of the collector node                               degree C
 *   Tamb       ambient temperature                                             degree C
 *   v_wind     wind velocity                                                   m/s 
 *   Tsky       Sky temperature                                                 W/m^2
 *   Iglb       global solar radiation                                          W/m^2
 *   Idir       direct solar radiation                                          W/m^2
 *   Idfu       diffuse solar radiation                                         W/m^2
 *   sigmaSB    Stefan-Boltzmann constant 5.67e-8                               W/m^2/K^4
 *         
 * structure of u (input vector)
 * port 0:
 * index use
 * 0    direct solar radiation                  W/m^2
 * 1    diffuse solar radiation                 W/m^2
 * 2    longwave sky radiation                  W/m^2
 * 3    incidence angle direct radiation        radian
 * 4    ambient temperature                     degree centigrade
 * 5    mean wind veloctiy                      m/s
 *
 * port 1:
 * 0    temperature at collector inlet          degree centigrade
 * port 2:
 * 0    massflow                                kg/s
 * port 3:
 * 0    pressure                                Pa  
 * 1    fluid ID (defined in CARNOT.h)                 
 * 2    mixture  (defined in CARNOT.h)
 *
 *
 * structure of y (output vector)
 *  port    use
 *  0       collector outlet temperature        degree centigrade
 *  1       average temperature                 degree centigrade
 *  2       instentaneous power of collector    W
 */

/*
 * The following #define is used to specify the name of this S-Function.
 */

#define S_FUNCTION_LEVEL 2
#define S_FUNCTION_NAME solarcollector12975

/*
 * need to include simstruc.h for the definition of the SimStruct and
 * its associated macro definitions.
 */

#include "tmwtypes.h"
#include "simstruc.h"
#include "carlib.h"
#include <math.h>

/*
 *   #defines for easy access to the parameters
 */
#define A_COLL  *mxGetPr(ssGetSFcnParam(S, 0)) /* absorber surface area:  Acoll    */
#define C1      *mxGetPr(ssGetSFcnParam(S, 1)) /* c1 : heat loss coefficient at (Tm-Ta)=0  [W/(m²*K)]   */
#define C2      *mxGetPr(ssGetSFcnParam(S, 2)) /* c2: temperature dependence of the heat loss coefficient [W/(m*K)²]   */
#define C3      *mxGetPr(ssGetSFcnParam(S, 3)) /* c3 : wind speed dependence of the heat loss coefficient [J/(m³K)]   */
#define C4      *mxGetPr(ssGetSFcnParam(S, 4)) /* c4 : sky temperature dependence of the heat loss coefficient [W/(m²K)]   */
#define C5      *mxGetPr(ssGetSFcnParam(S, 5)) /* c5 : effective thermal capacity [J/(m²K)]   */
#define C6      *mxGetPr(ssGetSFcnParam(S, 6)) /* c6 : wind dependence in the zero loss efficiency [s/m]   */
#define T_INIT  *mxGetPr(ssGetSFcnParam(S, 7)) /* initial temperature       */
#define N_PARAMETER                        8

#define POWER       dwork_power[0]
                             
#define QSOLAR     (*u0[0])  /* absorbed solar radiation */
#define IGLB       (*u0[1])  /* global radiation   */
#define TAMB       (*u0[2])  /* ambient temperature */
#define VWIND      (*u0[3])  /* wind velocity */
#define TSKY      (*u0[4])  /* sky temperature longwave radiation */
#define NINPUT1         5

#define TIN        (*u1[0])  /* inlet temperature */
#define NINPUT2         1
#define MDOT       (*u2[0])  /* massflow */
#define NINPUT3         1
#define PRESS      (*u3[0])  /* pressure */
#define FLUID_ID   (*u3[1])  /* fluid ID (defined in carlib.h) */
#define PERCENTAGE (*u3[2])  /* mixture  (defined in carlib.h) */
#define NINPUT4         3


#define MDL_CHECK_PARAMETERS
#if defined(MDL_CHECK_PARAMETERS) && defined(MATLAB_MEX_FILE)
  /* Function: mdlCheckParameters =============================================
   * Abstract:
   *    Validate our parameters to verify they are okay.
   */
  static void mdlCheckParameters(SimStruct *S)
  {
      /* */
      {
          if (A_COLL < 1.0e-3) {
              ssSetErrorStatus(S,"Error in solar collector: surface must be > 0");
              return;
          }
      }
      /* */
      {
          if (C5 < 1.0e-3) {
              ssSetErrorStatus(S,"Error in solar collector: heat capacity c5 must be > 0");
              return;
          }
      }
  }
#endif /* MDL_CHECK_PARAMETERS */
 

/* Function: mdlInitializeSizes ===============================================
 * Abstract:
 *   Setup sizes of the various vectors.
 */
static void mdlInitializeSizes(SimStruct *S)
{
    ssSetNumSFcnParams(S, N_PARAMETER);  /* Number of expected parameters */
#if defined(MATLAB_MEX_FILE)
    if (ssGetNumSFcnParams(S) == ssGetSFcnParamsCount(S)) {
        mdlCheckParameters(S);
        if(ssGetErrorStatus(S) != NULL) return;
    } else {
        /* Return if number of expected != number of actual parameters */
        return;
    }
#endif


    ssSetNumContStates(S, 1);
    ssSetNumDiscStates(S, 0);

    if (!ssSetNumInputPorts(S, 4)) return;
    ssSetInputPortWidth(S, 0, NINPUT1);
    ssSetInputPortDirectFeedThrough(S, 0, 0);

    ssSetInputPortWidth(S, 1, NINPUT2);
    ssSetInputPortDirectFeedThrough(S, 1, 1);

    ssSetInputPortWidth(S, 2, NINPUT3);
    ssSetInputPortDirectFeedThrough(S, 2, 1);

    ssSetInputPortWidth(S, 3, NINPUT4);
    ssSetInputPortDirectFeedThrough(S, 3, 0);

    if (!ssSetNumOutputPorts(S, 3)) return;
    ssSetOutputPortWidth(S, 0, 1);
    ssSetOutputPortWidth(S, 1, 1);
    ssSetOutputPortWidth(S, 2, 1);

    ssSetNumSampleTimes(S, 1);
    ssSetNumRWork(S, 0);
    ssSetNumIWork(S, 0);
    ssSetNumPWork(S, 0);
    ssSetNumDWork(S, 1);
    ssSetDWorkWidth(S, 0, 1);
    ssSetDWorkDataType(S, 0, SS_DOUBLE);
    ssSetDWorkName(S, 0, "DWORK_POWER");
    ssSetDWorkUsageType(S, 0, SS_DWORK_USED_AS_DSTATE);
    
    ssSetNumModes(S, 0);
    ssSetNumNonsampledZCs(S, 0);

	ssSetSimStateCompliance(S, USE_DEFAULT_SIM_STATE);
    ssSetSimStateVisibility(S, 1);
    
    ssSupportsMultipleExecInstances(S, true);
	
#ifdef EXCEPTION_FREE_CODE
    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE);
#endif
}


/*
 * mdlInitializeSampleTimes - initialize the sample times array
 *
 * This function is used to specify the sample time(s) for your S-function.
 * If your S-function is continuous, you must specify a sample time of 0.0.
 * Sample times must be registered in ascending order.
 */
static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, CONTINUOUS_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, 0.0);
}


#define MDL_INITIALIZE_CONDITIONS   /* Change to #undef to remove function */
/*
 * mdlInitializeConditions - initialize the states
 *
 * In this function, you should initialize the continuous and discrete
 * states for your S-function block.  The initial states are placed
 * in the x0 variable.  You can also perform any other initialization
 * activities that your S-function may require.
 */
#if defined(MDL_INITIALIZE_CONDITIONS)
  static void mdlInitializeConditions(SimStruct *S)
  {
    real_T *tmean = ssGetContStates(S);
    real_T t0  = T_INIT;       /* initial temperature */
    real_T *dwork_power   = ssGetDWork(S, 0);

    tmean[0] = t0;	        /* collector temperature set to Tinit */
	POWER = (real_T)0.0;    /* power initalized with 0 */
  }
#endif /* MDL_INITIALIZE_CONDITIONS */


/*
 * mdlOutputs - compute the outputs
 *
 * In this function, you compute the outputs of your S-function
 * block.  The outputs are placed in the y variable.
 */
static void mdlOutputs(SimStruct *S, int_T tid)
{
    InputRealPtrsType u1  = ssGetInputPortRealSignalPtrs(S,1);
    real_T *tout    = ssGetOutputPortRealSignal(S,0);
    real_T *tm      = ssGetOutputPortRealSignal(S,1);
    real_T *qdot    = ssGetOutputPortRealSignal(S,2);
    real_T *tmean   = ssGetContStates(S);
    real_T *dwork_power   = ssGetDWork(S, 0);

    tout[0] = (2.0*tmean[0])-TIN;   /* outlet temperature  */
    tm[0] = tmean[0];               /* average temperature */
    qdot[0] = POWER;                /* power of collector */
} /* end mdlOutputs */


#define MDL_DERIVATIVES
/* Function: mdlDerivatives =================================================
 * Abstract:
 *      xdot = Ax + Bu
 */
static void mdlDerivatives(SimStruct *S)
{
    real_T *dTmdt = ssGetdX(S);
    real_T *tmean = ssGetContStates(S);
    real_T *dwork_power = ssGetDWork(S, 0);

    InputRealPtrsType u0  = ssGetInputPortRealSignalPtrs(S,0);
    InputRealPtrsType u1  = ssGetInputPortRealSignalPtrs(S,1);
    InputRealPtrsType u2  = ssGetInputPortRealSignalPtrs(S,2);
    InputRealPtrsType u3  = ssGetInputPortRealSignalPtrs(S,3);

    real_T cp;    
    real_T tdiff;

    /*  dTm/dt = 1/c5 *(
     *      F'(TauAlfa) Kdir Idir + F'(TauAlfa) Kdfu Idfu 
     *      - c1 (Tm-Tamb) - c2 (Tm-Tamb)^2 
     *      - c3 v_wind (Tm-Ta) - c6 v_wind Iglb 
     *      + c4 (sigmaSB*(Tsky+273.15)^4 - sigmaSB*(Tamb+273.15)^4) 
     *      - mdot cp (Tout-Tin) /A )
     *
     *  Tm = 0.5*(Tout+Tin)
     *
     *  -> Tout = 2*Tm - Tin
     */

    cp = heat_capacity(FLUID_ID, PERCENTAGE, TIN, PRESS);
    tdiff = (tmean[0] -TAMB);           /* difference between mean collector temperature and ambient */
	POWER = 2.0*MDOT*cp*(tmean[0] - TIN);

    dTmdt[0] = (QSOLAR - tdiff *(C1 + C2*tdiff)
        - VWIND * (C3*tdiff + C6*IGLB)
        + C4 * STEFAN_BOLTZMANN *(square(square(TSKY + 273.15)) -  square(square(TAMB + 273.15)))
        - POWER/A_COLL) / C5;
	
}


/*
 * mdlTerminate - called when the simulation is terminated.
 *
 * In this function, you should perform any actions that are necessary
 * at the termination of a simulation.  For example, if memory was allocated
 * in mdlInitializeConditions, this is the place to free it.
 */

static void mdlTerminate(SimStruct *S)
{}       /* NOP */



#ifdef   MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif

