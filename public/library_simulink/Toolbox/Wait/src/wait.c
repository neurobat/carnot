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
 * Syntax  wait
 *
 * Version  Author          Changes                               Date
 * 0.01.0   Thomas Wenzel   created                               16dec1999
 * 6.0.0    Arnold Wohlfeil access to undefined IWork vector      11nov2014
 *                          deleted
 *                          RWork replaced by DWork
 * 6.0.1	Arnold Wohlfeil	added Simstate compiliance and		  24jul2015
 *							multiple instances
 * 6.0.2    Arnold Wohlfeil implicit casts made explicity,        10sep2015
 *                          unused function deleted
 *
 * Copyright (c) 1998-2014 Solar-Institut Juelich, Germany
 *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *  D E S C R I P T I O N
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
   This Functions waits until the system time reaches a given date. Whenever
   this functions called then again, it will wait for the given number of seconds.

   example: 02 January 1999  12:00:00  
   
            parameters : month day hour minute second Waitingseconds
            output     : ---
    
   To ignore the start date and start directly, the month has to be negative.
   Then the actual time will be saved in rwork, so it can be compare during
   the next function call.
 */


#define S_FUNCTION_LEVEL 2
#define S_FUNCTION_NAME wait


/*
 * Need to include simstruc.h for the definition of the SimStruct and
 * its associated macro definitions. math.h is for function sqrt
 */
#include "simstruc.h"
#include <math.h>
#include <time.h>


/*
 * some defines for access to the parameters
 */
#define MONTH       (*mxGetPr(ssGetSFcnParam(S,0))) /* Month  1..12   */ 
#define DAY         (*mxGetPr(ssGetSFcnParam(S,1))) /* Day    1..31   */ 
#define HOUR        (*mxGetPr(ssGetSFcnParam(S,2))) /* Hour   0..23   */ 
#define MINUTE      (*mxGetPr(ssGetSFcnParam(S,3))) /* minute 0..59   */ 
#define SECOND      (*mxGetPr(ssGetSFcnParam(S,4))) /* second 0..59   */ 
#define WAITSECOND  (*mxGetPr(ssGetSFcnParam(S,5))) /* waiting time in seconds  */ 
#define N_PARA                                 6  


/* count the seconds in the past year, given by date */

int countseconds(int month,int day, int hour,int minute, int second)
{

    int imonth, iday; //i
    
    iday = 0;
 
    for (imonth=1;imonth<month;imonth++)
      if ( ( imonth<=7 && imonth%2==1) || (imonth>=8 && imonth%2==0) )
         iday += 31;
      else if (imonth==2)
         iday += 28;
      else
         iday += 30;
         
    return (((iday+day-1)*24+hour)*60+minute)*60+second;
}



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

    if (!ssSetNumInputPorts(S, 0)) return;  
    /* ssSetInputPortWidth(S, 0, 1); */
    /* sSetInputPortDirectFeedThrough(S, 0, 0); */

    if (!ssSetNumOutputPorts(S, 0)) return;
    /* ssSetOutputPortWidth(S, 0, 1); */

    ssSetNumSampleTimes(S, 1);
    ssSetNumDWork(S, 1);
    ssSetDWorkWidth(S, 0, 1);
    ssSetDWorkDataType(S, 0, SS_DOUBLE);
    ssSetDWorkName(S, 0, "DWORK0");
    ssSetDWorkUsageType(S, 0, SS_DWORK_USED_AS_DSTATE);
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
    // ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE);
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
    ssSetSampleTime(S, 0, WAITSECOND);
    ssSetOffsetTime(S, 0, 0.0);
}





#define MDL_START  /* Change to #undef to remove function */
#if defined(MDL_START) 
  /* Function: mdlStart =======================================================
   * Abstract:
   *    This function is called once at start of model execution. If you
   *    have states that should be initialized once, this is the place
   *    to do it.
   */
  static void mdlStart(SimStruct *S)
  {
    real_T  *DWork0 = (double*)ssGetDWork(S, 0);
    time_t   now;
    struct   tm *ts;
    //real_T   syssecond;

    /* Startzeit in Sekunden */
    if (MONTH>0)
    {
       DWork0[0] = (double)countseconds((int) MONTH,(int) DAY,(int) HOUR,(int) MINUTE,(int) SECOND); //store start time in RWork
    }
    else
    {
        (void)time(&now);
        ts  = localtime(&now);
        DWork0[0] = (double)countseconds(ts->tm_mon+1,ts->tm_mday,ts->tm_hour,ts->tm_min,ts->tm_sec); 
    }            
  }
#endif /*  MDL_START */



/* Function: mdlOutputs =======================================================
 * Abstract:
 *    In this function, you compute the outputs of your S-function
 *    block. Generally outputs are placed in the output vector, ssGetY(S).
 */
static void mdlOutputs(SimStruct *S, int_T tid)
{
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
    real_T  *DWork0 = (double*)ssGetDWork(S, 0);
    time_t   now;
    struct   tm *ts;
    real_T   syssecond;
  
    do
    {
      (void)time(&now);
      ts  = localtime(&now);
      syssecond = (double)countseconds(ts->tm_mon+1,ts->tm_mday,ts->tm_hour,ts->tm_min,ts->tm_sec); 
    }
    while (syssecond < DWork0[0]+WAITSECOND);

    DWork0[0] += WAITSECOND; 
}
#endif /* MDL_UPDATE */



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

