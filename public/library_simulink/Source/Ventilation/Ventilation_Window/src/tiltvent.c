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
 * Free driven window ventilation based on:
 * Weber, A. Modell für natürliche Lüftung durch Kippfenster. TRNSYS Usertag in Stuttgart, EMPA, CH-8600 Dübendorf, 1997
 *
 * Syntax  [sys, x0] = tiltvent(t,x,u,flag)
 *
 * Version  Author          Changes                                 Date
 * 0.1.0    Philipp Eller   created                                 04jan11
 * 0.1.1    Ralf Dott       corrected to abs(deltaT)                23apr12
 *                          in     ventrate=Cd*Ck*height*sqrt(fabs(deltaT)*gm*height);
 * 6.0.0    Arnold Wohlfeil changed to level 2 S-function           10aug15
 *                          Simstate compiliance
 *                          MultipleExecInstances activated
 *                          include of carlib.h deleted
 * 6.0.1    Arnold Wohlfeil unused functions deleted                10sep15
 *
 * Copyright (c) 2011 Institute of Energy in Building, Switzerland
 *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *  D E S C R I P T I O N
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * modified from mex file tabs.c.
 *
 * structure of u (input vector)
 * index   use
 *  0       ambient temperature                        °C  
 *  1       inside temperature                         °C
 *  2       control [0..1]                              - 
 *
 *
 * structure of y (output vector)
 * index   use
 *  0       Volume flow rate                            m3/h
 *
 * parameters
 * index    use
 *  0       angle alpha (tilt angle of open window)     ° degree
 *  1       Height of Window                            m
 *  2       Width of Window                             m
 *
 */

/* specify the name of your S-Function */

#define S_FUNCTION_NAME tiltvent
#define S_FUNCTION_LEVEL 2

/*
 * Need to include simstruc.h for the definition of the SimStruct and
 * its associated macro definitions. Need math.h for exp-function.
 */
#include "tmwtypes.h"
#include "simstruc.h"
#include <math.h>

/*
 *   Defines for easy access to the parameters (not inputs!) 
 *   that are passed in. (ATTENTION: ssGetArg() returns **Matrix !!
 *   but mxGetPr() converts to double-pointer)
 */
#define ALPHA        (*mxGetPr(ssGetSFcnParam(S,0)))
#define HEIGHT       (*mxGetPr(ssGetSFcnParam(S,1)))
#define WIDTH        (*mxGetPr(ssGetSFcnParam(S,2)))

#define T1       (*u[0])
#define T2       (*u[1])
#define CTRL     (*u[2])


/*
 * mdlInitializeSizes - initialize the sizes array
 *
 * The sizes array is used by SIMULINK to determine the S-function block's
 * characteristics (number of inputs, outputs, states, etc.).
 */

static void mdlInitializeSizes(SimStruct *S)
{
    ssSetNumSFcnParams(S, 3);  /* Number of expected parameters */
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
	ssSetInputPortWidth(S, 0, 3);
    ssSetInputPortDirectFeedThrough(S, 0, 1); /* direct feedthrough flag */
    
    if (!ssSetNumOutputPorts(S, 1))      /* number of outputs   */
    {
        return;
    }
    ssSetOutputPortWidth(S, 0, 1);

    ssSetNumSampleTimes(S, 1);  /* number of sample times */
    ssSetNumDWork(S, 0);  /* number of real work vector elements */
    ssSetNumRWork(S, 0);  /* number of real work vector elements */
    ssSetNumIWork(S, 0);  /* number of integer work vector elements */
    ssSetNumPWork(S, 0);  /* number of pointer work vector elements */
    
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




static void mdlOutputs(SimStruct *S, int_T tid)
{
    InputRealPtrsType u=ssGetInputPortSignal(S, 0);
    real_T *y=ssGetOutputPortSignal(S, 0);
    
    double alpha = ALPHA;
    double height = HEIGHT;
    double width = WIDTH;
    
    double t1 = T1 + 273.15;
    double t2 = T2 + 273.15;
    double ctrl = CTRL;
    
    double ventrate, Cd, Ck, angle, deltaT;
    
    double gm = 1.09; //=g/9
    
    angle = ctrl * alpha;
    deltaT = 2.0*(t1 - t2)/(t1 + t2);
    Cd = 0.0174*angle*width - 0.0928*height + 0.4116*width;
    Ck = 0.0186*angle - 0.000119*angle*angle + 0.00000026*angle*angle*angle;
    ventrate=Cd*Ck*height*sqrt(fabs(deltaT)*gm*height);
    
    /* set outputs */
    y[0] = ventrate;
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
