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
 * mixer for two flows, use enthalpy balance for humid air. For liquids the
 * more simple, less accurate but faster method can be chosen:
 * Tmix = (mdot1*T1 + mdot2*T2)/(mdot1+mdot2)
 *
 * Syntax  [sys, x0] = mix_temperature(t,x,u,flag)
 *
 * author list:     cw -> Carsten Wemhoener
 *                  hf -> Bernd Hafner
 *                  tw -> Thomas Wenzel
 *                  gf -> Gaelle Faure
 *                  aw -> Arnold Wohlfeil
 *
 * version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
 *
 * Version  Author  Changes                                       Date
 * 0.8.0    hf      created                                       16jul1998
 * 0.10.0   hf      flowID is no longer input, it                 14dec1998
 *                      created algebraic loops
 * 1.0.0    hf      changed if (mdot == 0) to                     16jul1999
 *                      if (mdot < NO_MASSFLOW)
 * 1.1.0    hf      temperatures have continuous states           12aug1999
 * 1.1.1    tw      temperature for mixture of air                18jan2000
 * 4.1.0    hf      new inports for c,l,q                         21oct2009
 * 4.1.1    gf      correction quadratic coefficient calculus     15oct2010
 * 4.1.2    gf      correction for the beginning of the           17dec2010
 *                      simulation : add the case there is no
 *                      massflow -> fdiv = 0.5
 * 4.1.3    gf      test of too many iterations for               08nov2011
 *                      enthalpy2temperature
 * 4.1.4    gf      debug call to enthalpy2temperature            17nov2011
 * 6.1.0    hf      separated function for temperature            09mar2013
 * 6.1.1    aw      SimStateCompiliance and                       11aug2015
 *                  MultipleExecInstances activated
 * 6.1.2    aw      tab does not need memory allocation here;     15sep2015
 *                  this is done in carlib.c
 *                  comparison of equality of doubles
 *                  corrected
 *                          
 *
 * Copyright (c) 1998 Solar-Institut Juelich, Germany
 * 
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *  D E S C R I P T I O N
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * This file is same as mixer2.c but has internal conditions for temperature
 */


/*
 * You must specify the S_FUNCTION_NAME as the name of your S-function
 * (i.e. replace sfuntmpl with the name of your S-function).
 */

#define S_FUNCTION_NAME  mix_temperature
#define S_FUNCTION_LEVEL 2

#define T1          (*u1Ptrs[0])    /* temperature 1 */
#define MDOT1       (*u1Ptrs[1])    /* massflow 1 */
#define P1          (*u1Ptrs[2])    /* pressure 1 */
#define FLUID1      (*u1Ptrs[3])    /* fluid type 1 */
#define MIX1        (*u1Ptrs[4])    /* fluid mix 1 */
#define NIN1                 5

#define T2          (*u2Ptrs[0])     /* temperature 2 */
#define MDOT2       (*u2Ptrs[1])     /* massflow 2 */
#define P2          (*u2Ptrs[2])     /* pressure 2 */
#define FLUID2      (*u2Ptrs[3])     /* fluid type 2 */
#define MIX2        (*u2Ptrs[4])     /* fluid mix 3 */
#define NIN2                 5

#define MIXCALC   *mxGetPr(ssGetSFcnParam(S,0)) /* calculation of mixing */

/*
 * Need to include simstruc.hfor the definition of the SimStruct and
 * its associated macro definitions.
 */
#include "simstruc.h"

#include "carlib.h"     /* for some specific defines in Carnot */
#include <math.h>       /* for function sqrt */


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
    ssSetNumSFcnParams(S, 1);  /* Number of expected parameters */
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S))
    {
        /* Return if number of expected != number of actual parameters */
        return;
    }
    ssSetNumContStates(S, 0);
    ssSetNumDiscStates(S, 0);

    if (!ssSetNumInputPorts(S, 2))
    {
        return;
    }
    ssSetInputPortWidth(S, 0, NIN1);
    ssSetInputPortDirectFeedThrough(S, 0, 1);
    ssSetInputPortWidth(S, 1, NIN2);
    ssSetInputPortDirectFeedThrough(S, 1, 1);

    if (!ssSetNumOutputPorts(S, 2))
    {
        return;
    }
    ssSetOutputPortWidth(S, 0, 1);
    ssSetOutputPortWidth(S, 1, 1);

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



/* Function: mdlOutputs =======================================================
 * Abstract:
 *    In this function, you compute the outputs of your S-function
 *    block. Generally outputs are placed in the output vector, ssGetY(S).
 */
static void mdlOutputs(SimStruct *S, int_T tid)
{
    InputRealPtrsType u1Ptrs = ssGetInputPortRealSignalPtrs(S,0);
    InputRealPtrsType u2Ptrs = ssGetInputPortRealSignalPtrs(S,1);
    real_T *y1               = ssGetOutputPortRealSignal(S,0);
    real_T *y2               = ssGetOutputPortRealSignal(S,1);

    real_T mdotsum;
    double *tab = NULL;

    mdotsum = MDOT1+MDOT2;
    
    if (mdotsum < NO_MASSFLOW)      /* if sum of massflows < limit: no massflow */
    {
        y1[0] = 0.5*(T1+T2);        /* average temperature */
        y2[0] = 0.5*(MIX1+MIX2);    /* average mixture */
    }
    else if (MDOT2 < NO_MASSFLOW)   /* else if massflow in path 2 < limit */
    {
        y1[0] = T1;
        y2[0] = MIX1;               /* mixture from path 1 */
    }
    else if (MDOT1 < NO_MASSFLOW)   /* else if massflow in path 1 < limit */
    {
        y1[0] = T2;
        y2[0] = MIX2;               /* mixture from path 2 */
    }
    else                            /* both pathes open */
    {
        if ((int)(MIXCALC+0.5) == 2                                              /* if enthalpy calculation required */
            || ((int)(FLUID1+0.5))==AIR || ((int)(FLUID2+0.5))==AIR)    /* or if mixture of air */
        {
            double h1,h2,hges,Pges;
        
            h1 = enthalpy(FLUID1,MIX1,T1,P1);
            h2 = enthalpy(FLUID2,MIX2,T2,P2);
            hges = (h1*MDOT1 + h2*MDOT2) / mdotsum;
            Pges = 0.5*(P1+P2);

            tab = enthalpy2temperature(FLUID1, MIX1, hges, Pges);
            y1[0] = tab[0];
            
            if (tab[1] >= 200.0)
            {
                printf("WARNING : in enthalpy2temperature, maximum authorized iterations (200) exceeded.\n");
            }
            free(tab);
        } 
        else            /* else use simplified method */
        {
            y1[0] = (MDOT1*T1+MDOT2*T2)/mdotsum;
            y2[0] = (MDOT1*MIX1+MDOT2*MIX2)/mdotsum;
        }
    }  /* end if mdotsum */
    
} /* end mdlOutputs */



#undef MDL_UPDATE  /* Change to #undef to remove function */
#if defined(MDL_UPDATE)
  /* Function: mdlUpdate ======================================================
   * Abstract:
   *    This function is called once for every major integration time step.
   *    Discrete states are typically updated here, but this function is useful
   *    for performing any tasks that should only take place once per
   *    integration step.
   */
  static void mdlUpdate(SimStruct *S, int_T tid)
  {
  }
#endif /* MDL_UPDATE */



#undef MDL_DERIVATIVES  /* Change to #undef to remove function */
#if defined(MDL_DERIVATIVES)
  /* Function: mdlDerivatives =================================================
   * Abstract:
   *    In this function, you compute the S-function block's derivatives.
   *    The derivatives are placed in the derivative vector, ssGetdX(S).
   */
  static void mdlDerivatives(SimStruct *S)
  {
  }
#endif /* MDL_DERIVATIVES */



/* Function: mdlTerminate =====================================================
 * Abstract:
 *    In this function, you should perform any actions that are necessary
 *    at the termination of a simulation.  For example, if memory was
 *    allocated in mdlInitializeConditions, this is the place to free it.
 */
static void mdlTerminate(SimStruct *S)
{
}


/*======================================================*
 * See sfuntmpl.doc for the optional S-function methods *
 *======================================================*/

/*=============================*
 * Required S-function trailer *
 *=============================*/

#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif

