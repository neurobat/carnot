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
 *
 * The model of an unglazed flat plate collector is based on a
 * model that includes thermal capacity of the collector, the incidence 
 * angle modifier.
 *
 * author list:     gf -> Gaelle Faure
 *                  hf -> Bernd Hafner
 *                  rd -> Ralf Dott
 * Copyright (c) Solar-Institut Juelich and the authors, all Rights Reserved
 *
 * version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
 * Version  Author  Changes                                     Date
 * 0.1.0    gf      created with uni_coll.c base                03dec2010
 * 5.1.0    gf      corrected condensation model                12oct2012
 * 5.2.0    rd      parameters in psTdew and r corrected        04nov2012
 *          hf      model parameters comments                   09nov2012
 *                  corrected heat transfer calculation
 * 5.2.1    hf      qdotback removed, renamed parameter uback   10nov2012
 *                  to uc1_eta0 (= c6 in EN12975)
 *          hf      abs changed to fabs                         14nov2012
 * 6.1.0    hf      Name changed to solarcollector_unglazed.c   20oct2013
 *                  from coll_unglazed.c .
 *                  Input changed from water content to relative
 *                  humidity (as defined in weather data bus).
 * 6.1.1	aw		SimStateCompliance and						24jul2015
 *					SupportsMultipleExecInstances
 *					enabled
 * 6.1.2    aw      implicit casts replaced by explicit         10sep2015
 *                  casts
 *
 *
 * The collector is devided into two thermal nodes :
 * + one representing the absorber,
 * + one representing the fluid.
 *
 * The absorber's node is devided into "NODES" nodes (NODES>=2).
 * The energy-balance for every node is a differential equation:
 *
 * c_abs * dTp/dt   =  qdot_solar - qdot_conv
 *                          - qdot_cond - qdot_sky - qdot_fluid
 *
 * qdot_solar = absorbed_solar_radiation - uc1_eta0*Iglb*vwind
 *
 * qdot_conv = qdot_conv_gain + qdot_conv_loss
 *      qdot_conv_gain = fconv * (Uc0_gain + Uc1_gain * vwind) * 
 *                          (Tplast + fconv * (Tp - Tplast) - Tamb)
 *      qdot_conv_loss = (1 - fconv) * (Uc0_loss + Uc1_loss * vwind) * 
 *                          (Tpo + fconv * (Tp - Tpo) - Tamb)
 *
 * qdot_cond = fcond * (Uc0_cond + Uc1_cond * vwind) * Ccond
 *             * (ps(Tdew) - ps(Tp_cond))
 *
 * qdot_sky = epsilon * sigma * (Tp^4 - Tsky^4)
 *
 * qdot_fluid = hi * (Tp - Tf)
 *
 * where :
 * * fconv = ( min( Tpo , max(Tamb,Tplast) ) - Tplast ) / ( Tpo - Tplast )
 * * fcond = ( min( Tpo , max(Tdew,Tplast) ) - Tplast ) / ( Tpo - Tplast )
 * * Tp_cond = Tplast + fcond * ( Tp - Tplast )
 * * Tpo = 2*Tp - Tplast
 *
 *
 * The fluid's node is devided into "NODES" nodes.
 * The energy-balance for every node is a differential equation:
 *
 * c_fluid * dTf/dt    = hi * (Tp - Tf)
 *                  + mdot * cp / Acoll * (Tlastnode - Tnode)
 *
 *  symbol      used for                                    unit
 *  Acoll       absorber surface area                       m^2
 *  Ccond       coefficient for pression in temperature 
 *              conversion                                  K/Pa
 *  cp          heat capacity of fluid                      J/(kg*K)
 *  c_abs       heat capacity of absorber per surface       J/(m^2*K)
 *  c_fluid     heat capacity of fluid per surface          J/(m^2*K)
 *  epsilon     effective emission coefficient of the 
 *              absorber surface                            -
 *  fcond       share of the collector aperture area where
 *              condensation takes place                    -
 *  fconv       share of the collector aperture area where
 *              convection takes place                      -
 *  hi          heat transfer coefficent between absorber 
                and fluid                                   W/(m^2*K)
 *  mdot        mass flow rate                              kg/s
 *  ps          satured vapour pressure of water            Pa
 *  qdot_solar  power input per surface from sun            W/m^2
 *  sigma       Stefan-Boltzmann constant                   W/(m^2*K^4)
 *  Tamb        ambient temperature                         K
 *  Tdew        dew point temperature                       K
 *  Tf          fluid temperature                           K
 *  Tp          absorber temperature                        K
 *  t           time                                        s
 *  uc1_eta0    wind dependance in optical efficiency       W/(m^2*m/s)
 *  Uc0_cond    wind speed independant part of the 
 *              condensatin heat transfer coefficient       W/(m^2*Pa)
 *  Uc1_cond    wind speed dependant part of the 
 *              convection heat transfer coefficient        W/((m/s)*m^2*Pa)
 *  Uc0_gain    wind speed independant part of the 
 *              heat transfer coefficientfor the convective
 *              gains                                       W/(m^2*K)
 *  Uc1_gain    wind speed dependant part of the 
 *              heat transfer coefficientfor the convective
 *              gains                                       W/((m/s)*m^2*K)
 *  Uc0_loss    wind speed independant part of the 
 *              heat transfer coefficientfor the convective
 *              losse                                       W/(m^2*K)
 *  Uc1_loss    wind speed dependant part of the 
 *              heat transfer coefficientfor the convective
 *              losses                                      W/((m/s)*m^2*K)
 *  vwind       velocity of wind                            m/s
 *         
 * structure of u (input vector)
 * port 0:
 * index use
 * 0    direct solar radiation                  W/m^2
 * 1    diffuse solar radiation                 W/m^2
 * 2    ambient temperature                     degree centigrade
 * 3    sky temperature                         degree centigrade
 * 4    portion of water                        -
 * 5    station presure                         Pa
 * 5    mean wind speed                         m/s
 *
 * port 1:
 * 0    qdot_solar                              W/m^2
 *
 * port 2:
 * 0    temperature at collector inlet          degree centigrade
 * 1    massflow                                kg/s
 * 2    pressure                                Pa  
 * 3    fluid ID (defined in CARNOT.h)                 
 * 4    mixture  (defined in CARNOT.h)
 *
 * port 3:
 * 0    collector slope    (in degree)
 * 1    collector azimuth   (in degree)
 * 2    collector rotation   (in degree)
 *
 *
 * structure of y (output vector)
 *  port    use
 *  0       solar fluid outlet temperature      degree Celsius
 *  1   0   temperature absorber node 1         degree Celsius
 *      1   temperature absorber node 2         degree Celsius
 *      N   temperature absorber node N         degree Celsius
 *  2   0   temperature fluid node 1            degree Celsius
 *      1   temperature fluid node 2            degree Celsius
 *      N   temperature fluid node N            degree Celsius
 *
 * Literature: 
 *  Frank, Elimar: Modellierung unabgedeckter Kollektoren, Dissertation Uni Kassel, 2007
 *  Vajen, Klaus; Frank, Elimar: Unverglaste Kollektoren, OTTI Solarthermie, 2009
 */

/*
 * The following #define is used to specify the name of this S-Function.
 */

#define S_FUNCTION_LEVEL 2
#define S_FUNCTION_NAME solarcollector_unglazed

/*
 * need to include simstruc.h for the definition of the SimStruct and
 * its associated macro definitions.
 */

#include "tmwtypes.h"
#include "simstruc.h"
#include "carlib.h"
#include <math.h>

/*#defines for easy access to the parameters */
#define A_COLL   *mxGetPr(ssGetSFcnParam(S, 0)) /* absorber surface area:  Acoll        */
#define UC0_COND *mxGetPr(ssGetSFcnParam(S, 1)) /* linear coefficient  for condensation */
#define UC1_COND *mxGetPr(ssGetSFcnParam(S, 2)) /* quadratic loss coefficient           */
#define UC0LOSS  *mxGetPr(ssGetSFcnParam(S, 3)) /* linear loss coefficient              */
#define UC1LOSS  *mxGetPr(ssGetSFcnParam(S, 4)) /* quadratic loss coefficient           */
#define UC0GAIN  *mxGetPr(ssGetSFcnParam(S, 5)) /* linear loss coefficient              */
#define UC1GAIN  *mxGetPr(ssGetSFcnParam(S, 6)) /* quadratic loss coefficient           */
#define ESKY     *mxGetPr(ssGetSFcnParam(S, 7)) /* effective emission coefficient of the absorber surface  */
#define UC1ETA0  *mxGetPr(ssGetSFcnParam(S, 8)) /* wind dependance in eta0 */
#define HI       *mxGetPr(ssGetSFcnParam(S, 9)) /* heat transfer coefficent between absorber and fluid  */
#define INV_C_ABS *mxGetPr(ssGetSFcnParam(S,10)) /* heat capacity of collector           */
#define INV_C_FL *mxGetPr(ssGetSFcnParam(S,11)) /* heat capacity of fluid               */
#define LENGTH   *mxGetPr(ssGetSFcnParam(S,12)) /* length between inlet and outlet      */
#define T_INIT   *mxGetPr(ssGetSFcnParam(S,13)) /* initial temperature                  */
#define NODES    *mxGetPr(ssGetSFcnParam(S,14)) /* number of nodes                      */
#define N_PARAMETER                        15

#define Ta(n)      x[n]      /* absorber node temperature */
#define DTaDT(n)  dx[n]
#define Tf(n)      x[n+nodes]/* fluid node temperature */
#define DTfDT(n)  dx[n+nodes]
                             
#define IDIR       (*u0[0])  /* direct radiation */
#define IDFU       (*u0[1])  /* diffuse radiation */
#define TAMB       (*u0[2])  /* ambient temperature */
#define TSKY       (*u0[3])  /* sky temperature */
#define RELHUM     (*u0[4])  /* relative humidity */
#define PSTATION   (*u0[5])  /* station pressure */
#define VWIND      (*u0[6])  /* wind speed */
#define NINPUT0         7

#define QDOTSOLAR  (*u1[0])  /* energy flux through transparent cover */
#define NINPUT1         1

#define TIN        (*u2[0])  /* inlet temperature */
#define MDOT       (*u2[1])  /* massflow */
#define PRESS      (*u2[2])  /* pressure */
#define FLUID_ID   (*u2[3])  /* fluid ID (defined in carlib.h) */
#define PERCENTAGE (*u2[4])  /* mixture  (defined in carlib.h) */
#define NINPUT2         5

#define LE          0.845    /* Lewis number for Ccond calculus */


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
          if (UC0_COND < 0.0) {
              ssSetErrorStatus(S,"Error in solar collector: loss coefficient must be >= 0");
              return;
          }
      }
      /* */
      {
          if (UC1_COND < 0.0) {
              ssSetErrorStatus(S,"Error in solar collector: wind loss coefficient must be >= 0");
              return;
          }
      }
      /* */
      {
          if (UC0LOSS < 0.0) {
              ssSetErrorStatus(S,"Error in solar collector: loss coefficient for convection losses must be >= 0");
              return;
          }
      }
            /* */
      {
          if (UC1LOSS < 0.0) {
              ssSetErrorStatus(S,"Error in solar collector: wind loss coefficient for convection losses must be >= 0");
              return;
          }
      }
      /* */
      {
          if (UC0GAIN < 0.0) {
              ssSetErrorStatus(S,"Error in solar collector: loss coefficient for convection gains must be >= 0");
              return;
          }
      }
      /* */
            {
          if (UC1GAIN < 0.0) {
              ssSetErrorStatus(S,"Error in solar collector: wind loss coefficient for convection gains must be >= 0");
              return;
          }
      }
      /* */
            {
          if (ESKY < 0.0 || ESKY > 1.0) {
              ssSetErrorStatus(S,"Error in solar collector: effective emission coefficient of the absorber must be between 0 and 1");
              return;
          }
      }
      /* */
            {
          if (HI < 0.0) {
              ssSetErrorStatus(S,"Error in solar collector: heat transfer coefficent between absorber and fluid must be >= 0");
              return;
          }
      }
      /* */
            {
          if (UC1ETA0 < 0.0) {
              ssSetErrorStatus(S,"Error in solar collector: wind loss dependancy must be >= 0");
              return;
          }
      }
      /* */
            {
          if (LENGTH < 0.0) {
              ssSetErrorStatus(S,"Error in solar collector: length between inlet and outlet must be >= 0");
              return;
          }
      }
      /* */
      {
          if (NODES < 2.0) {
              ssSetErrorStatus(S,"Error in solar collector: number of nodes must be >= 2");
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
    int_T  nodes  = (int_T)NODES;
    
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

    ssSetNumContStates(S, 2*nodes);
    ssSetNumDiscStates(S, 0);

    if (!ssSetNumInputPorts(S, 3)) return;
    ssSetInputPortWidth(S, 0, NINPUT0);
    ssSetInputPortDirectFeedThrough(S, 0, 0);
    ssSetInputPortWidth(S, 1, NINPUT1);
    ssSetInputPortDirectFeedThrough(S, 1, 0);
    ssSetInputPortWidth(S, 2, NINPUT2);
    ssSetInputPortDirectFeedThrough(S, 2, 0);

    if (!ssSetNumOutputPorts(S, 3)) return;
    ssSetOutputPortWidth(S, 0, 1);
    ssSetOutputPortWidth(S, 1, nodes);
    ssSetOutputPortWidth(S, 2, nodes);

    ssSetNumSampleTimes(S, 1);
    ssSetNumRWork(S, 0);
    ssSetNumIWork(S, 0);
    ssSetNumPWork(S, 0);
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
    real_T *x = ssGetContStates(S);
    real_T t0 = T_INIT;       /* initial temperature */
    int_T  nodes  = (int_T)NODES;
    int_T  n;

    for (n = 0; n < nodes; n++) 
    {
        Ta(n) = t0;
        Tf(n) = t0;
    }
}
#endif /* MDL_INITIALIZE_CONDITIONS */


/*
 * mdlOutputs - compute the outputs
 */
static void mdlOutputs(SimStruct *S, int_T tid)
{
    real_T *y0 = ssGetOutputPortRealSignal(S,0);
    real_T *y1 = ssGetOutputPortRealSignal(S,1);
    real_T *y2 = ssGetOutputPortRealSignal(S,2);
    real_T *x  = ssGetContStates(S);
    int_T  nodes  = (int)NODES;
    int_T  n;

    /* outlet temperature */
    y0[0] = Tf(nodes-1);   /* temperature of the last node of the fluid  */

    /* fluid temperature and absorber temperature */
    for (n = 0; n < nodes; n++)
    {
        y1[n] = Ta(n);
        y2[n] = Tf(n);
    }
}


#define MDL_DERIVATIVES
/* Function: mdlDerivatives =================================================
 * Abstract:
 *      xdot = Ax + Bu
 */
static void mdlDerivatives(SimStruct *S)
{
    real_T *dx = ssGetdX(S);
    real_T *x  = ssGetContStates(S);

    InputRealPtrsType u0  = ssGetInputPortRealSignalPtrs(S,0);
    InputRealPtrsType u1  = ssGetInputPortRealSignalPtrs(S,1);
    InputRealPtrsType u2  = ssGetInputPortRealSignalPtrs(S,2);

    real_T acoll = A_COLL;
    real_T uc0cond = UC0_COND;
    real_T uc1cond = UC1_COND;
    real_T uc0gain = UC0GAIN;
    real_T uc1gain = UC1GAIN;
    real_T uc0loss = UC0LOSS;
    real_T uc1loss = UC1LOSS;
    real_T epsilon = ESKY;
    real_T uc1eta0 = UC1ETA0;
    real_T invcapabs = INV_C_ABS;
    real_T invcapfl = INV_C_FL;
    real_T hi = HI;
    real_T ccond, r, cp_air;
    real_T Taprec, Tasuiv, Tacond, cp, flow, Tfprec, fcond, fconv;
    real_T ugain, uloss, ucond, Tdew, psTacond, psTdew, xwater;
    // real_T b;
    int    nodes = (int)NODES;
    int    n;
    
    cp = heat_capacity(FLUID_ID, PERCENTAGE, TIN, PRESS);
    xwater = relativeHumidity2waterContent(TIN, PSTATION, RELHUM);
    Tdew = saturationtemperature((double)AIR, xwater, TAMB, PSTATION); // dew point
    psTdew = vapourpressure((double)WATER, 0.0, Tdew, 1.0); // independent of pressure
    r = evaporation_enthalpy(1,0,TAMB,PSTATION); 
    cp_air = heat_capacity((double)AIR,xwater,TAMB,PSTATION);
    ccond = RGRD*r/(PSTATION*cp_air)*pow(LE,-0.66);
    
	if (MDOT > 0.0)		// if there is a massflow
	    Tfprec = TIN;	// take inlet temperature
	else				// else 
		Tfprec = Tf(0);	// take node temperature
    Taprec = Ta(0);
    
    flow = MDOT * cp * nodes/acoll;
    ugain = uc0gain + uc1gain * VWIND;
    uloss = uc0loss + uc1loss * VWIND;
    ucond = uc0cond + uc1cond * VWIND;
    
    for (n = 0; n < nodes; n++)
    {
        Tasuiv = 2*Ta(n) - Taprec;

        // if (Taprec > Tasuiv)
        //     ssPrintf("Taprec > Tasuiv\n");
        
        if (fabs(Tasuiv - Taprec) < 1e-6) {
            //  ssPrintf("abs(Tasuiv - Taprec) < 1e-6\n");
            if (Tasuiv < TAMB && Taprec < TAMB) {
                fconv = 1.0;
            } else if (Tasuiv > TAMB && Taprec > TAMB) {
                fconv = 0.0;
            } else {
                fconv = 0.5;
            }
            
            if (Tasuiv < Tdew && Taprec < Tdew) {
                fcond = 1.0;
            } else if (Tasuiv > Tdew && Taprec > Tdew) {
                fcond = 0.0;
            } else {
                fcond = 0.5;
            }
            
        } else {
            if (Tasuiv >= Taprec) {
                fconv = ( min( Tasuiv , max(TAMB, Taprec) ) - Taprec ) / ( Tasuiv - Taprec );
                fcond = ( min( Tasuiv , max(Tdew, Taprec) ) - Taprec ) / ( Tasuiv - Taprec );
            } else {
                fconv = ( min( Taprec , max(TAMB, Tasuiv) ) - Tasuiv ) / ( Taprec - Tasuiv );
                fcond = ( min( Taprec , max(Tdew, Tasuiv) ) - Tasuiv ) / ( Taprec - Tasuiv );
            }
        }
  
        //if (fconv != 1) {
        //    printf("node %i: fconv = %0.5e, Taprec = %0.5e, Tasuiv = %0.5e Tamb = %0.5e \n",n,fconv,Taprec,Tasuiv,TAMB);
        //}
        //printf("fcond = %f\n",fcond);
        // fcond = (TAMB > Ta(n)) ? 1 : 0;
        // fconv = (Tdew > Ta(n)) ? 1 : 0;
        
        Tacond = Taprec + fcond * ( Ta(n) - Taprec );
        psTacond = vapourpressure((double)AIR,xwater,Tacond,PSTATION);
        
        // radiative heat exchange over backside
        // b = (pow(Ta(n)+273.15,4) - pow(TAMB+273.15,4))/(Ta(n)-TAMB); //temperaturefactor for linearisation
        //printf("b: %0.5e  b*sigma: %0.5e\n",b,b*SIGMA_STEFAN_BOLTZMANN);
        //printf("QDOTSOLAR = %0.5e\n",QDOTSOLAR);
        //printf("qdotgain = %0.5e , fconv= %f\n",fconv * ugain * (Taprec + fconv * (Ta(n) - Taprec) - TAMB),fconv);
        //printf("qdotloss = %0.5e , 1-fconv= %f\n",(1 - fconv) * uloss * (Tasuiv + (1 - fconv) * (Ta(n) - Tasuiv) - TAMB),1-fconv);
        //printf("qdotloss2 = %0.5e \n",uloss * (Ta(n) - TAMB));
        //printf("qdotcond = %0.5e , fcond= %f\n",fcond * ucond * ccond * (psTdew - psTacond),fcond);
        //printf("qdotcond = %0.5e %0.5e %0.5e %0.5e\n",ucond,ccond,psTdew,psTacond);
        //printf("qdotlw = %0.5e\n",epsilon * SIGMA_STEFAN_BOLTZMANN * (pow(Ta(n),4) - pow(TSKY,4)));
        //printf("qdotback = %0.5e\n",uback * (Ta(n) - TAMB));
        //printf("qdotfluid = %0.5e\n\n",hi * (Ta(n) - (Tf(n) + Tfprec)*0.5 ));
        
        // Calculus for absorber nodes
        DTaDT(n) = invcapabs * (QDOTSOLAR
                  - fconv * ugain * (Taprec + fconv * (Ta(n) - Taprec) - TAMB)
                  - (1 - fconv) * uloss * (Tasuiv + (1 - fconv) * (Ta(n) - Tasuiv) - TAMB)
                  - fcond * ucond * ccond * (psTdew - psTacond)
                  - epsilon * SIGMA_STEFAN_BOLTZMANN * (pow(Ta(n),4) - pow(TSKY,4))
                  - uc1eta0 * (IDFU+IDIR) * VWIND
                  - hi * (Ta(n) - Tf(n)));
        Taprec = Ta(n);
        
         // Calculus for fluid nodes
        DTfDT(n) = invcapfl * (hi * (Ta(n) - Tf(n))
                  + flow * (Tfprec - Tf(n)));
        Tfprec = Tf(n);
    }
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

