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
 * calculation of the position
 * output: 1 - solar zentith angle
 *         2 - solar azimut angle
 *
 * * list of authors  * * * *
 * cw -> Carsten Wemhoener
 * hf -> Bernd Hafner
 * aw -> Arnold Wohlfeil
 * 
 * * version management * * *
 * Version  Author  Changes                                       Date
 * 0.1.0    cw      created                                       March1998
 * 0.1.1    hf      incidence angle on collector is not output,   14mar1998
 *                  timezone is a parameter
 * 0.5.0    hf      toolbox name changed to CARNOT                30apr1998
 * 0.8.0    hf      changed to easier variabe access              30jun1998
 * 0.11.0   hf      old type declarations removed                 11jan1999
 *                  corrected hourangle (woz not moz)
 * 0.11.1   hf      interpolate azimuth+zenith at sunrise/sunset  11jan1999
 * 3.1.0    hf      functions now in carlib                       26dec2008
 * 6.1.0    hf      added commments                               28feb2015
 * 6.1.1    aw      converted to level 2 S-function               10aug2015
 *                  RWork converted to DWork
 *                  Simstate compiliance and
 *                  MultipleExecInstances activated
 * 6.1.2    aw      DWork-vectors initialisated                   17aug2015
 * 6.1.3    hf      remove inport, not used                       12sep2015
 *           
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *  D E S C R I P T I O N
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *         
 * The s-function calculates the sun_position described by the three sun-angles zenit-angle,
 * azimuth-angle and the angle between collector normal and the sun. The calculation is 
 * carried out based on the formulas of Duffie, 2006. 
 * Inputs:  - none
 * Outputs: 1 solar zenith angle in degrees
 *          2 solar azimut angle in degrees
 */

/*
 * You must specify the S_FUNCTION_NAME as the name of your S-function.
 */

#define S_FUNCTION_NAME sunpos
#define S_FUNCTION_LEVEL 2

#include <stdio.h>
#include <math.h>
// #include "tmwtypes.h" // already included in carlib.h
// #include "simstruc.h" // already included in carlib.h
#include "carlib.h"

/*
 * parameters ==========================================
 */

#define LONGI    (*mxGetPr(ssGetSFcnParam(S, 0)))  /* geographical longitude in degrees (east negative) */
#define LATI     (*mxGetPr(ssGetSFcnParam(S, 1)))  /* geographical latitude in degrees (north positive) */
#define TIMEZONE (*mxGetPr(ssGetSFcnParam(S, 2)))  /* geographical longitude of timezone in degrees (east negative) */

#define TIME     ssGetT(S)

#define DWORK_OLDAZI_NR             0
#define DWORK_OLDZEN_NR             1
#define DWORK_OLDTLT_NR             2
#define OLDAZI                      dwork_oldazi[0]
#define OLDZEN                      dwork_oldzen[0]
#define OLDTLT                      dwork_oldtlt[0]


/*
 * Function: mdlInitializeSizes ===============================================
 */
static void mdlInitializeSizes(SimStruct *S)
{
    ssSetNumSFcnParams(S, 3);  /* Number of expected parameters */
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S))
    {
        /* Return if number of expected != number of actual parameters */
        return;
    }

    ssSetNumContStates(    S, 0);   /* number of continuous states           */
    ssSetNumDiscStates(    S, 0);   /* number of discrete states             */
    
    if (!ssSetNumInputPorts(S, 0))   /* number of inputs    */
    {
        return;
    }

    if (!ssSetNumOutputPorts(S, 1))      /* number of outputs   */
    {
        return;
    }
    ssSetOutputPortWidth(S, 0, 2);
    
    ssSetNumSampleTimes(   S, 1);   /* number of sample times                */
    
    ssSetNumRWork(S, 0); /* number of real work vector elements   */
    ssSetNumIWork(S, 0); /* number of integer work vector elements*/
    ssSetNumPWork(S, 0); /* number of pointer work vector elements*/
    ssSetNumDWork(S, 3);
    ssSetDWorkWidth(S, 0, 1);
    ssSetDWorkDataType(S, 0, SS_DOUBLE);
    ssSetDWorkName(S, 0, "DWORK_OLDAZI");
    ssSetDWorkUsageType(S, 0, SS_DWORK_USED_AS_DSTATE);
    ssSetDWorkWidth(S, 1, 1);
    ssSetDWorkDataType(S, 1, SS_DOUBLE);
    ssSetDWorkName(S, 1, "DWORK_OLDZEN");
    ssSetDWorkUsageType(S, 1, SS_DWORK_USED_AS_DSTATE);
    ssSetDWorkWidth(S, 2, 1);
    ssSetDWorkDataType(S, 2, SS_DOUBLE);
    ssSetDWorkName(S, 2, "DWORK_OLDTLT");
    ssSetDWorkUsageType(S, 2, SS_DWORK_USED_AS_DSTATE);
    
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
}



#define MDL_INITIALIZE_CONDITIONS
/* Function: mdlInitializeConditions ==========================================
 * Abstract:
 *
 * In this function, you should initialize the continuous and discrete
 * states for your S-function block.  The initial states are placed
 * in the x0 variable.  You can also perform any other initialization
 * activities that your S-function may require.
 */
static void mdlInitializeConditions(SimStruct *S)
{
    real_T *dwork_oldazi     = (real_T *)ssGetDWork(S, DWORK_OLDAZI_NR);
    real_T *dwork_oldzen     = (real_T *)ssGetDWork(S, DWORK_OLDZEN_NR);
    real_T *dwork_oldtlt     = (real_T *)ssGetDWork(S, DWORK_OLDTLT_NR);
    
    OLDAZI = 0.0;
    OLDZEN = 0.0;
    OLDTLT = 0.0;
}

/* Function: mdlUpdate  =============================================
 * Abstract:
 *
 * This function is called once for every major integration time step.
 * Discrete states are typically updated here, but this function is useful
 * for performing any tasks that should only take place once per integration
 * step.
 */
#undef MDL_UPDATE  /* Change to #undef to remove function */
static void mdlUpdate(SimStruct *S, int_T tid)
{
//     real_T *dwork_oldazi     = (real_T *)ssGetDWork(S, DWORK_OLDAZI_NR);
//     real_T *dwork_oldzen     = (real_T *)ssGetDWork(S, DWORK_OLDZEN_NR);
//     real_T *y                = ssGetOutputPortSignal(S, 0);
}



/* Function: mdlOutputs =======================================================
 * Abstract:
 *
 * In this function, you compute the outputs of your S-function
 * block. The outputs are placed in the y variable.
 */
static void mdlOutputs(SimStruct *S, int_T tid)
{
    real_T *dwork_oldazi     = (real_T *)ssGetDWork(S, DWORK_OLDAZI_NR);
    real_T *dwork_oldzen     = (real_T *)ssGetDWork(S, DWORK_OLDZEN_NR);
    real_T *dwork_oldtlt     = (real_T *)ssGetDWork(S, DWORK_OLDTLT_NR);
    InputRealPtrsType u      = ssGetInputPortSignal(S, 0);
    real_T *y                = ssGetOutputPortSignal(S, 0);

    real_T delta, woz, hourangle, sunrise, zzauf, riseazi, zen, azi, lat;
    real_T solpos[5];
    
    real_T time = TIME;
    real_T latitude  = LATI;
    real_T longitude = LONGI;
    real_T longitudenull = TIMEZONE;

    lat = DEG2RAD*latitude;
    
    /* calculate solar position in the carlib function    */
    solar_position(solpos, time, latitude, longitude, longitudenull);
    zen = RAD2DEG*solpos[0];        /* zenith angle */
    azi = RAD2DEG*solpos[1];        /* azimut angle */
    delta = solpos[2];              /* declination */
    hourangle = solpos[3];          /* solar hour angle */
    woz = solpos[4];                /* true local time */
    
    /* set outputs */
    y[0] = zen;
    y[1] = azi;

    if ((90.0-OLDZEN)*(90.0-zen) < 0.0         /* sunset or sunrise in timestep */
        && ssGetTStart(S) < time)              /* and time is not starttime */
    {   /* sunset or sunrise */
        /* hour angle at sunrise */
        sunrise = -RAD2DEG*acos(-tan(delta)*tan(lat));

        /* true local time in seconds at sunrise or sunset */
        if (hourangle < 0.0)
            zzauf = 43200.0 + sunrise*240.0;
        else
            zzauf = 43200.0 - sunrise*240.0;

        /* interpolate zenith angle, result is 90° at sunsettime */
        y[0] = OLDZEN - (OLDZEN-90.0)/(zzauf-OLDTLT)*(woz-OLDTLT);

        riseazi = RAD2DEG * acos(-sin(delta)/cos(lat));
        riseazi = (hourangle < 0.0)? -riseazi : riseazi; /* same sign as hourangle */

        /* interpolate azimuth angle, result is sunrise-azimuth at sunrisetime */
        y[1] = OLDAZI - (OLDAZI-riseazi)/(zzauf-OLDTLT)*(woz-OLDTLT);
        /* printf("  time %f  azi %f  OLDAZI %f  y1 %f  riseazi %f woz %f zzauf %f OLDTLT %f \n", 
            time, azi, OLDAZI, y[1], riseazi, woz, zzauf, OLDTLT); */
    }

    /* keep angles for next call */
    OLDZEN = zen;
    OLDAZI = azi; 
    OLDTLT = woz;
} /* end mdlOutputs */



/* Function: mdlTerminate  =============================================
 * Abstract:
 *
 * In this function, you should perform any actions that are necessary
 * at the termination of a simulation.  For example, if memory was allocated
 * in mdlInitializeConditions, this is the place to free it.
 */
static void mdlTerminate(SimStruct *S)
{
}


/* ============================================= *
 * Required S-function trailer *
 * ============================================= */

#ifdef	MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"       /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"        /* Code generation registration function */
#endif

