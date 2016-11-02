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
 * Syntax  TSKY = metsky_s(TAMB,HUM,CLOUD)
 *
 * Version  Author      Changes                                 Date
 * 0.01.0   Th. Wenzel  created M-script                        18oct99
 * 0.02.0   tw          created S-function                      25nov99
 * 3.1.0    hf          including Berdahl/Martin cos term       31dec2008
 *
 * Copyright (c) 1999 Solar-Institut Juelich, Germany
 * 
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *  D E S C R I P T I O N
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * function erg=metsky_s(Tamb,hum,Cloud);

   FUNCTION:    Calculates the Sky-Temperature

              Input-Vector

				   1.	Tamb	  :	ambient temperature °C
				   2.	hum		  :	humidity %
                   3.  Cloud     : Cloudness index [0..1]

              Output

				   1.	Tsky			:	sky temperature °C
 
   Modifizierung des M-Skriptes metcalc.m von Markus Werner, Solar-Institut Juelich

   Thomas Wenzel, 25.11.1999
 */


#define S_FUNCTION_LEVEL 2
#define S_FUNCTION_NAME metsky_s

/* 

*/



/*
 * Need to include simstruc.h for the definition of the SimStruct and
 * its associated macro definitions. math.h is for function sqrt
 */
#include "simstruc.h"
#include <math.h>
#include "carlib.h"


/* defines */
#define TIME     ssGetT(S)
#define SECONDSPERDAY 86400.0


/*
 * some defines for access to the parameters
 */
#define TSKYMODELL  *mxGetPr(ssGetSFcnParam(S,  0)) /* modell for the sky temperature */
#define N_PARA                                  1

/*
 * some defines for access to the input vector
 */

#define TAMB           (*u1Ptrs[0])    /* ambient temperature in degree C   */
#define HUM            (*u1Ptrs[1])    /* relative humidity in %            */
#define CLOUD          (*u1Ptrs[2])    /* cloud cover (0, 1/8, 2/8, .., 8/8 */
#define IN_WIDTH                3      /* number of inputs per port */


/*
 * some defines for access to the output vector
 */
#define TSKY       y1[0]    
#define OUT_WIDTH     1     /* number of outputs per port */


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

    if (!ssSetNumOutputPorts(S, 1)) return;
    ssSetOutputPortWidth(S, 0, OUT_WIDTH);

    ssSetNumSampleTimes(S, 1);
    ssSetNumRWork(S, 0);
    ssSetNumIWork(S, 0);
    ssSetNumPWork(S, 0);
    ssSetNumModes(S, 0);
    ssSetNumNonsampledZCs(S, 0);

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



#undef MDL_INITIALIZE_CONDITIONS   /* Change to #undef to remove function */
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
  }
#endif /* MDL_INITIALIZE_CONDITIONS */



#undef MDL_START  /* Change to #undef to remove function */
#if defined(MDL_START) 
  /* Function: mdlStart =======================================================
   * Abstract:
   *    This function is called once at start of model execution. If you
   *    have states that should be initialized once, this is the place
   *    to do it.
   */
  static void mdlStart(SimStruct *S)
  {
  }
#endif /*  MDL_START */



/* Function: mdlOutputs =======================================================
 * Abstract:
 *    In this function, you compute the outputs of your S-function
 *    block. Generally outputs are placed in the output vector, ssGetY(S).
 */
static void mdlOutputs(SimStruct *S, int_T tid)
{
    InputRealPtrsType   u1Ptrs  = ssGetInputPortRealSignalPtrs(S,0);
    real_T              *y1     = ssGetOutputPortRealSignal(S,0);
    const real_T        e       = 0.885191547524961;                /* e = exp(-1000.0/8200.0) */
    const real_T        c1      = 611.0;
    real_T              time    = TIME;

    real_T  sec, hum, Tamb, Tamb4, c2, c3, d , Tdew, ps, pd , temp;
    int days;
     
    /* ------------------------------------------------------------------------------- 
     	"Tdew"			Taupunkttemperatur 
     	"Tsky"			Himmelstemperatur 
    	"CloudIndex"	Bedeckungsgrad, Diskretisierung in Okta [0, 1/8, 2/8, ... ,8/8]
     ------------------------------------------------------------------------------- */
    
    hum = HUM;              /* relative humidity in % */
    Tamb  = TAMB;           /* ambient temperature in degree C */
    Tamb4 = Tamb + TA0;     /* ambient temperature in K */
    Tamb4 *= Tamb4;         /* Tamb^2 */
    Tamb4 *= Tamb4;         /* Tamb^4 */

    TSKY = 0;
    
    /* time of the day in seconds */
    days = ((int)(time/SECONDSPERDAY));         /* determine time in days first */
    sec = time - SECONDSPERDAY*(real_T)days;
    
    if (hum > 0)           /* measurement data for relative humidity are available */
    {
        if (Tamb >= 0.0)    /* if ambient temperature above zero */
        {
            c2 = 17.08;
            c3 = 234.18;
        }
        else
        {
            c2 = 17.84;
            c3 = 245.43;
        }
        
        /* Sättigungsdampfdruck der Luft "ps" in Abh. von der Lufttemperatur "Tamb"*/
        /* (nach VDI 3786 Blatt 4, 1985), mbar:                                    */
        ps = c1 * exp( c2*Tamb/(c3+Tamb) );      
        
        /* Aktueller Dampfdruck der Luft "pd", mbar:                               */
        pd = hum/100. * ps;
        
        /* Taupunkttemperatur "Tdew" (nach VDI 3786 Blatt 4, 1985):                */
        d = log(pd/c1);
        Tdew = c3*d /(c2-d);
        
        
        /* Himmelstemperatur "Tsky" nach BERDAHL, Martin 1984 für tiefe Wolken (1000 m) */
        /* (OHNE cos-Term, s. Feist,1994,S.290ff):                                 */
        temp = 0.711 + 0.0056*Tdew + 7.3e-5*Tdew*Tdew;

        /* cos-Term if needed */
        if (TSKYMODELL > 0.0)
        {
            temp += 0.013*cos(7.272205216643040e-5*sec);    
            /* 360/(24*3600)*pi/180 = 15/3600*pi/180 = 7.272205216643040e-5 */
        }
        
        if ((CLOUD) < 1.0e-4)                            /* no clouds */
            TSKY = pow((Tamb4 * temp),0.25) - TA0;
        else
            TSKY = pow((Tamb4 * ((1-temp)*CLOUD*e + temp)),0.25) - TA0;
    }   
    else /* es liegen KEINE Feuchtewerte vor! -> Himmelstemperatur "Tsky" nach UNSWORTH*/
    {                           
        /* (mit korrigierten Parametern, s. Feist,1994,S.290ff):                  */
        if ((CLOUD) < 1.0e-4)                            /* no clouds */
            TSKY = pow(( -150./STEFAN_BOLTZMANN + 1.2 *Tamb4 ),0.25) - TA0;
        else
            TSKY = pow(( -150./STEFAN_BOLTZMANN * (1.0 - CLOUD*0.9) + 
                 (1.2 - 0.2*CLOUD*0.9)*Tamb4 ),0.25) - TA0;
    }
} /* end mdloutputs */



#undef MDL_UPDATE  /* Change to #undef to remove function */
#if defined(MDL_UPDATE)
  /* Function: mdlUpdate ======================================================
   * Abstract:
   *    This function is called once for every major integration time step.
   *    Discrete states are typically updated here, but this function is useful
   *    for performing any tasks that should only take place once per
   *    integration step.
   */
  static void mdlUpdate(SimStruct *S, int_T tid)
  {
  }
#endif /* MDL_UPDATE */



#undef MDL_DERIVATIVES  /* Change to #undef to remove function */
#if defined(MDL_DERIVATIVES)
  /* Function: mdlDerivatives =================================================
   * Abstract:
   *    In this function, you compute the S-function block's derivatives.
   *    The derivatives are placed in the derivative vector, ssGetdX(S).
   */
  static void mdlDerivatives(SimStruct *S)
  {
  }
#endif /* MDL_DERIVATIVES */



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

