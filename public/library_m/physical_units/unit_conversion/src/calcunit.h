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
 
  Function:  calculate_unit_factor

  Version  Author              Changes                             Date
  0.1.0    Thomas Wenzel       created                             26jan2000
 
  Copyright (c) 2000 Solar-Institut Juelich, Germany

******************************************************************************

  This function calculates by which factor you have to multiply a specified
  unit to get another specified unit.
  When specifying a unit, the unit symbols have to be separated by * or /.
  That means kWh has to be written as kW*h.

  Syntax    f = calculated_unit_factor("m/s","km/h",1);

  input     char *inputunit       eg: "m/s"
            char *outputunit          "km/h"
            int  outputflag           1 = output of SI-Units, 0 = no output
  output    double return-value       3.6

******************************************************************************
  
  For expandig the list of known units, just write those units
  in the function init_unit_list and compile againg.

     mex unitconv.c 
  or 
     mex unitconv_s.c 

  For compilation the function cutils.c is needed, but 
  don't have to be specified.

******************************************************************************/


#ifndef HEADER_CALCUNIT
#define HEADER_CALCUNIT



#define MAX_CHAR 100
#define MAX_DIM  7     /* 0 x/m - 1 m/kg - 2 t/s - 3 I/A - 4 T/K - 5 N/mol - 6 J/cd*/
#define UNITFILE "unitlist"
#define MAX_UNIT_NUMBER 100
#define MAX_UNIT_CHAR   10


#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include "cutils.h"    /* function str2doub, doub2str, zeile, ... */



/*****************************************************************************

  init_unit_list

  Here you can specify new functions


  dim[0] = m
  dim[1] = kg
  dim[2] = s
  dim[3] = A

*****************************************************************************/


int init_unit_list(void *unit_d,double *unit_c,void *unit_ch)
{

   double *unit_coeff = (double*) unit_c;
   int    *unit_dim = (int*) unit_d;
   char   *unit_char = (char*) unit_ch;
  
   int i,j,k, i_unit, i_temp;
   char s1[MAX_CHAR];
   double d;

   for(i=0;i<MAX_UNIT_NUMBER;i++)
   {
      unit_dim[0+MAX_DIM*i] = 0; 
      unit_dim[1+MAX_DIM*i] = 0; 
      unit_dim[2+MAX_DIM*i] = 0; 
      unit_dim[3+MAX_DIM*i] = 0; 
      unit_dim[4+MAX_DIM*i] = 0; 
      unit_dim[5+MAX_DIM*i] = 0; 
      unit_dim[6+MAX_DIM*i] = 0; 
   }   

   strcpy(unit_char+0*MAX_UNIT_CHAR,"galUK");
   unit_coeff[0] = 0.004546;
   unit_dim[0+MAX_DIM*0] = 3;
   unit_dim[1+MAX_DIM*0] = 0;
   unit_dim[2+MAX_DIM*0] = 0;
   unit_dim[3+MAX_DIM*0] = 0;
   
   strcpy(unit_char+1*MAX_UNIT_CHAR,"galUS");
   unit_coeff[1] = 0.003785;
   unit_dim[0+MAX_DIM*1] = 3;
   unit_dim[1+MAX_DIM*1] = 0;
   unit_dim[2+MAX_DIM*1] = 0;
   unit_dim[3+MAX_DIM*1] = 0;
   
   strcpy(unit_char+2*MAX_UNIT_CHAR,"mmHg");
   unit_coeff[2] = 133.322368;
   unit_dim[0+MAX_DIM*2] = -1;
   unit_dim[1+MAX_DIM*2] = 1;
   unit_dim[2+MAX_DIM*2] = -2;
   unit_dim[3+MAX_DIM*2] = 0;
   
   strcpy(unit_char+3*MAX_UNIT_CHAR,"knot");
   unit_coeff[3] = 0.514444;
   unit_dim[0+MAX_DIM*3] = 1;
   unit_dim[1+MAX_DIM*3] = 0;
   unit_dim[2+MAX_DIM*3] = -1;
   unit_dim[3+MAX_DIM*3] = 0;
   
   strcpy(unit_char+4*MAX_UNIT_CHAR,"torr");
   unit_coeff[4] = 133.322368;
   unit_dim[0+MAX_DIM*4] = -1;
   unit_dim[1+MAX_DIM*4] = 1;
   unit_dim[2+MAX_DIM*4] = -2;
   unit_dim[3+MAX_DIM*4] = 0;
   
   strcpy(unit_char+5*MAX_UNIT_CHAR,"bar");
   unit_coeff[5] = 100000.000000;
   unit_dim[0+MAX_DIM*5] = -1;
   unit_dim[1+MAX_DIM*5] = 1;
   unit_dim[2+MAX_DIM*5] = -2;
   unit_dim[3+MAX_DIM*5] = 0;
   
   strcpy(unit_char+6*MAX_UNIT_CHAR,"cal");
   unit_coeff[6] = 4.186800;
   unit_dim[0+MAX_DIM*6] = 2;
   unit_dim[1+MAX_DIM*6] = 1;
   unit_dim[2+MAX_DIM*6] = -2;
   unit_dim[3+MAX_DIM*6] = 0;
   
   strcpy(unit_char+7*MAX_UNIT_CHAR,"min");
   unit_coeff[7] = 60.000000;
   unit_dim[0+MAX_DIM*7] = 0;
   unit_dim[1+MAX_DIM*7] = 0;
   unit_dim[2+MAX_DIM*7] = 1;
   unit_dim[3+MAX_DIM*7] = 0;
   
   strcpy(unit_char+8*MAX_UNIT_CHAR,"bbl");
   unit_coeff[8] = 0.158987;
   unit_dim[0+MAX_DIM*8] = 3;
   unit_dim[1+MAX_DIM*8] = 0;
   unit_dim[2+MAX_DIM*8] = 0;
   unit_dim[3+MAX_DIM*8] = 0;
   
   strcpy(unit_char+9*MAX_UNIT_CHAR,"atm");
   unit_coeff[9] = 101325.000000;
   unit_dim[0+MAX_DIM*9] = -1;
   unit_dim[1+MAX_DIM*9] = 1;
   unit_dim[2+MAX_DIM*9] = -2;
   unit_dim[3+MAX_DIM*9] = 0;
   
   strcpy(unit_char+10*MAX_UNIT_CHAR,"yd");
   unit_coeff[10] = 0.914400;
   unit_dim[0+MAX_DIM*10] = 1;
   unit_dim[1+MAX_DIM*10] = 0;
   unit_dim[2+MAX_DIM*10] = 0;
   unit_dim[3+MAX_DIM*10] = 0;
   
   strcpy(unit_char+11*MAX_UNIT_CHAR,"hp");
   unit_coeff[11] = 745.699870;
   unit_dim[0+MAX_DIM*11] = 2;
   unit_dim[1+MAX_DIM*11] = 1;
   unit_dim[2+MAX_DIM*11] = -3;
   unit_dim[3+MAX_DIM*11] = 0;
   
   strcpy(unit_char+12*MAX_UNIT_CHAR,"Pa");
   unit_coeff[12] = 1.000000;
   unit_dim[0+MAX_DIM*12] = -1;
   unit_dim[1+MAX_DIM*12] = 1;
   unit_dim[2+MAX_DIM*12] = -2;
   unit_dim[3+MAX_DIM*12] = 0;
   
   strcpy(unit_char+13*MAX_UNIT_CHAR,"Hz");
   unit_coeff[13] = 1.000000;
   unit_dim[0+MAX_DIM*13] = 0;
   unit_dim[1+MAX_DIM*13] = 0;
   unit_dim[2+MAX_DIM*13] = -1;
   unit_dim[3+MAX_DIM*13] = 0;
   
   strcpy(unit_char+14*MAX_UNIT_CHAR,"lb");
   unit_coeff[14] = 0.453592;
   unit_dim[0+MAX_DIM*14] = 0;
   unit_dim[1+MAX_DIM*14] = 1;
   unit_dim[2+MAX_DIM*14] = 0;
   unit_dim[3+MAX_DIM*14] = 0;
   
   strcpy(unit_char+15*MAX_UNIT_CHAR,"oz");
   unit_coeff[15] = 0.028350;
   unit_dim[0+MAX_DIM*15] = 0;
   unit_dim[1+MAX_DIM*15] = 1;
   unit_dim[2+MAX_DIM*15] = 0;
   unit_dim[3+MAX_DIM*15] = 0;
   
   strcpy(unit_char+16*MAX_UNIT_CHAR,"PS");
   unit_coeff[16] = 735.498750;
   unit_dim[0+MAX_DIM*16] = 2;
   unit_dim[1+MAX_DIM*16] = 1;
   unit_dim[2+MAX_DIM*16] = -3;
   unit_dim[3+MAX_DIM*16] = 0;
   
   strcpy(unit_char+17*MAX_UNIT_CHAR,"ft");
   unit_coeff[17] = 0.304800;
   unit_dim[0+MAX_DIM*17] = 1;
   unit_dim[1+MAX_DIM*17] = 0;
   unit_dim[2+MAX_DIM*17] = 0;
   unit_dim[3+MAX_DIM*17] = 0;
   
   strcpy(unit_char+18*MAX_UNIT_CHAR,"in");
   unit_coeff[18] = 0.025400;
   unit_dim[0+MAX_DIM*18] = 1;
   unit_dim[1+MAX_DIM*18] = 0;
   unit_dim[2+MAX_DIM*18] = 0;
   unit_dim[3+MAX_DIM*18] = 0;
   
   strcpy(unit_char+19*MAX_UNIT_CHAR,"mi");
   unit_coeff[19] = 1609.000000;
   unit_dim[0+MAX_DIM*19] = 1;
   unit_dim[1+MAX_DIM*19] = 0;
   unit_dim[2+MAX_DIM*19] = 0;
   unit_dim[3+MAX_DIM*19] = 0;
   
   strcpy(unit_char+20*MAX_UNIT_CHAR,"V");
   unit_coeff[20] = 1.000000;
   unit_dim[0+MAX_DIM*20] = 2;
   unit_dim[1+MAX_DIM*20] = 1;
   unit_dim[2+MAX_DIM*20] = -3;
   unit_dim[3+MAX_DIM*20] = -1;
   
   strcpy(unit_char+21*MAX_UNIT_CHAR,"T");
   unit_coeff[21] = 1.000000;
   unit_dim[0+MAX_DIM*21] = 0;
   unit_dim[1+MAX_DIM*21] = 1;
   unit_dim[2+MAX_DIM*21] = -2;
   unit_dim[3+MAX_DIM*21] = -1;
   
   strcpy(unit_char+22*MAX_UNIT_CHAR,"g");
   unit_coeff[22] = 0.001000;
   unit_dim[0+MAX_DIM*22] = 0;
   unit_dim[1+MAX_DIM*22] = 1;
   unit_dim[2+MAX_DIM*22] = 0;
   unit_dim[3+MAX_DIM*22] = 0;
   
   strcpy(unit_char+23*MAX_UNIT_CHAR,"s");
   unit_coeff[23] = 1.000000;
   unit_dim[0+MAX_DIM*23] = 0;
   unit_dim[1+MAX_DIM*23] = 0;
   unit_dim[2+MAX_DIM*23] = 1;
   unit_dim[3+MAX_DIM*23] = 0;
   
   strcpy(unit_char+24*MAX_UNIT_CHAR,"A");
   unit_coeff[24] = 1.000000;
   unit_dim[0+MAX_DIM*24] = 0;
   unit_dim[1+MAX_DIM*24] = 0;
   unit_dim[2+MAX_DIM*24] = 0;
   unit_dim[3+MAX_DIM*24] = 1;
   
   strcpy(unit_char+25*MAX_UNIT_CHAR,"a");    /* Gemeinjahr = 365 d */
   unit_coeff[25] = 31536000;
   unit_dim[0+MAX_DIM*25] = 0;
   unit_dim[1+MAX_DIM*25] = 0;
   unit_dim[2+MAX_DIM*25] = 1;
   unit_dim[3+MAX_DIM*25] = 0;
   
   strcpy(unit_char+26*MAX_UNIT_CHAR,"N");
   unit_coeff[26] = 1.000000;
   unit_dim[0+MAX_DIM*26] = 1;
   unit_dim[1+MAX_DIM*26] = 1;
   unit_dim[2+MAX_DIM*26] = -2;
   unit_dim[3+MAX_DIM*26] = 0;
   
   strcpy(unit_char+27*MAX_UNIT_CHAR,"W");
   unit_coeff[27] = 1.000000;
   unit_dim[0+MAX_DIM*27] = 2;
   unit_dim[1+MAX_DIM*27] = 1;
   unit_dim[2+MAX_DIM*27] = -3;
   unit_dim[3+MAX_DIM*27] = 0;
   
   strcpy(unit_char+28*MAX_UNIT_CHAR,"J");
   unit_coeff[28] = 1.000000;
   unit_dim[0+MAX_DIM*28] = 2;
   unit_dim[1+MAX_DIM*28] = 1;
   unit_dim[2+MAX_DIM*28] = -2;
   unit_dim[3+MAX_DIM*28] = 0;
   
   strcpy(unit_char+29*MAX_UNIT_CHAR,"h");
   unit_coeff[29] = 3600.000000;
   unit_dim[0+MAX_DIM*29] = 0;
   unit_dim[1+MAX_DIM*29] = 0;
   unit_dim[2+MAX_DIM*29] = 1;
   unit_dim[3+MAX_DIM*29] = 0;
   
   strcpy(unit_char+30*MAX_UNIT_CHAR,"m");
   unit_coeff[30] = 1.000000;
   unit_dim[0+MAX_DIM*30] = 1;
   unit_dim[1+MAX_DIM*30] = 0;
   unit_dim[2+MAX_DIM*30] = 0;
   unit_dim[3+MAX_DIM*30] = 0;
   
   strcpy(unit_char+31*MAX_UNIT_CHAR,"l");
   unit_coeff[31] = 0.001000;
   unit_dim[0+MAX_DIM*31] = 3;
   unit_dim[1+MAX_DIM*31] = 0;
   unit_dim[2+MAX_DIM*31] = 0;
   unit_dim[3+MAX_DIM*31] = 0;
   i_unit = 32;    
      
    
   strcpy(unit_char+32*MAX_UNIT_CHAR,"t");
   unit_coeff[32] = 1000.000000;
   unit_dim[0+MAX_DIM*32] = 0;
   unit_dim[1+MAX_DIM*32] = 1;
   unit_dim[2+MAX_DIM*32] = 0;
   unit_dim[3+MAX_DIM*32] = 0;
   unit_dim[4+MAX_DIM*i_unit] = 0;
   i_unit = 33;    

   strcpy(unit_char+i_unit*MAX_UNIT_CHAR,"d");
   unit_coeff[i_unit] = 86400.000000;
   unit_dim[0+MAX_DIM*i_unit] = 0;
   unit_dim[1+MAX_DIM*i_unit] = 0;
   unit_dim[2+MAX_DIM*i_unit] = 1;
   unit_dim[3+MAX_DIM*i_unit] = 0;
   unit_dim[4+MAX_DIM*i_unit] = 0;
   i_unit ++;    

   strcpy(unit_char+i_unit*MAX_UNIT_CHAR,"Btu");
   unit_coeff[i_unit] = 745.7;
   unit_dim[0+MAX_DIM*i_unit] = 2;
   unit_dim[1+MAX_DIM*i_unit] = 1;
   unit_dim[2+MAX_DIM*i_unit] = -3;
   unit_dim[3+MAX_DIM*i_unit] = 0;
   unit_dim[4+MAX_DIM*i_unit] = 0;
   i_unit ++;    

   strcpy(unit_char+i_unit*MAX_UNIT_CHAR,"K");
   unit_coeff[i_unit] = 1;
   unit_dim[0+MAX_DIM*i_unit] = 0;
   unit_dim[1+MAX_DIM*i_unit] = 0;
   unit_dim[2+MAX_DIM*i_unit] = 0;
   unit_dim[3+MAX_DIM*i_unit] = 0;
   unit_dim[4+MAX_DIM*i_unit] = 1;
   i_unit ++;    

   strcpy(unit_char+i_unit*MAX_UNIT_CHAR,"sm");
   unit_coeff[i_unit] = 1852;
   unit_dim[0+MAX_DIM*i_unit] = 1;
   unit_dim[1+MAX_DIM*i_unit] = 0;
   unit_dim[2+MAX_DIM*i_unit] = 0;
   unit_dim[3+MAX_DIM*i_unit] = 0;
   unit_dim[4+MAX_DIM*i_unit] = 0;
   i_unit ++;    

   strcpy(unit_char+i_unit*MAX_UNIT_CHAR,"gr");
   unit_coeff[i_unit] = 6.4799e-5;
   unit_dim[0+MAX_DIM*i_unit] = 0;
   unit_dim[1+MAX_DIM*i_unit] = 1;
   unit_dim[2+MAX_DIM*i_unit] = 0;
   unit_dim[3+MAX_DIM*i_unit] = 0;
   unit_dim[4+MAX_DIM*i_unit] = 0;
   i_unit ++;    

   strcpy(unit_char+i_unit*MAX_UNIT_CHAR,"c");
   unit_coeff[i_unit] = 2.99792468e8;
   unit_dim[0+MAX_DIM*i_unit] = 1;
   unit_dim[1+MAX_DIM*i_unit] = 0;
   unit_dim[2+MAX_DIM*i_unit] = -1;
   unit_dim[3+MAX_DIM*i_unit] = 0;
   unit_dim[4+MAX_DIM*i_unit] = 0;
   i_unit ++;    

   strcpy(unit_char+i_unit*MAX_UNIT_CHAR,"ha");
   unit_coeff[i_unit] = 10000;
   unit_dim[0+MAX_DIM*i_unit] = 2;
   unit_dim[1+MAX_DIM*i_unit] = 0;
   unit_dim[2+MAX_DIM*i_unit] = 0;
   unit_dim[3+MAX_DIM*i_unit] = 0;
   unit_dim[4+MAX_DIM*i_unit] = 0;
   i_unit ++;    

   strcpy(unit_char+i_unit*MAX_UNIT_CHAR,"G");
   unit_coeff[i_unit] = 6.67529e-11;
   unit_dim[0+MAX_DIM*i_unit] = 3;
   unit_dim[1+MAX_DIM*i_unit] = -1;
   unit_dim[2+MAX_DIM*i_unit] = -2;
   unit_dim[3+MAX_DIM*i_unit] = 0;
   unit_dim[4+MAX_DIM*i_unit] = 0;
   i_unit ++;    

   strcpy(unit_char+i_unit*MAX_UNIT_CHAR,"e");
   unit_coeff[i_unit] = 1.60217733e-19;
   unit_dim[0+MAX_DIM*i_unit] = 0;
   unit_dim[1+MAX_DIM*i_unit] = 0;
   unit_dim[2+MAX_DIM*i_unit] = -1;
   unit_dim[3+MAX_DIM*i_unit] = 1;
   unit_dim[4+MAX_DIM*i_unit] = 0;
   i_unit ++;    

   strcpy(unit_char+i_unit*MAX_UNIT_CHAR,"NA");
   unit_coeff[i_unit] = 6.0221367e23;
   unit_dim[0+MAX_DIM*i_unit] = 0;
   unit_dim[1+MAX_DIM*i_unit] = 0;
   unit_dim[2+MAX_DIM*i_unit] = 0;
   unit_dim[3+MAX_DIM*i_unit] = 0;
   unit_dim[4+MAX_DIM*i_unit] = 0;
   unit_dim[5+MAX_DIM*i_unit] = -1;
   unit_dim[6+MAX_DIM*i_unit] = 0;         /* cd  */
   i_unit ++;    

   strcpy(unit_char+i_unit*MAX_UNIT_CHAR,"Rm");
   unit_coeff[i_unit] = 8.314510;
   unit_dim[0+MAX_DIM*i_unit] = 2;         /* m */
   unit_dim[1+MAX_DIM*i_unit] = 1;         /* kg */
   unit_dim[2+MAX_DIM*i_unit] = -2;         /* s  */
   unit_dim[3+MAX_DIM*i_unit] = 0;         /* A  */
   unit_dim[4+MAX_DIM*i_unit] = -1;        /* K  */
   unit_dim[5+MAX_DIM*i_unit] = -1;        /* mol */
   unit_dim[6+MAX_DIM*i_unit] = 0;         /* cd  */
   i_unit ++;    

   strcpy(unit_char+i_unit*MAX_UNIT_CHAR,"µ0");
   unit_coeff[i_unit] = 12.5663706143592e-7;
   unit_dim[0+MAX_DIM*i_unit] = 1;          /* m   */
   unit_dim[1+MAX_DIM*i_unit] = 1;          /* kg  */
   unit_dim[2+MAX_DIM*i_unit] = -2;         /* s   */
   unit_dim[3+MAX_DIM*i_unit] = -2;         /* A   */
   unit_dim[4+MAX_DIM*i_unit] = 0;          /* K   */
   unit_dim[5+MAX_DIM*i_unit] = 0;          /* mol */
   i_unit ++;    

   strcpy(unit_char+i_unit*MAX_UNIT_CHAR,"eps0");
   unit_coeff[i_unit] = 8.85418781762e-12;
   unit_dim[0+MAX_DIM*i_unit] = -3;         /* m   */
   unit_dim[1+MAX_DIM*i_unit] = -1;         /* kg  */
   unit_dim[2+MAX_DIM*i_unit] = 4;          /* s   */
   unit_dim[3+MAX_DIM*i_unit] = 2;          /* A   */
   unit_dim[4+MAX_DIM*i_unit] = 0;          /* K   */
   unit_dim[5+MAX_DIM*i_unit] = 0;          /* mol */
   unit_dim[6+MAX_DIM*i_unit] = 0;         /* cd  */
   i_unit ++;    

   strcpy(unit_char+i_unit*MAX_UNIT_CHAR,"u");
   unit_coeff[i_unit] = 1.6605402e-27;
   unit_dim[0+MAX_DIM*i_unit] = 0;         /* m   */
   unit_dim[1+MAX_DIM*i_unit] = 1;         /* kg  */
   unit_dim[2+MAX_DIM*i_unit] = 0;         /* s   */
   unit_dim[3+MAX_DIM*i_unit] = 0;         /* A   */
   unit_dim[4+MAX_DIM*i_unit] = 0;         /* K   */
   unit_dim[5+MAX_DIM*i_unit] = 0;         /* mol */
   unit_dim[6+MAX_DIM*i_unit] = 0;         /* cd  */
   i_unit ++;    

   strcpy(unit_char+i_unit*MAX_UNIT_CHAR,"kb");
   unit_coeff[i_unit] = 1.380658e-23;
   unit_dim[0+MAX_DIM*i_unit] = 2;         /* m   */
   unit_dim[1+MAX_DIM*i_unit] = 1;         /* kg  */
   unit_dim[2+MAX_DIM*i_unit] = -2;        /* s   */
   unit_dim[3+MAX_DIM*i_unit] = 0;         /* A   */
   unit_dim[4+MAX_DIM*i_unit] = -1;         /* K   */
   unit_dim[5+MAX_DIM*i_unit] = 0;         /* mol */
   unit_dim[6+MAX_DIM*i_unit] = 0;         /* cd  */
   i_unit ++;    

   strcpy(unit_char+i_unit*MAX_UNIT_CHAR,"eV");
   unit_coeff[i_unit] = 1.60217733e-19;
   unit_dim[0+MAX_DIM*i_unit] = 2;         /* m   */
   unit_dim[1+MAX_DIM*i_unit] = 1;         /* kg  */
   unit_dim[2+MAX_DIM*i_unit] = -2;        /* s   */
   unit_dim[3+MAX_DIM*i_unit] = 0;         /* A   */
   unit_dim[4+MAX_DIM*i_unit] = 0;         /* K   */
   unit_dim[5+MAX_DIM*i_unit] = 0;         /* mol */
   unit_dim[6+MAX_DIM*i_unit] = 0;         /* cd  */
   i_unit ++;    

   strcpy(unit_char+i_unit*MAX_UNIT_CHAR,"dpt");
   unit_coeff[i_unit] = 1;
   unit_dim[0+MAX_DIM*i_unit] = -1;        /* m   */
   unit_dim[1+MAX_DIM*i_unit] = 0;         /* kg  */
   unit_dim[2+MAX_DIM*i_unit] = 0;         /* s   */
   unit_dim[3+MAX_DIM*i_unit] = 0;         /* A   */
   unit_dim[4+MAX_DIM*i_unit] = 0;         /* K   */
   unit_dim[5+MAX_DIM*i_unit] = 0;         /* mol */
   unit_dim[6+MAX_DIM*i_unit] = 0;         /* cd  */
   i_unit ++;    

   strcpy(unit_char+i_unit*MAX_UNIT_CHAR,"AE");
   unit_coeff[i_unit] = 1.4959787e11;
   unit_dim[0+MAX_DIM*i_unit] = 1;         /* m   */
   unit_dim[1+MAX_DIM*i_unit] = 0;         /* kg  */
   unit_dim[2+MAX_DIM*i_unit] = 0;         /* s   */
   unit_dim[3+MAX_DIM*i_unit] = 0;         /* A   */
   unit_dim[4+MAX_DIM*i_unit] = 0;         /* K   */
   unit_dim[5+MAX_DIM*i_unit] = 0;         /* mol */
   unit_dim[6+MAX_DIM*i_unit] = 0;         /* cd  */
   i_unit ++;    

   strcpy(unit_char+i_unit*MAX_UNIT_CHAR,"lj");
   unit_coeff[i_unit] = 9.4605e15;
   unit_dim[0+MAX_DIM*i_unit] = 1;         /* m   */
   unit_dim[1+MAX_DIM*i_unit] = 0;         /* kg  */
   unit_dim[2+MAX_DIM*i_unit] = 0;         /* s   */
   unit_dim[3+MAX_DIM*i_unit] = 0;         /* A   */
   unit_dim[4+MAX_DIM*i_unit] = 0;         /* K   */
   unit_dim[5+MAX_DIM*i_unit] = 0;         /* mol */
   unit_dim[6+MAX_DIM*i_unit] = 0;         /* cd  */
   i_unit ++;    

   strcpy(unit_char+i_unit*MAX_UNIT_CHAR,"pc");
   unit_coeff[i_unit] = 3.0857e16;
   unit_dim[0+MAX_DIM*i_unit] = 1;         /* m   */
   unit_dim[1+MAX_DIM*i_unit] = 0;         /* kg  */
   unit_dim[2+MAX_DIM*i_unit] = 0;         /* s   */
   unit_dim[3+MAX_DIM*i_unit] = 0;         /* A   */
   unit_dim[4+MAX_DIM*i_unit] = 0;         /* K   */
   unit_dim[5+MAX_DIM*i_unit] = 0;         /* mol */
   unit_dim[6+MAX_DIM*i_unit] = 0;         /* cd  */
   i_unit ++;    

   strcpy(unit_char+i_unit*MAX_UNIT_CHAR,"erg");
   unit_coeff[i_unit] = 1e-7;
   unit_dim[0+MAX_DIM*i_unit] = 2;         /* m   */
   unit_dim[1+MAX_DIM*i_unit] = 1;         /* kg  */
   unit_dim[2+MAX_DIM*i_unit] = -2;        /* s   */
   unit_dim[3+MAX_DIM*i_unit] = 0;         /* A   */
   unit_dim[4+MAX_DIM*i_unit] = 0;         /* K   */
   unit_dim[5+MAX_DIM*i_unit] = 0;         /* mol */
   unit_dim[6+MAX_DIM*i_unit] = 0;         /* cd  */
   i_unit ++;    

   strcpy(unit_char+i_unit*MAX_UNIT_CHAR,"cd");
   unit_coeff[i_unit] = 1;
   unit_dim[0+MAX_DIM*i_unit] = 0;         /* m   */
   unit_dim[1+MAX_DIM*i_unit] = 0;         /* kg  */
   unit_dim[2+MAX_DIM*i_unit] = 0;         /* s   */
   unit_dim[3+MAX_DIM*i_unit] = 0;         /* A   */
   unit_dim[4+MAX_DIM*i_unit] = 0;         /* K   */
   unit_dim[5+MAX_DIM*i_unit] = 0;         /* mol */
   unit_dim[6+MAX_DIM*i_unit] = 1;         /* cd  */
   i_unit ++;    

   strcpy(unit_char+i_unit*MAX_UNIT_CHAR,"F");
   unit_coeff[i_unit] = 1;
   unit_dim[0+MAX_DIM*i_unit] = -2;        /* m   */
   unit_dim[1+MAX_DIM*i_unit] = -1;        /* kg  */
   unit_dim[2+MAX_DIM*i_unit] = 4;         /* s   */
   unit_dim[3+MAX_DIM*i_unit] = 2;         /* A   */
   unit_dim[4+MAX_DIM*i_unit] = 0;         /* K   */
   unit_dim[5+MAX_DIM*i_unit] = 0;         /* mol */
   unit_dim[6+MAX_DIM*i_unit] = 0;         /* cd  */
   i_unit ++;    

   strcpy(unit_char+i_unit*MAX_UNIT_CHAR,"C");
   unit_coeff[i_unit] = 1;
   unit_dim[0+MAX_DIM*i_unit] = 0;         /* m   */
   unit_dim[1+MAX_DIM*i_unit] = 0;         /* kg  */
   unit_dim[2+MAX_DIM*i_unit] = 1;         /* s   */
   unit_dim[3+MAX_DIM*i_unit] = 1;         /* A   */
   unit_dim[4+MAX_DIM*i_unit] = 0;         /* K   */
   unit_dim[5+MAX_DIM*i_unit] = 0;         /* mol */
   unit_dim[6+MAX_DIM*i_unit] = 0;         /* cd  */
   i_unit ++;    

   strcpy(unit_char+i_unit*MAX_UNIT_CHAR,"Wb");
   unit_coeff[i_unit] = 1;
   unit_dim[0+MAX_DIM*i_unit] = 2;         /* m   */
   unit_dim[1+MAX_DIM*i_unit] = 1;         /* kg  */
   unit_dim[2+MAX_DIM*i_unit] = -2;         /* s   */
   unit_dim[3+MAX_DIM*i_unit] = -1;         /* A   */
   unit_dim[4+MAX_DIM*i_unit] = 0;         /* K   */
   unit_dim[5+MAX_DIM*i_unit] = 0;         /* mol */
   unit_dim[6+MAX_DIM*i_unit] = 0;         /* cd  */
   i_unit ++;    

   strcpy(unit_char+i_unit*MAX_UNIT_CHAR,"T");
   unit_coeff[i_unit] = 1;
   unit_dim[0+MAX_DIM*i_unit] = 0;         /* m   */
   unit_dim[1+MAX_DIM*i_unit] = 1;         /* kg  */
   unit_dim[2+MAX_DIM*i_unit] = -2;         /* s   */
   unit_dim[3+MAX_DIM*i_unit] = -1;         /* A   */
   unit_dim[4+MAX_DIM*i_unit] = 0;         /* K   */
   unit_dim[5+MAX_DIM*i_unit] = 0;         /* mol */
   unit_dim[6+MAX_DIM*i_unit] = 0;         /* cd  */
   i_unit ++;    

   strcpy(unit_char+i_unit*MAX_UNIT_CHAR,"S");
   unit_coeff[i_unit] = 1;
   unit_dim[0+MAX_DIM*i_unit] = -2;        /* m   */
   unit_dim[1+MAX_DIM*i_unit] = -1;        /* kg  */
   unit_dim[2+MAX_DIM*i_unit] = 3;         /* s   */
   unit_dim[3+MAX_DIM*i_unit] = 2;         /* A   */
   unit_dim[4+MAX_DIM*i_unit] = 0;         /* K   */
   unit_dim[5+MAX_DIM*i_unit] = 0;         /* mol */
   unit_dim[6+MAX_DIM*i_unit] = 0;         /* cd  */
   i_unit ++;    

   strcpy(unit_char+i_unit*MAX_UNIT_CHAR,"Ohm");
   unit_coeff[i_unit] = 1;
   unit_dim[0+MAX_DIM*i_unit] = 2;         /* m   */
   unit_dim[1+MAX_DIM*i_unit] = 1;         /* kg  */
   unit_dim[2+MAX_DIM*i_unit] = -3;        /* s   */
   unit_dim[3+MAX_DIM*i_unit] = -2;        /* A   */
   unit_dim[4+MAX_DIM*i_unit] = 0;         /* K   */
   unit_dim[5+MAX_DIM*i_unit] = 0;         /* mol */
   unit_dim[6+MAX_DIM*i_unit] = 0;         /* cd  */
   i_unit ++;    

   strcpy(unit_char+i_unit*MAX_UNIT_CHAR,"Bq");
   unit_coeff[i_unit] = 1;
   unit_dim[0+MAX_DIM*i_unit] = 0;         /* m   */
   unit_dim[1+MAX_DIM*i_unit] = 0;         /* kg  */
   unit_dim[2+MAX_DIM*i_unit] = -1;        /* s   */
   unit_dim[3+MAX_DIM*i_unit] = 0;         /* A   */
   unit_dim[4+MAX_DIM*i_unit] = 0;         /* K   */
   unit_dim[5+MAX_DIM*i_unit] = 0;         /* mol */
   unit_dim[6+MAX_DIM*i_unit] = 0;         /* cd  */
   i_unit ++;    

   strcpy(unit_char+i_unit*MAX_UNIT_CHAR,"b");
   unit_coeff[i_unit] = 1e-28;
   unit_dim[0+MAX_DIM*i_unit] = 2;         /* m   */
   unit_dim[1+MAX_DIM*i_unit] = 0;         /* kg  */
   unit_dim[2+MAX_DIM*i_unit] = 0;         /* s   */
   unit_dim[3+MAX_DIM*i_unit] = 0;         /* A   */
   unit_dim[4+MAX_DIM*i_unit] = 0;         /* K   */
   unit_dim[5+MAX_DIM*i_unit] = 0;         /* mol */
   unit_dim[6+MAX_DIM*i_unit] = 0;         /* cd  */
   i_unit ++;    




   /* Bubblesort by length. previous error: ft not feet but femto ton */

   for (i=0;i<i_unit;i++)
     for (j=i;j<i_unit;j++)
       if (strlen(unit_char+i*MAX_UNIT_CHAR) < strlen(unit_char+j*MAX_UNIT_CHAR) )
       {
            strcpy(s1,unit_char+i*MAX_UNIT_CHAR); 
            strcpy(unit_char+i*MAX_UNIT_CHAR,unit_char+j*MAX_UNIT_CHAR);
            strcpy(unit_char+j*MAX_UNIT_CHAR,s1);

           for (k=0;k<MAX_DIM;k++)
           {
              i_temp = unit_dim[k+MAX_DIM*i];
              unit_dim[k+MAX_DIM*i] = unit_dim[k+MAX_DIM*j];
              unit_dim[k+MAX_DIM*j] = i_temp;
           }
           
           d = unit_coeff[i];
           unit_coeff[i] = unit_coeff[j];
           unit_coeff[j] = d;
       }

   return(i_unit);
}




/******************************************************************************

  Hier wird ein Bruch in Zähler und Nenner aufgeteilt.
  Dafür wird der Bruch zeichenweise eingelesen und die vorkommenden
  * und / und () beachtet.
  Jeder Factor wird dadurch entweder dem Zähler oder dem Nenner zugeordnet.

  Syntax:  teile_string(inputunit,&in_zaehler, &in_nenner);

******************************************************************************/


void teile_string(char *bruch, char *zaehler, char *nenner)
{
   char *p;
   char z[MAX_CHAR],n[MAX_CHAR],b[MAX_CHAR],t[MAX_CHAR];
   int  klammer,
        i,
        akt_vor,
        vorzeichen[300];  /* Vorzeichen vor Klammer, z.B. /(  ),  1 = *, -1 = / */


   z[0] = '\0';
   n[0] = '\0';
   strcpy(b,bruch);
   for (i=0;i<30;i++)
      vorzeichen[i] = 1;
   vorzeichen[0] = 1;
   akt_vor = 1;
   klammer = 0;
    zaehler[0] = '\0';
    nenner[0] = '\0';

   do
   {
      p = b;
      while (p[0]=='(' || p[0]==')' || p[0]=='*' || p[0]=='/')   /* alle * / ( ) überlesen */
      {
        if (p[0]=='(')
        {
           klammer ++;
           vorzeichen[klammer] = akt_vor*vorzeichen[klammer-1];
           akt_vor = 1;
        }
        else if (p[0]==')')
        {
           klammer --;
           akt_vor = vorzeichen[klammer];
        }
        else if (p[0]=='/')
             akt_vor = -1;
        else if (p[0]=='*')
             akt_vor = 1;

        p++;
      }
      strcpy(t,p);               /* t = Teilstring des Factors */
      p = t;
      while (p[0]!='\0' && p[0]!='*' && p[0]!='/' && p[0]!=')')   /* Ende von t finden */
        p++;
      
      strcpy(b,p);
      p[0] = '\0';

      if (strlen(t))
        if (vorzeichen[klammer]*akt_vor>0)           /* Faktor t Zähler oder Nenner zuordnen */
        {
           strcat(zaehler,"*");
           strcat(zaehler,t);
        }
        else
        {
           strcat(nenner,"*");
           strcat(nenner,t);
        }
   }
   while (strlen(b)>0);              /* bis ganzer Bruch abgearbeitet */

   while (zaehler[0]=='*')
      strcpy(zaehler,zaehler+1);
   while (nenner[0]=='*')
      strcpy(nenner,nenner+1);
  
}





/******************************************************************************

   convert2si

   converts from a specified product of units to SI units and by which
   factor the product is to be multiplied to get the SI units

   SYNTAX:   zaehler1 = convert2si(in_zaehler,&dim[0],unit_dim,unit_coeff,unit_char,unit_number);  

   input  : char   *string
            int    *unit_dim       List of dimension of known units
            double *unit_coeff     List of factor unit/SI
            char   *unit_ch        List of known unit names
            int    unit_number     Number of known units
   output : int    dim             SI units of specified product
            double returnvalue     factor to get SI

******************************************************************************/



double convert2si(char *string, void *di,void *unit_d,double *unit_c,void *unit_ch,int unit_number)
{
  char s[10],
       s_zahl[10],
       *p;
  double d,
         factor,
         factor_unit,
         factor_vor;   
  int    pot,
         i, j,length1, length2,
         fehler,
         //Di[MAX_DIM],
         found, found_vor;
  
  double *unit_coeff = (double*) unit_c;
  int    *unit_dim = (int*) unit_d;
  char   *unit_char = (char*) unit_ch;
  int    *Dim = (int*) di;

  char *c_vor = "yzafpnµmcdDhkMGTPEZY";
  double d_vor[] = {1e-24,1e-21,1e-18,1e-15,1e-12,1e-9,1e-6,1e-3,1e-2,1e-1,1e1,1e2,1e3,1e6,1e9,1e12,1e15,1e18,1e21,1e24};


  for (i=0;i<MAX_DIM;i++)
    Dim[i] = 0;


  factor = 1;
/*  printf("\n %s  ",string);*/

  while (strlen(string)>0)
  {
    strcpy(s,string);
    p = s;
    while (p[0]!='*' && p[0]!='\0')        /* read until next unit */
      p++;
    if (p[0]=='*')
    {
      p[0] = '\0';    
      p++;
    }
    strcpy(string,p);

    pot = 1;
    if ((p=strstr(s,"^"))!=NULL)           /* is a exponent specified */
    {
      strcpy(s_zahl,p+1);
      fehler = string2double(s_zahl,&d);
      pot = (int) d;
      /* printf("pot %d %f\n",pot,d);*/
      p[0] = '\0';
    }

    found = found_vor = 0;
    factor_unit = factor_vor = 1;

    if (strlen(s)==1 && s[0]=='1')         /* unit = 1?   */
      found=1;
    else
    for (i=0;i<unit_number && !found;i++)  /* look for unit name in list of known units */
    {
      length1 = (int_T)strlen(s);
      length2 = (int_T)strlen(unit_char+i*MAX_UNIT_CHAR);
      if (length1>=length2)
        if (strcmp(s+(length1-length2),unit_char+i*MAX_UNIT_CHAR)==0)
        {
           found = 1;    
           factor_unit = unit_coeff[i];
           for (j=0;j<MAX_DIM;j++)
                  Dim[j] += unit_dim[j+MAX_DIM*i]*pot;

        }
    }
    i--;
    if (!found)
    {
      printf("error: unit %s not found\n",s);
      printf("\nonly following %d units and constants are known:\n",unit_number);
      for (i=0;i<unit_number;i++)
      {
         printf(" %5s",unit_char+i*MAX_UNIT_CHAR);
         if ((i+1)%10==0)
            printf("\n");
      }
      printf("\n");
         
      factor = 0;
    }

    if (length1>length2)                         /* look for sign of unit */
    {
      s[1] = '\0';                               /* max 1 sign! */
      for (j=0;j<(int_T)(strlen(c_vor) && !found_vor);j++)
        if (s[0]==c_vor[j])
        {
           found_vor = 1;
           factor_vor = d_vor[j];
        }
    }
    j--;
 
    factor *= pow(factor_unit*factor_vor,pot);
     
  }

  return factor;
}






/******************************************************************************

   dim_ausgabe

   print only dimension != 0

******************************************************************************/



void dim_ausgabe(int *dim)
{
   if (dim[0]!=0)
     printf(" m^%d",dim[0]);
   if (dim[1]!=0)
     printf(" kg^%d",dim[1]);
   if (dim[2]!=0)
     printf(" s^%d",dim[2]);
   if (dim[3]!=0)
     printf(" A^%d",dim[3]);
   if (dim[4]!=0)
     printf(" K^%d",dim[4]);
   if (dim[5]!=0)
     printf(" mol^%d",dim[5]);
   if (dim[6]!=0)
     printf(" cd^%d",dim[6]);
   printf("\n");
}





/******************************************************************************
 
  Function calculate_unit_factor

  This function calculates by which factor you have to multiply a specified
  unit to get another specified unit.
  When specifying a unit, the unit symbols have to be separated by * or /.
  That means kWh has to be written as kW*h.

  Syntax    f = calculated_unit_factor("m/s","km/h",1);

  input     char *inputunit       eg: "m/s"
            char *outputunit          "km/h"
            int  outputflag           1 = output of SI-Units, 0 = no output
  output    double return-value       3.6


******************************************************************************/



double calculate_unit_factor(char *inputunit,char *outputunit, int outputflag)
{

  int dim[4][MAX_DIM], dim_in[MAX_DIM], dim_out[MAX_DIM]; 

  int i, j,fehler,
          unit_number;
  char in_zaehler[MAX_CHAR],out_zaehler[MAX_CHAR],in_nenner[MAX_CHAR],out_nenner[MAX_CHAR];

  double zaehler1,zaehler2,nenner1,nenner2,  
         value1, value2, factor;

  int    unit_dim[MAX_UNIT_NUMBER][MAX_DIM];
  double unit_coeff[MAX_UNIT_NUMBER];
  char   unit_char[MAX_UNIT_NUMBER][MAX_UNIT_CHAR];


  /* initialize */

  for (i=0;i<4;i++)
    for (j=0;j<MAX_DIM;j++)
       dim[i][j] = 0;

  /* load unit list */

  if ((unit_number=init_unit_list(unit_dim,unit_coeff,&unit_char))==0)
    return (0);
   

  /* 1. unit */

  teile_string(inputunit,in_zaehler, in_nenner); /* Nenner und Zaehler auseinanderrechnen */
  zaehler1 = convert2si(in_zaehler,&dim[0],unit_dim,unit_coeff,unit_char,unit_number);   /* SI-Wert des Nenners    */
  nenner1 = convert2si(in_nenner,&dim[1],unit_dim,unit_coeff,unit_char,unit_number);     /* SI-Wert des Zaehlers   */
  for (i=0;i<MAX_DIM;i++)                     /* Einheiten kürzen       */
    dim_in[i] = dim[0][i]-dim[1][i];
  if (nenner1)                                /* SI-Wert der 1. Einheit */
    value1 = zaehler1 / nenner1;

  /* 2. unit */

  teile_string(outputunit,out_zaehler, out_nenner); /* Nenner und Zaehler auseinanderrechnen */
  zaehler2 = convert2si(out_zaehler,&dim[2],unit_dim,unit_coeff,unit_char,unit_number);  /* SI-Wert des Nenners    */
  nenner2 = convert2si(out_nenner,&dim[3],unit_dim,unit_coeff,unit_char,unit_number);    /* SI-Wert des Zaehlers   */
  for (i=0;i<MAX_DIM;i++)                     /* Einheiten kürzen       */
    dim_out[i] = dim[2][i]-dim[3][i];
  if (nenner2)                                /* SI-Wert der 2. Einheit */
    value2 = zaehler2 / nenner2;

  /* calculate factor */

  if (value1)
    factor = value1/value2;
 
  /* check units */

  fehler = 0;
  for (i=0;i<MAX_DIM;i++)
     if (dim_in[i]!=dim_out[i])
        fehler = 1;
  if (fehler)
  {
     factor = 0;
     printf("error in units!\n");
     printf("input : ");
       if (dim_in[0])
          printf("m^%d",dim_in[0]);
       if (dim_in[1])
          printf(" kg^%d",dim_in[1]);
       if (dim_in[2])
          printf(" s^%d",dim_in[2]);
       if (dim_in[3])
          printf(" A^%d",dim_in[3]);
       if (dim_in[4])
          printf(" K^%d",dim_in[4]);
       if (dim_in[5])
          printf(" mol^%d",dim_in[5]);
       if (dim_in[6])
          printf(" cd^%d",dim_in[6]);
       printf("\n");
     printf("output: ");
       if (dim_out[0])
          printf("m^%d",dim_out[0]);
       if (dim_out[1])
          printf(" kg^%d",dim_out[1]);
       if (dim_out[2])
          printf(" s^%d",dim_out[2]);
       if (dim_out[3])
          printf(" A^%d",dim_out[3]);
       if (dim_out[4])
          printf(" K^%d",dim_out[4]);
       if (dim_out[5])
          printf(" mol^%d",dim_out[5]);
       if (dim_out[6])
          printf(" cd^%d",dim_out[6]);
       printf("\n");
   }
   if (outputflag)
   {
       if (dim_out[0])
          printf("m^%d",dim_out[0]);
       if (dim_out[1])
          printf(" kg^%d",dim_out[1]);
       if (dim_out[2])
          printf(" s^%d",dim_out[2]);
       if (dim_out[3])
          printf(" A^%d",dim_out[3]);
       if (dim_out[4])
          printf(" K^%d",dim_out[4]);
       if (dim_out[5])
          printf(" mol^%d",dim_out[5]);
       if (dim_out[6])
          printf(" cd^%d",dim_out[6]);
       printf("\n");
   }

   return factor;
}


#endif

