% unitconv_carnot (value, input_unit, output_unit, flag)
%
%   Input   value
%           input unit
%           output unit
%           print flag (1 = print SI-Unit,  0 = no output
%   
%   Output  converted double value
%
%  example unitconv(12,'kW*h','W*s',1)


% ***********************************************************************
% This file is part of the CARNOT Blockset.
% 
% Copyright (c) 1998-2015, Solar-Institute Juelich of the FH Aachen.
% Additional Copyright for this file see list auf authors.
% All rights reserved.
% 
% Redistribution and use in source and binary forms, with or without 
% modification, are permitted provided that the following conditions are 
% met:
% 
% 1. Redistributions of source code must retain the above copyright notice, 
%    this list of conditions and the following disclaimer.
% 
% 2. Redistributions in binary form must reproduce the above copyright 
%    notice, this list of conditions and the following disclaimer in the 
%    documentation and/or other materials provided with the distribution.
% 
% 3. Neither the name of the copyright holder nor the names of its 
%    contributors may be used to endorse or promote products derived from 
%    this software without specific prior written permission.
% 
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE 
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF 
% THE POSSIBILITY OF SUCH DAMAGE.
% $Revision$
% $Author$
% $Date$
% $HeadURL$
% **********************************************************************
% file history
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
% Syntax  unitconv_carnot
% Version  Author           Changes                                 Date
% 0.1.0    Thomas Wenzel    created                                 17jun1999
% 6.1.0    hf               comment out cutils.h                    21feb2015
% 6.1.1    hf               name changed to unitconv_carnot         02jun2015
%
% **********************************************************************
% D O C U M E N T A T I O N
% **********************************************************************
% unit      meaning                     used for
% galUK     gallon in UK                fluid volume
% galUS     gallon in US                fluid volume
% mmHg      millimeter Hg               pressure
% torr      millimeter Hg               pressure
% bar       pressure measurement        pressure
% atm       atmosphere                  pressure
% knot      ???seamile per hour         speed (of a boat)
%           unit_coeff[3] = 0.514444;
% cal       calory                      energy (heat)   
% min       Minute                      time
   
%    strcpy(unit_char+8*MAX_UNIT_CHAR,"bbl");
%    unit_coeff[8] = 0.158987;
   
%    strcpy(unit_char+10*MAX_UNIT_CHAR,"yd");
%    unit_coeff[10] = 0.914400;
%    
%    strcpy(unit_char+11*MAX_UNIT_CHAR,"hp");
%    unit_coeff[11] = 745.699870;
%    
%    strcpy(unit_char+12*MAX_UNIT_CHAR,"Pa");
%    unit_coeff[12] = 1.000000;
%    
%    strcpy(unit_char+13*MAX_UNIT_CHAR,"Hz");
%    unit_coeff[13] = 1.000000;
%    
%    strcpy(unit_char+14*MAX_UNIT_CHAR,"lb");
%    unit_coeff[14] = 0.453592;
%    
%    strcpy(unit_char+15*MAX_UNIT_CHAR,"oz");
%    unit_coeff[15] = 0.028350;
%    
%    strcpy(unit_char+16*MAX_UNIT_CHAR,"PS");
%    unit_coeff[16] = 735.498750;
%    
%    strcpy(unit_char+17*MAX_UNIT_CHAR,"ft");
%    unit_coeff[17] = 0.304800;
%    
%    strcpy(unit_char+18*MAX_UNIT_CHAR,"in");
%    unit_coeff[18] = 0.025400;
%    
%    strcpy(unit_char+19*MAX_UNIT_CHAR,"mi");
%    unit_coeff[19] = 1609.000000;
%    
%    strcpy(unit_char+20*MAX_UNIT_CHAR,"V");
%    unit_coeff[20] = 1.000000;
%    
%    strcpy(unit_char+21*MAX_UNIT_CHAR,"T");
%    unit_coeff[21] = 1.000000;
%    
%    strcpy(unit_char+22*MAX_UNIT_CHAR,"g");
%    unit_coeff[22] = 0.001000;
%    
%    strcpy(unit_char+23*MAX_UNIT_CHAR,"s");
%    unit_coeff[23] = 1.000000;
%    
%    strcpy(unit_char+24*MAX_UNIT_CHAR,"A");
%    unit_coeff[24] = 1.000000;
%    
%    strcpy(unit_char+25*MAX_UNIT_CHAR,"a");    /* Gemeinjahr = 365 d */
%    unit_coeff[25] = 31536000;
%    
%    strcpy(unit_char+26*MAX_UNIT_CHAR,"N");
%    unit_coeff[26] = 1.000000;
%    
%    strcpy(unit_char+27*MAX_UNIT_CHAR,"W");
%    unit_coeff[27] = 1.000000;
%    
%    strcpy(unit_char+28*MAX_UNIT_CHAR,"J");
%    unit_coeff[28] = 1.000000;
%    
%    strcpy(unit_char+29*MAX_UNIT_CHAR,"h");
%    unit_coeff[29] = 3600.000000;
%    
%    strcpy(unit_char+30*MAX_UNIT_CHAR,"m");
%    unit_coeff[30] = 1.000000;
%    unit_dim[0+MAX_DIM*30] = 1;
%    unit_dim[1+MAX_DIM*30] = 0;
%    unit_dim[2+MAX_DIM*30] = 0;
%    unit_dim[3+MAX_DIM*30] = 0;
%    
%    strcpy(unit_char+31*MAX_UNIT_CHAR,"l");
%    unit_coeff[31] = 0.001000;
%    unit_dim[0+MAX_DIM*31] = 3;
%    unit_dim[1+MAX_DIM*31] = 0;
%    unit_dim[2+MAX_DIM*31] = 0;
%    unit_dim[3+MAX_DIM*31] = 0;
%    i_unit = 32;    
%       
%     
%    strcpy(unit_char+32*MAX_UNIT_CHAR,"t");
%    unit_coeff[32] = 1000.000000;
%    unit_dim[0+MAX_DIM*32] = 0;
%    unit_dim[1+MAX_DIM*32] = 1;
%    unit_dim[2+MAX_DIM*32] = 0;
%    unit_dim[3+MAX_DIM*32] = 0;
%    unit_dim[4+MAX_DIM*i_unit] = 0;
%    i_unit = 33;    
% 
%    strcpy(unit_char+i_unit*MAX_UNIT_CHAR,"d");
%    unit_coeff[i_unit] = 86400.000000;
%    unit_dim[0+MAX_DIM*i_unit] = 0;
%    unit_dim[1+MAX_DIM*i_unit] = 0;
%    unit_dim[2+MAX_DIM*i_unit] = 1;
%    unit_dim[3+MAX_DIM*i_unit] = 0;
%    unit_dim[4+MAX_DIM*i_unit] = 0;
%    i_unit ++;    
% 
%    strcpy(unit_char+i_unit*MAX_UNIT_CHAR,"Btu");
%    unit_coeff[i_unit] = 745.7;
%    unit_dim[0+MAX_DIM*i_unit] = 2;
%    unit_dim[1+MAX_DIM*i_unit] = 1;
%    unit_dim[2+MAX_DIM*i_unit] = -3;
%    unit_dim[3+MAX_DIM*i_unit] = 0;
%    unit_dim[4+MAX_DIM*i_unit] = 0;
%    i_unit ++;    
% 
%    strcpy(unit_char+i_unit*MAX_UNIT_CHAR,"K");
%    unit_coeff[i_unit] = 1;
%    unit_dim[0+MAX_DIM*i_unit] = 0;
%    unit_dim[1+MAX_DIM*i_unit] = 0;
%    unit_dim[2+MAX_DIM*i_unit] = 0;
%    unit_dim[3+MAX_DIM*i_unit] = 0;
%    unit_dim[4+MAX_DIM*i_unit] = 1;
%    i_unit ++;    
% 
%    strcpy(unit_char+i_unit*MAX_UNIT_CHAR,"sm");
%    unit_coeff[i_unit] = 1852;
%    unit_dim[0+MAX_DIM*i_unit] = 1;
%    unit_dim[1+MAX_DIM*i_unit] = 0;
%    unit_dim[2+MAX_DIM*i_unit] = 0;
%    unit_dim[3+MAX_DIM*i_unit] = 0;
%    unit_dim[4+MAX_DIM*i_unit] = 0;
%    i_unit ++;    
% 
%    strcpy(unit_char+i_unit*MAX_UNIT_CHAR,"gr");
%    unit_coeff[i_unit] = 6.4799e-5;
%    unit_dim[0+MAX_DIM*i_unit] = 0;
%    unit_dim[1+MAX_DIM*i_unit] = 1;
%    unit_dim[2+MAX_DIM*i_unit] = 0;
%    unit_dim[3+MAX_DIM*i_unit] = 0;
%    unit_dim[4+MAX_DIM*i_unit] = 0;
%    i_unit ++;    
% 
%    strcpy(unit_char+i_unit*MAX_UNIT_CHAR,"c");
%    unit_coeff[i_unit] = 2.99792468e8;
%    unit_dim[0+MAX_DIM*i_unit] = 1;
%    unit_dim[1+MAX_DIM*i_unit] = 0;
%    unit_dim[2+MAX_DIM*i_unit] = -1;
%    unit_dim[3+MAX_DIM*i_unit] = 0;
%    unit_dim[4+MAX_DIM*i_unit] = 0;
%    i_unit ++;    
% 
%    strcpy(unit_char+i_unit*MAX_UNIT_CHAR,"ha");
%    unit_coeff[i_unit] = 10000;
%    unit_dim[0+MAX_DIM*i_unit] = 2;
%    unit_dim[1+MAX_DIM*i_unit] = 0;
%    unit_dim[2+MAX_DIM*i_unit] = 0;
%    unit_dim[3+MAX_DIM*i_unit] = 0;
%    unit_dim[4+MAX_DIM*i_unit] = 0;
%    i_unit ++;    
% 
%    strcpy(unit_char+i_unit*MAX_UNIT_CHAR,"G");
%    unit_coeff[i_unit] = 6.67529e-11;
%    unit_dim[0+MAX_DIM*i_unit] = 3;
%    unit_dim[1+MAX_DIM*i_unit] = -1;
%    unit_dim[2+MAX_DIM*i_unit] = -2;
%    unit_dim[3+MAX_DIM*i_unit] = 0;
%    unit_dim[4+MAX_DIM*i_unit] = 0;
%    i_unit ++;    
% 
%    strcpy(unit_char+i_unit*MAX_UNIT_CHAR,"e");
%    unit_coeff[i_unit] = 1.60217733e-19;
%    unit_dim[0+MAX_DIM*i_unit] = 0;
%    unit_dim[1+MAX_DIM*i_unit] = 0;
%    unit_dim[2+MAX_DIM*i_unit] = -1;
%    unit_dim[3+MAX_DIM*i_unit] = 1;
%    unit_dim[4+MAX_DIM*i_unit] = 0;
%    i_unit ++;    
% 
%    strcpy(unit_char+i_unit*MAX_UNIT_CHAR,"NA");
%    unit_coeff[i_unit] = 6.0221367e23;
%    unit_dim[0+MAX_DIM*i_unit] = 0;
%    unit_dim[1+MAX_DIM*i_unit] = 0;
%    unit_dim[2+MAX_DIM*i_unit] = 0;
%    unit_dim[3+MAX_DIM*i_unit] = 0;
%    unit_dim[4+MAX_DIM*i_unit] = 0;
%    unit_dim[5+MAX_DIM*i_unit] = -1;
%    unit_dim[6+MAX_DIM*i_unit] = 0;         /* cd  */
%    i_unit ++;    
% 
%    strcpy(unit_char+i_unit*MAX_UNIT_CHAR,"Rm");
%    unit_coeff[i_unit] = 8.314510;
%    unit_dim[0+MAX_DIM*i_unit] = 2;         /* m */
%    unit_dim[1+MAX_DIM*i_unit] = 1;         /* kg */
%    unit_dim[2+MAX_DIM*i_unit] = -2;         /* s  */
%    unit_dim[3+MAX_DIM*i_unit] = 0;         /* A  */
%    unit_dim[4+MAX_DIM*i_unit] = -1;        /* K  */
%    unit_dim[5+MAX_DIM*i_unit] = -1;        /* mol */
%    unit_dim[6+MAX_DIM*i_unit] = 0;         /* cd  */
%    i_unit ++;    
% 
%    strcpy(unit_char+i_unit*MAX_UNIT_CHAR,"µ0");
%    unit_coeff[i_unit] = 12.5663706143592e-7;
%    unit_dim[0+MAX_DIM*i_unit] = 1;          /* m   */
%    unit_dim[1+MAX_DIM*i_unit] = 1;          /* kg  */
%    unit_dim[2+MAX_DIM*i_unit] = -2;         /* s   */
%    unit_dim[3+MAX_DIM*i_unit] = -2;         /* A   */
%    unit_dim[4+MAX_DIM*i_unit] = 0;          /* K   */
%    unit_dim[5+MAX_DIM*i_unit] = 0;          /* mol */
%    i_unit ++;    
% 
%    strcpy(unit_char+i_unit*MAX_UNIT_CHAR,"eps0");
%    unit_coeff[i_unit] = 8.85418781762e-12;
%    unit_dim[0+MAX_DIM*i_unit] = -3;         /* m   */
%    unit_dim[1+MAX_DIM*i_unit] = -1;         /* kg  */
%    unit_dim[2+MAX_DIM*i_unit] = 4;          /* s   */
%    unit_dim[3+MAX_DIM*i_unit] = 2;          /* A   */
%    unit_dim[4+MAX_DIM*i_unit] = 0;          /* K   */
%    unit_dim[5+MAX_DIM*i_unit] = 0;          /* mol */
%    unit_dim[6+MAX_DIM*i_unit] = 0;         /* cd  */
%    i_unit ++;    
% 
%    strcpy(unit_char+i_unit*MAX_UNIT_CHAR,"u");
%    unit_coeff[i_unit] = 1.6605402e-27;
%    unit_dim[0+MAX_DIM*i_unit] = 0;         /* m   */
%    unit_dim[1+MAX_DIM*i_unit] = 1;         /* kg  */
%    unit_dim[2+MAX_DIM*i_unit] = 0;         /* s   */
%    unit_dim[3+MAX_DIM*i_unit] = 0;         /* A   */
%    unit_dim[4+MAX_DIM*i_unit] = 0;         /* K   */
%    unit_dim[5+MAX_DIM*i_unit] = 0;         /* mol */
%    unit_dim[6+MAX_DIM*i_unit] = 0;         /* cd  */
%    i_unit ++;    
% 
%    strcpy(unit_char+i_unit*MAX_UNIT_CHAR,"kb");
%    unit_coeff[i_unit] = 1.380658e-23;
%    unit_dim[0+MAX_DIM*i_unit] = 2;         /* m   */
%    unit_dim[1+MAX_DIM*i_unit] = 1;         /* kg  */
%    unit_dim[2+MAX_DIM*i_unit] = -2;        /* s   */
%    unit_dim[3+MAX_DIM*i_unit] = 0;         /* A   */
%    unit_dim[4+MAX_DIM*i_unit] = -1;         /* K   */
%    unit_dim[5+MAX_DIM*i_unit] = 0;         /* mol */
%    unit_dim[6+MAX_DIM*i_unit] = 0;         /* cd  */
%    i_unit ++;    
% 
%    strcpy(unit_char+i_unit*MAX_UNIT_CHAR,"eV");
%    unit_coeff[i_unit] = 1.60217733e-19;
%    unit_dim[0+MAX_DIM*i_unit] = 2;         /* m   */
%    unit_dim[1+MAX_DIM*i_unit] = 1;         /* kg  */
%    unit_dim[2+MAX_DIM*i_unit] = -2;        /* s   */
%    unit_dim[3+MAX_DIM*i_unit] = 0;         /* A   */
%    unit_dim[4+MAX_DIM*i_unit] = 0;         /* K   */
%    unit_dim[5+MAX_DIM*i_unit] = 0;         /* mol */
%    unit_dim[6+MAX_DIM*i_unit] = 0;         /* cd  */
%    i_unit ++;    
% 
%    strcpy(unit_char+i_unit*MAX_UNIT_CHAR,"dpt");
%    unit_coeff[i_unit] = 1;
%    unit_dim[0+MAX_DIM*i_unit] = -1;        /* m   */
%    unit_dim[1+MAX_DIM*i_unit] = 0;         /* kg  */
%    unit_dim[2+MAX_DIM*i_unit] = 0;         /* s   */
%    unit_dim[3+MAX_DIM*i_unit] = 0;         /* A   */
%    unit_dim[4+MAX_DIM*i_unit] = 0;         /* K   */
%    unit_dim[5+MAX_DIM*i_unit] = 0;         /* mol */
%    unit_dim[6+MAX_DIM*i_unit] = 0;         /* cd  */
%    i_unit ++;    
% 
%    strcpy(unit_char+i_unit*MAX_UNIT_CHAR,"AE");
%    unit_coeff[i_unit] = 1.4959787e11;
%    unit_dim[0+MAX_DIM*i_unit] = 1;         /* m   */
%    unit_dim[1+MAX_DIM*i_unit] = 0;         /* kg  */
%    unit_dim[2+MAX_DIM*i_unit] = 0;         /* s   */
%    unit_dim[3+MAX_DIM*i_unit] = 0;         /* A   */
%    unit_dim[4+MAX_DIM*i_unit] = 0;         /* K   */
%    unit_dim[5+MAX_DIM*i_unit] = 0;         /* mol */
%    unit_dim[6+MAX_DIM*i_unit] = 0;         /* cd  */
%    i_unit ++;    
% 
%    strcpy(unit_char+i_unit*MAX_UNIT_CHAR,"lj");
%    unit_coeff[i_unit] = 9.4605e15;
%    unit_dim[0+MAX_DIM*i_unit] = 1;         /* m   */
%    unit_dim[1+MAX_DIM*i_unit] = 0;         /* kg  */
%    unit_dim[2+MAX_DIM*i_unit] = 0;         /* s   */
%    unit_dim[3+MAX_DIM*i_unit] = 0;         /* A   */
%    unit_dim[4+MAX_DIM*i_unit] = 0;         /* K   */
%    unit_dim[5+MAX_DIM*i_unit] = 0;         /* mol */
%    unit_dim[6+MAX_DIM*i_unit] = 0;         /* cd  */
%    i_unit ++;    
% 
%    strcpy(unit_char+i_unit*MAX_UNIT_CHAR,"pc");
%    unit_coeff[i_unit] = 3.0857e16;
%    unit_dim[0+MAX_DIM*i_unit] = 1;         /* m   */
%    unit_dim[1+MAX_DIM*i_unit] = 0;         /* kg  */
%    unit_dim[2+MAX_DIM*i_unit] = 0;         /* s   */
%    unit_dim[3+MAX_DIM*i_unit] = 0;         /* A   */
%    unit_dim[4+MAX_DIM*i_unit] = 0;         /* K   */
%    unit_dim[5+MAX_DIM*i_unit] = 0;         /* mol */
%    unit_dim[6+MAX_DIM*i_unit] = 0;         /* cd  */
%    i_unit ++;    
% 
%    strcpy(unit_char+i_unit*MAX_UNIT_CHAR,"erg");
%    unit_coeff[i_unit] = 1e-7;
%    unit_dim[0+MAX_DIM*i_unit] = 2;         /* m   */
%    unit_dim[1+MAX_DIM*i_unit] = 1;         /* kg  */
%    unit_dim[2+MAX_DIM*i_unit] = -2;        /* s   */
%    unit_dim[3+MAX_DIM*i_unit] = 0;         /* A   */
%    unit_dim[4+MAX_DIM*i_unit] = 0;         /* K   */
%    unit_dim[5+MAX_DIM*i_unit] = 0;         /* mol */
%    unit_dim[6+MAX_DIM*i_unit] = 0;         /* cd  */
%    i_unit ++;    
% 
%    strcpy(unit_char+i_unit*MAX_UNIT_CHAR,"cd");
%    unit_coeff[i_unit] = 1;
%    unit_dim[0+MAX_DIM*i_unit] = 0;         /* m   */
%    unit_dim[1+MAX_DIM*i_unit] = 0;         /* kg  */
%    unit_dim[2+MAX_DIM*i_unit] = 0;         /* s   */
%    unit_dim[3+MAX_DIM*i_unit] = 0;         /* A   */
%    unit_dim[4+MAX_DIM*i_unit] = 0;         /* K   */
%    unit_dim[5+MAX_DIM*i_unit] = 0;         /* mol */
%    unit_dim[6+MAX_DIM*i_unit] = 1;         /* cd  */
%    i_unit ++;    
% 
%    strcpy(unit_char+i_unit*MAX_UNIT_CHAR,"F");
%    unit_coeff[i_unit] = 1;
%    unit_dim[0+MAX_DIM*i_unit] = -2;        /* m   */
%    unit_dim[1+MAX_DIM*i_unit] = -1;        /* kg  */
%    unit_dim[2+MAX_DIM*i_unit] = 4;         /* s   */
%    unit_dim[3+MAX_DIM*i_unit] = 2;         /* A   */
%    unit_dim[4+MAX_DIM*i_unit] = 0;         /* K   */
%    unit_dim[5+MAX_DIM*i_unit] = 0;         /* mol */
%    unit_dim[6+MAX_DIM*i_unit] = 0;         /* cd  */
%    i_unit ++;    
% 
%    strcpy(unit_char+i_unit*MAX_UNIT_CHAR,"C");
%    unit_coeff[i_unit] = 1;
%    unit_dim[0+MAX_DIM*i_unit] = 0;         /* m   */
%    unit_dim[1+MAX_DIM*i_unit] = 0;         /* kg  */
%    unit_dim[2+MAX_DIM*i_unit] = 1;         /* s   */
%    unit_dim[3+MAX_DIM*i_unit] = 1;         /* A   */
%    unit_dim[4+MAX_DIM*i_unit] = 0;         /* K   */
%    unit_dim[5+MAX_DIM*i_unit] = 0;         /* mol */
%    unit_dim[6+MAX_DIM*i_unit] = 0;         /* cd  */
%    i_unit ++;    
% 
%    strcpy(unit_char+i_unit*MAX_UNIT_CHAR,"Wb");
%    unit_coeff[i_unit] = 1;
%    unit_dim[0+MAX_DIM*i_unit] = 2;         /* m   */
%    unit_dim[1+MAX_DIM*i_unit] = 1;         /* kg  */
%    unit_dim[2+MAX_DIM*i_unit] = -2;         /* s   */
%    unit_dim[3+MAX_DIM*i_unit] = -1;         /* A   */
%    unit_dim[4+MAX_DIM*i_unit] = 0;         /* K   */
%    unit_dim[5+MAX_DIM*i_unit] = 0;         /* mol */
%    unit_dim[6+MAX_DIM*i_unit] = 0;         /* cd  */
%    i_unit ++;    
% 
%    strcpy(unit_char+i_unit*MAX_UNIT_CHAR,"T");
%    unit_coeff[i_unit] = 1;
%    unit_dim[0+MAX_DIM*i_unit] = 0;         /* m   */
%    unit_dim[1+MAX_DIM*i_unit] = 1;         /* kg  */
%    unit_dim[2+MAX_DIM*i_unit] = -2;         /* s   */
%    unit_dim[3+MAX_DIM*i_unit] = -1;         /* A   */
%    unit_dim[4+MAX_DIM*i_unit] = 0;         /* K   */
%    unit_dim[5+MAX_DIM*i_unit] = 0;         /* mol */
%    unit_dim[6+MAX_DIM*i_unit] = 0;         /* cd  */
%    i_unit ++;    
% 
%    strcpy(unit_char+i_unit*MAX_UNIT_CHAR,"S");
%    unit_coeff[i_unit] = 1;
%    unit_dim[0+MAX_DIM*i_unit] = -2;        /* m   */
%    unit_dim[1+MAX_DIM*i_unit] = -1;        /* kg  */
%    unit_dim[2+MAX_DIM*i_unit] = 3;         /* s   */
%    unit_dim[3+MAX_DIM*i_unit] = 2;         /* A   */
%    unit_dim[4+MAX_DIM*i_unit] = 0;         /* K   */
%    unit_dim[5+MAX_DIM*i_unit] = 0;         /* mol */
%    unit_dim[6+MAX_DIM*i_unit] = 0;         /* cd  */
%    i_unit ++;    
% 
%    strcpy(unit_char+i_unit*MAX_UNIT_CHAR,"Ohm");
%    unit_coeff[i_unit] = 1;
%    unit_dim[0+MAX_DIM*i_unit] = 2;         /* m   */
%    unit_dim[1+MAX_DIM*i_unit] = 1;         /* kg  */
%    unit_dim[2+MAX_DIM*i_unit] = -3;        /* s   */
%    unit_dim[3+MAX_DIM*i_unit] = -2;        /* A   */
%    unit_dim[4+MAX_DIM*i_unit] = 0;         /* K   */
%    unit_dim[5+MAX_DIM*i_unit] = 0;         /* mol */
%    unit_dim[6+MAX_DIM*i_unit] = 0;         /* cd  */
%    i_unit ++;    
% 
%    strcpy(unit_char+i_unit*MAX_UNIT_CHAR,"Bq");
%    unit_coeff[i_unit] = 1;
%    unit_dim[0+MAX_DIM*i_unit] = 0;         /* m   */
%    unit_dim[1+MAX_DIM*i_unit] = 0;         /* kg  */
%    unit_dim[2+MAX_DIM*i_unit] = -1;        /* s   */
%    unit_dim[3+MAX_DIM*i_unit] = 0;         /* A   */
%    unit_dim[4+MAX_DIM*i_unit] = 0;         /* K   */
%    unit_dim[5+MAX_DIM*i_unit] = 0;         /* mol */
%    unit_dim[6+MAX_DIM*i_unit] = 0;         /* cd  */
%    i_unit ++;    
% 
%    strcpy(unit_char+i_unit*MAX_UNIT_CHAR,"b");
%    unit_coeff[i_unit] = 1e-28;
%    unit_dim[0+MAX_DIM*i_unit] = 2;         /* m   */
%    unit_dim[1+MAX_DIM*i_unit] = 0;         /* kg  */
%    unit_dim[2+MAX_DIM*i_unit] = 0;         /* s   */
%    unit_dim[3+MAX_DIM*i_unit] = 0;         /* A   */
%    unit_dim[4+MAX_DIM*i_unit] = 0;         /* K   */
%    unit_dim[5+MAX_DIM*i_unit] = 0;         /* mol */
%    unit_dim[6+MAX_DIM*i_unit] = 0;         /* cd  */
%    i_unit ++;    
% 
% 