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
 * Syntax  average
 *
 * Version  Author          Changes                               Date
 * 0.01.0   Thomas Wenzel   created                               10feb2000
 * 6.0.0    Arnold Wohlfeil RWork and IWork replaced by DWork     17aug2015
 *                          SimstateCompiliance and
 *                          MultipleInstancesExec activated
 *                          include of time.h deleted
 * 6.0.1    Arnold Wohlfeil implicit cast changed to exciplite    08sep2015
 *                          cast, unused variables deleted,
 *                          all DWork vectors initialisated
 * 6.0.2    Arnold Wohlfeil SUM_TIME set to int32_T               15sep2015
 *                          unused functions delted
 *
 * Copyright (c) 2000 Solar-Institut Juelich, Germany
 * 
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *  D E S C R I P T I O N
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * 
 * This functions calculates the average of each input vector during a specified time Delta_t. 
 * During this time intervall the output is not changed. The output time is the time of the 
 * last average calculation. Every time the average is calculated new, a signal pulse of 1 is 
 * put out.
 *
 * When the full hour flag is set, the calculating of the average is started every full hour new.
 *
 * When the enable flag is set, the functions calculates only while the enable signal is 1. 
 * When it is 0, the function repeat putting out the last output.
 *
 * The output of each vector line is:
 * 
 *    average = sum ( input(i)*(time(i)-time(i-1)) ) / sum (time(i)-time(i-1))
 */


#define S_FUNCTION_LEVEL 2
#define S_FUNCTION_NAME average

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

#define DELTA_T     (*mxGetPr(ssGetSFcnParam(S,0)))    /* time intervall              */
#define OFFSET_FLAG (*mxGetPr(ssGetSFcnParam(S,1)))    /* start new every full hour   */
#define PULSE_FLAG  (*mxGetPr(ssGetSFcnParam(S,2)))    /* look for enable/input_pulse */
#define N_PARA                              3

/*
 * some defines for access to the input vector
 */
#define INPUT(x)     (*u1Ptrs[x])                      
#define TIME         (*u1Ptrs[NUMBER])    
#define INPUT_PULSE  (*u1Ptrs[NUMBER+1])    

#define IN_WIDTH    DYNAMICALLY_SIZED             /* number of inputs per port */


/*
 * some defines for access to the output vector
 */

#define OUTPUT(x)    y1[x]    
#define OUTPUT_TIME  y1[NUMBER]    
#define OUTPUT_PULSE y1[NUMBER+1]    


#define OUT_WIDTH    DYNAMICALLY_SIZED     /* number of outputs per port */


/*
 * some defines for access to the work vector
 */

#define DWORK_LAST_OUTPUT_NR            0
#define DWORK_COUNTER_NR                1
#define DWORK_SUM_TIME_NR               2
#define DWORK_NEXTTIME_NR               3
#define DWORK_LASTTIME_NR               4
#define DWORK_LASTOUTPUT_TIME_NR        5
#define DWORK_ENABLED_NR                6
#define DWORK_NUMBER_NR                 7

#define NEXTTIME                        dwork_nexttime[0]          /* next time to calculate average        */
#define LASTTIME                        dwork_lasttime[0]          /* last time function was called         */
#define LASTOUTPUT_TIME                 dwork_lastoutput_time[0]          
#define ENABLED                         dwork_enabled[0]           /* input_pulse is 1                      */
#define NUMBER                          dwork_number[0]            /* width of input vector                 */

#define LAST_OUTPUT(x)                  dwork_last_output[x]          
#define COUNTER(x)                      dwork_counter[x]           /* sum of input(i)*(time now - LASTTIME) */
#define SUM_TIME                        dwork_sum_time[0]          /* sum of (time now - LASTTIME)          */



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
   int_T number;

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
    number = ssGetInputPortWidth(S, 0);        /* = IN_WIDTH = DYNAMICALLY SIZED */

    if (!ssSetNumOutputPorts(S, 1)) return;
    ssSetOutputPortWidth(S, 0, OUT_WIDTH);

    ssSetNumSampleTimes(S, 1);
    ssSetNumRWork(S, 0); 
    ssSetNumIWork(S, 0);
    ssSetNumPWork(S, 0);
    
    ssSetNumDWork(S, 8);
    ssSetDWorkWidth(S, 0, number);
    ssSetDWorkDataType(S, 0, SS_DOUBLE);
    ssSetDWorkName(S, 0, "D_LAST_OUTPUT");
    ssSetDWorkUsageType(S, 0, SS_DWORK_USED_AS_DSTATE);
    ssSetDWorkWidth(S, 1, number);
    ssSetDWorkDataType(S, 1, SS_DOUBLE);
    ssSetDWorkName(S, 1, "D_COUNTER");
    ssSetDWorkUsageType(S, 1, SS_DWORK_USED_AS_DSTATE);
    ssSetDWorkWidth(S, 2, 1);
    ssSetDWorkDataType(S, 2, SS_INT32);
    ssSetDWorkName(S, 2, "D_SUM_TIME");
    ssSetDWorkUsageType(S, 2, SS_DWORK_USED_AS_DSTATE);
    ssSetDWorkWidth(S, 3, 1);
    ssSetDWorkDataType(S, 3, SS_INT32);
    ssSetDWorkName(S, 3, "D_NEXTTIME");
    ssSetDWorkUsageType(S, 3, SS_DWORK_USED_AS_DSTATE);
    ssSetDWorkWidth(S, 4, 1);
    ssSetDWorkDataType(S, 4, SS_INT32);
    ssSetDWorkName(S, 4, "D_LASTTIME");
    ssSetDWorkUsageType(S, 4, SS_DWORK_USED_AS_DSTATE);
    ssSetDWorkWidth(S, 5, 1);
    ssSetDWorkDataType(S, 5, SS_INT32);
    ssSetDWorkName(S, 5, "D_LASTOUT_TIME");
    ssSetDWorkUsageType(S, 5, SS_DWORK_USED_AS_DSTATE);
    ssSetDWorkWidth(S, 6, 1);
    ssSetDWorkDataType(S, 6, SS_INT32);
    ssSetDWorkName(S, 6, "D_ENABLED");
    ssSetDWorkUsageType(S, 6, SS_DWORK_USED_AS_DSTATE);
    ssSetDWorkWidth(S, 7, 1);
    ssSetDWorkDataType(S, 7, SS_INT32);
    ssSetDWorkName(S, 7, "DWORK_NUMBER");
    ssSetDWorkUsageType(S, 7, SS_DWORK_USED_AS_DSTATE);
    
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
    
    real_T  *dwork_last_output     = (real_T  *)ssGetDWork(S, DWORK_LAST_OUTPUT_NR);
    real_T  *dwork_counter         = (real_T  *)ssGetDWork(S, DWORK_COUNTER_NR);
    int32_T *dwork_sum_time        = (int32_T *)ssGetDWork(S, DWORK_SUM_TIME_NR);
    int32_T *dwork_nexttime        = (int32_T *)ssGetDWork(S, DWORK_NEXTTIME_NR);
    int32_T *dwork_lasttime        = (int32_T *)ssGetDWork(S, DWORK_LASTTIME_NR);
    int32_T *dwork_lastoutput_time = (int32_T *)ssGetDWork(S, DWORK_LASTOUTPUT_TIME_NR);
    int32_T *dwork_enabled         = (int32_T *)ssGetDWork(S, DWORK_ENABLED_NR);
    int32_T *dwork_number          = (int32_T *)ssGetDWork(S, DWORK_NUMBER_NR);
    int_T second, i;

    LASTTIME = second = (int_T)TIME;

    NEXTTIME = 0;
    for (i=0;i<NUMBER;i++)
    {
      COUNTER(i) = 0.0;
      LAST_OUTPUT(i) = 0.0;
    }
    SUM_TIME = 0;
     
    ENABLED  = 1;

    NUMBER   = ssGetInputPortWidth(S,0)-2;  /* width of input vector without time and pulse */

    NEXTTIME = -1;
    
    LASTOUTPUT_TIME = 0;
        
  }
#endif /* MDL_INITIALIZE_CONDITIONS */




/* count the seconds in the past year, given by date, no calculation of leap year */

int countseconds(int month, int day, int hour,int minute, int second)
{
    int imonth, iday;
    
    iday = 0;
 
    for (imonth=1;imonth<month;imonth++)
    {
      if ( ( imonth<=7 && imonth%2==1) || (imonth>=8 && imonth%2==0) )
      {
         iday += 31;
      }
      else if (imonth==2)
      {
         iday += 28;
      }
      else
      {
         iday += 30;
      }
    }
         
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

    real_T  *dwork_last_output     = (real_T  *)ssGetDWork(S, DWORK_LAST_OUTPUT_NR);
    real_T  *dwork_counter         = (real_T  *)ssGetDWork(S, DWORK_COUNTER_NR);
    int32_T *dwork_sum_time        = (int32_T *)ssGetDWork(S, DWORK_SUM_TIME_NR);
    int32_T *dwork_nexttime        = (int32_T *)ssGetDWork(S, DWORK_NEXTTIME_NR);
    int32_T *dwork_lasttime        = (int32_T *)ssGetDWork(S, DWORK_LASTTIME_NR);
    int32_T *dwork_lastoutput_time = (int32_T *)ssGetDWork(S, DWORK_LASTOUTPUT_TIME_NR);
    int32_T *dwork_enabled         = (int32_T *)ssGetDWork(S, DWORK_ENABLED_NR);
    int32_T *dwork_number          = (int32_T *)ssGetDWork(S, DWORK_NUMBER_NR);
  
    int_T  second, second_full,i;


    second = (int_T)TIME;


    if (NEXTTIME == -1)                         /* initalize nexttime */
    {
                                                /* end of next time intervall      */
      if (OFFSET_FLAG > 0.9)                    /* ==1, then try to find next hour */
      {
         NEXTTIME = second + (int_T)DELTA_T;
         second_full = (second/3600+1)*3600;
         if (second < second_full && NEXTTIME > second_full)  
           NEXTTIME = second_full;
      }
      else
        NEXTTIME = second + (int_T)DELTA_T;           
    }



    if ((PULSE_FLAG>0.9) && ENABLED==0 && INPUT_PULSE>0.9)       /* when pulse is enabling function */
    {                                                      /* pulse rises from 0 to 1         */
       ENABLED = 1;
       LASTTIME = second;
       for (i=0;i<NUMBER;i++)
       {
          COUNTER(i) = 0.0;                                   /* reset stack */
       }
       SUM_TIME = 0;
 
                                                   /* end of next time intervall      */
       if (OFFSET_FLAG > 0.9                   )   /* ==1, then try to find next hour */
       {
          NEXTTIME = second + (int_T)DELTA_T;
          second_full = (second/3600+1)*3600;
          if (second < second_full && NEXTTIME > second_full)
            NEXTTIME = second_full;
       }
       else
          NEXTTIME = second + (int_T)DELTA_T;           
    }
    else if ((PULSE_FLAG>0.9) && ENABLED==1 && INPUT_PULSE<0.1)  /* when pulse is disabling function */
    {                                                      /* pulse descends from 1 to 0       */
       ENABLED = 0;
       NEXTTIME = second-1;
    }

   
    for (i=0;i<NUMBER;i++)
      COUNTER(i) += INPUT(i)*(second-LASTTIME);              /* sum the input to the stack */
    SUM_TIME += second-LASTTIME;
    LASTTIME = second;


    if (second >= NEXTTIME && ENABLED!=0)             /* when end of time intervall is reached */
    {
        for (i=0;i<NUMBER;i++)
        {
          if (SUM_TIME>0)                                      /* make average */
          {
            LAST_OUTPUT(i) = COUNTER(i)/SUM_TIME;
          }
          else
          {
            LAST_OUTPUT(i) = 0.0;
          }
          COUNTER(i) = 0.0;                                     /* reset stack */
        }
        SUM_TIME = 0;

                                             /* end of next time intervall      */
        if (OFFSET_FLAG > 0.9)               /* ==1, then try to find next hour */
        {
           NEXTTIME = second + (int_T)DELTA_T;
             second_full = (second/3600+1)*3600;
           if (second < second_full && NEXTTIME > second_full)
           {
             NEXTTIME = second_full;
           }
        }
        else
        {
           NEXTTIME = second + (int_T)DELTA_T;
        }

        LASTOUTPUT_TIME = second;            /* save time             */
        OUTPUT_PULSE = 1.0;                    /* set output pulse to 1 */
    }
    else
    {
       OUTPUT_PULSE = 0.0;
    }

    for (i=0;i<NUMBER;i++)                   /* set output */
    {
      OUTPUT(i) = LAST_OUTPUT(i);
    }
    OUTPUT_TIME = (double)LASTOUTPUT_TIME;

} /* end mdloutputs */



/* Function: mdlTerminate =====================================================
 * Abstract:
 *    In this function, you should perform any actions that are necessary
 *    at the termination of a simulation.  For example, if memory was
 *    allocated in mdlInitializeConditions, this is the place to free it.
 */
static void mdlTerminate(SimStruct *S /*@unused@*/)
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
