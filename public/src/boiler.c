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
 * This MEX-file performs the model of a furnace (oil or gas fired).
 *
 *     Syntax  [sys, x0] = boiler(t,x,u,flag)
 *
 * related header files: carlib.h
 *
 * compiler command (Matlab): mex boiler.c carlib.lib
 *
 * author list:     cw -> Carsten Wemhoener
 *                  hf -> Bernd Hafner
 *                  aw -> Arnold Wohlfeil
 *
 * version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
 *
 * Version  Author  Changes                                     Date
 * 0.9.0    cw      created                                     23jul98
 * 0.11.0   hf      changed to level 2 s-function               10feb99
 * 0.11.1   hf      exception free code assumed                 22feb99
 * 5.1.0    hf      update comments,                            15auf2012
 *                  Pnom as input, not parameter for condesing
 *                  boiler modelling
 * 5.2.0    hf      Tm as mean of input and output              26nov2012
 *                  power to heating circuit as new output
 * 6.0.0    aw      SimstateCompiliance and                     11aug2015
 *                  MultipleInstancesExec activated
 *
 * Copyright by the authors and (c) 1998 Solar-Institut Juelich, Germany
 *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *  D E S C R I P T I O N
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *
 * The boiler is devided into "NODES" nodes.
 * The energy-balance for every node is a differential equation:
 *
 * m_node*cp*dT/dt = U1 * (Tamb      - Tnode)
 *                  + mdot*cp*(Tlastnode - Tnode)
 *                  + Pnom
 *
 *  symbol      used for                                    unit
 *  cp          heat capacity of fluid                      J/(kg*K)
 *  mdot        mass flow rate                              kg/s
 *  Pnom        nominal power inputof the boiler            W
 *  T           temperature                                 K
 *  t           time                                        s
 *  U1          linear heat loss coefficient                W/K
 * 
 *         
 * structure of u (input vector)
 * port use
 * 0    ambient temperature                                 degree Celsius
 * 1    temperature at inlet                                degree Celsius
 * 2    massflow                                            kg/s
 * 3    pressure                                            Pa  
 * 4    fluid ID (defined in carlib.h)                 
 * 5    mixture  (defined in carlib.h)                 
 * 6    control signal (0..1)
 *
 *
 * structure of y (output vector)
 *  port    use
 *  0       outlet temperature                              degree Celsius
 *  1       mean temperature                                degree Celsius
 *  2       power to the heating circuit                    W
 */
 
/*
 * The following #define is used to specify the name of this S-Function.
 */

#define S_FUNCTION_NAME     boiler
#define S_FUNCTION_LEVEL    2

#include "simstruc.h"
#include "carlib.h"

/*
 *   Defines for easy access to the parameters
 */
#define ULOSS   *mxGetPr(ssGetSFcnParam(S,0)) /* heat loss coefficient */
#define VOL     *mxGetPr(ssGetSFcnParam(S,1)) /* volume of boiler */
#define TINI    *mxGetPr(ssGetSFcnParam(S,2)) /* initial temperature */
#define NODES   *mxGetPr(ssGetSFcnParam(S,3)) /* number of nodes */
#define NPARAMS                           4
                
#define TAMB       (*u0[0])      /* ambient temperature */
#define TIN        (*u1[0])      /* inlet temperature */
#define MDOT       (*u2[0])      /* massflow */
#define PRESS      (*u3[0])      /* pressure */
#define FLUID_ID   (*u4[0])      /* fluid ID (defined in carlib.h) */
#define PERCENTAGE (*u4[1])      /* mixture  (defined in carlib.h) */
#define PNOM       (*u5[0])     /* nominal power of the boiler */

#define POWER       rwork[0]
#define TMEAN       rwork[1]


#define MDL_CHECK_PARAMETERS
#if defined(MDL_CHECK_PARAMETERS) && defined(MATLAB_MEX_FILE)
  /* Function: mdlCheckParameters =============================================
   * Abstract:
   *    Validate our parameters to verify they are okay.
   */
  static void mdlCheckParameters(SimStruct *S)
  {
       /* Check 2nd parameter: heat loss coefficient */
      {
          if (ULOSS < 0.0) {
              ssSetErrorStatus(S,"Error in furnace: loss coefficient must be >= 0");
              return;
          }
      }
      /* Check 3rd parameter: volume of boiler */
      {
          if (VOL <= 1.0e-5) {
              ssSetErrorStatus(S,"Error in furnace: volume must be > 1e-5 m^3");
              return;
          }
      }
      /* Check 4th parameter: initial temperature */
      {
          if (TINI < -273.15) {
              ssSetErrorStatus(S,"Error in furnace: initial temperature is below 0 K");
              return;
          }
      }
      /* Check 5th parameter: number of nodes */
      {
          if (NODES < 1) {
              ssSetErrorStatus(S,"Error in furnace: number of nodes must be >= 1");
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
    ssSetNumSFcnParams(S, NPARAMS);
#if defined(MATLAB_MEX_FILE)
    if (ssGetNumSFcnParams(S) == ssGetSFcnParamsCount(S)) {
        mdlCheckParameters(S);
        if (ssGetErrorStatus(S) != NULL) {
            return;
        }
    } else {
        return; /* Parameter mismatch will be reported by Simulink */
    }
#endif

    ssSetNumContStates(S, (int)NODES);  /* number of continuous states */
    ssSetNumDiscStates(S, 0);           /* number of discrete states */

    if (!ssSetNumInputPorts(S, 6)) return;
    ssSetInputPortWidth(S, 0, 1);
    ssSetInputPortDirectFeedThrough(S, 0, 0);
    ssSetInputPortWidth(S, 1, 1);
    ssSetInputPortDirectFeedThrough(S, 1, 0);
    ssSetInputPortWidth(S, 2, 1);
    ssSetInputPortDirectFeedThrough(S, 2, 0);
    ssSetInputPortWidth(S, 3, 1);
    ssSetInputPortDirectFeedThrough(S, 3, 0);
    ssSetInputPortWidth(S, 4, 2);
    ssSetInputPortDirectFeedThrough(S, 4, 0);
    ssSetInputPortWidth(S, 5, 1);
    ssSetInputPortDirectFeedThrough(S, 5, 0);

    if (!ssSetNumOutputPorts(S,3)) return;
    ssSetOutputPortWidth(S, 0, 1);
    ssSetOutputPortWidth(S, 1, 1);
    ssSetOutputPortWidth(S, 2, 1);

    ssSetNumSampleTimes(S, 1);
    ssSetNumRWork(S, 2);
    ssSetNumIWork(S, 0);
    ssSetNumPWork(S, 0);
    ssSetNumModes(S, 0);
    ssSetNumNonsampledZCs(S, 0);
    
    ssSetSimStateCompliance(S, USE_DEFAULT_SIM_STATE);
    ssSetSimStateVisibility(S, 1);
    ssSupportsMultipleExecInstances(S, true);

    /* Take care when specifying exception free code - see sfuntmpl.doc */
#ifdef  EXCEPTION_FREE_CODE
    //ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE);
#endif
}


/* Function: mdlInitializeSampleTimes =========================================
 * Abstract:
 *    Specifiy that we inherit our sample time from the driving block.
 */
static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, CONTINUOUS_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, 0.0);
}


#define MDL_INITIALIZE_CONDITIONS
/* Function: mdlInitializeConditions ========================================
 * Abstract:
 *    Initialize both states to one
 */
static void mdlInitializeConditions(SimStruct *S)
{
    real_T *x0   = ssGetContStates(S);
    real_T t0    = TINI;
    int_T  nodes = (int_T)NODES;
    int_T  n;
 
    for (n = 0; n < nodes; n++) 
        x0[n] = t0;             /* state-vector is initialized with TINI */
}



/* Function: mdlOutputs =======================================================
 */
static void mdlOutputs(SimStruct *S, int_T tid)
{
    InputRealPtrsType u1 = ssGetInputPortRealSignalPtrs(S,1);
    real_T   *y0    = ssGetOutputPortRealSignal(S,0);
    real_T   *y1    = ssGetOutputPortRealSignal(S,1);
    real_T   *y2    = ssGetOutputPortRealSignal(S,2);
    real_T   *x     = ssGetContStates(S);
    real_T   *rwork = ssGetRWork(S);
    real_T   tenter;
    int nodes = (int_T)NODES;;

    tenter = TIN;

    y0[0] = x[nodes-1];     /* temperature of the last node  */
    y1[0] = TMEAN;          /* average temperature */
    y2[0] = POWER;          /* power */
}


#define MDL_DERIVATIVES
/* Function: mdlDerivatives =================================================
 * Abstract:
 *      xdot = Ax + Bu
 */
static void mdlDerivatives(SimStruct *S)
{
    real_T   *dx    = ssGetdX(S);
    real_T   *x     = ssGetContStates(S);
    real_T   *rwork = ssGetRWork(S);

    InputRealPtrsType u0 = ssGetInputPortRealSignalPtrs(S,0);
    InputRealPtrsType u1 = ssGetInputPortRealSignalPtrs(S,1);
    InputRealPtrsType u2 = ssGetInputPortRealSignalPtrs(S,2);
    InputRealPtrsType u3 = ssGetInputPortRealSignalPtrs(S,3);
    InputRealPtrsType u4 = ssGetInputPortRealSignalPtrs(S,4);
    InputRealPtrsType u5 = ssGetInputPortRealSignalPtrs(S,5);

    int      nodes = (int)NODES;
    real_T   qloss, tenter, mdotcp, invmass, qeff, qheat;
    int      n;
    
    tenter  = TIN;                      /* entering temperature is inlet temperature for 1st node */
    qeff    = PNOM/nodes;               /* power from burner per node */
    POWER   = 0.0;                      /* no power at the beginning */
    TMEAN   = (tenter+x[nodes-1])*0.5;  /* average temperature */
    qloss   = ULOSS*(TAMB-TMEAN)/nodes; /* losses per node */

    mdotcp  = heat_capacity(FLUID_ID, PERCENTAGE, TMEAN, PRESS); /* only cp */
    invmass = nodes/(mdotcp*density(FLUID_ID, PERCENTAGE, TMEAN, PRESS)*VOL); 
    mdotcp  *= MDOT;                    /* now with massflow */
    
    for (n = 0; n < nodes; n++)
    {
        qheat = mdotcp*(x[n]-tenter);   /* power to water (positive if heating) */
        POWER += qheat;                 /* sum up power */
        dx[n] = (qloss - qheat + qeff)*invmass;
        tenter = x[n];
    }
}


/* Function: mdlTerminate =====================================================
 * Abstract:
 *    No termination needed, but we are required to have this routine.
 */
static void mdlTerminate(SimStruct *S)
{
}


#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif

