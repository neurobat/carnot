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
 * This MEX-file is the interface from m-files to the carnot-library
 * carlib and its functions for the fluid properties
 *
 *     Syntax  [sys, x0] = fluidprop(t,x,u,flag,x(1),x(2),x(3),x0)
 *
 * Author list
 *  Bernd Hafner -> hf
 *  Gaelle Faure -> gf
 *  Thomas Wenzel -> tw
 *  Pierre Charles -> pc
 *
 * version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
 *
 * Version  Author  Changes                                         Date
 * 0.9.0    hf      created                                         03dez98
 * 0.11.0   hf      include saturation temperature                  28jan99
 * 0.11.1   hf      vectorized inputs                               28jan99
 * 0.11.2   hf      new functions and input range check             10jun99
 * 0.11.3   tw      saturationproperty                              27sep99
 * 4.1.0    gf      warning messages more precise                   14dec10
 * 4.1.1    hf      include enthalpy2temperature                    30jan2011
 * 4.1.2    hf      line319: case WATERGLYCOL:                      16mar2011
 *                  if (0 < t[id] -> changed to if (t[id] < 0
 * 4.1.3    pc      Tyfocor LS added                                20apr2011
 * 4.1.4    gf      test of too many iterations for                 08nov2011
 *                  enthalpy2temperature 
 * 6.1.0    hf      revised warning 'vapourpressure only available  20oct2016
 *                  for water', function also available for air and
 *                  gylocol mixtures
 *
 * Copyright (c) 1998-2016 Solar-Institut Juelich, Germany
 *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *  D E S C R I P T I O N
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *        
 * structure of u (input vector)
 * index use
 * 0    temperature                                         degree centigrade
 * 1    pressure                                            Pa  
 * 2    fluid ID (defined in CARNOT.h)                 
 * 3    mixture  (defined in CARNOT.h)                 
 * 4    type of property
 *
 *
 * structure of y (output vector)
 *  index   use
 *  0       fluid property
 *
   In this function is checked, if temperature and pressure are in a 
   valid range. Otherwise a warning is printed.

   Following values are valid for temperature and pressure:
    [T] = °C
    [p] = bar
 
    density	        WATER,V			  T <  800 			  p < 490
                	WATER,L			  T <  800 			  p < 200
        	        AIR	          0 < T < 1000	      1 < p < 200
            	    COTOIL			  T <  250			  p =   1
        	        SILOIL			  T <  250			  p =   1
            	    WATERGLYKOL   0 < T <  100			  p =   1
                    TYFOCOR LS  -30 < T <  120            p =   1
    enthalpy        WATER,V			  T <  800			  p < 490
                	WATER,L	      0 < T <  200	   0,01 < p < 100
            	    AIR	          0 < T <  800	      1 < p < 100
                    TYFOCOR LS  -30 < T <  120 or Tsat    p =   1
    entropy	        WATER,V	      0 < T <  800	      1 < p < 490
        	        WATER,L	      0 < T <  300	    0,1 < p < 100
            	    AIR	          0 < T < 1000	      1 < p <  20
    heat_capacity	WATER,V	     50 < T <  450	    0,1 < p <  20
                	WATER,L	      0 < T <  450			  p < 100
        	        AIR	          0 < T <  500			  p =   1
            	    COTOIL			  T <  250			  p =   1
    	            SILOIL			  T <  250			  p =   1
                	WATERGLYKOL	  0 < T <  100			  p =   1
                    TYFOCOR LS  -30 < T <  120            p =   1
    kin_viscosity	WATER,V	     50 < T <  500	    0,1 < p < 200
    	            WATER,L	      0 < T <  160	      1 < p < 100
                	AIR	          0 < T <  400				
                	COTOIL			  T <  250			  p =   1
    	            SILOIL			  T <  250			  p =   1
                	WATERGLYKOL	  0 < T <  100			  p =   1
                    TYFOCOR LS  -30 < T <  120            p =   1
    sat.temp.	    WATER			  T <  Tkrit		  p < Pkrit
                    TYFOCOR LS   40 < T <  200            p =   1
    spec.volume	    WATER,V	     50 < T <  800	      1 < p < 490
            	    WATER,L	      0 < T <  800        1 < p < 200
        	        AIR	          0 < T < 1000	      1 < p < 100
            	    COTOIL			  T <  250			  p =   1
        	        SILOIL			  T <  250			  p =   1
                	WATERGLYKOL	  0 < T <  100			  p =   1
                    TYFOCOR LS  -30 < T <  120            p =   1
    therm.conduct.	WATER,V	     50 < T <  400	    0,1 < p <  20
                	WATER,L	      0 < T <  800	      1 < p < 100
                	AIR	          0 < T <  400			  p =   1
                	COTOIL			  T <  250			  p =   1
                	SILOIL			  T <  250			  p =   1
                	WATERGLYKOL   0 < T <  100			  p =   1
                    TYFOCOR LS  -30 < T <  120            p =   1
    prandtl	        WATER,V	 	      T <  800			  p < 490
                	WATER,L	      0 < T <  160					
                	AIR	          0 < T <  400	    0,9 < p <   1,1
                	COTOIL			  T <  200					
                	SILOIL			  T <  200					
                	WATERGLYKOL	  0 < T <  100			
                    TYFOCOR LS  -30 < T <  120            p =   1		
    evap-enthalpy	WATER,L			  T <  Tkrit		  p < Pkrit
    vap.pressure	WATER		  	  T <  Tkrit		  p < Pkrit
                    TYFOCOR LS   40 < T <  200            p =   1

*/





/*
 *   Einfügen von saturationproperty
 * 
 *   Bei Aufruf von Saturationproperty wird dieselbe Property-ID benutzt,
 *   wie beim Aufruf von fluidprop. 
 *   Will man die Sättigungswerte wissen, dann muß diese prop-ID aber negativ sein.
 *   Außerdem erhält man jetzt doppelt soviele Werte, jeweils für den flüssigen
 *   und den gasförmigen Zustand.
 *   Daher wird in der mex-Funktion die Anzahl der Zeilen (rows) verdoppelt.
 *   Dadurch erhält man statt eines Vektors jetzt eine Matrix als Ausgabe.
 *
 */
 

#include "mex.h"
#include "carlib.h" 


void fluidprop(double x[], double ft[], double fm[], double t[], double p[],
    double prop[], int num[])
/* x is pointer for return value
 */
{
    int propi;
    int n, id[4], pos, np[4], m;
    int material;  
    double stateswitch;
    double* temp;

//     // nur zeitweise
//      double tu,to,t3,hm,dh1,dh2,stepsize;
//      int iterations = 0;
//     // nur zeitweise
    
    if (prop[0]>=0)
       propi = (int)(prop[0]+0.5);
    else
       propi = (int)(prop[0]-0.5);

    pos = 0;
    for (n = 0; n < 4; n++) {
        np[n] = 0;
        if (num[n] > 1) {
            pos = n;     /* keep position of vector input */
            np[n] = 1;   /* flag for vector */
        }
        id[n] = 0;
    }

    material = (int)(ft[id[2]]+0.5);

    if ( (ft[id[2]]==WATER || ft[id[2]]==WATERGLYCOL || ft[id[2]]==TYFOCOR_LS)   /* mix in [0..1] ? */
        && (fm[id[3]]<0 || fm[id[3]]>1) )
         mexErrMsgTxt ("Error while evaluating fluidprop.\n" 
                       "Mixture has to be in [0..1].\n");
    else
    {
         
    stateswitch = (int) vapourpressure(ft[id[2]], fm[id[3]], t[id[0]], p[id[1]]);

    for (n = 0; n < num[pos]; n++) /* loop over vector length */
    {
       
        for (m = 0; m < 4; m++) {
            if (np[m]) id[m] = n; /* check vector flag and increment index if necessary */
        }
        if (propi>=0)
        switch (propi)
        {
            case ENTHALPY2TEMPERATURE:
                temp = malloc(2*sizeof(double));
                temp = enthalpy2temperature(ft[id[2]], fm[id[3]], t[id[0]], p[id[1]]);
                x[n] = temp[0];
                if (temp[1] >= 200.0)
                    printf("WARNING : in enthalpy2temperature, maximum authorized iterations (200) exceeded.\n");
//                 x[n] = enthalpy2temperature(ft[id[2]], fm[id[3]], t[id[0]], p[id[1]]);
                break;
                
            case DENSITY:
                 switch (material)
                 {
                    case WATER:
                         if (p[id[1]] < stateswitch || stateswitch < 0)
                         {/* water is vaporous */  
                             if (t[id[0]] > 800.0)
                                 printf ("Warning in density: temperature out of range! \n"
                                         "        Valid temperature range below 800°C \n");
                             if (p[id[1]] > 4.9033e7)
                                 printf ("Warning in density: pressure out of range!\n"
                                         "        Valid pressure range from 49.033 MPa");
                         }
                         else
                         {
                             if (t[id[0]] > 800.0)
                                 printf ("Warning in density: temperature out of range! \n"
                                         "        Valid temperature range below 800°C \n");
                             if (p[id[1]] > 2.0e7)
                                 printf ("Warning in density: pressure out of range!\n"
                                         "        Valid pressure range from 49.033 MPa\n");
                         }
                         /* liquid water no limits of temperature or pressure */
                         break;  
                    case AIR:
                         if (t[id[0]] < 0.0 || t[id[0]] > 1000.0)
                             printf("Warning in density: temperaure out of range!\n"
                                    "        Valid range of temperature from 0°C to 1000°C\n");
                         
                         if (p[id[1]] < 1.0e5 || p[id[1]] > 1.0e7)
                             printf("Warning in density: pressure out of range!\n"
                                    "        Valid range of pressure from 1 to 100 bar\n");
                         break;
                    case COTOIL: case SILOIL:
                         if (t[id[0]] > 250.0)
                             printf ("Warning in density: temperature out of range!\n"
                                     "        Temperatures up to 250°C are valid\n");
                         if (p[id[1]] > 1.1e5 || p[id[1]] < 0.9e5)
                             printf ("Warning in density: pressure out of range!\n"
                                     "        Valid pressure is 1e5 Pa\n");
                         break;              
                    case WATERGLYCOL:
                         if (t[id[0]]<0.0 || t[id[0]] > 100.0)
                             printf ("Warning in density: temperature out of range of interpolation!\n"
                                     "        Values are interpolated  between 0°C and 100 °C");
                         if (p[id[1]] > 1.1e5 || p[id[1]] < 0.9e5)
                             printf ("Warning in density: pressure out of range!\n"
                                     "        Valid pressure is 1e5 Pa\n");
                         break;
                    case TYFOCOR_LS:
                         if (t[id[0]]<-30.0 || t[id[0]] > 120.0)
                             printf ("Warning in density: temperature out of range of interpolation!\n"
                                     "        Values are interpolated  between -30°C and 120 °C");
                         break;
                 } /* end switch material */
                 x[n] = density(ft[id[2]], fm[id[3]], t[id[0]], p[id[1]]);
                 if (x[n] < 0.0)
                    mexErrMsgTxt ("Error while evaluating density.\n" 
                                  "Check the range of your input variables.");
                 break;
                  
            case HEAT_CAPACITY:
                 switch (material)
                 {   
                    case WATER:
                         if (p[id[1]] <= stateswitch)
                         {   /* water is vaporous */
                             if (t[id[0]] < 50.0 || t[id[0]] > 450.0)
                                 printf ("Warning in heat capacity: temperature out of range!\n"
                                         "        Valid temperature range: 50°C to 450°C\n");
                             if (p[id[1]] < 1.0e4 || p[id[1]] > 2.0e6)
                                 printf ("Warning in heat capacity: pressure out of range!\n"
                                         "        Valid pressure range 0,01 MPa to 2 MPa\n");  
                         }
                         else 
                         { /* fluid is liquid */    
                            if (t[id[0]] < 0.0 || t[id[0]] > 450.0)
                                printf ("Warning in heat capacity: temperature out of range!\n" 
                                        "        Valid temperature range: 0°C to 450°C\n");
                            
                            if (p[id[1]] < 1.0e5 || p[id[1]] > 1.0e7)
                                 printf ("Warning in heat capacity: pressure out of range!\n"
                                         "        Valid pressure range 0,1 MPa to 10 MPa\n");  
                         }
                         break;
                    case AIR: 
                         if (p[id[1]] < 0.9e5 || p[id[1]] > 1.1e5)
                             printf("Warning in heat capacity:\n"
                                    "        Valid pressure is only p = 1 bar!\n");
                         if (fm[id[3]] == 0)
                            if (t[id[0]] < -100 || t[id[0]] > 500)
                                 printf("Warning in heat capacity:\n"
                                        "        Valid temperature range: -100 °C to 500°C\n");
                             
                            if (fm[id[3]]!=0)
                                {if (t[id[0]] < 50.0 || t[id[0]] > 400.0)
                                    printf("Warning in heat capacity:\n"
                                           "    Valid temperature range: 50 °C to 400°C\n");              
                                }
                         break;
                    case COTOIL: case SILOIL:
                         if (t[id[0]] > 250.0)
                            printf ("Warning in heat capacity:\n"
                                    "        Valid temperature range up to 250°C\n");
                         
                         break;                      
                    case WATERGLYCOL:
                         if (t[id[0]] < 0.0 || t[id[0]] > 100.0)
                             printf ("Warning in heat capacity:\n"
                                     "        temperature out of range of interpolation!\n"
                                     "        Values are interpolated  between 0°C and 100 °C\n");
                         break;
                         
                    case TYFOCOR_LS:
                         if (t[id[0]]<-30.0 || t[id[0]] > 120.0)
                             printf ("Warning in density: temperature out of range of interpolation!\n"
                                     "        Values are interpolated  between -30°C and 120 °C");
                         break;
                 } /* end switch material */
                 x[n] = heat_capacity(ft[id[2]], fm[id[3]], t[id[0]], p[id[1]]);
                 if (x[n] < 0.0)
                     mexErrMsgTxt ("An error occured while evaluation the heat capacity.\n" 
                                   "Check the range of the inputs.\n");
                break;
            case THERMAL_CONDUCTIVITY:
                 switch (material)
                 {
                    case WATER:                 
                         if (p[id[1]] < stateswitch)
                         {   /* water is vaporous */
                            if (t[id[0]] < 50.0 || t[id[0]] > 400.0)
                                printf ("Warning in thermal conductivity : temperature out of range!\n"
                                        "Valid temperature range from 50°C to 400°C");
                            if (p[id[1]] < 1.0e4 || p[id[1]] > 2.0e6)
                                printf ("Warning in thermal conductivity: pressure out of range!\n"
                                        "Valid pressure range from 0,01 MPa and 2 MPa");
                         }else { /* water is liquid */
                               if (t[id[0]] < 0.0 || t[id[0]] > 800.0)
                                   printf ("Warning in thermal conductivity: temperature out of range!\n" 
                                           "Valid temperature range from 0°C to 800°C");
                               if (p[id[1]] < 1.0e5 || p[id[1]] > 1.0e7)
                                   printf ("Warning in thermal conductivity: pressure out of range!\n"
                                           "Valid pressure range from 0,1 MPa and 10 MPa");
                         }
                         break;
                    case AIR:
                         if (p[id[1]] < 0.9e5 || p[id[1]] > 1.1e5)
                            printf("Warning in thermal conductivity:\n"
                                   "        pressure is only valid for p = 1 bar!");
                             
                         if (fm[id[3]] == 0)
                                {if (t[id[0]] < 0.0 || t[id[0]] > 400.0)
                                      printf("Warning in thermal conductivity:\n"
                                             "        Valid temperature range: t = 0°C to 400 °C");
                                      
                                }
                         break;
                    case COTOIL: case SILOIL:                 
                         if (t[id[0]] > 250.0)
                            printf ("Warning in thermal conductivity: temperature out of range!\n"
                                    "Values are valid up to 250°C");
                         if (p[id[1]] > 1.1e5 || p[id[1]] < 0.9e5)
                             printf ("Warning in thermal conductivity: pressure out of range!\n"
                                     "Valid pressure is 1e5 Pa\n");
                            
                         break;               
                    case WATERGLYCOL:
                         if (t[id[0]] > 100.0 || t[id[0]] < 0.0)
                            printf ("Warning in thermal conductivity: temperature out of range of interpolation!\n"
                                     "Values are interpolated  between 0°C and 100 °C");
                         if (p[id[1]] > 1.1e5 || p[id[1]] < 0.9e5)
                             printf ("Warning in thermal conductivity: pressure out of range!\n"
                                     "Valid pressure is 1e5 Pa\n");
                            
                         break;
                    case TYFOCOR_LS:
                         if (t[id[0]] < -30.0 || t[id[0]] > 120.0)
                             printf ("Warning in density: temperature out of range of interpolation!\n"
                                     "        Values are interpolated  between -30°C and 120 °C");
                         break;
                 }  /* end switch material */
                 x[n] = thermal_conductivity(ft[id[2]], fm[id[3]], t[id[0]], p[id[1]]);
                 if (x[n] < 0.0)
                     mexErrMsgTxt ("An error occured while evaluation the heat conductivity.\n" 
                                   "Check the range of the inputs.");
                 break;

            case VISCOSITY:
                 switch (material)
                 {
                    case WATER:                
                    /* Range check of state variables */
                         if (p[id[1]] < stateswitch) 
                            { /* water is vaporous */
                            if (t[id[0]] < 50.0 || t[id[0]] > 500.0)
                                printf ("Warning in viscosity: temperature out of range!\n"
                                        "The temperature must be between 50°C and 500°C\n");
                            if (p[id[1]] < 1.0e4 || p[id[1]] > 2.0e7)
                                printf ("Warning in viscosity: pressure out of range!\n"
                                        "The pressure must be between 0.01 MPa and 20 MPa\n");
                        }else 
                            { /* water is liquid */
                             if (t[id[0]] < 0.0 || t[id[0]] > 160.0)
                                 printf ("Warning in viscosity: temperature out of range!\n" 
                                         "Valid temperature range from 0°C to 160°C\n");
                             if (p[id[1]] < 1.0e5 || p[id[1]] > 1.0e7)
                                 printf ("Warning in viscosity: pressure out of range!\n"
                                         "The pressure must be between 0.1 MPa and 10 MPa\n");
                            }
                         break;
                    case AIR: if (t[id[0]] < 0.0 || t[id[0]] > 400.0)
                                 printf ("Warning in viscosity: temperature out of range!\n" 
                                         "Valid temperature range from 0°C to 400°C\n");
                              if (p[id[1]] < 1.0e5-1 || p[id[1]] > 1.0e5+1)
                                  printf("Warning in viscosity: pressure is only valid for p = 1 bar!\n");
                              if (fm[id[3]] == 0)
                                  {if (t[id[0]] < -20.0 || t[id[0]] > 200.0)
                                      printf("Warning in viscosity: Valid temperature range from -20 °C to 200°C\n");              
                                  }
                         break;
                    case COTOIL: case SILOIL:
                         if (t[id[0]] > 250)
                             printf ("Warning in viscosity: temperature out of range!\n"
                                     "Values are valid up to 250°C\n");
                         if (p[id[1]] > 1.1e5 || p[id[1]] < 0.9e5)
                             printf ("Warning in viscosity: pressure out of range!\n"
                                     "Valid pressure is 1e5 Pa\n");
                         break;
                    case WATERGLYCOL:
                         if (t[id[0]] < 0.0 || t[id[0]] > 100.0)
                             printf ("Warning in viscosity: temperature out of range of interpolation!\n"
                                     "Values are interpolated  between 0°C and 100°C\n");
                         if (p[id[1]] > 1.1e5 || p[id[1]] < 0.9e5)
                             printf ("Warning in viscosity: pressure out of range!\n"
                                     "Valid pressure is 1e5 Pa\n");
                         break;
                    case TYFOCOR_LS:
                         if (t[id[0]] < -30.0 || t[id[0]] > 120.0)
                             printf ("Warning in density: temperature out of range of interpolation!\n"
                                     "        Values are interpolated  between -30°C and 120 °C");
                         break;
                  } /* end switch material */
                  x[n] = viscosity(ft[id[2]], fm[id[3]], t[id[0]], p[id[1]]);
                  if (x[n] < 0.0)
                      mexErrMsgTxt ("An error occured while evaluation the kinematic viscosity.\n" 
                                    "Check the range of the inputs.\n");
                  break;

            case ENTHALPY:
                /* Range check of state variables */
                 switch (material)
                 {
                     default:
                          break;
                      case WATER:
                        if (p[id[1]] < stateswitch) 
                           { /* fluid is vaporous */
                            if (t[id[0]] > 800)
                                printf ("Warning in enthaply: temperature out of range!\n"
                                        "        Valid temperature range up to 800°C\n");
                            if (p[id[1]] > 4.9033e7)
                                printf ("Warning in enthaply: pressure out of range!\n"
                                        "        Valid pressure range up to 49.055 MPa\n");
                           }
                        else 
                            { /* fluid is liquid */    
                            if (t[id[0]] < 0 || t[id[0]] > 200)
                                printf ("Warning in enthaply: temperature out of range!\n" 
                                        "        Valid temperature range from 0°C to 200°C\n");
                            if (p[id[1]] < 1e3 || p[id[1]] > 1e7)
                                printf ("Warning in enthaply: pressure out of range!\n"
                                       "         Valid pressure range from 0.001 MPa to 10 MPa\n");
                            }
                          break;  
                     case AIR:
                          if (fm[id[3]] == 0)
                          { 
                            if (t[id[0]] < -150 || t[id[0]] > 1000)
                                printf("Warning in enthaply: Valid temperature range\n"
                                       "        from -150 °C to 1000°C\n");              
                          } 
                          else if (t[id[0]] < 0 || t[id[0]] > 800)
                                printf ("Warning in enthaply: temperature out of range!\n" 
                                        "        Valid temperature range from 0°C to 800°C\n");
                          if (p[id[1]] < 1e5 || p[id[1]] > 1e7)
                              printf("Warning in enthaply: pressure is only valid between\n" 
                                     "        p = 1 bar and p = 100 bar!\n");
                          break;
                    case TYFOCOR_LS:
                         if (t[id[0]]<-30 || t[id[0]] > 120)
                             printf ("Warning in density: temperature out of range of interpolation!\n"
                                     "        Values are interpolated  between -30°C and 120 °C");
                         break;
                 }  /* end switch material */
                 x[n] = enthalpy(ft[id[2]], fm[id[3]], t[id[0]], p[id[1]]);
                 if (x[n] < 0.0)
                     mexErrMsgTxt ("An error occured while evaluation the enthalpy.\n" 
                                   "Check the range of the inputs.\n");
                 break;

            case ENTROPY:
            /* Range check of state variables */
                 switch (material)
                 {
                    case WATER:             
                        if (p[id[1]] < stateswitch) 
                        { /* fluid is vaporous */
                            if (t[id[0]] < 0 || t[id[0]] > 800)
                                printf ("Warning in entropy: temperature out of range!\n"
                                        "Valid temperature range from 0°C  to 800°C\n");
                            if (p[id[1]] < 1e5 || p[id[1]] > 4.9033e7)
                                printf ("Warning in entropy: pressure out of range!\n"
                                        "Valid pressure range from 0.1 MPa to 49.055 MPa\n");
                        } else { /* fluid is mixture of boiling fluid and saturated steam*/    
                               if (t[id[0]] < 0 || t[id[0]] > 300)
                                   printf ("Warning in entropy: temperature out of range!\n" 
                                           "Valid temperature range from 0°C to 374,15°C\n");
                               if (p[id[1]] < 1e4 || p[id[1]] > 1e7)
                                   printf ("Warning in entropy: pressure out of range!\n"
                                           "Valid pressure range from 0.1 bar to 100 bar\n");
                               }
                         break;   
                    case AIR: 
                        if (t[id[0]] < 0 || t[id[0]] > 1000.0)
                            printf ("Warning in entropy: temperature out of range!\n"
                                    "Valid temperature range from 0°C to 1000°C\n");
                        if (p[id[1]] < 1e5 || p[id[1]] > 1e7)
                            printf ("Warning in entropy: pressure out of range!\n"
                                    "Valid pressure range from  .1 bar to 10 bar\n");
                         break;
                     case COTOIL: case SILOIL:case WATERGLYCOL:case TYFOCOR_LS:
                          printf("No values available for cottonoil,siliconoil\n" 
                                  ", water glycol and Tyfocor_LS so far\n");
                         break;
                }  /* end switch material */
                x[n] = entropy(ft[id[2]], fm[id[3]], t[id[0]], p[id[1]]);
                if (x[n] < 0.0)
                    mexErrMsgTxt ("An error occured while evaluation the entropy.\n" 
                                  "Check the range of the inputs.\n");
                break;

            case PRANDTL:
                /* Range check of state variables */
                switch (material)
                { 
                    case WATER:
                         if (p[id[1]] < stateswitch) 
                         { /* fluid is vaporous */
                            if (t[id[0]] > 800)
                                printf ("Warning in Prandtl: temperature out of range!\n"
                                        "Valid temperature range from 0°C to 800°C\n");
                            if (p[id[1]] > 4.9033e7)
                                printf ("Warning: pressure out of range!\n");
                         } 
                         else 
                         { /* fluid is liquid */    
                             if (t[id[0]] < 0 || t[id[0]] > 160)
                                 printf ("Warning in Prandtl: temperature out of range!\n" 
                                         "Valid temperature range from 0°C to 160°C\n");
                         }
                         break;
                    case AIR:
                         if (t[id[0]] < 0.0 || t[id[0]] > 400)
                             printf ("Warning in Prandtl: temperature out of range!\n"
                                     "Valid temperature range from 0°C to 400°C\n");
                         if (p[id[1]] > 1.1e5 || p[id[1]] < 0.9e5)
                             printf ("Warning in Prandtl: pressure out of range!\n"
                                     "Valid pressure is 1e5 Pa\n");
                         break;
                    case COTOIL: case SILOIL:
                         if (t[id[0]] > 200)
                             printf ("Warning in Prandtl: temperature out of range!\n"
                                     "Values are valid up to 200°C\n");
                         break;              
                    case WATERGLYCOL:
                         if (t[id[0]]<0 || t[id[0]]>100)
                         printf ("Warning in Prandtl: temperature out of range of interpolation!\n"
                                 "Values are interpolated  between 0°C and 100°C\n");
                         break;
                    case TYFOCOR_LS:
                         if (t[id[0]]<-30 || t[id[0]] > 120)
                             printf ("Warning in density: temperature out of range of interpolation!\n"
                                     "        Values are interpolated  between -30°C and 120 °C");
                         break;
                } /* end switch material */
                x[n] = prandtl(ft[id[2]], fm[id[3]], t[id[0]], p[id[1]]);
                if (x[n] < 0.0)
                    mexErrMsgTxt ("An error occured while evaluation the prandtl number.\n" 
                                  "Check the range of the inputs.\n");
                break;

            case SPECIFIC_VOLUME:
                /* Range check of state variables */
                switch (material)
                {     
                    case WATER:
                        if (p[id[1]] < stateswitch) 
                    { /* fluid is vaporous */
                            if (t[id[0]] > 800 || t[id[0]]<50)
                            printf ("Warning in specific volume: temperature out of range!\n"
                                   "Valid temperature range from 50°C to 800°C\n");
                        if (p[id[1]] > 4.9033e7 || p[id[1]]<1e5)
                            printf ("Warning in specific volume: pressure out of range!\n"
                                    "Valid pressure range from 1e5 Pa to 49.055 MPa\n");
                    } 
                    else 
                    { /* fluid is liquid */    
                        if (t[id[0]] < 0 || t[id[0]] > 800)
                            printf ("Warning in specific volume: temperature out of range!\n" 
                                    "Valid temperature range from 0°C to 200°C\n");
                        if (p[id[1]] < 1e5 || p[id[1]] > 2e7)
                            printf ("Warning: pressure out of range!\n"
                                    "Valid pressure range from 1e5 Pa to 20 MPa\n");
                    }
                         break;
                    case AIR: 
                         if (p[id[1]] > 1e7 || p[id[1]]<1e5)
                             printf ("Warning in specific volume: pressure out of range!\n"
                                 "Valid pressure up from 0.1 MPa to 10 MPa\n");
                         if (t[id[0]] > 1000 || t[id[0]]<0)
                             printf ("Warning in specific volume: temperature out of range!\n"
                                     "Valid temperature from 0 to 1000 degrees\n");
                    case COTOIL: case SILOIL: 
                        if (t[id[0]] > 250)
                            printf ("Warning in specific volume: temperature out of range!\n" 
                                    "Valid temperature range from 0°C to 250°C\n");
                         if (p[id[1]] > 1.1e5 || p[id[1]] < 0.9e5)
                             printf ("Warning in specific volume: pressure out of range!\n"
                                     "Valid pressure is 1e5 Pa\n");
                         break;
                    case WATERGLYCOL:
                        if (t[id[0]] < 0 || t[id[0]] > 100)
                            printf ("Warning in specific volume: temperature out of range!\n" 
                                    "Valid temperature range from 0°C to 100°C\n");
                         if (p[id[1]] > 1.1e5 || p[id[1]] < 0.9e5)
                             printf ("Warning in specific volume: pressure out of range!\n"
                                     "Valid pressure is 1e5 Pa\n");
                         break;
                    case TYFOCOR_LS:
                         if (t[id[0]]<-30 || t[id[0]] > 120)
                             printf ("Warning in density: temperature out of range of interpolation!\n"
                                     "        Values are interpolated  between -30°C and 120 °C");
                         break;
                }  /* end switch material */
                x[n] = specific_volume(ft[id[2]], fm[id[3]], t[id[0]], p[id[1]]);
                if (x[n] < 0.0)
                    mexErrMsgTxt ("An error occured while evaluation the specific volume.\n" 
                                  "Check the range of the inputs.\n");
                break;
  
            case EVAPORATION_ENTHALPY:
                /* Range check of state variables */
                switch (material)
                {   
                    case WATER:
                         if (p[id[1]] > PRESSKRIT) 
                             printf ("Evaporation_enthalpy only defined for pressures\n" 
                                     "smaller than the critical pressure!\n");
                         if (t[id[0]] > TEMPKRIT)
                             printf ("Evaporation_enthalpy only defined for temperatures\n" 
                                     "smaller than the critical temperature 374.15°C!\n");
                         break;
                    case AIR: case COTOIL: case SILOIL: case WATERGLYCOL: case TYFOCOR_LS:
                         printf ("Evaporation_enthalpy only available for water!\n");        
                         break;
                } /* end switch material */
                x[n] = evaporation_enthalpy(ft[id[2]], fm[id[3]], t[id[0]], p[id[1]]);
                /*printf("%f\n",x[n]);*/
                if (x[n] < 0.0)
                    mexErrMsgTxt ("An error occured while evaluation the evaporation enthalpy.\n" 
                        "Check the range of the inputs.");
                break;

            case VAPOURPRESSURE:
                /* Range check of state variables */
                switch (material)
                {
                    case WATER:
                         {if(t[id[0]] > TEMPKRIT)
                             printf ("Warning: vapourpressure is not defined for\n" 
                                     "temperatures above the critical point!\n");
                          if(p[id[1]] > PRESSKRIT)
                             printf ("Warning: vapourpressure is not defined for\n" 
                                     "pressures above the critical point!\n");
                         }
                         break;
                    case WATERGLYCOL: case TYFOCOR_LS:
                         if (t[id[0]] < 39.0 || t[id[0]] > 200.0)
                             printf ("Warning in vapour pressure: temperature out of range of interpolation!\n"
                                     "        Values are interpolated  between 40°C and 200 °C\n");
                         break;
                    case AIR:
                         break;   
                    case COTOIL: case SILOIL: default:
                         printf ("vapourpressure not available for cotton oil and silicon oil\n");        
                         break;   
                } /* end switch material */
                x[n] = vapourpressure(ft[id[2]], fm[id[3]], t[id[0]], p[id[1]]);
                /* printf("vapourpressure %f",x[n]); */
                if (x[n] < 0.0)
                    mexErrMsgTxt ("An error occured while evaluation the vapourpressure.\n" 
                        "Check the range of the inputs.");
                break;

            case SATURATIONTEMPERATURE:
                /* Range check of state variables */
                switch (material)
                {
                  case WATER: case AIR:
                       if(p[id[1]] > PRESSKRIT)
                          printf ("Warning: saturationtemperature is not defined for" 
                                  "pressures above the critical point!");
                       if(t[id[0]] > TEMPKRIT)
                          printf ("Warning: saturationtemperature is not defined for" 
                                  "temperatures above the critical point!");
                       break;
                  case TYFOCOR_LS:
                         if (t[id[0]]<40 || t[id[0]] > 200)
                             printf ("Warning in density: temperature out of range of interpolation!\n"
                                     "        Values are interpolated  between 40°C and 200 °C");
                         break;
                  case COTOIL: case SILOIL: case WATERGLYCOL:
                       printf ("Error: saturationtemperature only available for water and moist air\n");        
                       break;
                }  /* end switch material */
                x[n] = saturationtemperature(ft[id[2]], fm[id[3]], t[id[0]], p[id[1]]);
                if (x[n] < -273.15 || x[n]>1e20)
                    mexErrMsgTxt ("An error occured while evaluation of property.\n" 
                                  "Check the range of the inputs.");
                break;
            default:
                mexErrMsgTxt ("Error in fluidprop: function unknown!");
                break;
        } /* end switch property*/
        
        else      /* if (propi=>0) */
        
        {
          /* SATURATIONPROPERTY: */
                /* Range check of state variables */
                switch (material)
                {
                  case WATER:
                       if(p[id[1]] > PRESSKRIT)
                          printf ("Warning: saturationtemperature is not defined for" 
                                  "pressures above the critical point!");
                       if(t[id[0]] > TEMPKRIT)
                          printf ("Warning: saturationtemperature is not defined for" 
                                  "temperatures above the critical point!");
                       break;
                    case AIR: case COTOIL: case SILOIL: case WATERGLYCOL: case TYFOCOR_LS:
                       printf ("saturationtemperature only available for water!");        
                       break;
                }  /* end switch material */
                switch (-propi)
                {
                    case DENSITY:
                         x[2*n] = saturationproperty(ft[id[2]], fm[id[3]], t[id[0]], p[id[1]],DENSITY,VAPOROUS);
                         x[2*n+1] = saturationproperty(ft[id[2]], fm[id[3]], t[id[0]], p[id[1]],DENSITY,LIQUID);
                         break;
                    case HEAT_CAPACITY:
                         x[2*n] = saturationproperty(ft[id[2]], fm[id[3]], t[id[0]], p[id[1]],HEAT_CAPACITY,VAPOROUS);
                         x[2*n+1] = saturationproperty(ft[id[2]], fm[id[3]], t[id[0]], p[id[1]],HEAT_CAPACITY,LIQUID);
                         break;                    
                    case THERMAL_CONDUCTIVITY:
                         x[2*n] = saturationproperty(ft[id[2]], fm[id[3]], t[id[0]], p[id[1]],3,1);
                         x[2*n+1] = saturationproperty(ft[id[2]], fm[id[3]], t[id[0]], p[id[1]],3,2);
                         break;
                    case VISCOSITY:
                         x[2*n] = saturationproperty(ft[id[2]], fm[id[3]], t[id[0]], p[id[1]],4,1);
                         x[2*n+1] = saturationproperty(ft[id[2]], fm[id[3]], t[id[0]], p[id[1]],4,2);
                         break;
                    case ENTHALPY:
                         x[2*n] = saturationproperty(ft[id[2]], fm[id[3]], t[id[0]], p[id[1]],5,1);
                         x[2*n+1] = saturationproperty(ft[id[2]], fm[id[3]], t[id[0]], p[id[1]],5,2);
                         break;
                    case ENTROPY:
                         x[2*n] = saturationproperty(ft[id[2]], fm[id[3]], t[id[0]], p[id[1]],6,1);
                         x[2*n+1] = saturationproperty(ft[id[2]], fm[id[3]], t[id[0]], p[id[1]],6,2);
                         break;
                    case PRANDTL:
                         x[2*n] = saturationproperty(ft[id[2]], fm[id[3]], t[id[0]], p[id[1]],7,1);
                         x[2*n+1] = saturationproperty(ft[id[2]], fm[id[3]], t[id[0]], p[id[1]],7,2);
                         break;
                    case SPECIFIC_VOLUME:
                         x[2*n] = 1./saturationproperty(ft[id[2]], fm[id[3]], t[id[0]], p[id[1]],1,1);
                         x[2*n+1] = 1./saturationproperty(ft[id[2]], fm[id[3]], t[id[0]], p[id[1]],1,2);                     
                         break;
                    default:
                         printf("property %d unknown\n",propi);                     
                 } /* switch */
                if (x[2*n] < -273.15 || x[2*n+1] < -273.15)
                    mexErrMsgTxt ("An error occured while evaluation of the saturation property.\n" 
                                  "Check the range of the inputs.");
                if (x[2*n] > 1e20 || x[2*n+1] > 1e20)
                    mexErrMsgTxt ("An error occured while evaluation of the saturation property.\n" 
                                  "Check the range of the inputs.\n");
         } /* else */

    } /* end for n */
    } /* if mix in [0..1] */
} /* end function */


void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[] )
{
    double *x, *t, *p, *ft, *fm, *prop;
    int    rows, num[4], cols, m, n, i;
  
    /* Check for proper number of arguments. */
    if(nrhs!=5)
        mexErrMsgTxt("ERROR in fluidprop: Five inputs required.");
    if(nlhs>1)
        mexErrMsgTxt("ERROR in fluidprop: Only one output argument allowed.");
  
    /* check input arguments */
    for (i = 0; i < 5; i++) {
        if( !mxIsNumeric(prhs[i]) || !mxIsDouble(prhs[i]) ||
            mxIsEmpty(prhs[i])    || mxIsComplex(prhs[i]) ) {
            mexErrMsgTxt("ERROR in fluidprop: input must be a number");
        }
    }

    /*  get the input matrix */
    t  = mxGetPr(prhs[0]);
    p  = mxGetPr(prhs[1]);
    ft = mxGetPr(prhs[2]);
    fm = mxGetPr(prhs[3]);

    /*  get the scalar input prop */
    prop = mxGetPr(prhs[4]);
  
    /*  get the dimensions of the matrix input */
    rows = 1;
    cols = 1;
    for (i = 0; i < 4; i++) {
        m = (int_T)(mxGetM(prhs[i]));
        n = (int_T)(mxGetN(prhs[i]));
        if (m > 1 && m != rows && rows > 1 ||
            n > 1 && n != cols && cols > 1)
            mexErrMsgTxt ("ERROR in fluidprop: inputs must have the same size or be a scalar");
        num[i] = max(m, n);
        rows = max(m, rows);
        cols = max(n, cols);
    }

     if (prop[0]<0)      /* wenn neg. dann zwei Zeilen, wegen s.o. */
        rows*=2; 
  
    /* Create matrix for the return argument. */
    plhs[0] = mxCreateDoubleMatrix(rows, cols, mxREAL);

    /* x is the pointer to the result */
    x = mxGetPr(plhs[0]);
    fluidprop(x, ft, fm, t, p, prop, num);
    
    return;
}

