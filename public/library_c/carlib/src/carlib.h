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
 * carlib.h     
 *      
 *  Prototypes of globaly accessable functions from
 *  "carlib.c"
 *      
 * version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
 *
 * author list:     cw -> Carsten Wemhoener
 *                  hf -> Bernd Hafner
 *                  tw -> Thomas Wenzel
 *                  gf -> Gaelle Faure
 *                  pc -> Pierre Charles
 *                  aw -> Arnold Wohlfeil
 *                  mp -> Marcel Paasche
 *
 * Copyright (c) by the authors, all Rights Reserved
 *
 *  Version Author  Changes                                       Date      
 *  0.4.0   rhh     created                                       03feb98   
 *  0.11.0  cw      extension of water and steam                  02march99 
 *  3.1.0   hf      including extraterrestrial radiation          25dec2008
 *  3.1.1   gf      added temperature unit conversion             21jan2010
 *  4.1.0   hf      definition of PI only if not done by math.h   20jan2011
 *  4.1.1   gf      return nb iterations in enthalpy2temperature  08nov2011
 *                  to enable the test of too many iterations   
 *  5.2.1   hf      added constants SIGMA_STEFAN_BOLTZMANN, ...   16nov2012
 *  5.2.2   hf      added function solve_massflow_equation        12mar2013
 *  5.2.3   hf/aw   added declaration of mixViscosity             06jun2013
 *  5.2.4   hf/aw   several defines replaced by enums             21aug2013
 *  6.1.1   aw      MAXSATTEMPDEV added                           31oct2013
 *  6.1.2   hf      rangecheck added                              02nov2013
 *  6.1.3   aw      message management added                      02apr2014
 *                  simstruc.h and ssPrintf included
 *  6.1.4   hf      added enum for rangecheck
 *  6.1.5   hf      diameterchange removed                        24apr2014
 *  6.1.6   aw      message management updated                    03jun2014
 *                  include simstruc.c in ifdef
 *  6.1.7   aw      new fluids: constant water and air            03jul2014
 *  6.1.8   hf      added property GRASHOFNUMBER, PRANDTLNUMBER   14jul2014
 *  6.2.0   mp      solve_massflow_equation replaced by           02sep2014
 *                  solve_quadratic_equation
 *  6.2.1   aw      added macros for mix / max                    20aug2015
 *  6.3.0   hf      included solar_postion, removed global_memory 16sep2015
 *                  cs_energy_cogen commented out
 *  6.3.1   hf      cs_energy_cogen removed                       29nov2015
 *                  added declaration of solve_quadratic_equation 
 */
 

#ifdef MATLAB_MEX_FILE
    #include "simstruc.h"
#endif
#include "tmwtypes.h"

#ifndef carlib_h
#define carlib_h

/* workaround for rapid accelerator mode */
#ifndef ssPrintf
    #define ssPrintf printf
#endif

#define EXCEPTION_FREE_CODE


#define NO_MASSFLOW             1.0e-9             /* check for massflow = 0: mdot < NO_MASSFLOW   */
#define DEG2RAD                 0.017453292519943   /* Matlab value for long pi/180                 */
#define RAD2DEG                 57.29577951308232   /* Matlab value for long 180/pi                 */
#define C_GRAVITATION           9.81                /* m/s²                                         */
#define SIGMA_STEFAN_BOLTZMANN  5.67e-8             /* W/(m^2 * K^4)                                */
#define SECONDSPERDAY           86400.0             /* result of 365*24*3600                        */

#ifndef PI
    #ifdef M_PI
        #define PI      M_PI                   /* definition in math.h */
    #else
        #define PI      3.141592653589793      /* Matlab value for long */
    #endif
#endif

/* define macros for mix and max if not done by the compiler*/
#ifndef max	
	#define max(x,y) ((x)>(y)?(x):(y))
#endif
#ifndef min
	#define min(x,y) ((x)<(y)?(x):(y))
#endif
        
/* definition of fluid_types (fluid ID) */
enum FLUID
{
    WATER = 1,
    AIR,
    COTOIL,
    SILOIL,
    WATERGLYCOL,
    TYFOCOR_LS,
    WATER_CONSTANT,
    AIR_CONSTANT
};

/* definition of property_types (property ID) */
enum PROPERTY
{
    DENSITY = 1,
    HEAT_CAPACITY,
    THERMAL_CONDUCTIVITY,
    VISCOSITY,
    ENTHALPY,
    ENTROPY,
    PRANDTL,
    SPECIFIC_VOLUME,
    EVAPORATION_ENTHALPY,
    VAPOURPRESSURE,
    SATURATIONTEMPERATURE,
    SATURATIONPROPERTY,
    TEMPERATURE_CONDUCTIVITY,
    ENTHALPY2TEMPERATURE,
    GRASHOFNUMBER,
    PRANDTLNUMBER,
    VAPOURCONTENT
};



/* definition of solar calculation */
enum SOLAR
{
    EXTRATERRARADIATION = 1,
    DECLINATION,
    SOLARTIME,
    SOLARPOSITION
};



/* definition of fluid_phase (phase ID) */
enum PHASE
{
    VAPOROUS = 1,
    LIQUID,
    SOLID
};


/* definitions for the message management */
enum MESSAGELEVEL
{
    MESSAGELEVELDEBUG = 1,
    MESSAGELEVELINFO,
    MESSAGELEVELWARNING,
    MESSAGELEVELERROR,
    MESSAGELEVELFATAL,
    MESSAGELEVELNONE
};



enum MESSAGEPRINT
{
    MESSAGEPRINTNONE,
    MESSAGESUPPRESSED,
    MESSAGEPRINTPROMPT,
    MESSAGEPRINTFILE,
    MESSAGEPRINTPROMPTANDFILE
};

/* definition of rangecheck errors */
enum RANGECHECKERRORS
{
    RANGEISCORRECT         = 0,
    FUNCTIONNOTAVAILABLE   = 1,
    TEMPERATUREOUTOFRANGE  = 2,
    PRESSUREOUTOFRANGE     = 4,
    MIXTUREOUTOFRANGE      = 8
};



#define ABS(x)  ((x)<0)? (-x):(x)
#define MAX(x,y) ((x)>(y)?(x):(y))
#define MIN(x,y) ((x)<(y)?(x):(y))


/* Definition der definierten, konstanten Groessen aus VDI 63:                   */

#define TA0                 (double)273.15      /* Umrechnung t + ta0 von [C] in [K]            */
#define TAT_WATER           (double)273.16      /* Absolut-Temperatur im Tripel-Punkt [K]       */
#define TAK_WATER           (double)647.3       /* Absolut-Temperatur im kritischen Punkt [K]   */
#define PRESSKRIT           (double)22128700.0  /* absoluter Druck im kritischen Punkt [Pa]     */
#define TEMPKRIT            (double)374.15      /* Temperature of critical point [°C]           */
#define R_WATER             (double)461.528     /* Gaskonstante Wasserdampf [J/kg/K]            */
#define FPABAR              (double)1.0e5       /* Umrechnungsfaktor von [Pa] in [bar]          */
#define STEFAN_BOLTZMANN    (double)5.6697e-8   /* Stefan-Boltzmann constant in [W/(m^2*K^4)]   */
#define RGRD                (double)0.6221      /* RG/RD = 287.1/461.5 = 0.622101841820152 */
#define MAXSATTEMPDEV       (double)0.02        /* max deviation of the vapour pressure curce [K] */

/* declaration of funcitons - in alphabetica order */
extern double density(double, double, double, double);
extern double density_solid(double, double);
extern double enthalpy(double, double, double, double);
extern double entropy(double, double, double, double);
extern double evaporation_enthalpy(double, double, double, double);
extern double* enthalpy2temperature(double, double, double, double);
extern double extraterrestrial_radiation(double);
extern double grashof(double, double, double, double, double, double);
extern double heat_capacity(double, double, double, double);
extern double heat_capacity_solid(double, double);
extern double mixViscosity(double, double, double, double);
extern double prandtl(double, double, double, double);
extern double relativeHumidity2waterContent(double, double, double);
extern double reynolds(double, double, double, double, double, double);
extern double saturationproperty(double, double, double, double, double, double);
extern double saturationtemperature(double, double, double, double);
extern double square(double);
extern double specific_volume (double, double, double, double);
extern double saturationproperty(double, double, double, double, double, double);
extern double solar_declination(double);
extern double solar_time(double, double, double);
extern void   solar_position(real_T *, real_T, real_T, real_T, real_T);
extern void   solve_quadratic_equation(double *, double, double, double);
extern double thermal_conductivity_solid(double, double);
extern double thermal_conductivity(double, double, double, double);
extern double temperature_conductivity(double, double, double, double);
extern double unitconv_temp(int, int, double);
extern double vapourcontent(double, double, double, double, double, int);
extern double vapourpressure(double, double, double, double);
extern double viscosity(double, double, double, double);
extern double waterContent2relativeHumidity(double, double, double);

int           printmessage(const char *message, const char *origin, 
                double time, int levelofmessage, int levelofblock, 
                unsigned int *totalmessages, double maxtotalmessages, 
                unsigned int *consecutivemessages, double maxconsecutivemessages, 
                int writetofile, const char *filename);
extern int    rangecheck(int, double, double, double, double);

#endif


