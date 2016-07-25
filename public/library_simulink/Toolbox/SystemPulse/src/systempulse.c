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
 * Syntax  systempulse
 *
 * Version  Author          Changes                               Date
 * 0.01.0   Thomas Wenzel   created                               10jan2000
 * 0.02.0   tw              waiting for systempulse and/or date   10feb2000
 * 6.0.1    Arnold Wohlfeil IWork replaced by DWork               10sep2015
 *                          SimStateCompiliance and
 *                          MultipleExecInstances activated,
 *                          implicit casts replaced by explicit
 *                          casts,
 *                          unused variables deleted
 *
 * Copyright (c) 2000 Solar-Institut Juelich, Germany
 * 
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *  D E S C R I P T I O N
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
   Then it will generated a discrete pulse of 0 and 1, but this pulse
   is depending on the system time, not the simulation time.

   If the dateflag is set, the function will start pulsing only, when the
   systemdate reaches the specified date. Otherwise the output will be 0.

   If the enableflag is set, the function will wait, until the enablepulse
   once will rise from 0 to 1. Afterwards the pulsing is started, before,
   the output will be 0.


   input vector : [month day hour minute second period pulsewidth enablepulse]

   parameter    : [dateflag, enable_flag]

   output       : 0 or 1
    


   setting of dwork
   dwork[0] = time in seconds, when the next pulse begins, while output is 0
   dwork[1] = time in seconds, when the next pulse begins, while output is 1
   dwork[2] = 1 when function has waited for start time, else 0
   dwork[3] = ENABLED, = 1, when enablepulse has risen or =1 when 
              enableflag is not set
   dwork[4] = STARTED = 1, when systemdate reaches the specified date or =1,
              when dateflag is not set
 */


#define S_FUNCTION_LEVEL 2
#define S_FUNCTION_NAME systempulse

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

#define DATE_FLAG (*mxGetPr(ssGetSFcnParam(S,0))) 
#define ENABLE_FLAG (*mxGetPr(ssGetSFcnParam(S,1))) 
#define N_PARA                              2

/*
 * some defines for access to the input vector
 */
#define MONTH     (*u1Ptrs[0])    /* Month  1..12   */
#define DAY       (*u1Ptrs[1])    /* Day   1..31    */
#define HOUR      (*u1Ptrs[2])    
#define MINUTE    (*u1Ptrs[3])    
#define SECOND    (*u1Ptrs[4])    
#define PERIOD    (*u1Ptrs[5])    /* Period in seconds */
#define PULSEWIDTH (*u1Ptrs[6])   /* Pulse width in seconds */
#define ENABLE     (*u1Ptrs[7])

#define IN_WIDTH    8             /* number of inputs per port */


/*
 * some defines for access to the output vector
 */

#define OUT_WIDTH     1     /* number of outputs per port */


/*
 * some defines for access to the rwork vector
 */

#define ENABLED    dwork[3]
#define STARTED    dwork[4]

int countseconds(int month,int day, int hour,int minute, int second); //declaration 

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
    ssSetNumDWork(S, 1);
    ssSetDWorkWidth(S, 0, 5);
    ssSetDWorkDataType(S, 0, SS_INT32);
    ssSetDWorkName(S, 0, "DWORK");
    ssSetDWorkUsageType(S, 0, SS_DWORK_USED_AS_DSTATE);
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
    int32_T *dwork    = (int32_T *)ssGetDWork(S, 0);
    time_t  now;
    struct tm *ts;
    
    dwork[1] = 0;
    dwork[2] = 0;
     
    
    if (ENABLE_FLAG<0.1)   /*==0 */
       ENABLED = 1;
    else
    {
      if (ENABLE>=0.9)    /* ==1 */
         ENABLED = 1;           /* enable flag */
      else
         ENABLED = 0;           /* enable flag */
    }

printf("E: F %f  D %d E %f\n",ENABLE_FLAG,ENABLED,ENABLE);
    if (DATE_FLAG>0.9 ) /*&& iwork[2]==0)  */ 				/* wait for start time */
        STARTED = 0;
    else
        STARTED = 1;


         time(&now);
         ts  = localtime(&now);
         dwork[0] = countseconds(ts->tm_mon+1,ts->tm_mday,ts->tm_hour,ts->tm_min,ts->tm_sec); 
/* printf("start : %d            %s l. %d\n",iwork[0],__FILE__,__LINE__);*/


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



/* Function: mdlOutputs =======================================================
 * Abstract:
 *    In this function, you compute the outputs of your S-function
 *    block. Generally outputs are placed in the output vector, ssGetY(S).
 */
static void mdlOutputs(SimStruct *S, int_T tid)
{
    InputRealPtrsType u1Ptrs = ssGetInputPortRealSignalPtrs(S,0);

    real_T *y1 = ssGetOutputPortRealSignal(S,0);

    int32_T *dwork    = (int32_T *)ssGetDWork(S, 0);
  
    int_T  second, syssecond, oldsecond;
    time_t  now;
    struct tm *ts;

    if (ENABLE_FLAG>0.9 && ENABLE>0.9)   /*==1 ,when ENABLE FLAG once is 1, then systempulse will work */
    {
       ENABLED = 1;           /* enable flag */
        (void)time(&now);
        ts  = localtime(&now);
        syssecond = countseconds(ts->tm_mon+1,ts->tm_mday,ts->tm_hour,ts->tm_min,ts->tm_sec); 
        dwork[0] = syssecond;
    }
     
    if (DATE_FLAG>0.9 && !STARTED ) /*&& iwork[2]==0)  */ 				/* wait for start time */
    {
       dwork[2] = 1;              				/* don't come here again */

       second = countseconds((int) MONTH,(int) DAY,(int) HOUR,(int) MINUTE,(int) SECOND);
    
       (void)time(&now);
       ts  = localtime(&now);
       syssecond = countseconds(ts->tm_mon+1,ts->tm_mday,ts->tm_hour,ts->tm_min,ts->tm_sec); 
       STARTED = (int32_T)(second<syssecond);      /* 1, when sim-time reaches systemtime */
       dwork[0] = syssecond;
    }


    time(&now);
    ts  = localtime(&now);
    oldsecond = dwork[0];                       

    syssecond = countseconds(ts->tm_mon+1,ts->tm_mday,ts->tm_hour,ts->tm_min,ts->tm_sec); 

    if ( syssecond>=oldsecond && syssecond<oldsecond+(int) PULSEWIDTH)	/* at beginning */
    { 									/* of period    */
       y1[0] = 1.0;                                       		/* Output = 1   */
       if (dwork[1]==0)							/* every 1st time      */
         dwork[1] = syssecond + (int_T)PERIOD;					/* save next oldsecond */
    }
    else
       y1[0] = 0.0;							/* else Output = 0 */
    /*
     printf("old : %d    now : %d   pulse : %d",oldsecond,syssecond,oldsecond + (int) PULSEWIDTH);
     printf("  -- %f --\n",y1[0]);
    */

    if (ENABLED==0 || STARTED==0)     /* while not startet and not enabled, output = 0 */
      y1[0] = 0.0;

    if ((double)syssecond>(double)oldsecond+PULSEWIDTH && dwork[1]>0)			/* when period over */
    {
       dwork[0] = dwork[1]; 						/* then new oldsecond */
       dwork[1] = 0;							/* next oldsecond */
    }

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
