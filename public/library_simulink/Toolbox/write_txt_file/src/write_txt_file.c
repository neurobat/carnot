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
 * Syntax  write_txt_file
 *
 * Version  Author          Changes                                 Date
 * 0.01.0   Thomas Wenzel   created                                 11feb2000
 * 6.1.1	aw				added SimState compilance and			24jul2015
 *							multiple instances
 *							replaced IWork by DWork
 *
 * Copyright (c) 2000 Solar-Institut Juelich, Germany
 * 
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *  D E S C R I P T I O N
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *  This function write the input data to a ascii-txt-file, so it can be opened
 *  be a usual editor.
 *  
 *  The data is only written, when the enable flag is 1.
 * 
 *  It's possible to append data to an existing file or to clear the file before writing.
 *  
 *  
 *  input:  - input data
 *          - enable signal [0,1]
 *  
 *  output: - none
 *  
 *  parameter: - clear flag : 0 = appending
 *                            1 = clear file  
 *             - filename
 */


#define S_FUNCTION_LEVEL 2
#define S_FUNCTION_NAME write_txt_file


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

#define CLEAR_FLAG (*mxGetPr(ssGetSFcnParam(S,0)))   
#define FILENAME ((ssGetSFcnParam(S,1)))
#define N_PARA                             2

/*
 * some defines for access to the input vector
 */
#define INPUT(x)     (*u1Ptrs[x])                      
#define ENABLE       (*u1Ptrs[NUMBER])    

#define IN_WIDTH    DYNAMICALLY_SIZED             /* number of inputs per port */


/*
 * some defines for access to the output vector
 */

#define OUT_WIDTH    1     /* number of outputs per port */


/*
 * some defines for access to the rwork vector
 */

#define NUMBER          dwork_number[0]          /* width of input vector                 */



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
   double number;

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
	ssSetNumDWork(S, 1);
    ssSetDWorkWidth(S, 0, 1); /* heigth of one node */
    ssSetDWorkDataType(S, 0, SS_INT16);
    ssSetDWorkName(S, 0, "DWORK_NUMBER");
    ssSetDWorkUsageType(S, 0, SS_DWORK_USED_AS_DSTATE);
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
    int_T   *dwork_number    = ssGetDWork(S, 0);
    char *name, *model;
    int_T   name_length, status; //i, fehler
    FILE *datei;
    time_t  now;
    struct tm *ts;



    NUMBER   = ssGetInputPortWidth(S,0)-1;  /* width of input vector without pulse */

   if (CLEAR_FLAG)
    {
       name_length = (int_T)(mxGetM(FILENAME)*mxGetN(FILENAME))+1;         /* find filename */
       name = mxCalloc(name_length,sizeof(char));
       status = mxGetString(FILENAME,name,name_length);

       if ((datei=fopen(name,"w"))==NULL)
         printf("error: couldn't open file \"%s\"\n",name);
       else
       {
         name_length = (int_T)strlen(ssGetPath(S));         /* find blockname */
         model = mxCalloc(name_length,sizeof(char));
         strcpy(model,ssGetPath(S));

         (void)time(&now);                                 /* find time */
         ts  = localtime(&now);

         fprintf(datei,"%% This file has been generated at %d:%d on %d.%d.%d "
                       "by the block \"%s\"\n",
                       ts->tm_hour,ts->tm_min,
                       ts->tm_mday,ts->tm_mon+1,ts->tm_year+1900,
                       model);
         (void)fclose(datei);
       }
     }
  
       
  }
#endif /* MDL_INITIALIZE_CONDITIONS */


/* count the seconds in the past year, given by date, no calculation of leap year */




/* Function: mdlOutputs =======================================================
 * Abstract:
 *    In this function, you compute the outputs of your S-function
 *    block. Generally outputs are placed in the output vector, ssGetY(S).
 */
static void mdlOutputs(SimStruct *S, int_T tid)
{
    InputRealPtrsType u1Ptrs = ssGetInputPortRealSignalPtrs(S,0);

    int_T   *dwork_number    = ssGetDWork(S, 0);
  
    //long pos;
    char *name;
    int_T   i, name_length, status; //fehler
    FILE *datei;


    if (ENABLE>0.9)
    {
       name_length = (int_T)(mxGetM(FILENAME)*mxGetN(FILENAME))+1;         /* find filename */
       name = mxCalloc(name_length,sizeof(char));
       status = mxGetString(FILENAME,name,name_length);

       if ((datei=fopen(name,"a"))==NULL)
         printf("error: couldn't open file \"%s\"\n",name);
       else
       {
         for (i=0;i<NUMBER;i++)
         {
            fprintf(datei,"%f ",INPUT(i));
         }
         fprintf(datei,"\n");
         (void)fclose(datei);
       }
     }
 



} /* end mdloutputs */



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
