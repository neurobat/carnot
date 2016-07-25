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
 * This s-function calculates the angles of a tracked collector
 *
 *     Syntax  [sys, x0] = tracking(t,x,u,flag,x(1),x(2),x(3),x0)
 *
 * Version  Author          Changes                                 Date
 * 0.8.0    Bernd Hafner    created                               29jun98
 * 0.11.0   hf              extension to other tracking modes     29jan99
 * 3.1.0	hf				correct angles immediately at start	  22dec2008
 *							sunset for zenith angles >= 90
 * 6.0.0    Arnold Wohlfeil changed to level 2 S-function         10aug2015
 *                          Simstate compiliance
 *                          RWork replaced by DWork
 *                          MultipleExecInstanes enabled
 * 6.0.1    Arnold Wohlfeil #define MDL_INITIALIZE_CONDITIONS     17aug2015
 *                          added
 * 6.0.2    Arnold Wohlfeil comaprison for equality for doubles   10sep2015
 *                          changed,
 *                          empty function mdlDerivatives and
 *                          mdlUpdate deleted
 *
 * Copyright (c) 1998 Solar-Institut Juelich, Germany
 *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *  D E S C R I P T I O N
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * structure of the input vector
 * index    use                                             units
 * 0        ZENITH angle of sun (at time, not averaged)      degree
 * 1        azimut angle of sun (0°=south, east negative)   degree
 * 2        direct solar radiation on horizontal            W/m^2
 * 3        diffuse solar radiation on horizontal           W/m^2
 * 4        inclination of the surface (0° = horizontal)    degree
 * 5        azimut of the surface (0°=south, east negativ)  degree
 *
 *
 * structure of the output vector
 * index    use                                             units
 * 0        collector inclination angle                     degree
 * 1        collector azimut angle                          degree
 * 2        collector rotation angle                        degree
 *
 *
 * parameters
 * index    use                                             units
 * 0        tracking type
 *              1 = turning around collector riser
 *              2 = turning around vertical axis
 * 1        tracking time                                   s
 */


#define S_FUNCTION_NAME tracking
#define S_FUNCTION_LEVEL 2

/*
 * Need to include simstruc.h for the definition of the SimStruct and
 * its associated macro definitions.
 */
#include "tmwtypes.h"
#include "simstruc.h"
#include "carlib.h"
#include <math.h>

#define ZENITH      (*u[0])
#define AZIMUT      (*u[1])

/* TRACKTYPE    descritption 
 *  1           tracking axis is collector riser
 *  2           not yet used
 */

#define TRACKTYPE    (*mxGetPr(ssGetSFcnParam(S,0))) /* type of tracking */
#define TRACKTIME    (*mxGetPr(ssGetSFcnParam(S,1))) /* time of tracking */
#define AXISANGLE    (*mxGetPr(ssGetSFcnParam(S,2))) /* inclination of surface or axis */
#define AXISAZIMUT   (*mxGetPr(ssGetSFcnParam(S,3))) /* azimuth of surface or axis */
#define ROTATION     (*mxGetPr(ssGetSFcnParam(S,4))) /* rotation of surface */
#define NPARAM                           5

#define DWORK_OLDTRACKTIME_NR       0
#define DWORK_ANGLE1_NR             1
#define DWORK_ANGLE2_NR             2
#define DWORK_ANGLE3_NR             3
#define OLDTRACKTIME                dwork_oldtracktime[0]
#define ANGLE1                      dwork_angle1[0]
#define ANGLE2                      dwork_angle2[0]
#define ANGLE3                      dwork_angle3[0]

#define TIME            ssGetT(S)

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
    ssSetNumSFcnParams(S, NPARAM);  /* Number of expected parameters */
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S))
    {
        /* Return if number of expected != number of actual parameters */
        return;
    }
    ssSetNumContStates(    S, 0);   /* number of continuous states           */
    ssSetNumDiscStates(    S, 0);   /* number of discrete states             */
    
    if (!ssSetNumInputPorts(S, 1))   /* number of inputs    */
    {
        return;
    }
	ssSetInputPortWidth(S, 0, 2);
    ssSetInputPortDirectFeedThrough(S, 0, 1); /* direct feedthrough flag */
    
    if (!ssSetNumOutputPorts(S, 1))      /* number of outputs   */
    {
        return;
    }
    ssSetOutputPortWidth(S, 0, 3);
    
    ssSetNumSampleTimes(   S, 1);   /* number of sample times                */
    ssSetNumRWork(         S, 0);   /* number of real work vector elements   */
    ssSetNumIWork(         S, 0);   /* number of integer work vector elements*/
    ssSetNumPWork(         S, 0);   /* number of pointer work vector elements*/
    
    ssSetNumDWork(S, 4);
    ssSetDWorkWidth(S, 0, 1);
    ssSetDWorkDataType(S, 0, SS_DOUBLE);
    ssSetDWorkName(S, 0, "D_OLDTRACKTIME");
    ssSetDWorkUsageType(S, 0, SS_DWORK_USED_AS_DSTATE);
    ssSetDWorkWidth(S, 1, 1);
    ssSetDWorkDataType(S, 1, SS_DOUBLE);
    ssSetDWorkName(S, 1, "D_ANGLE1");
    ssSetDWorkUsageType(S, 1, SS_DWORK_USED_AS_DSTATE);
    ssSetDWorkWidth(S, 2, 1);
    ssSetDWorkDataType(S, 2, SS_DOUBLE);
    ssSetDWorkName(S, 2, "D_ANGLE2");
    ssSetDWorkUsageType(S, 2, SS_DWORK_USED_AS_DSTATE);
    ssSetDWorkWidth(S, 3, 1);
    ssSetDWorkDataType(S, 3, SS_DOUBLE);
    ssSetDWorkName(S, 3, "D_ANGLE3");
    ssSetDWorkUsageType(S, 3, SS_DWORK_USED_AS_DSTATE);
    
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
    ssSetSampleTime(S, 0, TRACKTIME);
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
    real_T *dwork_oldtracktime     = (real_T *)ssGetDWork(S, DWORK_OLDTRACKTIME_NR);
    real_T *dwork_angle1           = (real_T *)ssGetDWork(S, DWORK_ANGLE1_NR);
    real_T *dwork_angle2           = (real_T *)ssGetDWork(S, DWORK_ANGLE2_NR);
    real_T *dwork_angle3           = (real_T *)ssGetDWork(S, DWORK_ANGLE3_NR);

	OLDTRACKTIME = ssGetTStart(S) - 2.0*TRACKTIME;	/* last tracking was done before starttime -> first tracking at start */
    ANGLE1 = AXISANGLE;								/* set collector angles from parameters */
    ANGLE2 = AXISAZIMUT;
    ANGLE3 = ROTATION;
}



/* Function: mdlOutputs =======================================================
 * Abstract:
 *
 * In this function, you compute the outputs of your S-function
 * block. The outputs are placed in the y variable.
 */
static void mdlOutputs(SimStruct *S, int_T tid)
{
    InputRealPtrsType u=ssGetInputPortSignal(S, 0);
    real_T *y=ssGetOutputPortSignal(S, 0);
    
    int    tracktype  = (int)(TRACKTYPE+0.5);
    real_T axisangle  = AXISANGLE;
    real_T axisazimut = AXISAZIMUT;
    real_T rotation   = ROTATION;
    real_T tracktime  = TRACKTIME ;
                        
    real_T *dwork_oldtracktime     = (real_T *)ssGetDWork(S, DWORK_OLDTRACKTIME_NR);
    real_T *dwork_angle1           = (real_T *)ssGetDWork(S, DWORK_ANGLE1_NR);
    real_T *dwork_angle2           = (real_T *)ssGetDWork(S, DWORK_ANGLE2_NR);
    real_T *dwork_angle3           = (real_T *)ssGetDWork(S, DWORK_ANGLE3_NR);
    real_T time = TIME;

    double as, zs, rc, zc, ac, costeta, szc, czs, szs, czc, tetatrans,
        src, crc, sda, cda;

    if(ZENITH <= -9998.0 || AZIMUT <= -9998.0) /* value is -9999.0, but check for equality with doubles is problematic */
    {
        ssSetErrorStatus(S,"Weather data does not include sunposition. "
            "Use block carnot/weather/set_sun_position.\n");
        return;
    }

    if (ZENITH >= 90.0) /* no sun when zenith angle is 90 or more*/
    {
        ANGLE1 = axisangle;
        ANGLE2 = axisazimut;
        ANGLE3 = rotation;
    }
    else
    {									/* sun is there, zenith angle below 90 */
        if (OLDTRACKTIME+tracktime < time) 
		{										/* start stracking */
            OLDTRACKTIME = time;				/* keep time for next tracking */
			
			ANGLE1 = axisangle;					/* all angles from the parameters */
			ANGLE2 = axisazimut;				/* overwriting them with the tracked values later */
			ANGLE3 = rotation;

            switch (tracktype)
            {
                case 1:							/* tracking axis is collector riser = axis of collector rotation */
                    zs = DEG2RAD * ZENITH;
                    as = DEG2RAD * AZIMUT;
                    zc = DEG2RAD * axisangle;
                    ac = DEG2RAD * axisazimut;
                    rc = DEG2RAD * rotation;
                    
                    sda = sin(ac-as);		/* sine of difference of azimuth */
                    cda = cos(ac-as);		/* cosine of difference of azimuth */
                    szs = sin(zs);			/* sine zenith angle of sun */
                    czs = cos(zs);			/* cosine zenith angle of sun */
                    szc = sin(zc);			/* sine zenith angle of collector (inclination) */
                    czc = cos(zc);			/* cosine zenith angle of collector (inclination) */
                    src = sin(rc);			/* sine rotation angle of collector */
                    crc = cos(rc);			/* cosine rotation angle of collector */
                    
                    /* cos of incidence angle on surface */
                    costeta = src*sda*szs+crc*(szc*cda*szs+czc*czs);

                    /* incidence angle in transversal collector plane (direction header - vertical on collector plane) */
                    tetatrans = acos(costeta/sqrt(square(crc*sda*szs
                        -src*(szc*cda*szs+czc*czs))+square(costeta)));
                    tetatrans = min(RAD2DEG*tetatrans,90.0);
                    tetatrans = (as < 0.0)? -tetatrans : tetatrans;	/* negative in the morning */
                    ANGLE3 = tetatrans;								/* collector rotation is transversal incidence on plane */
                    break;
                case 2:							/* turn around vertical axis */
					ANGLE2 = AZIMUT;			/* collector azimut is sun azimut */
                    break;
                case 3:							/* turn around vertical and horizontal axis */
                    ANGLE1 = ZENITH;			/* collector inclination is sun zenith angle */
                    ANGLE2 = AZIMUT;			/* collector azimut is sun azimut */
                    break;
				case 4: default:				/* no tracking, fixed surface */
                    /* nothing to do, angles already set */
					break;
            } /* end switch */
        } /* endif tracktime */
    }/* end if ZENTIH, check for sunset */

    y[0] = ANGLE1; /* inclination */
    y[1] = ANGLE2; /* azimuth */
    y[2] = ANGLE3; /* rotation */
}





/* Function: mdlTerminate =====================================================
 * Abstract:
 *
 * In this function, you should perform any actions that are necessary
 * at the termination of a simulation.  For example, if memory was allocated
 * in mdlInitializeConditions, this is the place to free it.
 */
static void mdlTerminate(SimStruct *S)
{
    /*
     * YOUR CODE GOES HERE
     */
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
