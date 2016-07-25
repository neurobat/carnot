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
 * Syntax  monoflop_realtime
 *
 * Version  Author          Changes                                 Date
 * 0.01.0   Thomas Wenzel   created                                 10feb2000
 *
 * Copyright (c) 2000 Solar-Institut Juelich, Germany
 * 
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *  D E S C R I P T I O N
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * This functions creates a signal pulse, whenever the input pulse is 
 * changing as specified. The duration of the pulse is depending on the 
 * system time, not the simulation time.
 */


#define S_FUNCTION_LEVEL 2
#define S_FUNCTION_NAME monoflop_realtime

/*
 * Need to include simstruc.h for the definition of the SimStruct and
 * its associated macro definitions. math.h is for function sqrt
 */
#include "simstruc.h"
#include <math.h>
#include <time.h>
/* #include "carlib.h" not yet necessary */


/* defines for the iteration loop */
#define MAXCALL         100    /* maximum number of iteration calls */
#define ERROR           1.0e-5 /* error in massflow iteration       */


/*
 * some defines for access to the parameters
 */

#define TIME        (*mxGetPr(ssGetSFcnParam(S,0)))    /* time intervall              */
#define DIRECTION   (*mxGetPr(ssGetSFcnParam(S,1)))    /* 1=rising, 2=falling, 3=either */
#define N_PARA                              2

/*
 * some defines for access to the input vector
 */
#define INPUT        (*u1Ptrs[0])                      

#define IN_WIDTH    1             /* number of inputs per port */


/*
 * some defines for access to the output vector
 */

#define OUTPUT    y1[0]    


#define OUT_WIDTH    1     /* number of outputs per port */


/*
 * some defines for access to the rwork vector
 */

#define NEXTTIME        iwork[0]          /* next time = end of duration of output signal 1  */
                                          /*           = 0, when output signal 0             */
#define LAST_INPUT      iwork[1]         




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
    ssSetNumSFcnParams(S, N_PARA);  /* Number of expected parameters */
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
        /* Return if number of expected != number of actual parameters */
        return;
    }

    ssSetNumContStates(S, 0);
    ssSetNumDiscStates(S, 0);

    if (!ssSetNumInputPorts(S, 1)) return;  
    ssSetInputPortWidth(S, 0, IN_WIDTH);
    ssSetInputPortDirectFeedThrough(S, 0, 1);

    if (!ssSetNumOutputPorts(S, 1)) return;
    ssSetOutputPortWidth(S, 0, OUT_WIDTH);

    ssSetNumSampleTimes(S, 1);
    ssSetNumRWork(S, 0);
    ssSetNumIWork(S, 2);
    ssSetNumPWork(S, 0);
    ssSetNumModes(S, 0);
    ssSetNumNonsampledZCs(S, 0);

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


#define MDL_INITIALIZE_CONDITIONS
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
    InputRealPtrsType u1Ptrs = ssGetInputPortRealSignalPtrs(S,0);
    int_T   *iwork    = ssGetIWork(S);


    NEXTTIME = 0;
    LAST_INPUT = 0;

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



/* count the seconds in the past year, given by date, no calculation of leap year */

int countseconds(int month,int day, int hour,int minute, int second)
{
    int imonth, iday;
    
    iday = 0;
 
    for (imonth=1;imonth<month;imonth++)
      if ( ( imonth<=7 && imonth%2) || (imonth>=8 && imonth%2==0) )
         iday += 31;
      else if (imonth==2)
         iday += 28;
      else
         iday += 30;
         
    return (((iday+day-1)*24+hour)*60+minute)*60+second;
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

    real_T *y1 = ssGetOutputPortRealSignal(S,0);
    real_T *y2 = ssGetOutputPortRealSignal(S,1);

    int_T   *iwork    = ssGetIWork(S);
  
    int_T  seconds;
    time_t  now;
    struct tm *ts;


    time(&now);
    ts  = localtime(&now);
    seconds = countseconds(ts->tm_mon+1,ts->tm_mday,ts->tm_hour,ts->tm_min,ts->tm_sec); 


    if (NEXTTIME == 0 && INPUT!=LAST_INPUT)      /* no output signal and input signal changed */
    {
       if ((int) (DIRECTION+0.1)==3)             /* either rising or falling */
         NEXTTIME = seconds+(int_T)TIME;
       else if ((int) (DIRECTION+0.1)==2 && INPUT<0.1 && LAST_INPUT>0.9)  /* only falling */
         NEXTTIME = seconds+(int_T)TIME;
       else if ((int) (DIRECTION+0.1)==1 && INPUT>0.9 && LAST_INPUT<0.1)  /* only rising */
         NEXTTIME = seconds+(int_T)TIME;
    }

    if (seconds<NEXTTIME) 
      OUTPUT = 1;
    else
      OUTPUT = 0;
 
    if  (seconds>=NEXTTIME)                      /* when end of duration reached, no signal */
      NEXTTIME = 0;

    LAST_INPUT = (int_T)INPUT;

} /* end mdloutputs */



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
