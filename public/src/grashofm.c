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
 * mex file for multi-input, single-output state-space system.
 *
 * This MEX-file is the interface from m-files to the carnot-library
 * carlib and its functions for the fluid the Grashof number
 *
 *     Syntax  [sys, x0] = grashofm(t,x,u,flag,x(1),x(2),x(3),x0)
 *
 * Version  Author              Changes                             Date
 * 0.11.0   Bernd Hafner (hf)   created                             04feb99
 * 6.1.0    hf                  comments added                      29sep2014
 *
 *
 * Copyright (c) 1998-2014 Solar-Institut Juelich, Germany
 *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *  D E S C R I P T I O N
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *         
 * structure of u (input vector)
 * index use
 * 0    temperature at wall                                 degree centigrade
 * 1    temperature at infinite distance                    degree centigrade
 * 2    pressure                                            Pa  
 * 3    fluid ID (defined in CARNOT.h)                 
 * 4    mixture  (defined in CARNOT.h)                 
 * 5    characteristic dimension                            m
 *
 *
 * structure of y (output vector)
 *  index   use
 *  0       grashof number
 *
 */

#include "mex.h"
#include "carlib.h" 



void grashofm(double x[], double ft[], double fm[], double tw[], double ti[],
    double p[], double d[], int num[])
{
    int n, id[6], pos, np[6], m;
    
    pos = 0;
    for (n = 0; n < 6; n++) {
        np[n] = 0;
        if (num[n] > 1) {
            pos = n;
            np[n] = 1;
        }
        id[n] = 0;
    }

    for (n = 0; n < num[pos]; n++)
    {
        for (m = 0; m < 6; m++)
            if (np[m]) id[m] = n;
        x[n] = grashof(ft[id[3]], fm[id[4]], tw[id[0]], ti[id[1]], p[id[2]], d[id[5]]);
/*        printf("n %i gr %f \n ", n, x[n]);*/
        if (x[n]==-1)
              mexErrMsgTxt ("An error occured while evaluation of grassof number:\n" 
                            "Check the range of the inputs.\n");
    } /* end for n */
}


void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[] )
{
    double *x, *tw, *ti, *d, *p, *ft, *fm;
    int    rows, num[6], cols, m, n, i;
  
    /* Check for proper number of arguments. */
    if(nrhs!=6)
        mexErrMsgTxt("ERROR in grashof: 6 inputs required.");
    if(nlhs>1)
        mexErrMsgTxt("ERROR in grashof: One output arguments allowed.");
  
    /* check input arguments */
    for (i = 0; i < 5; i++) {
        if( !mxIsNumeric(prhs[i]) || !mxIsDouble(prhs[i]) ||
            mxIsEmpty(prhs[i])    || mxIsComplex(prhs[i]) ) {
            mexErrMsgTxt("ERROR in grashof: input must be a number");
        }
    }

    /*  get the input matrix */
    tw = mxGetPr(prhs[0]);
    ti = mxGetPr(prhs[1]);
    p  = mxGetPr(prhs[2]);
    ft = mxGetPr(prhs[3]);
    fm = mxGetPr(prhs[4]);
    d  = mxGetPr(prhs[5]);
  
    /*  get the dimensions of the matrix input */
    rows = 1;
    cols = 1;
    for (i = 0; i < 6; i++) {
        m = (int_T)mxGetM(prhs[i]);
        n = (int_T)mxGetN(prhs[i]);
        if (m > 1 && m != rows && rows > 1 ||
            n > 1 && n != cols && cols > 1)
            mexErrMsgTxt ("ERROR in Grashof: inputs must have the same size or be a scalar");
        num[i] = max(m, n);
        rows = max(m, rows);
        cols = max(n, cols);
    }

    /* Create matrix for the return argument. */
    plhs[0] = mxCreateDoubleMatrix(rows, cols, mxREAL);

/*printf("bin in mexfun \n");*/

    /* x is the pointer to the result */
    x = mxGetPr(plhs[0]);
    grashofm(x, ft, fm, tw, ti, p, d, num);
    return;
}
