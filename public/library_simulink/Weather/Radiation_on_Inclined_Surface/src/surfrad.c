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
 * This s-function calculates the radiation on a tilted surface from 
 * the sun position.
 * author list:     gf -> Gaelle Faure
 *                  hf -> Bernd Hafner
 *                  wec -> Carsten Wemhoener
 *
 * version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
 * Version  Author  Changes                                         Date
 * 0.1.0    hf      created                                         05mar98
 * 0.1.1    hf      collector angle and azimut as                   06mar98
 *                  input, not as parameter                         
 * 0.1.2    hf      include function square = x*x                   05mar98
 * 0.1.3    hf      check sunset, no calculation at night,          20mar98
 * 0.5.0    hf      toolbox name changed to CARNOT                  30apr98
 * 0.5.1    hf      material properties from carlib                 20mai98
 * 0.8.0    hf      collector rotation angle is now                 29jun98
 *                  rotation around riser (east negative)           
 * 0.9.0    hf      direct and diffuse radiation not                19jul98
 *                  less than zero                                  
 * 0.11.0   hf      always calculate tetap and tetas                27jan99
 * 3.1.0    hf      level 2 s-function                              25dec2008
 *                  new equation for extraterrestrial radiation
 * 3.1.1    gf      add call to mdlCheckParameter in                10feb2011
 *                  mdlInitializeSizes
 * 4.7      wec		amendment of Perez (1990) model (skymodel =3)   3march2011
 *                  mdlCheckParameter extended to 3.0
 * 4.7.1    gf      modify with new weather data vector             31mai2011
 * 5.1.0    hf      corrected ground reflected radiation            11apr2012
 * 5.2.0    hf      output is always in new weather data format     13mar2013
 * 6.1.0    hf      input new weather data format from WDB          08dec2013
 * 6.1.1	aw		SimState compiliance and						24jul2015
 *					multiple instances activated
 * 6.1.2    aw      implicite casts replaced by explicite casts     10sep2015
 *                  unused variables deleted
 * 6.1.3    hf      modified no-sun condition                       23sep2016
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * parameters                                                           
 * index    use                                             units       
 * 0        sky model (1=isotropic)                         -           
 * 1        ground reflectance (0..1)                       -           
 *                                                                    
 * Definiton of INPUTS and OUTPUTS 
 * structure of the input vector
 * port index   use                                             units
 * 0    0..17   weather data vector (index see output vector)
 * 1    0       inclination of the surface (0° = horizontal)    degree
 *      1       azimut of the surface (0°=south, east negativ)  degree
 *      2       collector rotation angle                        degree
 * 
 * structure of the output vector
 * col   description                                         units
 *  1    time                                                s
 *  2    timevalue (comment line) format YYYYMMDDHHMM        -
 *       Y is the year, M the month, D the day, H the hour
 *  3    zenith angle of sun (at time, not averaged)         degree
 *       (continue at night to get time of sunrise by
 *       linear interpolation)
 *  4    azimuth angle of sun (0°=south, east negative)      degree
 *       (at time, not average in timestep)
 *  5    direct beam solar radiation on a normal surface     W/m^2
 *  6    diffuse solar radiation on a horizontal surface     W/m^2
 *  7    ambient temperature                                 degree Celsius
 *  8    radiation temperature of sky                        degree Celsius
 *  9    relative humidity                                   percent
 * 10    precipitation                                       m/s
 * 11    cloud index (0=no cloud, 1=covered sky)             -
 * 12    station pressure                                    Pa
 * 13    mean wind speed                                     m/s
 * 14    wind direction (north=0° west=270°)                 degree
 * 15    incidence angle on surface (0° = vertical)          degree
 * 16    incidence angle in a vertical plane on the collecor degree
 *       orientation of the plane is parallel to the risers,
 *       referred as longitudinal plane in EN 12975
 * 17    incidence angle in a vertical plane on the collecor degree
 *       orientation of the plane is parallel to the headers
 *       referred as transversal plane in EN 12975
 *       (= -9999, if surface orientation is unknown)
 * 18    direct solar radiation on surface                   W/m^2
 * 19    diffuse solar radiation on surface                  W/m^2
 *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *  L I T E R A T U R E
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * /1/  Duffie, Beckman: Solar Engineering of Thermal Processes, 2006
 */

#define S_FUNCTION_NAME surfrad
#define S_FUNCTION_LEVEL 2

#include "tmwtypes.h"
#include "simstruc.h"
#include "carlib.h"
#include <math.h>
#include <string.h>

#define ZENITH          (*uPtrs0[1])
#define AZIMUT          (*uPtrs0[2])
#define COLANGLE        (*u1[0])
#define COLAZIMUT       (*u1[1])
#define COLROTATE       (*u1[2])

#define SKYMODEL    *mxGetPr(ssGetSFcnParam(S, 0)) /* sky model */      
#define GREFLECT    *mxGetPr(ssGetSFcnParam(S, 1)) /* ground reflectance */
                                                                        
#define TIME        ssGetT(S)

                                                                        

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
          if (SKYMODEL < 1.0 || SKYMODEL > 3.0) {
              ssSetErrorStatus(S,"Error in surfrad: sky model unspecified, diffuse radiation not changed");
              return;
          }
      }
      /* */
      {
          if (GREFLECT < 0.0) {
              ssSetErrorStatus(S,"Error in surfrad: ground reflectance mustbe >= 0");
              return;
          }
      }
  }
#endif /* MDL_CHECK_PARAMETERS */


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
    int_T n;
    
    ssSetNumSFcnParams(S, 2);  /* Number of expected parameters */
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
    ssSetNumDiscStates(S, 0);

    if (!ssSetNumInputPorts(S, 2)) return;
    ssSetInputPortWidth(S, 0, 18);
    ssSetInputPortDirectFeedThrough(S, 0, 1);
    ssSetInputPortWidth(S, 1, 3);
    ssSetInputPortDirectFeedThrough(S, 1, 1);

    if (!ssSetNumOutputPorts(S, 18)) return;
    for (n = 0; n < 18; n++)
        ssSetOutputPortWidth(S, n, 1);

    ssSetNumSampleTimes(S, 1);
    ssSetNumRWork(S, 0);
    ssSetNumIWork(S, 0);
    ssSetNumPWork(S, 0);
    ssSetNumModes(S, 0);
    ssSetNumNonsampledZCs(S, 0);
	
	ssSetSimStateCompliance(S, USE_DEFAULT_SIM_STATE);
    ssSetSimStateVisibility(S, 1);
    
    ssSupportsMultipleExecInstances(S, true);

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
    InputRealPtrsType uPtrs0  = ssGetInputPortRealSignalPtrs(S,0);
    InputRealPtrsType u1      = ssGetInputPortRealSignalPtrs(S,1);
    
    real_T *y0 = ssGetOutputPortRealSignal(S, 0);
    real_T *y1 = ssGetOutputPortRealSignal(S, 1);
    real_T *y2 = ssGetOutputPortRealSignal(S, 2);
    real_T *y3 = ssGetOutputPortRealSignal(S, 3);
    real_T *y4 = ssGetOutputPortRealSignal(S, 4);
    real_T *y5 = ssGetOutputPortRealSignal(S, 5);
    real_T *y6 = ssGetOutputPortRealSignal(S, 6);
    real_T *y7 = ssGetOutputPortRealSignal(S, 7);
    real_T *y8 = ssGetOutputPortRealSignal(S, 8);
    real_T *y9 = ssGetOutputPortRealSignal(S, 9);
    real_T *y10= ssGetOutputPortRealSignal(S, 10);
    real_T *y11= ssGetOutputPortRealSignal(S, 11);
    real_T *y12= ssGetOutputPortRealSignal(S, 12);
    real_T *y13= ssGetOutputPortRealSignal(S, 13);
    real_T *y14= ssGetOutputPortRealSignal(S, 14);
    real_T *y15= ssGetOutputPortRealSignal(S, 15);
    real_T *y16= ssGetOutputPortRealSignal(S, 16);
    real_T *y17= ssGetOutputPortRealSignal(S, 17);

    real_T time = TIME;
    int_T skymodel = (int_T)SKYMODEL;
    real_T idir_sun_h, idir_sun_n, idfu_sun_h;
    
    real_T tetatrans = -9999.0; /* incidence angle transversal coll. plane */
    real_T tetalong  = -9999.0; /* incidence angle longitudinal coll. plane */
    real_T costeta   = 0.0;     /* incidence angle collector plane */
    real_T idir_t    = 0.0;     /* direct radiation on surface */
    real_T idfu_t    = 0.0;     /* diffuse radiation on surface */
    real_T iextra_n  = 0.0;     /* extraterrestrial radiation on horizontal */
    
    real_T as, zs, rc, zc, ac, rb;
    real_T szc, czs, szs, czc, src, crc, sda, cda;
    
    real_T clearness, F1, F2, a, b, f11, f12, f13, f21, f22, f23, brightness; 	/* parameters Perez model */
    real_T z3;                  /* dummy for zenith^3 */
 	
    /* initialisation of variables */
    idir_sun_n = *uPtrs0[3];    /* direct normal beam radiation */
    idfu_sun_h = *uPtrs0[4];    /* diffuse radiation on horizontal */
    
    if(ZENITH == -9999.0 || AZIMUT == -9999.0) 
    {
        ssSetErrorStatus(S,"surfrad: weather data does not include sunposition.");
        return;
    }
    
    as = DEG2RAD * AZIMUT;
    zs = DEG2RAD * ZENITH;
    zc = DEG2RAD * COLANGLE;
    ac = DEG2RAD * COLAZIMUT;
    rc = DEG2RAD * COLROTATE;
    
    szs = sin(zs);      /* sine ZENITH angle of sun */
    czs = cos(zs);      /* cosine ZENITH angle of sun */
    sda = sin(as-ac);   /* difference of azimut */
    cda = cos(as-ac);
    szc = sin(zc);      /* sine ZENITH angle of collector (inclination) */
    czc = cos(zc);      /* cosine ZENITH angle of collector (inclination) */
    src = sin(rc);      /* sine rotation angle of collector */
    crc = cos(rc);      /* cosine rotation angle of collector */
    
    if (czs < 1.0e-3)   /* no sun */
    {
        tetalong = 90.0;
        tetatrans = 90.0;
    } 
    else                /* sun is there */
    {
        /* extraterrestrial radiation on normal (from carlib function) */
        iextra_n = extraterrestrial_radiation(time);
        
        /* cos of incidence angle on surface */
        costeta = src*sda*szs+crc*(szc*cda*szs+czc*czs);
        /* incidence angle in longitudinal collector plane (direction riser - vertical on window) */
        tetalong = acos(costeta/sqrt(square(czc*cda*szs-szc*czs)+square(costeta)));
        /* incidence angle in transversal collector plane (direction header - vertical on window) */
        tetatrans = acos(costeta/sqrt(square(crc*sda*szs-src*(szc*cda*szs+czc*czs))+square(costeta)));
    
        /* ---- radiation on tilted surface ----- */
        rb = costeta/czs;                                           /* ratio of direct radiation */
        idir_sun_h = idir_sun_n*czs;                                /* direct radiation on horizontal */
        idfu_t = (idfu_sun_h + idir_sun_h)*0.5*GREFLECT*(1.0-czc);  /* reflected from ground */
    
        switch (skymodel)       /* diffuse radiation on surface depends on sky model */
        {
            case 1:             /* isotropic sky model */
                idfu_t += 0.5*idfu_sun_h*(1.0+czc);
                break;
            case 2:             /* Hay Davies sky model */
                idfu_t += idfu_sun_h*((1.0-idir_sun_n/iextra_n)*0.5*(1.0+czc) + rb*idir_sun_n/iextra_n);
                break;
            case 3:             /* Perez sky model */
                /* Testdataset from example 2.16.2 of Duffie Beckmann, 2006, p.95) */
                /* czs = 0.466; zenith = 62.2; zs = DEG2RAD*62.2; rb = 1.71; time = 4352400; idfu_t = 0.787; costeta = 0.799 */
                
                a = max(0.0,costeta); 
                b = max(cos(DEG2RAD*85),cos(zs));

                /* clearness = ((idfu_t + idir_sun/czs)/idfu_sun + 5.535*1e-6*pow(zenith,3))/(1+5.535*1e-6*pow(zenith,3)); */ /* test example */
                z3 = ZENITH*ZENITH*ZENITH;
                clearness = ((idfu_sun_h + idir_sun_n)/idfu_sun_h + 5.535*1e-6*z3)/(1+5.535*1e-6*z3); 
                
                /* determination of brightness coefficients from Duffie-Beckman (2006) referring to Perez (1990) */	
                if (clearness <= 1.065) {
                    f11 = -0.008; f12 =  0.588; f13 = -0.062; f21 = -0.060; f22 = 0.072; f23 = -0.022;
                } else if (clearness <= 1.23) {
                    f11 =  0.130; f12 =  0.683; f13 = -0.151; f21 = -0.019; f22 = 0.066; f23 = -0.029;
                } else if (clearness <= 1.5) {	
                    f11 =  0.330; f12 =  0.487; f13 = -0.221; f21 =  0.055; f22 =-0.064; f23 = -0.026;
                } else if (clearness <= 1.95) {
                    f11 =  0.568; f12 =  0.187; f13 = -0.295; f21 =  0.109; f22 =-0.152; f23 =  0.014;
                } else if (clearness < 2.8) {	
                    f11 =  0.873; f12 = -0.392; f13 = -0.362; f21 =  0.226; f22 =-0.462; f23 =  0.001;
                } else if (clearness < 4.5) {
                    f11 =  1.132; f12 = -1.237; f13 = -0.412; f21 =  0.288; f22 =-0.823; f23 =  0.056;
                } else if (clearness < 6.2) {
                    f11 =  1.060; f12 = -1.600; f13 = -0.359; f21 =  0.264; f22 =-1.127; f23 =  0.131;
                } else {
                   f11 =  0.678; f12 = -0.327; f13 = -0.250; f21 =  0.156; f22 =-1.377; f23 =  0.251;
                }

                brightness = 1.0/czs * idfu_sun_h/iextra_n;
	            F1 = max(0.0,(f11 + f12*brightness + f13*zs));
                F2 = (f21 + f22*brightness + f23*zs);

		        /* calculation of diffuse */
          	    idfu_t += idfu_sun_h*((1.0-F1)*0.5*(1.0+czc) + F1*a/b + F2*szc);
                break;
            default: /* no sky model */
                idfu_t += idfu_sun_h;
                break;
        }
        /* limited to iextra_n to avoid peaks at high ZENITH angles of sun */
        idfu_t = min(iextra_n, idfu_t);  /* diffuse radiation on surface  */
       
        /* direct radiation on surface  */
        idir_t = min(iextra_n, idir_sun_n*costeta);
        
    } /* end if csz > 1e-5, check for sunset */
    
    /* ----- set outputs ----- */
    y0[0]  = *uPtrs0[0];                        /*  1   timevalue (comment line) format YYYYMMDDHHMM        -               */
    y1[0]  = *uPtrs0[1];                        /*  2   zenith angle of sun (at time, not averaged)         degree          */
    y2[0]  = *uPtrs0[2];                        /*  3   azimuth angle of sun (0°=south, east negative)      degree          */
    y3[0]  = idir_sun_n;                        /*  4   direct beam solar radiation on a normal surface     W/m^2           */
    y4[0]  = idfu_sun_h;                        /*  5   diffuse solar radiation on a horizontal surface     W/m^2           */
    y5[0]  = *uPtrs0[5];                        /*  6   ambient temperature                                 degree celsius  */
    y6[0]  = *uPtrs0[6];                        /*  7   radiation temperature of sky                        degree celsius  */
    y7[0]  = *uPtrs0[7];                        /*  8   relative humidity                                   percent         */
    y8[0]  = *uPtrs0[8];                        /*  9   precipitation                                       m/s             */
    y9[0]  = *uPtrs0[9];                        /* 10   cloud index (0=no cloud, 1=covered sky)             -               */    
    y10[0] = *uPtrs0[10];                       /* 11   station pressure                                    Pa              */    
    y11[0] = *uPtrs0[11];                       /* 12   mean wind speed                                     m/s             */
    y12[0] = *uPtrs0[12];                       /* 13   wind direction (north=0° west=270°)                 degree          */
    y13[0] = min(90.0, RAD2DEG*acos(costeta));  /* 14   incidence angle on surface (0° = vertical)          degree          */
    y14[0] = min(RAD2DEG*tetalong, 90.0);       /* 15   longitudinal incidence angle                        degree          */
    y15[0] = min(RAD2DEG*tetatrans, 90.0);      /* 16   transversal incidence angle                         degree          */
    y16[0] = max(0.0, idir_t);                  /* 17   direct solar radiation on surface                   W/m^2           */
    y17[0] = max(0.0, idfu_t);                  /* 18   diffuse solar radiation on surface                  W/m^2           */
    
} // end mdlOutputs


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
 *    allocated in mdlStart, this is the place to free it.
 */
static void mdlTerminate(SimStruct *S)
{
}


/*======================================================*
 * See sfuntmpl_doc.c for the optional S-function methods *
 *======================================================*/

/*=============================*
 * Required S-function trailer *
 *=============================*/

#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif

