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
 * Syntax  [year month day hour minute second] = sumtime_s
 *
 * Version  Author          Changes                               Date
 * 0.01.0   Thomas Wenzel   created                               24nov1999
 * 6.0.0    Arnold Wohlfeil unused variables deleted,             10sep2015
 *                          implicite casts replaced by
 *                          explicit casts
 *
 * Copyright (c) 1999 Solar-Institut Juelich, Germany
 * 
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *  D E S C R I P T I O N
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
   This Functions calculates for a given date the sum of seconds, minutes, ...
   in the year.

   example: 02 January 1999  12:00:00  
   
            input vector : [99 01 02 12 00 00]
            output vector: [0.0041 0.048 1.5 36 2160 129600]
            
            year   :      0.0041
            month  :      0.048
            day    :      1.5
            hour   :     36
            minute :   2160            
            second : 129600

   ATTENTION: The year may be given with 2 digits, so the program calculates every
              year which is divisible by four as a leap year.
              Therefore errors are made in ..., 1900, 2100, 2200, ... but not in 2000.
 */


#define S_FUNCTION_LEVEL 2
#define S_FUNCTION_NAME sumtime_s

/*
 * Need to include simstruc.h for the definition of the SimStruct and
 * its associated macro definitions. math.h is for function sqrt
 */
#include "simstruc.h"
#include <math.h>
/* #include "carlib.h" not yet necessary */


/* defines for the iteration loop */
#define MAXCALL         100    /* maximum number of iteration calls */
#define ERROR           1.0e-5 /* error in massflow iteration       */


/*
 * some defines for access to the parameters
 */
/*define DIAMETER (*mxGetPr(ssGetSFcnParam(S,0))) *//* diameter of inlet and outlet */
#define N_PARA                              0

/*
 * some defines for access to the input vector
 */
#define YEAR      (*u1Ptrs[0])    /* Year 00..99    */
#define MONTH     (*u1Ptrs[1])    /* Month  1..12   */
#define DAY       (*u1Ptrs[2])    /* Day   1..31    */
#define HOUR      (*u1Ptrs[3])    
#define MINUTE    (*u1Ptrs[4])    
#define SECOND    (*u1Ptrs[5])    


#define IN_WIDTH    6             /* number of inputs per port */


/*
 * some defines for access to the output vector
 */
#define YEAR_SUM   y1[0]    
#define MONTH_SUM  y1[1]    
#define DAY_SUM    y1[2]    
#define HOUR_SUM   y1[3]    
#define MINUTE_SUM y1[4]    
#define SECOND_SUM y1[5]    

#define OUT_WIDTH     6     /* number of outputs per port */

#define SQR(x) ((x)*(x))
#define MAX(x,y) ((x)>(y) ? (x) : (y))


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



#undef MDL_INITIALIZE_CONDITIONS   /* Change to #undef to remove function */
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
    InputRealPtrsType u1Ptrs = ssGetInputPortRealSignalPtrs(S,0);

    real_T *y1 = ssGetOutputPortRealSignal(S,0);

    //real_T  phi,rho,r,zeta dp;
    real_T  second;

    int month,  this_month, day, year; //i
    
    year = (int_T)(floor (YEAR+0.5));
    day = 0;
    
    for (month=1;month<(int_T)(MONTH+0.5);month++)
      if ( ( month<=7 && month%2==1) || (month>=8 && month%2==0) )
         day += 31;
      else if (month==2 && year%4==0)
         day += 29;
      else if (month==2 && year%4!=0)
         day += 28;
      else
         day += 30;
         
    second = (((day+DAY-1)*24+HOUR)*60+MINUTE)*60+SECOND;
    SECOND_SUM = second;
    MINUTE_SUM = second/60;
    HOUR_SUM   = second/3600;
    DAY_SUM    = second/86400;

     month = (int_T)(floor( MONTH+0.5));
 
      if ( ( month<=7 && month%2==1) || (month>=8 && month%2==0) )
         this_month = 31;
      else if (month==2 && year%4==0)
         this_month = 29;
      else if (month==2 && year%4!=0)
         this_month = 28;
      else
         this_month = 30;

    this_month *= 86400;

    MONTH_SUM  = MONTH -1 + ((((DAY-1)*24+HOUR)*60+MINUTE)*60+SECOND)/this_month;
    
    if (year%4>0)
      YEAR_SUM = second/31536000;
    else
      YEAR_SUM = second/31622400;            

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
