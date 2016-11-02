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
 * s-function specific volume in m^3/kg
 *
 * author list:     cw -> Carsten Wemhoener
 *                  pc -> Pierre Charles
 *                  aw -> Arnold Wohlfeil
 *                  hf -> Bernd Hafner
 *
 * version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
 * Version  Author          Changes                                 Date
 * 0.11.0   cw              created                                 mai99
 * 1.0.0    pc              tyfocor LS added                        18apr2011
 * 2.0.0    aw              message management added                01apr2014
 * 2.0.1    aw              message management updated              03jun2014
 * 6.1.0    hf              changed temperature input to vector     09jul2014
 *                          int_T chk = rangecheck() should be integrated
 * 6.1.1    aw              set mdlInitializeConditions static      11nov2014
 *                          added SimStateCompiliance
 *                          ssSupportsMultipleExecInstances enabled
 * 6.1.2    aw              added                                   29jan2015
 *                          ssSetOptions(S,
 *                          SS_OPTION_DISALLOW_CONSTANT_SAMPLE_TIME)
 */


#define S_FUNCTION_NAME specivol
#define S_FUNCTION_LEVEL 2

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "simstruc.h"
#include "carlib.h"


#define MESSAGELEVELBLOCK           (int)(*mxGetPr(ssGetSFcnParam(S,0))) /* error level of the block */
#define NOTOTALWARNINGS             (*mxGetPr(ssGetSFcnParam(S,1))) /* total number of warnings [1] */
#define NOCONSECUTIVEWARNINGS       (*mxGetPr(ssGetSFcnParam(S,2))) /* consecutive number of warnings [1] */
#define WRITETOFILE                 (int)(*mxGetPr(ssGetSFcnParam(S,3))) /* write to file */
#define FILENAME                    (*mxGetPr(ssGetSFcnParam(S,4))) /* filename */


#define DWORK_FILENAME                    (char*)ssGetDWork(S, 0) /* filename */
#define DWORK_ORIGIN                      (char*)ssGetDWork(S, 1) /* name of the current file */
#define DWORK_PRINTEDTOTALWARNINGS        (uint32_T*)ssGetDWork(S, 2) /* number of total printed warnings */
#define DWORK_PRINTEDCONSECUTIVEWARNINGS  (uint32_T*)ssGetDWork(S, 3) /* number of consecutive printed warnings */


/* Function: mdlInitializeSizes ===============================================
 * Abstract:
 *   Setup sizes of the various vectors.
 */
static void mdlInitializeSizes(SimStruct *S)
{
    ssSetNumSFcnParams(S, 5);
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S))
    {
        return; /* Parameter mismatch will be reported by Simulink */
    }

    ssSetNumContStates(S, 0);
    ssSetNumDiscStates(S, 0);

    if (!ssSetNumInputPorts(S, 4)) return;

    ssSetInputPortWidth(S, 0, 1);                   /* fluid */
    ssSetInputPortDirectFeedThrough(S, 0, 1);
    ssSetInputPortWidth(S, 1, 1);                   /* mixture */
    ssSetInputPortDirectFeedThrough(S, 1, 1);
    ssSetInputPortWidth(S, 2, DYNAMICALLY_SIZED);   /* Temperature */
    ssSetInputPortDirectFeedThrough(S, 2, 1);
    ssSetInputPortWidth(S, 3, 1);                   /* Pressure */
    ssSetInputPortDirectFeedThrough(S, 3, 1);

    if (!ssSetNumOutputPorts(S,1)) return;

    ssSetOutputPortWidth(S, 0, DYNAMICALLY_SIZED);

    ssSetOutputPortReusable(S, 0, 1);
    
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
    
    ssSetNumSampleTimes(S, 1);
    ssSetNumRWork(S, 0);
    ssSetNumIWork(S, 0);
    ssSetNumPWork(S, 0);
    ssSetNumModes(S, 0);
    ssSetNumNonsampledZCs(S, 0);

    #ifdef  EXCEPTION_FREE_CODE
        ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE);
    #endif
        
    ssSetOptions(S, SS_OPTION_DISALLOW_CONSTANT_SAMPLE_TIME);
    
    ssSetSimStateCompliance(S, USE_DEFAULT_SIM_STATE);
    ssSetSimStateVisibility(S, 1);
    
    ssSupportsMultipleExecInstances(S, true);
}

#define MDL_INITIALIZE_CONDITIONS
static void mdlInitializeConditions(SimStruct *S)
{   
    uint32_T *D2 = DWORK_PRINTEDTOTALWARNINGS;
    uint32_T *D3 = DWORK_PRINTEDCONSECUTIVEWARNINGS;
    
    
    mxGetString((ssGetSFcnParam(S, 4)), DWORK_FILENAME, (int)(mxGetN(ssGetSFcnParam(S, 4))+1)*sizeof(mxChar)); 
    
    sprintf(DWORK_ORIGIN, "%s/%s.c",ssGetPath(S), ssGetModelName(S));

    D2[0] = (uint32_T)0;
    D3[0] = (uint32_T)0;
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
    InputRealPtrsType id  = ssGetInputPortRealSignalPtrs(S,0);
    InputRealPtrsType mx  = ssGetInputPortRealSignalPtrs(S,1);
    InputRealPtrsType t   = ssGetInputPortRealSignalPtrs(S,2);
    InputRealPtrsType p   = ssGetInputPortRealSignalPtrs(S,3);
    int_T  width          = ssGetOutputPortWidth(S,0);
    real_T *y             = ssGetOutputPortRealSignal(S,0);
    real_T td, pd, idd, mxd;
    int_T n;

    double stateswitch;
    
    char message[500];
    int_T messageset = MESSAGEPRINTNONE;

    td   = *t [0];
    pd   = *p [0];
    idd  = *id[0];
    mxd  = *mx[0];

    for (n = 0; n < width; n++)
    {
        td   = *t [n];
        
        if ((int) (idd+0.5)==WATER || (int) (idd+0.5)==WATERGLYCOL || (int) (idd+0.5)==TYFOCOR_LS)  
        {
            if (mxd>1.0)
            {
                mxd = 1.0;
                sprintf(message,"Mixture has to be in [0..1].\n\tUsing mixture 1.0.\n");
                messageset = printmessage(message, DWORK_ORIGIN, ssGetT(S), MESSAGELEVELWARNING, MESSAGELEVELBLOCK, DWORK_PRINTEDTOTALWARNINGS, NOTOTALWARNINGS, DWORK_PRINTEDCONSECUTIVEWARNINGS, NOCONSECUTIVEWARNINGS, WRITETOFILE, DWORK_FILENAME);
            }
            if (mxd<0.0)
            {
                mxd = 0.0;
                sprintf(message,"Mixture has to be in [0..1].\n\tUsing mixture 0.0.\n");
                messageset = printmessage(message, DWORK_ORIGIN, ssGetT(S), MESSAGELEVELWARNING, MESSAGELEVELBLOCK, DWORK_PRINTEDTOTALWARNINGS, NOTOTALWARNINGS, DWORK_PRINTEDCONSECUTIVEWARNINGS, NOCONSECUTIVEWARNINGS, WRITETOFILE, DWORK_FILENAME);
            }
        }

    
        /* Range check of state variables */
        switch ((int) (idd+0.5))
        {     
            case WATER:
                stateswitch = (int) vapourpressure(idd, mxd, td, pd);
                if (pd < stateswitch) 
                { /* fluid is vaporous */
                    if (td > 800.0)
                    {
                        sprintf(message,"Warning: temperature out of range!\n\tValid temperature range up to 800°C\n");
                        messageset = printmessage(message, DWORK_ORIGIN, ssGetT(S), MESSAGELEVELWARNING, MESSAGELEVELBLOCK, DWORK_PRINTEDTOTALWARNINGS, NOTOTALWARNINGS, DWORK_PRINTEDCONSECUTIVEWARNINGS, NOCONSECUTIVEWARNINGS, WRITETOFILE, DWORK_FILENAME);
                    }
                    if (pd > 4.9033e7)
                    {
                        sprintf(message,"Warning: pressure out of range!\n\tValid pressure range up to 49.055 MPa\n");
                        messageset = printmessage(message, DWORK_ORIGIN, ssGetT(S), MESSAGELEVELWARNING, MESSAGELEVELBLOCK, DWORK_PRINTEDTOTALWARNINGS, NOTOTALWARNINGS, DWORK_PRINTEDCONSECUTIVEWARNINGS, NOCONSECUTIVEWARNINGS, WRITETOFILE, DWORK_FILENAME);
                    }
                } 
                else 
                { /* fluid is liquid */    
                    if (td < 0.0 || td > 200.0)
                    {
                        sprintf(message,"Warning: temperature out of range!\n\tValid temperature range from 0°C to 200°C\n");
                        messageset = printmessage(message, DWORK_ORIGIN, ssGetT(S), MESSAGELEVELWARNING, MESSAGELEVELBLOCK, DWORK_PRINTEDTOTALWARNINGS, NOTOTALWARNINGS, DWORK_PRINTEDCONSECUTIVEWARNINGS, NOCONSECUTIVEWARNINGS, WRITETOFILE, DWORK_FILENAME);
                    }
                    if (pd < 1e3 || pd > 2e6)
                    {
                        sprintf(message,"Warning: pressure out of range!\n\tValid pressure range from 1e3 MPa to 2 MPa\n");
                        messageset = printmessage(message, DWORK_ORIGIN, ssGetT(S), MESSAGELEVELWARNING, MESSAGELEVELBLOCK, DWORK_PRINTEDTOTALWARNINGS, NOTOTALWARNINGS, DWORK_PRINTEDCONSECUTIVEWARNINGS, NOCONSECUTIVEWARNINGS, WRITETOFILE, DWORK_FILENAME);
                    }
                }
                break;
            case AIR: 
                if (pd < 1e7)
                {
                    sprintf(message,"Warning: pressure out of range!\n\tValid pressure up to 10 MPa\n");
                    messageset = printmessage(message, DWORK_ORIGIN, ssGetT(S), MESSAGELEVELWARNING, MESSAGELEVELBLOCK, DWORK_PRINTEDTOTALWARNINGS, NOTOTALWARNINGS, DWORK_PRINTEDCONSECUTIVEWARNINGS, NOCONSECUTIVEWARNINGS, WRITETOFILE, DWORK_FILENAME);
                }
                if (td > 1000)
                {
                    sprintf(message,"Warning: temperature out of range!\n\tValid temperature up to 1000 degrees\n\n");
                    messageset = printmessage(message, DWORK_ORIGIN, ssGetT(S), MESSAGELEVELWARNING, MESSAGELEVELBLOCK, DWORK_PRINTEDTOTALWARNINGS, NOTOTALWARNINGS, DWORK_PRINTEDCONSECUTIVEWARNINGS, NOCONSECUTIVEWARNINGS, WRITETOFILE, DWORK_FILENAME);
                }
                break;
            case COTOIL: case SILOIL: case WATERGLYCOL:
                sprintf(message,"No values available for cottonoil,siliconoil and water glycol so far\n");
                messageset = printmessage(message, DWORK_ORIGIN, ssGetT(S), MESSAGELEVELWARNING, MESSAGELEVELBLOCK, DWORK_PRINTEDTOTALWARNINGS, NOTOTALWARNINGS, DWORK_PRINTEDCONSECUTIVEWARNINGS, NOCONSECUTIVEWARNINGS, WRITETOFILE, DWORK_FILENAME);
                break;
            case TYFOCOR_LS:
                if (td > 120.0 || td<-30.0)
                {
                    sprintf(message,"Warning: temperature out of range!\n\tValid temperature between -30 and 120 °C\n");
                    messageset = printmessage(message, DWORK_ORIGIN, ssGetT(S), MESSAGELEVELWARNING, MESSAGELEVELBLOCK, DWORK_PRINTEDTOTALWARNINGS, NOTOTALWARNINGS, DWORK_PRINTEDCONSECUTIVEWARNINGS, NOCONSECUTIVEWARNINGS, WRITETOFILE, DWORK_FILENAME);
                }
                break;
        }  /* end switch mxd */
      
    
        y[n] = specific_volume(idd,mxd,td,pd);

        if (y[n] < 0.0)
        {
            /* chk = (int_T)rangecheck(SPECIFIC_VOLUME,idd,mxd,td,pd);  */

            sprintf(message,"Error while calculating specific volume!\n\tCheck range of inputs (see manual for range).\n");
            messageset = printmessage(message, DWORK_ORIGIN, ssGetT(S), MESSAGELEVELWARNING, MESSAGELEVELBLOCK, DWORK_PRINTEDTOTALWARNINGS, NOTOTALWARNINGS, DWORK_PRINTEDCONSECUTIVEWARNINGS, NOCONSECUTIVEWARNINGS, WRITETOFILE, DWORK_FILENAME);
        }
        
        if (messageset==MESSAGEPRINTNONE)
        {
            uint32_T *D = DWORK_PRINTEDCONSECUTIVEWARNINGS;
            D[0] = (uint32_T)0;
        }
   } /* end for n */
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

