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
 * pressure drop in a pipe from theoretical appraoch
 *
 * Version  Author          Changes                             Date
 * 6.0.0    Bernd Hafner    created, adapted from pipe_c.c      05oct2013
 * 6.1.0    Arnold Wohlfeil SimState compiliance and            11aug2015
 *                          MultipleExecInstanes enabled
 * 6.1.1    Bernd Hafner    initialize variables properly       11sep2015
 *
 * Copyright (c) 2000-2015 Solar-Institut Juelich, Germany
 * 
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *  D E S C R I P T I O N
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *
 * Calculate the pressure drop of a fluid flow in a pipe with a 
 * theoretical approach.
 * The crossection of the pipe is a circle or otherwise pass hydralic 
 * diameter as input.
 *  D_hydr = 4 * Crosssection-Area / Circumference
 * Difference in static height between inlet and outlet is also taken
 * into account. Outlet above inlet has a positive height and a decrease
 * in static pressure.
 *
 *  symbol      used for                                        unit
 *  D_hydr      (hydraulic) diameter of the pipe                m
 *  dh          distance between two nodes                      m
 *  mdot        mass flow rate                                  kg/s
 *  rho         density                                         kg/m^3
 *  T           temperature                                     K
 *  t           time                                            s
 *	Vnode       node volume                                     m^3
 *         
 * structure of u (input vector)
 *  see defines below
 *
 * structure of y (output vector)
 *  index   use
 *  0       temperature                                     degree Celsius  
 *  1       node temperatures (vector)                      degree Celsius 
 *
 */


#define S_FUNCTION_NAME  pipe_PressureDrop
#define S_FUNCTION_LEVEL 2

/*
 * Need to include simstruc.h for the definition of the SimStruct and
 * its associated macro definitions.
 */
#include "simstruc.h"
#include "carlib.h"
#include <math.h>

/*
 *   Defines for easy access to the parameters (not inputs!) 
 *   that are passed in. (ATTENTION: ssGetArg() returns **Matrix !!
 *   but mxGetPr() converts to double-pointer)
 */
#define DIA       *mxGetPr(ssGetSFcnParam(S,0)) /* diameter [m] */
#define LENGTH    *mxGetPr(ssGetSFcnParam(S,1)) /* length in m */
#define ROUGHNESS *mxGetPr(ssGetSFcnParam(S,2)) /* roughness of pipe in mm */
#define NBENDS    *mxGetPr(ssGetSFcnParam(S,3)) /* No. of 90° bends (45° = 0.667) */
#define N_PARAM                             4


#define T(n)       (*u0[n])     /* node temperature */
#define MDOT       (*u1[0])     /* massflow */
#define PRESS      (*u2[0])     /* pressure */
#define FLUID_ID   (*u3[0])     /* fluid ID (defined in CARNOT.h) */
#define PERCENTAGE (*u4[0])     /* mixture  (defined in CARNOT.h) */
#define N_INPUT_PORTS 5


/*====================*
 * S-function methods *
 *====================*/

/* Function: mdlInitializeSizes ===============================================
 * Abstract:
 *    The sizes information is used by Simulink to determine the S-function
 *    block's characteristics (number of inputs, outputs, states, etc.).
 */
static void mdlInitializeSizes(SimStruct *S)
{
    /* See sfuntmpl_doc.c for more details on the macros below */

    ssSetNumSFcnParams(S, N_PARAM);  /* Number of expected parameters */
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S))
    {
        /* Return if number of expected != number of actual parameters */
        return;
    }

    ssSetNumContStates(S, 0);
    ssSetNumDiscStates(S, 0);

    if (!ssSetNumInputPorts(S, N_INPUT_PORTS))
    {
        return;
    }
    ssSetInputPortWidth(S, 0, DYNAMICALLY_SIZED);
    ssSetInputPortDirectFeedThrough(S, 0, 1);
    ssSetInputPortWidth(S, 1, 1);
    ssSetInputPortDirectFeedThrough(S, 1, 1);
    ssSetInputPortWidth(S, 2, 1);
    ssSetInputPortDirectFeedThrough(S, 2, 1);
    ssSetInputPortWidth(S, 3, 1);
    ssSetInputPortDirectFeedThrough(S, 3, 1);
    ssSetInputPortWidth(S, 4, 1);
    ssSetInputPortDirectFeedThrough(S, 4, 1);

    if (!ssSetNumOutputPorts(S, 3))
    {
        return;
    }
    ssSetOutputPortWidth(S, 0, 1);
    ssSetOutputPortWidth(S, 1, 1);
    ssSetOutputPortWidth(S, 2, 1);

    ssSetNumSampleTimes(S, 1);
    ssSetNumRWork(S, 0);
    ssSetNumIWork(S, 0);
    ssSetNumPWork(S, 0);
    ssSetNumModes(S, 0);
    ssSetNumNonsampledZCs(S, 0);
    
    ssSetSimStateCompliance(S, USE_DEFAULT_SIM_STATE);
    ssSetSimStateVisibility(S, 1);
    ssSupportsMultipleExecInstances(S, true);

    /* Take care when specifying exception free code - see sfuntmpl.doc */
#ifdef  EXCEPTION_FREE_CODE
    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE);
#endif
}



/* Function: mdlInitializeSampleTimes =========================================
 * Abstract:
 *    This function is used to specify the sample time(s) for your
 *    S-function. You must register the same number of sample times as
 *    specified in ssSetNumSampleTimes.
 */
static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, CONTINUOUS_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, 0.0);

}



#undef MDL_START  /* Change to #undef to remove function */
#if defined(MDL_START) 
  /* Function: mdlStart =======================================================
   * Abstract:
   *    This function is called once at start of model execution. If you
   *    have states that should be initialized once, this is the place
   *    to do it.
   */
  static void mdlStart(SimStruct *S)
  {
    //real_T *RWork = ssGetRWork(S);  
    //real_T length = LENGTH;
    //real_T dia    = DIA;
    //real_T uloss  = ULOSS;
    //int_T  nodes  = (int)NODES;

    /* geometries */
    //LNODE = length/(double)nodes;   /* length of one node */
    //VNODE = PI*dia*dia*LNODE*0.25;  /* node volume */
    //LOSS  = uloss*4.0/dia;          /* losses in W per m³ node volume */
  }
#endif /*  MDL_START */



/* Function: mdlOutputs =======================================================
 * Abstract:
 *    In this function, you compute the outputs of your S-function
 *    block.
 */
static void mdlOutputs(SimStruct *S, int_T tid)
{
    InputRealPtrsType u0 = ssGetInputPortRealSignalPtrs(S,0);
    InputRealPtrsType u1 = ssGetInputPortRealSignalPtrs(S,1);
    InputRealPtrsType u2 = ssGetInputPortRealSignalPtrs(S,2);
    InputRealPtrsType u3 = ssGetInputPortRealSignalPtrs(S,3);
    InputRealPtrsType u4 = ssGetInputPortRealSignalPtrs(S,4);
    real_T *y0 = ssGetOutputPortRealSignal(S,0);
    real_T *y1 = ssGetOutputPortRealSignal(S,1);
    real_T *y2 = ssGetOutputPortRealSignal(S,2);
    int_T  nodes = ssGetInputPortWidth(S,0);

    real_T nbend = NBENDS;
    real_T length = LENGTH;
    real_T rough = ROUGHNESS;
    real_T dia   = DIA;
    real_T rho, v, re, fh, k, leq, flimit, klimit, tmean, hh, dplin, dpqua;
    int_T  n; 

    /* set geometries */
    flimit = 1.0/(2.0*log10(dia/rough)+1.14);   /* lowest value of fh, Nikuradse */
    flimit *= flimit;                           /* limit is (1/(2*log10(...)))^2 */
    klimit = rough/dia;  /* limit of friction coefficient k is (roughness/diameter)^2 */
    klimit *= klimit;

    /* average pipe temperature */
    tmean = 0.0;
    for (n = 0; n < nodes; n++) {
        tmean += T(n);
    }
    tmean = tmean/(double)nodes;

    /* pipe friction calculate only if there is massflow */
    dplin = 0.0;
    dpqua = 0.0;
    k = 0.0;
    fh = 0.0;
    hh = 0.0;
    leq = length;

    if (MDOT > 0.0)  
    {
        rho = density(FLUID_ID, PERCENTAGE, tmean, PRESS);
        v = 4.0*MDOT/(rho*PI*dia*dia);
        re = v*dia/viscosity(FLUID_ID, PERCENTAGE, tmean, PRESS);

        /* developing flow correction */
	    /* from A. Lencastre : Hydraulique generale, Eyrolles Safege/*
        /* and from Bohl: technische Stroemungslehre, Vogel Verlag */
        if (re < 2050.0)                        /* laminar flow */
        {
	        fh = 64.0/re;
            leq += dia*(1.6-re/2000.0)/fh*nbend;  /*use of Leq to store the pressure drop in dplin*/
        } 
        else if (re < 3000.0)                   /* transition zone : linear interpolation */
        {
            fh = ((max(flimit, 4.4e-2)-0.032)/1000)*(re-2000)+0.032;
            k += (0.6+0.15*re/1000)*nbend;
        } 
        else 
        {                                       /* turbulent flow : Blasius and Nikuradse correlations*/
            fh = max(flimit, ((re <= 1.0e5)? 0.3164*pow(re,-0.25) : 0.221*pow(re,-0.237)+0.0032));
            k += (re < 3e5)? (0.75-(0.75-klimit)*re/3.0e5)*nbend : klimit*nbend;
        }

        if (re < 100.0)                         /* low reynolds number correction */
            k = 100.0*k/max(1.0,re);

        /* pressure drop */
        hh = rho*v*v*0.5;

        if (re < 2050.0) {
            dplin = fh*leq/dia*hh/MDOT;
            dpqua = k*hh/(MDOT*MDOT);
        } else {
            dpqua = (fh*leq/dia+k)*hh/(MDOT*MDOT);
            dplin = 0.0;
        }
    } /* end if mdot */

    /* set outputs */
    y0[0] = dplin;
    y1[0] = dpqua;
    y2[0] = (fh*leq/dia+k)*hh;  /* pressure drop */
}


/* Function: mdlTerminate =====================================================
 * Abstract:
 *    In this function, you should perform any actions that are necessary
 *    at the termination of a simulation.  For example, if memory was
 *    allocated in mdlStart, this is the place to free it.
 */
static void mdlTerminate(SimStruct *S)
{
}


/*======================================================*
 * See sfuntmpl_doc.c for the optional S-function methods *
 *======================================================*/

/*=============================*
 * Required S-function trailer *
 *=============================*/

#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif
