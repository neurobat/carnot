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
 * Syntax  season_temperature
 *
 * Version  Author          Changes                                 Date
 * 0.01.0   Thomas Wenzel   created                                 16feb2000
 * 0.02.0   Gaelle Faure    modified for use with date2sec instead
 *                          of countseconds                         24mar2011
 * 1.00.0   gf              debug                                   28mar2011
 * 6.1.0    hf              removed #define for MIN, MAX, ABS       02jul2014
 *                          as they are defined in the carlib.c
 *                          declaration of d3,t3, deltaT removed
 * 6.1.1    hf              comment out cutils.h                    21feb2015
 * 6.1.2	aw				Simstate compiliance and				24jul2015
 *							multiple instances activated
 *							IWork adn RWork replaced by DWork
 * 6.1.3    hf              remove inport, not needed               12sep2015
 *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *  D E S C R I P T I O N
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * This functions varies a temperature during a year.
 * The temperature is distributed in sinus form or linear.
 * Two monthes and two temperatures have to be specified,
 * e.g. as coldes month february with 6°C and 
 *      as hottest month august with 14°C
 * 
 * This function is used for a water tap.
 * 
 * Parameter : month with min. temperature [1..12]
 *             min. temperature [°C]
 *             month with max. temperature [1..12]
 *             max. temperature [°C]
 *             form : 1 = sinus wave
 *                    2 = linear distribution
 *
 * input       time [s]
 *
 * output      temperature [°C]
 */


#define S_FUNCTION_LEVEL 2
#define S_FUNCTION_NAME season_temperature


/*
 * Need to include simstruc.h for the definition of the SimStruct and
 * its associated macro definitions. math.h is for function sqrt
 */
#include "simstruc.h"
#include <math.h>
//#include "cutils.h"
#include "carlib.h"


/* defines for the iteration loop */
#define MAXCALL         100    /* maximum number of iteration calls */
#define ERROR           1.0e-5 /* error in massflow iteration       */


/*
 * some defines for access to the parameters
 */

#define DATEMIN       (*mxGetPr(ssGetSFcnParam(S,0)))    /*  month       */
#define Tmin          (*mxGetPr(ssGetSFcnParam(S,1)))    /*  min. temp   */
#define DATEMAX       (*mxGetPr(ssGetSFcnParam(S,2)))    /*  month       */
#define Tmax          (*mxGetPr(ssGetSFcnParam(S,3)))    /*  max. temp   */
#define FORM        (int)((*mxGetPr(ssGetSFcnParam(S,4)))+0.5)   /* 1=sinus, 2=linear     */
#define N_PARA                              5

/*
 * some defines for access to the output vector
 */

#define Y_OUT        y1[0]    


#define OUT_WIDTH    1     /* number of outputs per port */


/*
 * some defines for access to the rwork vector
 */



#define AMP             dwork_amp[0]        /* amplitude of sinus distribution         */
#define	DWORK_AMP_NR	0
#define T_CONST         dwork_t_const[0]        /* constant factor of sinus distribution   */
#define DWORK_T_CONST_NR 1

#define X1              dwork_x1[0]        /* constant factors of sinus distribution  */
#define DWORK_X1_NR		2
#define X2              dwork_x2[0]
#define DWORK_X2_NR		3
#define X               xC[0]        /* angle of sinus distribution             */
#define PHI1            dwork_phi1[0]
#define DWORK_PHI1_NR	4
#define PHI2            dwork_phi2[0]
#define DWORK_PHI2_NR	5
#define PHI3            dwork_phi3[0]
#define DWORK_PHI3_NR	6
#define PHI             xC[1]
#define tprec           dwork_tprec[0]
#define DWORK_TPREC_NR	7

#define B1              dwork_b1[0]        /* constant factors of linear distribution */
#define DWORK_B1_NR		8
#define B2              dwork_b2[0]
#define	DWORK_B2_NR		9
#define B3              dwork_b3[0]
#define	DWORK_B3_NR		10
#define M1              dwork_m1[0]       /* inclination of linear distribution      */
#define DWORK_M1_NR		11
#define M2              dwork_m2[0]
#define	DWORK_M2_NR		12

#define DMIN            dwork_dmin[0]        /* mid of first month in seconds           */
#define DWORK_DMIN_NR	13
#define DMAX            dwork_dmax[0]        /* mid of second month in seconds          */
#define DWORK_DMAX_NR	14

#define SECONDS_YEAR    31536000

/*====================*
 * S-function methods *
 *====================*/

#define MDL_CHECK_PARAMETERS
#if defined(MDL_CHECK_PARAMETERS) && defined(MATLAB_MEX_FILE)
  /* Function: mdlCheckParameters =============================================
   * Abstract:
   *    Validate our parameters to verify they are okay.
   */
  static void mdlCheckParameters(SimStruct *S)
  {
      /* */
      {
          if (Tmin > Tmax) {
              ssSetErrorStatus(S,"Error in season temperature: Tmin must be below Tmax");
              return;
          }
      }
      /* */
      {
          if (DATEMIN < 1.0 || DATEMIN > 12.0) {
              ssSetErrorStatus(S,"Error in season temperature: the first date must be a month between 1 and 12.");
              return;
          }
      }
      /* */
      {
          if (DATEMAX < 1.0 || DATEMAX > 12.0) {
              ssSetErrorStatus(S,"Error in season temperature: the second date must be a month between 1 and 12.");
              return;
          }
      }
  }
#endif /* MDL_CHECK_PARAMETERS */

/* Function: mdlInitializeSizes ===============================================
 * Abstract:
 *    The sizes information is used by Simulink to determine the S-function
 *    block's characteristics (number of inputs, outputs, states, etc.).
 */
static void mdlInitializeSizes(SimStruct *S)
{
    ssSetNumSFcnParams(S, N_PARA);  /* Number of expected parameters */
#if defined(MATLAB_MEX_FILE)
    if (ssGetNumSFcnParams(S) == ssGetSFcnParamsCount(S)) {
        mdlCheckParameters(S);
        if(ssGetErrorStatus(S) != NULL) return;
    } else {
        /* Return if number of expected != number of actual parameters */
        return;
    }
#endif

    ssSetNumContStates(S, 0);
    ssSetNumDiscStates(S, 2);

    if (!ssSetNumInputPorts(S, 0)) return;  

    if (!ssSetNumOutputPorts(S, 1)) return;
    ssSetOutputPortWidth(S, 0, OUT_WIDTH);

    ssSetNumSampleTimes(S, 1);
    ssSetNumRWork(S, 0); 
    ssSetNumIWork(S, 0);
    ssSetNumPWork(S, 0);
    ssSetNumDWork(S, 15);
    ssSetDWorkWidth(S, 0, 1);
    ssSetDWorkDataType(S, 0, SS_DOUBLE);
    ssSetDWorkName(S, 0, "DWORK_AMB");
    ssSetDWorkUsageType(S, 0, SS_DWORK_USED_AS_DSTATE);
	ssSetDWorkWidth(S, 1, 1);
    ssSetDWorkDataType(S, 1, SS_DOUBLE);
    ssSetDWorkName(S, 1, "DWORK_T_CONST");
    ssSetDWorkUsageType(S, 1, SS_DWORK_USED_AS_DSTATE);
	ssSetDWorkWidth(S, 2, 1);
    ssSetDWorkDataType(S, 2, SS_DOUBLE);
    ssSetDWorkName(S, 2, "DWORK_X1");
    ssSetDWorkUsageType(S, 2, SS_DWORK_USED_AS_DSTATE);
	ssSetDWorkWidth(S, 3, 1);
    ssSetDWorkDataType(S, 3, SS_DOUBLE);
    ssSetDWorkName(S, 3, "DWORK_X2");
    ssSetDWorkUsageType(S, 3, SS_DWORK_USED_AS_DSTATE);
	ssSetDWorkWidth(S, 4, 1);
    ssSetDWorkDataType(S, 4, SS_DOUBLE);
    ssSetDWorkName(S, 4, "DWORK_PHI1");
    ssSetDWorkUsageType(S, 4, SS_DWORK_USED_AS_DSTATE);
	ssSetDWorkWidth(S, 5, 1);
    ssSetDWorkDataType(S, 5, SS_DOUBLE);
    ssSetDWorkName(S, 5, "DWORK_PHI2");
    ssSetDWorkUsageType(S, 5, SS_DWORK_USED_AS_DSTATE);
	ssSetDWorkWidth(S, 6, 1);
    ssSetDWorkDataType(S, 6, SS_DOUBLE);
    ssSetDWorkName(S, 6, "DWORK_PHI3");
    ssSetDWorkUsageType(S, 6, SS_DWORK_USED_AS_DSTATE);
	ssSetDWorkWidth(S, 7, 1);
    ssSetDWorkDataType(S, 7, SS_DOUBLE);
    ssSetDWorkName(S, 7, "DWORK_TPREC");
    ssSetDWorkUsageType(S, 7, SS_DWORK_USED_AS_DSTATE);
	ssSetDWorkWidth(S, 8, 1);
    ssSetDWorkDataType(S, 8, SS_DOUBLE);
    ssSetDWorkName(S, 8, "DWORK_B1");
    ssSetDWorkUsageType(S, 8, SS_DWORK_USED_AS_DSTATE);
	ssSetDWorkWidth(S, 9, 1);
    ssSetDWorkDataType(S, 9, SS_DOUBLE);
    ssSetDWorkName(S, 9, "DWORK_B2");
    ssSetDWorkUsageType(S, 9, SS_DWORK_USED_AS_DSTATE);
	ssSetDWorkWidth(S, 10, 1);
    ssSetDWorkDataType(S, 10, SS_DOUBLE);
    ssSetDWorkName(S, 10, "DWORK_B3");
    ssSetDWorkUsageType(S, 10, SS_DWORK_USED_AS_DSTATE);
	ssSetDWorkWidth(S, 11, 1);
    ssSetDWorkDataType(S, 11, SS_DOUBLE);
    ssSetDWorkName(S, 11, "DWORK_M1");
    ssSetDWorkUsageType(S, 11, SS_DWORK_USED_AS_DSTATE);
	ssSetDWorkWidth(S, 12, 1);
    ssSetDWorkDataType(S, 12, SS_DOUBLE);
    ssSetDWorkName(S, 12, "DWORK_M2");
    ssSetDWorkUsageType(S, 12, SS_DWORK_USED_AS_DSTATE);
	ssSetDWorkWidth(S, 13, 1);
    ssSetDWorkDataType(S, 13, SS_INT32);
    ssSetDWorkName(S, 13, "DWORK_DMIN");
    ssSetDWorkUsageType(S, 13, SS_DWORK_USED_AS_DSTATE);
	ssSetDWorkWidth(S, 14, 1);
    ssSetDWorkDataType(S, 14, SS_INT32);
    ssSetDWorkName(S, 14, "DWORK_DMAX");
    ssSetDWorkUsageType(S, 14, SS_DWORK_USED_AS_DSTATE);
	
	ssSetNumModes(S, 0);
    ssSetNumNonsampledZCs(S, 0);
	
	ssSetSimStateCompliance(S, USE_DEFAULT_SIM_STATE);
    ssSetSimStateVisibility(S, 1);
    
    ssSupportsMultipleExecInstances(S, true);

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



#define MDL_INITIALIZE_CONDITIONS
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
    /*InputRealPtrsType u1Ptrs = ssGetInputPortRealSignalPtrs(S,0);*/
    real_T *dwork_amp 		 = ssGetDWork(S, DWORK_AMP_NR);
	real_T *dwork_t_const 	 = ssGetDWork(S, DWORK_T_CONST_NR);
	real_T *dwork_x1 		 = ssGetDWork(S, DWORK_X1_NR);
	real_T *dwork_x2 		 = ssGetDWork(S, DWORK_X2_NR);
	real_T *dwork_phi1 		 = ssGetDWork(S, DWORK_PHI1_NR);
	real_T *dwork_phi2 		 = ssGetDWork(S, DWORK_PHI2_NR);
	real_T *dwork_phi3 		 = ssGetDWork(S, DWORK_PHI3_NR);
	real_T *dwork_tprec 	 = ssGetDWork(S, DWORK_TPREC_NR);
	real_T *dwork_b1 		 = ssGetDWork(S, DWORK_B1_NR);
	real_T *dwork_b2 		 = ssGetDWork(S, DWORK_B2_NR);
	real_T *dwork_b3 		 = ssGetDWork(S, DWORK_B3_NR);
	real_T *dwork_m1 		 = ssGetDWork(S, DWORK_M1_NR);
	real_T *dwork_m2 		 = ssGetDWork(S, DWORK_M2_NR);
	int32_T *dwork_dmin 	 = ssGetDWork(S, DWORK_DMIN_NR);
	int32_T *dwork_dmax      = ssGetDWork(S, DWORK_DMAX_NR);
    real_T  *xC       		 = ssGetDiscStates(S);
    real_T  tStart    		 = (real_T)ssGetTStart(S);
    
    mxArray *out[1], *in[1];
    double *nhls;
    int_T   fail;
    /* int_T   d3, fail; */
    /* real_T  t3, deltaT; */


    AMP = (Tmax-Tmin)/2;
    T_CONST = Tmin+AMP;
        
    in[0] = mxCreateDoubleMatrix(1,5,mxREAL);
    nhls = mxGetPr(in[0]);
    nhls[0] = (double)DATEMIN;
    nhls[1] = 15.0;
    nhls[2] = 0.0;
    nhls[3] = 0.0;
    nhls[4] = 0.0;
    fail = mexCallMATLAB(1, out, 1, in, "date2sec");
    if (fail) {
        ssSetErrorStatus(S,"Error calling 'date2sec.m'");
        return;
    }    
    DMIN = (int_T)*mxGetPr(out[0]);
    
    nhls[0] = (double)DATEMAX;
    nhls[1] = 15.0;
    nhls[2] = 0.0;
    nhls[3] = 0.0;
    nhls[4] = 0.0;
    fail = mexCallMATLAB(1, out, 1, in, "date2sec");
    if (fail) {
        ssSetErrorStatus(S,"Error calling 'date2sec.m'");
        return;
    }
    DMAX = (int_T)*mxGetPr(out[0]);
    
    if (FORM==1) {      /* sinus distribution */ 
        
        tStart = (real_T)((int_T)tStart % SECONDS_YEAR);
        
        if (DMAX>DMIN) {
            X1 = PI/(real_T)(DMAX-DMIN);
            X2 = PI/(real_T)(DMIN+SECONDS_YEAR-DMAX);
            
            PHI1 = - PI/2 - (X2*DMIN);
            PHI2 = - PI/2 - (X1*DMIN);
            PHI3 = PI/2 - (X2*DMAX);
            
            if(tStart<(double)DMIN) {
                PHI = PHI1;
                X = X2;
            } else if(tStart>(double)DMAX) {
                PHI = PHI3;
                X = X2;
            }else{
                PHI = PHI2;
                X = X1;
            }
            
        } else {
            X1 = PI/(real_T)(DMAX+SECONDS_YEAR-DMIN);
            X2 = PI/(real_T)(DMIN-DMAX);
                      
            PHI1 = PI/2 - (X1*DMAX);
            PHI2 = PI/2 - (X2*DMAX);
            PHI3 = - PI/2 - (X1*DMIN);
            
            if(tStart<(double)DMAX) {
                PHI = PHI1;
                X = X1;
            } else if(tStart>(double)DMIN) {
                PHI = PHI3;
                X = X1;
            }else{
                PHI = PHI2;
                X = X2;
            }
        }
        
    } else {
        M1 = (Tmax-Tmin)/(DMAX>DMIN?(DMAX-DMIN):(DMAX+SECONDS_YEAR-DMIN));
        M2 = (Tmin-Tmax)/(DMIN>DMAX?(DMIN-DMAX):(DMIN+SECONDS_YEAR-DMAX));
        
        B1 = Tmax-M1*DMAX;
        B2 = Tmax-M2*DMAX;
        B3 = Tmin-(DMAX>DMIN?M2:M1)*DMIN;
    }
    
    tprec = tStart;

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
    /*InputRealPtrsType u1Ptrs = ssGetInputPortRealSignalPtrs(S,0);*/

    real_T *y1 = ssGetOutputPortRealSignal(S,0);

    real_T *xC  = ssGetDiscStates(S);
	
    real_T *dwork_amp 		 = ssGetDWork(S, DWORK_AMP_NR);
	real_T *dwork_t_const 	 = ssGetDWork(S, DWORK_T_CONST_NR);
	/*real_T *dwork_x1 		 = ssGetDWork(S, DWORK_X1_NR);
	real_T *dwork_x2 		 = ssGetDWork(S, DWORK_X2_NR);
	real_T *dwork_phi1 		 = ssGetDWork(S, DWORK_PHI1_NR);
	real_T *dwork_phi2 		 = ssGetDWork(S, DWORK_PHI2_NR);
	real_T *dwork_phi3 		 = ssGetDWork(S, DWORK_PHI3_NR);
	real_T *dwork_tprec 	 = ssGetDWork(S, DWORK_TPREC_NR);*/
	real_T *dwork_b1 		 = ssGetDWork(S, DWORK_B1_NR);
	real_T *dwork_b2 		 = ssGetDWork(S, DWORK_B2_NR);
	real_T *dwork_b3 		 = ssGetDWork(S, DWORK_B3_NR);
	real_T *dwork_m1 		 = ssGetDWork(S, DWORK_M1_NR);
	real_T *dwork_m2 		 = ssGetDWork(S, DWORK_M2_NR);
	int32_T *dwork_dmin 	 = ssGetDWork(S, DWORK_DMIN_NR);
	int32_T *dwork_dmax      = ssGetDWork(S, DWORK_DMAX_NR);
    
    real_T  t = (real_T)ssGetT(S);

    t = ((int_T) t) % SECONDS_YEAR + (t - (int_T)t);
   
    if (FORM==1)       /* sinus distribution */
    {

        Y_OUT = AMP*sin(t*X+PHI) + T_CONST;
       
    }      
    else             /* linear distribution */
    {
        if(DMIN<DMAX) {
            if (t<(double)DMIN)
                Y_OUT = M2*t+B3;
            else if (t<(double)DMAX)
                Y_OUT = M1*t+B1;
            else
                Y_OUT = M2*t+B2;
        }else{
            if (t<(double)DMAX)
                Y_OUT = M1*t+B1;
            else if (t<(double)DMIN)
                Y_OUT = M2*t+B2;
            else
                Y_OUT = M1*t+B3;
        }
    }
    
} /* end mdloutputs */



#define MDL_UPDATE  /* Change to #undef to remove function */
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
    /*InputRealPtrsType u1Ptrs = ssGetInputPortRealSignalPtrs(S,0);*/
    
    real_T            *xC  = ssGetDiscStates(S);
    
	/*real_T *dwork_amp 		 = ssGetDWork(S, DWORK_AMP_NR);
	real_T *dwork_T_CONST 	 = ssGetDWork(S, DWORK_T_CONST_NR);*/
	real_T *dwork_x1 		 = ssGetDWork(S, DWORK_X1_NR);
	real_T *dwork_x2 		 = ssGetDWork(S, DWORK_X2_NR);
	real_T *dwork_phi1 		 = ssGetDWork(S, DWORK_PHI1_NR);
	real_T *dwork_phi2 		 = ssGetDWork(S, DWORK_PHI2_NR);
	real_T *dwork_phi3 		 = ssGetDWork(S, DWORK_PHI3_NR);
	real_T *dwork_tprec 	 = ssGetDWork(S, DWORK_TPREC_NR);
	/*real_T *dwork_b1 		 = ssGetDWork(S, DWORK_B1_NR);
	real_T *dwork_b2 		 = ssGetDWork(S, DWORK_B2_NR);
	real_T *dwork_b3 		 = ssGetDWork(S, DWORK_B3_NR);
	real_T *dwork_m1 		 = ssGetDWork(S, DWORK_M1_NR);
	real_T *dwork_m2 		 = ssGetDWork(S, DWORK_M2_NR);*/
	int32_T *dwork_dmin 	 = ssGetDWork(S, DWORK_DMIN_NR);
	int32_T *dwork_dmax      = ssGetDWork(S, DWORK_DMAX_NR);
    
    real_T  t = (real_T)ssGetT(S);

    t = ((int_T) t) % SECONDS_YEAR + (t - (int_T)t);
    
    if (FORM==1)       /* sinus distribution */ {
        if (tprec < (double)DMIN && t >= (double)DMIN) {
            X = X1;
        } else if (tprec < (double)DMAX && t >= (double)DMAX) {
            X = X2;
        }
        
        if (DMAX>DMIN) {
            if(tprec < (double)DMIN && t >= (double)DMIN) {
                PHI = PHI2;
            }else if(tprec < (double)DMAX && t >= (double)DMAX) {
                PHI = PHI3;
            }else if(tprec>=SECONDS_YEAR/2 && t<SECONDS_YEAR/2){
                PHI = PHI1;
               }
            
        } else {
            if(tprec < (double)DMIN && t >= (double)DMIN) {
                PHI = PHI3;
            }else if(tprec < (double)DMAX && t >= (double)DMAX) {
                PHI = PHI2;
            }else if(tprec>SECONDS_YEAR/2 && t<SECONDS_YEAR/2){
                PHI = PHI1;
            }
        }
        tprec = t;
    }
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
