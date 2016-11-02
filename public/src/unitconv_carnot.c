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
 *  History
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * Syntax  unitconv_carnot
 *
 * Version  Author          Changes                                 Date
 * 0.1.0    Thomas Wenzel   created                                 17jun1999
 * 6.1.0    hf              comment out cutils.h                    21feb2015
 ***********************************************************************
 *  M O D E L    O R    F U N C T I O N
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *   
 * converts a value from a specified unit to another unit
 * Input        double value
 *	input unit
 *		output unit
 *		print flag (1 = print SI-Unit,  0 = no output
 *  
 *  Output        converted double value
 * 
 * 
 * This function needs calcunit.c, unitname.c
 ***********************************************************************
 */


#include <string.h>
#include "mex.h"
// #include "cutils.h"
#include "calcunit.h"
     
double calculate_unit_factor(char *inputunit,char *outputunit,int outputflag);

void
mexFunction(int nlhs,mxArray *plhs[],int nrhs,const mxArray *prhs[])
{
  int buf_len,status; /* Hilfszählvariablen        */

  char *inputunit, *outputunit;//, out_valuestring[20], *flag_string, *value_string; 
  double in_value, out_value, dflag; //in1
  double conv_factor;
  int flag; //int fehler;

   if (nrhs!=4)
   {
      printf("\n");
      printf(" unitconv value input_unit output_unit flag\n");
      printf("\n");
      printf("   Input   double value\n");
      printf("           input unit\n");
      printf("           output unit\n");
      printf("           print flag (1 = print SI-Unit,  0 = no output\n");
      printf("   \n");
      printf("   Output  converted double value\n");
      printf("\n");
      printf("  example unitconv(12,'kW*h','W*s',1)\n");
      printf("\n");
      plhs[0]=mxCreateDoubleMatrix(1,1,mxREAL);
      *mxGetPr(plhs[0])= 0;
      
      
   }
   else
   {
   
      in_value = *mxGetPr(prhs[0]);                          /* Wert einlesen */
   
      buf_len = (int_T)(mxGetM(prhs[1])*mxGetN(prhs[1]))+1;         /* 1. Einheit einlesen */
      inputunit = mxCalloc(buf_len,sizeof(char));
      status = mxGetString(prhs[1],inputunit,buf_len);
   
      buf_len = (int_T)(mxGetM(prhs[2])*mxGetN(prhs[2]))+1;         /* Zieleinheit einlesen */
      outputunit = mxCalloc(buf_len,sizeof(char));
      status = mxGetString(prhs[2],outputunit,buf_len);
   
      dflag = *mxGetPr(prhs[3]);                             /* flag einlesen */
      flag = (int) dflag;
   
      
      conv_factor = calculate_unit_factor(inputunit,outputunit,flag);
   
   
      out_value = conv_factor * in_value;
   
   
      if (flag)
        printf("%f %s -> %f %s\n",in_value,inputunit,out_value,outputunit);
   
      plhs[0]=mxCreateDoubleMatrix(1,1,mxREAL);
      *mxGetPr(plhs[0])= out_value;
   }
}
/* END */

