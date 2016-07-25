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
 * mixer for 2 fluid flows
 * Calculate distribution according to the quadratic coefficients in
 * each branch and determine the resistance of the total flow.
 *
 * The pressure drop in each branch is given by:
 * dp1 = c1 + l1*mdot1 + q1*mdot1^2
 * dp2 = c2 + l2*mdot2 + q2*mdot2^2
 * dp1 must be equal to dp2 !
 *
 * mdotsum = mdot1 + mdot2
 * mdot2 = mdotsum-mdot1
 *
 * dp1 = dp2 = c1 + l1*mdot1 + q1*mdotsum^2
 *     = c2 + l2*(mdotsum-mdot1) + q2*(mdotsum-mdot1)^2
 * (q1-q2)*mdot1^2 + (l1+l2+2*q2*mdotsum)*mdot1
 *     +(c1-c2-l2*mdotsum-q2*mdotsum^2) = 0
 * solve for mdot1
 *
 * Resistance of the two branches for the total flow (caculate c, l, q)
 * redo calculation above for 3 artifical total massflows 0.1, 0.2 and 0.3 kg/s
 * mdotS is flow in branch 1 at a total flow of 0.1 kg/s
 * mdotD is flow in branch 1 at a total flow of 0.2 kg/s
 * mdotT is flow in branch 1 at a total flow of 0.3 kg/s
 * (A) pressure drop : dpA = c1 + l1*mdotS + q1*mdotS^2 = c + l*0.1 + q*0.1^2
 * (B) pressure drop : dpB = c1 + l1*mdotD + q1*mdotD^2 = c + l*0.2 + q*0.2^2
 * (C) pressure drop : dpC = c1 + l1*mdotT + q1*mdotT^2 = c + l*0.3 + q*0.3^2
 * -> q = dpC-2*dpB+dp / (2*mdotsum^2)
 *    c = 2*q*mdotsum^2 - dpB + 2*dp
 *    l = (dp - c - q*mdotsum^2)/mdotsum
 *
 * Syntax  [sys, x0] = mix_flow(t,x,u,flag)
 *
 * author list:     cw -> Carsten Wemhoener
 *                  hf -> Bernd Hafner
 *                  tw -> Thomas Wenzel
 *                  gf -> Gaelle Faure
 *                  pahm -> Marce Paasche
 *                  aw -> Arnold Wohlfeil
 *
 * version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
 *
 * Version  Author  Changes                                         Date
 * 0.8.0    hf      created                                         16jul1998
 * 0.10.0   hf      flowID is no longer input, it                   14dec1998
 *                      created algebraic loops
 * 1.0.0    hf      changed if (mdot == 0) to                       16jul1999
 *                      if (mdot < NO_MASSFLOW)
 * 1.1.0    hf      temperatures have continuous states             12aug1999
 * 1.1.1    tw      temperature for mixture of air                  18jan2000
 * 4.1.0    hf      new inports for c,l,q                           21oct2009
 * 4.1.1    gf      correction quadratic coefficient calculus       15oct2010
 * 4.1.2    gf      correction for the beginning of the             17dec2010
 *                      simulation : add the case there is no
 *                      massflow -> fdiv = 0.5
 * 4.1.3    gf      test of too many iterations for                 08nov2011
 *                      enthalpy2temperature
 * 4.1.4    gf      debug call to enthalpy2temperature              17nov2011
 * 5.1.0    hf      separated functions for flow-distribution       09mar2013
 * 5.1.1    hf      new version of resistance calculation           11mar2013
 * 6.1.0    hf      variable "root" removed, not used any more      02jul2014
 * 6.1.1    PahM    streamlined sFun-style (timestwo.c)             12aug2014
 * 6.1.2    PahM    solve_quadratic_equation instead of             19aug2014
 *                  solve_masslflow_equation
 * 6.1.3    hf      comment out SS_OPTION_USE_TLC_WITH_ACCELERATOR  17oct2014
 *                  to be corrected later with lecacy_code
 * 6.1.4    aw      SimStates set visible and                       11aug2015
 *                  MultipleExecInstances activated
 */


#define S_FUNCTION_LEVEL 2
#define S_FUNCTION_NAME  mix_flow

#define ID1         (*u1Ptrs[0])    /* ID 1 */
#define CON1        (*u1Ptrs[1])    /* vector 1 constant (static pressure) */
#define LIN1        (*u1Ptrs[2])    /* vector 1 linear */
#define QUA1        (*u1Ptrs[3])    /* vector 1 quadratic */
#define NIN1                 4

#define ID2         (*u2Ptrs[0])    /* ID 2 */
#define CON2        (*u2Ptrs[1])    /* vector 2 constant (static pressure) */
#define LIN2        (*u2Ptrs[2])    /* vector 2 linear */
#define QUA2        (*u2Ptrs[3])    /* vector 2 quadratic */
#define NIN2                 4

#define OLDMDOT     (*u3Ptrs[0])    /* former vector massflow */
#define OLDCON      (*u3Ptrs[1])    /* former vector linear */
#define OLDLIN      (*u3Ptrs[2])    /* former vector linear */
#define OLDQUA      (*u3Ptrs[3])    /* former vector quadratic */
#define NIN3                 4

/*
 * Need to include simstruc.hfor the definition of the SimStruct and
 * its associated macro definitions.
 */
#include "simstruc.h"
#include "carlib.h"     /* for some specific defines in Carnot */


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
    
    if (!ssSetNumInputPorts(S, 3))
    {
        return;
    }
    ssSetInputPortWidth(S, 0, NIN1);
    ssSetInputPortDirectFeedThrough(S, 0, 1);
    ssSetInputPortWidth(S, 1, NIN2);
    ssSetInputPortDirectFeedThrough(S, 1, 1);
    ssSetInputPortWidth(S, 2, NIN3);
    ssSetInputPortDirectFeedThrough(S, 2, 1);
    
    if (!ssSetNumOutputPorts(S, 2))
    {
        return;
    }
    ssSetOutputPortWidth(S, 0, 3);
    ssSetOutputPortWidth(S, 1, 1);
    
    ssSetNumSampleTimes(S, 1);
    
    /* specify the sim state compliance to be same as a built-in block */
    ssSetSimStateCompliance(S, USE_DEFAULT_SIM_STATE);
    ssSetSimStateVisibility(S, 1);
    
    ssSupportsMultipleExecInstances(S, true);
    
//     ssSetOptions(S,
//             SS_OPTION_WORKS_WITH_CODE_REUSE |
//             SS_OPTION_EXCEPTION_FREE_CODE |
//             SS_OPTION_USE_TLC_WITH_ACCELERATOR);
    ssSetOptions(S,
            SS_OPTION_WORKS_WITH_CODE_REUSE |
            SS_OPTION_EXCEPTION_FREE_CODE);
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
 *    In this function, you compute the outputs of your S-function
 *    block.
 */
static void mdlOutputs(SimStruct *S, int_T tid)
{
    InputRealPtrsType u1Ptrs = ssGetInputPortRealSignalPtrs(S,0);
    InputRealPtrsType u2Ptrs = ssGetInputPortRealSignalPtrs(S,1);
    InputRealPtrsType u3Ptrs = ssGetInputPortRealSignalPtrs(S,2);
    real_T *y1               = ssGetOutputPortRealSignal(S,0);
    real_T *y2               = ssGetOutputPortRealSignal(S,1);
    
    real_T x12_1[2], mdot1;
    real_T  x12_T[2], mdotT[3], dpT[3];
    real_T c1, l1, q1, c2, l2, q2;
    real_T oldmdot, oldcon, oldlin, oldqua;
    real_T a, b, c;
    int_T i;
    
    c1 = CON1;
    l1 = LIN1;
    q1 = QUA1;
    c2 = CON2;
    l2 = LIN2;
    q2 = QUA2;
    oldmdot = OLDMDOT;
    oldcon = OLDCON;
    oldlin = OLDLIN;
    oldqua = OLDQUA;
    
    
    if ((ID1 < 0.0) && (ID2 < 0.0))   /* no massflow */
    {
        y1[0] = min(c1, c2) + oldcon;
        y1[1] = min(l1, l2) + oldlin;
        y1[2] = min(q1, q2) + oldqua;
        y2[0] = 0.5;            /* massflow equally divided between path 1 and path 2 */
    }
    else if (ID2 < 0.0)           /* no massflow or closed path 2 */
    {
        y1[0] = c1 + oldcon;
        y1[1] = l1 + oldlin;
        y1[2] = q1 + oldqua;
        y2[0] = 1.0;            /* fdiv is one, full massflow through path 1 */
    }
    else if (ID1 < 0.0)           /* no massflow or closed path 1 */
    {
        y1[0] = c2 + oldcon;
        y1[1] = l2 + oldlin;
        y1[2] = q2 + oldqua;
        y2[0] = 0.0;            /* fdiv is zero, full massflow through path 2 */
    }
    else
    {
        /* determine flow diversion factor by calculation the massflow in branch 1 and 2 */
        a = q1-q2;
        b = 2.0*q2*oldmdot+l1+l2;
        c = c1-c2-(q2*oldmdot+l2)*oldmdot;
        solve_quadratic_equation(x12_1, a, b, c);  // return by reference: solutions are returned in the array of pointer *mdot1
        
        if (x12_1[0] < 0.0)
        {
            mdot1 = max(0.0, x12_1[1]);    // max in case both are negative
        }
        else if (x12_1[1] < 0.0)
        {
            mdot1 = max(0.0, x12_1[0]);    // max in case both are negative
        }
        else
        {
            /* both x12 >= 0
             * unless both are 0, this is only possible for
             * a) a < 0, b > 0, c <= 0
             * b) a > 0, b < 0, c >= 0
             */
            mdot1 = min(x12_1[0], x12_1[1]);   // take other solution if out of range
        }
        
        /* determine resistance of branches for the rest of the circuit */
        
        /* mdotS is massflow in branch 1 when 0.1 kg/s is flowing as sum in branch 1 and 2*/
        mdotT[0] = 0.1;
        mdotT[1] = 0.2;
        mdotT[2] = 0.3;
        for (i = 0; i < 3; i++)
        {
            b = 2.0*q2*mdotT[i]+l1+l2;
            c = c1-c2-(q2*mdotT[i]+l2)*mdotT[i];
            solve_quadratic_equation(x12_T, a, b, c);
            if (x12_T[0] < 0.0)
            {
                mdotT[i] = max(0.0, x12_T[1]);    // max in case both are negative
            }
            else if (x12_T[1] < 0.0)
            {
                mdotT[i] = max(0.0, x12_T[0]);    // max in case both are negative
            }
            else
            {
                /* both x12 >= 0
                 * unless both are 0, this is only possible for
                 * a) a < 0, b > 0, c <= 0
                 * b) a > 0, b < 0, c >= 0
                 */
                mdotT[i] = min(x12_T[0], x12_T[1]);
            }
            dpT[i] = c1 + mdotT[i]*(l1 + q1*mdotT[i]);       /* pressure drop at mdotT */
        }
        
        /* set outputs */
        y1[0] = dpT[2]-3.0*dpT[1]+3.0*dpT[0];             /* constant factor */
        y1[1] = 5.0*(8.0*dpT[1]-3.0*dpT[2]-5.0*dpT[0]);   /* linear factor */
        y1[2] = 50.0*(dpT[2]-2.0*dpT[1]+dpT[0]);          /* quadratic factor */
        
        y1[0] += oldcon;
        y1[1] += oldlin;
        y1[2] += oldqua;
        
        /* calculate fdiv */
        if (oldmdot != 0.0)
        {
            y2[0] = mdot1/oldmdot;              /* flow diversion is massflow 1 divided by total massflow */
            y2[0] = max(0.0, min(1.0, y2[0]));  /* limit diversion factor between 0 and 1 */
            if (oldmdot < 2.0*NO_MASSFLOW)
            {
                if (y2[0] < 0.5)    // too little for two branches: round
                {
                    y2[0] = 0.0;
                }
                else
                {
                    y2[0] = 1.0;
                }
            }
            else if (oldmdot*y2[0] < NO_MASSFLOW)   // too little for branch 1
            {
                y2[0]  = 0.0;
            }
            else if (oldmdot*(1-y2[0]) < NO_MASSFLOW)   // too little for branch 2
            {
                y2[0] = 1.0;
            }
        }
        else
        {
            y2[0] = 0.5;    // see IDx < 0 above
        }
        
        //printf("fdiv %f   mdotS %f  mdotsum %f \n", y2[0], mdotS, mdotsum);
    }  /* end no massflow */
    
} /* end mdlOutputs */



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
