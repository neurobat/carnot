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
 * printer.c: show incomming values during iteration
 *
 * Version  Author          Changes                                 Date
 * 1.0      Bernd Hafner    created                                 Feb98
 * 0.5.0    hf              toolbox name changed to CARNOT          30apr98
 * 0.5.1    hf              include typedef                         20mai98
 * 6.0.0    aw              converted to level 2 S-function         11aug15
 *                          IWork replaced by DWork vector
 *                          SimStateCompiliance and
 *                          MultipleExecInstances activated
 * 6.0.1    aw              printf format for unsigned int          09sep15
 *                          set to %u
 *
 *
 */


/*
 * You must specify the S_FUNCTION_NAME as the name of your S-function.
 */

#define S_FUNCTION_NAME printer
#define S_FUNCTION_LEVEL 2

/*
 * Need to include simstruc.h for the definition of the SimStruct and
 * its associated macro definitions.
 */
#include "simstruc.h"
#include "tmwtypes.h"

#define DWORK_NPRINTER_NR      0
#define NPRINTER               dwork_nprinter[0]

/* counter of printers in model */
static uint32_T nprinter = 0;


/* Error handling
 * --------------
 *
 * You should use the following technique to report errors encountered within
 * an S-function:
 *
 *       ssSetErrorStatus(S,"Error encountered due to ...");
 *       return;
 *
 * Note that the 2nd argument to ssSetErrorStatus must be persistent memory.
 * It cannot be a stack variable. For example the following will cause 
 * unpredictable errors:
 *
 *	mdlOutputs()
 *      {
 *	   char msg[256];         {ILLEGAL: to fix use "static char msg[256];"}
 *         sprintf(msg,"Error due to %s", string);
 *         ssSetErrorStatus(S,msg);
 *         return;
 *      }
 *
 * See matlabroot/simulink/src/sfunctmpl.doc for more details.
 */

/*====================*
 * S-function methods *
 *====================*/

/* Function: mdlInitializeSizes ===============================================
 * Abstract:
 *
 * The sizes information is used by SIMULINK to determine the S-function 
 * block's characteristics (number of inputs, outputs, states, etc.).
 * 
 */
static void mdlInitializeSizes(SimStruct *S)
{
    ssSetNumSFcnParams(S, 0);  /* Number of expected parameters */
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
        /* Return if number of expected != number of actual parameters */
        return;
    }

    ssSetNumContStates(    S, 0);   /* number of continuous states           */
    ssSetNumDiscStates(    S, 0);   /* number of discrete states             */
    if (!ssSetNumInputPorts(S, 1))   /* number of inputs    */
    {
        return;
    }
    ssSetInputPortWidth(S, 0, DYNAMICALLY_SIZED);
    ssSetInputPortDirectFeedThrough(S, 0, 1);  /* direct feedthrough flag */
     if (!ssSetNumOutputPorts(S, 1))      /* number of outputs   */
    {
        return;
    }
    ssSetOutputPortWidth(S, 0, DYNAMICALLY_SIZED);
    
    ssSetNumSampleTimes(   S, 1);   /* number of sample times                */
    
    ssSetNumRWork(         S, 0);   /* number of real work vector elements   */
    ssSetNumIWork(         S, 0);   /* number of integer work vector elements*/
    ssSetNumPWork(         S, 0);   /* number of pointer work vector elements*/
    
    ssSetNumDWork(S, 1);
    ssSetDWorkWidth(S, 0, 1); /* heigth of one node */
    ssSetDWorkDataType(S, 0, SS_UINT32);
    ssSetDWorkName(S, 0, "DWORK_NPRINTER");
    ssSetDWorkUsageType(S, 0, SS_DWORK_USED_AS_DSTATE);
    
    
    ssSetNumModes(         S, 0);   /* number of mode work vector elements   */
    ssSetNumNonsampledZCs( S, 0);   /* number of nonsampled zero crossings   */
    
    
    ssSetSimStateCompliance(S, USE_DEFAULT_SIM_STATE);
    ssSetSimStateVisibility(S, 1);
    
    ssSupportsMultipleExecInstances(S, true);
}



/* Function: mdlInitializeSampleTimes =========================================
 * Abstract:
 *
 * This function is used to specify the sample time(s) for your S-function.
 * You must register the same number of sample times as specified in 
 * ssSetNumSampleTimes. 
 */
static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, CONTINUOUS_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, 0.0);
    
    /*
     * SET OTHER SAMPLE TIMES AND OFFSETS HERE
     */
}



/* Function: mdlInitializeConditions ==========================================
 * Abstract:
 *
 * In this function, you should initialize the continuous and discrete
 * states for your S-function block.  The initial states are placed
 * in the x0 variable.  You can also perform any other initialization
 * activities that your S-function may require.
 */
#define MDL_INITIALIZE_CONDITIONS
static void mdlInitializeConditions(SimStruct *S)
{
    uint32_T *dwork_nprinter     = (uint32_T *)ssGetDWork(S, DWORK_NPRINTER_NR);

    if (ssIsFirstInitCond(S))
    {
        nprinter++;
        NPRINTER = nprinter;
    }
}



/* Function: mdlOutputs =======================================================
 * Abstract:
 *
 * In this function, you compute the outputs of your S-function
 * block. The outputs are placed in the y variable.
 */
static void mdlOutputs(SimStruct *S, int_T tid)
{
    double  t = ssGetT(S);  
    uint32_T *dwork_nprinter     = (uint32_T *)ssGetDWork(S, DWORK_NPRINTER_NR);
    InputRealPtrsType u=ssGetInputPortSignal(S, 0);
    real_T *y=ssGetOutputPortSignal(S, 0);
    int     nout, i;

    nout = ssGetInputPortWidth(S, 0);
    printf("--> print %u, time %g: ", NPRINTER, t);
    for (i = 0; i < nout; i++)
    {
        printf("%g ", *u[i]);
        y[i] = *u[i];
    }
    printf("\n");
}



/* Function: mdlUpdate ========================================================
 * Abstract:
 *
 * This function is called once for every major integration time step.
 * Discrete states are typically updated here, but this function is useful
 * for performing any tasks that should only take place once per integration
 * step.
 */
/*
static void mdlUpdate(SimStruct *S, int_T tid)
{

}
*/


/* Function: mdlDerivatives ===================================================
 * Abstract:
 *
 * In this function, you compute the S-function block's derivatives.
 * The derivatives are placed in the dx variable.
 */
/*
static void mdlDerivatives(SimStruct *S)
{
}
*/


/* Function: mdlTerminate =====================================================
 * Abstract:
 *
 * In this function, you should perform any actions that are necessary
 * at the termination of a simulation.  For example, if memory was allocated
 * in mdlInitializeConditions, this is the place to free it.
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

#ifdef	MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif
