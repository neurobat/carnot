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
 * heating/cooling power from thermally activated building components
 *
 * Syntax  [sys, x0] = tabs(t,x,u,flag)
 *
 * Version  Author          Changes                                 Date
 * 0.1.0    Ralf Dott       created                                 06jun06
 * 0.1.1    wec		        massflow and length adapted to 	        23jun09
 *                          loop over n pipe pieces
 * 0.1.2    wec             comment of type of calculated           29jun09
 *                          system added 
 * 0.1.3    Ralf Dott       calculation of massflow dependent       22nov13
 *                          heatflux resitances corrected &
 *                          mdot_sp_nom, cap_fl_nom, lambda_fl_nom
 *                          changed to dynamic calculation
 * 0.1.4    Christian       call to thermal_conductivity and        02jul14 
 *          Winteler        heat_capacity corrected
 * 6.0.0    Arnold Wohlfeil changed to level 2 S-function           10aug15
 *                          Simstate compiliance
 *                          MultipleExecInstances activated
 * 6.0.1    Arnold Wohlfeil #define MDL_INITIALIZE_CONDITIONS       17aug15
 *                          added
 *
 *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *  D E S C R I P T I O N
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * modified from mex file for multi-input, multi-output state-space system.
 *
 * structure of u (input vector)
 * index   use
 *  0       flow temperature                            °C  
 *  1       massflow                                    kg/s
 *  2       pressure                                    Pa  
 *  3       fluid ID (defined in CARNOT.h)              -    
 *  4       mixture  (defined in CARNOT.h)              -    
 *  5       temperature of wall layer                   °C   
 *
 *
 * structure of y (output vector)
 * index   use
 *  0       heating/cooling power                       W
 *  1       return temperature                          °C
 *
 * parameters
 * index    use
 *  0       thickness of active layer                   m
 *  1       depth of pipes in active layer              m
 *  2       outer diameter of pipes                     m
 *  3       wall thickness of pipe                      m
 *  4       distance between center of pipes            m
 *  5       length of pipe                              m
 *  6       thermal conductivity of pipe                W/(m*K)
 *  7       thermal conductivity of layer material      W/(m*K)
 *
 */

/* specify the name of your S-Function */

#define S_FUNCTION_NAME tabs
#define S_FUNCTION_LEVEL 2


/*
 * Need to include simstruc.h for the definition of the SimStruct and
 * its associated macro definitions. Need math.h for exp-function.
 */
#include "tmwtypes.h"
#include "simstruc.h"
#include "carlib.h"
#include <math.h>

#ifndef PI
    #define PI      3.14159265358979
#endif

/*
 *   Defines for easy access to the parameters (not inputs!) 
 *   that are passed in. (ATTENTION: ssGetArg() returns **Matrix !!
 *   but mxGetPr() converts to double-pointer)
 */
#define D_LAYER        (*mxGetPr(ssGetSFcnParam(S,0)))
#define D_ACTIVE       (*mxGetPr(ssGetSFcnParam(S,1)))
#define D_PIPE         (*mxGetPr(ssGetSFcnParam(S,2)))
#define D_R            (*mxGetPr(ssGetSFcnParam(S,3)))
#define D_X            (*mxGetPr(ssGetSFcnParam(S,4)))
#define LENGTH         (*mxGetPr(ssGetSFcnParam(S,5)))
#define LAMBDA_R       (*mxGetPr(ssGetSFcnParam(S,6)))
#define LAMBDA_B       (*mxGetPr(ssGetSFcnParam(S,7)))


#define T_FL       (*u[0])
#define MDOT       (*u[1])
#define PRESS      (*u[2])
#define FLUID_ID   (*u[3])
#define PERCENTAGE (*u[4])
#define T_WALL     (*u[5])


/*
 * mdlInitializeSizes - initialize the sizes array
 *
 * The sizes array is used by SIMULINK to determine the S-function block's
 * characteristics (number of inputs, outputs, states, etc.).
 */

static void mdlInitializeSizes(SimStruct *S)
{
    ssSetNumSFcnParams(S, 8);  /* Number of expected parameters */
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
	ssSetInputPortWidth(S, 0, 6);
    ssSetInputPortDirectFeedThrough(S, 0, 1); /* direct feedthrough flag */

    ssSetNumSampleTimes(S, 1);  /* number of sample times */
    ssSetNumDWork(S, 0);  /* number of Dwork vector elements */
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



#define MDL_INITIALIZE_CONDITIONS
/*
 * mdlInitializeConditions - initialize the states
 *
 * In this function, you should initialize the continuous and discrete
 * states for your S-function block.  The initial states are placed
 * in the x0 variable.  You can also perform any other initialization
 * activities that your S-function may require.
 */
static void mdlInitializeConditions(SimStruct *S)
{
    double d_layer = D_LAYER;
    double d_active = D_ACTIVE;
    double d_pipe = D_PIPE;
    double d_x = D_X;

    if (d_pipe/d_x < 0.2)   
    { 
        /* printf(" \n You are calculating a TABS or floor heating system \n\n"); */ 
        if (d_layer / d_x < 0.3 || (d_layer - d_active) / d_x < 0.3) /* Error message for conditions outside the model boundaries */ 
        { 
            printf("WARNING in tabs floor heating system: depth of pipes in active layer must be greater than 0.3 * distance between center of pipes OR outer diameter of pipes must be less than 0.2 * distance between center of pipes \n\n"); 
        } 
        else /* normal floor heating or TABS according to Koschenz/Lehmann (2000) chap. 4 */ 
        { 
        } 
    } 
    else   
    { 
        /* printf("  \n  You are calculating a capillary tube system \n\n"); */ 
    } 
}




/*
 * mdlOutputs - compute the outputs
 */

static void mdlOutputs(SimStruct *S, int_T tid)
{
    InputRealPtrsType u = ssGetInputPortSignal(S, 0);
    real_T *y = ssGetOutputPortSignal(S, 0);
    
    double d_layer = D_LAYER;
    double d_active = D_ACTIVE;
    double d_pipe = D_PIPE;
    double d_r = D_R;
    double d_x = D_X;
    double length = LENGTH;
    double lambda_r = LAMBDA_R;
    double lambda_b = LAMBDA_B;
    
    double t_flow = T_FL;
    double mdot = MDOT;
    double p = PRESS;
    double fluid_id = FLUID_ID;
    double mix = PERCENTAGE;
    double t_wall = T_WALL;

    double t_flow_i, t_return_i, qdot_i, mdot_sp, lambda_fl, cap_fl;
    double R_t, R_r, R_x, R_w, R_z, n, i;
    
    double power, t_return;
    
    t_flow_i = t_flow;
    t_return_i = t_flow;
    qdot_i = 0;
    mdot_sp = mdot / length / d_x;
/*    lambda_fl = thermal_conductivity(t_flow, p, fluid_id, mix);*/
    lambda_fl = thermal_conductivity(fluid_id, mix, t_flow, p);
/*    cap_fl = heat_capacity(t_flow, p, fluid_id, mix);*/
    cap_fl = heat_capacity(fluid_id, mix,t_flow, p);  
    R_t=0; R_r=0; R_x=0; R_w=0; R_z=0; n=0; i=0;
    
    power = 0;
    t_return = t_flow;
    
    if (d_pipe/d_x < 0.2)
    {
        R_r = d_x / 2 / PI / lambda_r * log( d_pipe / (d_pipe - 2 * d_r) );
        R_x = d_x / 2 / PI / lambda_b * log( d_x / PI / d_pipe );
        R_w = pow(d_x, 0.13) / 8 / PI * pow( ((d_pipe - 2 * d_r) / mdot_sp / length), 0.87); /* m2K/W */
        n = ceil( 0.5 / (cap_fl * mdot_sp * ( R_r + R_x + R_w )) ); /* instationary case */
        R_z = 0.5 / mdot_sp / n / cap_fl;
    }
    else  /* capillary tubes according to Koschenz/Lehmann (2000) chap. 5 */
    {
        R_r = d_x / 2 / PI / lambda_r * log( d_pipe / (d_pipe - 2 * d_r) );
        R_x = d_x / 2 / PI / lambda_b / 3 * ( d_x / PI / d_pipe );
        R_w = d_x / PI / lambda_fl * pow((49.03 + 4.17 * 4 / PI * mdot_sp * cap_fl * d_x / lambda_fl), -1/3);
        n = ceil( 0.5 / (cap_fl * mdot_sp * ( R_r + R_x + R_w )) ); /* instationary case */
        R_z = 0.5 / mdot_sp / n / cap_fl;
    }
    
    if (mdot > 0)
    {
    for (i=1; i<=n; i++)
    {
/*        lambda_fl = thermal_conductivity(t_flow_i, p, fluid_id, mix);*/
        lambda_fl = thermal_conductivity(fluid_id, mix, t_flow_i, p);
/*        cap_fl = heat_capacity(t_flow_i, p, fluid_id, mix);*/
        cap_fl = heat_capacity(fluid_id, mix,t_flow_i, p);  
        if (d_pipe/d_x < 0.2)
        {
            R_r = d_x / 2 / PI / lambda_r * log( d_pipe / (d_pipe - 2 * d_r) );
            R_x = d_x / 2 / PI / lambda_b * log( d_x / PI / d_pipe );
            R_w = pow(d_x, 0.13) / 8 / PI * pow( ((d_pipe - 2 * d_r) / mdot_sp / length), 0.87);
            R_z = 0.5 / mdot_sp / n / cap_fl;
        }
        else  /* capillary tubes according to Koschenz/Lehmann (2000) chap. 5 */
        {
            R_r = d_x / 2 / PI / lambda_r * log( d_pipe / (d_pipe - 2 * d_r) );
            R_x = d_x / 2 / PI / lambda_b / 3 * ( d_x / PI / d_pipe );
            R_w = d_x / PI / lambda_fl * pow((49.03 + 4.17 * 4 / PI * mdot_sp * cap_fl * d_x / lambda_fl), -1/3);
            R_z = 0.5 / mdot_sp / n / cap_fl;
        }
        R_t = R_r + R_x + R_w + R_z;
        qdot_i = (t_flow_i - t_wall) / R_t;
        t_return_i = t_flow_i - qdot_i / (mdot_sp*n) / cap_fl;
        /* printf("R_z: %f  R_w:  %f   R_r:   %f    R_x:   %f   \n",R_z,R_w,R_r,R_x);
	    printf("R_t: %f  UA:   %f    qdot_i:  %f   \n",R_t,1/R_t,qdot_i);
	    printf("t_flow: %f     t_flow_i: %f  t_return_i:  %f   t_wall:   %f   n:  %f   i:  %f   \n\n",t_flow,t_flow_i,t_return_i,t_wall,n,i); */
        power = power + qdot_i * length/n * d_x ;
        t_flow_i = t_return_i;
        

    }
    t_return = t_return_i;
    }
    else
    {
    t_return = t_wall;
    }
    
    /* set outputs */
    y[0] = power;       /* heating/cooling power */
    y[1] = t_return;    /* return temperature */
}


/*
 * mdlUpdate - perform action at major integration time step
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

/*
 * mdlDerivatives - compute the derivatives
 *
 * In this function, you compute the S-function block's derivatives.
 * The derivatives are placed in the dx variable.
 */
/*
static void mdlDerivatives(SimStruct *S)
{
}
*/

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
