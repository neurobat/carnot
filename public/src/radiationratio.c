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
 * Syntax  R = radiationratio(month,latitude,longitude,longitude0,ClearIndex,Skymodel,Greflect)
 * 
 * tw -> Thomas Wenzel
 * aw -> Arnold Wohlfeil
 * hf -> Bernd Hafner
 *
 * Version  Author  Changes                                     Date
 * 0.1.0    tw      created                                     11apr2000
 *                  Declination copied from metrad_s.c
 * 3.1.0    hf      call functions in carlib                    31dec2008
 * 6.1.0    aw/hf   initialize variables, check DBL_EPSILON     12sep2015
 * 6.2.0    hf      solar position calculated by carlib         18sep2015
 *                  function solar_position  
 *                  corrected if(ZENITH < -9998.0 ...
 *
 * Copyright (c) 2000-2015 Solar-Institut Juelich, Germany
 *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *  D E S C R I P T I O N
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 FUNCTION: Calculates a matrix of ratio of direct radiation on tilted 
           surface to that on horizontal surface.
           The matrix contains the ratios for different slope angles and
           different surface azimuth angles.
           The rows vary over the slope angles from 0° to 90° in steps of 5°.
           The columns vary over the surface azimuth angles from 0° to 180°
           in steps from 5°.
           For one position all ratios are calculated for all days and all
           full hours. Then the ratios are middled, weighted by the 
           extraterrestric radiation.
            

           INPUT
       
           1. month         :   [1..12]
           2. latitude      :   Breitengrad ([-90,90],Nord positiv)
           3. longitude     :   Längengrad ([-180,180],West positiv)
           4. longitudenull :   Referenzlängengrad (Zeitzone)
					
           OUTPUT
  
           1. R             : matrix of ratio
			  

  Berechnung des Sonnenstandes aus sunpos.c übernommen:
  
 * The model calculates the sun_position described by the three sun-angles zenit-angle,
 * azimuth-angle and the angle between collector normal and the sun. The calculation is 
 * carried out based on the formulas of the "Deutscher Wetterdienst". The input data are 
 * taken from the Test reference year (TRY). 
 
 
 Calculation of Ratio of Radiaton from:
 Duffie, J.A., Beckman, W.A. Solar Engineering of Thermal Processes, 1991

*/



/*
 * Need to include simstruc.h for the definition of the SimStruct and
 * its associated macro definitions. math.h is for function sqrt
 */
#include "simstruc.h"
#include "carlib.h"
#include <math.h>
#include <float.h>

#define SQR(x) ((x)*(x))


/******************************************************************************
*                                                                             *
* countseconds                                                                *
*                                                                             *
* count the seconds in the past year, given by date                           *
* this function is equivalent to date2sec                                     *
*                                                                             *
*                                                                             *
******************************************************************************/

int countseconds(int year, int month,int day, int hour,int minute, int second)
{

    int imonth, iday;
    
    iday = 0;
 
    for (imonth=1;imonth<month;imonth++)
      if ( ( imonth<=7 && imonth%2==1) || (imonth>=8 && imonth%2==0) )
         iday += 31;
      else if (imonth==2)
      {
         if (year%4==0)
           iday += 24;
         else 
           iday += 28;
      }
      else
         iday += 30;
         
    return (((iday+day-1)*24+hour)*60+minute)*60+second;
}




/******************************************************************************
*                                                                             *
* declination                                                                 *
*                                                                             *
* INPUT                                                                       *
*                                                                             *
*  1. time          :   [s]                                                   *
*  2. latitude      :   Breitengrad ([-90,90],Nord positiv)                   *
*  3. longitude     :   Längengrad ([-180,180],West positiv)                  *
*  4. longitudenull :   Referenzlängengrad (Zeitzone)                         *
*                                                                             *
* OUTPUT                                                                      *
*                                                                             *
*  1. declination   :   [-23.4°..23.4°]                                       *
*  2. SunAngle      :                                                         *
*  3. Zenith                                                                  *
*  4. Azimuth                                                                 *
*  5. Iextra                                                                  *
*                                                                             *
******************************************************************************/

void declination(double time, double latitude, double longitude, double longitudenull,
        double *out_decl, double *out_altitude, double *out_zenith,
        double *out_azimuth, double *out_hourangle,double *Iextra)
{
    
    real_T SunHour, ClearIndex, delta, woz, HourAngle, sunangle, IextraDay;
    real_T zenith, azimut, xx, coszenit;
    real_T solpos[5];

    /* Besetzen diverser Variablen mit Default-Werten:*/
    SunHour = 0.0;	/* Kennung für Tagesstunden; "0" = NACHTstunden*/
    ClearIndex = -1.0; /* Erkennungsmarke für NACHT-Interpolation    */
    // latitude = DEG2RAD*latitude; // input for solar_position is in degree
    
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

    /* calculate solar position in the carlib function    */
    solar_position(solpos, time, latitude, longitude, longitudenull);
    zenith = solpos[0]*RAD2DEG; // zenith angle in degree, 0 is solar position vertical above ground
    azimut = solpos[1]*RAD2DEG; // azimut angle in degree, 0 is South, West is positive
    delta = solpos[2];          // solar declination angle in radian, North positive
    HourAngle = solpos[3];      // solar hour angle in radian, West positive
    woz = solpos[4];            // true local time in s
    coszenit = cos(solpos[0]);  // cosine of zenith angle

    /* Tagesmittelwert der extraterrestrischen Strahlung "IextraDay", die senkrecht*/
    /* auf eine zur Sonne orientierten Fläche fällt */
    IextraDay = extraterrestrial_radiation(time);
    
    /* Sonnenhöhenwinkel "SunAngle":*/
    sunangle = 90.0 - zenith;
    if (sunangle < 0.01)
       sunangle = 0.01; /* da sonst Warnung "log(0)" (s.u.), falls SunAngle = 0.*/
  
    /* Auf eine HORIZONTALE (= der Erdoberfläche parallelen) Fläche unter dem  */
    /* Winkel "zenit" treffende extraterrestrische Strahlung "Iextra":         */
    *Iextra = IextraDay * coszenit;
  
    *out_decl = RAD2DEG*delta;
    *out_azimuth = azimut;
    *out_altitude = sunangle;
    *out_zenith = zenith; 
    *out_hourangle = HourAngle*RAD2DEG;   
    
} /* end mdloutputs */



void surfrad(double TIME,double IDIR,double IDFU,double *idir_geneigt,double *idfu_geneigt, double *out_R,
             double ZENITH,double AZIMUT,double COLANGLE,double COLAZIMUT,double COLROTATE,
             double SKYMODEL,double GREFLECT)
{

    double time;
    double tetatrans = -9999.0; /* incidence angle transversal coll. plane */
    double tetalong  = -9999.0; /* incidence angle longitudinal coll. plane */
    double costeta = 0.0;       /* incidence angle collector plane */
    double idir_t  = 0.0;       /* direct radiation on surface */
    double idfu_t  = 0.0;       /* diffuse radiation on surface */
    double iextra  = 0.0;       /* extraterrestrial radiation on horizontal */
    double R;

    double as, zs, rc, zc, ac, rb;
    double szc, czs, szs, czc, src, crc, sda, cda;

    int skymodel;

    skymodel    = (int)SKYMODEL;
    time = TIME;
    rb = 0.0;
  
    //     printf("ZENITH %f  AZIMUT %f  \n", ZENITH, AZIMUT);

    if(ZENITH < -9998.0 || AZIMUT < -9998.0) { /* -9999 for no value */
          printf("Error: weather data does not include sunposition. \n");
          printf("       Use block carnot/weather/set_sun_position.\n");
          return;
    }
      as = DEG2RAD * AZIMUT;
      zs = DEG2RAD * ZENITH;
      zc = DEG2RAD * COLANGLE;
      ac = DEG2RAD * COLAZIMUT;
      rc = DEG2RAD * COLROTATE;
  
      sda = sin(as-ac); /* difference of azimut */
      cda = cos(as-ac); 
      szs = sin(zs); /* sine ZENITH angle of sun */
      czs = cos(zs); /* cosine ZENITH angle of sun */
      szc = sin(zc); /* sine ZENITH angle of collector (inclination) */
      czc = cos(zc); /* cosine ZENITH angle of collector (inclination) */
      src = sin(rc); /* sine rotation angle of collector */
      crc = cos(rc); /* cosine rotation angle of collector */
  
      if (czs < 1.0e-5) { /* no sun */
          tetalong = 90.0;
          tetatrans = 90.0;
      } else { /* sun is there */
          /* cos of incidence angle on surface */
          costeta = src*sda*szs+crc*(szc*cda*szs+czc*czs);
  
          rb = costeta/czs; /* ratio of direct radiation */
  
          /* incidence angle in longitudinal collector plane
            (direction riser - vertical on window) */
          tetalong = acos(costeta/
              sqrt(SQR(czc*cda*szs-szc*czs)+SQR(costeta)));
          /* incidence angle in transversal collector plane 
             (direction header - vertical on window) */
          tetatrans = acos(costeta/
              sqrt(SQR(crc*sda*szs-src*(szc*cda*szs+czc*czs))+SQR(costeta)));
  
          /* ---- radiation on tilted surface ----- */
          /* extraterrestrial radiation on horizontal */
          iextra = 1367.0 * (1.0 + 0.033*cos(1.992384990861106e-7*time)) * czs;
  
          /* diffuse radiation on surface depends on sky model */
          /* from Duffie, Beckman: Solar Engineering of Thermal Processes, 1991 */
          idfu_t = (IDFU+IDIR)*0.5*GREFLECT*(1.0-czc); /* reflected from ground */
  
          switch (skymodel) {
              case 1: /* isotropic sky model */
                  idfu_t += 0.5*IDFU*(1.0+czc); /* add to idfu_t */
                  break;
              case 2: /* Hay Davies sky model */
                  idfu_t += IDFU*((1.0-IDIR/iextra)*0.5*(1.0+czc) 
                      + rb*IDIR/iextra);        /* add to idfu_t */
                  break;
              default: /* no sky model */
                  idfu_t += IDFU;
                  break;
          }
          /* limited to iextra to avoid peaks at high ZENITHh angles of sun */
          idfu_t = MIN(iextra, idfu_t);  /* diffuse radiation un surface  */
          idir_t = MIN(iextra, IDIR*rb); /* direct radiation un surface  */
      } /* end if csz > 1e-5, check for sunset */
  
  
      /* formula (2.15.2) */
      if (fabs(IDIR+IDFU) < DBL_EPSILON)
        R = 0;
      else
        R = IDIR*rb/(IDIR+IDFU) + IDFU/(IDIR+IDFU)*(1+cos(COLANGLE*DEG2RAD))/2
            + GREFLECT*(1-cos(COLANGLE*DEG2RAD))/2;
      
  
      *idir_geneigt = idir_t;
      *idfu_geneigt = idfu_t;
      *out_R = R;
      
}



/******************************************************************************
*                                                                             *
*  flaechenfaktor                                                             *
*                                                                             *
*  - calculates the zentith and the extraterrestric radiation                 *
*  - calculates the angle of incidence (1.6.2)                                *
*  - calculates ratio R = cos(incidence)/cos(zenith)                          *
*                                                                             *
*  output: double *r      = max(R,0)                                          *
*          double *iextra = extraterrestric radiation                         *
*                                                                             *
******************************************************************************/

void flaechenfaktor(double time,double latitude,double longitude,double longitude0,
        double slope,double surfaceangle,double ClearIndex, double Skymodel, 
        double Greflect, double *r,double *out_iextra)
{
   double decl,altitude,azimuth,zenith,hourangle,iextra,I,idfu,idir,idir_gen,idfu_gen,R;
   
   declination(time,latitude,longitude,longitude0,&decl,&altitude,&zenith,
           &azimuth,&hourangle,&iextra);
             
           I = ClearIndex*iextra;
                       
           /* Diffuse Strahlung auf HORIZONTALE Fläche "Idfu" ...  */
           if (ClearIndex <= 0.3)
              idfu = I * (1 - 0.2 * ClearIndex);
           else if (ClearIndex > 0.3 && ClearIndex <= 0.79)
              idfu = I * (1.423-1.612 * ClearIndex);
           else
              idfu = I * 0.15;
        
        /* Direkte Strahlung auf HORIZONTALE Fläche "Idir"*/
        idir = I - idfu;
        
   /*     printf("iextra %f  I %f   Idfu %f  Idir %f\n",iextra,I,idfu,idir);*/
        
        surfrad(time,idir,idfu,&idir_gen,&idfu_gen, &R,
             zenith,azimuth,slope,surfaceangle,0,
             Skymodel,Greflect);
        
        *r = MAX((idir_gen+idfu_gen)/(idir+idfu),0.0);
  /*      if (slope>0)
        printf("%.0f°/%.0f° idir %f.1 %f.1   igen %f.1 %f.1   R %f %f\n",slope,surfaceangle,idir,idir_gen,idfu,idfu_gen,*r,R);
  */
  /* *r = MAX(cos_inc/cos(zenith*DEG2RAD),0);*/
  *r = MAX(R,0.0);
   *out_iextra = iextra;
}





void mexFunction(int nlhs,mxArray *plhs[],int nrhs,const mxArray *prhs[])
{
    if (nrhs!=7)
    {
      printf("error: not 7 arguments\n");
    }
    else
    {
      double monat,time,latitude,longitude,longitudenull;   /* input */
     
      
      double iextra;         /* output */
      double sum_r,sum_i,r;
      int    islope,iangle,tag,stunde,minute,max_angle,max_slope;
      double slope,surfaceangle, startmonat,endmonat,
             ClearIndex,Skymodel,Greflect;
      double *R;
      
      max_slope = 37; /*19; */  /* 0:5:90  */
      max_angle = 37;   /* 0:5:180 */    

      monat = *mxGetPr(prhs[0]);
      latitude = *mxGetPr(prhs[1]);
      longitude = *mxGetPr(prhs[2]);
      longitudenull = *mxGetPr(prhs[3]);
      ClearIndex = *mxGetPr(prhs[4]);
      Skymodel = *mxGetPr(prhs[5]);
      Greflect = *mxGetPr(prhs[6]);
   
      if (monat<1.0)
      {
         startmonat = 1.0;
         endmonat = 12.0;
      }
      else
      {
         startmonat = monat;
         endmonat = monat;
      }
      
      plhs[0]=mxCreateDoubleMatrix(max_slope,max_angle,mxREAL); 
      R = mxGetPr(plhs[0]);

/*      declination(time,latitude,longitude,longitudenull,&decl,&altitude,&azimuth,&zenith,&hourangle,&iextra);*/
   
      for (islope=0;islope<max_slope;islope++)     /* iteration over surface slope */
      { 
         slope = 90/(max_slope-1.)*islope; 
         printf("slope %.0f°\n",slope);
         for (iangle=0;iangle<max_angle;iangle++)       /* iteration over surface zenith angle */
         {
            surfaceangle = -180/(max_angle-1.)*iangle;
            sum_r = 0;
            sum_i = 0;
            for (monat=startmonat;monat<=endmonat;monat++)
            for (tag=1;tag<=28;tag+=1)
              for (stunde=1;stunde<24;stunde+=1)
                for (minute=0;minute<60;minute+=60)
                {
                   time = (double)countseconds((int)99, (int)monat, (int)tag,
                           stunde, (int)minute, (int)0);
                   
                   flaechenfaktor(time,latitude,longitude,longitudenull,slope,
                           surfaceangle,ClearIndex,Skymodel,Greflect,&r,&iextra);
                   if (iextra>0.0)// && r>0)
                   {
/*                   if (slope>=90 && surfaceangle>-5)
                      printf("r %f   iextra %f   sum_r %f\n",r,iextra,sum_r+r*iextra);
  */
                      sum_r += r*iextra;
                      sum_i += iextra;
                   }
                }
/*printf("%.0f°/%.0f°  %f/%f = %f\n",slope,surfaceangle,sum_r,sum_i,sum_r/sum_i);              */
              if (sum_i>0.0)
                R[islope+iangle*max_slope] = sum_r/sum_i;  
              else
                R[islope+iangle*max_slope] = 0;  
         } /* for iangle */
      } /* for islope */
                   
   }
      
}

