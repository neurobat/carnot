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
 * This MEX-file is the interface from m-files to the carnot-library
 * carlib and its functions for the solar calculation
 *
 *     Syntax  [sys, x0] = calcsolar(time,x,u,flag,x(1),x(2),x(3),x0)
 *
 * Version  Author          Changes                             Date
 * 3.1.0    Bernd Hafner(hf)created                             25dec2008
 * 6.1.0    hf              changed loop for SOLARTIME          04oct2014
 *
 *
 * 
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *  D E S C R I P T I O N
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *
 * structure of u (input vector)
 * index use
 * 0    time (0 = 1st January, 0:00:00)                     s
 * 1    type of calculation
 *
 * structure of y (output vector)
 *  index   use
 *  0       result
 *
 * 
 *  type    function                    calculation 
 *  0       extraterrestrial_radiation  solar extraterrestrial radiation on normal plane
 */

#include "mex.h"
#include "carlib.h" 


void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[] )
{
    double *x, *t, *prop, *lat, *lon, *lon0;
    int    rows, num, cols, m, n, i, matrix;
  
    /* Check for proper number of arguments. */
    if (nrhs != 5) 
    {
        mexErrMsgTxt("ERROR in calcsolar: 5 inputs required.");
        return;
    }
    /* check input arguments */
    for (i = 0; i < 5; i++) {
        if( !mxIsNumeric(prhs[i]) || !mxIsDouble(prhs[i]) ||
            mxIsEmpty(prhs[i])    || mxIsComplex(prhs[i]) )
        {
            mexErrMsgTxt("ERROR in calcsolar: input must be a number");
            return;
        }
    }

    /*  get the input matrix */
    t    = mxGetPr(prhs[0]);
    lat  = mxGetPr(prhs[1]);
    lon  = mxGetPr(prhs[2]);
    lon0 = mxGetPr(prhs[3]);

    /*  get the scalar input prop */
    prop = mxGetPr(prhs[4]);
  
    /*  get the dimensions of the matrix input */
    rows = 1;
    cols = 1;
    num = 0;
    for (i = 0; i < 3; i++) {
        m = (int_T)(mxGetM(prhs[i]));
        n = (int_T)(mxGetN(prhs[i]));
        
        if ( (m > 1 && rows > 1) || (n > 1 && cols > 1) || (m > 1 && n > 1))
        {
            mexErrMsgTxt ("ERROR in calcsolar: only one input can be a vector");
            return;
        }
        else if (m > 1 || n > 1)
        {
            matrix = i;          /* index to input which is a vector */
        }
        num = max(m, num);
        num = max(n, num);
        rows = max(m, rows);
        cols = max(n, cols);
    }   
 
    /* Create matrix for the return argument. */
    plhs[0] = mxCreateDoubleMatrix(rows, cols, mxREAL);

    /* x is the pointer to the result */
    x = mxGetPr(plhs[0]);

    /* call the required calculation */
    for (n = 0; n < num; n++)                               /* loop over vector length */
    {        
        switch ((int)(prop[0]+0.5))
        {
            case EXTRATERRARADIATION:
                x[n] = extraterrestrial_radiation(t[n]);    /* call function for extraterrestrial solar radiation in carlib */
                break;
            case DECLINATION:
                x[n] = RAD2DEG*solar_declination(t[n]);     /* call solar declination in carlib and transfer result to degrees */
                break;
            case SOLARTIME:
                if (matrix == 0)                            /* time is the vector */
                    x[n] = solar_time(t[n],lon0[0],lon[0]); /* call function for solar time in carlib */
                else if (matrix == 1)                       /* ref-longitude is the vector */
                    x[n] = solar_time(t[0],lon0[n],lon[0]); /* call function for solar time in carlib */
                else if (matrix == 2)                       /* longitude is the vector */
                    x[n] = solar_time(t[0],lon0[0],lon[n]); /* call function for solar time in carlib */
                else
                    x[n] = 0.0;
                break;
            default:
            case SOLARPOSITION:
                break;
        } /* end switch */
    } /* end for n */

    return;
}
