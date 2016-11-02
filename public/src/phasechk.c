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
 * phase check for fluids
 *
 * Syntax  [sys, x0] = phasechk(t,x,u,flag)
 *
 * Version  Author          Changes                                 Date
 * 0.5.0    Bernd Hafner    created                                 02mai98
 * 0.5.1    hf              material properties from carlib         20mai98
 * 0.8.0    hf              extend glycol mixtures                  15jul98
 * 6.0.0    Arnold Wohlfeil changed to level 2 S-function           11aug15
 *                          SimState compiliance
 *                          MultipleExecInstanes enabled
 *
 * Copyright (c) 1998 Solar-Institut Juelich, Germany
 * 
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *  D E S C R I P T I O N
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * structure of u (input vector)
 *  see defines below
 *
 * structure of y (output vector)
 *  index   use
 *  0       stop signal
 */

/* specify the name of your S-Function */

#define S_FUNCTION_NAME phasechk
#define S_FUNCTION_LEVEL 2

/*
 * Need to include simstruc.h for the definition of the SimStruct and
 * its associated macro definitions. Need math.h for exp-function.
 */
#include "tmwtypes.h"
#include "simstruc.h"

#include <math.h>
#include "carlib.h"

/*
 *   Defines for easy access to the parameters (not inputs!) 
 *   that are passed in. (ATTENTION: ssGetArg() returns **Matrix !!
 *   but mxGetPr() converts to double-pointer)
 */
                             
#define TIN        (*u[0])      /* inlet temperature */
#define MDOT       (*u[1])      /* massflow */
#define PRESS      (*u[2])      /* pressure */
#define FLUID_ID   (*u[3])      /* fluid ID (defined in CARNOT.h) */
#define PERCENTAGE (*u[4])      /* mixture  (defined in CARNOT.h) */


/*
 * mdlInitializeSizes - initialize the sizes array
 *
 * The sizes array is used by SIMULINK to determine the S-function block's
 * characteristics (number of inputs, outputs, states, etc.).
 */

static void mdlInitializeSizes(SimStruct *S)
{
    ssSetNumSFcnParams(S, 0);  /* Number of expected parameters */
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S))
    {
        /* Return if number of expected != number of actual parameters */
        return;
    }
    ssSetNumContStates(    S, 0);  /* number of continuous states */
    ssSetNumDiscStates(    S, 0);  /* number of discrete states */
    
    if (!ssSetNumInputPorts(S, 1))   /* number of inputs    */
    {
        return;
    }
	ssSetInputPortWidth(S, 0, 5);
    ssSetInputPortDirectFeedThrough(S, 0, 1); /* direct feedthrough flag */
    
    if (!ssSetNumOutputPorts(S, 0))      /* number of outputs   */
    {
        return;
    }
    ssSetNumSampleTimes(   S, 1);  /* number of sample times */
    ssSetNumRWork(         S, 0);  /* number of real work vector elements */
    ssSetNumIWork(         S, 0);  /* number of integer work vector elements */
    ssSetNumPWork(         S, 0);  /* number of pointer work vector elements */
    
    ssSetSimStateCompliance(S, USE_DEFAULT_SIM_STATE);
    ssSetSimStateVisibility(S, 1);
    
    ssSupportsMultipleExecInstances(S, true);
}

/*
 * mdlInitializeSampleTimes - initialize the sample times array
 *
 * This function is used to specify the sample time(s) for your S-function.
 * If your S-function is continuous, you must specify a sample time of 0.0.
 * Sample times must be registered in ascending order.  If your S-function
 * is to acquire the sample time of the block that is driving it, you must
 * specify the sample time to be INHERITED_SAMPLE_TIME.
 */

static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, 0.0);
    ssSetOffsetTime(S, 0, 0.0);
}


/*
 * mdlInitializeConditions - initialize the states
 *
 * In this function, you should initialize the continuous and discrete
 * states for your S-function block.  The initial states are placed
 * in the x0 variable.  You can also perform any other initialization
 * activities that your S-function may require.
 */
/*
static void mdlInitializeConditions(real_T *x0, SimStruct *S)
{
}
*/

/*
 * mdlOutputs - compute the outputs
 */

static void mdlOutputs(SimStruct *S, int_T tid)
{
    InputRealPtrsType u = ssGetInputPortSignal(S, 0);
    int stop = 0;
    double pc;

    switch ((int)FLUID_ID)
    {
        case 1: /* water */
            /* vapor pressure line of water */
            pc = vapourpressure(FLUID_ID,PERCENTAGE,TIN,PRESS);
            if (TIN < 0.0)
            {
                ssSetErrorStatus(S,"The water in your system is ice. Stopping simulation.\n");
                return;
            }
            if (PRESS < pc)
            {
                ssSetErrorStatus(S,"The water in your system is steam. Stopping simulation.\n");
                return;
            }
            break;
        case 2: /*air */
            if (TIN < -273.15)
            {
                ssSetErrorStatus(S,"Your system temperature is below 0 K. Stopping simulation.\n");
                return;
            }
            break;
        case 3: /* cotton oil */
            if (TIN < -20.0) {
                ssSetErrorStatus(S,"The oil in your system is solid. Stopping simulation.\n");
                return;
            } 
            if (TIN > 450.0)
            {
                ssSetErrorStatus(S,"The oil in your system has cracked. Stopping simulation.\n");
                return;
            }
            break;
        case 4: /* silicone oil */
            if (TIN < -50.0)
            {
                ssSetErrorStatus(S,"The oil in your system is solid. Stopping simulation.\n");
                return;
            }
            else if (TIN > 450.0)
            {
                ssSetErrorStatus(S,"The oil in your system has cracked. Stopping simulation.\n");
                return;
            }
            break;
        case 5: /* water glycol mix */
            pc = vapourpressure(FLUID_ID,PERCENTAGE,TIN,PRESS);
            if (TIN < ((-222.2222*PERCENTAGE+61.9048)*PERCENTAGE-48.7302)*PERCENTAGE)
            {
                ssSetErrorStatus(S,"The water-glycol mix in your system is ice. Stopping simulation.\n");
                return;
            }
            if (PRESS < pc)
            {
                ssSetErrorStatus(S,"The water-glycol in your system is steam. Stopping simulation.\n");
                return;
            }
            break;
        default: /* material not known */
            break;
    }

    /* set outputs */
    /* y[0] = stop; */
}


/*
 * mdlTerminate - called when the simulation is terminated.
 *
 * In this function, you should perform any actions that are necessary
 * at the termination of a simulation.  For example, if memory was allocated
 * in mdlInitializeConditions, this is the place to free it.
 */

static void mdlTerminate(SimStruct *S)
{
}

#ifdef	MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif

