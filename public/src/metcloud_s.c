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
 * Syntax  [CloudIndex] = metcloud_s [time Iglob, lat, long, long0, SkyType]
 *
 * Version  Author      Changes                                 Date
 * 0.01.0   Th. Wenzel  created M-script                        18oct99
 * 0.02.0   tw          created S-function                      25nov99
 * 3.1.0    hf          skytype as parameter                    29dec2008
 *                      get time with ssGetT()
 * 6.1.0    hf          double m,b,dx replaced by               14sep2015
 *                      real_T mx,bx,dx in mdlOutputs
 * 6.1.1    aw          RWork replaced by DWork                 15sep2015
 *                      SimStateCompliance and
 *                      SupportsMultipleExecInstances added
 * 6.1.2    hf          corrected mx (not m) in line 387        18sep2015
 *
 * Copyright (c) 1999 Solar-Institut Juelich, Germany
 * 
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *  D E S C R I P T I O N
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * FUNCTION:		Berechnug des Bewölkungsindexes            

              INPUT-Vector
         
			  1. time		    :	Stunde eines Jahres, 1, s
			  2. I	   	        :	Globalstrahlung auf eine HORIZONTALE Fläche, W/m2
			  3. latitude      :   Breitengrad ([-90,90],Nord positiv)
              4. longitude     :   Längengrad ([-180,180],West positiv)
              5. longitudenull :   Referenzlängengrad (Zeitzone)
              6. SkyType       :   1,2,3,4 (s.u.)
					
     		  OUTPUT-Vector

              1. CloudIndex	  :   Bewölkungsindex

 
 Modifizierung des M-Skriptes metcalc.m von Markus Werner, Solar-Institut Juelich

 Thomas Wenzel, 25.11.1999
 */


#define S_FUNCTION_LEVEL 2
#define S_FUNCTION_NAME metcloud_s


/*
 * Need to include simstruc.h for the definition of the SimStruct and
 * its associated macro definitions. math.h is for function sqrt
 */
#include "simstruc.h"
#include <math.h>
#include "carlib.h"


/*
 * some defines for access to the parameters
 * index    use                                       
 * 0        type of sky   1: high mountain, 2: lowland
 *                        3: urban region, 4: industrial zone 
 */
#define SKYTYPE    *mxGetPr(ssGetSFcnParam(S, 0))
#define N_PARA                                1


/*
 * some defines for access to the input vector
 */
#define IGLOB          (*u1Ptrs[0])    /* global solar radiation on horizontal in w/m^2         */
#define LATITUDE       (*u1Ptrs[1])    /* geographical latitude in degree, north positive       */
#define LONGITUDE      (*u1Ptrs[2])    /* geographical longitude in degree, east negative       */
#define LONGITUDENULL  (*u1Ptrs[3])    /* longitude of timezone in degree, GMT=0, east negative */
#define IN_WIDTH                4      /* number of inputs per port */


/*
 * some defines for access to the output vector
 */
#define CLOUDINDEX y1[0]    
#define OUT_WIDTH     1     /* number of outputs per port */


#define SQR(x) ((x)*(x))
#define HourAngleAmpl  0.261799387799149  /* = 15 * pi/180;      */
#define TIME        ssGetT(S)


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
    ssSetNumDWork(S, 1);
    ssSetDWorkWidth(S, 0, 4); /* heigth of one node */
    ssSetDWorkDataType(S, 0, SS_DOUBLE);
    ssSetDWorkName(S, 0, "DWORK");
    ssSetDWorkUsageType(S, 0, SS_DWORK_USED_AS_DSTATE);
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
      real_T *dwork    = (real_T *)ssGetDWork(S, 0);

      dwork[0] = 1.0;
      dwork[1] = 0.0;
      dwork[2] = 2.0;
      dwork[3] = 0.0;



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
    real_T *dwork    = (real_T *)ssGetDWork(S, 0);
    real_T time = TIME;

    real_T I, ClearIndex, delta, woz, HourAngle, coszenit,
           Iextra, IextraDay, day, 
           dimness, Idirclear, Idfuclear, Iclear, Taudir, Taudfu,
           latitude, Trs, Tab, Tms,
           zenith, sunangle, CloudFraction, a, b;
    real_T mx,bx,dx;

    int    SunHour;
     
    I = IGLOB;
    a = 0.75; /* Parameter für Berechnung von "CloudIndex"*/
    b = 3.2;  /* Parameter für Berechnung von "CloudIndex"*/

    latitude = DEG2RAD*LATITUDE;
    
    /* Besetzen diverser Variablen mit Default-Werten:*/
    SunHour = 0;	    /* Kennung für Tagesstunden; "0" = NACHTstunden*/
    ClearIndex = -1.0;    /* Erkennungsmarke für NACHT-Interpolation    */
    CLOUDINDEX = 0.0;
    day = ceil(TIME/86400.);
    
       /* Tägliche Deklination der Sonne "DeclDay" (nach Meliß,1988,S.32):*/
       //DeclDay = DeclDayAmpl * cos(2*PI*(day+10)/365);
       //DeclDay = solar_declination(double time);
       
    /* Tagesmittelwert der extraterrestrischen Strahlung "IextraDay", die senkrecht*/
    /* auf eine zur Sonne orientierten Fläche fällt */
    IextraDay = extraterrestrial_radiation(time);
       
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
    zenith  =  acos(coszenit)*RAD2DEG;   
    
        
    /* Sonnenhöhenwinkel "SunAngle":*/
    sunangle = 90.0 - zenith;
    if (sunangle < 0.01)
        sunangle = 0.01; /* da sonst Warnung "log(0)" (s.u.), falls SunAngle = 0.*/
        
    /* Auf eine HORIZONTALE (= der Erdoberfläche parallelen) Fläche unter dem  */
    /* Winkel "zenit" treffende extraterrestrische Strahlung "Iextra":         */
    Iextra = IextraDay * coszenit;
        
    /* Kennung für Tagesstunden "SunHour":      */
    if (Iextra > 0.0)
        SunHour = 1;
    else
        SunHour = 0;
        
        /* Spline-Interpolation der Zwischenwerte der Transmissionsfaktoren "TauXY": */
        /*        Trs = interp1(SunAngleRef,TauRS,sunangle,'cubic');
        Tab = interp1(SunAngleRef,TauAB,sunangle,'cubic');
        Tms = interp1(SunAngleRef,TauMS,sunangle,'cubic');  
        */      
    /*
     * Anstelle der Interpolation mit interp1 und gegebenen Vektoren, stehen hier
     * Funktionen, die aus den Vektoren TauRS, ... mit Hilfe von Origin ermittelt wurden.
     * Die Fehler liegen maximal bei 0.1 %
     */
    Trs = 0.0101  + 0.4225*(1-exp(-sunangle/15.83705)) + 0.47249*(1+exp(-sunangle/1.56203));
    Tab = 0.01001 + 0.18336*(1-exp(-sunangle/10.72578)) + 0.71278*(1+exp(-sunangle/0.00125));
    
    switch ((int)(SKYTYPE+0.5))
    {
        case 1: default:            /* high mountain */
            Tms = 0.01 + 0.41882*(1-exp(-sunangle/9.86609)) 
                + 0.56058*(1+exp(-sunangle/0.02186));
            break;
        case 2:                     /* lowland */
            Tms = 0.01 + 0.66679*(1-exp(-sunangle/13.71293)) 
                + 0.23729*(1+exp(-sunangle/0.02186));
            break;

        case 3:                     /* urban region */
            Tms = 0.01026 + 0.41079*(1-exp(-sunangle/32.42557)) 
                + 0.44058*(1+exp(-sunangle/8.46267));
            break;

        case 4:                     /* industrial zone */
            Tms = -0.00021 + 0.38332*(1-exp(-sunangle/24.10493)) 
                + 0.38343*(1+exp(-sunangle/24.25446));
            break;
    }
    
    /* Trübungsfaktor "dimness" (nach Meliß, 1993, S.38ff):  */
    dimness = 1.0 + ( (log(Tms) + log(Tab)) / log(Trs) );
        
    /* KLARER Himmel: Transmissionsfaktor "Taudir" und DIREKTstrahlung "Idirclear" */
    /* auf eine zur Einfallsrichtung senkrechte Fläche (nach Kasten/Meliß,1993,S.38ff):*/
    Taudir = exp( -dimness/(0.9 + 9.4 * coszenit) );
    Idirclear = Iextra * Taudir;
    
    /* KLARER Himmel: Transmissionsfaktor "Taudfu" und DIFFUSstrahlung "Idfuclear" */
    /* auf eine zur Einfallsrichtung senkrechte Fläche                             */
    /*(nach Liu/Jordan bzw. nach Duffie/Beckman,1991,S.75):                        */
    Taudfu = 0.2710 - 0.2939 * Taudir; 
    Idfuclear	= Iextra * Taudfu;
    
    /* KLARER Himmel: Globalstrahlung auf HORIZONTALE "Iclear":                    */
    Iclear= Idirclear + Idfuclear;
    
    /* Unterdrückung von nächtlichen Offset-Werten in "I":                         */
    if (SunHour == 0 && I > 0.0)
       I = 0.0;
       	

   	
	/* ------------------------------------------------------------------------------- 
	  	"ClearIndex"	Klarheitsindex der Atmosphäre (TAG)
	 	"CloudIndex"	Bedeckungsgrad des Himmels (TAG)
	 	"Idir"			direkte Strahlung auf der Erdoberfläche
	 	"Idfu"			diffuse Strahlung auf der Erdoberfläche
	 ------------------------------------------------------------------------------- */

    if (SunHour == 1)
    {
       CloudFraction = I/Iclear;

       if (CloudFraction > 1.0)       /*ggfs. Korrektur, damit "CloudIndex" <= 1 bleibt:*/
    		CloudFraction = 1.0;

       CLOUDINDEX = pow(( 1.0/a * (1.0 - CloudFraction) ),(1.0/b));
       
       if (CLOUDINDEX > 1.0)
          CLOUDINDEX = 1.0;

    }
    else      /* Nachtwerte : Interpolation durch Gerade durch die letzten beiden Werte */
    {
       dx = (dwork[2]-dwork[0]);
       
       if (dx > 1.0e-10)         
            mx = (dwork[3]-dwork[1])/dx;
       else 
            mx = 0.0;
       bx = dwork[1]-mx*dwork[0];
       CLOUDINDEX = mx*time+bx;
    }
       
    
    /* Interpolation ? */

     /* Diskretisierung von "CloudIndex" in Okta [0, 1/8, 2/8, ... ,8/8]:*/
    if (CLOUDINDEX >= 1.0)
    	CLOUDINDEX = 1.0;
  	else if (CLOUDINDEX >= .875)
		CLOUDINDEX = .875;
    else if (CLOUDINDEX >= .75)
		CLOUDINDEX = .75;
    else if (CLOUDINDEX >= .625)
		CLOUDINDEX = .625;
    else if (CLOUDINDEX >= .5)
		CLOUDINDEX = .5;
    else if (CLOUDINDEX >= .375)
		CLOUDINDEX = .375;
    else if (CLOUDINDEX >= .25)
		CLOUDINDEX = .25;
    else if (CLOUDINDEX > 0.0)
		CLOUDINDEX = .125;
    else 
		CLOUDINDEX = 0.0;

    dwork[0] = dwork[2];
    dwork[1] = dwork[3];
    dwork[2] = time;
    dwork[3] = CLOUDINDEX;

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
