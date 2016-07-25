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
 * s-function grashofn: grashof number
 *
 * author list:     hf -> Bernd Hafner
 *                  rhh -> Robbi Hoeller
 *                  aw -> Arnold Wohlfeil
 *
 * Version  Author          Changes                             Date
 * 0.4.0    rhh             created                             jul98
 * 0.11.0   hf              changed to level2 s-function        22feb99
 * 1.1.0    aw              message management added            03jul2014
 * 6.1.0    hf              vectorized input Twall              14jul2014
 * 6.1.1    aw              set mdlInitializeConditions static  11nov2014
 *                          added SimStateCompiliance
 *                          ssSupportsMultipleExecInstances enabled
 * 6.1.2    aw              added                               29jan2015
 *                          ssSetOptions(S,
 *                          SS_OPTION_DISALLOW_CONSTANT_SAMPLE_TIME)
 */

#define S_FUNCTION_NAME     grashofn
#define S_FUNCTION_LEVEL    2

#include "tmwtypes.h"
#include "simstruc.h"
#include "carlib.h"

#define MESSAGELEVELBLOCK      		(int)(*mxGetPr(ssGetSFcnParam(S,0))) /* error level of the block */
#define NOTOTALMESSAGES       		(*mxGetPr(ssGetSFcnParam(S,1))) /* total number of messages [1] */
#define NOCONSECUTIVEMESSAGES       (*mxGetPr(ssGetSFcnParam(S,2))) /* consecutive number of messages [1] */
#define WRITETOFILE                 (int)(*mxGetPr(ssGetSFcnParam(S,3))) /* write to file */
#define FILENAME                    (*mxGetPr(ssGetSFcnParam(S,4))) /* filename */


#define DWORK_FILENAME                    (char*)ssGetDWork(S, 0) /* filename */
#define DWORK_ORIGIN                      (char*)ssGetDWork(S, 1) /* name of the current file */
#define DWORK_PRINTEDTOTALMESSAGES        (uint32_T*)ssGetDWork(S, 2) /* number of total printed messages */
#define DWORK_PRINTEDCONSECUTIVEMESSAGES  (uint32_T*)ssGetDWork(S, 3) /* number of consecutive printed messages */


/* Function: mdlInitializeSizes ===============================================
 * Abstract:
 *   Setup sizes of the various vectors.
 */
static void mdlInitializeSizes(SimStruct *S)
{
    int i;

    ssSetNumSFcnParams(S, 5);
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S))
    {
        return; /* Parameter mismatch will be reported by Simulink */
    }

    ssSetNumContStates(S, 0);
    ssSetNumDiscStates(S, 0);

    if (!ssSetNumInputPorts(S, 6))  
        return;
    ssSetInputPortWidth(S, 0, 1);                   /* Fluid Type */
    ssSetInputPortWidth(S, 1, 1);                   /* Fluid Mix */
    ssSetInputPortWidth(S, 2, DYNAMICALLY_SIZED);   /* Wall temperature */
    ssSetInputPortWidth(S, 3, 1);                   /* temperature at infinity */
    ssSetInputPortWidth(S, 4, 1);                   /* pressure */
    ssSetInputPortWidth(S, 5, 1);                   /* characteristic dimension */

    for (i = 0; i < 6; i++)
        ssSetInputPortDirectFeedThrough(S, i, 1);

    if (!ssSetNumOutputPorts(S,1)) 
        return;
    ssSetOutputPortWidth(S, 0, DYNAMICALLY_SIZED);

    ssSetNumSampleTimes(S, 1);
    ssSetNumRWork(S, 0);
    ssSetNumIWork(S, 0);
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
    uint32_T *D2 = DWORK_PRINTEDTOTALMESSAGES;
    uint32_T *D3 = DWORK_PRINTEDCONSECUTIVEMESSAGES;
    
    
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
    InputRealPtrsType tw  = ssGetInputPortRealSignalPtrs(S,2);
    InputRealPtrsType ti  = ssGetInputPortRealSignalPtrs(S,3);
    InputRealPtrsType p   = ssGetInputPortRealSignalPtrs(S,4);
    InputRealPtrsType xc  = ssGetInputPortRealSignalPtrs(S,5);
    real_T *y             = ssGetOutputPortRealSignal(S,0);
    int_T  width = ssGetOutputPortWidth(S,0);
    real_T twd, tinf, pd, idd, mxd, xcd;
    char message[500];
	int_T messageset = MESSAGEPRINTNONE;
    int_T n, chk;

    tinf = *ti[0];
    pd   = *p [0];
    idd  = *id[0];
    mxd  = *mx[0];
    xcd  = *xc[0];
    
    
    for (n = 0; n < width; n++)
    {
        twd  = *tw[n];
        
        chk = (int_T)rangecheck(GRASHOFNUMBER,idd,mxd,twd,pd);
        
        if ((int) (idd+0.5)==WATER || (int) (idd+0.5)==WATERGLYCOL) 
        {
           if (mxd>1.0)
			{
				mxd = 1.0;
				sprintf(message,"Warning: mixture has to be in [0..1].\n\tUsing mixture 1.0\n");
				messageset = printmessage(message, DWORK_ORIGIN, ssGetT(S), MESSAGELEVELWARNING, MESSAGELEVELBLOCK, DWORK_PRINTEDTOTALMESSAGES, NOTOTALMESSAGES, DWORK_PRINTEDCONSECUTIVEMESSAGES, NOCONSECUTIVEMESSAGES, WRITETOFILE, DWORK_FILENAME);
			}
			if (mxd<0.0)
			{
				mxd = 0.0;
				sprintf(message,"Warning: mixture has to be in [0..1].\n\tUsing mixture 0.0\n");
				messageset = printmessage(message, DWORK_ORIGIN, ssGetT(S), MESSAGELEVELWARNING, MESSAGELEVELBLOCK, DWORK_PRINTEDTOTALMESSAGES, NOTOTALMESSAGES, DWORK_PRINTEDCONSECUTIVEMESSAGES, NOCONSECUTIVEMESSAGES, WRITETOFILE, DWORK_FILENAME);
			}
        }
        
        y[n] = grashof(idd, mxd, twd, tinf, pd, xcd);
        
        if (messageset==MESSAGEPRINTNONE)
        {
            uint32_T *D = DWORK_PRINTEDCONSECUTIVEMESSAGES;
            D[0] = (uint32_T)0;
        }
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
