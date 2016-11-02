/***********************************************************************
 *  M O D E L    O R    F U N C T I O N
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * Thermal comfort according to ISO 7730
 *
 * Author list
 *  Arnold Wohlfeil -> aw
 *
 * Version  Author  Changes                                     Date
 * 0.9.0    aw      created                                     19jul2016
 *
 ***********************************************************************
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
 
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *  D E S C R I P T I O N
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * 
 *
 * Literature: 
 * DIN EN ISO 7730:2005
 */

#define S_FUNCTION_NAME     comfortsfcn
#define S_FUNCTION_LEVEL    2

#include <stdio.h>
#include <math.h>
#include <float.h>
#include "carlib.h"
#include "simstruc.h"


/* definitionof the inputs */
#define M           (*u0[0])    /* metabolic rate [W/m²]; 1 met = 58.2 W/m² */
#define W           (*u1[0])    /* effective mechanical power [W/m²] */
#define I_CL        (*u2[0])    /* clothing isolation [m²/kW]; 1 clo = 0.155 W/m² */
#define T_A         (*u3[0])    /* air temperature [°C] */
#define T_R         (*u4[0])    /* mean radiant temperature [°C] */
#define V_AR        (*u5[0])    /* relative air velocity [m/s] */
#define P_A         (*u6[0])    /* partial pressure of water [Pa] */

/* definition of the outputs */
#define PMV         (y0[0]) 	/* PMV  - predicted mean vote [-] */
#define PPD         (y1[0]) 	/* PPD  - predicted percentage of dissatisfied [%] */
#define T_CL        (y2[0]) 	/* t_cl - clothing surface temperature [°C] */
#define F_CL        (y3[0]) 	/* f_cl - clothing surface area factor [1] */
#define H_C         (y4[0]) 	/* h_c  - convective heat transfer coefficient [W/m²K] */


#define MESSAGELEVELBLOCK           (int)(*mxGetPr(ssGetSFcnParam(S,0))) /* error level of the block */
#define NOTOTALWARNINGS             (*mxGetPr(ssGetSFcnParam(S,1))) /* total number of warnings [1] */
#define NOCONSECUTIVEWARNINGS       (*mxGetPr(ssGetSFcnParam(S,2))) /* consecutive number of warnings [1] */
#define WRITETOFILE                 (int)(*mxGetPr(ssGetSFcnParam(S,3))) /* write to file */
#define FILENAME                    (*mxGetPr(ssGetSFcnParam(S,4))) /* filename */


#define DWORK_FILENAME                    (char*)ssGetDWork(S, 0) /* filename */
#define DWORK_ORIGIN                      (char*)ssGetDWork(S, 1) /* name of the current file */
#define DWORK_PRINTEDTOTALMESSAGES        (uint32_T*)ssGetDWork(S, 2) /* number of total printed warnings */
#define DWORK_PRINTEDCONSECUTIVEMESSAGES  (uint32_T*)ssGetDWork(S, 3) /* number of consecutive printed warnings */



#define MDL_CHECK_PARAMETERS
#if defined(MDL_CHECK_PARAMETERS) && defined(MATLAB_MEX_FILE)
  /* Function: mdlCheckParameters =============================================
   * Abstract:
   *    Validate our parameters to verify they are okay.
   */
static void mdlCheckParameters(SimStruct *S)
{
	
    
	/*
    if (bla)
	{
        ssSetErrorStatus(S,"Something");
        return;
    }
	*/
	

}
#endif /* MDL_CHECK_PARAMETERS */
 

/* Function: mdlInitializeSizes ===============================================
 * Abstract:
 *   Setup sizes of the various vectors.
 */
static void mdlInitializeSizes(SimStruct *S)
{
    ssSetNumSFcnParams(S, 5);
#if defined(MATLAB_MEX_FILE)
    if (ssGetNumSFcnParams(S) == ssGetSFcnParamsCount(S))
	{
        mdlCheckParameters(S);
        if (ssGetErrorStatus(S) != NULL)
		{
            return;
        }
    }
	else
	{
        return; /* Parameter mismatch will be reported by Simulink */
    }
#endif

    ssSetNumContStates(S, 0);  /* number of continuous states */
    ssSetNumDiscStates(S, 0);  /* number of discrete states */

    if (!ssSetNumInputPorts(S, 7))
	{
		return;
	}
    ssSetInputPortWidth(S, 0, 1);
    ssSetInputPortDirectFeedThrough(S, 0, 1);
    ssSetInputPortWidth(S, 1, 1);
    ssSetInputPortDirectFeedThrough(S, 1, 1);
    ssSetInputPortWidth(S, 2, 1);
    ssSetInputPortDirectFeedThrough(S, 2, 1);
    ssSetInputPortWidth(S, 3, 1);
    ssSetInputPortDirectFeedThrough(S, 3, 1);
    ssSetInputPortWidth(S, 4, 1);
    ssSetInputPortDirectFeedThrough(S, 4, 1);
    ssSetInputPortWidth(S, 5, 1);
    ssSetInputPortDirectFeedThrough(S, 5, 1);
    ssSetInputPortWidth(S, 6, 1);
    ssSetInputPortDirectFeedThrough(S, 6, 1);

    if (!ssSetNumOutputPorts(S, 5))
	{
		return;
	}
    ssSetOutputPortWidth(S, 0, 1);
    ssSetOutputPortWidth(S, 1, 1);
	ssSetOutputPortWidth(S, 2, 1);
	ssSetOutputPortWidth(S, 3, 1);
	ssSetOutputPortWidth(S, 4, 1);

    ssSetNumSampleTimes(S, 1);

    ssSetNumIWork(S, 0);
	ssSetNumRWork(S, 0);
    ssSetNumPWork(S, 0);
    ssSetNumModes(S, 0);
    ssSetNumNonsampledZCs(S, 0);
    
    ssSetNumDWork(S, 4);
    ssSetDWorkWidth(S, 0, (int)mxGetN((ssGetSFcnParam(S, 4)))*sizeof(mxChar) + 1*sizeof(mxChar));
    ssSetDWorkDataType(S, 0, SS_UINT8);
    ssSetDWorkName(S, 0, "DWORK_FILENAME");
    ssSetDWorkUsageType(S, 0, SS_DWORK_USED_AS_DSTATE);
    ssSetDWorkWidth(S, 1, (int)(strlen(ssGetPath(S)) + strlen(ssGetModelName(S)) + 4)*sizeof(mxChar));
    ssSetDWorkName(S, 1, "DWORK_ORIGIN");
    ssSetDWorkUsageType(S, 1, SS_DWORK_USED_AS_DSTATE);
    ssSetDWorkDataType(S, 1, SS_UINT8);
    ssSetDWorkWidth(S, 2, 1);
    ssSetDWorkName(S, 2, "DWORK_TOTAL");
    ssSetDWorkUsageType(S, 2, SS_DWORK_USED_AS_DSTATE);
    ssSetDWorkDataType(S, 2, SS_UINT32);
    ssSetDWorkWidth(S, 3, 1);
    ssSetDWorkDataType(S, 3, SS_UINT32);
    ssSetDWorkName(S, 3, "DWORK_CON");
    ssSetDWorkUsageType(S, 3, SS_DWORK_USED_AS_DSTATE);
	
	
    /* Take care when specifying exception free code - see sfuntmpl.doc */
    /* ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE); */
	
	ssSetSimStateCompliance(S, USE_DEFAULT_SIM_STATE);
    ssSetSimStateVisibility(S, 1);
    ssSupportsMultipleExecInstances(S, true);
}


/* Function: mdlInitializeSampleTimes =========================================
 * Abstract:
 *    Specifiy that we inherit our sample time from the driving block.
 */
static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, CONTINUOUS_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, 0.0);
}


#define MDL_INITIALIZE_CONDITIONS
/* Function: mdlInitializeConditions ========================================
 * Abstract:
 *    Initialize both states to one
 */

static void mdlInitializeConditions(SimStruct *S)
{
    uint32_T *D2 = DWORK_PRINTEDTOTALMESSAGES;
    uint32_T *D3 = DWORK_PRINTEDCONSECUTIVEMESSAGES;
    
    mxGetString((ssGetSFcnParam(S, 4)), DWORK_FILENAME, (int)(mxGetN(ssGetSFcnParam(S, 4))+1)*sizeof(mxChar)); 
    
    sprintf(DWORK_ORIGIN, "%s/%s.c",ssGetPath(S), ssGetModelName(S));

    D2[0] = (uint32_T)0;
    D3[0] = (uint32_T)0;
}



static double calculate_f_cl(double i_cl)
/* calculation of the clothing area factor - equation (4) of DIN EN ISO 7730:2005 */
{
	double f_cl;
	
	if (i_cl<=0.078)
	{
		f_cl = 1.00+1.290*i_cl;
	}
	else
	{
		f_cl = 1.05+0.645*i_cl;
	}
	
	return(f_cl);
}

static double calculate_h_c(double v_ar, double t_cl, double t_a)
/* calculation of the heat transfer coefficient - equation (3) of DIN EN ISO 7730:2005 */
{
	double h_c_1, h_c_2;
	double h_c;
	
	h_c_1 = 2.38*sqrt(sqrt(fabs(t_cl-t_a)));
	h_c_2 = 12.1*sqrt(v_ar);
	
	if (h_c_1 > h_c_2)
	{
		h_c = h_c_1;
	}
	else
	{
		h_c = h_c_2;
	}
	
	return(h_c);
}


static int sign(double x)
/* signum function
 * returns  0 for x==0.0,
 * returns -1 for x<0.0,
 * returns +1 for x>0.0
 */
{
	if (fabs(x)<DBL_EPSILON)
	{
		return(0);
	}
	else
	{
		if (x < 0.0)
		{
			return(-1);
		}
		else
		{
			return(1);
		}
	}
}


static double calculate_t_cl_tf(double m, double w, double i_cl, double f_cl, double h_c, double v_ar, double t_a, double t_r, double t_cl)
/* target function
 * surface temperature of the clothing - equation (2) of DIN EN ISO 7730:2005
 * minus t_cl in order to get a value of zero
 */
{
	double result;
	double aux1, aux2;
	
	aux1 = 3.96e-8 * f_cl * (pow(t_cl+273.0, 4.0) - pow(t_r+273.0, 4.0));
	aux2 = f_cl * h_c * (t_cl-t_a);
	result = 35.7 - 0.028*(m-w) - i_cl*(aux1 + aux2) - t_cl;
	
	return(result);
}


static double calculate_t_cl(SimStruct *S, double m, double w, double i_cl, double t_a, double t_r, double v_ar)
/* calculates the surface temperature of the clothes by the regula falsi method */
{
    double t_cl, t_cl1, t_cl2; /* valvues of t_cl */
	double delta;
	double step = 1.0; /* step size to search for values [°C] */
	double f_cl, h_c;
	double tf, tf1, tf2; /* value of the target function */
	double epsilon = 1e-6;
    int count;
	int maxcount = 1000000;
    char message[500];
    int_T messageset = MESSAGEPRINTNONE;
    
	
	f_cl = calculate_f_cl(i_cl); /* the clothing area factor is constant during the calculation */
	
	/* step 1:
	 * find starting values: one >0, one <0
	 * in the end tf(t_cl1)<0 and tf(t_cl2)>0
	*/
	delta = 0.0;
	t_cl = (t_a + t_r)/2.0; /* first guess: mean value of air and radiation temperature */
	h_c = calculate_h_c(v_ar, t_cl, t_a);
	tf = calculate_t_cl_tf(m, w, i_cl, f_cl, h_c, v_ar, t_a, t_r, t_cl);
	
	if(fabs(tf)<DBL_EPSILON)
	{  /* exact value found by chance */
		return(t_cl);
	}
	
	/*
	 * set t_cl1 and t_cl2 to t_cl as starting point
	 * and set tf1 and tf2 to tf
	 */
	t_cl1 = t_cl;
	t_cl2 = t_cl;
	tf1 = tf;
	tf2 = tf;
	
	/* aim:
	 * find a value of t_cl1, so that tf(t_cl1)<0 and
	 * find a value of t_cl2, so that tf(t_cl2)>0
	 * look around the start value +/- delta
	 * delta is increased each loop run by the value of step
	 *
	 * It is checked if the sign of tf1=tf(t_cl1) or tf2=tf(t_cl2)
	 * differ from tf=tf(t_cl).
	 * If this is true, the regula falsi can start
	 */
    count = 0;
	do
	{
		delta = delta + step;
        count++;
		
		/* check t_cl + delta */
		h_c = calculate_h_c(v_ar, t_cl+delta, t_a);
		tf = calculate_t_cl_tf(m, w, i_cl, f_cl, h_c, v_ar, t_a, t_r, t_cl+delta);
		
		if(fabs(tf)<DBL_EPSILON)
		{ /* exact value found by chance */
			return(t_cl+delta);
		}

		if(sign(tf1) != sign(tf))
		{ /* match */
			if(tf<0.0)
			{
				tf1=tf;
				t_cl1=t_cl+delta;
			}
			else
			{
				tf2=tf;
				t_cl2=t_cl+delta;
			}
			break;
		}
		
		/* check t_cl - delta */
		h_c = calculate_h_c(v_ar, t_cl-delta, t_a);
		tf = calculate_t_cl_tf(m, w, i_cl, f_cl, h_c, v_ar, t_a, t_r, t_cl-delta);

		if(fabs(tf)<DBL_EPSILON)
		{ /* exact value found by chance */
			return(t_cl-delta);
		}
		
		if(sign(tf1) != sign(tf))
		{ /* match */
			if(tf<0.0)
			{
				tf1=tf;
				t_cl1=t_cl-delta;
			}
			else
			{
				tf2=tf;
				t_cl2=t_cl-delta;
			}
			break;
		}
		
		
	}	
	while( (sign(tf1)==sign(tf2))&&(count<=maxcount) );
    
    if (count>maxcount)
    {
         sprintf(message,"Error: Could not find starting value to iterate clothing surface temeprature! Temperatuer set to 20 °C.\n");
    	 messageset = printmessage(message, DWORK_ORIGIN, ssGetT(S), MESSAGELEVELERROR, MESSAGELEVELBLOCK, DWORK_PRINTEDTOTALMESSAGES, NOTOTALWARNINGS, DWORK_PRINTEDCONSECUTIVEMESSAGES, NOCONSECUTIVEWARNINGS, WRITETOFILE, DWORK_FILENAME);
         return(20.0);
    }
	
	
	/* now start the regula falsi between t_cl1 and t_cl2 */
	count = 0;
	do
	{
		count++;
		
		/* calculate new t_cl and new tf=tf(t_cl) */
		t_cl = (t_cl1) - tf1*(t_cl2-t_cl1)/(tf2-tf1); /* new t_cl */
		h_c = calculate_h_c(v_ar, t_cl, t_a);
		tf = calculate_t_cl_tf(m, w, i_cl, f_cl, h_c, v_ar, t_a, t_r, t_cl);
		
		/* set new value left or right side */
		if(tf<0.0)
		{
			tf1=tf;
			t_cl1=t_cl;
		}
		else
		{
			tf2=tf;
			t_cl2=t_cl;
		}
	}
	while( (fabs(t_cl1-t_cl2)<epsilon) && (count <= maxcount) );
    
    if (count>maxcount)
    {
        t_cl = (t_cl1 + t_cl2)/2.0;
    	sprintf(message,"Warning: Clothing surface temperature did not converge between %f °C and %f °C, set to %f.\n", t_cl1, t_cl2, t_cl);
    	messageset = printmessage(message, DWORK_ORIGIN, ssGetT(S), MESSAGELEVELWARNING, MESSAGELEVELBLOCK, DWORK_PRINTEDTOTALMESSAGES, NOTOTALWARNINGS, DWORK_PRINTEDCONSECUTIVEMESSAGES, NOCONSECUTIVEWARNINGS, WRITETOFILE, DWORK_FILENAME);
        return(t_cl);
    }
    
    if (messageset==MESSAGEPRINTNONE)
    {
        uint32_T *D = DWORK_PRINTEDCONSECUTIVEMESSAGES;
        D[0] = (uint32_T)0;
    }

	/* return the better value (i.e. where tf is nearer zero) */
	if (-tf1>tf2) /* tf1 is always < 0, tf2 is alwways > 0 */
	{
		return(t_cl2);
	}
	else
	{
		return(t_cl1);
	}
}


static double calculate_pmv(double m, double w, double f_cl, double h_c, double p_a, double t_a, double t_r, double t_cl)
/* calculation of pmv - equation (1) in DIN EN ISO 7730:2005 */
{
	double aux1, aux2, aux3, aux4;
	double pmv;

	aux1 = (m-w)-3.05e-3*(5733.0-6.99*(m-w)-p_a)-0.42*((m-w)-58.15);
	aux2 = -1.7e-5*m*(5867.0-p_a)-0.0014*m*(34.0-t_a);
	aux3 = -3.96e-8*f_cl*(pow(t_cl+273.0,4.0)-pow(t_r+273.0,4.0)) - f_cl*h_c*(t_cl-t_a);
	aux4 = 0.303*exp(-0.036*m) + 0.028;
	
	pmv = aux4 * (aux1 + aux2 + aux3);
	return(pmv);
}



/* Function: mdlOutputs =======================================================
 */
static void mdlOutputs(SimStruct *S, int_T tid)
{
    InputRealPtrsType u0    = ssGetInputPortRealSignalPtrs(S, 0);
    InputRealPtrsType u1    = ssGetInputPortRealSignalPtrs(S, 1);
    InputRealPtrsType u2    = ssGetInputPortRealSignalPtrs(S, 2);
    InputRealPtrsType u3    = ssGetInputPortRealSignalPtrs(S, 3);
    InputRealPtrsType u4    = ssGetInputPortRealSignalPtrs(S, 4);
    InputRealPtrsType u5    = ssGetInputPortRealSignalPtrs(S, 5);
    InputRealPtrsType u6    = ssGetInputPortRealSignalPtrs(S, 6);
    
    real_T   *y0   = ssGetOutputPortRealSignal(S, 0);
    real_T   *y1   = ssGetOutputPortRealSignal(S, 1);
	real_T   *y2   = ssGetOutputPortRealSignal(S, 2);
	real_T   *y3   = ssGetOutputPortRealSignal(S, 3);
	real_T   *y4   = ssGetOutputPortRealSignal(S, 4);
	
	double t_cl, f_cl, h_c, pmv, ppd;

	/* calculate the clothing surface temperatuzre t_cl */
	t_cl = calculate_t_cl(S, M, W, I_CL, T_A, T_R, V_AR);
	T_CL = t_cl;
	
	f_cl = calculate_f_cl(I_CL);
	F_CL = f_cl;
	h_c  = calculate_h_c(V_AR, t_cl, T_A);
	H_C  = h_c;
	
	/* calculate pmv */
	pmv = calculate_pmv(M, W, f_cl, h_c, P_A, T_A, T_R, t_cl);
	PMV = pmv;

	/* calculate ppd - equation (5) in DIN EN ISO 7730:2005 */
	ppd = 100.0-95.0*exp(-0.03353*pow(pmv, 4.0)-0.2179*pow(pmv, 2.0));
	PPD = ppd;
}



/*#define MDL_DERIVATIVES */
/* Function: mdlDerivatives =================================================
 * Abstract:
 *      xdot = Ax + Bu
 */
/*
static void mdlDerivatives(SimStruct *S)
{
}
*/



/* Function: mdlTerminate =====================================================
 * Abstract:
 *    No termination needed, but we are required to have this routine.
 */
static void mdlTerminate(SimStruct *S)
{
}


#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif

