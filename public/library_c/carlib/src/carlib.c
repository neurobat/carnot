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
 * $Revision$
 * $Author$
 * $Date$
 * $HeadURL$
 ***********************************************************************
 *  M O D E L    O R    F U N C T I O N
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * carlib.c     
 * 
 *     Standard library routines for the CARNOT blockset for Matlab.
 *     Accessable functions have to be exported in "carlib.h",   
 *     as well as in the link-response-file "carlib.lnk", if you  
 *     want to create a dynamic link library. (The link-response-
 *     file is created from within the Makefile now!)                
 *
 * version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
 *
 * author list:     rhh -> Robby Hoeller
 *                  cw -> Carsten Wemhoener
 *                  gf -> Gaelle Faure
 *                  tw -> Thomas Wenzel
 *                  hf -> Bernd Hafner
 *                  aw -> Arnold Wohlfeil
 *                  mp -> Marcel Paasche
 *
 *  Version Author  Changes                                         Date
 *  0.4.0   rhh     -created                                        02feb98
 *  0.11.0  cw      -extension of water and steam                   02march99
 *  0.12.0  tw      -when sat.temp, then vapourpress = p            10nov99
 *  1.0.1   cw      -extension of calculation of                    26jan2000
 *                   heat_capacity for mixture of air, steam        
 *                   and liquid phase                               
 *  1.0.2   tw      -extension of calculation of thermal_           14feb2000
 *                   cond. and viscosity for water below 0°C
 *                   and for mixture of air
 *                  - new calculation viscosity of water >160°C
 *                  -density of ice
 *                  -new calculation entropy air
 *                  -new calculation enthalpy water
 *  1.0.3.  tw      -correction of calculation of entropy           16feb2000
 *                   and enthalpy of air
 *                  -heat_capacity for water_steam -60°C..50°C
 *  1.0.4.  tw      -enthalpy for humid air                         28feb2000
 *  1.0.5.  tw      -extend functions for air with                  21jul2000
 *                   pressure values from 0.5 to 2-3 bar            
 *  1.0.6.  tw      -correction of enthalpy moist air               26jul2000
 *  1.0.6   cw      -redefinition of the saturation-                
 *                   temperature of moist air                       26jul2000
 *  1.0.7.  tw      -new functions for cp, enthalpy and             02aug2000
 *                   entropy of dry air                             
 *          cw      -new fluid type TYFOCOR_LS                      14dec2000
 *          tw      -correction of range check for dry air          14dec2000
 *                   viscosity                                      
 *          tw      -correction vapourpressure for TYFOCOR          28feb2001
 *                   (bar -> Pa)                                    
 *                  -calculation of saturationtemperature           
 *                   for WATERGLYCOL and TYFOCOR                    
 *          tw      -added global_memory()                          20sep2001
 *  1.0.8   hf      corrected enthalpy of humid air                 25jan2008 
 *                   added h *= 1.0e3 because formula
 *                   is in kJ/kg, result must be in J/kg
 *  3.1.0   hf      including extraterrestrial radiation            25dec2008
 *  3.1.1   gf      added unitconv_temperature                      21jan2011
 *  4.1.0   hf      limit iteration steps in enthalpy2temperature   30jan2011
 *  4.1.1   hf      density of water: linear coeff is 6.187e-2      23feb2011
 *                  (not 6.1187e-2) according to EN 12975
 *  4.2.0   pc      modified interpolation for TYFOCOR_LS           18apr2011
 *  4.2.1   pc      modified calculation for moist air density and  01jun2011
 *                  heat capacity to have dry air kg as unit (no 
 *                  more moist air kg)
 *  4.2.2   gf      add WARNING in enthalpy2temperature in case     07nov2011
 *                  of too many iterations
 *  4.2.3   gf      modify algorithm of enthalpy2temperature to     16nov2011
 *                  improve it hardiness
 *  5.2.1   hf      changed abs to fabs in enthalpy2temperature     16nov2012
 *                  constants moved to carlib.h
 *  5.2.2   hf/aw   saturationproperty-density-water-solid          06jun2013
 *                    density is 900 (not 1/900)
 *                  saturationtemperature-water
 *                    t=-63,16113... (instead of t=-63,17113...) 
 *                  several functions - water 
 *                    check for TEMPKRIT (not 374.15)
 *	5.2.3	aw		changed correlations for water:					21aug2013
 *						- saturation temperature
 *						- vapourpressure
 *					deleted old property data
 *					added {} in if loops for readability
 *					added comments if water property deviations
 *						are high
 *					long calculations devided in two calculations
 *						to support lcc
 *                  removed dry air density correlation for
 *                      pressures < 1 bar and replaced by the
 *                      ideal gas equation
 * 5.2.4    hf      corrected viscosity of Tyfocor LS               11sep2013
 * 6.1.0    hf      added relativeHumidity2waterContent             27oct2013
 *                  and waterContent2relativeHumidity and reynolds
 * 6.1.1	aw		changed calculation for cP						31oct2013
 *					saturation state was checked via (int)t,
 *					which mean 1 K range
 *					but our accuracy is MAXSATTEMPDEV [K]
 * 6.1.2    hf      changed heat_capactiy calculation for humid     31oct2013
 *                  air: base for water is vapour, not liquid
 * 6.1.3	aw		message management added						02apr2014
 * 6.1.4	aw		message management updated						03jun2014
 * 6.1.5	aw		new fluids: constant water and air				03jul2014
 * 6.2.0    mp      solve_massflow_equation replaced by             02sep2014
 *                  solve_quadratic_equation, new calculation method
 *                  for second root
 * 6.2.1    hf      corrected functions                             24nov2014
 *                  line 326 : potentially uninitialized local 
 *                  variable 'ts' used -> added ts for 
 *                  WATER_CONSTANT, AIR_CONSTANT, added else path for AIR
 *                  line 747 : potentially uninitialized local  
 *                  variable 'satprop' used -> satprop initialized with -1
 *                  line 977 : potentially uninitialized local 
 *                  variable 'sv' used -> variable rho replaced by sv for 
 *                  WATER_CONSTANT, AIR_CONSTANT
 *                  line 1711: potentially uninitialized local variable 
 *                  'vap_cont' used -> added default case
 * 6.3.0    hf      included solar_postion, removed global_memory   16sep2015
 *                  added float.h for DBL_EPSILON
 * 6.3.1    hf      added equation thermal conductivity for silicon 15nov2016
 *                  oil from H.Teichmann, FHD
 *                  added values for WATER_CONSTANT and AIR_CONSTANT
 *
 * 2do:
 *    - include pressure in properties of air
 *
 * Literature:
 * Adunka, Franz: Handbuch der Wärmeverbrauchsmessung, Vulkan Verlag, 1991
 * Baehr, Hans Dieter, Berlin, Springer Verlag, 2000
 * Duffie, Beckman: Solar Engineering of Thermal Processes, 2006
 * Glueck Bernd: Zustands- und Stoffwerte, Verlag für Bauwesen, Berlin 1991
 * IAPWS, Revised Release on the Pressure along the Melting and Sublimation
		  Curves of Ordinary Water Substance, www.iapws.org, september 2011
 * VDI-Wärmeatlas 1988
 * EN 12975-2, 2006
 */

#include <math.h>
#include <stdlib.h>
#include <stdio.h>
#include <float.h>
#include "carlib.h"   /* must be last header to include because other   *
                       * defines are checked here                       */

/********************************************************************** 
 *                         helpfull functions
 *********************************************************************/

/* calculate the square of a variable */
double square(double x){ return(x*x); }


/*
 * solve a quadratic equation 
 * 
 * Syntax : x = solve_quadratic_equation(a,b,c)
 *          x[1] = error flag (0: ok   1: error occured)
 *          a is the quadratic coefficient
 *          b is the linear coefficient
 *          c is the constant coefficient
 *  a * x^2 + b * x + c = 0
 *  x(1/2) = (-b +/- sqrt(b^2-4*a*c))
 *  take only the root further away from zero, the other root is calculated by
 *  x(2/1) = c/a/x(1/2)
 *  
 */
void solve_quadratic_equation(double *x12, double a, double b, double c)
{
    double root;

    if (a == 0.0)
    {
        if (b != 0.0)
        {
            x12[0] = -c/b;                  /* solve linear equation */
            x12[1] = -c/b;
        }
        else    // no solution
        {
            x12[0] = 0.0;
            x12[1] = 0.0;
        }
    }
    
    else // a ~=0
    {
        root = b*b - 4.0*a*c;               /* set root */
        
        if (root > 0.0)
        {
            root = sqrt(root);
        }
        else
        {
            root = 0.0;                     /* no negative root */
        }
        
        if (b < 0)
        {
            x12[0] = 0.5*(-b+root)/a;
        }
        else
        {
            x12[0] = 0.5*(-b-root)/a;
        }
        x12[1] = c/a/x12[0];    // second solution!
    }
} /* end solve_quadratic_equation */



/********************************************************************** 
 *                         solar calculation
 *********************************************************************/
/* solar position as zenith angle and azimut anlge         
 * inputs: 
 *  time            : legal time in s, January 1st at 0:00 is 0 s
 *  latitude        : gegraphical latitude [-90,90], North positive
 *  longitude       : geographical longitude [-180,180], West positive
 *  longitudenull   : reference longitude (timezone)
 *
 * outputs: solpos is a pointer to double of size 5
 *  solpos[0]: zenith angle in radian, 0 is solar position vertical above ground
 *  solpos[1]: azimut angle in radian, 0 is South, West is positive
 *  solpos[2]: solar declination angle in radian, North positive
 *  solpos[3]: solar hour angle in radian, West positive
 *  solpos[4]: true local time in s
 *
 * syntax:
 *  real_T solpos[5];
 *  solar_position(solpos, time, latitude, longitude, longitudenull);
 *  zenith = solpos[0];         // zenith angle in radian, 0 is solar position vertical above ground
 *  azimut = solpos[1];         // azimut angle in radian, 0 is South, West is positive
 *  declinlination = solpos[2]; // solar declination angle in radian, North positive
 *  hourangle = solpos[3];      // solar hour angle in radian, West positive
 *  truelocaltime = solpos[4];  // true local time in s
 * 
 * Literature: 
 * Duffie, Beckmann: Solar Engineering of Thermal Processes, Wiley, 2006
 */
void solar_position(real_T *solpos, real_T time, real_T latitude, 
        real_T longitude, real_T longitudenull)
{
    real_T xx, delta, woz, hourangle, costetaz, tetaz, lati;

    lati = DEG2RAD*latitude;         /* latitude in radian */
    delta = solar_declination(time); /* declination of the sun in radian */
    /* solar time 0 .. 24*3600 s, function in carlib */
    woz = solar_time(time, longitudenull, longitude);
    /* solar hour angle in radian (noon = 0,  6 a.m. = -PI) */
    hourangle = (woz - 43200.0)*7.272205216643040e-5;

    /* solar zenith angle in degrees (0° = zenith position, 90° = horizont) */
    costetaz = (sin(lati)*sin(delta) + cos(lati)*cos(delta)*cos(hourangle));
    tetaz  = acos(costetaz);

    /* set solar azimuth angle */
    xx = cos(lati)*sin(tetaz);
    if (fabs(xx) > DBL_EPSILON)
    {
        solpos[1] = acos((sin(lati)*costetaz-sin(delta))/xx);
        solpos[1] = (hourangle < 0.0)? -solpos[1] : solpos[1]; /* szimuth has same sign as hourangle */
    }
    else
    {
        solpos[1] = 0.0;
    }
    solpos[0] = tetaz;          /* set zenith angle */
    solpos[2] = delta;
    solpos[3] = hourangle;
    solpos[4] = woz;
} /* end of function solar_position */

/* solar time 0 .. 24*3600 s
 * equation from Duffie, Beckman: Solar Engineering of Thermal Processes, 2006
 * (original source Spencer 1971) 
 */
double solar_time(double time, double timezone, double longitude)
{
    double e, b;
    int    time_in_days;

    time_in_days = ((int)(time/SECONDSPERDAY));
    b = 1.992384990861107e-7*time;
    e = 13752.0*(0.000075 + 0.001868*cos(b) - 0.032077*sin(b)    /* 229.2*60 = 13752 */
        - 0.014615*cos(2.0*b) - 0.04089*sin(2.0*b));
    
    /*          240 s for 1° (24*3600 for 360°) */
    return (e + 240.0*(timezone-longitude) + (time - (SECONDSPERDAY*(double)time_in_days)));
}

/* declination angle of the sun in radian (north: positive)
 * equation from Duffie, Beckman: Solar Engineering of Thermal Processes, 2006
 * (original source Spencer 1971) 
 */
double solar_declination(double time)
{
    double b;
    b = 1.992384990861107e-7*time;
    b = 0.006918 - 0.399912*cos(b) + 0.070257*sin(b)
        - 0.006758*cos(2.0*b) + 0.000907*sin(2.0*b)
        - 0.002679*cos(3.0*b) + 0.00148*sin(3.0*b);
    return b;
}

/* solar extraterrestrial radiation in W/m^2 on a normal surface
 * equation from Duffie, Beckman: Solar Engineering of Thermal Processes, 2006
 * (original source Spencer 1971) 
 */
double extraterrestrial_radiation(double time)
{
    double b;
    b = 1.992384990861107e-7*time;
    b = 1367.0 * (1.00011 + 0.034221*cos(b) + 0.001280*sin(b) 
        + 0.000719*cos(2.0*b) + 0.000077*sin(2.0*b));
    return b;
}


/********************************************************************** 
 *                         fluid properties
 *********************************************************************/

double saturationtemperature(double id, double xi, double t, double p)
{
    double ts, lnp,to,tu;

 	switch((int)(id+0.5))
	{
		case WATER:
            if (p <= 611.657)
			{	/* fitted data from IAPWS September 2011 */
                /* max. deviation < 0.02 K */
				/* valid between 50 K to 273.16 K (2*10^(-40) Pa to 611.657 Pa) */
                lnp = log(p/611.657); /* log(pi) */
				ts = (((((3.8288459961E-13*lnp + 1.1717377096E-10)*lnp + 0.000000013588513109)*lnp + 0.00000067893402502)*lnp - 0.000001589015468)*lnp + 0.044375182202)*lnp - 1.0000557801;
				ts = -273.16/ts - 273.15;
			}
			else
			{	/* fitted from Baehr: Thermodynamik, Springer, 10th ed., pages 602-604), max error < 0.02 K, max deviation to IAPWS data < 0.02 K */
				lnp = log(p);
				ts =  ((7.99565261221834E-08*lnp -5.13938927763879E-07)*lnp + 0.000181371152411444)*lnp
				     +((-4.99865980513684E-28*p  + 1.26423010265555E-20)*p -1.27080669457697E-12)*p
					 -0.00482459403954328;
				ts = -1.0/ts - 273.15;
			}
            break;
		case AIR: /* saturation temperature is dew point temperature */
            if (xi > 1e-20) /* dew point temperature only available for moist air */
                ts = saturationtemperature(1.0,1.0,0.0,vapourpressure(2.0,xi,t,p));
			else
			    ts = -273.15;
            break;
        case WATERGLYCOL:
            /* find saturationtemperature by iterative method */
            tu = 20.0;
            to = 200.0;
            while (to-tu>0.01)
            {
                ts = (to+tu)/2.0;
                if (vapourpressure(id,xi,ts,p)>p)
					to = ts;
                else
					tu = ts;
            }  
            break; 
        case TYFOCOR_LS:       
            /* fitted from output of vapourpressure, error < 3.5 %  */
            ts = 263.9257158*(1-exp(-pow(p/1e5/6.2299009,0.4022453)));
            break;
        case COTOIL: 
            ts = -1.0;
            break;
        case SILOIL:
            if (p > 100.0)
            {
                lnp = log(p);
                ts = (((0.0711440955480129*lnp-2.17481443031356)*lnp
                    +26.1155694350263)*lnp-124.156908912854)*lnp+238.387144454680;
            }
            else
                ts = p - 60;
            break;
		case WATER_CONSTANT:
			ts = 100.0;  /* condensation temperature of steam at 1013 hPa */
			break;
		case AIR_CONSTANT:
			ts = -273.15;  /* dew point of dry air */
			break;
        default:
            ts = -1.0;
            break;
	} /* switch(id) */
    return ts;
}

double saturationproperty(double id, double xi, double t, double p,
                          double prop, double state)
{
    double vis, sv, satprop;

    satprop = -1.0;

    if((int)(id+0.5) == WATER)
	{
        /* Implementation of the values for liquid water and saturated steam *
         * for temperatures < 200°C                                          *
         * - Bernd Glueck: Zustands- und Stoffwerte                          *
         *   Verlag für Bauwesen, Berlin 1991                                *
         * for temperatures > 200°C                                          *
         * - VDI-Wärmeatlas 1988                                             *
         * - Baehr : Thermodynamik                                           */
        switch ((int)(prop+0.5))
		{
			case DENSITY:
				if (state == VAPOROUS)
				{
					if (t >= 0.0 && t<= 100.0)
					{	/* 10 °C to 100 °C, max. error 0.10% */
						/* specific volume of saturated steam */ 
						sv = exp(5.322289 + t*(-6.80891e-2 + t*(2.561151e-4 -
							  t*5.602153e-7)));
							  satprop = 1.0/sv;
					}
					else if (t> 100.0 && t <= 200.0) /* 100°C to 200°C; max. error 0.04%  */    
					{
						sv = exp (5.01069 + t*(-5.8737e-2 + t*(1.5874e-4 -
							  t*2.095037e-7)));
							  satprop = 1.0/sv;  
					}
					else if (t > 200.0 && t < TEMPKRIT)
					{
							 satprop = 780148.9427180408 + t*(-23552.81867816708 + 
									   t*(309.3305106735482 + t*(-2.308423284568578 + 
									   t*(0.01070684593798153 + t*(-3.160755841977299e-005 +
									   t*(5.800204451485451e-008 + t*(-6.049909245909843e-011 + 
									   t*(2.746534582591971e-014))))))));
					}
					else
					{
						satprop = -1.0;  /* calculation failed */
					}
				}
				else if (state == LIQUID)
				{   /* water is liquid */
					/* specific volume of boiling fluid */
					if (t >= 0.0 && t <= 200.0)
					{
						/* 10 °C to 100 °C, max. error 0.10% in relation boiling fluid */
						sv = 9.976577e-4 + t*(1.280991e-7 + t*(3.191465e-9 +
							t*5.894941e-13));
						satprop = 1.0/sv;
					}
					else if (t > 200.0 && t < 370.0)
					{
							 satprop = 0.1*(2795679.546915335 + t*(-73790.90325768168 + 
									   t*(832.1537387294162 + t*(-5.180016379209315 + 
									   t*(0.01922177026665264 + t*(-4.252546668254571e-005 + 
									   t*(5.194435724768688e-008 + t*(-2.70304918544137e-011))))))));
					}
					else
					{
					   satprop = -1.0;  /* calculation failed */
					}
				}
				else /* state is solid */
				{
					satprop = 900.0;
				}
				break;
			case HEAT_CAPACITY:
				if (state == VAPOROUS)
				{ 	/* water is steam */
					/* heat capacity of saturated steam         */
					/* Bernd Glueck: Zustands- und Stoffwerte   */
					/* 10°C to 200°C, max. error 0.16%          */
					/* 0°C error: 0.26 %, Baehr: Thermodynamik  */
					if (t >= 0 && t <= 200)
					{
						satprop = (1.854283 + t*(1.12674e-3 + t*(-6.939165e-6 + 
								   t*1.344783e-7)))*1.0e3;
					}
					else if (t > 200.0 && t < 370.0)
					{
						satprop = t*(-11.29917656675101 + t*(0.04128064892062269 + 
								  t*(-0.0001127642431864269 + t*(2.274758790716646e-007 + 
								  t*(-3.293929342370112e-010 + t*(3.242311052344776e-013 + 
								  t*(-1.944550624602927e-016+ t*(5.366702307674348e-020))))))));
						satprop = -2593444363375.184 + t*(125509845668.5221 + 
								  t*(-2794565929.542156 + t*(37905547.90064985 + 
								  t*(-349458.9702133503 + t*(2312.406235788321 + 
								  satprop)))));
					}
					else
					{
						satprop = -274.0;
					}
				}                 
				else if (state == LIQUID)
				{   /* water is liquid */ 
					/* heat capacity of boiling fluid */
					/* 20°C to 200°C, max. error 0.45% */
					if (t>0.0 && t <= 200.0)
					{
						satprop = (4.177375 + t*(-2.144614e-6 + t*(-3.165823e-7 +
								   t*(4.134309e-8))))*1000;
					}
					else if (t > 200.0 && t < 370.0)
					{
						satprop = t*(-5.134735877784219 + t*(0.01875915522699768 + 
								  t*(-5.12427618326873e-005 + t*(1.033688552112819e-007 + 
								  t*(-1.496789441474804e-010 + t*(1.473302725116287e-013 + 
								  t*(-8.835807017007676e-017 + t*(2.438500546854433e-020))))))));
						satprop = -1178567091637.282 + t*(57036985064.64829 + 
								  t*(-1269970366.485687 + t*(17225883.93569702 + 
								  t*(-158808.3986859223 + t*(1050.84567252893 + 
								  satprop)))));
					}
					else
					{
						satprop = -274.0;
					}
				}
				else /* state is solid */
					satprop = 2040.0;
				break;
			case THERMAL_CONDUCTIVITY:
				if (state == VAPOROUS)
				{   /* water is steam */
					/* thermal conductivity of saturated steam */
					/* 10°C to 200°C, max. error 0.17% */                                        
					if (t > 0.0 && t <= 200.0)
					{
						satprop = 1.70247e-2 + t*(5.510435e-5 + t*(2.123489e-7 + 
								  t*4.4338899e-10));
					}
					else if (t > 200.0 && t < 370.0)
					{
						satprop = t*(2.658327014259441e-008 + t*(-5.538781171704306e-011 + 
								  t*(7.541228540407111e-014 + t*(-6.059028517760954e-017 + 
								  t*(2.181623561662977e-020)))));
						satprop = 49150.8588044485 + t*(-1839.966116754073 + 
								  t*(30.85799353076558 + t*(-0.3053201114418838 + 
								  t*(0.001973768806687964 + t*(-8.711184509479591e-006 + 
								  satprop)))));
					}
					else
					{
						satprop = -274.0;
					}
				}             
				else if (state == LIQUID) /* water is liquid */
					/* heat conductivity of boiling fluid */
					/* 10°C to 200°C, max. error 0.22% */
					  {  
					  if (t > 0 && t <=200)
						  satprop = 5.587913e-1 + t*(2.268458e-3 + t*(-1.248304e-5 + t*1.890318e-8));                                  
					  else if (t > 200 && t < 370)
						  satprop = 1686.710210506068 + t*(-50.89509166656749 + t*(0.6681551865365955 + 
									t*(-0.004982506509897533 + t*(2.308400423139788e-005 + 
									t*(-6.804270783014144e-008 + t*(1.246171812523178e-010 + 
									t*(-1.29660521455703e-013 + t*(5.868384719350212e-017))))))));
					  else
						  satprop = -274;
					  }
				else /* state is solid */
					satprop = 2.25;
				break;
			case VISCOSITY:
				if (state == VAPOROUS) 
				{	/* water is steam */
					/* kinematic viscosity of saturated steam */
					/* 10°C to 200°C, max. error 0.08% */
					if (t > 0.0 && t <= 200.0)                                
					{
						vis = 9.186109e-6 + t*(2.597258e-8 + t*(6.312254e-11 - 
							  t*(1.421265e-13)));
						satprop = vis/saturationproperty(1.0,0.0,t,p,1,1);
					}
					else if (t > 200.0 && t < 370.0)
					   satprop = 3.644048366015422e-005 + t*(-4.093038556361459e-007 + 
								 t*(1.788498774511462e-009 + t*(-3.549614436421561e-012 + 
								 t*(2.673503611974201e-015))));
					else
					{
						satprop = -274.0;
					}
				} 
				else if (state == LIQUID) 
				{	/* water is liquid */
					/* kinematic viscosity of boiling fluid */
					/* 10°C to 200°C, max. error 0.3% */
					if (t > 0.0 && t <= 200.0)                                
					{
						vis = 556272.7 + t*(19703.39+ t*(124.4091 - t*(0.3770952)));
						satprop = 1.0/vis;  
					}
					else if (t > 200 && t <370)
					{
						satprop = 6.130243612601768e-007 + t*(-5.33714101803075e-009 + 
								  t*(2.355450792761161e-011 + t*(-5.013499285954002e-014 + 
								  t*(4.221784407550515e-017))));
					}
					else
					{
							satprop = -274;
					}
				}
				else /* state is solid */
				{
					satprop = -1.0;
				}
				break;

			case ENTHALPY:
				if (state == VAPOROUS) /* water is steam */
				{
					/* enthalpy of saturated steam */
					/* 10°C to 200°C, max. error 0.08% */
					if (t >=0.0 && t <= 200.0)
					{
						satprop = (2.501482e3 + t*(1.789736 +t*(8.957546e-4 +
								   t*-1.300254e-5)))*1000.0;
					}
					else if (t >200.0 && t < 370.0)
					{
						satprop = 1000* (2504.288740612868+ t*(1.195103492606086+ 
									t*(0.02995996920311951+ t*(-0.0005570513196055269+ 
									t*(4.824179179175011e-006+ t*(-2.185944421033951e-008+ 
									t*(4.905625815773255e-011+ t*(-4.337503041508869e-014))))))));
					}
					else
					{
						satprop = -274.0;
					}
				}
				else if (state == LIQUID) /* water is liquid */
				{
					/* Schmidt, E.: Properties of Water and Steam */
				
					/* enthalpy of boiling fluid */
					/* 10°C to 200°C, max. error 0.3% */
					if (t >=0 && t <= 200)
					{
						satprop = (-2.25e-2 + t*(4.2063437 + t*(-6.014696e-4 +
								   t*4.381537e-6)))*1000.0; 
					}
					else if (t >200 && t < 370)
					{
						satprop = 1000.0 * (2.725830639980112+t*(3.740498401870351+
										 t*(0.01545122605503305+t*(-0.0002073762890347522+
										 t*(1.277897913767397e-006+t*(-3.577862543083539e-009+
										 t*(3.797647973330941e-012)))))));
					}
					else
					{
						satprop = -274;
					}
				}
				else
				    satprop = 0.0;
				break;            
			case ENTROPY:
				if (state == VAPOROUS) /* water is steam */
				{   /* entropy of saturated steam, max. error 2.36% */
					if (t >=0.0 && t <= 370.0)
					{
						satprop = 1000*(9.150540212512082+ t*(-0.02553974876629463+ 
										t*(8.110024224252947e-005+ t*(9.95415778390101e-008+ 
										t*(-2.204959555097782e-009+ t*(7.587817132714513e-012+ 
										t*(-8.691639516628623e-015)))))));
					}
					else
					{
						satprop = -274.0;
					}
				}
				else if (state == LIQUID) /* water is liquid */
				{   /* entropy of boiling fluid, max. error 2.36% */
					/* Schmidt, E.:
						Properties of Water and Steam */
					if (t >=0.0 && t <= 370.0)
					{
						satprop = 1000.0 *(0.004187621642589782+t*(0.01466959215224805+
										t*(-5.357852583670469e-006+t*(-2.402076740099851e-007+
										t*(1.764898265850286e-009+t*(-5.157386783528383e-012+
										t*(5.554778442699537e-015)))))));
					}
					else
					{
						satprop = -274.0;
					}
				}
				else /* state is solid */
				{
					satprop = 0.0;
				}
				break;
			case PRANDTL:
				if (state == VAPOROUS) 
				{    /* water is steam */
					 /* prandtl number of saturated steam */
					 /* 10°C to 200°C, max. error 0.41% */
					if (t > 0 && t <= 200)
					{
						satprop = 1.003512 + t*(-9.396716e-5 + t*(-3.900988e-6 + 
								  t*(3.798923e-8)));
					}
					else if (t > 200 && t < 370)
					{
						satprop = t*(0.0001139887963832552 + t*(-3.571077158406628e-007 + 
								  t*(8.129929857389525e-010 + t*(-1.311739308796059e-012 + 
								  t*(1.423838842626759e-015 + t*(-9.335833656398411e-019 + 
								  t*(2.796435508804818e-022)))))));
						satprop = 48123739.38237105 + t*(-2155105.270759231 + 
								  t*(44079.41109911966 + t*(-544.5033097203302 + 
								  t*(4.524352078763585 + t*(-0.02664062009246363 + 
								  satprop)))));
					}
					else
					{
						satprop = -274;
					}
				}
				else if (state == LIQUID) /* water is liquid */
				{
					/* prandtl number of boiling fluid */
					/* 10°C to 200°C, max. error 0.37% */
					if (t > 0 && t <= 200)
					{
						satprop = 1.0/(7.547718e-2 + t*(2.76297e-3 + t*(3.210257e-5 + t*-1.015768e-7)));
					}
					else if (t > 200 && t < 370)
					{
						satprop = t*(-2.079502499460676e-007 + t*(4.763790910155839e-010 +
								  t*(-7.732321564529959e-013 + t*(8.441344997927588e-016 +
								  t*(-5.565263552119546e-019 + t*(1.675769484028955e-022))))));
						satprop = 26637670.35330131 + t*(-1202481.297756214 + t*(24786.3004071483 +
								  t*(-308.4848957640091 + t*(2.581888044433202 +
								  t*(-0.01530955096383876 + t*(6.594876030428829e-005 +
								  satprop))))));
					}
					else
					{
						satprop = -274;
					}
				}
				else /* state is solid */
					satprop = 0.0;
				break;
			case SPECIFIC_VOLUME:
				if (state == VAPOROUS)
				{   /* 10 °C to 100 °C, max. error 0.10% */
					/* specific volume of saturated steam */
					if (t < 100.0)
					{
						satprop = exp(5.322289 + t*(-6.80891e-2 + 
							t*(2.561151e-4 - t*(5.602153e-7))));
					}
					else if (t < 200.0) /* 100°C to 200°C; max. error 0.04%  */
					{
						satprop = exp (5.01069 + t*(-5.8737e-2 +
							t*(1.5874e-4 - t*(2.095037e-7))));
					}
					else if (t < 370.0)
					{
						satprop = 1.0/saturationproperty(1,0,t,p,DENSITY,VAPOROUS);
					}
				}
				else if (state == LIQUID) /* water is liquid */
				{   /* specific volume of boiling fluid */
					if (t > 10 && t < 100) /* 10 °C to 100 °C, max. error 0.10% in relation boiling fluid*/
					{
						satprop = 9.976577e-4 + t*(1.280991e-7 + t*(3.191465e-9 + t*(5.894941e-13)));
					}
					else if (t < 370)
					{
						satprop = 1.0/saturationproperty(1,0,t,p,DENSITY,LIQUID);
					}
				}
				else /* state is solid */
				{
					satprop = 1.0/900.0;
				}
				break;
			case TEMPERATURE_CONDUCTIVITY:
				if (state == VAPOROUS)
				{
					satprop = saturationproperty(1,0,t,p,THERMAL_CONDUCTIVITY,VAPOROUS)
							  /saturationproperty(1,0,t,p,DENSITY,VAPOROUS)
							  /saturationproperty(1,0,t,p,HEAT_CAPACITY,VAPOROUS);
				}
				else if (state == LIQUID)
				{   /* water is liquid */
					 satprop = saturationproperty(1,0,t,p,THERMAL_CONDUCTIVITY,LIQUID)
							  /saturationproperty(1,0,t,p,DENSITY,LIQUID)
							  /saturationproperty(1,0,t,p,HEAT_CAPACITY,LIQUID);
				}
				else /* state is solid */
				{
					satprop = -1.0;
				}
				break;
			default:
				satprop = -1.0; 
				break;
		} /*switch (prop) */
    }

    return satprop;
}/* saturationproperty */        


double density(double id, double xi, double t, double p)
{
    double vsteam, vliquid, sigma, tau, vv, rho;
    int    vp;

 	switch((int)(id+0.5))
	{
		case WATER:  /* Implementation of the values for liquid water and saturated steam *
                      * Bernd Glueck: Zustands- und Stoffwerte                            *
                      * Verlag für Bauwesen, Berlin 1991                                  */
		    if ((int)(t/MAXSATTEMPDEV) == (int) (saturationtemperature(1.0,1.0,t,p)/MAXSATTEMPDEV))
			{
		        vp = (int) p;
			}
		    else 
			{
				vp = (int)vapourpressure(1.0,1.0,t,p);
			}
            if (p==0)
			{
               rho = 0.067;   /*  1/specific volume at 0.1 bar, 50°C *//* density(id,xi,20,1e5);*/
			}
            else
			{
				if (((int)p < vp || vp < 0.0))
				{   /* water is steam, Values from VDI 1963 */
					/* Valid for 0 < p < 49.095 bar and 0 < t < 800 °C) */
					/* reduzierte Temperatur t, reduzierter Druck p  */
					sigma = p / PRESSKRIT;
					tau = ( t + TA0 ) / TAK_WATER;
					vv = 0.0134992 * tau / sigma;
					vv -= ( 4.7331e-3 - 3.17362e-5 * ( 1.55108 - sigma ) * pow(tau,5.64) ) 
						   / pow( tau, 2.82 );
					vv -= sigma * sigma * ( ( 2.93945e-3 - 6.70126e-4 * sigma * ( 1.26591 * sigma
						- tau*tau*tau ) ) / pow( tau, 14. ) + 4.35507e-6 / pow( tau, 32. ) );
					vv -= 8.06867e-5 * tau * (1. - 1.32735 * sigma );
					if (vv!=0)
					   rho = 1/vv;
					else
					   rho = -1;           /* calculation failed */
				}
				else if ((int)p == vp) 
				{   /* water is mixture of boiling water and saturated steam */ 
					vsteam = saturationproperty(1,1,t,p,1,1);
					vliquid = saturationproperty(1,0,t,p,1,2);
					rho = vsteam*xi+vliquid*(1-xi);
				}             
				else if (p > vp)
				{   /* water is liquid */
					/* Schmidt, E.: Properties of Water and Steam */                
					if (t > 140.0)      /* max_error 0.0047655 */
						rho = 996.38 - 2.8532e-2*t -3.1823e-3*t*t + 5.2574e-7*p - 7.5637e-15*p*p + 1.9152e-9*t*p;
					else if (t >= 0.0) /* equation of EN 12975-2 */
						rho = 999.85 + t*( 6.187e-2 + t*(-7.654e-3 
							 + t*( 3.974e-5 - t*( 1.110e-7 ))));
					else if (t >= -20.0)     /* fit from VDI-Wärmeatlas 1988   max_error 0.0000917 */
						rho = -0.015143*t*t+0.043143*t+999.763;
					else
						rho = 900.0; /* water is ice */
				}
				else
				{
					rho = -1.0; /* calculation failed */
				}
			}
            break;
            
        case AIR:
            if (xi > 0.0) 
            {   /* moist air */
                vv = xi;
                if (t < saturationtemperature(1.0,1.0,0.0,vapourpressure(2.0,xi,t,p)))
                {   /* temperature below dew point */
                    vv = vapourpressure(1.0,0.0,t,p);
                    vv = 0.6222*vv/(p-vv); /* water content at 100% humidity */
                }
                if (0.6222+vv!=0)
				{
					rho = 1.0/(0.6222+vv) * p/(0.46155981126839e3*(t+273.15));
				}
                else
				{
					rho = -1;   /* calculation failed */
				}
            }
            else /* xi == 0.0 */
            { 
				/* dry air */  /* range p < 100 bar, T < 1000, VDI-Wärmeatlas !? */
                rho = 1.293 * 273.15/(t+273.15) * p/101300.0;
            }
            break;
            
		case COTOIL:     /* cotton oil */
			rho = 935.0 - 0.6806 * t;
            break;

		case SILOIL:
			rho = 983.1 - 0.9232 * t;
            break;

		case WATERGLYCOL:    /* fitted from Adunka91 data */
            xi = xi*100;   /* in percent */
			rho = t*(-6.845166114722718e-003  + xi*( 1.598552881093090e-004 +
                xi*(-2.500513947679818e-006 + xi*( 1.353169632549166e-008))) +
                t*( 2.199819078440755e-005  + xi*(-9.643408179314126e-007 +
                xi*( 2.189831042031030e-008 + xi*(-1.318311789959629e-010)))));
			rho = 9.998510249903282e+002    + xi*( 1.402898851698828e+000 +
                xi*( 4.720597537855296e-003 + xi*(-5.932727559791945e-005))) +
                t*( 5.547642027503766e-002  + xi*(-8.269670418186260e-003 +
                xi*(-4.776070860890714e-005 + xi*( 6.261556797531848e-007))) +
                rho);
            break;

        case TYFOCOR_LS: /* for -30°C < T < 120°C */
            rho = 3.162027e-6 * pow(t,3) - 2.291580e-3 * pow(t,2) - 4.785221e-1 * t +
                    1.044581e3;
            break;

		case WATER_CONSTANT:
			rho = 998.21; /* for 20 °C: H.D. Baehr, K. Stephan, Wärme- und Stoffübertragung, 4th edition, Springer, page 696 */
			break;
			
		case AIR_CONSTANT:
			rho = 1.188;  /* for 20 °C: H.D. Baehr, K. Stephan, Wärme- und Stoffübertragung, 4th edition, Springer, page 695 */
			break;
			
        default:
            rho = -1.0;
            break;
	} /* switch(id) */
	return rho;
} /* density() */


double specific_volume(double id, double xi, double t, double p)
{
    double vsteam, vliquid, sigma, tau, sv, rho;
    int vp;

 	switch((int)(id+0.5))
	{
		case WATER:  /* Implementation of the values for liquid water and saturated steam *
                      * Bernd Glueck: Zustands- und Stoffwerte                            *
                      * Verlag für Bauwesen, Berlin 1991                                  */
		    if ((int)(t/MAXSATTEMPDEV) == (int) (saturationtemperature(1.0,1.0,t,p)/MAXSATTEMPDEV))
			{
		        vp = (int) p;
			}
		    else
			{
                vp = (int)vapourpressure(1.0,1.0,t,p);
			}
            if (p==0)
			{
				sv = 1.0/ density(id,xi,t,p);
			}
            else if ((int)p < vp || vp < 0.0)
			{	/* water is steam, values from VDI 1963 */
                /* reduced temperature t, reduced pressure p  */
                sigma = p / PRESSKRIT;
                tau = ( t + TA0 ) / TAK_WATER;
                
                sv = 0.0134992 * tau / sigma;
                sv -= ( 4.7331e-3 - 3.17362e-5 * ( 1.55108 - sigma ) * pow( tau, 5.64 ) ) 
                       / pow( tau, 2.82 );
                sv -= sigma * sigma * ( ( 2.93945e-3 - 6.70126e-4 * sigma * ( 1.26591 * sigma - pow( tau, 3. ) ) )
			         / pow( tau, 14. ) + 4.35507e-6 / pow( tau, 32. ) );
                sv -= 8.06867e-5 * tau * ( 1. - 1.32735 * sigma );
            }
			else if ((int)p == vp) 
            {	/*water is mixture of boiling water and saturated steam */ 
                vsteam = saturationproperty(1,1,t,p,8,1);
                vliquid = saturationproperty(1,0,t,p,8,2);
                sv = vsteam*xi+vliquid*(1-xi);
            }
			else
            {   /* water is liquid */
                /* Schmidt, E.: Properties of Water and Steam */                
                if (t > 140.0)
                {	/* range: 140 <= t < 800) */
                    rho = 996.38 - 2.8532e-2*t -3.1823e-3*t*t + 5.2574e-7*p - 7.5637e-15*p*p + 1.9152e-9*t*p;
				}
                else if (t >= 0.0)
				{
    		        rho = 999.85 + t*( 6.1187e-2 + t*(-7.654e-3 
                       + t*( 3.974e-5 - t*( 1.110e-7 ))));
				}
                else if (t >= -20.0)     /* fit from VDI-Wärmeatlas 1988   max_error 0.0000917 */
				{
                    rho = -0.015143*t*t+0.043143*t+999.763;
				}
                else
				{
                   rho = 900.0; /* water is ice */
				}
                if (rho!=0)
				{
					sv = 1.0/rho;
				}
                else
				{
					sv = -1.0;  /* calculation failed */
				}
            }
            break;    
			
        case AIR: case COTOIL: case SILOIL: case WATERGLYCOL:
            sv = 1.0/density(id,xi,t,p);
            break;
			
        case TYFOCOR_LS:
            sv = 1.0/ density(id,xi,t,p);
            break;
			
		case WATER_CONSTANT:
			sv = 1.0/998.21; /* for 20 °C: H.D. Baehr, K. Stephan, Wärme- und Stoffübertragung, 4th edition, Springer, page 696 */
			break;
			
		case AIR_CONSTANT:
			sv = 1.0/1.188;  /* for 20 °C: H.D. Baehr, K. Stephan, Wärme- und Stoffübertragung, 4th edition, Springer, page 695 */
			break;
			
        default:
            sv = -1.0;
            break;
    }   /* switch(id) */
    return sv;
} /* specific volume() */


double heat_capacity(double id, double xi, double t, double p)
{
    double c, cliquid, csteam, l, ca, cl, cv, xs, xl, xv, ps, cso;
    int vp;

 	switch((int)(id+0.5))
	{
		case WATER:
		    if ((int)(t/MAXSATTEMPDEV) == (int) (saturationtemperature(1.0,1.0,t,p)/MAXSATTEMPDEV))
			{
		        vp = (int) p;
			}
		    else 
			{
				vp = (int)vapourpressure(1.0,1.0,t,p);
			}
            if ((int)p < vp || vp < 0.0)
            {  
				if (-60.0<t && t<50.0) /* fitted from Baehr, Thermodynamik, -60°C ..50°C error 0.00386 % */   
				{
					c = (3.75e-4*t+ 0.092143)*t +1859.114;
				}
				else /* for higher pressures / temperatures in the near of the dew point higher errors; in the near of the critical region deviations up to 50 % */
				{	/* water is steam --> polynom from Glueck: Zustands- und Stoffwerte */
					/* 50°C to 450°C, 0.01 MPa to 2 MPa         max_error = 0.0081      */
         
					l = pow((p*1.0e-6),(1.07+0.0944*(p*1.0e-6))) - 0.11*pow((p*1e-6),2);
					if (t!=0.0)
					{
						c = 1.9 + t*(-3.154439e-4 + t*(3.027647e-6 +t*(-3.200767e-9)))
							+ (-1.94949e3 + 2.5e5*l)*pow(t,-2.5)
							+ 2.4e12*square(square(p*1e-6))/(t*t*t*t*t*t);
					}
					else
					{
						c = -0.001;  /* calculation failed */
					}
					c *= 1000.0;
				} 
            } 
            else if ((int)p == vp) 
            {   /* water is mixture of boiling water and saturated steam */ 
                csteam = saturationproperty(1,1,t,p,2,1);
                cliquid = saturationproperty(1,0,t,p,2,2);
                c = csteam*xi+cliquid*(1-xi);
            }             
            else   /* p > vp */
            {   
				if (t <= 0)
				{
					c = 2040; /* water is ice < 0°C, Baehr: Wärme- und Stofübertragung, 1994 */
				}
                else if (t <= 160.0)
				{	/* water is liquid --> own fit, data from Wagner: Waermeuebertragung, 1991 */
                    c = 4.21755e3 + t*(-3.285513443084539 + t*(9.814628609819744e-2
                        + t*(-1.392959667625599e-3 + t*(1.061425030943696e-5
                        + t*(-3.645684367204544e-8 + t*4.123984766679122e-11 )))));
				}
                else if (t<=260.0)
				{
                    c = (4.178e-7*t*t*t - 2.225e-4*t*t + 4.365e-2*t + 1.323)*1000;
				}
                else /* t > 260 */
				{
                    c = 2.9961e-7*t*t*t*t -3.51095e-4*t*t*t + 1.54214e-1*t*t
                         -3.00613e1*t + 2.19777e3;
				}
            }
            break;
            
            
		case AIR:   /* only for 1e5 Pa for the moment */ /* -100°C to 500°C */
		    if (t>=-20.0 && t<=200.0 && p >=0.9e5 && p<=1.1e5)
			{	/* Glueck: Zustandsgrößen und Stoffwerte   max error 0.0005 */ 
                c = 1000*(1.0065 + 5.309587e-6*t + 4.758596e-7*t*t-1.136145e-10*t*t*t);
			}
            else if (p<20.0e5)
			{	/* fit from VDI-Wärmeatlas, max.error = 3.5 % */     
				/* -75..200°C, >1..20 bar */
				c = 1009.01495672421    -0.207912766032049*t
                  + 2.04621051844876e-005*p + 0.00118281266435257*t*t
                  + 7.50877366680047e-014*p*p  -0.126045949982768*log(p);
			}
            else
			{	/* fit from VDI-Wärmeatlas, max.error = 14.7 % */     
				/* -75..200°C, >20..<100 bar */                  
				c = 1392.541274611            -  1.92547495217948*t
                  + 3.28100800469501e-005*p  +  0.00767496698339238*t*t
                  -4.08966289954414e-013*p*p  - 26.8016372500728*log(p);
			}               

            if (xi > 0.0)
            {   /* moist air */
                /* water content vaporous at saturation */
                ps = vapourpressure((double)WATER,0.0,t,0.0);  /* pressure is a dummy */
                xs = 0.6222*ps/(p-ps); /* saturation water content */
				if(xi>xs) /* over saturated */
				{
					xv = xs; /* vapourous water content */
					xl = xi - xs; /* liquid (or solid) water content */
				}
                else
                {
					xv = xi;
                    xl = 0.0;
                }
                ca = c; /* dry air heat capacity already calculated */
                
                if (t < 0.01)
                {   /* moist air is mixture of air and water in solid and vaporous phase */
                    /* heat capacity of vapour*/
                    cv = heat_capacity((double)WATER, 1.0, t, p);
                    /* heat capacity of solid */
                    cso = heat_capacity(1.0,0.0,t,p);
                    /* heat capacity of fluid mix */
                    c = (xl * cso + xv * cv + ca); 
                }
                else /* moist air is mixture of air and liquid/vapouraous water */ 
                {   
                    /* heat capacity of vapour at saturation */
                    cv = saturationproperty((double)WATER, 1.0, t, p, HEAT_CAPACITY, VAPOROUS);

                    if (t < saturationtemperature((double)AIR, xi, t, p))
                    {   /* moist air is mixture of air and water in liquid and vaporous phase */ 
                        /* heat capacity of liquid */
                        cl = heat_capacity((double)WATER,0.0,t,p);
                    }
                    else
                    {
                        cl = 0.0;
                    }
                    
                    /* heat capacity of fluid mix */
                    c = (xl * cl + xv * cv + ca); 
                }
            }
 
            
            break;

		case COTOIL:	/* cotton oil */
			c = 4.2144*t + 1649.0;
            break;

		case SILOIL:	/* silicon oil */
			c = 1.7*t + 1470.0;
            break;

		case WATERGLYCOL:    /* fitted from Adunka91 data */
            xi *= 100.0;     /* in percent */
			c = t*( 3.610080227640085e-002  + xi*(-2.471590456775278e-003 +    
                xi*( 4.378416414199766e-005 + xi*(-2.206548881875750e-007))) + 
                t*(-1.058075689319986e-004  + xi*( 8.201126167829168e-006 +    
                xi*(-1.630532655206974e-007 + xi*( 9.195676812116590e-010)))));
			c = 4223.636919944118           + xi*(-11.53171347245531 +    
                xi*(-2.499319374992276e-001 + xi*( 1.703052389430512e-003))) + 
                t*(-2.369140514594071 +       xi*( 1.630272708066081e-001 +    
                xi*( 5.273110167848944e-004 + xi*(-1.563214167040990e-005))) + 
                c);
            break;

        case TYFOCOR_LS: /* für -30°C < T < 120°C */
             c = 3.977553*t+3.520392e3;
            break;

		case WATER_CONSTANT:
			c = 4181.0; /* for 20 °C: H.D. Baehr, K. Stephan, Wärme- und Stoffübertragung, 4th edition, Springer, page 696 */
			break;
			
		case AIR_CONSTANT:
			c = 1007.0; /* for 20 °C: H.D. Baehr, K. Stephan, Wärme- und Stoffübertragung, 4th edition, Springer, page 695 */
			break;
			
        default:
            c = -1.0;
            break;
	} /* switch(id) */
	return c;
} /* heat_capacity() */


double thermal_conductivity(double id, double xi, double t, double p)
{
    double c, lliquid, lsteam, cs,cso,ca,cl,ps,xs,xl;
    int vp;

 	switch((int)(id+0.5))
	{
		case WATER:
		    if ((int)(t/MAXSATTEMPDEV) == (int) (saturationtemperature(1.0,1.0,t,p)/MAXSATTEMPDEV))
			{
		        vp = (int) p;
			}
		    else
			{
                vp = (int)vapourpressure(1.0,1.0,t,p);
			}
            if ((int)p < vp || vp < 0.0)  /* water is steam */ /* errors increase with pressure (e.g. 10 bar up to 3.5 %) */
            {	/* Glueck 50°C to 400°C, 0.01 MPa to 2 MPa    max error = 0.0123  */
                c = 1.71e-2 + t*(5.875435e-5 + t*(1.169690e-7 + t*(-7.180650e-11)))
                    + 0.0199*(p*1e-6 - 0.01)*exp(-0.0077*t);
			}
            else if ((int)p == vp) 
            {   /*water is mixture of boiling water and saturated steam */ 
                lsteam = saturationproperty(1,1,t,p,3,1);
                lliquid = saturationproperty(1,0,t,p,3,2);
                c = lsteam*xi+lliquid*(1-xi);
            }
			else
            {   /* water is liquid */
                if (t < 0)
				{	/* VDI-Wärmeatlas 1988   max_error 2.169e-16 */
                    c = 0.562 + t*(0.00109 + t*(-0.000391+t*(-3.76e-5-t*1.08e-6)));
				}
                else if (t <= 160.0)
				{	/* Glueck: Zustandsgrößen und Stoffwerte   max error 0.0022 */ 
                    c = 5.587913e-1 + t*(2.268458e-3 + t*(-1.248304e-5 + t*(1.890318e-8)));
				}
                else
				{
                    c = ((-1.396526e-13*t*t*t*t + 2.140341e-10*t*t*t
                        -1.3470567e-7*t*t + 4.451069e-5*t -8.1432715e-3)*t
                        +7.8177696e-1)*t -30.0704;
				}
            }
            break;
			
		case AIR: /* only for 1e5 Pa for the moment */
 	        c = 2.498583110194e-002 + -1.090866188829e-009*p*1e-5 + 6.857401550894e-010*p*p*1e-10 + -1.968021762265e-010*p*p*p*1e-15
                + 6.535367184087e-005*t + -7.692342578961e-009*t*t + -1.897469024167e-012*t*t*t
                + -1.387285112633e-010/(p*1e-5) 
                + -4.213789828084e-014*t/(p*1e-5)
                + 2.173726797621e-011*p*p*p*p*1e-20 + 1.455466843591e-015*t*t*t*t ;
	          
            if (xi > 0.0)
            {   /* moist air */
                /* water content vaporous at saturation */
                ps = vapourpressure(1.0,0.0,t,p);
                xs = 0.6222*ps/(p-ps);            
                /* water content liquid */
                xl = xi - xs;  /* = xso */
				if (t < 0.01)
				{	/* moist air is mixture of air and water in solid and vaporous phase */
					/* thermal_conductivity of vapour at saturation*/
					cs = saturationproperty(1.0, xs, t, p, THERMAL_CONDUCTIVITY, VAPOROUS);
					/* thermal_conductivity of solid */
					cso = thermal_conductivity(1.0,0.0,t,p);
					/* thermal_conductivity of air */
					ca = thermal_conductivity(2.0,0.0,t,p);
					/* thermal_conductivity of fluid mix */
					c = (xl * cso + (xs * cs + ca))/(1 + xi); 
				}
				else if (t < saturationtemperature(2.0, xi, t, p))
				{	/* moist air is mixture of air and water in liquid and vaporous phase */ 
                    /* thermal_conductivity of vapour at saturation*/
                    cs = saturationproperty(1.0, xi, t, p, THERMAL_CONDUCTIVITY, VAPOROUS);
                    /* thermal_conductivity of liquid */
                    cl = thermal_conductivity(1.0,0.0,t,p);
                    /* thermal_conductivity of air */
                    ca = thermal_conductivity(2.0,0.0,t,p);
                    /* thermal_conductivity of fluid mix */
                    c = (xl * cl + (xs * cs + ca))/(1 + xi); 
				}
				else if (t >= saturationtemperature(2.0, xi, t, p))
				{	/* moist air is mixture of air and water in vaporous phase */
                    cs = thermal_conductivity(1.0,1.0,t,vapourpressure(1.0,0.0,t,p));
                    ca = thermal_conductivity(2.0,0.0,t,p);
                    c = ((xi * cs + ca)/(1 + xi));  /* xi = xs, if t>= saturationtemperature */
				}
				else
				{
                     c = -1.0;  /* calculation failed */
				}
            }
            break;
			
		case COTOIL:     /* cotton oil */
			c = 0.169 - 1.342e-4*t;
            break;
			
		case SILOIL:	/* silicon oil */
			/* data from Teichmann: Bericht Carlib-Validierung HSD, 2016 
             * (remark: equation c = 0.0017*t + 1.574; is wrong)
             * Source: Syltherm 800 - Manufacturer DOW - Product information
             */
            c = -0.000188076923076923*t + 0.138770512820513;
            break;
			
		case WATERGLYCOL: /* fitted from Adunka91 data */
            xi = xi*100.0;   /* in percent */
			c = t*(-8.273646532405401e-006 + xi*(-8.159028398563302e-007 +
                xi*( 1.419387521066986e-008 + xi*(-6.011521361767284e-011))) +
                t*(-6.200664366083245e-010 + xi*( 3.425957621761650e-009 +
                xi*(-4.877629569113623e-011 + xi*( 1.471192853339312e-013)))));
        	c = 5.599018706509451e-001 + xi*(-5.473076651398347e-003 +
                xi*( 2.667551459920901e-005 + xi*(-8.306804717746987e-008))) +
                t*( 1.940361259016100e-003 + xi*(-8.463380261282282e-005 +
                xi*( 1.274778893577746e-006 + xi*(-6.457473084375714e-009))) +
                c);
            break;
			
		case WATER_CONSTANT:
			c = 0.5984; /* for 20 °C: H.D. Baehr, K. Stephan, Wärme- und Stoffübertragung, 4th edition, Springer, page 696 */
			break;
			
		case AIR_CONSTANT:
			c = 0.02569; /* for 20 °C: H.D. Baehr, K. Stephan, Wärme- und Stoffübertragung, 4th edition, Springer, page 695 */
			break;
			
        case TYFOCOR_LS: /* for -30°C < T < 120°C  max f = 0.194 %  */
            c = 7.011693e-4*t+3.991658e-1;
            break;
        default:
            c = -1.0;
            break;
	} /* switch(id) */
	
	if (c<=0.0)
	{
	   c = -1.0;
	}
	
	return c;
} /* thermal_conductivity() */


double temperature_conductivity(double id, double xi, double t, double p)
{
    double a, aliquid, asteam;
    int vp, iid;
    
    iid = (int)(id+0.5);
 	switch(iid)
	{
		case WATER: /* deviations for high pressures and high temperature rise to 6 % */
			if ((int)(t/MAXSATTEMPDEV) == (int) (saturationtemperature(1.0,1.0,t,p)/MAXSATTEMPDEV))
			{
				vp = (int) p;
			}
			else 
			{
				vp = (int)vapourpressure(1.0,1.0,t,p);
			}
            
			if ((int)p < vp || vp < 0.0)  /* water is steam */
            {    /* Glueck 50°C to 400°C, 0.01 MPa to 2 MPa */
                 a = thermal_conductivity(1,1,t,p)/density(1,1,t,p)/heat_capacity(1,1,t,p);
            }
            else if ((int)p == vp) 
            {   /*water is mixture of boiling water and saturated steam */ 
                asteam = saturationproperty(1,1,t,p,THERMAL_CONDUCTIVITY,VAPOROUS)
                         /saturationproperty(1,1,t,p,DENSITY,VAPOROUS)
                         /saturationproperty(1,1,t,p,HEAT_CAPACITY,VAPOROUS);
                aliquid = saturationproperty(1,1,t,p,THERMAL_CONDUCTIVITY,LIQUID)
                         /saturationproperty(1,1,t,p,DENSITY,LIQUID)
                         /saturationproperty(1,1,t,p,HEAT_CAPACITY,LIQUID);
                a = asteam*xi+aliquid*(1-xi);
            }
			else
            {   /* water is liquid */
                a = thermal_conductivity(1,0,t,p)/density(1,0,t,p)/heat_capacity(1,0,t,p);
            }
             break;
		case AIR: case COTOIL: case SILOIL: case WATERGLYCOL: case TYFOCOR_LS:
             a = thermal_conductivity(iid,xi,t,p)/density(iid,xi,t,p)/heat_capacity(iid,xi,t,p);           
             break;
		case WATER_CONSTANT: case AIR_CONSTANT:
             a = thermal_conductivity(iid,0.0,20,1013e2)/density(iid,0.0,20,1013e2)/heat_capacity(iid,0.0,20.0,1013e2);           
             break;
        default:
            a = -1.0;
            break;
	} /* switch(id) */
	
	if (a<=0.0)
	{
	   a = -1.0;
	}
	
	return a;
} /* temperature_conductivity() */



double enthalpy(double id, double xi, double t, double p)
{
    double h, hsteam, hliquid, i, i0, tau, sigma, Tr;
    int vp;

 	switch((int)(id+0.5))
	{
		case WATER:
		    if ((int)(t/MAXSATTEMPDEV) == (int) (saturationtemperature(1.0,1.0,t,p)/MAXSATTEMPDEV))
			{
		        vp = (int) p;
			}
		    else 
			{
				vp = (int)vapourpressure(1.0,1.0,t,p);
			}
            if ((int)p < vp || vp < 0.0)
            {   /* water is steam */
                /* reduced temperature t, reduced pressure p  */
                /* VDI 1963 */
                tau = ( t + TA0 ) / TAK_WATER;
                sigma = p  / PRESSKRIT;
                i0 = 478.4866 + 279.4174 * tau - 1.92399 * tau * tau;
                i0 += 17.61866 * pow( tau, 3.) - 3.11137 * pow( tau, 4. );
                i = ( 3.82 * 4.7331e-3 / pow( tau, 2.82 )
			          + 1.82 * 3.17362e-5 * pow( tau, 2.82 )
			          * ( 1.55108 - sigma / 2. ) ) * sigma;
                i += ( ( 5. * 2.93945e-3 - 3. * 6.70126e-4 * sigma
			          * ( 1.26591 * sigma - pow( tau, 3. ) ) )
			          / pow( tau, 14. )
			          + 11. * 4.35507e-6 / pow( tau, 32. ) )
			          * pow( sigma, 3. );
                i = i0 - 5285.35 * i;
                h = 4.1868 * i * 1000;
            } 
			else if ((int)p == vp) 
            {   /* water is mixture of liquid water and steam */
                hsteam = saturationproperty(1,1,t,p,5,1);
                hliquid = saturationproperty(1,0,t,p,5,2);
                h = (hsteam*xi+hliquid*(1-xi));
            }
			else if (t <= 30 && p<=10e5) /* Glueck: Zustandsgrößen und Stoffwerte  max_error = 0.0222*/ 
			{
                h = (0.938+4.204920*t-5.942827e-4*t*t+4.310326e-7*t*t*t)*1e3;
			}
            else if (t <= 30)
			{	/* Schmidt, E.: Properties of Water and Steam */
				/* max error 6.2% bei 0°C, sonst <0.2%  */
				h = (0.10079e-5*p +4.196*t + 0.035315 -3.0734e-16*p*p
					-0.00023*t*t -0.00033338e-5*p*t)*1e3;
			}
			else if (t <= 200)  /* liquid water */
			{	/* Schmidt, E.: Properties of Water and Steam  max error 0.21 %  */
				h = (0.099159e-5*p +  4.0822*t +  3.0335 -1.6451e-16*p
					+  0.00075719*t*t -0.00024377e-5*t*p)*1e3;
			}
			else  /* Schmidt, E.: Properties of Water and Steam    max error = 2.6 %*/
			{
				h = (0.35098e-5*p -0.73947*t +554.23  +0.00025197e-10*p*p 
				+ 0.011461*t*t  -0.0017882e-5*p*t)*1e3;
			}
            break;
		case AIR:
            /* Baehr, BWK Bd. 40 (1988)           */
            /* -50°C < t < 2250 °C                */
            /* max. error 2e-4                    */
            Tr = (t+273.15)/1000.0;
            h = -0.063616 * pow(Tr,-4) + 2.318450 * pow(Tr,-3)
                -40.594004 * pow(Tr,-2) + 527.344724 * pow(Tr,-1)
				+ 2073.666933 * pow(Tr,0)  + -4045.847662 * pow(Tr,1)
				+ 3693.979192 * pow(Tr,2)  + -2085.579907 * pow(Tr,3)
				+  836.201311 * pow(Tr,4)  + -220.023509 * pow(Tr,5)
				+   33.913350 * pow(Tr,6)  + -2.314129 * pow(Tr,7)
				+ 2076.578399 * log(Tr);
            h *= 1.0e3;
            
            if (xi > 0.0)
            {   /* moist air */

                /* Baehr: Thermodynamik, 1996 S. 218 */
                if (t >= saturationtemperature(2.0, xi, t, p))
                {	/* moist air is mixture of air and water in vaporous phase */
					double r0,cs0;
					r0 = 2501504.5; /*evaporation_enthalpy(1,1,0,1e5);*/
					cs0 = 1854.283; /*heat_capacity(1,1,0,vapourpressure(1,1,0,1e5));*/
					h += xi*(r0+cs0*t);               
                }
                else if (t >= 0)
                {	/* moist air is mixture of air and water in liquid and vaporous phase */
					double ps,xs,xl,r0,cs0;
					/* water content vaporous at saturation */
					ps = vapourpressure(1.0,0.0,t,p);
					xs = 0.6222*ps/(p-ps);            
					/* water content liquid */
					xl = xi - xs;  /* = xso */
                 
					r0 = 2501504.5; /*evaporation_enthalpy(1,1,0,1e5);*/
					cs0 = 1854.283; /*heat_capacity(1,1,0,vapourpressure(1,1,0,1e5));*/

					if (xl>0)
					{
						h += xs*(r0+cs0*t) + xl*heat_capacity(1,0,t,p)*t;
					}
					else
					{
						h += xi*(r0+cs0*t);
					}
                }                
                else 
                {	/* moist air is mixture of air and ice and water in vaporous phase */
					double ps,xs,xl,r0,cs0;
					/* water content vaporous at saturation */
					ps = vapourpressure(1.0,0.0,t,p);
					xs = 0.6222*ps/(p-ps);            
					/* water content liquid */
					xl = xi - xs;  /* = xso */
                 
					r0 = 2501504.5; /*evaporation_enthalpy(1,1,0,1e5);*/
					cs0 = 1854.283; /*heat_capacity(1,1,0,vapourpressure(1,1,0,1e5));*/

					h += xs*(r0+cs0*t) - xl*(333e3 - heat_capacity(1,0,t,p)*t); /*333 kJ latent heat of ice */                    
                }                
            }
            break;
		case COTOIL:     /* cotton oil */
			h = (935.0 - 0.6806 * t)*t;
            break;
		case SILOIL:
			h = (983.1 - 0.9232*t)*t;
            break;
		case WATERGLYCOL:    /* fitted from Adunka91 data */
			xi = xi*100;   /* in percent */
			h = t*(-6.845166114722718e-003  + xi*( 1.598552881093090e-004 +
				xi*(-2.500513947679818e-006 + xi*( 1.353169632549166e-008))) +
				t*( 2.199819078440755e-005  + xi*(-9.643408179314126e-007 +
				xi*( 2.189831042031030e-008 + xi*(-1.318311789959629e-010)))));
			h = (9.998510249903282e+002    + xi*( 1.402898851698828e+000 +
				xi*( 4.720597537855296e-003 + xi*(-5.932727559791945e-005))) +
				t*( 5.547642027503766e-002  + xi*(-8.269670418186260e-003 +
				xi*(-4.776070860890714e-005 + xi*( 6.261556797531848e-007))) +
				h))*t;
            break;
        case TYFOCOR_LS: /*only in monophasic liquid zone*/
			h=heat_capacity(id,xi,t,p)*t;
			break;
		case WATER_CONSTANT:  /* Source: IAPWS97, values for pressure 1013 hPa, temperature 20°C */
            h = 84013.0346245843;
            break;
		case AIR_CONSTANT:
            h = 0.0;           
            break;
        default:
            h = -1.0;
            break;
	} /* switch(id) */
	
	return h;
} /* enthalpy() */


double entropy(double id, double xi, double t, double p)
{
    double s, s0, sliquid, ssteam, tau, sigma, Tr;
    int vp;

 	switch((int)(id+0.5)){
		case WATER:
		    if ((int)(t/MAXSATTEMPDEV) == (int) (saturationtemperature(1.0,1.0,t,p)/MAXSATTEMPDEV))
			{
				vp = (int) p;
			}
		    else
			{
				vp = (int)vapourpressure(1.0,1.0,t,p);
			}
            if (((int)p < vp || vp < 0.0) && t < 800.0)
			{	/* water is steam */
                /* reduced temperature t, reduced pressure p  */
                sigma = p  / PRESSKRIT;
                tau = ( t + TA0 ) / TAK_WATER;
                s0 = 0.431666 * log( tau ) + 2.554752;
                s0 += -5.94467e-3 * tau + 0.0408280 * tau * tau;
                s0 -= 6.40892e-3 * pow( tau, 3.);
                s = ( 2.82 * 4.7331e-3 / pow( tau, 3.82 )
			          + 2.82 * 3.17362e-5 * pow( tau, 1.82 )
			          * ( 1.55108 - sigma / 2. )
			          - 8.06867e-5 * ( 1. - 1.32735 * sigma / 2. ) )
			          * sigma;
                s += ( ( 14. * 2.93945e-3 / 3. - 6.70126e-4 * sigma
			            * ( 14. * 1.26591 * sigma / 5.
				        - 11. * pow( tau, 3. ) / 4. ) )
			            / pow( tau, 15. )
			            + 32. * 4.35507e-6 / 3. / pow( tau, 33. ) )
			            * pow( sigma, 3. );
                s = s0 - 8.16522 * 0.0134992 * log( sigma / 2.760e-5 )
			            - 8.16522 * s;
                s = 4.1868 * s * 1000;
            }
            else if ((int)p == vp) 
            {   /* water is mixture of boiling fluid and saturated steam */
                ssteam = saturationproperty(1,1,t,p,6,1);
                sliquid = saturationproperty(1,0,t,p,6,2);
                s = ssteam*xi+sliquid*(1-xi);
            }
			else if (p < 22.1287e6 && t >= 0.0 && t < TEMPKRIT) /* liquid water */
			{	/* Schmidt, E.: Properties of Water and Steam */
                s = 56.327 + 12.8707*t - 7.0459e-3*t*t - 0.075516*p*1e-5 - 3.6913e-4*p*p*1e-10 
                    - 6.3467e-4*t*p*1e-5;
			}
            else
                s = -1.0;
            break;
		case AIR: /* from -50°C to 2250°C */
            /* Baehr, BWK Bd. 40 (1988)           */
            /* -50°C < t < 2250 °C                */
            /* max. error 2e-4                    */
            Tr = (t+273.15)/1000;
             
            s= -0.00005089 * pow(Tr,-5) + 0.00173884 * pow(Tr,-4)  /* standardentropy */
               -0.02706267 * pow(Tr,-3) + 0.26367236 * pow(Tr,-2)
               -2.07657840 * pow(Tr,-1) + 4.83742931 * pow(Tr,0)
               + 7.38793838 * pow(Tr,1)   -3.12836986 * pow(Tr,2)
               + 1.11493508 * pow(Tr,3)   -0.27502939 * pow(Tr,4)
               + 0.04069602 * pow(Tr,5)   -0.00269982 * pow(Tr,6)
               -4.04584756 * log(Tr);
            s = s*1e3 -287.06*log(p/1e5);     /* spez. Entropy */
		    if (xi > 0.0)
		    {
				double Xil,Xiw,yl,yw;

		        Xiw = xi/(1.+xi);
		        Xil = 1./(1.+xi);
		        yl = 1./(xi*0.6222+1.);
		        yw = 1./(1.+1./(xi+0.6222));
		        s =  Xil*(s - 0.28706*log(yl))
                    + Xiw*(entropy(WATER,xi,t,p) - 0.46152*log(yw));
		    }
		    
            break;
        case TYFOCOR_LS:
            s=-1.0;/*no correlation yet*/
            break;
		case WATER_CONSTANT: /* IAPWS97, values for pressure 1013 hPa, temperature 20°C */
            s = 296.482651731789;           
            break;
		case AIR_CONSTANT:
            s = 0.0;           
            break;
        default:
            s = -1.0;
            break;
	} /* switch(id) */
	
	return s;
} /* entropy() */

double evaporation_enthalpy(double id, double xi, double t, double p)
{
    double r, hsteam, hliquid;

 	switch((int)(id+0.5))
	{
		case WATER:         
            if (t <= TEMPKRIT && p <= PRESSKRIT)
			{
                hsteam = saturationproperty(1,1,t,p,5,1);
                hliquid = saturationproperty(1,0,t,p,5,2);
                r = hsteam - hliquid;    
            }
			else
			{
                r = -1.0;
			}
            break;
        case WATER_CONSTANT:  /* % Source: IAPWS97, values for pressure 1013 hPa, temperature 20°C */
            r = 2454158.62854583;
            break;
        case AIR: case COTOIL: case SILOIL:	case WATERGLYCOL: case TYFOCOR_LS: case AIR_CONSTANT: default:
            r = -1.0;
            break;
    } /* switch(id) */
	return r;
} /* end evaporation_enthalpy() */


double vapourcontent(double id, double xi, double t, double p, double value, int prop)
{
    double steam, liquid, vap_cont;

    switch (prop)
    {
        case DENSITY:
             steam = saturationproperty(id, 1, t, p, DENSITY, VAPOROUS);
             liquid = saturationproperty(id, 0, t, p, DENSITY, LIQUID);
             vap_cont = (value - liquid)/(steam - liquid);
            break;
        case HEAT_CAPACITY:
             steam = saturationproperty(id, 1, t, p, HEAT_CAPACITY, VAPOROUS);
             liquid = saturationproperty(id, 0, t, p, HEAT_CAPACITY, LIQUID);
             vap_cont = (value - liquid)/(steam - liquid);
            break;
        case THERMAL_CONDUCTIVITY:
             steam = saturationproperty(id, 1, t, p, THERMAL_CONDUCTIVITY, VAPOROUS);
             liquid = saturationproperty(id, 0, t, p, THERMAL_CONDUCTIVITY, LIQUID);
             vap_cont = (value - liquid)/(steam - liquid);
            break;
        case VISCOSITY:
             steam = saturationproperty(id, 1, t, p, VISCOSITY, VAPOROUS);
             liquid = saturationproperty(id, 0, t, p, VISCOSITY, LIQUID);
             vap_cont = (value - liquid)/(steam - liquid);
            break;
        case ENTHALPY:
             steam = saturationproperty(id, 1, t, p, ENTHALPY, VAPOROUS);
             liquid = saturationproperty(id, 0, t, p, ENTHALPY, LIQUID);
             vap_cont = (value - liquid)/(steam - liquid);
            break;
        case ENTROPY:
             steam = saturationproperty(id, 1, t, p, ENTROPY, VAPOROUS);
             liquid = saturationproperty(id, 0, t, p, ENTROPY, LIQUID);
             vap_cont = (value - liquid)/(steam - liquid);
            break;
        case PRANDTL:
             steam = saturationproperty(id, 1, t, p, PRANDTL, VAPOROUS);
             liquid = saturationproperty(id, 0, t, p, PRANDTL, LIQUID);
             vap_cont = (value - liquid)/(steam - liquid);
            break;
        case SPECIFIC_VOLUME:
             steam = saturationproperty(id, 1, t, p, SPECIFIC_VOLUME, VAPOROUS);
             liquid = saturationproperty(id, 0, t, p, SPECIFIC_VOLUME, LIQUID);
             vap_cont = (value - liquid)/(steam - liquid);
            break;
        default:
            vap_cont = 0.0;
            break;
        } /* end switch */
    return vap_cont;
} /* vapourcontent */



/* kinematic viscosity of fluids [m^2/s] */

/*
 * special case: water/glycol mix
 *
 * Table interpolation gives an max. error of 2.7% for pure water against
 * the corresponding polynominal. 2-dimensional polynominal interpolation
 * instead led to negative viscosity values, which was not exactly what
 * we wanted. Extrapolation of 100% glycol far beyond 100 degree
 * centigrade is not recomended, because the real function becomes
 * extremly nonlinear in that area. Extrapolations beyond 0 degree is far
 * less critical.			14may98 <rhh>
 */

double mixViscosity(double id, double x, double t, double p)
{
    #define XMAXNUM  6
    #define TMAXNUM	13

    static double mixVisc[XMAXNUM][TMAXNUM]=
    {{5,3,1.8,1.3,0.97,0.78,0.65,0.56,0.49,0.43,0.39,0.36,0.33}, /* x = 0% */
     {10,7,4.9,3.6,2.7,1.9,1.5,1.2,1,.83,.73,.65,.6},            /* x = 20% */
     {50,23,13,7.5,4.9,3.4,2.5,1.9,1.5,1.3,1.1,.95,.86},         /* x = 40% */
     {80,35,28,15,10,6.5,4.7,3.5,2.7,2.1,1.7,1.4,1.2},           /* x = 60% */
     {400,170,79,41,23,14,9.3,6.4,4.7,3.5,2.8,2.3,1.95},         /* x = 80% */
     {2000,800,300,145,68,39,25,17,12,8,6,4.6,3.8}};             /* x = 100% */

    int     ixn,itn;
    double  xn,tn, viscT, visc, dv_dt, dv_dx;

    /* range check percentage... */
    if(x < 0.0)
	{
        x = 0.0;			/* just bound it */
	}
    else if(x > 1.0)
	{
        x = 1.0;
	}

    ixn = (int)(x*5.0);		/* x -> integer array index .le. x */


    /* range check temperature... */
    if(t <= -20.0)         /* neg. extrapolation */
	{
        itn = 0;
	}
    else if(t > 100.0)     /* pos. extrapolation */
	{
        itn = TMAXNUM-2;
	}
    else				   /* interpolation */
	{
        itn = (int)(t*0.1) + 1; /* t -> integer array index .le. t */
	}

    /* do the linear xx-polation... */
    xn = (double) (ixn) / 5;  	/* first valid array percentage beneath x */
    tn = (double) (itn-2) * 10; /* first valid array temperature beneath t */

    dv_dt = (mixVisc[ixn][itn+1] - mixVisc[ixn][itn]) * 0.1; /* part. deriv.'s */
    dv_dx = (mixVisc[ixn+1][itn] - mixVisc[ixn][itn]) * 5.0;

    viscT = mixVisc[ixn][itn] + dv_dt*(t-tn);
    visc  = (viscT + dv_dx*(x-xn)) * 1e-6;

    return(visc);
} /* mixViscosity() */



double viscosity(double id, double xi, double t, double p)
{
    double eta, etasteam, etaliquid, etaa,etas,etaso,etal,ps,xs,xl;
    int vp;

    switch ((int)(id+0.5))
	{
        case WATER:
		    if ((int)(t/MAXSATTEMPDEV) == (int) (saturationtemperature(1.0,1.0,t,p)/MAXSATTEMPDEV))
			{
		        vp = (int) p;
			}
		    else
			{
                vp = (int)vapourpressure(WATER,1.0,t,p);
			}
            if ((int)p < vp || vp < 0.0)
            {   /* Glueck: Zustandsgrößen und Stoffwerte   max error 0.0029  */
                /* water is steam */ /* 50°C to 400°C, 0.01 MPa to 2 MPa */
                eta = 9.054339e-6 + t*(2.941217e-8 + t*(4.021091e-11 - t*(4.379615e-14)))- 
                        1e-12*p*exp(-0.007*t);
                eta *= specific_volume(WATER, 1.0, t, p);
            }
			else if ((int)p == vp)
            {   /*water is mixture of boiling water and saturated steam */               
                etasteam = saturationproperty(WATER,1,t,p,4,1);
                etaliquid = saturationproperty(WATER,0,t,p,4,2);
                eta = etasteam*xi + etaliquid*(1.0-xi);
            }
			else
            {   /* water is liquid */
                if (t < 0.0)
				{	/* VDI-Wärmeatlas 1988   max error 0.000373  */
                    eta = 1.792e-6 + t*(-7.2833e-8+t*(-2.0133e-9+t*(-4.026e-10-t*8.288e-12)));
				}
				else if (t < 160)
				{	/* Glueck: Zustandsgrößen und Stoffwerte   max error 0.003  */
					eta = 1.0/(556272.7 + t*(19703.39 + t*(124.409 - t*0.3770952)));
				}
				else   	 /* VDI-Wärmeatlas 1988   max error 1 %*/
				{
                    eta = (3.0835e-010*p -0.0011449*t +0.31892 -4.412e-018*p*p
                          + 1.5885e-006*t*t -1.867e-013*p*t)*1e-6;
				}
            }
            break;
        case AIR:   /* only for 1e5 Pa for the moment */
            if (xi > 0.0)
            {   /* moist air */
				/* water content vaporous at saturation */
				ps = vapourpressure(1.0,0.0,t,p);
				xs = 0.6222*ps/(p-ps);            
				/* water content liquid */
				xl = xi - xs;  /* = xso */
				if (t < 0.01)
				{	/* moist air is mixture of air and water in solid and vaporous phase */
					/* viscosity of vapour at saturation*/
					etas = saturationproperty(1.0, xs, t, p, VISCOSITY, VAPOROUS);
					/* viscosity of solid */
					etaso = viscosity(1.0,0.0,t,p);
					/* viscosity of air */
					etaa = viscosity(2.0,0.0,t,p);
					/* viscosity of fluid mix */
					eta = (xl * etaso + (xs * etas + etaa))/(1 + xi); 
				}
				else if (t < saturationtemperature(2.0, xi, t, p))
				{	/* moist air is mixture of air and water in liquid and vaporous phase */ 
					/* viscosity of vapour at saturation*/
					etas = saturationproperty(1.0, xi, t, p, VISCOSITY, VAPOROUS);
					/* viscosity of liquid */
					etal = viscosity(1.0,0.0,t,p);
					/* viscosity of air */
					etaa = viscosity(2.0,0.0,t,p);
					/* viscosity of fluid mix */
					eta = (xl * etal + (xs * etas + etaa))/(1 + xi); 
				}
				else if (t >= saturationtemperature(2.0, xi, t, p))
				{	/* moist air is mixture of air and water in vaporous phase */
					etas = viscosity(1.0,1.0,t,vapourpressure(1.0,0.0,t,p));
					etaa = viscosity(2.0,0.0,t,p);
					eta = ((xi * etas + etaa)/(1 + xi));  /* xi = xs, if t>= saturationtemperature */
				}
				else
				{
					eta = -1;
				}
            }
			else /* if xi==0 */
            {
				if (p>=0.99e5 && p <=1.01e5)
				{
					/* Glueck: Zustandsgrößen und Stoffwerte   max error 0.0003  */                
					/* 1 bar, -20..200°C */
					eta = 1.35198e-5 + t*(8.930841e-8 + t*(1.094808e-10 - t*3.659345e-14));
				}
				else if (-20.0<=t && t<=20.0)
				{	/* fit from FluidExl-Values                                 */
					/* -20°C<=t<=20°C, 0.5bar <= p <=2 bar, max.rel.error = 0.0002 */
					eta = -2.400077647349e-008 + 3.954095671819e-009*p*1e-5 + 6.010463719314e-009*p*p*1e-10 + -5.346762840607e-009*p*p*p*1e-15
						+ 2.548435977491e-011*t + 8.636197926264e-011*t*t + 7.580349847195e-013*t*t*t
						+ 1.346085515812e-005/(p*1e-5) 
						+ 8.538700084364e-008*t/(p*1e-5)
						+ 1.189959676455e-009*p*p*p*p*1e-20 + 7.016630639601e-014*t*t*t*t;
				}
				else if (20.0 < t && t < 120.0)
				{	/* fit from FluidExl-Values                                 */
					/* 20°C<=t<=200°C, 0.5bar <= p <=2 bar, max.rel.error = 0.036 */
					eta = 9.928090804498e-007 + 5.407495561150e-010*p*1e-5 + -4.968562083166e-010*p*p*1e-10 + 2.088452183357e-010*p*p*p*1e-15
						+ -2.244444170184e-008*t + 1.041180535824e-010*t*t + -5.833102110968e-014*t*t*t
						+ 1.237944251808e-005/(p*1e-5) 
						+ 1.095691676377e-007*t/(p*1e-5)
						+ -3.264224018787e-011*p*p*p*p*1e-20 + 3.392992258699e-017*t*t*t*t;
				}
				else
				{
					eta = -1.0;
				}
			}
            break;
        case COTOIL:       
            if (t!=0)                                               
			{
				eta = 5.5328e-7 + (((24.842/t - 2.99177)/t + 0.12077)/t - 2.0783e-4)/t;
			}
            else
			{
				eta = -1;  /* calculation failed */
			}
            break;
        case SILOIL:                                                          
            eta = (2.5881+exp(3.92223*exp((15.24688-t)/143.42001)))*1.0e-6;
            break;
        case WATERGLYCOL:
            if (p >= vapourpressure(WATERGLYCOL,xi,t,p))
			{
    	        eta = mixViscosity(WATERGLYCOL,xi,t,p);
			}
            else
			{
                eta = -1.0;
			}
            break;
        case TYFOCOR_LS:
			if (-40.0 <= t && t <= 140.0)  // validated from -30 to 120 °C
			{
				eta = exp(((((8.469770e-11*t - 4.007900e-8)*t +
                    1.530728e-6)*t + 4.635253e-4)*t 
                    - 6.174704e-2)*t -1.116944e+001);
			}  
            else
			{
               eta = -1.0;
			}
            break;
		case WATER_CONSTANT:
			eta = 1.004e-6; /* for 20 °C: H.D. Baehr, K. Stephan, Wärme- und Stoffübertragung, 4th edition, Springer, page 696 */
			break;
		case AIR_CONSTANT:
			eta = 15.35e-6;
			break; /* for 20 °C: H.D. Baehr, K. Stephan, Wärme- und Stoffübertragung, 4th edition, Springer, page 695 */
        default:
            eta = -1.0;
            break;
    } /* switch(id) */

    return eta;
} /* viscosity() */


double grashof(double id, double xi, double twall, double tinf, double p, double x)
{
    double gras;
    double dwall, dinf;

    dwall = density(id, xi, twall, p);
    dinf = density(id, xi, tinf, p);
    if (dwall==-1 || dinf == -1)
       gras = -1;
    else
    {
      gras = dwall;
      gras = 9.81*x*x*x * (gras - dinf)
          / (gras * square(viscosity(id, xi, (twall+tinf)*0.5, p)));
      gras = (gras < 0.0)? -gras : gras; /* no negative values */
    }
    return gras;
}


double prandtl(double id, double xi, double t, double p)
{
    double pran, pransteam, pranliquid;
    int vp;
    
    if ((int)t == (int) saturationtemperature(1.0,1.0,t,p))
	{
		vp = (int) p;
	}
    else 
	{
		vp = (int)vapourpressure(WATER,1.0,t,p);
	}

    
    if ((int)(id+0.5) == WATER && (int)p == vp)
	{	/* water is mixture of boiling water and saturated steam */ 
        pransteam = saturationproperty(1,1,t,p,7,1);
        pranliquid = saturationproperty(1,0,t,p,7,2);
        pran = pransteam*xi+pranliquid*(1-xi);
    }
    else
	{
        pran = density(id, xi, t, p) * viscosity(id, xi, t, p) *
            heat_capacity(id, xi, t, p) / thermal_conductivity(id, xi, t, p);
	}

    return pran;
} /* end prandtl */


/* function to check the input range for the fluid property functions */
int rangecheck(int property, double id, double xi, double t, double p)
{
    int check = RANGEISCORRECT; /* assume that check is ok */
    /* see enum RANGECHECKERRORS for other values      */
    
    switch(property)
    {    
  	    case DENSITY:
	    case HEAT_CAPACITY:
	    case THERMAL_CONDUCTIVITY:
	    case VISCOSITY:
	    case PRANDTL:
	    case SPECIFIC_VOLUME:
	    case VAPOURPRESSURE:
	    case SATURATIONTEMPERATURE:
	    case SATURATIONPROPERTY:
	    case TEMPERATURE_CONDUCTIVITY:
	    case ENTHALPY2TEMPERATURE:
	    case ENTHALPY:
        case ENTROPY: 
	    case EVAPORATION_ENTHALPY:
            switch ((int)(id+0.5))
            {
                case WATER:             
                    if (p < vapourpressure(id, xi, t, p))
                    { /* fluid is vaporous */
                        if (t > 800.0)
						{
                            check = check | TEMPERATUREOUTOFRANGE;
						}
                        if (p > 4.9033e7 || p < 0.0)
						{
                            check = check | PRESSUREOUTOFRANGE;
						}
                    }
					else
					{ /* fluid is mixture of boiling fluid and saturated steam*/  
                        if (t < 0.0 || t > TEMPKRIT)
						{
                            check = check | TEMPERATUREOUTOFRANGE;
						}
                        if (p > PRESSKRIT)
						{
                            check = check | PRESSUREOUTOFRANGE;
						}
                    }
               		if (xi>1.0 || xi<0.0)
					{
                        check = check | MIXTUREOUTOFRANGE;
					}
                    break;   
                case AIR:
                    if (t < -100.0 || t > 1000.0)
					{
                        check = check | TEMPERATUREOUTOFRANGE;
					}
                    if (p < 0.9e5 || p > 1.0e7)
					{
                        check = check | PRESSUREOUTOFRANGE;
					}
                    break;
                 case WATERGLYCOL:
               		if (xi>1.0 || xi<0.0)
					{
                        check = check | MIXTUREOUTOFRANGE;
					}
                    break;
                 case COTOIL: case SILOIL:
                    if (t < -10.0 || t > 250.0)
					{
                        check = check | TEMPERATUREOUTOFRANGE;
					}
                    break;
                 case TYFOCOR_LS:
                    if (t < 0.0 || t > 100.0)
					{
                        check = check | TEMPERATUREOUTOFRANGE;
					}
                    break;
            }  /* end switch id */
	        break;
	    default:
	        break;
	} /* end switch property */
	
	return check; 
} /* end rangecheck */


double reynolds(double id, double xi, double t, double p, double w, double d)
{
    double re;
    re = w*d/viscosity(id, xi, t, p);
    return re;
}





double relativeHumidity2waterContent(double t, double p, double rh)
{
    /*        RG      f · ps
     *  x  = ----  --------------            
     *        RD     p - f · ps
     *
     *  or
     *           x · p
     *  f =  -----------------
     *        ps ( RG/RD + x)
     *
     *  RG = 287.1 Nm/kgK (Gas Constant Air)
     *  RD = 461.5 Nm/kgK (Gas Constant Water Vapour)
     *  x absolute Humudity
     *  f relative Humidity
     * pD partial pressure of water vapour
     */
    
    double x, f;
    
    f = rh*0.01; /* from percent to absolute number */
    x = vapourpressure(WATER, 0.0, t, p); /* ps */
    x = RGRD*x*f/(p-x*f); 
    return x;
}



/*
 * solid materials
 * ===============
 */

double heat_capacity_solid(double mat_id, double t){   /* in J/(kg*K) */

    switch ((int)(mat_id+0.5)) {
        case 1: /* aluminium */
            return 945;
        case 2: /* bronze */
            return 377;
        case 3: /* cast iron */
            return 540;
        case 4: /* steel */
            return 470;
        case 5: /* stainless steel */
            return 477;
        case 6: /* coper */
            return 419;
        case 7: /* brass */
            return 376;
        case 8: /* gravel */
            return 1840;
        case 9: /* granite */
            return 890;
        case 10: /* glas */
            return 700;
        case 11: /* PU-foam */
            return 1250;
        case 12: /* glas wool */
            return 600;
        default: /* material not known */
            return 500.0;
    }
}

double density_solid(double mat_id, double t){   /* in kg/m^3 */

    switch ((int)(mat_id+0.5)) {
        case 1: /* aluminium */
            return 2700;
        case 2: /* bronze */
            return 8800;
        case 3: /* cast iron */
            return 7400;
        case 4: /* steel */
            return 7830;
        case 5: /* stainless steel */
            return 8000;
        case 6: /* coper */
            return 8300;
        case 7: /* brass */
            return 8400;
        case 8: /* gravel */
            return 2040;
        case 9: /* granite */
            return 2750;
        case 10: /* glas */
            return 2480;
        case 11: /* PU-foam */
            return 15;
        case 12: /* glas wool */
            return 200;
        default: /* material not known */
            return 500.0;
    }
}

double
thermal_conductivity_solid(double mat_id, double t){   /* in W/(m*K) */

    switch ((int)(mat_id+0.5)) {
        case 1: /* aluminium */
            return 238;
        case 2: /* bronze */
            return 61.7;
        case 3: /* cast iron */
            return 58;
        case 4: /* steel */
            return 52;
        case 5: /* stainless steel */
            return 15;
        case 6: /* coper */
            return 372;
        case 7: /* brass */
            return 113;
        case 8: /* gravel */
            return 1.6;
        case 9: /* granite */
            return 2.9;
        case 10: /* glas */
            return 1.16;
        case 11: /* PU-foam */
            return 0.025;
        case 12: /* glas wool */
            return 0.037;
        default: /* material not known */
            return 5.0;
    }
}



/* the temperaure is determined from pressure and enthalpy */
/*                                                         */
/* pegasus iteration is used                               */
// double enthalpy2temperature(double id, double xi, double h, double p)
double * enthalpy2temperature(double id, double xi, double h, double p)
{
    double t1,t2,t3,t1prec,t2prec,h3,h1,h2;
    int iterations = 0;
    double *result;
    result = malloc(402*sizeof(double));
    
    t1 = -273.15;                           /* intial guess for lower temperature limit */
    do
    {
        t2 = t1+50.0;
        h2 = enthalpy(id,xi,t2,p) - h;      /* look for upper limit */
        if (h2 < 0)                         /* if enthalpy is still smaller -> increase t */
		{
            t1 = t2;
		}
    }
    while (h2 < 0);                         /* repeat until a value above h is found */
    
    h1 = enthalpy(id,xi,t1,p)-h;            /* lower limit values */
    do
    {
        iterations++;                       /* one more iteration step */

        result[iterations+1] = t1;
        result[iterations+1+200] = t2;
        
        t3 = t2 - h2*(t2-t1)/(h2-h1);       /* t3 : Sekante = 0 */
        h3 = enthalpy(id,xi,t3,p)-h;        /* new function value at t3 */
        
        t1prec = t1;
        t2prec = t2;

        if (h3*h2 < 0.0)                    /* zero crossing between h3 an h2 (t3 and t2) */
        {
            t1 = t3;                        /* rise lower limit */
            h1 = h3;                        /* keep result of lower limit */
        }
        else                                /* otherwise zero crossing must be between t1 and t3 */
        {
            t2 = t3;                        /* new upper limit */
            h2 = h3;                        /* keep result of upper limit */
        }
    }
    while (t1<t2-0.1 && ((fabs(t1prec-t1)>1.e-15 || fabs(t2prec-t2)>1.e-15)) && iterations<200);   /* iterate to 0.1 K precision or maximum 200 steps or no change*/
    
    /* terminate with dichotomy if problem to converge */
    if (fabs(t1prec-t1)<=1.e-15 && fabs(t2prec-t2)<=1.e-15 && fabs(h3)>100)
	{
        do
		{
            iterations++;                       /* one more iteration step */
            
            t3 = (t1+t2)/2;				        /* t3 : Dichotomy */
            h3 = enthalpy(id, xi, t3, p)-h;     /* new function value at t3 */
            
            if (h3*h2 < 0.0)                    /* zero crossing between h3 an h2 (t3 and t2) */
			{
                t1 = t3;                        /* rise lower limit */
                h1 = h3;                        /* keep result of lower limit */
            }
            else                                /* otherwise zero crossing must be between t1 and t3 */
			{
                t2 = t3;                        /* new upper limit */
                h2 = h3;                        /* keep result of upper limit */
            }
        }
        while (t1<t2-0.1 && fabs(h3)>100.0 && iterations<200);   /* iterate to 0.1 K precision or maximum 200 steps */
    }
    
    result[0] = t3;
    result[1] = iterations;
    
    return result;
}

double vapourpressure(double id, double xi, double t, double p)
{
    double vp;

 	switch((int)(id+0.5))
	{
		case WATER:
            if (t <= 0.01)
			{	/* IAPWS data, September 2011, max deviation 5 %, for > 200 K max deviation 0.37 % */
				double theta, lntheta;
				theta = (t+273.15)/273.16;
				lntheta=log(theta);
				vp = -0.212144006e2*exp(0.333333333e-2*lntheta) + 0.273203819e2*exp(0.120666667e1*lntheta) -0.610598130e1*exp(0.170333333e1*lntheta);
				vp = 611.657 * exp(vp/theta);
			}
			else if (t < TEMPKRIT)
			{	/* fitted from Baehr: Thermodynamik, Springer, 10th ed., pages 602-604), max error 0.5 %, max deviation to IAPWS data < 0.5 % */
				double negdivt;
				negdivt=-1.0/(t+273.15);
                vp = exp(((((43846605086720.0*negdivt + 626460434744.924)*negdivt + 3527025099.56357)*negdivt + 9523587.46742864)*negdivt + 16948.897414932)*negdivt + 30.183847582);
			}
            else if (t == TEMPKRIT)
                vp = PRESSKRIT;    
            else
                vp = -1.0;
            break;
		case AIR: /* partial pressure of water-vapour in moist air */
            vp = p*xi/(0.622+xi);
            break;
		case AIR_CONSTANT: /* partial pressure of water-vapour in dry air at */
            vp = 0.0;
            break;
		case WATER_CONSTANT: /* partial pressure of water-vapour in moist air in Pa */
            vp = 2339.21476677690; /* value from IAPWS97 */
            break;
        case COTOIL:
            vp = -1.0;
            break;
        case SILOIL: 
            if (t < 0.0)
                vp = 0.0;
            else
                vp = 0.4953e-3*pow(t,3.631);
            break;
        case WATERGLYCOL:  /* for 20°C < T < 200°C */
            vp = (exp (-0.81264*log(t)*log(t)*xi*xi + 0.65201*log(t)*log(t)*xi
                 + 0.81015*log(t)*log(t)  + 6.5902*log(t)*xi*xi
                 - 6.2249*log(t)*xi - 3.8104*log(t)                                    
                 - 15.826*xi*xi + 11.552*xi + 0.42034))*1e5;
            break;
        case TYFOCOR_LS: /* for 40°C < T < 200°C  max f = 2,2 % */
            if (40 <= t && t <= 200)  /* max f = 3,7 % */
			{
              vp = exp(4.538434 * pow(t,0.25) - 2.893717);
			}
            else
			{
              vp = -1.0;
			}
            break;
        default:
            vp = -1.0;
            break;
	} /* switch(id) */
    return vp;
}


double waterContent2relativeHumidity(double t, double p, double x)
{
    /*        RG      f · ps
     *  x  = ----  --------------            
     *        RD     p - f · ps
     *
     *  or
     *           x · p
     *  f =  -----------------
     *        ps ( RG/RD + x)
     *
     *  RG = 287.1 Nm/kgK (Gas Constant Air)
     *  RD = 461.5 Nm/kgK (Gas Constant Water Vapour)
     *  x absolute Humudity
     *  f relative Humidity
     * pD partial pressure of water vapour
     */
    
    double rh;
    
    rh = vapourpressure(WATER, 0.0, t, p);  /* ps */
    rh = x*p/(rh*(RGRD+x)); 
    return (rh*100.0);                      /* from absolute number to percent */
}





 
/*
 * converts a temperature form a unit to another
 * 
 * Syntax : temp_conv = conv_temperatur(init_unit, final_unit, value)
 *   where :
 *          init_unit  is the initial unit
 *          final_unit is the final unit
 *          value      is the temperature to convert
 * 
 * init_unit and final_unit should be one of the following integers :
 *  - 1 : Celsius
 *  - 2 : Kelvin
 *  - 3 : Farenheit
 * 
 * Warning : a difference of temperature doesn't need to be convert from
 * Kelvin to Celsius.
 *
 * 21.01.2011, G. Faure
 *
 */
double unitconv_temp(int init_unit, int final_unit, double temp) {
    
    double temp_K, new_temp;
    
    switch(init_unit)
	{
        case 1 : /* initial value is in °C */
            /* convert to K */
            temp_K = temp + 273.15;
            break;
        case 2 : /* initial value is in K */
            temp_K = temp;
            break;
        case 3 : /* initial value is in °F */
            /* convert to K */
            temp_K = (temp + 459.67) * 5/9;
            break;
        default :
            return -1e6;
    }
    
    /* Here, temp_conv is in Kelvins */
    
    switch(final_unit)
	{
        case 1 : /* final value is in °C */
            new_temp = temp_K - 273.15;
            break;
        case 2 : /* final value is in K */
            new_temp = temp_K;
            break;
        case 3 : /* final value is in °F */
            new_temp = (temp_K * 9/5) - 459.67;
            break;
        default :
            return -1e6;
    }
    
    return new_temp;
}


int printmessage(const char *message, const char *origin, double time, int levelofmessage, int levelofblock, unsigned int *totalmessages, double maxtotalmessages, unsigned int *consecutivemessages, double maxconsecutivemessages, int writetofile, const char *filename)
/* prints a message */
{
    int returnvalue;
    const char messagetype[][10]={"debug", "info", "warning", "error", "fatal"};
    FILE *fileptr;
	
	returnvalue = MESSAGESUPPRESSED;
    
    if ((double)consecutivemessages[0]<maxconsecutivemessages && (double)totalmessages[0]<maxtotalmessages && levelofmessage>=levelofblock)
    {
        returnvalue=MESSAGEPRINTPROMPT;
        ssPrintf("t=%f %s %s: %s\n",time,origin,messagetype[levelofmessage],message);
        consecutivemessages[0] = consecutivemessages[0] + (unsigned int)1;
        totalmessages[0] = totalmessages[0] + (unsigned int)1;
    }
	else
	{
		/* do nothing */
	}
    
    if (writetofile && levelofmessage>=levelofblock)
    {
        if (returnvalue==MESSAGEPRINTPROMPT)
        {
            returnvalue=MESSAGEPRINTPROMPTANDFILE;
        }
        else
        {
            returnvalue=MESSAGEPRINTFILE;
        }
        fileptr=fopen(filename,"a");
        fprintf(fileptr,"%f\t%s\t%s\t%s\n",time,messagetype[levelofmessage-1],origin,message);
        fclose(fileptr);
    }
	
    return(returnvalue);
}

  