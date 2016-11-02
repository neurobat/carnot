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
 * Venetian Blinds shading
 *
 * Syntax  [sys, x0] = venetian(t,x,u,flag)
 *
 * Version  Author          Changes                               Date
 * 0.1.0    Philipp Eller   created                               05jan2011
 * 6.0.0    Arnold Wohlfeil changed to level 2 S-function         10aug2015
 *                          SimState compiliance
 *                          some formal changes
 *                          inner switch-case loop corrected
 *                          (break included)
 *                          deleted include for carlib.h
 *                          MultipleExecInstanes enabled
 * 6.0.1    Arnold Wohlfeil unused functions deleted              10sep2015
 *
 * Copyright (c) 2011 Institute of Energy in Building, Switzerland
 * All Rights Reserved
 *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *  D E S C R I P T I O N
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * modified from mex file tiltvent.c, code ported and optimized from WindowShading.m
 *
 * structure of u (input vector)
 * index   use
 *  0       ff                                          X  
 *
 * structure of y (output vector)
 * index   use
 *  0       ff                                          X
 *
 * parameters
 * index    use
 *  0       ff                                          X
 *
 */

/* specify the name of your S-Function */
#define S_FUNCTION_NAME venetian
#define S_FUNCTION_LEVEL 2

/*
 * Need to include simstruc.h for the definition of the SimStruct and
 * its associated macro definitions. Need math.h for exp-function.
 */
#include "tmwtypes.h"
#include "simstruc.h"
#include <math.h>


#define BLI_A        (*mxGetPr(ssGetSFcnParam(S, 0)))
#define BLI_B        (*mxGetPr(ssGetSFcnParam(S, 1)))
#define BLI_C        (*mxGetPr(ssGetSFcnParam(S, 2)))
#define BLI_D        (*mxGetPr(ssGetSFcnParam(S, 3)))
#define BLI_ALPHA    (*mxGetPr(ssGetSFcnParam(S, 4)))
#define BLI_REFL     (*mxGetPr(ssGetSFcnParam(S, 5)))
#define SHAD_TYPE    ((int)(*mxGetPr(ssGetSFcnParam(S, 6))+0.5))
#define TYPE_GLAZING ((int)(*mxGetPr(ssGetSFcnParam(S, 7))+0.5))
#define TAU_SHAD     (*mxGetPr(ssGetSFcnParam(S, 8)))

#define R_SHAD       (*u[0])
#define ZEN_ANGLE    (*u[1])

/*
 * mdlInitializeSizes - initialize the sizes array
 *
 * The sizes array is used by SIMULINK to determine the S-function block's
 * characteristics (number of inputs, outputs, states, etc.).
 */

static void mdlInitializeSizes(SimStruct *S)
{
    ssSetNumSFcnParams(S, 9);  /* Number of expected parameters */
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S))
    {
        /* Return if number of expected != number of actual parameters */
        return;
    }
    
    ssSetNumContStates(S, 0);  /* number of continuous states */
    ssSetNumDiscStates(S, 0);  /* number of discrete states */
    
    if (!ssSetNumInputPorts(S, 1))   /* number of inputs    */
    {
        return;
    }
    ssSetInputPortWidth(S, 0, 2);
    ssSetInputPortDirectFeedThrough(S, 0, 1);  /* direct feedthrough flag */
    
    if (!ssSetNumOutputPorts(S, 1))      /* number of outputs   */
    {
        return;
    }
    ssSetOutputPortWidth(S, 0, 4);
    
    
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


static void mdlOutputs(SimStruct *S, int_T tid)
{
    InputRealPtrsType u = ssGetInputPortSignal(S, 0);
    real_T *y = ssGetOutputPortSignal(S, 0);
    
    int shad_type = SHAD_TYPE;
    double r_shad = R_SHAD;
	int type_glazing = TYPE_GLAZING;
    double tau_shad = TAU_SHAD;
    double bli_a = BLI_A;
    double bli_b = BLI_B;
    double bli_c = BLI_C;
    double bli_d = BLI_D;
    double bli_refl = BLI_REFL;
	#ifdef PI
        double pi = PI;
    #else
        double pi = 3.14159;
    #endif
    double zen_angle = ZEN_ANGLE*pi/180.0;
    double bli_alpha = BLI_ALPHA*pi/180.0;
    double cos_a = cos(bli_alpha);
    double sin_a = sin(bli_alpha);  
    double X_shad, X_shad_a, X_shad_b, F_Shad_dir, bli_r, a2, d2, f_para, e_para, gamma, F_Shad_dfu, refl_alpha, D_refl, f_g;
    double el_h=(pi/2.0-zen_angle);
    double epsilon=atan(bli_b/bli_c);
    double A_corr=1.3; //weight factor empirically evaluated with task34 empa measurments
    
    

    switch(shad_type)
    {
        case 1:
        {
          //no blinds
          y[0]=1.0;
          y[1]=1.0;
          y[2]=1.0;
          y[3]=1.0;
          break;
        } /* end case 1 */
        case 2:
        {
          //'Exterior Screen'
          y[0]=1.0-r_shad*(1.0-tau_shad);
          y[1]=1.0-r_shad*(1.0-tau_shad);
          y[2]=1.0;
          y[3]=1.0;
          break;
        } /* end case 2 */
        case 3:
        {
          //'Interior Screen'
            f_g=1.0;
            switch (type_glazing) //shading: Selection of glasing type, setting appropriate reducing factor for g value
            {
                case 1:
                    f_g = 0.48;
                    break;
                case 2:
                    f_g = 0.66;
                    break;
                case 3:
                    f_g = 0.73;
                    break;
                case 4:
                    f_g = 0.85;
                    break;
                case 5:
                    f_g = 0.54;
                    break;
                case 6:
                    f_g = 0.74;
                    break;
            }
            y[0]=1.0;
            y[1]=1.0;
            y[2]=1.0-((1.0-f_g)*r_shad);
            y[3]=1.0-(r_shad*(1.0-tau_shad));
            break;
        } /* end case 3 */
        case 4:
        {
          //venetian blinds

            //*** Shading of direct beam irradiance ***
            // shading through element b
            if ((bli_alpha+epsilon) > (el_h+(pi/2.0)))
            {
              bli_r=sqrt((pow(bli_c,2.0)+pow(bli_b,2.0)));
              X_shad_b=-1.0*bli_r*cos(bli_alpha+epsilon-el_h)/cos(el_h);
            }
            else
            {
                X_shad_b=0.0;
            }
            // shading through element a.  Calculation is identical to method by H. Simmler
            X_shad_a = bli_a*(cos_a+sin_a*tan(el_h));
            if (X_shad_a<0.0)
            {
                X_shad_a=1.0;
            }
            // shading factor
            X_shad=X_shad_a+X_shad_b;  
            if (X_shad > bli_d)
            {
                F_Shad_dir=1;
            }
            else
            {
                F_Shad_dir=(X_shad)/bli_d;
            }

            //*** Shading of diffuse irradiance ***
            // Modelling with view factor method:
            // Calculation of "left open angle" gamma
            a2 = pow(bli_a,2.0);
            d2 = pow(bli_d,2.0);
            f_para=(a2+d2-2.0*(bli_d*bli_a*cos_a))/4.0;
            e_para=(a2+d2+2.0*(bli_d*bli_a*cos_a))/4.0;
            gamma = acos((f_para+e_para-d2)/(2.0*sqrt(f_para*e_para)));
            F_Shad_dfu = 1.0-(gamma/pi); // View Factor for geometrical shading of diffuse irradiance
            // Reflectance
            refl_alpha=(1.0-cos_a); // 1=no Reflection 0=Total Reflection (Reflectance of diffuse irradiance)
            D_refl = (1.0-bli_refl*refl_alpha)*A_corr; 
            F_Shad_dfu = F_Shad_dfu*D_refl; // reducing shading factor with Reflectance factor 
            // set outputs
            y[0]=1.0-(r_shad*F_Shad_dir);
            y[1]=1.0-(r_shad*F_Shad_dfu); 
            y[2]=1.0;
            y[3]=1.0;
            break;
          } /* end case 4 */
	} /* end switch */

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

