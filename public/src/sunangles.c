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
 * Syntax  [Decl Altitude Zenith Azimuth HourAngle] = 
 *          sunangles(time, lat, long, long0)
 *
 * version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
 * author list:  hf -> Bernd Hafner
 *               gf -> Gaelle Faure
 *               tw -> Thomas Wenzel
 * 
 * Version  Author  Changes                                     Date
 * 0.01.0   tw      created                                     31mar2000
 * 3.1.0    hf      functions now in carlib                     26dec2008
 * 1.0.0    tw      created, copied from metrad_s.c             31mar2000
 * 4.1.0    hf      vectorized input and output                 05jan2011
 * 6.1.0    hf      call solar_position in carlib               18sep2015
 * 6.1.1    aw      unused variable coszenit in declination()   17jan2017
 *                  deleted
 *
 * Copyright (c) 1999-2015 Solar-Institut Juelich, Germany
 * 
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *  D E S C R I P T I O N
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
% FUNCTION:	  Calculates declination, angle, zenith and azimuth of sun
%            
%
%              INPUT
%         
%			   1. time		    :	[s]
%			   2. latitude      :   Breitengrad ([-90,90],Nord positiv)
%              3. longitude     :   Längengrad ([-180,180],West positiv)
%              4. longitudenull :   Referenzlängengrad (Zeitzone)
%					
%              OUTPUT
%
%			   1. declination   :   [-23.4°..23.4°]
%              2. altitude of the sun
%              3. Zenith        
%              4. Azimuth
%              5. hourangle
%
% 

  Berechnung des Sonnenstandes aus sunpos.c übernommen:
  
 * The model calculates the sun_position described by the three sun-angles zenit-angle,
 * azimuth-angle and the angle between collector normal and the sun. The calculation is 
 * carried out based on the formulas of the "Deutscher Wetterdienst". The input data are 
 * taken from the Test reference year (TRY). 

*/



/*
 * Need to include simstruc.h for the definition of the SimStruct and
 * its associated macro definitions. math.h is for function sqrt
 */
#include "simstruc.h"
#include "carlib.h"
#include <math.h>


/* defines */
// #define SQR(x) ((x)*(x))
// #define DeclDayAmpl   -0.40927970959267   /* = -23.45 * pi/180;  */
// #define HourAngleAmpl  0.261799387799149  /* = 15 * pi/180;      */


/*

  function declination

  INPUT
         
   1. time          :   [s]
   2. latitude      :   Breitengrad ([-90,90],Nord positiv)
   3. longitude     :   Längengrad ([-180,180],West positiv)
   4. longitudenull :   Referenzlängengrad (Zeitzone)

  OUTPUT

   1. declination   :   [-23.4°..23.4°]
   2. SunAngle      :  angle between sun and horizon 
   3. Zenith        
   4. Azimuth
   5. hourangle
*/

void declination(real_T *time, real_T *latitude, real_T *longitude, 
        real_T *longitudenull, real_T *out_decl, real_T *out_altitude, 
        real_T *out_zenith, real_T *out_azimuth, real_T *out_hourangle,
        mwSize n_cells)
{
    real_T delta, deltaangle, woz, HourAngle, sunangle, IextraDay;
    real_T azimut, zenith, lati;
    real_T solpos[5];
    int i;

    for (i = 0; i < n_cells; i++)
    {
        lati = (real_T)DEG2RAD*latitude[0];
        
        /* calculate solar position in the carlib function    */
        solar_position(solpos, time[i], *latitude, *longitude, *longitudenull);
        zenith = solpos[0]*RAD2DEG; // zenith angle in degree, 0 is solar position vertical above ground
        azimut = solpos[1]*RAD2DEG; // azimut angle in degree, 0 is South, West is positive
        delta = solpos[2];          // solar declination angle in radian, North positive
        HourAngle = solpos[3];      // solar hour angle in radian, West positive
        woz = solpos[4];            // true local time in s
        /* declination of the sun in radian */
//         DeclDay = solar_declination(time[i]);

        /* Tagesmittelwert der extraterrestrischen Strahlung "IextraDay", die senkrecht*/
        /* auf eine zur Sonne orientierten Fläche fällt (nach Duffie/Beckman,1993,S.10):*/
        /* IextraDay = 1353 * (1+0.033*cos(2*PI*day/365));   */
        IextraDay = extraterrestrial_radiation(time[i]);
       
       /* ------------------------------------------------------------------------------- 
    	* 	"Decl"			Deklination der Sonne
    	*	"HourAngle" 	Stundenwinkel der Sonne 
    	*	"zenit"			zenithwinkel 
        *	"SunAngle"		Sonnenhöhenwinkel
    	* 	"azimut"			Azimutwinkel 
    	*	"Iextra"			Extraterrestrische Strahlung auf HORIZONTALE Fläche
        *	"SunHour"		Tag-/Nachterkennung Êrkennung
        *   "dimness"		Trübungsfaktor der Atmosphäre
        * 	"Idirclear"		direkte Strahlung auf der Erdoberfläche für KLAREN Himmel 
    	* 	"Idfuclear"		diffuse Strahlung auf der Erdoberfläche für KLAREN Himmel 
       /* -------------------------------------------------------------------------------*/ 

        /* solar time 0 .. 24*3600 s */
//         woz = solar_time(time[i], longitudenull[0], longitude[0]);      /* solar time from carlib */

        /* determine solar hour angle in radian (noon = 0,  6 a.m. = -PI) */
//         HourAngle = (woz - (real_T)43200.0)*(real_T)7.272205216643040e-5;

        /* declination of the sun */
//         delta = solar_declination(time[i]); 
        deltaangle = RAD2DEG*delta;
    
        /* solar zenith angle in degrees (0° = zenith position, 90° = horizont) */
//         coszenit = sin(lati)*sin(delta) + cos(lati)*cos(delta)*cos(HourAngle);
//         zenith  =  acos(coszenit)*(real_T)RAD2DEG;   
    
        /* solar azimuth angle */
//         if (zenith != (real_T)0.0)   /* for angles above 0 */
//         {
//             azimuth = (real_T)RAD2DEG*acos((sin(lati)*coszenit - sin(delta))
//                 /(cos(lati)*sin(acos(coszenit))));
//             if (HourAngle < (real_T)0.0)
//                 azimuth = -azimuth;
//         }
//         else
//             azimuth = (real_T)0.0;
       
        /* Sonnenhöhenwinkel "SunAngle":*/
        sunangle = 90.0 - zenith;
//         if (sunangle < (real_T)0.01)
//             sunangle = (real_T)0.01; /* da sonst Warnung "log(0)" (s.u.), falls SunAngle = 0.*/
        
        out_decl[i]      = deltaangle;
        out_azimuth[i]   = azimut;
        out_altitude[i]  = sunangle;
        out_zenith[i]    = zenith; 
        out_hourangle[i] = HourAngle*RAD2DEG;   
    } // end for i
} /* end declination */


void mexFunction(int nlhs,mxArray *plhs[],int nrhs,const mxArray *prhs[])
{
    if (nrhs!=4)
    {
        printf("[Declination Altitude Zenith Azimut HourAngle] = \n  sunangles(time, latitude, longitude, longitude_timezone)\n");
        mexErrMsgTxt("Need 4 input arguments\n");
    }
    else if (nlhs!=5)
    {
        printf("[Declination Altitude Zenith Azimut HourAngle] = \n  sunangles(time, latitude, longitude, longitude_timezone)\n");
        mexErrMsgTxt("Need 5 output arguments\n");
    }
    else
    {
        real_T *time, *latitude, *longitude, *longitudenull;      /* input vectors */
        real_T *decl, *altitude, *azimuth, *zenith, *hourangle;   /* output vectors */
        int i;
        mwSize m, n;
        mwSize n_cells = 1;

        // find length of time vector (first input)
        m = mxGetM(prhs[0]); 
        n = mxGetN(prhs[0]);
        n_cells = max(n,m);         // number of elements is max of rows and columns
            
        if (n > 1 && m > 1)         // if input is a matrix
        {
            mexErrMsgTxt("time must be scalar or vector, not a matrix\n");
        }
        for (i=1; i<nrhs; i++)      // check all other inputs
        {
            m = mxGetM(prhs[i]); 
            n = mxGetN(prhs[i]);

            if (max(n,m) > 1)        // if input has more than one element
            {
                mexErrMsgTxt("inputs exept time must be scalar\n");
            }
        }
        /* Create a matrix for the return argument */ 
        plhs[0] = mxCreateDoubleMatrix(n_cells,1,mxREAL);
        plhs[1] = mxCreateDoubleMatrix(n_cells,1,mxREAL);
        plhs[2] = mxCreateDoubleMatrix(n_cells,1,mxREAL);
        plhs[3] = mxCreateDoubleMatrix(n_cells,1,mxREAL);
        plhs[4] = mxCreateDoubleMatrix(n_cells,1,mxREAL);
  
        /* Assign pointers to the various parameters */ 
        time            = mxGetPr(prhs[0]); // time of the year in seconds
        latitude        = mxGetPr(prhs[1]); // geographical latitude [-90,90] north positive, south negative
        longitude       = mxGetPr(prhs[2]); // geographical longitude [-180,180], west positiv, east negative
        longitudenull   = mxGetPr(prhs[3]); // longitude of time zone [-180,180] west positiv, east negative (MEZ = -15, GMT = 0)
   
        decl        = mxGetPr(plhs[0]);
        altitude    = mxGetPr(plhs[1]);
        azimuth     = mxGetPr(plhs[2]);
        zenith      = mxGetPr(plhs[3]);
        hourangle   = mxGetPr(plhs[4]);

        /* Do the actual computations in a subroutine */
        declination(time,latitude,longitude,longitudenull,decl,altitude,azimuth,zenith,hourangle,n_cells);
   }
} // end mexFunction

