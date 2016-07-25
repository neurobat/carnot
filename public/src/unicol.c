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
 * Version  Author          Changes                                 Date
 * 0.1.0    Bernd Hafner    created                                 18feb98
 * 0.5.0    hf              toolbox name changed to CARNOT          30apr98
 * 0.5.1    hf              include static pressure calculation     30apr98
 * 0.5.2    hf              material properties from carlib         20mai98
 * 0.7.0    hf              switch pressure calculation             12jun98
 *                          ID <=10000 no pressure calculation
 *                          ID <=20000 only pressure drop
 *                          ID > 20000 pressure drop and static pressure
 * 0.8.0    hf              new pressure drop calculation           13jul98
 *                          dp = dp0 + dp1*mdot + dp2*mdot^2
 *                          function has new outputs dp0, dp1, dp2
 * 0.11.0   tw, hf          sky radiation losses included           14jun99
 * 1.0      hf              height is length between in- and outlet 07sep99
 * 1.0.1    hf              new output: energy balance              22jan99
 *                          changed to level2 S-function
 * 1.64     cw              change input 1 to direct feedthrough    19feb2003 (y2k problem :-))
 * 2.0      hf              losses and capacity on Tavg (in+out)/2  03mar2004
 * 2.1      jg, th, sa      function for thermosiphon corrected     01dec2005
 *             (conversiom of collector slope from degree in rad)
 * 4.0      hf              correctet inlet temperature (tenter)    02sep2009
 *                          in the case for no massflow
 * 4.1      Gaelle Faure    add call to mdlCheckParamter in         10fev11
 *                          mdlInitializeSizes
 * 6.1      hf              static pressure calculation in separate 01sep2014
 *                          bloc, elmiminated here. Tnodes as output.
 * 6.1.1	aw				added SimState compilance and			24jul2015
 *							multiple instances
 * 6.1.2    aw              unused function mdlUpdate deleted       10sep2015
 *
 *
 *
 * Copyright (c) 1998,2014 Solar-Institut Juelich, Germany
 *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *  D E S C R I P T I O N
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * The collector is devided into "NODES" nodes.
 * The energy-balance for every node is a differential equation:
 *
 * c_col * dT/dt    = ULIN *            (Tamb      - Tavg)
 *                  + UQUA *            (Tamb      - Tavg)^2
 *                  + USKY *            (Tavg      - Tsky)
 *                  + Uwind * vwind * (Tamb      - Tnode)
 *                  + mdot * cp / Acoll * (Tlastnode - Tnode)
 *                  + qdot_solar
 * 
 * Tagv = (Tnode+Tlastnode))/2  
 * Tlastnode = Tinlet (for node 1)
 * Tlastnode = T of the node before (all other nodes)
 *
 *  symbol      used for                                    unit
 *  cp          heat capacity of fluid                      J/(kg*K)
 *  c_col       heat capacity of collector per surface      J/(m^2*K)
 *  mdot        mass flow rate                              kg/s
 *  qdot_solar  power input per surface from sun            W/m^2
 *  T           temperature                                 K
 *  t           time                                        s
 *  ULIN          linear heat loss coefficient                W/(m^2*K)
 *  UQUA          quadratic heat loss coefficient             W/(m*K)^2
 *  USKY          sky loss coefficient   
 *  Uwind       wind speed dependant heat losses            W/((m/s)*m^2*K)
 *         
 * structure of u (input vector)
 * port 0:
 * index use
 * 0    absorbed solar radiation                W/m^2
 * 1    global solar radiation                  W/m^2
 * 2    ambient temperature                     degree centigrade
 * 3    mean wind speed                         m/s
 * 4    sky temperature                         degree centigrade
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
 *  0       collector outlet temperature        degree Celsius
 *  1       average temperature                 degree Celsius
 *  2 0.N-1 node temperatures                   degree Celsius
 */

/*
 * The following #define is used to specify the name of this S-Function.
 */

#define S_FUNCTION_LEVEL 2
#define S_FUNCTION_NAME unicol

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

#define A_COLL  *mxGetPr(ssGetSFcnParam(S,0)) /* absorber surface area:  Acoll    */
#define ULIN    *mxGetPr(ssGetSFcnParam(S,1)) /* linear loss coefficient         */
#define UQUA    *mxGetPr(ssGetSFcnParam(S,2)) /* quadratic loss coefficient      */
#define USKY    *mxGetPr(ssGetSFcnParam(S,3)) /* sky loss coefficient            */
#define UWIND   *mxGetPr(ssGetSFcnParam(S,4)) /* wind dependant loss coefficient */
#define C_COLL  *mxGetPr(ssGetSFcnParam(S,5)) /* heat capacity of collector      */
#define TINI    *mxGetPr(ssGetSFcnParam(S,6)) /* initial temperature       */
#define NODES   *mxGetPr(ssGetSFcnParam(S,7)) /* number of nodes       */
#define N_PARAMETER                       8

#define T(n)         x[n]      /* actual node temperature */
#define DTDT(n)      dx[n]

                             
#define QSOLAR     (*u0[0])  /* absorbed solar radiation */
#define IGLB       (*u0[1])  /* global radiation   */
#define TAMB       (*u0[2])  /* ambient temperature */
#define VWIND      (*u0[3])  /* wind velocity */
#define TSKY       (*u0[4])  /* Sky temperature */
#define NINPUT0         5

#define TIN        (*u1[0])  /* inlet temperature */
#define NINPUT1         1
#define MDOT       (*u2[0])  /* massflow */
#define NINPUT2         1
#define PRESS      (*u3[0])  /* pressure */
#define FLUID_ID   (*u3[1])  /* fluid ID (defined in carlib.h) */
#define PERCENTAGE (*u3[2])  /* mixture  (defined in carlib.h) */
#define NINPUT3         3


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
          if (C_COLL < 1.0e-3) {
              ssSetErrorStatus(S,"Error in solar collector: heat capacity must be > 0");
              return;
          }
      }
      /* */
      {
          if (NODES < 1.0) {
              ssSetErrorStatus(S,"Error in solar collector: number of nodes must be >= 1");
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
    int_T nodes;
    nodes = (int_T)NODES;
    
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

    ssSetNumContStates(S, nodes);
    ssSetNumDiscStates(S, 0);

    if (!ssSetNumInputPorts(S, 4)) return;
    ssSetInputPortWidth(S, 0, NINPUT0);
    ssSetInputPortDirectFeedThrough(S, 0, 0);

    ssSetInputPortWidth(S, 1, NINPUT1);
    ssSetInputPortDirectFeedThrough(S, 1, 0);

    ssSetInputPortWidth(S, 2, NINPUT2);
    ssSetInputPortDirectFeedThrough(S, 2, 1);

    ssSetInputPortWidth(S, 3, NINPUT3);
    ssSetInputPortDirectFeedThrough(S, 3, 0);

    if (!ssSetNumOutputPorts(S, 3)) return;
    ssSetOutputPortWidth(S, 0, 1);      // collector outlet temperature 
    ssSetOutputPortWidth(S, 1, 1);      // average temperature
    ssSetOutputPortWidth(S, 2, nodes);  //node temperatures

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


#define MDL_INITIALIZE_CONDITIONS
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
    real_T *x0 = ssGetContStates(S);
    real_T t0 = TINI;        /* initial temperature */
    int_T  nodes = (int_T)NODES;
    int_T  n;

    for (n = 0; n < nodes; n++) 
    {
        x0[n] = t0;
    }
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
    real_T *tout  = ssGetOutputPortRealSignal(S,0);
    real_T *tm    = ssGetOutputPortRealSignal(S,1);
    real_T *tnode = ssGetOutputPortRealSignal(S,2);
    real_T *x = ssGetContStates(S);
    int_T  nodes  = (int_T)NODES;
    real_T tt;
    int_T n;

    /* set outputs */
    tout[0] = T(nodes-1);           /* temperature of the last node  */

    tt = 0.0;
    for (n = 0; n < nodes; n++)
    {
        tt += T(n);
    }
    tm[0] = tt/(real_T)nodes;       /* average temperature */
    
    for (n = 0; n < nodes; n++)
    {
        tnode[n] = T(n);            /* node temperatures */
    }
}



#define MDL_DERIVATIVES
/* Function: mdlDerivatives =================================================
 * Abstract:
 *      xdot = Ax + Bu
 */
static void mdlDerivatives(SimStruct *S)
{
    real_T            *dx = ssGetdX(S);
    real_T            *x  = ssGetContStates(S);
    InputRealPtrsType u0  = ssGetInputPortRealSignalPtrs(S,0);
    InputRealPtrsType u1  = ssGetInputPortRealSignalPtrs(S,1);
    InputRealPtrsType u2  = ssGetInputPortRealSignalPtrs(S,2);
    InputRealPtrsType u3  = ssGetInputPortRealSignalPtrs(S,3);
    real_T ulin = ULIN;
    real_T uqua = UQUA;
    real_T usky = USKY;
    real_T uwind = UWIND;
	real_T qsolar = QSOLAR;
    real_T tenter, wind, flow, tavg, asegment, invcap, tt;
    int_T  nodes = (int_T)NODES;
    int_T  n;
    
    asegment = A_COLL/nodes;    // collector surface per node in m²
    invcap = 1.0/C_COLL;        // reciprocal valuue of thermal capacity in m²/W
    wind = uwind * VWIND;       // wind loss coeff * wind velocity
    
    if (MDOT > NO_MASSFLOW)     // if there is a massflow
    {
	    tenter = TIN;                   // entering temperature is inlet temperature
        tt = 0.5*(tenter+T(nodes-1));   // average temperature between inlet and outlet
        flow = MDOT*heat_capacity(FLUID_ID, PERCENTAGE, tt, PRESS)/asegment;
    }
    else				// else 
    {
		tenter = T(0);	// entering temperature is node temperature
        flow = 0.0;
    }
    
    for (n = 0; n < nodes; n++)
    {
        tavg = 0.5*(T(n)+tenter);
        tt = tavg-TAMB;
        DTDT(n) = (qsolar - tt*(ulin+wind+uqua*tt) - usky*(tavg-TSKY)
                + flow*(tenter-T(n))) * invcap;
        /* printf("node %i qsolar %f   tin %f   T(n) %f  p %f  FLUID_ID %f  PERCENTAGE %f \n", 
         *       n,     qsolar,   tenter,     T(n), PRESS,   FLUID_ID,    PERCENTAGE);
         */
        tenter = T(n);
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