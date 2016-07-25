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
 * heat exchanger with capacity
 *
 * Syntax  [sys, x0] = heatexch(t,x,u,flag)
 *
 * Version  Author          Changes                                         Date
 * 0.4.0    Bernd Hafner    created                                         04apr98
 * 0.5.0    hf              toolbox name changed to CARNOT                  30apr98
 * 0.5.1    hf              heat transfer has linear massflow               11mai98
 *                              dependance
 * 0.5.2    hf              material properties from carlib                 20mai98
 * 0.7.0    hf              switch pressure calculation                     12jun98
 *                          ID <=10000 no pressure calculation
 *                          ID <=20000 only pressure drop
 *                          ID > 20000 pressure drop and static pressure
 * 0.8.0    hf              new pressure drop calculation                   13jul98
 *                          dp = dp0 + dp1*mdot + dp2*mdot^2
 *                          solve: dp = a0 + a1*mdot + a2*mdot^2
 * 1.0.0    hf              new heat transfer correlation:                  02jan00
 *                          ua = ua0 * ( (mdothot/mdot_nomhot)^ua_exphot
 *                             + (mdotcold/mdot_nomcold)^ua_expcold )
 *                          with new parameters
 *                              ua0, ua_exphot, ua_expcold, 
 *                              mdot_nomhot, mdot_nomcold
 * 1.0.1    hf              changed to level2 S-function                    22jan00
 *                          new outputs added (energy balance)
 *
 * 1.0.2    hf              new calculation of outport temperature          27feb01
 *                          during stand-still (no massflow)
 *
 * 1.53     hf,cw           changes concerning mdot = 0;                    5mar01
 *                          1. if-loop for denominator of psi in 
 *                              case of counter-flow
 *                          2. changes for heat capacity flow 
 *                             characteristic (wcold = 0.0 in case 
 *                             of mcold = 0)
 *                          3. output temperatures changed for mdot = 0    
 *                          4. pressure drop calculation in simulink, 
 *                             not in S-function (avoids algebraic loop)
 *
 * 1.53    cw               elimination of jump in outlet temperature       22mar01
 *                          by saving the last value before switch in 
 *                          rwork 
 * 1.64    cw               change input to direct feedthrough              19feb03
 *                          (required by matlab R 13)
 * 1.65    Gaelle Faure     add call to mdlCheckParamter in                 10fev11
 *                          mdlInitializeSizes
 * 6.1.0   hf               remove all pressure drop relevant inputs, 20oct13
 *                          keep only thermal inputs
 *
 * Copyright (c) 1998 Solar-Institut Juelich, Germany
 * 
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *  D E S C R I P T I O N
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * The heat exchanger is characterized by the number of transfer units.
 * Input temperatures are delayed by the heat capacity of the exchanger.
 * Parallel, cross and counter flow are possible.
 *
 *  T_hot_out  = T_hot_in  - psi * (T_hot_in - Tcold_in)
 *
 *  T_cold_out = T_cold_in - W_hot/W_cold * (T_hot_in - T_hot_out)
 *
 *  ntu = ua / W;
 *
 *  ua = ua0 * ( (mdothot/mdot_nomhot)^ua_exphot
 *     + (mdotcold/mdot_nomcold)^ua_expcold )
 *
 *  p1  = exp(-ntu*(1.0 + w1to2*(1.0 - 2.0*flowtype)));
 *
 *  psi = (1.0-p1) / (1.0+w1to2*(1.0-flowtype*(1.0+p1)));
 *
 * the delay for the inlet temperature is:
 *
 *  (0.5*cap)*dT/dt = (T_in - T) - UAloss * (Tamb - T)
 *
 * symbol       used for                                        unit
 *  cap         mass * heat capacity                            J/K
 *  psi         dimensionless temperature change                -
 *  flowtype    0 = parallel, 0.5 = cross, 1 = counter
 *  T           temperature                                     K
 *  t           time                                            s
 *  UAloss      heat losses                                     W/K
 *  W_hot       massflow * capacity hot flow                    W/K
 *  W_cold      massflow * capacity cold flow                   W/K
 *         
 *
 * input vector and parameters see define below
 *
 * structure of y (output vector)
 *  port    use
 *  0       temperature hot part                         °C
 *  1       pressure hot part                            Pa  
 *  2       temperature cold part                        °C  
 *  3       pressure cold part                           Pa  
 *  4       energy exchanged between flows               J
 */

/* specify the name of your S-Function */

#define S_FUNCTION_NAME heatexch
#define S_FUNCTION_LEVEL 2

/*
 * Need to include simstruc.h for the definition of the SimStruct and
 * its associated macro definitions. Need math.h for exp-function.
 */
#include "tmwtypes.h"
#include "simstruc.h"
#include "carlib.h"
#include <math.h>

/* parameters */
#define FLOWTYPE *mxGetPr(ssGetSFcnParam(S,0)) /* flow 0 = parallel, 0.5 = cross, 1 = counter */
#define UA_0     *mxGetPr(ssGetSFcnParam(S,1)) /* constant heat transfer W/K */
#define MDOTNOMH *mxGetPr(ssGetSFcnParam(S,2)) /* nominal massflow hot side (for ua-correction) */
#define UA_EXPH  *mxGetPr(ssGetSFcnParam(S,3)) /* exponent for heat transfer correction hot side */
#define MDOTNOMC *mxGetPr(ssGetSFcnParam(S,4)) /* nominal massflow cold side (for ua-correction) */
#define UA_EXPC  *mxGetPr(ssGetSFcnParam(S,5)) /* exponent for heat transfer correction cold side */
#define UALOSS   *mxGetPr(ssGetSFcnParam(S,6)) /* heat losses [W/K] */
#define CAP      *mxGetPr(ssGetSFcnParam(S,7)) /* mass * capacity  J/K*/
#define TINI     *mxGetPr(ssGetSFcnParam(S,8)) /* initial pipe temperature [°C] */
#define N_PARAMETER                        9   /* number of parameters */
/* flow characteristic 0   = counter flow
 *                     0.5 = cross flow
 *                     1   = parallel flow
 */

/* inputs */
#define TAMB         (*u0[0])   /* temperature outside */

#define T_HOT_IN     (*u1[0])   /* inlet temperature hot part */
#define MDOT_HOT     (*u1[1])   /* massflow hot part */
#define P_HOT        (*u1[2])   /* pressure hot part */
#define FLUID_HOT    (*u1[3])   /* fluid ID hot part */
#define PERCENT_HOT  (*u1[4])   /* mixture hot part */

#define T_COLD_IN    (*u2[0])   /* inlet temperature cold part */ 
#define MDOT_COLD    (*u2[1])   /* massflow cold part */
#define P_COLD       (*u2[2])   /* pressure cold part */
#define FLUID_COLD   (*u2[3])   /* fluid ID cold part */
#define PERCENT_COLD (*u2[4])   /* mixture cold part */

/* state space */
#define T_HOT      x[0]      /* hot node temperature */
#define DTDT_HOT  dx[0]
#define T_COLD     x[1]      /* cold node temperature */
#define DTDT_COLD dx[1]


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
          if (FLOWTYPE < 0 || FLOWTYPE > 1) {
              ssSetErrorStatus(S,"Error in heatexchanger: flowtype must be in range 0..1");
              return;
          }
      }
      /* */
      {
          if (UA_0 <= 0) {
              ssSetErrorStatus(S,"Error in heatexchanger: heat transfer must be > 0");
              return;
          }
      }
      /* */
      {
          if (MDOTNOMH <= 0 || MDOTNOMC <= 0) {
              ssSetErrorStatus(S,"Error in heatexchanger: nominal massflow must be > 0");
              return;
          }
      }
      /* */
      {
          if (UA_EXPH < 0 || UA_EXPC < 0) {
              ssSetErrorStatus(S,"Error in heatexchanger: "
                    "exponent for heat transfer correction must be >= 0");
              return;
          }
      }
      /* */
      {
          if (UALOSS < 0) {
              ssSetErrorStatus(S,"Error in heatexchanger: heat loss coefficient must be >= 0");
              return;
          }
      }
      /* */
      {
          if (CAP < 1.0e-3) {
              ssSetErrorStatus(S,"Error in heatexchanger: heat capacity must be > 1.0e-3");
              return;
          }
      }
      /* */
      {
          if (TINI < -273.15) {
              ssSetErrorStatus(S,"Error in heatexchanger: initial temperature must be > -273.15°C");
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

    ssSetNumContStates(S, 2);
    ssSetNumDiscStates(S, 0);

    if (!ssSetNumInputPorts(S, 3)) return;
    ssSetInputPortWidth(S, 0, 1);
    ssSetInputPortDirectFeedThrough(S, 1, 1);
    ssSetInputPortWidth(S, 1, 5);
    ssSetInputPortDirectFeedThrough(S, 1, 1);
    ssSetInputPortWidth(S, 2, 5);
    ssSetInputPortDirectFeedThrough(S, 2, 1);

    if (!ssSetNumOutputPorts(S, 3)) return;
    ssSetOutputPortWidth(S, 0, 1);
    ssSetOutputPortWidth(S, 1, 1);
    ssSetOutputPortWidth(S, 2, 1);

    ssSetNumSampleTimes(S, 1);
    ssSetNumRWork(S, 2);
    ssSetNumIWork(S, 0);
    ssSetNumPWork(S, 0);
    ssSetNumModes(S, 0);
    ssSetNumNonsampledZCs(S, 0);

#ifdef EXCEPTION_FREE_CODE
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
  static void mdlInitializeConditions(SimStruct *S)
  {
    real_T *x0 = ssGetContStates(S);
    real_T t0  = TINI;  /* initial temperature as parameter */

    x0[0] = t0;         /* state-vector is initialized with TINI */
    x0[1] = t0;
  }
#endif /* MDL_INITIALIZE_CONDITIONS */


/*
 * mdlOutputs - compute the outputs
 */
static void mdlOutputs(SimStruct *S, int_T tid)

{
/* definition of outputs:
 *  0       temperature hot part                         °C
 *  1       temperature cold part                        °C  
 *  2       energy exchanged between flows               J
 */
    real_T   *y0   = ssGetOutputPortRealSignal(S,0);
    real_T   *y1   = ssGetOutputPortRealSignal(S,1);
    real_T   *y2   = ssGetOutputPortRealSignal(S,2);
    real_T   *y3   = ssGetOutputPortRealSignal(S,3);
    real_T   *y4   = ssGetOutputPortRealSignal(S,4);
    real_T   *x    = ssGetContStates(S);

    InputRealPtrsType u1  = ssGetInputPortRealSignalPtrs(S,1);
    InputRealPtrsType u2  = ssGetInputPortRealSignalPtrs(S,2);

    real_T  *rwork    = ssGetRWork(S);


    double flowtype = FLOWTYPE;
    double whot, wcold, ntu, psi, w1, w1to2, ua, cp, p1, denom;
    int    normal;

    /* equations from Wagner: Waermeuebertragung, Vogel Verlag, 1991 */ 
    if (MDOT_COLD >= NO_MASSFLOW && MDOT_HOT >= NO_MASSFLOW)
    {
        /* heat capacity flow */
        cp = heat_capacity(FLUID_HOT, PERCENT_HOT, T_HOT, P_HOT);
        whot = MDOT_HOT*cp;
        wcold = MDOT_COLD*heat_capacity(FLUID_COLD,PERCENT_COLD,T_COLD,P_COLD);

        /* heat capacity flow characteristic number w1to2 */
        if (whot <= wcold) {
            w1 = whot;
            w1to2 = w1/wcold;
            normal = 1;
        } else {
            w1 = wcold;
            w1to2 = w1/whot;
            normal = 0;
        }

        /* heat transfer characteristic number  ntu = Number of Transfer Units */
        ua = UA_0 * (pow(MDOT_HOT/MDOTNOMH,UA_EXPH)+pow(MDOT_COLD/MDOTNOMC,UA_EXPC))*0.5;
        ntu = ua/w1; 

        /* heat exchanger characteristics: dimensionless temperature change */
        p1 = exp(-ntu*(1.0 + w1to2*(1.0 - 2.0*flowtype)));

        denom = (1.0+w1to2*(1.0-flowtype*(1.0+p1)));
        /* denominator = 0, if w1to2 = 1, i.e. if (m*cp)hot = (m*cp)cold */    
        if (denom==0)
            psi = ua/(ua+1);  /* equation for psi in case of w1to2=1                           */
                              /* from Renz: Kalorische Apparate, Vorlesungsumdruck RWTH Aachen */
        else
            psi = (1.0-p1)/(1.0+w1to2*(1.0-flowtype*(1.0+p1)));

        /* not yet corrected for crossflow exchangers, equation is
           correct only for NTU <= 2, for NTU = 4 error is about 5% */

        /* set outputs */
        if (normal) {
            y0[0] = T_HOT - psi*(T_HOT-T_COLD);     /* outlet T hot part */
            y1[0] = T_COLD + w1to2*(T_HOT-y0[0]);   /* outlet T cold part */
        } else {
            y1[0] = T_COLD - psi*(T_COLD-T_HOT);    /* outlet T cold part */
            y0[0] = T_HOT + w1to2*(T_COLD-y1[0]);   /* outlet T hot part */
        }
        y2[0] = cp*MDOT_HOT*(T_HOT-y0[0]);          /* power */

        rwork[0] = psi;
        rwork[1] = w1to2;
        
   } else { /* no massflow */
            y1[0] = T_COLD-rwork[0]*(T_COLD-T_HOT); /* outlet T cold part */
            y0[0] = T_HOT +rwork[1]*(T_COLD-y1[0]); /* outlet T hot part */
            y2[0] = 0.0;                            /* power */
   }     
}


/*
 * mdlUpdate - perform action at major integration time step
 *
 * This function is called once for every major integration time step.
 * Discrete states are typically updated here, but this function is useful
 * for performing any tasks that should only take place once per integration
 * step.
 */

static void mdlUpdate(real_T *x, const real_T *u, SimStruct *S, int_T tid)
{
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

    double ualoss = 0.5*UALOSS; /* half losses for one side */
    double invcap = 2.0/CAP; /* half capacity for one side */
   

    if (MDOT_COLD < NO_MASSFLOW)
        DTDT_COLD = invcap*(ualoss*(TAMB-T_COLD) + UA_0*(T_HOT-T_COLD));  
    else
        DTDT_COLD = invcap*(ualoss*(TAMB-T_COLD)
            + MDOT_COLD*(T_COLD_IN-T_COLD)
            *heat_capacity(FLUID_COLD, PERCENT_COLD, T_COLD_IN, P_COLD));

    if (MDOT_HOT < NO_MASSFLOW)
        DTDT_HOT = invcap*(ualoss*(TAMB-T_HOT) + UA_0*(T_COLD-T_HOT));  
    else
        DTDT_HOT = invcap*(ualoss*(TAMB-T_HOT)
            + MDOT_HOT*(T_HOT_IN-T_HOT)
            *heat_capacity(FLUID_HOT, PERCENT_HOT, T_HOT_IN, P_HOT));

} /* end mdlDerivatives */

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
