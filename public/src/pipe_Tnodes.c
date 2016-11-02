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
 * multinode pipe with capacity
 *
 * Version  Author          Changes                                 Date
 * 0.5.0    Bernd Hafner    created, adapted from pipe_c.c          25mai98
 *                          with fast pressure drop calculation
 * 0.7.0    hf              switch pressure calculation             12jun98
 *                          ID <=10000 no pressure calculation
 *                          ID <=20000 only pressure drop
 *                          ID > 20000 pressure drop and static pressure
 * 1.0.0    hf              check mdot = 0 changed to               16jul99
 *                          mdot < NO_MASSFLOW (defined in carlib.h)
 * 1.0.1    hf              check mdot == 0 for pressure drop       26jul99
 * 6.0.1    hf              removed pressure drop calculation       03oct2013
 *                          changed to s-function Level 2
 * 6.0.2    Arnold Wohlfeil SimState compiliance and                11aug2015
 *                          MultipleExecInstanes enabled
 * 6.0.3    Arnold Wohlfeil unused variables deleted                09sep2015
 *
 * Copyright (c) 1998 Solar-Institut Juelich, Germany
 * 
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *  D E S C R I P T I O N
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *
 * The pipe is devided into "NODES" nodes 
 * energy-balance for every node with the differential equation:
 *
 * (cwall*length/vnode) * dT/dt = U * Aloss / Vnode *  (Tamb      - Tnode)
 *                              + cond / dh^2 *        (Tnextnode - Tnode)          
 *                              + cond / dh^2 *        (Tlastnode - Tnode)          
 *                              + mdot * cp / Vnode *  (Tlastnode - Tnode)
 *
 *  symbol      used for                                        unit
 *  Aloss       surface area for losses                         m^2
 *	cond        effective axial heat conduction                 W/(m*K)
 *  cp          heat capacity of fluid                          J/(kg*K)
 *  cwall       heat capacity of pipe per length                J/(m*K)
 *  dh          distance between two nodes                      m
 *  mdot        mass flow rate                                  kg/s
 *  rho         density                                         kg/m^3
 *  T           temperature                                     K
 *  t           time                                            s
 *  U           heat loss coefficient                           W/(m^2*K)
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


#define S_FUNCTION_NAME  pipe_Tnodes
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
#define VNODE     *mxGetPr(ssGetSFcnParam(S,0)) /* volume of the node in m^3 */
#define LNODE     *mxGetPr(ssGetSFcnParam(S,1)) /* length per node in m */
#define LOSS      *mxGetPr(ssGetSFcnParam(S,2)) /* loss coefficient [W/(m^3*K)] */
#define COND      *mxGetPr(ssGetSFcnParam(S,3)) /* axial conductivity / (node distance)^2 [W/(m^3*K)] */
#define CWALL     *mxGetPr(ssGetSFcnParam(S,4)) /* capacity wall per node volume in J/(m^3*K)*/
#define TINI      *mxGetPr(ssGetSFcnParam(S,5)) /* initial temperature [°C]  */
#define NODES     *mxGetPr(ssGetSFcnParam(S,6)) /* number of nodes */
#define N_PARAM                             7

#define T(n)         x[n]       /* node temperature (T) */
                             
#define TAMB       (*u0[0])     /* ambient temperature */
#define TIN        (*u1[0])     /* inlet temperature */
#define MDOT       (*u2[0])     /* massflow */
#define PRESS      (*u3[0])     /* pressure */
#define FLUID_ID   (*u4[0])     /* fluid ID (defined in CARNOT.h) */
#define PERCENTAGE (*u5[0])     /* mixture  (defined in CARNOT.h) */
#define N_INPUT_PORTS 6


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
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
        /* Return if number of expected != number of actual parameters */
        return;
    }

    ssSetNumContStates(S, (int_T)NODES);
    ssSetNumDiscStates(S, 0);

    if (!ssSetNumInputPorts(S, N_INPUT_PORTS)) return;
    ssSetInputPortWidth(S, 0, 1);
    ssSetInputPortDirectFeedThrough(S, 0, 0);
    ssSetInputPortWidth(S, 1, 1);
    ssSetInputPortDirectFeedThrough(S, 1, 0);
    ssSetInputPortWidth(S, 2, 1);
    ssSetInputPortDirectFeedThrough(S, 2, 0);
    ssSetInputPortWidth(S, 3, 1);
    ssSetInputPortDirectFeedThrough(S, 3, 0);
    ssSetInputPortWidth(S, 4, 1);
    ssSetInputPortDirectFeedThrough(S, 4, 0);
    ssSetInputPortWidth(S, 5, 1);
    ssSetInputPortDirectFeedThrough(S, 5, 0);

    if (!ssSetNumOutputPorts(S, 2)) return;
    ssSetOutputPortWidth(S, 0, 1);
    ssSetOutputPortWidth(S, 1, (int_T)NODES);

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


#define MDL_INITIALIZE_CONDITIONS   /* Change to #undef to remove function */
#if defined(MDL_INITIALIZE_CONDITIONS)
  /* Function: mdlInitializeConditions ========================================
   * Abstract:
   *    In this function, you should initialize the continuous and discrete
   *    states for your S-function block.  The initial states are placed
   *    in the state vector, ssGetContStates(S) or ssGetRealDiscStates(S).
   *    You can also perform any other initialization activities that your
   *    S-function may require. Note, this routine will be called at the
   *    start of simulation and if it is present in an enabled subsystem
   *    configured to reset states, it will be call when the enabled subsystem
   *    restarts execution to reset the states.
   */
  static void mdlInitializeConditions(SimStruct *S)
  {
    real_T *x0   = ssGetContStates(S);
    real_T t0    = TINI;        /* initial temperature as parameter */
    int_T  nodes = (int)NODES;  /* numer of nodes as parameter */
    int_T  n;

    for (n = 0; n < nodes; n++) 
    {
        x0[n] = t0;             /* state-vector is initialized with TINI */
    }
  }
#endif /* MDL_INITIALIZE_CONDITIONS */




/* Function: mdlOutputs =======================================================
 * Abstract:
 *    In this function, you compute the outputs of your S-function
 *    block.
 */
static void mdlOutputs(SimStruct *S, int_T tid)
{
    real_T *y0 = ssGetOutputPortRealSignal(S,0);
    real_T *y1 = ssGetOutputPortRealSignal(S,1);
    real_T *x = ssGetContStates(S);
    int_T  nodes = (int)NODES;  /* numer of nodes as parameter */
    int_T  n; 

    /* set outputs */
    y0[0] = T(nodes-1);    /* outlet temperature */
    for (n = 0; n < nodes; n++)
    {
        y1[n] = T(n);      /* T nodes */
    }
}


#define MDL_DERIVATIVES  /* Change to #undef to remove function */
#if defined(MDL_DERIVATIVES)
  /* Function: mdlDerivatives =================================================
   * Abstract:
   *    In this function, you compute the S-function block's derivatives.
   *    The derivatives are placed in the derivative vector, ssGetdX(S).
   */
  static void mdlDerivatives(SimStruct *S)
  {
    real_T       *dx = ssGetdX(S);
    real_T       *x  = ssGetContStates(S);
    InputRealPtrsType u0 = ssGetInputPortRealSignalPtrs(S,0);
    InputRealPtrsType u1 = ssGetInputPortRealSignalPtrs(S,1);
    InputRealPtrsType u2 = ssGetInputPortRealSignalPtrs(S,2);
    InputRealPtrsType u3 = ssGetInputPortRealSignalPtrs(S,3);
    InputRealPtrsType u4 = ssGetInputPortRealSignalPtrs(S,4);
    InputRealPtrsType u5 = ssGetInputPortRealSignalPtrs(S,5);

    /* define and get parameters */
    real_T vnode  = VNODE;
    real_T cond   = COND;
    real_T cwall  = CWALL;
    int_T  nodes  = (int)NODES;

    real_T invcap, rho, cpf, flow;
    int_T  n;

    rho = density(FLUID_ID, PERCENTAGE, TIN, PRESS);
    cpf = heat_capacity(FLUID_ID, PERCENTAGE, TIN, PRESS);

    /* set heat transport terms */
    flow  = cpf/vnode;                          /* by flow */
    invcap  = 1.0/(rho*cpf + cwall);            /* heat capacity per volume */

    for (n = 0; n < nodes; n++)
    {
       	dx[n] = LOSS*(TAMB-T(n));               /* losses */

        /* conduction forwards for all nodes except last */
        if (n < nodes-1)
            dx[n] += cond*(T(n+1)-T(n));

        /* conduction backwards and massflow (not for first node) */
        if (n > 0)
            dx[n] += (cond+flow*MDOT)*(T(n-1)-T(n));
        else
            dx[n] += flow*MDOT*(TIN-T(n));      /* first node: mdot from inlet */

        dx[n] *= invcap;                        /* adjust to energy balance */
    } /* end for */
  }
#endif /* MDL_DERIVATIVES */



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

