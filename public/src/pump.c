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
 * calculate massflow according to pump characteristic
 *
 * compiler call from Matlab: mex pump.c carlib.c
 *
 * structure of u (input vector)
 *  see defines below
 *
 * structure of y (output vector)
 *  index   use
 *  0       new massflow
 *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *  history
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * author list:     aw -> Arnold Wohlfeil
 *                  hf -> Bernd Hafner
 *                  pahm -> Marcel Paasche
 *
 * version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
 *
 * Version  Author  Changes                                     Date
 * 0.8.0    hf      created                                     23jun98
 * 0.8.1    hf      new pressure drop calculation               28jun98
 *                      dp = dp0 + dp1*mdot + dp2*mdot^2
 *                      solve: dp = a0 + a1*mdot + a2*mdot^2
 * 5.3.0    hf      included pump characteristics
 * 6.1.0    PahM    adopted streamlined sFun-style (timestwo.c) 12aug14
 * 6.1.2    PahM    solve_quadratic_equation instead of         25aug2014
 *                  solve_masslflow_equation
 * 6.1.3    aw      SimStateCompiliance and                     11aug2015
 *                  MultipleExecInstances activated
 * 6.1.4    hf      SS_OPTION_USE_TLC_WITH_ACCELERATOR and      29nov2015
 *                  SS_OPTION_WORKS_WITH_CODE_REUSE removed
 *                  included EXCEPTION_FREE_CODE from carlib.h
 */

#define S_FUNCTION_NAME pump
#define S_FUNCTION_LEVEL 2

#include "simstruc.h"

#include "carlib.h"     /* for some specific defines in Carnot */

#define ID      (*uPtrs[0])        /* flow identifier */
#define DPCON   (*uPtrs[1])        /* constant pressure drop term */
#define DPLIN   (*uPtrs[2])        /* linear pressure drop term */
#define DPQUA   (*uPtrs[3])        /* quadratic pressure drop term */
#define PUCON   (*uPtrs[4])        /* pump: constant pressure */
#define PULIN   (*uPtrs[5])        /* pump: slope of pressure with mdot */
#define PUQUA   (*uPtrs[6])        /* pump: quadratic term of p with mdot */

/*================*
 * Build checking *
 *================*/


/* Function: mdlInitializeSizes ===============================================
 * Abstract:
 *   Setup sizes of the various vectors.
 */
static void mdlInitializeSizes(SimStruct *S)
{
    ssSetNumSFcnParams(S, 0);
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S))
    {
        return; /* Parameter mismatch will be reported by Simulink */
    }

    if (!ssSetNumInputPorts(S, 1))
    {
        return;
    }
    ssSetInputPortWidth(S, 0, 7);
    ssSetInputPortDirectFeedThrough(S, 0, 1);
    
    if (!ssSetNumOutputPorts(S,1))
    {
        return;
    }
    ssSetOutputPortWidth(S, 0, 1);

    ssSetNumSampleTimes(S, 1);

    /* specify the sim state compliance to be same as a built-in block */
    ssSetSimStateCompliance(S, USE_DEFAULT_SIM_STATE);

    //     ssSetOptions(S,
    //                  SS_OPTION_WORKS_WITH_CODE_REUSE |
    //                  SS_OPTION_EXCEPTION_FREE_CODE |
    //                  SS_OPTION_USE_TLC_WITH_ACCELERATOR);
    #ifdef EXCEPTION_FREE_CODE
    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE);
    #endif
    
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
    ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, 0.0);
    ssSetModelReferenceSampleTimeDefaultInheritance(S); 
}


/* Function: mdlOutputs =======================================================
 * Abstract:
 *    compute the outputs
 */
static void mdlOutputs(SimStruct *S, int_T tid)
{
    InputRealPtrsType uPtrs = ssGetInputPortRealSignalPtrs(S,0);
    real_T            *y    = ssGetOutputPortRealSignal(S,0);
    
    real_T  a, b, c;
    real_T  x12[2];     // array for mdot calculation

    if (ID < 0.0) /* negative ID means pipes are closed by valve */
    {
        y[0] = 0.0;
    }
    else
    {
        a = PUQUA - DPQUA;
        b = PULIN - DPLIN;
        c = PUCON - DPCON;
        solve_quadratic_equation(x12, a, b, c);    // return by reference: solutions are returned in the array of pointer *x12
        
        if (x12[0] < 0.0)
        {
            y[0] = max(0.0, x12[1]);    // max in case both are negative
        }
        else if (x12[1] < 0.0)
        {
            y[0] = max(0.0, x12[0]);    // max in case both are negative
        }
        else
        /* both x12 >= 0
         * unless both are 0, this is only possible for
         * a) a < 0, b > 0, c <= 0
         * b) a > 0, b < 0, c >= 0
         * modelling hydraulics, we expect
         * for pumps:       qua <= 0, lin <= 0, c > 0
         * for resistances: qua >= 0, lin >= 0, c = 0 (or c > 0)
         * since resistances are subracted, we should only get a <= 0, b <= 0
         * thus this else case should never occur for the pump! */
        {
            if (b <= 0.0)
            {
                y[0] = min(x12[0], x12[1]); // something went wrong, better use small solution
            }
            else
            {
                y[0] = max(x12[0], x12[1]); // somethings really messed up but the solution "behind the hill" is probably more reasonable
            }
        }
        
        if (y[0] < NO_MASSFLOW)
        {
            y[0] = 0.0;
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

