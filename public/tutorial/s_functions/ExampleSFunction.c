/************************************************************************
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
 * H I S T O R Y
 * Version  Author          Changes                                 Date
 * 6.1.0    Arnold Wohlfeil created                                 2015
 * 
 ***********************************************************************
 *  M O D E L    O R    F U N C T I O N
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *   
 * This is a simplified C code S-Function for Simulink.
 * Inputs:
 * There are two input vectors with two elements each.
 * Input vector 0 can be accessed by *u0[0], *u0[1] .
 * Input vector 1 can be accessed by *u1[0], *u1[1] .
 * 
 * Outputs:
 * There are two outputs with one element each.
 * Output 0 can be accessed by y0[0] .
 * Output 1 can be accesses by y1[0] .
 *
 * Parameters:
 * There is one parameter with one element.
 * It can be accesses by *p0[0] .
 *
 * The equations are
 * y0[0] = (*u0[0] + *u0[1]) * (*p0[0])
 * d y1[0] / dt = ( *u1[0] + *u1[1] ) * (*p0[0]) + y0[0]
 * /

/* General strategy of this S-function:
 * First tell Simulink about the interfaces. This is done in mdlInitializeSizes and mdlInitializeSampleTimes.
 * These two functions are called during the initialisation of a model.
 * Second set the initial conditions. This is done in mdlInitializeConditions.
 * This function is called during initialisation as well.
 * Third calculate the outputs in mdlOutputs.
 * Fourth calculate the derivatives in mdlOutputs.
 * The function mdlOutput is called before mdlDerivates in each simulation step!
 * Fifth do cleanup work in mdlTerminate. This is done in the end of the simulation.

 *
/*
 * Each S-function must contain the functions
 * mdlInitializeSizes - tells Simulink everything about the interface (e.g. number of in- and outports)
 * mdlInitializeSampleTimes - tells Simulink about the sample time; this function can be copied in most cases
 * mdlOutputs - here the outports are st
 * mdlTerminate - in this example the function is empty; use it to tell Simulink what to do when finishing the simulation
 *
 * Furthermore, we have these two functions in our example
 * mdlInitializeConditions - sets the initial values of the continuous states (integrators)
 * and the Work vectors
 * mdlDerivatives - sets the derivative with respect to time
 */




/* specify the name of your S-Function */

/* first the name of the S-function must be defined.
 * The name is case-sensitive
 * Please take care the the compiled version is case sensitive as well.
 * If this is neglected, Simulink will crash.
 */
#define S_FUNCTION_NAME ExampleSFunction
/* please use level 2 S-functions only */
#define S_FUNCTION_LEVEL 2

/*
 * Here the Simulink interface functions are included
 */
#include "tmwtypes.h"
#include "simstruc.h"
 


/*
 * mdlInitializeSizes - initialize the sizes array
 *
 * The sizes array is used by SIMULINK to determine the S-function block's
 * characteristics (number of inputs, outputs, states, etc.).
 */

static void mdlInitializeSizes(SimStruct *S)
{
    ssSetNumSFcnParams(S, 1);  /* Number of expected parameters is one */
    /* check if the number of parameters is correct */
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S))
    {
        /* Return if number of expected != number of actual parameters */
        return;
    }
    
    /* Continuous states are used for integration.
     * Here we define one integrator.
       Integrators are called continuous states in Simulink */
    ssSetNumContStates(S, 1);  /* number of continuous states */
    
    /* We do not consider discrete systems */
    ssSetNumDiscStates(S, 0);      /* number of discrete states    */
    
    /* Now we set the number of inports (2 here) */
    if (!ssSetNumInputPorts(S, 2))   /* number of inputs    */
    {
        return;
    }
    /* Set number of elements to 2 for each inport */
	ssSetInputPortWidth(S, 0, 2);
    ssSetInputPortWidth(S, 1, 2);

    /* Direct feedthrough is a complicated concept at a first glance.
     * If the flag is set, at least one output is directly (i.e. without an integrator)
     * depended on the input. In other words, if the input is accessed in
     * the function mdlOutputs, set this flag to 1*/
    
    /* Inport 0 is directly used in mdlOutputs. So we face so called direct feed through.
     * If we would disable the flag, Simulink will crash when starting the simulation.
     */
    ssSetInputPortDirectFeedThrough(S, 0, 1);
    /* Inport 1 is not used in mdlOutputs (it is used in mdlDerivatives only).
     * So we can disable the flag. */
	ssSetInputPortDirectFeedThrough(S, 1, 0);
    /* We could directly feed output port 1 to the input of this S-function.
     * If we would do this with inport port 0, we would create an algebraic loop. */

    
    /* Set the number of outputs to 2 */
    if (!ssSetNumOutputPorts(S, 2))
    {
        return;
    }
    /* Set the number of elements for each outport to one */
    ssSetOutputPortWidth(S, 0, 1);
    ssSetOutputPortWidth(S, 1, 1);

    
    /* We only have one sample time */
    ssSetNumSampleTimes(S, 1);  /* number of sample times       */
    
    /* Work vectors are used to communicate between the functions.
     * They are a kind of global variables and should be avoided.
     * Sometimes, it might be helpful to use them to reduce
     * computational time (e.g. if several functions need to access
     * the same calculation) or as a kind of states.
     * If you really need such a work vector, please use DWork
     * vectors */
    ssSetNumRWork(S, 0); /* number of real work vector elements    */
    ssSetNumIWork(S, 0); /* number of integer work vector elements */
    ssSetNumPWork(S, 0); /* number of pointer work vector elements */
    
    /* one DWork vector shall be used here */
	ssSetNumDWork(S, 1); /* number of D work vector elements */
    ssSetDWorkWidth(S, 0, 1); /* there should be one element */
    ssSetDWorkDataType(S, 0, SS_DOUBLE); /* type double */
    ssSetDWorkName(S, 0, "DWORK_MYVECTOR"); /* give it a name */
    ssSetDWorkUsageType(S, 0, SS_DWORK_USED_AS_DSTATE); /* use it as state */
    /* If DWork vectors are used a DSTATE as in the last line, they must have a name
     * (here "DWORK_MYVECTOR").
     * Under these conditions, the DWork vector is SimState compliant.
     */
	
    /* If you only use continuous states and no work vectors or DSTATE DWork vectors,
     * set SimState compliance.
     * SimState compliance is useful if a simulation is stopped. All states
     * are saved and the simulation can be started from the termination point again.
     */
	ssSetSimStateCompliance(S, USE_DEFAULT_SIM_STATE);
    ssSetSimStateVisibility(S, 1);
    
    /* This flag is needed for ForEach subsystems */
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
    ssSetSampleTime(S, 0, CONTINUOUS_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, 0.0);
}


/*
 * mdlInitializeConditions - initialize the states
 *
 * In this function the initial states are set.
 * In our example, it is the integration constant and
 * the DWork vector.
 */
#define MDL_INITIALIZE_CONDITIONS
static void mdlInitializeConditions(SimStruct *S)
{
    /* This is the access function for the continuous states.
     * It return a pointer to the first continuous state.
       The continuous states can be accessed as array elements in C.
     */
    real_T *x=ssGetContStates(S);
    /* The data type real_T is defined by Simulink. Under normal conditions
     * it is the same as double. */
    
    /* This access function returns a pointer to the first DWork vector */
    real_T *D0 = (real_T*)ssGetDWork(S, 0);
    /* uint8_T is an 8 bit unsigned integer data type */
    
    /* set the first (and only) integrator to zero for t = 0 */
    x[0] = 0.0;
    
    /* set the first and only element of the first and only DWork vector */
    D0[0] = 0.0;
    /* In this example, there is actually no need to initialise the DWork vector:
     * This is because in mdlOutputs a value is written to the DWork vector.
     * In mdlDerivates it is read. Since mdlOutputs is called before mdlDerivatives,
     * there always will be a valid value in the DWork vector. However, it is a
     * good style to initialise work vectors as well.
     */
}


/*
 * mdlOutputs - compute the outputs
 */

static void mdlOutputs(SimStruct *S, int_T tid)
{
	
    /* Define variables:
     * Normally the interface functions return a pointer.
     * For example, to access the first inport we define
     * InputRealPtrsType u0=ssGetInputPortSignal(S, 0);
     * now we can access the first element of inport 0
     * by *u0[0], the second element of inport 0 by
     * *u0[1] etc. Similary we can access the
     * outport, the parameters and the continuous states. */
    
    
    /* access input port 0 */
    InputRealPtrsType u0=ssGetInputPortSignal(S, 0);
    
     /* access all continuous states
        Simulink will do the integration.
      */
	real_T *x=ssGetContStates(S);
    
    /* access both output ports */
	real_T *y0=ssGetOutputPortSignal(S, 0);
    real_T *y1=ssGetOutputPortSignal(S, 1);

    /* access parameter 0 */
    real_T *p0 = mxGetPr(ssGetSFcnParam(S,0));
    
    /* access DWork vector */
    real_T *D0 = (real_T*)ssGetDWork(S, 0);
    
    /* set output port 0
     * The output is directly depended on input 0 */
    y0[0] = ((*u0[0])+(*u0[1])) * (*p0);
    
    /* assign the value of the first output to the DWork vector */
    /* The value will be used in mdlDerivatives. There is no need to
     * calculate it again in mdlDerivatives. */
    D0[0] = y0[0];
    
    /* set output port 1 */
    y1[0] = x[0];

} /* end mdlOutputs */



/*
 * mdlDerivatives - compute the derivatives
 *
 * In this function, you compute the S-function block's derivatives.
 * The derivatives are placed in the dx variable.
 */
#define MDL_DERIVATIVES
static void mdlDerivatives(SimStruct *S)
{
    /* access function for the continuous states, i.e. the integrator */
    real_T *x = ssGetContStates(S);
    
    /* access the derivative with respect to time */
	real_T *dx = ssGetdX(S);
    
    /* access input port 1 */
	InputRealPtrsType u1=ssGetInputPortSignal(S, 1);
    
    /* access parameter 0 */
    real_T *p0 = mxGetPr(ssGetSFcnParam(S,0));
    
    /* access DWork vector */
    real_T *D0 = (real_T*)ssGetDWork(S, 0);


    /* Set the derivative.
     * The integration will be done by Simulink */
    dx[0] = (*u1[0] + *u1[1]) * p0[0] + D0[0];
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
    /* nothing to do */
}

#ifdef	MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif
