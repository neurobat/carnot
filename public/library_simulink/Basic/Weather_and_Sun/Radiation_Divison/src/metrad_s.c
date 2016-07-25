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
 * Syntax  [Idir Idfu SunAngel Zenith Azimuth] = metrad_s[time Iglob, lat, long, long0]
 *
 * Version  Author      Changes                                     Date
 * 0.01.0   Th. Wenzel  created M-script                            18oct1999
 * 0.02.0   tw          created S-function                          25nov1999
 * 4.1.0    hf          using carlib functions for solar position   02dec2008
 * 5.1.0    hf          changed unknown global-diffuse correlation  01jun2012
 *                      to the Orgill and Hollands Model (1977) 
 *
 * Copyright (c) 1999 Solar-Institut Juelich, Germany
 * 
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *  D E S C R I P T I O N
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * FUNCTION:		Berechnung von direkter und diffuser Strahlung auf die Horizontale
            
              INPUT
         
			  1. time		    :	Stunde eines Jahres, 1, [1,8760]
			  2. IGLOB	   	    :	Globalstrahlung auf eine HORIZONTALE Fläche, W/m2
			  3. latitude      :   Breitengrad ([-90,90],Nord positiv)
              4. longitude     :   Längengrad ([-180,180],West positiv)
              5. longitudenull :   Referenzlängengrad (Zeitzone)
					
              OUTPUT

			  1. Idir			:	direkte Strahlung auf Horizontale, W/m2
			  2. Idfu			:	diffuse Strahlung auf Horizontale, W/m2
              3. SunAngle      :   Sonnenhöhenwinkel
              4. Zenith        
              5. Azimuth

  Modifizierung des M-Skriptes metcalc.m von Markus Werner, Solar-Institut Juelich

  Thomas Wenzel, 25.11.1999


  Berechnung des Sonnenstandes aus sunpos.c übernommen:
  
 * The model calculates the sun_position described by the three sun-angles zenit-angle,
 * azimuth-angle and the angle between collector normal and the sun. The calculation is 
 * carried out based on the formulas of the "Deutscher Wetterdienst". The input data are 
 * taken from the Test reference year (TRY).
 */


#define S_FUNCTION_LEVEL 2
#define S_FUNCTION_NAME metrad_s


/*
 * Need to include simstruc.h for the definition of the SimStruct and
 * its associated macro definitions. math.h is for function sqrt
 */
#include "simstruc.h"
#include <math.h>
#include "carlib.h"


/*
 * some defines for access to the parameters
 */
/*define DIAMETER (*mxGetPr(ssGetSFcnParam(S,0))) *//* diameter of inlet and outlet */
#define N_PARA                              0

/*
 * some defines for access to the input vector
 */
#define IGLOB          (*u1Ptrs[0])    /* Month  1..12   */
#define LATITUDE       (*u1Ptrs[1])    /* Day   1..31    */
#define LONGITUDE      (*u1Ptrs[2])    
#define LONGITUDENULL  (*u1Ptrs[3])    
#define IN_WIDTH                4      /* number of inputs per port */


/*
 * some defines for access to the output vector
 */
#define IDIR       y1[0]    
#define IDFU       y1[1]    
#define SUNANGLE   y1[2]    
#define ZENITH     y1[3]    
#define AZIMUTH    y1[4]    
#define OUT_WIDTH     5     /* number of outputs per port */


#define TIME     ssGetT(S)
//#define DeclDayAmpl   -0.40927970959267   /* = -23.45 * pi/180;  */
//#define HourAngleAmpl  0.261799387799149  /* = 15 * pi/180;      */


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
    InputRealPtrsType u1Ptrs = ssGetInputPortRealSignalPtrs(S,0);
    real_T *y1 = ssGetOutputPortRealSignal(S,0);
    real_T time = TIME;
    
    real_T Iglobal, SunHour, ClearIndex, 
           delta, woz, HourAngle, coszenit,
           latitude, Iextra, IextraDay;
     
    Iglobal = IGLOB;
  
    /* Besetzen diverser Variablen mit Default-Werten:*/
    SunHour = 0;	/* Kennung für Tagesstunden; "0" = NACHTstunden*/
    ClearIndex = -1; /* Erkennungsmarke für NACHT-Interpolation    */
    
    IDFU = 0;	/* Default: "0" = NACHT */
    
    latitude = DEG2RAD*LATITUDE;
    
    
    SUNANGLE = 0;
    ZENITH = 0;
    AZIMUTH = 0;
    
    
    if (Iglobal<0)       /* wenn negative Einstrahlung, dann Einstrahlungen = 0*/
    {
       IDIR = 0;
       IDFU = 0;
    }
    else
    {
       /* ------------------------------------------------------------------------------- 
    	* 	"Decl"			Deklination der Sonne
    	*	"HourAngle" 	Stundenwinkel der Sonne 
    	*	"zenit"			Zenithwinkel 
        *	"SunAngle"		Sonnenhöhenwinkel
    	* 	"azimut"			Azimutwinkel 
    	*	"Iextra"			Extraterrestrische Strahlung auf HORIZONTALE Fläche
        *	"SunHour"		Tag-/Nachterkennung Êrkennung
        *"dimness"		Trübungsfaktor der Atmosphäre
        * 	"Idirclear"		direkte Strahlung auf der Erdoberfläche für KLAREN Himmel 
    	* 	"Idfuclear"		diffuse Strahlung auf der Erdoberfläche für KLAREN Himmel 
       /* -------------------------------------------------------------------------------*/ 

        /* solar time 0 .. 24*3600 s */
        woz = solar_time(time, LONGITUDENULL, LONGITUDE);      /* solar time from carlib */

        /* determine solar hour angle in radian (noon = 0,  6 a.m. = -PI) */
        HourAngle = (woz - 43200.0)*7.272205216643040e-5;

        /* declination of the sun */
        delta = solar_declination(time); 

        /* solar zenith angle in degrees (0° = zenith position, 90° = horizont) */
        coszenit = sin(latitude)*sin(delta) + cos(latitude)*cos(delta)*cos(HourAngle);
        ZENITH  =  acos(coszenit)*RAD2DEG;   
    
        /* solar azimuth angle */
        if (ZENITH != 0.0 && ZENITH != 180.0)  /* zenith angle not 0 and not 180 */ 
        {
           AZIMUTH = RAD2DEG*acos((sin(latitude)*coszenit 
              -sin(delta))/(cos(latitude)*sin(acos(coszenit))));
           if (HourAngle < 0)
              AZIMUTH = -AZIMUTH;
        }
        else
           AZIMUTH = 0.0;
        
        /* Sonnenhöhenwinkel "SunAngle":*/
        SUNANGLE = 90 - ZENITH;
        if (SUNANGLE < .01)
           SUNANGLE = .01; /* da sonst Warnung "log(0)" (s.u.), falls SunAngle = 0.*/
        
        /* Auf eine HORIZONTALE (= der Erdoberfläche parallelen) Fläche unter dem  */
        IextraDay = extraterrestrial_radiation(time);
        /* Winkel "zenit" treffende extraterrestrische Strahlung "Iextra":         */
        Iextra = IextraDay * coszenit;
        
        /* Kennung für Tagesstunden "SunHour":      */
        if (Iextra > 0.0)
           SunHour = 1;
        else
           SunHour = 0;
        
        /* Unterdrückung von nächtlichen Offset-Werten in "Iglobal":                         */
        if (SunHour == 0 && Iglobal > 0.0)
           Iglobal = 0.0;
       	
        /* ------------------------------------------------------------------------------- 
         * 	"ClearIndex"	Klarheitsindex der Atmosphäre (TAG)
         * 	"Idir"			direkte Strahlung auf der Erdoberfläche
         * 	"Idfu"			diffuse Strahlung auf der Erdoberfläche
         * ------------------------------------------------------------------------------- */
        
        IDFU = 0.0;
        if (SunHour == 1)
        {
           ClearIndex = Iglobal/Iextra;
           
           if (ClearIndex > 1.0)           /* ggfs. Korrektur, damit "ClearIndex" <= 1 bleibt:*/
              ClearIndex = 1.0;

           
           /* Diffuse Strahlung auf HORIZONTALE Fläche "Idfu" ...  */ /* unknown model */
           /* if (ClearIndex <= 0.3)
            *  IDFU = Iglobal * (1 - 0.2 * ClearIndex);
            * else if (ClearIndex <= 0.79)
            *  IDFU = Iglobal * (1.423-1.612 * ClearIndex);
            * else
            *  IDFU = Iglobal * 0.15;
            */

           /* diffuse radiation on horizontal surface
            *  Orgill & Hollands correlation from Duffie, Beckmann Solar Engineering 2006 */
            if (ClearIndex <= 0.35)
                IDFU = Iglobal * (1 - 0.249 * ClearIndex);
            else if (ClearIndex <= 0.75)
                IDFU = Iglobal * (1.557 - 1.84 * ClearIndex);
            else
                IDFU = Iglobal * 0.177;
        }
        
        /* Direkte Strahlung auf HORIZONTALE Fläche "Idir"*/
        IDIR = Iglobal - IDFU;
    
    } /* else if Iglobal>=0*/

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
