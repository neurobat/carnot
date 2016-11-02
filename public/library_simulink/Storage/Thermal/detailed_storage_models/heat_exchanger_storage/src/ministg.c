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
 * multinode mini storage with heat exchanger
 *
 * Syntax  [sys, x0] = pipe_c(t,x,u,flag)
 *
 * Version  Author          Changes                                 Date
 * 0.5.0    Bernd Hafner    created                                 14mai98
 * 0.5.1    hf              material properties from carlib         20mai98
 * 0.7.0    hf              switch pressure calculation             12jun98
 *                          ID <=10000 no pressure calculation
 *                          ID <=20000 only pressure drop
 *                          ID > 20000 pressure drop and static pressure
 * 6.0.0    aw              converted to level 2 S-function         11aug15
 *                          SimStateCompiliance and
 *                          MultipleExecInstances activated
 *
 * Copyright (c) 1998 Solar-Institut Juelich, Germany
 * 
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *  D E S C R I P T I O N
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * modified from mex file for multi-input, multi-output state-space system.
 *
 * The mini storage is devided into "NODES" nodes on both fluid sides,
 * the heat transfer side and the outer wall.
 * The energy-balance for every node is the differential equation:
 * (here cold side)
 * 
 * (cwall*length/vnode) * dT/dt = (U*A)loss / Vnode *  (Tamb      - Tnode)
 *                              + (U*A)exchange / Vnode *  (Tsec  - Tnode)
 *                              + mdot * cp / Vnode *  (Tlastnode - Tnode)
 *
 * (U*A)exchange = UA_Cn + UA_Ln*MDOT
 *
 * pressure drop: dp = DP_Ln*MDOT + DP_Qn*MDOT^2 + DP_Tn*Tn
 *
 *  symbol      used for                                        unit
 *  A           surface                                         m^2
 *	cond        effective axial heat conduction                 W/(m*K)
 *  cp          heat capacity of fluid                          J/(kg*K)
 *  cwall       heat capacity of pipe per length                J/(m*K)
 *  dh          distance between two nodes                      m
 *  exchange    heat exchange side
 *  loss        losses
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
 *  0       temperature hot side                   degree centigrade
 *  1       pressure hot side                      Pa  
 *  2       temperature cold side                  degree centigrade
 *  3       pressure cold side                     Pa  
 *
 */

/* specify the name of your S-Function */

#define S_FUNCTION_NAME ministg
#define S_FUNCTION_LEVEL 2

/*
 * Need to include simstruc.h for the definition of the SimStruct and
 * its associated macro definitions. Need math.h for exp-function.
 */
#include "tmwtypes.h"
#include "simstruc.h"
#include "carlib.h"

#include <math.h>

#ifndef PI
    #define PI      3.14159265358979
#endif

/*
 *   Defines for easy access to the parameters (not inputs!) 
 *   that are passed in. (ATTENTION: ssGetArg() returns **Matrix !!
 *   but mxGetPr() converts to double-pointer)
 */
#define V_HOT    (*mxGetPr(ssGetSFcnParam(S, 0))) /* volume hot side m^3  */
#define V_COLD   (*mxGetPr(ssGetSFcnParam(S, 1))) /* volume cold side m^3 */
#define UALOSS   (*mxGetPr(ssGetSFcnParam(S, 2))) /* loss coefficient [W/K] */
#define UACHOT   (*mxGetPr(ssGetSFcnParam(S, 3))) /* const.heat transfer hot side W/K */
#define UALHOT   (*mxGetPr(ssGetSFcnParam(S, 4))) /* linear massflow dependance */
#define UACCOLD  (*mxGetPr(ssGetSFcnParam(S, 5))) /* const.heat transfer cold side W/K */
#define UALCOLD  (*mxGetPr(ssGetSFcnParam(S, 6))) /* linear massflow dependance */
#define UACWALL  (*mxGetPr(ssGetSFcnParam(S, 7))) /* const.heat transfer to wall W/K */
#define UALWALL  (*mxGetPr(ssGetSFcnParam(S, 8))) /* linear massflow dependance */
#define MATERIAL (*mxGetPr(ssGetSFcnParam(S, 9))) /* ID of wall material */
#define MASS     (*mxGetPr(ssGetSFcnParam(S, 10))) /* total mass (without fluid) kg */
#define FRAC_IN  (*mxGetPr(ssGetSFcnParam(S, 11))) /* fraction of mass on inner side  */
#define TINI     (*mxGetPr(ssGetSFcnParam(S, 12))) /* initial temperature [°C]  */
#define DPLHOT   (*mxGetPr(ssGetSFcnParam(S, 13))) /* pressure drop linear in mdot */
#define DPQHOT   (*mxGetPr(ssGetSFcnParam(S, 14))) /* pressure drop quadratic in mdot */
#define DPTHOT   (*mxGetPr(ssGetSFcnParam(S, 15))) /* dp linear temperature dependance */
#define DPLCOLD  (*mxGetPr(ssGetSFcnParam(S, 16))) /* pressure drop linear in mdot */   
#define DPQCOLD  (*mxGetPr(ssGetSFcnParam(S, 17))) /* pressure drop quadratic in mdot */
#define DPTCOLD  (*mxGetPr(ssGetSFcnParam(S, 18))) /* dp linear temperature dependance */
#define NODES    (*mxGetPr(ssGetSFcnParam(S, 19))) /* number of nodes */
#define N_PARAMETER                  20

#define LAST_NODE  (nodes-1) /* index of last node */
#define FIRST_NODE 0         /* index of first node */

#define THOT      x[n]           /* node temperature (T) hot side */
#define THOTBACK  x[n-1]         /* T at node backwards in flowdirection */
#define THOTNEXT  x[n+1]         /* T next node in flowdirection */
#define DTDTHOT   dx[n]          /* dT/dt hot side */
#define TSURF     x[nodes+n]     /* T heat transfer surface */
#define TSURFBACK x[nodes+n-1]   /* T surface one node backwards */
#define TSURFNEXT x[nodes+n+1]   /* T surface next node */
#define DTDTSURF  dx[nodes+n]    /* dT/dt surface */
#define TCOLD     x[2*nodes+n]   /* T cold side */
#define TCOLDBACK x[2*nodes+n-1] /* T cold one node backwards */
#define TCOLDNEXT x[2*nodes+n+1] /* T cold next node */
#define DTDTCOLD  dx[2*nodes+n]  /* dT/dt cold side */
#define TWALL     x[3*nodes+n]   /* T wall */
#define TWALLBACK x[3*nodes+n-1] /* T wall one node backwards */
#define TWALLNEXT x[3*nodes+n+1] /* T wall next node */
#define DTDTWALL  dx[3*nodes+n]  /* dT/dt wall */
                             
/* define inputs for easy access to u-vector */
#define TAMB       (*u[0])      /* ambient temperature */
#define FLOW_ID_H  (*u[1])      /* flow id hot side */
#define TINHOT     (*u[2])      /* inlet temperature hot side */
#define MDOTHOT    (*u[3])      /* massflow hot side */
#define PRESSHOT   (*u[4])      /* pressure hot side */
#define FLUID_ID_H (*u[5])      /* fluid ID (defined in CARNOT.h) */
#define PERCENT_H  (*u[6])      /* mixture  (defined in CARNOT.h) */
#define FLOW_ID_C  (*u[7])      /* flow id cold side */
#define TINCOLD    (*u[8])      /* inlet temperature cold side */
#define MDOTCOLD   (*u[9])      /* massflow cold side */
#define PRESSCOLD  (*u[10])     /* pressure cold side */
#define FLUID_ID_C (*u[11])     /* fluid ID (defined in CARNOT.h) */
#define PERCENT_C  (*u[12])     /* mixture  (defined in CARNOT.h) */
#define N_INPUTS     13




/*
 * mdlInitializeSizes - initialize the sizes array
 *
 * The sizes array is used by SIMULINK to determine the S-function block's
 * characteristics (number of inputs, outputs, states, etc.).
 */

static void mdlInitializeSizes(SimStruct *S)
{
    ssSetNumSFcnParams(S, N_PARAMETER);  /* Number of expected parameters */
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S))
    {
        /* Return if number of expected != number of actual parameters */
        return;
    }
    
    ssSetNumContStates(S, 4*(int_T)NODES); /* number of continuous states */
    ssSetNumDiscStates(S, 0);       /* number of discrete states */
    if (!ssSetNumInputPorts(S, N_INPUTS))
    {
        return;
    }
    ssSetInputPortDirectFeedThrough(S, 0, 1);
    
    if (!ssSetNumOutputPorts(S, 1))
    {
        return;
    }
    ssSetOutputPortWidth(S, 0, 4);

    ssSetNumSampleTimes(S, 1);      /* number of sample times */
    ssSetNumRWork(S, 0); /* number of real work vector elements */
    ssSetNumIWork(S, 0); /* number of integer work vector elements */
    ssSetNumPWork(S, 0); /* number of pointer work vector elements */
    
    ssSetSimStateCompliance(S, USE_DEFAULT_SIM_STATE);
    ssSetSimStateVisibility(S, 1);
    
    ssSupportsMultipleExecInstances(S, true);
}

/*
 * mdlInitializeSampleTimes - initialize the sample times array
 *
 * This function is used to specify the sample time(s) for your S-function.
 * If your S-function is continuous, you must specify a sample time of 0.0.
 * Sample times must be registered in ascending order.  If your S-function
 * is to acquire the sample time of the block that is driving it, you must
 * specify the sample time to be INHERITED_SAMPLE_TIME.
 */

static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, 0.0);
    ssSetOffsetTime(S, 0, 0.0);
}


/*
 * mdlInitializeConditions - initialize the states
 *
 * In this function, you should initialize the continuous and discrete
 * states for your S-function block.  The initial states are placed
 * in the x0 variable.  You can also perform any other initialization
 * activities that your S-function may require.
 */
#define MDL_INITIALIZE_CONDITIONS
static void mdlInitializeConditions(SimStruct *S)
{
    double t0 = TINI;           /* initial temperature as parameter */
    int    nodes = (int)NODES;  /* numer of nodes as parameter */
    int    n;
    real_T *x0   = ssGetContStates(S);

    for (n = 0; n < 4*nodes; n++)
    {
        x0[n] = t0;             /* state-vector is initialized with TINI */
    }
}


/*
 * mdlOutputs - compute the outputs
 */

static void mdlOutputs(SimStruct *S, int_T tid)
{
    InputRealPtrsType u = ssGetInputPortRealSignalPtrs(S, 0);
    real_T *y           = ssGetOutputPortRealSignal(S, 0);
    real_T *x           = ssGetContStates(S);
    double dplinhot     = DPLHOT;
    double dpquahot     = DPQHOT;
    double dptemphot    = DPTHOT;
    double dplincold    = DPLCOLD;
    double dpquacold    = DPQCOLD;
    double dptempcold   = DPTCOLD;
    int    nodes = (int)NODES;  /* numer of nodes as parameter */

    double tmhot, tmcold, phot, pcold;
    int n;

    phot = PRESSHOT;
    pcold = PRESSCOLD;

    /* average pipe temperature */
    tmhot  = 0.0;
    tmcold = 0.0;
    for (n = FIRST_NODE; n <= LAST_NODE; n++)
    {
        tmhot  += THOT;
        tmcold += TCOLD;
    }
    tmhot  = tmhot /(double)nodes;
    tmcold = tmcold/(double)nodes;

    /* friction */
    if (FLOW_ID_H > 10000.0)
    {
        phot  -= (dpquahot*MDOTHOT+dplinhot)*MDOTHOT + dptemphot*tmhot;
    }
    if (FLOW_ID_C > 10000.0)
    {
        pcold -= (dpquacold*MDOTCOLD+dplincold)*MDOTCOLD + dptempcold*tmcold;
    }

    /* set outputs */
    n = LAST_NODE;
    y[0] = THOT;    /* temperature */
    y[1] = phot;    /* pressure */
    y[2] = TCOLD;   /* temperature */
    y[3] = pcold;   /* pressure */

    /* printf("ID %g pipe p %g mdot %g \n",FLOW_ID, p, MDOT);*/
}




/*
 * mdlDerivatives - compute the derivatives
 *
 * In this function, you compute the S-function block's derivatives.
 * The derivatives are placed in the dx variable.
 */
#define MDL_DERIVATIVES
static void mdlDerivatives(SimStruct *S)
{
    /* define and get parameters */
    real_T            *dx = ssGetdX(S);
    real_T            *x  = ssGetContStates(S);
    InputRealPtrsType u   = ssGetInputPortRealSignalPtrs(S, 0);
    double vhot = V_HOT;
    double vcold = V_COLD;
    double ualoss = UALOSS; 
    double uaconsthot = UACHOT;
    double ualinhot = UALHOT;
    double uaconstcold = UACCOLD;
    double ualincold = UALCOLD;
    double uaconstwall = UACWALL;
    double ualinwall = UALWALL;
    double material = MATERIAL;
    double mass = MASS;
    double fracin = FRAC_IN;
    double dnodes = NODES;
    int    nodes = (int)dnodes;  /* numer of nodes as parameter */

    double cphot, cpcold, rhohot, rhocold, uawall,
        flowhot, flowcold, uahot, uacold, caph, capc, caps, capw;
    int n;

    /* material properties at temperature of last node
       to avoid function calls at every node */
    n = LAST_NODE;
    rhohot  = density(FLUID_ID_H, PERCENT_H, THOT, PRESSHOT);
    rhocold = density(FLUID_ID_C, PERCENT_C, TCOLD, PRESSCOLD);
    cphot  = heat_capacity(FLUID_ID_H, PERCENT_H, THOT, PRESSHOT);
    cpcold = heat_capacity(FLUID_ID_C, PERCENT_C, TCOLD, PRESSCOLD);
    caph = vhot*cphot*rhohot;
    capc = vcold*cpcold*rhocold;
    caps = mass*fracin*heat_capacity_solid(material,TSURF);
    capw = mass*(1.0-fracin)*heat_capacity_solid(material,TWALL);

    /* set heat transport terms */
    flowhot  = MDOTHOT*dnodes/(vhot*rhohot);
    flowcold = MDOTCOLD*dnodes/(vcold*rhocold);
    uahot    = uaconsthot+ualinhot*MDOTHOT;
    uacold   = uaconstcold+ualincold*MDOTCOLD;
    uawall   = uaconstwall+ualinwall*MDOTCOLD;

    for (n = FIRST_NODE; n <= LAST_NODE; n++)
    {
        /* heat transfer */
        DTDTHOT  = uahot/caph*(TSURF-THOT);
        DTDTSURF = (uahot*(THOT-TSURF)+uacold*(TCOLD-TSURF))/caps;
        DTDTCOLD = (uacold*(TSURF-TCOLD)+uawall*(TWALL-TCOLD))/capc;
       	DTDTWALL = (uawall*(TCOLD-TWALL)+ualoss*(TAMB-TWALL))/capw;

        if (n > FIRST_NODE)
        { /* flow */
            DTDTHOT += flowhot*(THOTBACK-THOT);
            DTDTCOLD += flowcold*(TCOLDBACK-TCOLD);
        }
        else
        {
            DTDTHOT += flowhot*(TINHOT-THOT); /* first node: T from inlet */
            DTDTCOLD += flowcold*(TINCOLD-TCOLD);
        }
    } /* end for */
}

/*
 * mdlTerminate - called when the simulation is terminated.
 *
 * In this function, you should perform any actions that are necessary
 * at the termination of a simulation.  For example, if memory was allocated
 * in mdlInitializeConditions, this is the place to free it.
 */

static void mdlTerminate(SimStruct *S)
{
}

#ifdef	MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif

