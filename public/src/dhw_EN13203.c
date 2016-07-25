/*
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
 * dhw_EN13203 mex file for single-output state-space system.
 *
 * This MEX-file enables to perform the tapping profiles of european norm
 * 13203.
 *
 * This function calculates final times of the tapes with the gived 
 * energies and start times. It then changes the mass flow and set 
 * temperature at right time.
 *
 * Note : between 2 tapes, outputs are null.
 *
 * structure of y (output vector)
 *  port    use
 *  0       mass flow                           kg/s
 *  1       set temperature                     °C
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * Author gf -> Gaelle Faure
 *
 * Version  Author  Changes                                         Date
 * 5.0.0    gf      created                                         21fev2012
 * 5.0.1    gf      debug for start time different from 0           20mar2012
 *
 */

#define S_FUNCTION_NAME  dhw_EN13203
#define S_FUNCTION_LEVEL 2

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
#define TIMES      ( mxGetPr(ssGetSFcnParam(S,0)))  /* vector of tapping start in seconds */
#define ENERGIES   ( mxGetPr(ssGetSFcnParam(S,1)))  /* vector of energies in J            */
#define MDOT_COEFF ( mxGetPr(ssGetSFcnParam(S,2)))  /* vector of coefficient of on massflow   */
#define DELTA_TSET ( mxGetPr(ssGetSFcnParam(S,3)))  /* vector of set temperatures   */
#define MDOT_NOM   (*mxGetPr(ssGetSFcnParam(S,4)))  /* nominal massflow   */
#define N_PARAMETER                           5

#define DELTA_T     (x0[0])
#define T_ADD       (x0[1])
#define NDISCSTATES     2

#define TCOLD        (*u[0])    /* cold water inlet temperature */

#define FIRST_TAP   (iwork[0])
#define LAST_TAP    (iwork[1])
#define I_TINIT     (iwork[2])
#define I_TEND      (iwork[3])
#define NB_CYCLES   (iwork[4])  /* number of cycles since the time 0 */
#define N_TAP       (iwork[5])  /* number of tapping in the cycle     */  
#define NIWORK             6

#define T_FIN(n)    (rwork[n])          /* vector of final times */
#define ACTIF(n)    (rwork[N_TAP+n])  /* vector of booleans to know if a tapping is in progress */

#define SEC_IN_CYCLE    86400.0 /* for the moment, a cycle is a day 86400 = 24*3600*/

void calcule_addTime(SimStruct *S, time_T refTime) {
    
    real_T *x0      = ssGetRealDiscStates(S);
    int_T  *iwork   = ssGetIWork(S);
    real_T *rwork   = ssGetRWork(S);
    int_T i;
    real_T T_min;
    
    if (I_TINIT < N_TAP)
    {
        /** Determine Tmin in possible times */
        T_min = TIMES[I_TINIT];
        for (i=I_TINIT; i>=I_TEND; i--) {
            if (T_FIN(i)<T_min && T_FIN(i)+ NB_CYCLES*SEC_IN_CYCLE>refTime)
                T_min = T_FIN(i);
        }
        
        /** Determine T_ADD **/
        T_ADD = T_min + NB_CYCLES*SEC_IN_CYCLE - refTime;
        
        /** Update I_TINIT and I_TEND **/
        if (TIMES[I_TINIT]==T_min) {
            I_TINIT++;
        }
        if (T_min == T_FIN(I_TEND)) {
            I_TEND++;
            while (T_FIN(I_TEND)+ NB_CYCLES*SEC_IN_CYCLE<=refTime) /** Do the cleaning **/
                I_TEND++;
        }
        
    } else if (I_TEND<N_TAP) { /** the last cycles began. **/
        /** Determine T_ADD **/
        T_ADD = T_FIN(I_TEND)+ NB_CYCLES*SEC_IN_CYCLE - refTime;
        I_TEND++;
    } else { /** tapes of the cycle are finished. */
        NB_CYCLES++;
        T_ADD = TIMES[0]+ NB_CYCLES*SEC_IN_CYCLE - refTime;
        I_TEND = 0;
        I_TINIT = 1;
    }
}

/*====================*
 * S-function methods *
 *====================*/

#define MDL_CHECK_PARAMETERS
#if defined(MDL_CHECK_PARAMETERS) && defined(MATLAB_MEX_FILE)
  /* Function: mdlCheckParameters =============================================
   * Abstract:
   *    Validate our parameters to verify they are okay.
   */
  static void mdlCheckParameters(SimStruct *S)
  {
      int_T  n_tap;
      int_T i;

      n_tap = (int_T)mxGetNumberOfElements(ssGetSFcnParam(S,0)); // size of TIMES
      
      /* */
      {
          if (n_tap == 0) { 
              ssSetErrorStatus(S,"Error in dhw_EN13203: minimum one tapping.");
              return;
          }
      }
      /* */
      {
            for (i=1; i<4; i++)
                if ((int_T)mxGetNumberOfElements(ssGetSFcnParam(S,1)) != n_tap) {
                    ssSetErrorStatus(S, "Error in dhw_EN13203 : all vectors must have the same length.");
                    return;
                }
      }
      /* */
      {
          if (TIMES[0]<0) {
              ssSetErrorStatus(S, "Error in dhw_EN13203 : tapping times must be positive.");
              return;
          }
      }
      /* */
      {
          if (n_tap>1)
              for (i=0;i<n_tap-1;i++)
                  if (TIMES[i] > TIMES[i+1]) {
                    ssSetErrorStatus(S, "Error in dhw_EN13203 : tapping times must be monotically increasing.");
                    return;
                  }
      }
  }
#endif /* MDL_CHECK_PARAMETERS */

/* Function: mdlInitializeSizes ===============================================
 * Abstract:
 *    The sizes information is used by Simulink to determine the S-function
 *    block's characteristics (number of inputs, outputs, states, etc.).
 */
static void mdlInitializeSizes(SimStruct *S)
{
    int_T  n_tap;

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

    n_tap = (int_T)mxGetNumberOfElements(ssGetSFcnParam(S,1));
    
    ssSetNumContStates(S, 0);
    ssSetNumDiscStates(S, NDISCSTATES);

    if (!ssSetNumInputPorts(S, 1)) return;
    ssSetInputPortWidth(S, 0, 1);
    ssSetInputPortDirectFeedThrough(S, 0, 1);

    if (!ssSetNumOutputPorts(S, 2)) return;
    ssSetOutputPortWidth(S, 0, 1);
    ssSetOutputPortWidth(S, 1, 1);

    ssSetNumSampleTimes(S, 1);
    ssSetNumRWork(S, 2*n_tap);
    ssSetNumIWork(S, NIWORK);
    ssSetNumPWork(S, 0);
    ssSetNumModes(S, 0);
    ssSetNumNonsampledZCs(S, 0);

    /* Specify the sim state compliance to be same as a built-in block */
    ssSetSimStateCompliance(S, USE_DEFAULT_SIM_STATE);

    ssSetOptions(S, 0);
}



/* Function: mdlInitializeSampleTimes =========================================
 * Abstract:
 *    This function is used to specify the sample time(s) for your
 *    S-function. You must register the same number of sample times as
 *    specified in ssSetNumSampleTimes.
 */
static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, VARIABLE_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, 0.0);
    ssSetModelReferenceSampleTimeDefaultInheritance(S);
}

//#define MDL_START                      /* Change to #undef to remove function */
//#if defined(MDL_START)
/* Function: mdlStart ==========================================================
 */
//static void mdlStart(SimStruct *S)
//{
//#endif /*  MDL_START */


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
    real_T *x0 = ssGetRealDiscStates(S);
    int_T *iwork  = ssGetIWork(S);
    real_T *rwork   = ssGetRWork(S);
    real_T cp, dt;
    int_T i;

    NB_CYCLES = (int_T) (ssGetTStart(S)/(SEC_IN_CYCLE));
    N_TAP = (int_T)mxGetNumberOfElements(ssGetSFcnParam(S,1));
    
    /** Initialization of final times and active tables **/
    for (i=0 ; i<N_TAP; i++)
        ACTIF(i) = 0;
    
    for (i=0 ; i<N_TAP; i++) 
    {
        cp = heat_capacity(WATER, 0, DELTA_TSET[i]*0.5+10.0, 3.0e5);
        dt = ENERGIES[i] / (cp*MDOT_NOM*MDOT_COEFF[i]*DELTA_TSET[i]);
        T_FIN(i) = TIMES[i]+dt;
        
        if (TIMES[i]>SEC_IN_CYCLE || T_FIN(i)>SEC_IN_CYCLE) {
            ssSetErrorStatus(S, "Error in dhw_EN13203: the times of at least one tape is above one cycle.");
            return;
        }
    }

    /* Init ACTIF vector */
    DELTA_T = 0.0;

    for (i=0 ; i<N_TAP ; i++) {
        if ( (TIMES[i]+ NB_CYCLES*SEC_IN_CYCLE)<=ssGetTStart(S) && (T_FIN(i)+ NB_CYCLES*SEC_IN_CYCLE)>ssGetTStart(S) ) {
            ACTIF(i) = 1;
            
            if (DELTA_T == 0.0) {
                DELTA_T = DELTA_TSET[i];
            } else if (DELTA_T != DELTA_TSET[i]) {
                    ssSetErrorStatus(S, "Error in dhw_EN13203 : two tapping in the same time with different tsets is impossible.");
                    return;
            }
            
        } else {
            ACTIF(i) = 0;
        }
    }


    
    /* Init I_TINIT */
    i = 0;
    while ( i<N_TAP && (TIMES[i]+ NB_CYCLES*SEC_IN_CYCLE)<=ssGetTStart(S) )
        i++;
    I_TINIT = i;
    
    /* Init I_TEND */
    while ( i>=0 && (T_FIN(i)+ NB_CYCLES*SEC_IN_CYCLE)>ssGetTStart(S) )
        i--;
    I_TEND = i+1;
    
    /* Init T_ADD */
    calcule_addTime(S, ssGetTStart(S));

  }
#endif /* MDL_INITIALIZE_CONDITIONS */


#define MDL_GET_TIME_OF_NEXT_VAR_HIT
static void mdlGetTimeOfNextVarHit(SimStruct *S)
{
    real_T *x0 = ssGetRealDiscStates(S);

    /* Make sure input will increase time */
    if (T_ADD <= 0.0) {
        ssPrintf("T_ADD = %f.\n",T_ADD);
        /* If not, abort simulation */
        ssSetErrorStatus(S,"Error in dhw_EN13203 : Variable step control input must be "
                         "greater than zero");
        return;
    }
    ssSetTNext(S, ssGetT(S)+T_ADD);
}

/* Function: mdlOutputs =======================================================
 * Abstract:
 *    In this function, you compute the outputs of your S-function
 *    block.
 */
static void mdlOutputs(SimStruct *S, int_T tid)
{
    InputRealPtrsType   u = ssGetInputPortRealSignalPtrs(S,0);
    real_T            *x0 = ssGetRealDiscStates(S);
    int_T          *iwork = ssGetIWork(S);
    //void          **pwork = ssGetPWork(S);
    real_T *rwork   = ssGetRWork(S);
    real_T            *y0 = ssGetOutputPortSignal(S,0);
    real_T            *y1 = ssGetOutputPortSignal(S,1);
    int_T i;

    y0[0] = 0.0;
    for (i=0; i<N_TAP; i++)
        y0[0] += MDOT_NOM*MDOT_COEFF[i]*ACTIF(i);

    y1[0] = DELTA_T + TCOLD;
}



#define MDL_UPDATE  /* Change to #undef to remove function */
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
    real_T *x0 = ssGetRealDiscStates(S);
    int_T  *iwork   = ssGetIWork(S);
    //void   **pwork = ssGetPWork(S);
    real_T *rwork   = ssGetRWork(S);
    int_T i;
    //real_T T_min;

    // printf("mdlUpdate  \n");    
 
    DELTA_T = 0.0;
    for (i=0 ; i<N_TAP ; i++) 
    {
        if ( (TIMES[i]+ NB_CYCLES*SEC_IN_CYCLE)<=ssGetTNext(S) && (T_FIN(i)+ NB_CYCLES*SEC_IN_CYCLE)>ssGetTNext(S) ) 
        {
            ACTIF(i) = 1;
            if (DELTA_T == 0.0) 
            {
                DELTA_T = DELTA_TSET[i];
            }
            else if (DELTA_T != DELTA_TSET[i]) 
            {
                    ssSetErrorStatus(S, "Error in dhw_EN13203 : two tapping in the same time with different tsets is impossible.");
                    return;
            }
        } else {
            ACTIF(i) = 0;
        }
    }
    
    /* Update T_ADD */
    calcule_addTime(S, ssGetTNext(S));
    
}
#endif /* MDL_UPDATE */



#undef MDL_DERIVATIVES  /* Change to #undef to remove function */
#if defined(MDL_DERIVATIVES)
/* Function: mdlDerivatives =================================================
 * Abstract:
 *    In this function, you compute the S-function block's derivatives.
 *    The derivatives are placed in the derivative vector, ssGetdX(S).
 */
static void mdlDerivatives(SimStruct *S) {
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
