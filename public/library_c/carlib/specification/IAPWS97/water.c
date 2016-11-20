/***********************************************************************
 * This file is part of the CARNOT Blockset.
 *
 *  CARNOT is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU Lesser General Public License as 
 *  published by the Free Software Foundation, either version 3 of the 
 *  License, or (at your option) any later version.
 *
 *  CARNOT is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU Lesser General Public License for more details.
 *
 *  You should have received a copy (copying_lesser.txt) of the GNU Lesser
 *  General Public License along with CARNOT.
 *  If not, see <http://www.gnu.org/licenses/>.
 *
 ***********************************************************************
 *  M O D E L    O R    F U N C T I O N
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * s-function rhofluid: density in kg/m^3
 *
 * Version  Author          Changes                                 Date
 * 0.4.0    rhh             created                                 jul98
 * 0.11.0   hf              changed to level2 s-function            28jan99
 * 1.0.0    pc              Tyfocor LS added                        18apr2011
 */


#define S_FUNCTION_NAME water
#define S_FUNCTION_LEVEL 2

#include "simstruc.h"

#include "water_properties.h"


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
	ENTHALPY2TEMPERATURE
};


/* Function: mdlInitializeSizes ===============================================
 * Abstract:
 *   Setup sizes of the various vectors.
 */
static void mdlInitializeSizes(SimStruct *S)
{
    ssSetNumSFcnParams(S, 1);
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
        return; /* Parameter mismatch will be reported by Simulink */
    }

    ssSetNumContStates(S, 0);
    ssSetNumDiscStates(S, 0);

    if (!ssSetNumInputPorts(S, 2)) return;

    ssSetInputPortWidth(S, 0, 1);
    ssSetInputPortDirectFeedThrough(S, 0, 1);
    ssSetInputPortWidth(S, 1, 1);
    ssSetInputPortDirectFeedThrough(S, 1, 1);

    if (!ssSetNumOutputPorts(S,1)) return;
    ssSetOutputPortWidth(S, 0, 1);

    ssSetNumSampleTimes(S, 1);
    ssSetNumRWork(S, 0);
    ssSetNumIWork(S, 0);
    ssSetNumPWork(S, 0);
    ssSetNumModes(S, 0);
    ssSetNumNonsampledZCs(S, 0);

#ifdef  EXCEPTION_FREE_CODE
    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE);
#endif
}


/* Function: mdlInitializeSampleTimes =========================================
 * Abstract:
 *    Specifiy that we inherit our sample time from the driving block.
 */
static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, 0.0);
}


/* Function: mdlOutputs =======================================================
 */
static void mdlOutputs(SimStruct *S, int_T tid)
{
    InputRealPtrsType t             = ssGetInputPortRealSignalPtrs(S,0);
    InputRealPtrsType p             = ssGetInputPortRealSignalPtrs(S,1);
    real_T *y                       = ssGetOutputPortRealSignal(S,0);
    water_properties_region region  = water_properties_get_region(*t[0], *p[0]);
    
    switch((int)(*mxGetPr(ssGetSFcnParam(S,0))))
    {
        case DENSITY :
            y[0]=1.0/water_properties_specific_volume(region, *t[0], *p[0]);
            break;
        case HEAT_CAPACITY :
            y[0]=water_properties_specific_isobaric_heat_capacity(region, *t[0], *p[0]);
            break;
        case THERMAL_CONDUCTIVITY :
            y[0]=water_properties_thermal_conductivity(*t[0], *p[0]);
            break;
        case VISCOSITY :
            y[0]=water_properties_dynamic_viscosity(*t[0], *p[0])*water_properties_specific_volume(region, *t[0], *p[0]);
            break;
        case ENTHALPY :
            y[0]=water_properties_specific_enthalpy(region, *t[0], *p[0]);
            break;
        case ENTROPY :
            y[0]=water_properties_specific_entropy(region, *t[0], *p[0]);
            break;
        case PRANDTL :
            y[0] = water_properties_dynamic_viscosity(*t[0], *p[0]) *
                   water_properties_specific_isobaric_heat_capacity(region, *t[0], *p[0]) /
                   water_properties_thermal_conductivity(*t[0], *p[0]);
            break;
        case SPECIFIC_VOLUME :
            y[0]=water_properties_specific_volume(region, *t[0], *p[0]);
            break;
        case EVAPORATION_ENTHALPY :
            y[0] = water_properties_specific_enthalpy(water_properties_get_region(*t[0]+0.1, water_properties_ps(*t[0])), *t[0]+0.1, water_properties_ps(*t[0])) -
                   water_properties_specific_enthalpy(water_properties_get_region(*t[0]-0.1, water_properties_ps(*t[0])), *t[0]-0.1, water_properties_ps(*t[0]));
            break;
        case VAPOURPRESSURE :
            y[0]=water_properties_ps(*t[0]);
            break;
        case SATURATIONTEMPERATURE :
            y[0]=water_properties_Ts(*p[0]);
            break;
        case SATURATIONPROPERTY :
            y[0]=-1.0;
            break;
        case TEMPERATURE_CONDUCTIVITY :
            y[0] = water_properties_specific_volume(region, *t[0], *p[0]) *
                   water_properties_thermal_conductivity(*t[0], *p[0]) /
                   water_properties_specific_isobaric_heat_capacity(region, *t[0], *p[0]);
            break;
        case ENTHALPY2TEMPERATURE :
            y[0]=-1.0;
            break;
        default :
            y[0] = -2.0;
            break;
    }
    

   
    
    
    
    
}


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
