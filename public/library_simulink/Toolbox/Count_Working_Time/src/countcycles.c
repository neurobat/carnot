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
 *
 * version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
 *
 * author list:     gf -> Gaelle Faure
 *                  hf -> Bernd Hafner
 *                  aw -> Arnold Wohlfeil
 *
 * Version  Author  Changes                                         Date
 * 4.1.0    hf      created                                         31jan2009
 * 4.1.1    hf      changed to total and individual working time    03mar2009
 * 4.1.2    hf      corrected access to RWork array                 24mar2009
 * 4.1.3    gf      modified calculus to not reset the continuous   26oct2010
 *                  state (bug in 64 bits R2007b Matlab version)                  
 * 6.1.0    aw      ssGetNumContStates(S, 0)                        07may2014
 *                  replaced by ssGetNumContStates(S)
 *
 * Copyright (c) 2009-2014 Solar Institute Juelich
 */


#define S_FUNCTION_LEVEL 2
#define S_FUNCTION_NAME countcycles

/* 
 * This Functions calculates the number of cycles, the total working time and the 
 * actual working time.
 */



/*
 * Need to include simstruc.h for the definition of the SimStruct and
 * its associated macro definitions. math.h is for function sqrt
 */
#include "simstruc.h"
#include <math.h>
/* #include "carlib.h" not yet necessary */


/*
 * some defines for access to the input vector
 */
#define DIGIN(n)        (*uPtrs[n])     /* Digital input n  */

#define CYCLES(n)       iwork[n]
#define LASTIN(n)       rwork[2*n]      /* Last digital input n */
#define OLDTIMETOTAL(n) rwork[2*n+1]    /* total working time of input n before the beginning of the last cycle */

#define TIMETOTAL(n)    x[n]            /* total working time of input n */
#define DTONDT(n)       dx[n]           /* time derivative input n */


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
    ssSetNumSFcnParams(S, 0);  /* Number of expected parameters */
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
        /* Return if number of expected != number of actual parameters */
        return;
    }

    ssSetNumContStates(S, DYNAMICALLY_SIZED);
    ssSetNumDiscStates(S, 0);

    if (!ssSetNumInputPorts(S, 1)) return;  
    ssSetInputPortDirectFeedThrough(S, 0, 1);
    ssSetInputPortWidth(S, 0, DYNAMICALLY_SIZED);

    if (!ssSetNumOutputPorts(S, 4)) return;
    ssSetOutputPortWidth(S, 0, DYNAMICALLY_SIZED);  /* Latch */
    ssSetOutputPortWidth(S, 1, DYNAMICALLY_SIZED);  /* Cycle counter */
    ssSetOutputPortWidth(S, 2, DYNAMICALLY_SIZED);  /* Cycle time */
    ssSetOutputPortWidth(S, 3, DYNAMICALLY_SIZED);  /* Total operation time */
 
    ssSetNumSampleTimes(S, 1);
    ssSetNumRWork(S, DYNAMICALLY_SIZED);
    ssSetNumIWork(S, DYNAMICALLY_SIZED);

    ssSetNumPWork(S, 0);
    ssSetNumModes(S, 0);
    ssSetNumNonsampledZCs(S, 0);

    /* Take care when specifying exception free code - see sfuntmpl.doc */
#ifdef  EXCEPTION_FREE_CODE
    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE);
#endif
}

#define MDL_SET_WORK_WIDTHS   /* Change to #undef to remove function */
#if defined(MDL_SET_WORK_WIDTHS) && defined(MATLAB_MEX_FILE)
  /* Function: mdlSetWorkWidths ===============================================
   * Abstract:
   *      The optional method, mdlSetWorkWidths is called after input port
   *      width, output port width, and sample times of the S-function have
   *      been determined to set any state and work vector sizes which are
   *      a function of the input, output, and/or sample times. This method
   *      is used to specify the nonzero work vector widths via the macros
   *      ssNumContStates, ssSetNumDiscStates, ssSetNumRWork, ssSetNumIWork,
   *      ssSetNumPWork, ssSetNumModes, and ssSetNumNonsampledZCs.
   *
   *      Run-time parameters are registered in this method using methods 
   *      ssSetNumRunTimeParams, ssSetRunTimeParamInfo, and related methods.
   *
   *      If you are using mdlSetWorkWidths, then any work vectors you are
   *      using in your S-function should be set to DYNAMICALLY_SIZED in
   *      mdlInitializeSizes, even if the exact value is known at that point.
   *      The actual size to be used by the S-function should then be specified
   *      in mdlSetWorkWidths.
   */
  static void mdlSetWorkWidths(SimStruct *S)
  {
    int_T  nu = ssGetInputPortWidth(S,0);

    ssSetNumRWork(S, 2*nu);  // number of R-Work is 2 times No. of inputs
  }
#endif /* MDL_SET_WORK_WIDTHS */



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
    real_T *rwork = ssGetRWork(S);
    int_T  *iwork = ssGetIWork(S);
    real_T *x = ssGetContStates(S);
    int_T  i;
    
    for (i = 0; i < ssGetNumRWork(S); i++) rwork[i] = (real_T)0.0;
    for (i = 0; i < ssGetNumIWork(S); i++) iwork[i] = (int_T)0;
    for (i = 0; i < ssGetNumContStates(S); i++) x[i] = (real_T)0.0;
}
#endif /* MDL_INITIALIZE_CONDITIONS */



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
  }
#endif /*  MDL_START */



/* Function: mdlOutputs =======================================================
 * Abstract:
 *    In this function, you compute the outputs of your S-function
 *    block. Generally outputs are placed in the output vector, ssGetY(S).
 */
static void mdlOutputs(SimStruct *S, int_T tid)
{
    int_T   ny = ssGetOutputPortWidth(S,0);
    InputRealPtrsType uPtrs = ssGetInputPortRealSignalPtrs(S,0);
    real_T *y1 = ssGetOutputPortRealSignal(S,0);
    real_T *y2 = ssGetOutputPortRealSignal(S,1);
    real_T *y3 = ssGetOutputPortRealSignal(S,2);  
    real_T *y4 = ssGetOutputPortRealSignal(S,3);  
    real_T *x  = ssGetContStates(S);
    real_T *rwork = ssGetRWork(S);
    int_T  *iwork = ssGetIWork(S);
    int_T  i;
    
   
    for (i = 0; i < ny; i++) 
	{
        y1[i] = ((LASTIN(i) <= 0.0 && DIGIN(i) > 0.0) | (LASTIN(i) > 0.0 && DIGIN(i) <= 0.0));
        y2[i] = CYCLES(i);
        y3[i] = TIMETOTAL(i) - OLDTIMETOTAL(i); /* actual working time is time between the beginning of the current cycle and actual time */
        y4[i] = TIMETOTAL(i);  
	}

} /* end mdloutputs */



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
    int_T             ny = ssGetOutputPortWidth(S,0);
    InputRealPtrsType uPtrs  = ssGetInputPortRealSignalPtrs(S,0);
    real_T            *x  = ssGetContStates(S);
    real_T            *rwork = ssGetRWork(S);
    int_T             *iwork = ssGetIWork(S);
    int_T             i;

	int_T test = ssGetNumRWork(S); // nur Test
    
    for (i = 0; i < ny; i++) 
    {
        if (LASTIN(i) <= 0.0 && DIGIN(i) > 0.0)     /* check if last input was zero and actual input is above zero */
            CYCLES(i)++;                            /* increment number of cycles of this input */
        if (LASTIN(i) > 0.0 && DIGIN(i) <= 0.0)     /* check for declining flank  */
        {
            OLDTIMETOTAL(i) = TIMETOTAL(i);         /* store total working time after the cycle which just finished */
        }
        LASTIN(i) = DIGIN(i);                       /* keep actual input in the memory */
    }
}
#endif /* MDL_UPDATE */



#define MDL_DERIVATIVES  /* Change to #undef to remove function */
#if defined(MDL_DERIVATIVES)
  /* Function: mdlDerivatives =================================================
   * Abstract:
   *    In this function, you compute the S-function block's derivatives.
   *    The derivatives are placed in the derivative vector, ssGetdX(S).
   */
static void mdlDerivatives(SimStruct *S)
{
    real_T            *dx = ssGetdX(S);
    real_T            *x  = ssGetContStates(S);
    InputRealPtrsType uPtrs  = ssGetInputPortRealSignalPtrs(S,0);
    int_T             nu     = ssGetInputPortWidth(S,0);
    int_T             i;
    
    for (i = 0; i < nu; i++) 
    {
        if (DIGIN(i) > 0)       /* if input > 0 */ 
            DTONDT(i) = (real_T)1.0;    /* integrate working time */
        else                    /* otherwise */
            DTONDT(i) = (real_T)0.0;    /* no working time */
    }
    
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
