#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "water_properties.h"

/*water and steam properties according to
Wolfgang Wagner and Hans-Joachim Kretzschmar
International Steam Tables
2nd edition
Springer: 2008*/

/*description of functions:
water_properties_region water_properties_get_region(double temperature, double pressure)
The property field is divided into five regions. This function returns the region (enum) from the temeprature
in K and the pressure in Pa.

double water_properties_specific_volume(water_properties_region region, double temperature, double pressure)
The function returns the specific volume in m^3/kg from the temperature in K and the pressure in Pa.
The region is returned by water_properties_get_region.

double water_properties_specific_isobaric_heat_capacity(water_properties_region region, double temperature, double pressure)
The function returns the specific isobaric heat capacity in J/kgK from the temperature in K and the pressure in Pa.
The region is returned by water_properties_get_region.

double water_properties_specific_isochoric_heat_capacity(water_properties_region region, double temperature, double pressure)
The function returns the specific isochoric heat capacity in J/kgK from the temperature in K and the pressure in Pa.
The region is returned by water_properties_get_region.

double water_properties_specific_internal_energy(water_properties_region region, double temperature, double pressure)
The function returns the specific internal energy in J/kg from the temperature in K and the pressure in Pa.
The region is returned by water_properties_get_region.

double water_properties_specific_enthalpy(water_properties_region region, double temperature, double pressure)
The function returns the specific internal enthalpy in J/kg from the temperature in K and the pressure in Pa.
The region is returned by water_properties_get_region.

double water_properties_specific_entropy(water_properties_region region, double temperature, double pressure)
The function returns the specific entropy in J/kgK from the temperature in K and the pressure in Pa.
The region is returned by water_properties_get_region.

double water_properties_speed_of_sound(water_properties_region region, double temperature, double pressure)
The function returns the speeed of sound in m/s from the temperature in K and the pressure in Pa.
The region is returned by water_properties_get_region.

double water_properties_isobaric_cubic_expansion_coefficient(water_properties_region region, double temperature, double pressure);
The function returns the isobaric cubic expansion coefficient in 1/K from the temperature in K and the pressure in Pa.
The region is returned by water_properties_get_region.

double water_properties_isothermal_compressibility(water_properties_region region, double temperature, double pressure)
The function returns the isothermal compressibility in 1/Pa from the temperature in K and the pressure in Pa.
The region is returned by water_properties_get_region.

double water_properties_Ts(double pressure);
The function returns the saturation temperature in K from the pressure in Pa.

double water_properties_ps(double temperature);
The function returns the saturation pressure in Pa from the temperature in K.

double water_properties_surface_tension(double temperature);
The functions returns the durface tension in N/m from the temeprature in K

double water_properties_dynamic_viscosity(double temperature, double pressure);
The functions returns the dynamic viscosity in Pa s from the temperature in K and the pressure in Pa.

double water_properties_thermal_conductivity(double temperature, double pressure);
The functions returns the thermal conductivity in W/Km from the temperature in K and the pressure in Pa.

double water_properties_dielectric_constant(double temperature, double pressure);
The functions returns the dielectric constant from the temperature in K and the pressure in Pa.

double water_properties_refractive_index(double temperature, double pressure, double wavelength);
The functions returns the refractive index from the temperature in K, the pressure in Pa and
the wavelength in m.

*/

/*--------------------------------------------------------------------------*/


/*mathematical auxiliary functions*/

double power1(double x, int y)
{
	if (y==0)
	{
		return(1.0);
	}
	else if (y==1)
	{
		return(x);
	}
	else if (x>0.0)
	{
		return(exp((double)y*ln(x)));
	}
	else /*(x<=0)*/
	{
		if (y>0)
		{
			if (y%2==0)
			{
				return(exp((double)y*ln(-x)));
			}
			else
			{
				return(-exp((double)y*ln(-x)));
			}
		}
		else
		{
			return(1.0/power1(x,-y));
		}
	}

}


double power2(double x, double y)
{
	if (fabs(y-1.0)<1.0e-20)
	{
		return(x);
	}
	else if(fabs(y)<1.0e-20)
	{
		return(1.0);
	}
	else
	{
		return(exp(y*ln(x)));
	}
}


double ln(double x)
{
	return(log(x)/log(exp(1.0)));
}




/*general functions*/

water_properties_region water_properties_get_region(double temperature, double pressure)
{
	water_properties_region result;
	double T, p, p4, p23;
	
	T=temperature;
	p=pressure;
	if (623.15<=T && T<=863.15)
	{ /*is T in the range to calculate p23?*/
		p23=water_properties_pB23(T);
	}
	else
	{
		p23=0.0; /*does not matter: temperature range is also evaluated later*/
	}
	if (273.15<=T && T<=647.096)
	{
		p4=water_properties_ps(T);
	}
	else
	{ /*is T in the rage to calculate p4?*/
		p4=0.0; /*does not matter: temperature range is also evaluated later*/
	}
	
	if( (T<273.15) || (p>100.0e6) || (T>2273.15) || (T>1073.15 && p>50.0e6) || (p<0.0) )
	{
		result=none;
	}
	else if (fabs(p-p4)<1.0) /*vapour pressure*/
	{
		result=region4;
	}
	else if ( (273.15 <=T && T<=623.15) && (p4<=p && p<=100.0e6) )
	{
		result=region1;
	}
	else if ( (273.15<=T && T<=623.15) && p<=p4 )
	{
		result=region2;
	}
	else if ( (623.15<=T && T<=863.15) && p<=p23 )
	{
		result=region2;
	}
	else if ( (863.15<=T && T<=1073.15) && p<=100.0e6 )
	{
		result=region2;
	}
	else if ( (623.15<=T && T<=863.15) && (p23<=p && p<=100.0e6) )
	{
		result=region3;
	}
	else if ( (1073.15<=T && T<=2273.15) && p<=50.0e6 )
	{
		result=region5;
	}
	else
	{ /*shoud not happen!*/
		result=none;
	}
	return(result);
}


double water_properties_specific_volume(water_properties_region region, double temperature, double pressure)
{
	double reduced_pressure, aux_p, reduced_temperature, aux_t;
	double n, gamma_pi, gamma_pi0, gamma_pir, result;
	int I, J;
	int counter;
	
	gamma_pi=0.0;
	gamma_pi0=0.0;
	gamma_pir=0.0;
	reduced_pressure=0.0;
	reduced_temperature=0.0;
	result=0.0;
	
	switch(region)
	{
		case region1 :
		{
			reduced_pressure=pressure/16.53e6;
			reduced_temperature=1386.0/temperature;
			aux_p=7.1-reduced_pressure;
			aux_t=reduced_temperature-1.222;
			for (counter=1;counter<=34;counter++)
			{
				water_properties_constants_region1(counter, &I, &J, &n);
				gamma_pi=gamma_pi-n*((double)I)*power1(aux_p,I-1)*power1(aux_t,J);
			}
			result=reduced_pressure*gamma_pi*water_properties_R_water*temperature/pressure;
			break;
		}
		case region2 :
		{
			reduced_pressure=pressure/1.0e6;
			reduced_temperature=540.0/temperature;
			aux_p=ln(reduced_pressure);
			aux_t=ln(reduced_temperature-0.5);
			for (counter=1;counter<=43;counter++)
			{
				water_properties_constants_region2_r(counter, &I, &J, &n);
				gamma_pir=gamma_pir+n*(double)I*exp((double)(I-1)*aux_p)*exp((double)J*aux_t);
			}
			gamma_pi0=1.0/reduced_pressure;
			gamma_pi=gamma_pi0+gamma_pir;
			result=reduced_pressure*gamma_pi*water_properties_R_water*temperature/pressure;
			break;
		}
		case region2meta :
		{
			reduced_pressure=pressure/1.0e6;
			reduced_temperature=540.0/temperature;
			aux_p=ln(reduced_pressure);
			aux_t=ln(reduced_temperature-0.5);
			for (counter=1;counter<=13;counter++)
			{
				water_properties_constants_region2_meta_r(counter, &I, &J, &n);
				gamma_pir=gamma_pir+n*(double)I*exp((double)(I-1)*aux_p)*exp((double)J*aux_t);
			}
			gamma_pi0=1.0/reduced_pressure;
			gamma_pi=gamma_pi0+gamma_pir;
			result=reduced_pressure*gamma_pi*water_properties_R_water*temperature/pressure;
			break;
		}
		case region3 :
		{			
			result=water_properties_specific_volume_region3(water_properties_specific_volume_region3_get_region(temperature, pressure),
															temperature, pressure);
			break;
		}	
		case region4 :
		{
			/*undefined!*/
			gamma_pi=0.0;
			result=0.0;
			break;
		}
		case region5 :
		{
			reduced_pressure=pressure/1.0e6;
			reduced_temperature=1000.0/temperature;
			aux_p=ln(reduced_pressure);
			aux_t=ln(reduced_temperature);
			for (counter=1;counter<=6;counter++)
			{
				water_properties_constants_region5_r(counter, &I, &J, &n);
				gamma_pir=gamma_pir+n*(double)I*exp((double)(I-1)*aux_p)*exp((double)J*aux_t);
			}
			gamma_pi0=1.0/reduced_pressure;
			gamma_pi=gamma_pi0+gamma_pir;
			result=reduced_pressure*gamma_pi*water_properties_R_water*temperature/pressure;
			break;
		}
		case none:
		{
			gamma_pi=0.0;
			break;
		}
	}
	return(result);
}


double water_properties_specific_isobaric_heat_capacity(water_properties_region region, double temperature, double pressure)
{
	double reduced_pressure, reduced_temperature, reduced_density;
	double aux_p, aux_t, aux_t2;
	double n, gamma_tt, gamma_tt0, gamma_ttr, result;
	double phi_d, phi_dd, phi_dt, phi_tt;
	int I, J;
	int counter;
	
	result=0.0;
	gamma_tt=0.0;
	gamma_tt0=0.0;
	gamma_ttr=0.0;
	phi_d=0.0;
	phi_dd=0.0;
	phi_dt=0.0;
	phi_tt=0.0;
	
	switch(region)
	{
		case region1 :
		{
			reduced_pressure=pressure/16.53e6;
			reduced_temperature=1386.0/temperature;
			aux_p=7.1-reduced_pressure;
			aux_t=reduced_temperature-1.222;
			for (counter=1;counter<=34;counter++)
			{
				water_properties_constants_region1(counter, &I, &J, &n);
				gamma_tt=gamma_tt+n*power1(aux_p,I)*(double)(J*(J-1))*power1(aux_t,J-2);
			}
			result=-water_properties_R_water*reduced_temperature*reduced_temperature*gamma_tt;
			break;
		}
		
		case region2 :
		{
			reduced_pressure=pressure/1.0e6;
			reduced_temperature=540.0/temperature;
			aux_t2=ln(reduced_temperature);
			aux_t=ln(reduced_temperature-0.5);
			for (counter=1;counter<=9;counter++)
			{
				water_properties_constants_region2_0(counter, &J, &n);
				gamma_tt0=gamma_tt0+n*(double)J*(double)(J-1)*exp((double)(J-2)*aux_t2);
			}
			for (counter=1;counter<=43;counter++)
			{
				water_properties_constants_region2_r(counter, &I, &J, &n);
				gamma_ttr=gamma_ttr+n*power1(reduced_pressure,I)*(double)J*(double)(J-1)*exp((double)(J-2)*aux_t);
			}
			result=-water_properties_R_water*reduced_temperature*reduced_temperature*(gamma_tt0+gamma_ttr);
			break;
		}
		
		case region2meta :
		{
			reduced_pressure=pressure/1.0e6;
			reduced_temperature=540.0/temperature;
			aux_t=reduced_temperature-0.5;
			for (counter=1;counter<=9;counter++)
			{
				water_properties_constants_region2_meta_0(counter, &J, &n);
				gamma_tt0=gamma_tt0+n*(double)(J*(J-1))*power1(reduced_temperature,J-2);
			}
			for (counter=1;counter<=13;counter++)
			{
				water_properties_constants_region2_meta_r(counter, &I, &J, &n);
				gamma_ttr=gamma_ttr+n*power1(reduced_pressure,I)*(double)(J*(J-1))*power1(aux_t,J-2);
			}
			result=-water_properties_R_water*reduced_temperature*reduced_temperature*(gamma_tt0+gamma_ttr);
			break;
		}
		
		case region3:
		{
			reduced_temperature=647.096/temperature;
			reduced_density=1.0/(322.0*water_properties_specific_volume(region3,temperature,pressure));
			water_properties_constants_region3(1, &I, &J, &n);
			phi_d=n/reduced_density;
			phi_dd=-phi_d/reduced_density;
			for (counter=2;counter<=40;counter++)
			{
				water_properties_constants_region3(counter, &I, &J, &n);
				phi_d=phi_d+n*(double)I*power1(reduced_density,I-1)*power1(reduced_temperature,J);
				phi_dd=phi_dd+n*(double)(I*(I-1))*power1(reduced_density,I-2)*power1(reduced_temperature,J);
				phi_dt=phi_dt+n*(double)(I*J)*power1(reduced_density,I-1)*power1(reduced_temperature,J-1);
				phi_tt=phi_tt+n*power1(reduced_density,I)*(double)(J*(J-1))*power1(reduced_temperature,J-2);
			}
			result=-reduced_temperature*reduced_temperature*phi_tt;
			result=result+reduced_density*(phi_d-reduced_temperature*phi_dt)*(phi_d-reduced_temperature*phi_dt)/(2.0*phi_d+reduced_density*phi_dd);
			result=water_properties_R_water*result;
			break;
		}
		
		case region4 :
		{
			/*undefined*/
			result=0.0;
			break;
		}
		
		case region5 :
		{
			reduced_temperature=1000.0/temperature;
			reduced_pressure=pressure/1.0e6;
			for(counter=1;counter<=6;counter++)
			{
				water_properties_constants_region5_0(counter, &J, &n);
				gamma_tt0=gamma_tt0+n*(double)(J*(J-1))*power1(reduced_temperature,J-2);
			}
			for(counter=1;counter<=6;counter++)
			{
				water_properties_constants_region5_r(counter, &I, &J, &n);
				gamma_ttr=gamma_ttr+n*power1(reduced_pressure,I)*(double)(J*(J-1))*power1(reduced_temperature,J-2);
			}
			result=-water_properties_R_water*reduced_temperature*reduced_temperature*(gamma_tt0+gamma_ttr);
			break;
		}
	}

	return(result);
}


double water_properties_specific_isochoric_heat_capacity(water_properties_region region, double temperature, double pressure)
{
	double reduced_pressure, reduced_temperature, reduced_density;
	double aux_p, aux_t;
	double n, gamma_tt, gamma_tt0, gamma_ttr, result;
	double gamma_pp, gamma_pp0, gamma_ppr;
	double gamma_pt, gamma_pt0, gamma_ptr;
	double gamma_p, gamma_p0, gamma_pr;
	double phi_tt;
	int I, J;
	int counter;
	
	result=0.0;
	gamma_tt=0.0;
	gamma_tt0=0.0;
	gamma_ttr=0.0;
	gamma_pp=0.0;
	gamma_pp0=0.0;
	gamma_ppr=0.0;
	gamma_pt=0.0;
	gamma_pt0=0.0;
	gamma_ptr=0.0;
	gamma_p=0.0;
	gamma_p0=0.0;
	gamma_pr=0.0;
	phi_tt=0.0;
	
	switch(region)
	{
		case region1 :
		{
			reduced_pressure=pressure/16.53e6;
			reduced_temperature=1386.0/temperature;
			aux_p=7.1-reduced_pressure;
			aux_t=reduced_temperature-1.222;
			for (counter=1;counter<=34;counter++)
			{
				water_properties_constants_region1(counter, &I, &J, &n);
				gamma_tt=gamma_tt+n*power1(aux_p,I)*(double)(J*(J-1))*power1(aux_t,J-2);
				gamma_pp=gamma_pp+n*(double)(I*(I-1))*power1(aux_p,I-2)*power1(aux_t,J);
				gamma_pt=gamma_pt-n*(double)(I*J)*power1(aux_p,I-1)*power1(aux_t,J-1);
				gamma_p=gamma_p-n*(double)I*power1(aux_p,I-1)*power1(aux_t,J);
			}
			result=-reduced_temperature*reduced_temperature*gamma_tt;
			result=result+(gamma_p-reduced_temperature*gamma_pt)*(gamma_p-reduced_temperature*gamma_pt)/gamma_pp;
			result=water_properties_R_water*result;
			break;
		}
		
		case region2 :
		{
			reduced_pressure=pressure/1.0e6;
			reduced_temperature=540.0/temperature;
			aux_t=reduced_temperature-0.5;
			for (counter=1;counter<=9;counter++)
			{
				water_properties_constants_region2_0(counter, &J, &n);
				gamma_tt0=gamma_tt0+n*(double)(J*(J-1))*power1(reduced_temperature,J-2);
			}
			for (counter=1;counter<=43;counter++)
			{
				water_properties_constants_region2_r(counter, &I, &J, &n);
				gamma_ttr=gamma_ttr+n*power1(reduced_pressure,I)*(double)(J*(J-1))*power1(aux_t,J-2);
				gamma_ppr=gamma_ppr+n*(double)(I*(I-1))*power1(reduced_pressure,I-2)*power1(aux_t,J);
				gamma_ptr=gamma_ptr+n*(double)(I*J)*power1(reduced_pressure,I-1)*power1(aux_t,J-1);
				gamma_pr=gamma_pr+n*(double)I*power1(reduced_pressure,I-1)*power1(aux_t,J);
			}
			result=reduced_temperature*reduced_temperature*(gamma_tt0+gamma_ttr);
			result=result+(1.0+reduced_pressure*gamma_pr-reduced_temperature*reduced_pressure*gamma_ptr)*(1.0+reduced_pressure*gamma_pr-reduced_temperature*reduced_pressure*gamma_ptr)/(1.0-reduced_pressure*reduced_pressure*gamma_ppr);
			result=-water_properties_R_water*result;
			break;
		}
		
		case region2meta :
		{
			reduced_pressure=pressure/1.0e6;
			reduced_temperature=540.0/temperature;
			aux_t=reduced_temperature-0.5;
			for (counter=1;counter<=9;counter++)
			{
				water_properties_constants_region2_meta_0(counter, &J, &n);
				gamma_tt0=gamma_tt0+n*(double)(J*(J-1))*power1(reduced_temperature,J-2);
			}
			for (counter=1;counter<=13;counter++)
			{
				water_properties_constants_region2_meta_r(counter, &I, &J, &n);
				gamma_ttr=gamma_ttr+n*power1(reduced_pressure,I)*(double)(J*(J-1))*power1(aux_t,J-2);
				gamma_ppr=gamma_ppr+n*(double)(I*(I-1))*power1(reduced_pressure,I-2)*power1(aux_t,J);
				gamma_ptr=gamma_ptr+n*(double)(I*J)*power1(reduced_pressure,I-1)*power1(aux_t,J-1);
				gamma_pr=gamma_pr+n*(double)I*power1(reduced_pressure,I-1)*power1(aux_t,J);
			}
			result=reduced_temperature*reduced_temperature*(gamma_tt0+gamma_ttr);
			result=result+(1.0+reduced_pressure*gamma_pr-reduced_temperature*reduced_pressure*gamma_ptr)*(1.0+reduced_pressure*gamma_pr-reduced_temperature*reduced_pressure*gamma_ptr)/(1.0-reduced_pressure*reduced_pressure*gamma_ppr);
			result=-water_properties_R_water*result;
			break;
		}
		
		case region3:
		{
			reduced_temperature=647.096/temperature;
			reduced_density=1.0/(322.0*water_properties_specific_volume(region3,temperature,pressure));
			for (counter=2;counter<=40;counter++)
			{
				water_properties_constants_region3(counter, &I, &J, &n);
				phi_tt=phi_tt+n*power1(reduced_density,I)*(double)(J*(J-1))*power1(reduced_temperature,J-2);
			}
			result=-water_properties_R_water*reduced_temperature*reduced_temperature*phi_tt;
			break;
		}
		
		case region4 :
		{
			/*undefined*/
			result=0.0;
			break;
		}
		
		case region5 :
		{
			reduced_temperature=1000.0/temperature;
			reduced_pressure=pressure/1.0e6;
			for(counter=1;counter<=6;counter++)
			{
				water_properties_constants_region5_0(counter, &J, &n);
				gamma_tt0=gamma_tt0+n*(double)(J*(J-1))*power1(reduced_temperature,J-2);
			}
			for(counter=1;counter<=6;counter++)
			{
				water_properties_constants_region5_r(counter, &I, &J, &n);
				gamma_ttr=gamma_ttr+n*power1(reduced_pressure,I)*(double)(J*(J-1))*power1(reduced_temperature,J-2);
				gamma_pr=gamma_pr+n*(double)I*power1(reduced_pressure,I-1)*power1(reduced_temperature,J);
				gamma_ppr=gamma_ppr+n*(double)(I*(I-1))*power1(reduced_pressure,I-2)*power1(reduced_temperature,J);
				gamma_ptr=gamma_ptr+n*(double)(I*J)*power1(reduced_pressure,I-1)*power1(reduced_temperature,J-1);
			}
			result=reduced_temperature*reduced_temperature*(gamma_tt0+gamma_ttr);
			result=result+(1.0+reduced_pressure*gamma_pr-reduced_temperature*reduced_pressure*gamma_ptr)*(1.0+reduced_pressure*gamma_pr-reduced_temperature*reduced_pressure*gamma_ptr)/(1.0-reduced_pressure*reduced_pressure*gamma_ppr);
			result=-water_properties_R_water*result;
			break;
		}
	}
	return(result);
}


double water_properties_specific_internal_energy(water_properties_region region, double temperature, double pressure)
{
	double reduced_pressure, reduced_temperature, reduced_density;
	double aux_p, aux_t;
	double n, gamma_t, gamma_t0, gamma_tr, result;
	double gamma_p, gamma_p0, gamma_pr;
	double phi_t;
	int I, J;
	int counter;
	
	result=0.0;
	gamma_t=0.0;
	gamma_t0=0.0;
	gamma_tr=0.0;
	gamma_p=0.0;
	gamma_p0=0.0;
	gamma_pr=0.0;
	phi_t=0.0;
	
	switch(region)
	{
		case region1 :
		{
			reduced_pressure=pressure/16.53e6;
			reduced_temperature=1386.0/temperature;
			aux_p=7.1-reduced_pressure;
			aux_t=reduced_temperature-1.222;
			for (counter=1;counter<=34;counter++)
			{
				water_properties_constants_region1(counter, &I, &J, &n);
				gamma_t=gamma_t+n*power1(aux_p,I)*(double)J*power1(aux_t,J-1);
				gamma_p=gamma_p-n*(double)I*power1(aux_p,I-1)*power1(aux_t,J);
			}
			result=temperature*water_properties_R_water*(reduced_temperature*gamma_t-reduced_pressure*gamma_p);
			break;
		}
		
		case region2 :
		{
			reduced_pressure=pressure/1.0e6;
			reduced_temperature=540.0/temperature;
			aux_t=reduced_temperature-0.5;
			gamma_p0=1.0/reduced_pressure;
			for (counter=1;counter<=9;counter++)
			{
				water_properties_constants_region2_0(counter, &J, &n);
				gamma_t0=gamma_t0+n*(double)J*power1(reduced_temperature,J-1);
			}
			for (counter=1;counter<=43;counter++)
			{
				water_properties_constants_region2_r(counter, &I, &J, &n);
				gamma_tr=gamma_tr+n*power1(reduced_pressure,I)*(double)J*power1(aux_t,J-1);
				gamma_pr=gamma_pr+n*(double)I*power1(reduced_pressure,I-1)*power1(aux_t,J);
			}
			result=(gamma_t0+gamma_tr)*reduced_temperature-(gamma_p0+gamma_pr)*reduced_pressure;
			result=result*water_properties_R_water*temperature;
			break;
		}
		
		case region2meta :
		{
			reduced_pressure=pressure/1.0e6;
			reduced_temperature=540.0/temperature;
			aux_t=reduced_temperature-0.5;
			gamma_p0=1.0/reduced_pressure;
			for (counter=1;counter<=9;counter++)
			{
				water_properties_constants_region2_meta_0(counter, &J, &n);
				gamma_t0=gamma_t0+n*(double)J*power1(reduced_temperature,J-1);
			}
			for (counter=1;counter<=13;counter++)
			{
				water_properties_constants_region2_meta_r(counter, &I, &J, &n);
				gamma_tr=gamma_tr+n*power1(reduced_pressure,I)*(double)J*power1(aux_t,J-1);
				gamma_pr=gamma_pr+n*(double)I*power1(reduced_pressure,I-1)*power1(aux_t,J);
			}
			result=(gamma_t0+gamma_tr)*reduced_temperature-(gamma_p0+gamma_pr)*reduced_pressure;
			result=result*water_properties_R_water*temperature;
			break;
		}
		
		case region3:
		{
			reduced_temperature=647.096/temperature;
			reduced_density=1.0/(322.0*water_properties_specific_volume(region3,temperature,pressure));
			for (counter=2;counter<=40;counter++)
			{
				water_properties_constants_region3(counter, &I, &J, &n);
				phi_t=phi_t+n*power1(reduced_density,I)*(double)J*power1(reduced_temperature,J-1);
			}
			result=water_properties_R_water*temperature*reduced_temperature*phi_t;
			break;
		}
		
		case region4 :
		{
			/*undefined*/
			result=0.0;
			break;
		}
		
		case region5 :
		{
			reduced_temperature=1000.0/temperature;
			reduced_pressure=pressure/1.0e6;
			
			gamma_p0=1.0/reduced_pressure;
			for(counter=1;counter<=6;counter++)
			{
				water_properties_constants_region5_0(counter, &J, &n);
				gamma_t0=gamma_t0+n*(double)J*power1(reduced_temperature,J-1);
			}
			for(counter=1;counter<=6;counter++)
			{
				water_properties_constants_region5_r(counter, &I, &J, &n);
				gamma_tr=gamma_tr+n*power1(reduced_pressure,I)*(double)J*power1(reduced_temperature,J-1);
				gamma_pr=gamma_pr+n*(double)I*power1(reduced_pressure,I-1)*power1(reduced_temperature,J);
			}
			result=reduced_temperature*(gamma_t0+gamma_tr)-reduced_pressure*(gamma_p0+gamma_pr);
			result=result*water_properties_R_water*temperature;
			break;
		}
	}
	return(result);
}


double water_properties_specific_enthalpy(water_properties_region region, double temperature, double pressure)
{
	double reduced_pressure, reduced_temperature, reduced_density;
	double aux_p, aux_t;
	double n, gamma_t, gamma_t0, gamma_tr, result;
	double phi_d, phi_t;
	int I, J;
	int counter;
	
	result=0.0;
	gamma_t=0.0;
	gamma_t0=0.0;
	gamma_tr=0.0;
	phi_d=0.0;
	phi_t=0.0;
	
	switch(region)
	{
		case region1 :
		{
			reduced_pressure=pressure/16.53e6;
			reduced_temperature=1386.0/temperature;
			aux_p=7.1-reduced_pressure;
			aux_t=reduced_temperature-1.222;
			for (counter=1;counter<=34;counter++)
			{
				water_properties_constants_region1(counter, &I, &J, &n);
				gamma_t=gamma_t+n*power1(aux_p,I)*(double)J*power1(aux_t,J-1);
			}
			result=water_properties_R_water*temperature*reduced_temperature*gamma_t;
			break;
		}
		
		case region2 :
		{
			reduced_pressure=pressure/1.0e6;
			reduced_temperature=540.0/temperature;
			aux_t=reduced_temperature-0.5;
			for (counter=1;counter<=9;counter++)
			{
				water_properties_constants_region2_0(counter, &J, &n);
				gamma_t0=gamma_t0+n*(double)J*power1(reduced_temperature,J-1);
			}
			for (counter=1;counter<=43;counter++)
			{
				water_properties_constants_region2_r(counter, &I, &J, &n);
				gamma_tr=gamma_tr+n*power1(reduced_pressure,I)*(double)J*power1(aux_t,J-1);
			}
			result=water_properties_R_water*temperature*reduced_temperature*(gamma_t0+gamma_tr);
			break;
		}
		
		case region2meta :
		{
			reduced_pressure=pressure/1.0e6;
			reduced_temperature=540.0/temperature;
			aux_t=reduced_temperature-0.5;
			for (counter=1;counter<=9;counter++)
			{
				water_properties_constants_region2_meta_0(counter, &J, &n);
				gamma_t0=gamma_t0+n*(double)J*power1(reduced_temperature,J-1);
			}
			for (counter=1;counter<=13;counter++)
			{
				water_properties_constants_region2_meta_r(counter, &I, &J, &n);
				gamma_tr=gamma_tr+n*power1(reduced_pressure,I)*(double)J*power1(aux_t,J-1);
			}
			result=water_properties_R_water*temperature*reduced_temperature*(gamma_t0+gamma_tr);
			break;
		}
		
		case region3:
		{
			reduced_temperature=647.096/temperature;
			reduced_density=1.0/(322.0*water_properties_specific_volume(region3,temperature,pressure));
			water_properties_constants_region3(1, &I, &J, &n);
			phi_d=n/reduced_density;
			for (counter=2;counter<=40;counter++)
			{
				water_properties_constants_region3(counter, &I, &J, &n);
				phi_d=phi_d+n*(double)I*power1(reduced_density,I-1)*power1(reduced_temperature,J);
				phi_t=phi_t+n*power1(reduced_density,I)*(double)J*power1(reduced_temperature,J-1);
			}
			result=water_properties_R_water*temperature*(reduced_temperature*phi_t+reduced_density*phi_d);
			break;
		}
		
		case region4 :
		{
			/*undefined*/
			result=0.0;
			break;
		}
		
		case region5 :
		{
			reduced_temperature=1000.0/temperature;
			reduced_pressure=pressure/1.0e6;
			for(counter=1;counter<=6;counter++)
			{
				water_properties_constants_region5_0(counter, &J, &n);
				gamma_t0=gamma_t0+n*(double)J*power1(reduced_temperature,J-1);
			}
			for(counter=1;counter<=6;counter++)
			{
				water_properties_constants_region5_r(counter, &I, &J, &n);
				gamma_tr=gamma_tr+n*power1(reduced_pressure,I)*(double)J*power1(reduced_temperature,J-1);
			}
			result=water_properties_R_water*temperature*reduced_temperature*(gamma_t0+gamma_tr);
			break;
		}
	}
	
	return(result);
}


double water_properties_specific_entropy(water_properties_region region, double temperature, double pressure)
{
	double reduced_pressure, reduced_temperature, reduced_density;
	double aux_p, aux_t;
	double n, gamma_t, gamma_t0, gamma_tr, result;
	double gamma, gamma_0, gamma_r;
	double phi, phi_t;
	int I, J;
	int counter;
	
	result=0.0;
	gamma_t=0.0;
	gamma_t0=0.0;
	gamma_tr=0.0;
	gamma=0.0;
	gamma_0=0.0;
	gamma_r=0.0;
	phi=0.0;
	phi_t=0.0;
	
	switch(region)
	{
		case region1 :
		{
			reduced_pressure=pressure/16.53e6;
			reduced_temperature=1386.0/temperature;
			aux_p=7.1-reduced_pressure;
			aux_t=reduced_temperature-1.222;
			for (counter=1;counter<=34;counter++)
			{
				water_properties_constants_region1(counter, &I, &J, &n);
				gamma=gamma+n*power1(aux_p,I)*power1(aux_t,J);
				gamma_t=gamma_t+n*power1(aux_p,I)*(double)J*power1(aux_t,J-1);
			}
			result=water_properties_R_water*(reduced_temperature*gamma_t-gamma);
			break;
		}
		
		case region2 :
		{
			reduced_pressure=pressure/1.0e6;
			reduced_temperature=540.0/temperature;
			aux_t=reduced_temperature-0.5;
			gamma_0=ln(reduced_pressure);
			for (counter=1;counter<=9;counter++)
			{
				water_properties_constants_region2_0(counter, &J, &n);
				gamma_0=gamma_0+n*power1(reduced_temperature,J);
				gamma_t0=gamma_t0+n*(double)J*power1(reduced_temperature,J-1);
			}
			for (counter=1;counter<=43;counter++)
			{
				water_properties_constants_region2_r(counter, &I, &J, &n);
				gamma_r=gamma_r+n*power1(reduced_pressure,I)*power1(aux_t,J);
				gamma_tr=gamma_tr+n*power1(reduced_pressure,I)*(double)J*power1(aux_t,J-1);
			}
			result=water_properties_R_water*(reduced_temperature*(gamma_t0+gamma_tr)-(gamma_0+gamma_r));
			break;
		}
		
		case region2meta :
		{
			reduced_pressure=pressure/1.0e6;
			reduced_temperature=540.0/temperature;
			aux_t=reduced_temperature-0.5;
			gamma_0=ln(reduced_pressure);
			for (counter=1;counter<=9;counter++)
			{
				water_properties_constants_region2_meta_0(counter, &J, &n);
				gamma_0=gamma_0+n*power1(reduced_temperature,J);
				gamma_t0=gamma_t0+n*(double)J*power1(reduced_temperature,J-1);
			}
			for (counter=1;counter<=13;counter++)
			{
				water_properties_constants_region2_meta_r(counter, &I, &J, &n);
				gamma_r=gamma_r+n*power1(reduced_pressure,I)*power1(aux_t,J);
				gamma_tr=gamma_tr+n*power1(reduced_pressure,I)*(double)J*power1(aux_t,J-1);
			}
			result=water_properties_R_water*(reduced_temperature*(gamma_t0+gamma_tr)-(gamma_0+gamma_r));
			break;
		}
		
		case region3:
		{
			reduced_temperature=647.096/temperature;
			reduced_density=1.0/(322.0*water_properties_specific_volume(region3,temperature,pressure));
			water_properties_constants_region3(1, &I, &J, &n);
			phi=n*ln(reduced_density);
			for (counter=2;counter<=40;counter++)
			{
				water_properties_constants_region3(counter, &I, &J, &n);
				phi=phi+n*power1(reduced_density,I)*power1(reduced_temperature,J);
				phi_t=phi_t+n*power1(reduced_density,I)*(double)J*power1(reduced_temperature,J-1);
			}
			result=water_properties_R_water*(reduced_temperature*phi_t-phi);
			break;
		}
		
		case region4 :
		{
			/*undefined*/
			result=0.0;
			break;
		}
		
		case region5 :
		{
			reduced_temperature=1000.0/temperature;
			reduced_pressure=pressure/1.0e6;
			gamma_0=ln(reduced_pressure);
			for(counter=1;counter<=6;counter++)
			{
				water_properties_constants_region5_0(counter, &J, &n);
				gamma_0=gamma_0+n*power1(reduced_temperature,J);
				gamma_t0=gamma_t0+n*(double)J*power1(reduced_temperature,J-1);
			}
			for(counter=1;counter<=6;counter++)
			{
				water_properties_constants_region5_r(counter, &I, &J, &n);
				gamma_r=gamma_r+n*power1(reduced_pressure,I)*power1(reduced_temperature,J);
				gamma_tr=gamma_tr+n*power1(reduced_pressure,I)*(double)J*power1(reduced_temperature,J-1);
			}
			result=water_properties_R_water*(reduced_temperature*(gamma_t0+gamma_tr)-(gamma_0+gamma_r));
			break;
		}
	}
	
	return(result);
}


double water_properties_speed_of_sound(water_properties_region region, double temperature, double pressure)
{
	double reduced_pressure, reduced_temperature, reduced_density;
	double aux_p, aux_t;
	double n, gamma_tt, gamma_tt0, gamma_ttr, result;
	double gamma_pp, gamma_pp0, gamma_ppr;
	double gamma_pt, gamma_pt0, gamma_ptr;
	double gamma_p, gamma_p0, gamma_pr;
	double phi_tt, phi_d, phi_dd, phi_dt;
	int I, J;
	int counter;
	
	result=0.0;
	gamma_tt=0.0;
	gamma_tt0=0.0;
	gamma_ttr=0.0;
	gamma_pp=0.0;
	gamma_pp0=0.0;
	gamma_ppr=0.0;
	gamma_pt=0.0;
	gamma_pt0=0.0;
	gamma_ptr=0.0;
	gamma_p=0.0;
	gamma_p0=0.0;
	gamma_pr=0.0;
	phi_tt=0.0;
	phi_d=0.0;
	phi_dd=0.0;
	phi_dt=0.0;
	
	switch(region)
	{
		case region1 :
		{
			reduced_pressure=pressure/16.53e6;
			reduced_temperature=1386.0/temperature;
			aux_p=7.1-reduced_pressure;
			aux_t=reduced_temperature-1.222;
			for (counter=1;counter<=34;counter++)
			{
				water_properties_constants_region1(counter, &I, &J, &n);
				gamma_tt=gamma_tt+n*power1(aux_p,I)*(double)(J*(J-1))*power1(aux_t,J-2);
				gamma_pp=gamma_pp+n*(double)(I*(I-1))*power1(aux_p,I-2)*power1(aux_t,J);
				gamma_pt=gamma_pt-n*(double)(I*J)*power1(aux_p,I-1)*power1(aux_t,J-1);
				gamma_p=gamma_p-n*(double)I*power1(aux_p,I-1)*power1(aux_t,J);
			}
			result=gamma_p*gamma_p/((gamma_p-reduced_temperature*gamma_pt)*(gamma_p-reduced_temperature*gamma_pt)/reduced_temperature/reduced_temperature/gamma_tt-gamma_pp);
			result=sqrt(water_properties_R_water*temperature*result);
			break;
		}
		
		case region2 :
		{
			reduced_pressure=pressure/1.0e6;
			reduced_temperature=540.0/temperature;
			aux_t=reduced_temperature-0.5;
			for (counter=1;counter<=9;counter++)
			{
				water_properties_constants_region2_0(counter, &J, &n);
				gamma_tt0=gamma_tt0+n*(double)(J*(J-1))*power1(reduced_temperature,J-2);
			}
			for (counter=1;counter<=43;counter++)
			{
				water_properties_constants_region2_r(counter, &I, &J, &n);
				gamma_ttr=gamma_ttr+n*power1(reduced_pressure,I)*(double)(J*(J-1))*power1(aux_t,J-2);
				gamma_ppr=gamma_ppr+n*(double)(I*(I-1))*power1(reduced_pressure,I-2)*power1(aux_t,J);
				gamma_ptr=gamma_ptr+n*(double)(I*J)*power1(reduced_pressure,I-1)*power1(aux_t,J-1);
				gamma_pr=gamma_pr+n*(double)I*power1(reduced_pressure,I-1)*power1(aux_t,J);
			}
			result=(1.0+reduced_pressure*gamma_pr-reduced_temperature*reduced_pressure*gamma_ptr);
			result=result*result/(reduced_temperature*reduced_temperature*(gamma_tt0+gamma_ttr));
			result=result+(1.0-reduced_pressure*reduced_pressure*gamma_ppr);
			result=(1.0+2.0*reduced_pressure*gamma_pr+reduced_pressure*reduced_pressure*gamma_pr*gamma_pr)/result;
			result=sqrt(water_properties_R_water*temperature*result);
			break;
		}
		
		case region2meta :
		{
			reduced_pressure=pressure/1.0e6;
			reduced_temperature=540.0/temperature;
			aux_t=reduced_temperature-0.5;
			for (counter=1;counter<=9;counter++)
			{
				water_properties_constants_region2_meta_0(counter, &J, &n);
				gamma_tt0=gamma_tt0+n*(double)(J*(J-1))*power1(reduced_temperature,J-2);
			}
			for (counter=1;counter<=13;counter++)
			{
				water_properties_constants_region2_meta_r(counter, &I, &J, &n);
				gamma_ttr=gamma_ttr+n*power1(reduced_pressure,I)*(double)(J*(J-1))*power1(aux_t,J-2);
				gamma_ppr=gamma_ppr+n*(double)(I*(I-1))*power1(reduced_pressure,I-2)*power1(aux_t,J);
				gamma_ptr=gamma_ptr+n*(double)(I*J)*power1(reduced_pressure,I-1)*power1(aux_t,J-1);
				gamma_pr=gamma_pr+n*(double)I*power1(reduced_pressure,I-1)*power1(aux_t,J);
			}
			result=(1.0+reduced_pressure*gamma_pr-reduced_temperature*reduced_pressure*gamma_ptr);
			result=result*result/(reduced_temperature*reduced_temperature*(gamma_tt0+gamma_ttr));
			result=result+(1.0-reduced_pressure*reduced_pressure*gamma_ppr);
			result=(1.0+2.0*reduced_pressure*gamma_pr+reduced_pressure*reduced_pressure*gamma_pr*gamma_pr)/result;
			result=sqrt(water_properties_R_water*temperature*result);
			break;
		}
		
		case region3:
		{
			reduced_temperature=647.096/temperature;
			reduced_density=1.0/(322.0*water_properties_specific_volume(region3,temperature,pressure));
			water_properties_constants_region3(1, &I, &J, &n);
			phi_d=n/reduced_density;
			phi_dd=-phi_d/reduced_density;
			for (counter=2;counter<=40;counter++)
			{
				water_properties_constants_region3(counter, &I, &J, &n);
				phi_tt=phi_tt+n*power1(reduced_density,I)*(double)(J*(J-1))*power1(reduced_temperature,J-2);
				phi_d=phi_d+n*(double)I*power1(reduced_density,I-1)*power1(reduced_temperature,J);
				phi_dd=phi_dd+n*(double)(I*(I-1))*power1(reduced_density,I-2)*power1(reduced_temperature,J);
				phi_dt=phi_dt+n*(double)(I*J)*power1(reduced_density,I-1)*power1(reduced_temperature,J-1);
			}
			result=reduced_density*(phi_d-reduced_temperature*phi_dt)*(phi_d-reduced_temperature*phi_dt);
			result=result/(reduced_temperature*reduced_temperature*phi_tt);
			result=2.0*phi_d+reduced_density*phi_dd-result;
			result=sqrt(reduced_density*water_properties_R_water*temperature*result);
			break;
		}
		
		case region4 :
		{
			/*undefined*/
			result=0.0;
			break;
		}
		
		case region5 :
		{
			reduced_temperature=1000.0/temperature;
			reduced_pressure=pressure/1.0e6;
			for(counter=1;counter<=6;counter++)
			{
				water_properties_constants_region5_0(counter, &J, &n);
				gamma_tt0=gamma_tt0+n*(double)(J*(J-1))*power1(reduced_temperature,J-2);
			}
			for(counter=1;counter<=6;counter++)
			{
				water_properties_constants_region5_r(counter, &I, &J, &n);
				gamma_ttr=gamma_ttr+n*power1(reduced_pressure,I)*(double)(J*(J-1))*power1(reduced_temperature,J-2);
				gamma_pr=gamma_pr+n*(double)I*power1(reduced_pressure,I-1)*power1(reduced_temperature,J);
				gamma_ppr=gamma_ppr+n*(double)(I*(I-1))*power1(reduced_pressure,I-2)*power1(reduced_temperature,J);
				gamma_ptr=gamma_ptr+n*(double)(I*J)*power1(reduced_pressure,I-1)*power1(reduced_temperature,J-1);
			}
			result=(1.0+reduced_pressure*gamma_pr-reduced_temperature*reduced_pressure*gamma_ptr);
			result=result*result/(reduced_temperature*reduced_temperature*(gamma_tt0+gamma_ttr));
			result=result+(1.0-reduced_pressure*reduced_pressure*gamma_ppr);
			result=(1.0+2.0*reduced_pressure*gamma_pr+reduced_pressure*reduced_pressure*gamma_pr*gamma_pr)/result;
			result=sqrt(water_properties_R_water*temperature*result);
			break;
		}
	}
	return(result);
}


double water_properties_isobaric_cubic_expansion_coefficient(water_properties_region region, double temperature, double pressure)
{
	double reduced_pressure, reduced_temperature, reduced_density;
	double aux_p, aux_t;
	double n, result;
	double gamma_pt, gamma_pt0, gamma_ptr;
	double gamma_p, gamma_p0, gamma_pr;
	double phi_d, phi_dd, phi_dt;
	int I, J, counter;
	
	result=0.0;
	gamma_pt=0.0;
	gamma_pt0=0.0;
	gamma_ptr=0.0;
	gamma_p=0.0;
	gamma_p0=0.0;
	gamma_pr=0.0;
	phi_d=0.0;
	phi_dd=0.0;
	phi_dt=0.0;
	
	switch(region)
	{
		case region1 :
		{
			reduced_pressure=pressure/16.53e6;
			reduced_temperature=1386.0/temperature;
			aux_p=7.1-reduced_pressure;
			aux_t=reduced_temperature-1.222;
			for (counter=1;counter<=34;counter++)
			{
				water_properties_constants_region1(counter, &I, &J, &n);
				gamma_pt=gamma_pt-n*(double)(I*J)*power1(aux_p,I-1)*power1(aux_t,J-1);
				gamma_p=gamma_p-n*(double)I*power1(aux_p,I-1)*power1(aux_t,J);
			}
			result=(1.0-reduced_temperature*gamma_pt/gamma_p)/temperature;
			break;
		}
		
		case region2 :
		{
			reduced_pressure=pressure/1.0e6;
			reduced_temperature=540.0/temperature;
			aux_t=reduced_temperature-0.5;
			for (counter=1;counter<=43;counter++)
			{
				water_properties_constants_region2_r(counter, &I, &J, &n);
				gamma_ptr=gamma_ptr+n*(double)(I*J)*power1(reduced_pressure,I-1)*power1(aux_t,J-1);
				gamma_pr=gamma_pr+n*(double)I*power1(reduced_pressure,I-1)*power1(aux_t,J);
			}
			result=(1.0+reduced_pressure*gamma_pr-reduced_temperature*reduced_pressure*gamma_ptr)/(1.0+reduced_pressure*gamma_pr)/temperature;
			break;
		}
		
		case region2meta :
		{
			reduced_pressure=pressure/1.0e6;
			reduced_temperature=540.0/temperature;
			aux_t=reduced_temperature-0.5;
			for (counter=1;counter<=13;counter++)
			{
				water_properties_constants_region2_meta_r(counter, &I, &J, &n);
				gamma_ptr=gamma_ptr+n*(double)(I*J)*power1(reduced_pressure,I-1)*power1(aux_t,J-1);
				gamma_pr=gamma_pr+n*(double)I*power1(reduced_pressure,I-1)*power1(aux_t,J);
			}
			result=(1.0+reduced_pressure*gamma_pr-reduced_temperature*reduced_pressure*gamma_ptr)/(1.0+reduced_pressure*gamma_pr)/temperature;
			break;
		}
		
		case region3:
		{
			reduced_temperature=647.096/temperature;
			reduced_density=1.0/(322.0*water_properties_specific_volume(region3,temperature,pressure));
			water_properties_constants_region3(1, &I, &J, &n);
			phi_d=n/reduced_density;
			phi_dd=-phi_d/reduced_density;
			for (counter=2;counter<=40;counter++)
			{
				water_properties_constants_region3(counter, &I, &J, &n);
				phi_d=phi_d+n*(double)I*power1(reduced_density,I-1)*power1(reduced_temperature,J);
				phi_dd=phi_dd+n*(double)(I*(I-1))*power1(reduced_density,I-2)*power1(reduced_temperature,J);
				phi_dt=phi_dt+n*(double)(I*J)*power1(reduced_density,I-1)*power1(reduced_temperature,J-1);
			}
			result=(phi_d-reduced_temperature*phi_dt)/(2.0*phi_d+reduced_density*phi_dd)/temperature;
			break;
		}
		
		case region4 :
		{
			/*undefined*/
			result=0.0;
			break;
		}
		
		case region5 :
		{
			reduced_temperature=1000.0/temperature;
			reduced_pressure=pressure/1.0e6;
			for(counter=1;counter<=6;counter++)
			{
				water_properties_constants_region5_r(counter, &I, &J, &n);
				gamma_pr=gamma_pr+n*(double)I*power1(reduced_pressure,I-1)*power1(reduced_temperature,J);
				gamma_ptr=gamma_ptr+n*(double)(I*J)*power1(reduced_pressure,I-1)*power1(reduced_temperature,J-1);
			}
			result=(1.0+reduced_pressure*gamma_pr-reduced_temperature*reduced_pressure*gamma_ptr)/(1.0+reduced_pressure*gamma_pr)/temperature;
			break;
		}
	}
	return(result);
}


double water_properties_isothermal_compressibility(water_properties_region region, double temperature, double pressure)
{

	double reduced_pressure, reduced_temperature, reduced_density;
	double aux_p, aux_t;
	double n, result;
	double gamma_pp, gamma_pp0, gamma_ppr;
	double gamma_p, gamma_p0, gamma_pr;
	double phi_d, phi_dd, rho;
	int I, J;
	int counter;
	
	result=0.0;
	gamma_pp=0.0;
	gamma_pp0=0.0;
	gamma_ppr=0.0;
	gamma_p=0.0;
	gamma_p0=0.0;
	gamma_pr=0.0;
	phi_d=0.0;
	phi_dd=0.0;
	
	switch(region)
	{
		case region1 :
		{
			reduced_temperature=1386.0/temperature;
			reduced_pressure=pressure/16.53e6;
			aux_p=7.1-reduced_pressure;
			aux_t=reduced_temperature-1.222;
			for (counter=1;counter<=34;counter++)
			{
				water_properties_constants_region1(counter, &I, &J, &n);
				gamma_pp=gamma_pp+n*(double)(I*(I-1))*power1(aux_p,I-2)*power1(aux_t,J);
				gamma_p=gamma_p-n*(double)I*power1(aux_p,I-1)*power1(aux_t,J);
			}
			result=-reduced_pressure*gamma_pp/gamma_p/pressure;
			break;
		}
		
		case region2 :
		{
			reduced_temperature=540.0/temperature;
			reduced_pressure=pressure/1.0e6;
			aux_t=reduced_temperature-0.5;
			for (counter=1;counter<=43;counter++)
			{
				water_properties_constants_region2_r(counter, &I, &J, &n);
				gamma_ppr=gamma_ppr+n*(double)(I*(I-1))*power1(reduced_pressure,I-2)*power1(aux_t,J);
				gamma_pr=gamma_pr+n*(double)I*power1(reduced_pressure,I-1)*power1(aux_t,J);
			}
			result=(1.0-reduced_pressure*reduced_pressure*gamma_ppr)/(1.0+reduced_pressure*gamma_pr)/pressure;
			break;
		}
		
		case region2meta :
		{
			reduced_temperature=540.0/temperature;
			reduced_pressure=pressure/1.0e6;
			aux_t=reduced_temperature-0.5;
			for (counter=1;counter<=13;counter++)
			{
				water_properties_constants_region2_meta_r(counter, &I, &J, &n);
				gamma_ppr=gamma_ppr+n*(double)(I*(I-1))*power1(reduced_pressure,I-2)*power1(aux_t,J);
				gamma_pr=gamma_pr+n*(double)I*power1(reduced_pressure,I-1)*power1(aux_t,J);
			}
			result=(1.0-reduced_pressure*reduced_pressure*gamma_ppr)/(1.0+reduced_pressure*gamma_pr)/pressure;
			break;
		}
		
		case region3:
		{
			reduced_temperature=647.096/temperature;
			rho=1.0/water_properties_specific_volume(region3,temperature,pressure);
			reduced_density=rho/322.0;
			water_properties_constants_region3(1, &I, &J, &n);
			phi_d=n/reduced_density;
			phi_dd=-phi_d/reduced_density;
			for (counter=2;counter<=40;counter++)
			{
				water_properties_constants_region3(counter, &I, &J, &n);
				phi_d=phi_d+n*(double)I*power1(reduced_density,I-1)*power1(reduced_temperature,J);
				phi_dd=phi_dd+n*(double)(I*(I-1))*power1(reduced_density,I-2)*power1(reduced_temperature,J);
			}
			result=1.0/(reduced_density*(2.0*phi_d+reduced_density*phi_dd)*rho*water_properties_R_water*temperature);
			break;
		}
		
		case region4 :
		{
			/*undefined*/
			result=0.0;
			break;
		}
		
		case region5 :
		{
			reduced_temperature=1000.0/temperature;
			reduced_pressure=pressure/1.0e6;
			for(counter=1;counter<=6;counter++)
			{
				water_properties_constants_region5_r(counter, &I, &J, &n);
				gamma_pr=gamma_pr+n*(double)I*power1(reduced_pressure,I-1)*power1(reduced_temperature,J);
				gamma_ppr=gamma_ppr+n*(double)(I*(I-1))*power1(reduced_pressure,I-2)*power1(reduced_temperature,J);
			}
			result=(1.0-reduced_pressure*reduced_pressure*gamma_ppr)/(1.0+reduced_pressure*gamma_pr)/pressure;
			break;
		}
	}
	return(result);
}



double water_properties_Ts(double pressure)
/*region 4: saturation temperature*/
{
	double beta, n1, n2, n3, n4, n5, n6, n7, n8, n9, n10, D, E, F, G;
	
	beta=exp(0.25*ln(pressure/1.0e6));

	water_properties_constants_region4(1, &n1);
	water_properties_constants_region4(2, &n2);
	water_properties_constants_region4(3, &n3);
	water_properties_constants_region4(4, &n4);
	water_properties_constants_region4(5, &n5);
	water_properties_constants_region4(6, &n6);
	water_properties_constants_region4(7, &n7);
	water_properties_constants_region4(8, &n8);
	water_properties_constants_region4(9, &n9);
	water_properties_constants_region4(10, &n10);
	
	E=beta*(beta+n3)+n6;
	F=beta*(n1*beta+n4)+n7;
	G=beta*(n2*beta+n5)+n8;
	D=2.0*G/(-F-sqrt(F*F-4.0*E*G));
	
	return(  ( n10+D-sqrt( (n10+D)*(n10+D)-4.0*(n9+n10*D) ) ) / (2.0) );
}


double water_properties_ps(double temperature)
/*region 4: saturation pressure*/
{
	double theta, n1, n2, n3, n4, n5, n6, n7, n8, n9, n10, A, B, C;

	water_properties_constants_region4(1, &n1);
	water_properties_constants_region4(2, &n2);
	water_properties_constants_region4(3, &n3);
	water_properties_constants_region4(4, &n4);
	water_properties_constants_region4(5, &n5);
	water_properties_constants_region4(6, &n6);
	water_properties_constants_region4(7, &n7);
	water_properties_constants_region4(8, &n8);
	water_properties_constants_region4(9, &n9);
	water_properties_constants_region4(10, &n10);
	
	theta=temperature+n9/(temperature-n10);
	
	A=theta*(theta+n1)+n2;
	B=theta*(n3*theta+n4)+n5;
	C=theta*(n6*theta+n7)+n8;

	return( (1.0e6)*exp( 4.0*ln( 2.0*C/(-B+sqrt(B*B-4.0*A*C)) ) ) );
}


double water_properties_TB23(double pressure)
{
	double n3, n4, n5, reduced_pressure;
	
	reduced_pressure=pressure/1.0e6;
	water_properties_constans_region23(3,&n3);
	water_properties_constans_region23(4,&n4);
	water_properties_constans_region23(5,&n5);
	
	return(n4+sqrt((reduced_pressure-n5)/n3));
}


double water_properties_pB23(double temperature)
{
	double n1, n2, n3, reduced_temperature;

	reduced_temperature=temperature;
	water_properties_constans_region23(1,&n1);
	water_properties_constans_region23(2,&n2);
	water_properties_constans_region23(3,&n3);
	
	return(1.0e6*(n1+reduced_temperature*(n2+n3*reduced_temperature)));
}


/*--------------------------------------------------------------------------*/




/*function for coefficients of the single regions*/

void water_properties_constans_region23(int i, double *n)
{
	const double nArray[]={0.34805185628969e3,-0.11671859879975e1,
						   0.10192970039326e-2,0.57254459862746e3,
						   0.13918839778870e2};
	
	if (i<=5)
	{
		*n=nArray[i-1];
	}
	else
	{
		*n=0.0;
	}
}


void water_properties_constants_region1(int i, int *I, int *J, double *n)
{
	const int IArray[]={0,0,0,0,0,0,0,0,1,1,1,1,1,1,2,2,2,2,2,3,3,3,4,4,4,5,8,8,21,23,29,30,31,32};
	const int JArray[]={-2,-1,0,1,2,3,4,5,-9,-7,-1,0,1,3,-3,0,1,3,17,-4,0,6,-5,-2,10,-8,-11,-6,-29,-31,-38,-39,-40,-41};
	const double nArray[]={0.14632971213167,-0.84548187169114,-0.37563603672040e1,
						   0.33855169168385e1,-0.95791963387872,0.15772038513228,
						   -0.16616417199501e-1,0.81214629983568e-3,0.28319080123804e-3,
						   -0.60706301565874e-3,-0.18990068218419e-1,-0.32529748770505e-1,
						   -0.21841717175414e-1,-0.52838357969930e-4,-0.47184321073267e-3,
						   -0.30001780793026e-3,0.47661393906987e-4,-0.44141845330846e-5,
						   -0.72694996297594e-15,-0.31679644845054e-4,-0.28270797985312e-5,
						   -0.85205128120103e-9,-0.22425281908000e-5,-0.65171222895601e-6,
						   -0.14341729937924e-12,-0.40516996860117e-6,-0.12734301741641e-8,
						   -0.17424871230634e-9,-0.68762131295531e-18,0.14478307828521e-19,
						   0.26335781662795e-22,-0.11947622640071e-22,0.18228094581404e-23,
						   -0.93537087292458e-25};

	if (i<=34)
	{
		*I=IArray[i-1];
		*J=JArray[i-1];
		*n=nArray[i-1];
	}
	else
	{
		*I=0;
		*J=0;
		*n=0.0;
	}
}


void water_properties_constants_region2_0(int i, int *J, double *n)
{
	const int JArray[]={0,1,-5,-4,-3,-2,-1,2,3};
	const double nArray[]={-0.96927686500217e1,0.10086655968018e2,
						   -0.56087911283020e-2,0.71452738081455e-1,
						   -0.40710498223928,0.14240819171444e1,
						   -0.43839511319450e1,-0.28408632460772,
						   0.21268463753307e-1};
	
	if (i<=9)
	{
		*J=JArray[i-1];
		*n=nArray[i-1];
	}
	else
	{
		*J=0;
		*n=0.0;
	}
}


void water_properties_constants_region2_r(int i, int *I, int *J, double *n)
{
	const int IArray[]={1,1,1,1,1,2,2,2,2,2,3,3,3,3,3,4,4,4,5,6,6,6,7,
						7,7,8,8,9,10,10,10,16,16,18,20,20,20,21,22,23,24,24,24};
	const int JArray[]={0,1,2,3,6,1,2,4,7,36,0,1,3,6,35,1,2,3,7,3,16,35,0,11,25,
						8,36,13,4,10,14,29,50,57,20,35,48,21,53,39,26,40,58};
	const double nArray[]={-0.17731742473213e-2,-0.17834862292358e-1,-0.45996013696365e-1,-0.57581259083432e-1,
						   -0.50325278727930e-1,-0.33032641670203e-4,-0.18948987516315e-3,-0.39392777243355e-2,
						   -0.43797295650573e-1,-0.26674547914087e-4,0.20481737692309e-7,0.43870667284435e-6,
						   -0.32277677238570e-4,-0.15033924542148e-2,-0.40668253562649e-1,-0.78847309559367e-9,
						   0.12790717852285e-7,0.48225372718507e-6,0.22922076337661e-5,-0.16714766451061e-10,
						   -0.21171472321355e-2,-0.23895741934104e2,-0.59059564324270e-17,-0.12621808899101e-5,
						   -0.38946842435739e-1 ,0.11256211360459e-10,-0.82311340897998e1,0.19809712802088e-7,
						   0.10406965210174e-18,-0.10234747095929e-12,-0.10018179379511e-8,-0.80882908646985e-10,
						   0.10693031879409,-0.33662250574171,0.89185845355421e-24,0.30629316876232e-12,
						   -0.42002467698208e-5,-0.59056029685639e-25,0.37826947613457e-5,-0.12768608934681e-14,
						   0.73087610595061e-28,0.55414715350778e-16,-0.94369707241210e-6};
	if (i<=43 && i>=1)
	{
		*I=IArray[i-1];
		*J=JArray[i-1];
		*n=nArray[i-1];
	}
	else
	{
		*I=0;
		*J=0;
		*n=0.0;
	}
}


void water_properties_constants_region2_meta_0(int i, int *J, double *n)
{
	const int JArray[]={0,1,-5,-4,-3,-2,-1,2,3};
	const double nArray[]={-0.96937268393049e1,0.10087275970006e2,
						   -0.56087911283020e-2,0.71452738081455e-1,
						   -0.40710498223928,0.14240819171444e1,
						   -0.43839511319450e1,-0.28408632460772,
						   0.21268463753307e-1};
	
	if (i<=9 && i>=1)
	{
		*J=JArray[i-1];
		*n=nArray[i-1];
	}
	else
	{
		*J=0;
		*n=0.0;
	}
}


void water_properties_constants_region2_meta_r(int i, int *I, int *J, double *n)
{
	const int IArray[]={1,1,1,1,2,2,2,3,3,4,4,5,5};
	const int JArray[]={0,2,5,11,1,7,16,4,16,7,10,9,10};
	const double nArray[]={-0.73362260186506e-2,-0.88223831943146e-1,
						   -0.72334555213245e-1,-0.40813178534455e-2,
						   0.20097803380207e-2,-0.53045921898642e-1,
						   -0.76190409086970e-2,-0.63498037657313e-2,
						   -0.86043093028588e-1,0.75321581522770e-2,
						   -0.79238375446139e-2,-0.22888160778447e-3,
						   -0.26456501482810e-2};
	
	if (i<=13 && i>=1)
	{
		*I=IArray[i-1];
		*J=JArray[i-1];
		*n=nArray[i-1];
	}
	else
	{
		*I=0;
		*J=0;
		*n=0.0;
	}
}


void water_properties_constants_region3(int i, int *I, int *J, double *n)
{
	const int IArray[]={0,0,0,0,0,0,0,0,1,1,1,1,2,2,2,2,2,2,3,3,3,3,3,
						4,4,4,4,5,5,5,6,6,6,7,8,9,9,10,10,11};
	const int JArray[]={0,0,1,2,7,10,12,23,2,6,15,17,0,2,6,7,22,26,0,2,4,
						16,26,0,2,4,26,1,3,26,0,2,26,2,26,2,26,0,1,26};
	const double nArray[]={0.10658070028513e1,-0.15732845290239e2,0.20944396974307e2,-0.76867707878716e1,
						   0.26185947787954e1,-0.28080781148620e1,0.12053369696517e1,-0.84566812812502e-2,
						   -0.12654315477714e1,-0.11524407806681e1,0.88521043984318,-0.64207765181607,
						   0.38493460186671,-0.85214708824206,0.48972281541877e1,-0.30502617256965e1,
						   0.39420536879154e-1,0.12558408424308,-0.27999329698710,0.13899799569460e1,
						   -0.20189915023570e1,-0.82147637173963e-2,-0.47596035734923,0.43984074473500e-1,
						   -0.44476435428739,0.90572070719733,0.70522450087967,0.10770512626332,-0.32913623258954,
						   -0.50871062041158,-0.22175400873096e-1,0.94260751665092e-1,0.16436278447961,-0.13503372241348e-1,
						   -0.14834345352472e-1,0.57922953628084e-3,0.32308904703711e-2,0.80964802996215e-4,
						   -0.16557679795037e-3,-0.44923899061815e-4};
						
		if (i<=40 && i>=1)
	{
		*I=IArray[i-1];
		*J=JArray[i-1];
		*n=nArray[i-1];
	}
	else
	{
		*I=0;
		*J=0;
		*n=0.0;
	}
}


void water_properties_constants_region4(int i, double *n)
{
	const double nArray[]={0.11670521452767e4,-0.72421316703206e6,
						   -0.17073846940092e2,0.12020824702470e5,
						   -0.32325550322333e7,0.14915108613530e2,
						   -0.48232657361591e4,0.40511340542057e6,
						   -0.23855557567849,0.65017534844798e3};
	
	if (i<=10)
	{
		*n=nArray[i-1];
	}
	else
	{
		*n=0.0;
	}
}


void water_properties_constants_region5_0(int i, int *J, double *n)
{
	const int JArray[]={0,1,-3,-2,-1,2};
	const double nArray[]={-0.13179983674201e2,0.68540841634434e1,
						   -0.24805148933466e-1,0.36901534980333,
						   -0.31161318213925e1,-0.32961626538917};
	
	if (i<=6 && i>=1)
	{
		*J=JArray[i-1];
		*n=nArray[i-1];
	}
	else
	{
		*J=0;
		*n=0.0;
	}
}


void water_properties_constants_region5_r(int i, int *I, int *J, double *n)
{
	const int IArray[]={1,1,1,2,2,3};
	const int JArray[]={1,2,3,3,9,7};
	const double nArray[]={0.15736404855259e-2,0.90153761673944e-3,
						   -0.50270077677648e-2,0.22440037409485e-5,
						   -0.41163275453471e-5,0.37919454822955e-7};
	
	if (i<=6 && i>=1)
	{
		*I=IArray[i-1];
		*J=JArray[i-1];
		*n=nArray[i-1];
	}
	else
	{
		*I=0;
		*J=0;
		*n=0.0;
	}
}


/*--------------------------------------------------------------------------*/




/*function for backwards equations of region 3*/

double water_properties_specific_volume_region3(water_properties_region region,
												double temperature, double pressure)
{
	int N, counter, I, J;
	double p, T, v, a, b, c, d, e, result, n;
	double reduced_pressure, reduced_temperature, var1, var2;
	
	water_properties_specific_volume_region3_get_constants2(region, &v, &p, &T, &N,
															&a, &b, &c, &d, &e);
	reduced_pressure=pressure/p;
	reduced_temperature=temperature/T;
	result=0.0;
	
	if (region==region3n)
	{
		var1=reduced_pressure-a;
		var2=reduced_temperature-b;
		for(counter=1;counter<=N;counter++)
		{
			water_properties_specific_volume_region3_get_constants(region, counter, &I, &J, &n);
			result=result+n*exp((double)I*ln(var1))*exp((double)J*ln(var2));
		}
		result=v*exp(result);
	}
	else
	{
		var1=power2(reduced_pressure-a,c);
		var2=power2(reduced_temperature-b,d);
		for(counter=1;counter<=N;counter++)
		{
			water_properties_specific_volume_region3_get_constants(region, counter, &I, &J, &n);
			result=result+n*power1(var1,I)*power1(var2,J);
		}
		result=v*exp(e*ln(result));
	}
	return(result);
}


void water_properties_specific_volume_region3_get_boundary_constants(water_properties_region boundary,
																	 int i, int *I, double *n)
{
	*I=0;
	*n=0.0;
	switch(boundary)
	{
		case boundary_ab :
		{
			switch(i)
			{
				case 1 : *I=0; *n=0.154793642129415e4; break;
				case 2 : *I=1; *n=-0.187661219490113e3; break;
				case 3 : *I=2; *n=0.213144632222113e2; break;
				case 4 : *I=-1; *n=-0.191887498864292e4; break;
				case 5 : *I=-2; *n=0.918419702359447e3; break;
			} break;
		}
		case boundary_cd :
		{
			switch(i)
			{
				case 1 : *I=0; *n=0.585276966696349e3; break;
				case 2 : *I=1; *n=0.278233532206915e1; break;
                case 3 : *I=2; *n=-0.127283549295878e-1; break;
                case 4 : *I=3; *n=0.159090746562729e-3; break;
			} break;
		}
		case boundary_gh :
		{
			switch(i)
			{
				case 1 : *I=0; *n=-0.249284240900418e5; break;
				case 2 : *I=1; *n=0.428143584791546e4; break;
				case 3 : *I=2; *n=-0.269029173140130e3; break;
				case 4 : *I=3; *n=0.751608051114157e1; break;
                case 5 : *I=4; *n=-0.787105249910383e-1; break;
			} break;
		}
		case boundary_ij :
		{
			switch(i)
			{
				case 1 : *I=0; *n=0.584814781649163e3; break;
				case 2 : *I=1; *n=-0.616179320924617; break;
				case 3 : *I=2; *n=0.260763050899562; break;
                case 4 : *I=3; *n=-0.587071076864459e-2; break;
                case 5 : *I=4; *n=0.515308185433082e-4; break;
			} break;
		}
		case boundary_jk :
		{
			switch(i)
			{
				case 1 : *I=0; *n=0.617229772068439e3; break;
				case 2 : *I=1; *n=-0.770600270141675e1; break;
				case 3 : *I=2; *n=0.697072596851896; break;
				case 4 : *I=3; *n=-0.157391839848015e-1; break;
                case 5 : *I=4; *n=0.137897492684194e-3; break;
			} break;
		}
		case boundary_mn :
		{
			switch(i)
			{
				case 1 : *I=0; *n=0.535339483742384e3; break;
				case 2 : *I=1; *n=0.761978122720128e1; break;
				case 3 : *I=2; *n=-0.158365725441648; break;
                case 4 : *I=3; *n=0.192871054508108e-2; break;
			} break;
		}
		case boundary_op :
		{
			switch(i)
			{
				case 1 : *I=0; *n=0.969461372400213e3; break;
				case 2 : *I=1; *n=-0.332500170441278e3; break;
				case 3 : *I=2; *n=0.642859598466067e2; break;
				case 4 : *I=-1; *n=0.773845935768222e3; break;
				case 5 : *I=-2; *n=-0.152313732937084e4; break;
			} break;
		}
		case boundary_qu :
		{
			switch(i)
			{
				case 1 : *I=0; *n=0.565603648239126e3; break;
				case 2 : *I=1; *n=0.529062258221222e1; break;
				case 3 : *I=2; *n=-0.102020639611016; break;
                case 4 : *I=3; *n=0.122240301070145e-2; break;
			} break;
		}
		case boundary_rx :
		{
			switch(i)
			{
				case 1 : *I=0; *n=0.584561202520006e3; break;
				case 2 : *I=1; *n=-0.102961025163669e1; break;
				case 3 : *I=2; *n=0.243293362700452; break;
				case 4 : *I=3; *n=-0.294905044740799e-2; break;
			} break;
		}
		case boundary_uv :
		{
			switch(i)
			{
				case 1 : *I=0; *n=0.528199646263062e3; break;
				case 2 : *I=1; *n=0.890579602135307e1; break;
				case 3 : *I=2; *n=-0.222814134903755; break;
				case 4 : *I=3; *n=0.286791682263697e-2; break;
			} break;
		}
		case boundary_wx :
		{
			switch(i)
			{
				case 1 : *I=0; *n=0.728052609145380e1; break;
				case 2 : *I=1; *n=0.973505869861952e2; break;
				case 3 : *I=2; *n=0.147370491183191e2; break;
				case 4 : *I=-1; *n=0.329196213998375e3; break;
				case 5 : *I=-2; *n=0.873371668682417e3; break;
			} break;
		}
	}
}


double water_properties_region3_temperature_boundary(water_properties_region boundary, double pressure)
{
	int counter, I;
	double result, n, reduced_pressure, aux_var;
	
	result=0.0;
	reduced_pressure=pressure/1.0e6;
		
	if (boundary==boundary_ab || boundary==boundary_op || boundary==boundary_wx)
	{
		aux_var=ln(ln(reduced_pressure));
		for(counter=1;counter<=5;counter++)
		{
			water_properties_specific_volume_region3_get_boundary_constants(boundary,counter,&I,&n);
			result=result+n*exp((double)I*aux_var);
		}
	}
	else if (boundary==boundary_ef)
	{
		result=3.727888004*(reduced_pressure-22.064)+647.096;
	}
	else
	{
		aux_var=ln(reduced_pressure);
		for (counter=1;counter<=5;counter++)
		{
			water_properties_specific_volume_region3_get_boundary_constants(boundary,counter,&I,&n);
			result=result+n*exp((double)I*aux_var);
		}
	}
	return(result);
}


water_properties_region water_properties_specific_volume_region3_get_region(double temperature, double pressure)
{
	double p, T;
	p=pressure;
	T=temperature;
	if ( (40.0e6<p) && (p<=100.0e6))
	{
		if (T<=water_properties_region3_temperature_boundary(boundary_ab,p))
		{
			return(region3a);
		}
		else
		{
			return(region3b);
		}
	}
	else if ( (25.0e6<p) && (p<=40.0e6) )
	{
		if (T<=water_properties_region3_temperature_boundary(boundary_cd,p))
		{
			return(region3c);
		}
		else if (water_properties_region3_temperature_boundary(boundary_cd,p)<T && T<=water_properties_region3_temperature_boundary(boundary_ab,p) )
		{
			return(region3d);
		}
		else if ( water_properties_region3_temperature_boundary(boundary_ab,p)<T && T<= water_properties_region3_temperature_boundary(boundary_ef,p) )
		{
			return(region3e);
		}
		else if ( T>water_properties_region3_temperature_boundary(boundary_ef,p) )
		{
			return(region3f);
		}
	}
	else if (23.5e6<p && p<=25e6)
	{
		if (T<water_properties_region3_temperature_boundary(boundary_cd,p))
		{
			return(region3c);
		}
		else if ( water_properties_region3_temperature_boundary(boundary_cd,p)<T && T<=water_properties_region3_temperature_boundary(boundary_gh,p) )
		{
			return(region3g);
		}
		else if ( water_properties_region3_temperature_boundary(boundary_gh,p)<T && T<=water_properties_region3_temperature_boundary(boundary_ef,p) )
		{
			return(region3h);
		}
		else if ( water_properties_region3_temperature_boundary(boundary_ef,p)<T && T<=water_properties_region3_temperature_boundary(boundary_ij,p) )
		{
			return(region3i);
		}
		else if ( water_properties_region3_temperature_boundary(boundary_ij,p)<T && T<=water_properties_region3_temperature_boundary(boundary_jk,p) )
		{
			return(region3j);
		}
		else if ( water_properties_region3_temperature_boundary(boundary_jk,p)<T )
		{
			return(region3k);
		}
	}
	else if (23.0e6<p && p<=23.5e6)
	{
		if ( T<=water_properties_region3_temperature_boundary(boundary_cd,p) )
		{
			return(region3c);
		}
		else if ( water_properties_region3_temperature_boundary(boundary_cd,p)<T && T<=water_properties_region3_temperature_boundary(boundary_gh,p) )
		{
			return(region3l);
		}
		else if ( water_properties_region3_temperature_boundary(boundary_gh,p)<T && T<=water_properties_region3_temperature_boundary(boundary_ef,p) )
		{
			return(region3h);
		}
		else if ( water_properties_region3_temperature_boundary(boundary_ef,p)<T && T<=water_properties_region3_temperature_boundary(boundary_ij,p) )
		{
			return(region3i);
		}
		else if ( water_properties_region3_temperature_boundary(boundary_ij,p)<T && T<=water_properties_region3_temperature_boundary(boundary_jk,p) )
		{
			return(region3j);
		}
		else if ( water_properties_region3_temperature_boundary(boundary_jk,p)<T )
		{
			return(region3k);
		}
	}
	else if (22.5e6<p && p<=23.0e6)
	{
		if (T<=water_properties_region3_temperature_boundary(boundary_cd,p))
		{
			return(region3c);
		}
		else if (water_properties_region3_temperature_boundary(boundary_cd,p)<T && T<=water_properties_region3_temperature_boundary(boundary_gh,p) )
		{
			return(region3l);
		}
		else if (water_properties_region3_temperature_boundary(boundary_gh,p)<T && T<=water_properties_region3_temperature_boundary(boundary_mn,p) )
		{
			return(region3m);
		}
		else if (water_properties_region3_temperature_boundary(boundary_mn,p)<T && T<=water_properties_region3_temperature_boundary(boundary_ef,p) )
		{
			return(region3n);
		}
		else if (water_properties_region3_temperature_boundary(boundary_ef,p)<T && T<=water_properties_region3_temperature_boundary(boundary_op,p) )
		{
			return(region3o);
		}
		else if (water_properties_region3_temperature_boundary(boundary_op,p)<T && T<=water_properties_region3_temperature_boundary(boundary_ij,p) )
		{
			return(region3p);
		}
		else if (water_properties_region3_temperature_boundary(boundary_ij,p)<T && T<=water_properties_region3_temperature_boundary(boundary_jk,p) )
		{
			return(region3j);
		}
		else if (water_properties_region3_temperature_boundary(boundary_jk,p)<T )
		{
			return(region3k);
		}
	}
	else if (21.04336732e6<p && p<=22.5e6)
	{
		if ( water_properties_region3_temperature_boundary(boundary_qu,p)<=T && T<=water_properties_region3_temperature_boundary(boundary_rx,p) )
		{ /*near critial point*/
			if (p<=22.064e6)
			{
				if (T<=water_properties_Ts(p))
				{
					if ( 21.93161531e6<p && p<=22.064e6 )
					{
						if ( water_properties_region3_temperature_boundary(boundary_qu,p)<T && T<=water_properties_region3_temperature_boundary(boundary_uv,p) )
						{
							return(region3u);
						}
						else if (water_properties_region3_temperature_boundary(boundary_uv,p)<T)
						{
							return(region3y);
						}
					}
					else if (21.04336732e6<p && p<=21.93161531e6)
					{
						if (water_properties_region3_temperature_boundary(boundary_qu,p)<T)
						{
							return(region3u);
						}
					}
				}
				else
				{
					if (21.90096265e6<p && p<=22.064e6)
					{
						if (T<=water_properties_region3_temperature_boundary(boundary_wx,p) )
						{
							return(region3z);
						}
						else if ( water_properties_region3_temperature_boundary(boundary_wx,p)<T && T<=water_properties_region3_temperature_boundary(boundary_rx,p) )
						{
							return(region3x);
						}
					}
					else if ( 21.04336732e6<p && p<=21.90096265e6 )
					{
						if (T<=water_properties_region3_temperature_boundary(boundary_rx,p))
						{
							return(region3x);
						}
					}
				}
			}
			else
			{
				if (22.064e6<p && p<=22.11e6)
				{
					if (water_properties_region3_temperature_boundary(boundary_qu,p)<T && T<=water_properties_region3_temperature_boundary(boundary_uv,p) )
					{
						return(region3u);
					}
					else if (water_properties_region3_temperature_boundary(boundary_ef,p)<T && T<=water_properties_region3_temperature_boundary(boundary_wx,p) )
					{
						return(region3z);
					}
					else if (water_properties_region3_temperature_boundary(boundary_uv,p)<T && T<=water_properties_region3_temperature_boundary(boundary_ef,p) )
					{
						return(region3y);
					}
					else if (water_properties_region3_temperature_boundary(boundary_wx,p)<T && T<=water_properties_region3_temperature_boundary(boundary_rx,p) )
					{
						return(region3x);
					}
				}
				else if (22.11e6<p && p<=22.5e6)
				{
					if (water_properties_region3_temperature_boundary(boundary_qu,p)<T && T<=water_properties_region3_temperature_boundary(boundary_uv,p) )
					{
						return(region3u);
					}
					else if (water_properties_region3_temperature_boundary(boundary_ef,p)<T && T<=water_properties_region3_temperature_boundary(boundary_wx,p) )
					{
						return(region3w);
					}
					else if (water_properties_region3_temperature_boundary(boundary_uv,p)<T && T<=water_properties_region3_temperature_boundary(boundary_ef,p) )
					{
						return(region3v);
					}
					else if (water_properties_region3_temperature_boundary(boundary_wx,p)<T && T<=water_properties_region3_temperature_boundary(boundary_rx,p) )
					{
						return(region3x);
					}
				}
			}			
		} /*end near critial point region*/	
		else if ( T<=water_properties_region3_temperature_boundary(boundary_cd,p) )
		{
			return(region3c);
		}
		else if ( water_properties_region3_temperature_boundary(boundary_cd,p)<T && T<=water_properties_region3_temperature_boundary(boundary_qu,p) )
		{
			return(region3q);
		}
		else if ( water_properties_region3_temperature_boundary(boundary_rx,p)<T && T<=water_properties_region3_temperature_boundary(boundary_jk,p) )
		{
			return(region3r);
		}
		else if ( water_properties_region3_temperature_boundary(boundary_jk,p)<T )
		{
			return(region3k);
		}
	}
	else if ( 20.5e6<p && p<=21.04336732e6)
	{
		if ( T<=water_properties_region3_temperature_boundary(boundary_cd,p) )
		{
			return(region3c);
		}
		else if (water_properties_region3_temperature_boundary(boundary_cd,p)<T && T<=water_properties_Ts(p) )
		{
			return(region3s);
		}
		else if ( water_properties_Ts(p)<=T && T<=water_properties_region3_temperature_boundary(boundary_jk,p) )
		{
			return(region3r);
		}
		else if ( T>water_properties_region3_temperature_boundary(boundary_jk,p) )
		{
			return(region3k);
		}
	}
	else if ( 19.00881189e6<p && p<=20.5e6)
	{
		if (T<=water_properties_region3_temperature_boundary(boundary_cd,p) )
		{
			return(region3c);
		}
		else if (water_properties_region3_temperature_boundary(boundary_cd,p)<T && T<=water_properties_Ts(p) )
		{
			return(region3s);
		}
		else if ( T>=water_properties_Ts(p) )
		{
			return(region3t);
		}
	}
	else if ( 16.52916425e6<p && p<=19.00881189e6)
	{
		if (T<=water_properties_Ts(p) )
		{
			return(region3c);
		}
		else if (T>=water_properties_Ts(p) )
		{
			return(region3t);
		}
	}
	return(none);
}


void water_properties_specific_volume_region3_get_constants(water_properties_region region,
															int i, int *I, int *J, double *n)
{
	*I=0;
	*J=0;
	*n=0.0;
	
	switch(region)
	{
		case region3a :
		{
			switch(i)
			{
				case 1 : *I=-12; *J=5; *n=0.110879558823853e-2; break;
				case 2 : *I=-12; *J=10; *n=0.572616740810616e3; break;
				case 3 : *I=-12; *J=12; *n=-0.767051948380852e5; break;
				case 4 : *I=-10; *J=5; *n=-0.253321069529674e-1; break;
				case 5 : *I=-10; *J=10; *n=0.628008049345689e4; break;
				case 6 : *I=-10; *J=12; *n=0.234105654131876e6; break;
				case 7 : *I=-8; *J=5; *n=0.216867826045856; break;
				case 8 : *I=-8; *J=8; *n=-0.156237904341963e3; break;
				case 9 : *I=-8; *J=10; *n=-0.269893956176613e5; break;
				case 10 : *I=-6; *J=1; *n=-0.180407100085505e-3; break;
				case 11 : *I=-5; *J=1; *n=0.116732227668261e-2; break;
				case 12 : *I=-5; *J=5; *n=0.266987040856040e2; break;
				case 13 : *I=-5; *J=10; *n=0.282776617243286e5; break;
				case 14 : *I=-4; *J=8; *n=-0.242431520029523e4; break;
				case 15 : *I=-3; *J=0; *n=0.435217323022733e-3; break;
				case 16 : *I=-3; *J=1; *n=-0.122494831387441e-1; break;
				case 17 : *I=-3; *J=3; *n=0.179357604019989e1; break;
				case 18 : *I=-3; *J=6; *n=0.442729521058314e2; break;
				case 19 : *I=-2; *J=0; *n=-0.593223489018342e-2; break;
				case 20 : *I=-2; *J=2; *n=0.453186261685774; break;
				case 21 : *I=-2; *J=3; *n=0.135825703129140e1; break;
				case 22 : *I=-1; *J=0; *n=0.408748415856745e-1; break;
				case 23 : *I=-1; *J=1; *n=0.474686397863312; break;
				case 24 : *I=-1; *J=2; *n=0.118646814997915e1; break;
				case 25 : *I=0; *J=0; *n=0.546987265727549; break;
				case 26 : *I=0; *J=1; *n=0.195266770452643; break;
				case 27 : *I=1; *J=0; *n=-0.502268790869663e-1; break;
				case 28 : *I=1; *J=2; *n=-0.369645308193377; break;
				case 29 : *I=2; *J=0; *n=0.633828037528420e-2; break;
				case 30 : *I=2; *J=2; *n=0.797441793901017e-1; break;
			} break;
		}
		
		case region3b :
		{
			switch(i)
			{
				case 1 : *I=-12; *J=10; *n=-0.827670470003621e-1; break;
				case 2 : *I=-12; *J=12; *n=0.416887126010565e2; break;
				case 3 : *I=-10; *J=8; *n=0.483651982197059e-1; break;
				case 4 : *I=-10; *J=14; *n=-0.291032084950276e5; break;
				case 5 : *I=-8; *J=8; *n=-0.111422582236948e3; break;
				case 6 : *I=-6; *J=5; *n=-0.202300083904014e-1; break;
				case 7 : *I=-6; *J=6; *n=0.294002509338515e3; break;
				case 8 : *I=-6; *J=8; *n=0.140244997609658e3; break;
				case 9 : *I=-5; *J=5; *n=-0.344384158811459e3; break;
				case 10 : *I=-5; *J=8; *n=0.361182452612149e3; break;
				case 11 : *I=-5; *J=10; *n=-0.140699677420738e4; break;
				case 12 : *I=-4; *J=2; *n=-0.202023902676481e-2; break;
				case 13 : *I=-4; *J=4; *n=0.171346792457471e3; break;
				case 14 : *I=-4; *J=5; *n=-0.425597804058632e1; break;
				case 15 : *I=-3; *J=0; *n=0.691346085000334e-5; break;
				case 16 : *I=-3; *J=1; *n=0.151140509678925e-2; break;
				case 17 : *I=-3; *J=2; *n=-0.416375290166236e-1; break;
				case 18 : *I=-3; *J=3; *n=-0.413754957011042e2; break;
				case 19 : *I=-3; *J=5; *n=-0.506673295721637e2; break;
				case 20 : *I=-2; *J=0; *n=-0.572212965569023e-3; break;
				case 21 : *I=-2; *J=2; *n=0.608817368401785e1; break;
				case 22 : *I=-2; *J=5; *n=0.239600660256161e2; break;
				case 23 : *I=-1; *J=0; *n=0.122261479925384e-1; break;
				case 24 : *I=-1; *J=2; *n=0.216356057692938e1; break;
				case 25 : *I=0; *J=0; *n=0.398198903368642; break;
				case 26 : *I=0; *J=1; *n=-0.116892827834085; break;
				case 27 : *I=1; *J=0; *n=-0.102845919373532; break;
				case 28 : *I=1; *J=2; *n=-0.492676637589284; break;
				case 29 : *I=2; *J=0; *n=0.655540456406790e-1; break;
				case 30 : *I=3; *J=2; *n=-0.240462535078530; break;
				case 31 : *I=4; *J=0; *n=-0.269798180310075e-1; break;
				case 32 : *I=4; *J=1; *n=0.128369435967012; break;
			} break;
		}
		
		case region3c :
		{
			switch(i)
			{
				case 1 : *I=-12; *J=6; *n=0.311967788763030e1; break;
				case 2 : *I=-12; *J=8; *n=0.276713458847564e5; break;
				case 3 : *I=-12; *J=10; *n=0.322583103403269e8; break;
				case 4 : *I=-10; *J=6; *n=-0.342416065095363e3; break;
				case 5 : *I=-10; *J=8; *n=-0.899732529907377e6; break;
				case 6 : *I=-10; *J=10; *n=-0.793892049821251e8; break;
				case 7 : *I=-8; *J=5; *n=0.953193003217388e2; break;
				case 8 : *I=-8; *J=6; *n=0.229784742345072e4; break;
				case 9 : *I=-8; *J=7; *n=0.175336675322499e6; break;
				case 10 : *I=-6; *J=8; *n=0.791214365222792e7; break;
				case 11 : *I=-5; *J=1; *n=0.319933345844209e-4; break;
				case 12 : *I=-5; *J=4; *n=-0.659508863555767e2; break;
				case 13 : *I=-5; *J=7; *n=-0.833426563212851e6; break;
				case 14 : *I=-4; *J=2; *n=0.645734680583292e-1; break;
				case 15 : *I=-4; *J=8; *n=-0.382031020570813e7; break;
				case 16 : *I=-3; *J=0; *n=0.406398848470079e-4; break;
				case 17 : *I=-3; *J=3; *n=0.310327498492008e2; break;
				case 18 : *I=-2; *J=0; *n=-0.892996718483724e-3; break;
				case 19 : *I=-2; *J=4; *n=0.234604891591616e3; break;
				case 20 : *I=-2; *J=5; *n=0.377515668966951e4; break;
				case 21 : *I=-1; *J=0; *n=0.158646812591361e-1; break;
				case 22 : *I=-1; *J=1; *n=0.707906336241843; break;
				case 23 : *I=-1; *J=2; *n=0.126016225146570e2; break;
				case 24 : *I=0; *J=0; *n=0.736143655772152; break;
				case 25 : *I=0; *J=1; *n=0.676544268999101; break;
				case 26 : *I=0; *J=2; *n=-0.178100588189137e2; break;
				case 27 : *I=1; *J=0; *n=-0.156531975531713; break;
				case 28 : *I=1; *J=2; *n=0.117707430048158e2; break;
				case 29 : *I=2; *J=0; *n=0.840143653860447e-1; break;
				case 30 : *I=2; *J=1; *n=-0.186442467471949; break;
				case 31 : *I=2; *J=3; *n=-0.440170203949645e2; break;
				case 32 : *I=2; *J=7; *n=0.123290423502494e7; break;
				case 33 : *I=3; *J=0; *n=-0.240650039730845e-1; break;
				case 34 : *I=3; *J=7; *n=-0.107077716660869e7; break;
				case 35 : *I=8; *J=1; *n=0.438319858566475e-1; break;
			} break;
		}
		
		case region3d :
		{
			switch(i)
			{
				case 1 : *I=-12; *J=4; *n=-0.452484847171645e-9; break;
				case 2 : *I=-12; *J=6; *n=0.315210389538801e-4; break;
				case 3 : *I=-12; *J=7; *n=-0.214991352047545e-2; break;
				case 4 : *I=-12; *J=10; *n=0.508058874808345e3; break;
				case 5 : *I=-12; *J=12; *n=-0.127123036845932e8; break;
				case 6 : *I=-12; *J=16; *n=0.115371133120497e13; break;
				case 7 : *I=-10; *J=0; *n=-0.197805728776273e-15; break;
				case 8 : *I=-10; *J=2; *n=0.241554806033972e-10; break;
				case 9 : *I=-10; *J=4; *n=-0.156481703640525e-5; break;
				case 10 : *I=-10; *J=6; *n=0.277211346836625e-2; break;
				case 11 : *I=-10; *J=8; *n=-0.203578994462286e2; break;
				case 12 : *I=-10; *J=10; *n=0.144369489909053e7; break;
				case 13 : *I=-10; *J=14; *n=-0.411254217946539e11; break;
				case 14 : *I=-8; *J=3; *n=0.623449786243773e-5; break;
				case 15 : *I=-8; *J=7; *n=-0.221774281146038e2; break;
				case 16 : *I=-8; *J=8; *n=-0.689315087933158e5; break;
				case 17 : *I=-8; *J=10; *n=-0.195419525060713e8; break;
				case 18 : *I=-6; *J=6; *n=0.316373510564015e4; break;
				case 19 : *I=-6; *J=8; *n=0.224040754426988e7; break;
				case 20 : *I=-5; *J=1; *n=-0.436701347922356e-5; break;
				case 21 : *I=-5; *J=2; *n=-0.404213852833996e-3; break;
				case 22 : *I=-5; *J=5; *n=-0.348153203414663e3; break;
				case 23 : *I=-5; *J=7; *n=-0.385294213555289e6; break;
				case 24 : *I=-4; *J=0; *n=0.135203700099403e-6; break;
				case 25 : *I=-4; *J=1; *n=0.134648383271089e-3; break;
				case 26 : *I=-4; *J=7; *n=0.125031835351736e6; break;
				case 27 : *I=-3; *J=2; *n=0.968123678455841e-1; break;
				case 28 : *I=-3; *J=4; *n=0.225660517512438e3; break;
				case 29 : *I=-2; *J=0; *n=-0.190102435341872e-3; break;
				case 30 : *I=-2; *J=1; *n=-0.299628410819229e-1; break;
				case 31 : *I=-1; *J=0; *n=0.500833915372121e-2; break;
				case 32 : *I=-1; *J=1; *n=0.387842482998411; break;
				case 33 : *I=-1; *J=5; *n=-0.138535367777182e4; break;
				case 34 : *I=0; *J=0; *n=0.870745245971773; break;
				case 35 : *I=0; *J=2; *n=0.171946252068742e1; break;
				case 36 : *I=1; *J=0; *n=-0.326650121426383e-1; break;
				case 37 : *I=1; *J=6; *n=0.498044171727877e4; break;
				case 38 : *I=3; *J=0; *n=0.551478022765087e-2; break;
			} break;
		}
		
		case region3e :
		{
			switch(i)
			{
				case 1 : *I=-12; *J=14; *n=0.715815808404721e9; break;
				case 2 : *I=-12; *J=16; *n=-0.114328360753449e12; break;
				case 3 : *I=-10; *J=3; *n=0.376531002015720e-11; break;
				case 4 : *I=-10; *J=6; *n=-0.903983668691157e-4; break;
				case 5 : *I=-10; *J=10; *n=0.665695908836252e6; break;
				case 6 : *I=-10; *J=14; *n=0.535364174960127e10; break;
				case 7 : *I=-10; *J=16; *n=0.794977402335603e11; break;
				case 8 : *I=-8; *J=7; *n=0.922230563421437e2; break;
				case 9 : *I=-8; *J=8; *n=-0.142586073991215e6; break;
				case 10 : *I=-8; *J=10; *n=-0.111796381424162e7; break;
				case 11 : *I=-6; *J=6; *n=0.896121629640760e4; break;
				case 12 : *I=-5; *J=6; *n=-0.669989239070491e4; break;
				case 13 : *I=-4; *J=2; *n=0.451242538486834e-2; break;
				case 14 : *I=-4; *J=4; *n=-0.339731325977713e2; break;
				case 15 : *I=-3; *J=2; *n=-0.120523111552278e1; break;
				case 16 : *I=-3; *J=6; *n=0.475992667717124e5; break;
				case 17 : *I=-3; *J=7; *n=-0.266627750390341e6; break;
				case 18 : *I=-2; *J=0; *n=-0.153314954386524e-3; break;
				case 19 : *I=-2; *J=1; *n=0.305638404828265; break;
				case 20 : *I=-2; *J=3; *n=0.123654999499486e3; break;
				case 21 : *I=-2; *J=4; *n=-0.104390794213011e4; break;
				case 22 : *I=-1; *J=0; *n=-0.157496516174308e-1; break;
				case 23 : *I=0; *J=0; *n=0.685331118940253; break;
				case 24 : *I=0; *J=1; *n=0.178373462873903e1; break;
				case 25 : *I=1; *J=0; *n=-0.544674124878910; break;
				case 26 : *I=1; *J=4; *n=0.204529931318843e4; break;
				case 27 : *I=1; *J=6; *n=-0.228342359328752e5; break;
				case 28 : *I=2; *J=0; *n=0.413197481515899; break;
				case 29 : *I=2; *J=2; *n=-0.341931835910405e2; break;
			} break;
		}
		
		case region3f :
		{
			switch(i)
			{
				case 1 : *I=0; *J=-3; *n=-0.251756547792325e-7; break;
				case 2 : *I=0; *J=-2; *n=0.601307193668763e-5; break;
				case 3 : *I=0; *J=-1; *n=-0.100615977450049e-2; break;
				case 4 : *I=0; *J=0; *n=0.999969140252192; break;
				case 5 : *I=0; *J=1; *n=0.214107759236486e1; break;
				case 6 : *I=0; *J=2; *n=-0.165175571959086e2; break;
				case 7 : *I=1; *J=-1; *n=-0.141987303638727e-2; break;
				case 8 : *I=1; *J=1; *n=0.269251915156554e1; break;
				case 9 : *I=1; *J=2; *n=0.349741815858722e2; break;
				case 10 : *I=1; *J=3; *n=-0.300208695771783e2; break;
				case 11 : *I=2; *J=0; *n=-0.131546288252539e1; break;
				case 12 : *I=2; *J=1; *n=-0.839091277286169e1; break;
				case 13 : *I=3; *J=-5; *n=0.181545608337015e-9; break;
				case 14 : *I=3; *J=-2; *n=-0.591099206478909e-3; break;
				case 15 : *I=3; *J=0; *n=0.152115067087106e1; break;
				case 16 : *I=4; *J=-3; *n=0.252956470663225e-4; break;
				case 17 : *I=5; *J=-8; *n=0.100726265203786e-14; break;
				case 18 : *I=5; *J=1; *n=-0.149774533860650e1; break;
				case 19 : *I=6; *J=-6; *n=-0.793940970562969e-9; break;
				case 20 : *I=7; *J=-4; *n=-0.150290891264717e-3; break;
				case 21 : *I=7; *J=1; *n=0.151205531275133e1; break;
				case 22 : *I=10; *J=-6; *n=0.470942606221652e-5; break;
				case 23 : *I=12; *J=-10; *n=0.195049710391712e-12; break;
				case 24 : *I=12; *J=-8; *n=-0.911627886266077e-8; break;
				case 25 : *I=12; *J=-4; *n=0.604374640201265e-3; break;
				case 26 : *I=14; *J=-12; *n=-0.225132933900136e-15; break;
				case 27 : *I=14; *J=-10; *n=0.610916973582981e-11; break;
				case 28 : *I=14; *J=-8; *n=-0.303063908043404e-6; break;
				case 29 : *I=14; *J=-6; *n=-0.137796070798409e-4; break;
				case 30 : *I=14; *J=-4; *n=-0.919296736666106e-3; break;
				case 31 : *I=16; *J=-10; *n=0.639288223132545e-9; break;
				case 32 : *I=16; *J=-8; *n=0.753259479898699e-6; break;
				case 33 : *I=18; *J=-12; *n=-0.400321478682929e-12; break;
				case 34 : *I=18; *J=-10; *n=0.756140294351614e-8; break;
				case 35 : *I=20; *J=-12; *n=-0.912082054034891e-11; break;
				case 36 : *I=20; *J=-10; *n=-0.237612381140539e-7; break;
				case 37 : *I=20; *J=-6; *n=0.269586010591874e-4; break;
				case 38 : *I=22; *J=-12; *n=-0.732828135157839e-10; break;
				case 39 : *I=24; *J=-12; *n=0.241995578306660e-9; break;
				case 40 : *I=24; *J=-4; *n=-0.405735532730322e-3; break;
				case 41 : *I=28; *J=-12; *n=0.189424143498011e-9; break;
				case 42 : *I=32; *J=-12; *n=-0.486632965074563e-9; break;
			} break;
		}
		
		case region3g :
		{
			switch(i)
			{
				case 1 : *I=-12; *J=7; *n=0.412209020652996e-4; break;
				case 2 : *I=-12; *J=12; *n=-0.114987238280587e7; break;
				case 3 : *I=-12; *J=14; *n=0.948180885032080e10; break;
				case 4 : *I=-12; *J=18; *n=-0.195788865718971e18; break;
				case 5 : *I=-12; *J=22; *n=0.496250704871300e25; break;
				case 6 : *I=-12; *J=24; *n=-0.105549884548496e29; break;
				case 7 : *I=-10; *J=14; *n=-0.758642165988278e12; break;
				case 8 : *I=-10; *J=20; *n=-0.922172769596101e23; break;
				case 9 : *I=-10; *J=24; *n=0.725379072059348e30; break;
				case 10 : *I=-8; *J=7; *n=-0.617718249205859e2; break;
				case 11 : *I=-8; *J=8; *n=0.107555033344858e5; break;
				case 12 : *I=-8; *J=10; *n=-0.379545802336487e8; break;
				case 13 : *I=-8; *J=12; *n=0.228646846221831e12; break;
				case 14 : *I=-6; *J=8; *n=-0.499741093010619e7; break;
				case 15 : *I=-6; *J=22; *n=-0.280214310054101e31; break;
				case 16 : *I=-5; *J=7; *n=0.104915406769586e7; break;
				case 17 : *I=-5; *J=20; *n=0.613754229168619e28; break;
				case 18 : *I=-4; *J=22; *n=0.802056715528378e32; break;
				case 19 : *I=-3; *J=7; *n=-0.298617819828065e8; break;
				case 20 : *I=-2; *J=3; *n=-0.910782540134681e2; break;
				case 21 : *I=-2; *J=5; *n=0.135033227281565e6; break;
				case 22 : *I=-2; *J=14; *n=-0.712949383408211e19; break;
				case 23 : *I=-2; *J=24; *n=-0.104578785289542e37; break;
				case 24 : *I=-1; *J=2; *n=0.304331584444093e2; break;
				case 25 : *I=-1; *J=8; *n=0.593250797959445e10; break;
				case 26 : *I=-1; *J=18; *n=-0.364174062110798e28; break;
				case 27 : *I=0; *J=0; *n=0.921791403532461; break;
				case 28 : *I=0; *J=1; *n=-0.337693609657471; break;
				case 29 : *I=0; *J=2; *n=-0.724644143758508e2; break;
				case 30 : *I=1; *J=0; *n=-0.110480239272601; break;
				case 31 : *I=1; *J=1; *n=0.536516031875059e1; break;
				case 32 : *I=1; *J=3; *n=-0.291441872156205e4; break;
				case 33 : *I=3; *J=24; *n=0.616338176535305e40; break;
				case 34 : *I=5; *J=22; *n=-0.120889175861180e39; break;
				case 35 : *I=6; *J=12; *n=0.818396024524612e23; break;
				case 36 : *I=8; *J=3; *n=0.940781944835829e9; break;
				case 37 : *I=10; *J=0; *n=-0.367279669545448e5; break;
				case 38 : *I=10; *J=6; *n=-0.837513931798655e16; break;
			} break;
		}
		
		case region3h :
		{
			switch(i)
			{
				case 1 : *I=-12; *J=8; *n=0.561379678887577e-1; break;
				case 2 : *I=-12; *J=12; *n=0.774135421587083e10; break;
				case 3 : *I=-10; *J=4; *n=0.111482975877938e-8; break;
				case 4 : *I=-10; *J=6; *n=-0.143987128208183e-2; break;
				case 5 : *I=-10; *J=8; *n=0.193696558764920e4; break;
				case 6 : *I=-10; *J=10; *n=-0.605971823585005e9; break;
				case 7 : *I=-10; *J=14; *n=0.171951568124337e14; break;
				case 8 : *I=-10; *J=16; *n=-0.185461154985145e17; break;
				case 9 : *I=-8; *J=0; *n=0.387851168078010e-16; break;
				case 10 : *I=-8; *J=1; *n=-0.395464327846105e-13; break;
				case 11 : *I=-8; *J=6; *n=-0.170875935679023e3; break;
				case 12 : *I=-8; *J=7; *n=-0.212010620701220e4; break;
				case 13 : *I=-8; *J=8; *n=0.177683337348191e8; break;
				case 14 : *I=-6; *J=4; *n=0.110177443629575e2; break;
				case 15 : *I=-6; *J=6; *n=-0.234396091693313e6; break;
				case 16 : *I=-6; *J=8; *n=-0.656174421999594e7; break;
				case 17 : *I=-5; *J=2; *n=0.156362212977396e-4; break;
				case 18 : *I=-5; *J=3; *n=-0.212946257021400e1; break;
				case 19 : *I=-5; *J=4; *n=0.135249306374858e2; break;
				case 20 : *I=-4; *J=2; *n=0.177189164145813; break;
				case 21 : *I=-4; *J=4; *n=0.139499167345464e4; break;
				case 22 : *I=-3; *J=1; *n=-0.703670932036388e-2; break;
				case 23 : *I=-3; *J=2; *n=-0.152011044389648; break;
				case 24 : *I=-2; *J=0; *n=0.981916922991113e-4; break;
				case 25 : *I=-1; *J=0; *n=0.147199658618076e-2; break;
				case 26 : *I=-1; *J=2; *n=0.202618487025578e2; break;
				case 27 : *I=0; *J=0; *n=0.899345518944240; break;
				case 28 : *I=1; *J=0; *n=-0.211346402240858; break;
				case 29 : *I=1; *J=2; *n=0.249971752957491e2; break;
			} break;
		}
		
		case region3i :
		{
			switch(i)
			{
				case 1 : *I=0; *J=0; *n=0.106905684359136e1; break;
				case 2 : *I=0; *J=1; *n=-0.148620857922333e1; break;
				case 3 : *I=0; *J=10; *n=0.259862256980408e15; break;
				case 4 : *I=1; *J=-4; *n=-0.446352055678749e-11; break;
				case 5 : *I=1; *J=-2; *n=-0.566620757170032e-6; break;
				case 6 : *I=1; *J=-1; *n=-0.235302885736849e-2; break;
				case 7 : *I=1; *J=0; *n=-0.269226321968839; break;
				case 8 : *I=2; *J=0; *n=0.922024992944392e1; break;
				case 9 : *I=3; *J=-5; *n=0.357633505503772e-11; break;
				case 10 : *I=3; *J=0; *n=-0.173942565562222e2; break;
				case 11 : *I=4; *J=-3; *n=0.700681785556229e-5; break;
				case 12 : *I=4; *J=-2; *n=-0.267050351075768e-3; break;
				case 13 : *I=4; *J=-1; *n=-0.231779669675624e1; break;
				case 14 : *I=5; *J=-6; *n=-0.753533046979752e-12; break;
				case 15 : *I=5; *J=-1; *n=0.481337131452891e1; break;
				case 16 : *I=5; *J=12; *n=-0.223286270422356e22; break;
				case 17 : *I=7; *J=-4; *n=-0.118746004987383e-4; break;
				case 18 : *I=7; *J=-3; *n=0.646412934136496e-2; break;
				case 19 : *I=8; *J=-6; *n=-0.410588536330937e-9; break;
				case 20 : *I=8; *J=10; *n=0.422739537057241e20; break;
				case 21 : *I=10; *J=-8; *n=0.313698180473812e-12; break;
				case 22 : *I=12; *J=-12; *n=0.164395334345040e-23; break;
				case 23 : *I=12; *J=-6; *n=-0.339823323754373e-5; break;
				case 24 : *I=12; *J=-4; *n=-0.135268639905021e-1; break;
				case 25 : *I=14; *J=-10; *n=-0.723252514211625e-14; break;
				case 26 : *I=14; *J=-8; *n=0.184386437538366e-8; break;
				case 27 : *I=14; *J=-4; *n=-0.463959533752385e-1; break;
				case 28 : *I=14; *J=5; *n=-0.992263100376750e14; break;
				case 29 : *I=18; *J=-12; *n=0.688169154439335e-16; break;
				case 30 : *I=18; *J=-10; *n=-0.222620998452197e-10; break;
				case 31 : *I=18; *J=-8; *n=-0.540843018624083e-7; break;
				case 32 : *I=18; *J=-6; *n=0.345570606200257e-2; break;
				case 33 : *I=18; *J=2; *n=0.422275800304086e11; break;
				case 34 : *I=20; *J=-12; *n=-0.126974478770487e-14; break;
				case 35 : *I=20; *J=-10; *n=0.927237985153679e-9; break;
				case 36 : *I=22; *J=-12; *n=0.612670812016489e-13; break;
				case 37 : *I=24; *J=-12; *n=-0.722693924063497e-11; break;
				case 38 : *I=24; *J=-8; *n=-0.383669502636822e-3; break;
				case 39 : *I=32; *J=-10; *n=0.374684572410204e-3; break;
				case 40 : *I=32; *J=-5; *n=-0.931976897511086e5; break;
				case 41 : *I=36; *J=-10; *n=-0.247690616026922e-1; break;
				case 42 : *I=36; *J=-8; *n=0.658110546759474e2; break;
			} break;
		}
		
		case region3j :
		{
			switch(i)
			{
				case 1 : *I=0; *J=-1; *n=-0.111371317395540e-3; break;
				case 2 : *I=0; *J=0; *n=0.100342892423685e1; break;
				case 3 : *I=0; *J=1; *n=0.530615581928979e1; break;
				case 4 : *I=1; *J=-2; *n=0.179058760078792e-5; break;
				case 5 : *I=1; *J=-1; *n=-0.728541958464774e-3; break;
				case 6 : *I=1; *J=1; *n=-0.187576133371704e2; break;
				case 7 : *I=2; *J=-1; *n=0.199060874071849e-2; break;
				case 8 : *I=2; *J=1; *n=0.243574755377290e2; break;
				case 9 : *I=3; *J=-2; *n=-0.177040785499444e-3; break;
				case 10 : *I=4; *J=-2; *n=-0.259680385227130e-2; break;
				case 11 : *I=4; *J=2; *n=-0.198704578406823e3; break;
				case 12 : *I=5; *J=-3; *n=0.738627790224287e-4; break;
				case 13 : *I=5; *J=-2; *n=-0.236264692844138e-2; break;
				case 14 : *I=5; *J=0; *n=-0.161023121314333e1; break;
				case 15 : *I=6; *J=3; *n=0.622322971786473e4; break;
				case 16 : *I=10; *J=-6; *n=-0.960754116701669e-8; break;
				case 17 : *I=12; *J=-8; *n=-0.510572269720488e-10; break;
				case 18 : *I=12; *J=-3; *n=0.767373781404211e-2; break;
				case 19 : *I=14; *J=-10; *n=0.663855469485254e-14; break;
				case 20 : *I=14; *J=-8; *n=-0.717590735526745e-9; break;
				case 21 : *I=14; *J=-5; *n=0.146564542926508e-4; break;
				case 22 : *I=16; *J=-10; *n=0.309029474277013e-11; break;
				case 23 : *I=18; *J=-12; *n=-0.464216300971708e-15; break;
				case 24 : *I=20; *J=-12; *n=-0.390499637961161e-13; break;
				case 25 : *I=20; *J=-10; *n=-0.236716126781431e-9; break;
				case 26 : *I=24; *J=-12; *n=0.454652854268717e-11; break;
				case 27 : *I=24; *J=-6; *n=-0.422271787482497e-2; break;
				case 28 : *I=28; *J=-12; *n=0.283911742354706e-10; break;
				case 29 : *I=28; *J=-5; *n=0.270929002720228e1; break;
			} break;
		}
		
		case region3k :
		{
			switch(i)
			{
				case 1 : *I=-2; *J=10; *n=-0.401215699576099e9; break;
				case 2 : *I=-2; *J=12; *n=0.484501478318406e11; break;
				case 3 : *I=-1; *J=-5; *n=0.394721471363678e-14; break;
				case 4 : *I=-1; *J=6; *n=0.372629967374147e5; break;
				case 5 : *I=0; *J=-12; *n=-0.369794374168666e-29; break;
				case 6 : *I=0; *J=-6; *n=-0.380436407012452e-14; break;
				case 7 : *I=0; *J=-2; *n=0.475361629970233e-6; break;
				case 8 : *I=0; *J=-1; *n=-0.879148916140706e-3; break;
				case 9 : *I=0; *J=0; *n=0.844317863844331; break;
				case 10 : *I=0; *J=1; *n=0.122433162656600e2; break;
				case 11 : *I=0; *J=2; *n=-0.104529634830279e3; break;
				case 12 : *I=0; *J=3; *n=0.589702771277429e3; break;
				case 13 : *I=0; *J=14; *n=-0.291026851164444e14; break;
				case 14 : *I=1; *J=-3; *n=0.170343072841850e-5; break;
				case 15 : *I=1; *J=-2; *n=-0.277617606975748e-3; break;
				case 16 : *I=1; *J=0; *n=-0.344709605486686e1; break;
				case 17 : *I=1; *J=1; *n=0.221333862447095e2; break;
				case 18 : *I=1; *J=2; *n=-0.194646110037079e3; break;
				case 19 : *I=2; *J=-8; *n=0.808354639772825e-15; break;
				case 20 : *I=2; *J=-6; *n=-0.180845209145470e-10; break;
				case 21 : *I=2; *J=-3; *n=-0.696664158132412e-5; break;
				case 22 : *I=2; *J=-2; *n=-0.181057560300994e-2; break;
				case 23 : *I=2; *J=0; *n=0.255830298579027e1; break;
				case 24 : *I=2; *J=4; *n=0.328913873658481e4; break;
				case 25 : *I=5; *J=-12; *n=-0.173270241249904e-18; break;
				case 26 : *I=5; *J=-6; *n=-0.661876792558034e-6; break;
				case 27 : *I=5; *J=-3; *n=-0.395688923421250e-2; break;
				case 28 : *I=6; *J=-12; *n=0.604203299819132e-17; break;
				case 29 : *I=6; *J=-10; *n=-0.400879935920517e-13; break;
				case 30 : *I=6; *J=-8; *n=0.160751107464958e-8; break;
				case 31 : *I=6; *J=-5; *n=0.383719409025556e-4; break;
				case 32 : *I=8; *J=-12; *n=-0.649565446702457e-14; break;
				case 33 : *I=10; *J=-12; *n=-0.149095328506000e-11; break;
				case 34 : *I=12; *J=-10; *n=0.541449377329581e-8; break;
			} break;
		}
		
		case region3l :
		{
			switch(i)
			{
				case 1 : *I=-12; *J=14; *n=0.260702058647537e10; break;
				case 2 : *I=-12; *J=16; *n=-0.188277213604704e15; break;
				case 3 : *I=-12; *J=18; *n=0.554923870289667e19; break;
				case 4 : *I=-12; *J=20; *n=-0.758966946387758e23; break;
				case 5 : *I=-12; *J=22; *n=0.413865186848908e27; break;
				case 6 : *I=-10; *J=14; *n=-0.815038000738060e12; break;
				case 7 : *I=-10; *J=24; *n=-0.381458260489955e33; break;
				case 8 : *I=-8; *J=6; *n=-0.123239564600519e-1; break;
				case 9 : *I=-8; *J=10; *n=0.226095631437174e8; break;
				case 10 : *I=-8; *J=12; *n=-0.495017809506720e12; break;
				case 11 : *I=-8; *J=14; *n=0.529482996422863e16; break;
				case 12 : *I=-8; *J=18; *n=-0.444359478746295e23; break;
				case 13 : *I=-8; *J=24; *n=0.521635864527315e35; break;
				case 14 : *I=-8; *J=36; *n=-0.487095672740742e55; break;
				case 15 : *I=-6; *J=8; *n=-0.714430209937547e6; break;
				case 16 : *I=-5; *J=4; *n=0.127868634615495; break;
				case 17 : *I=-5; *J=5; *n=-0.100752127917598e2; break;
				case 18 : *I=-4; *J=7; *n=0.777451437960990e7; break;
				case 19 : *I=-4; *J=16; *n=-0.108105480796471e25; break;
				case 20 : *I=-3; *J=1; *n=-0.357578581169659e-5; break;
				case 21 : *I=-3; *J=3; *n=-0.212857169423484e1; break;
				case 22 : *I=-3; *J=18; *n=0.270706111085238e30; break;
				case 23 : *I=-3; *J=20; *n=-0.695953622348829e33; break;
				case 24 : *I=-2; *J=2; *n=0.110609027472280; break;
				case 25 : *I=-2; *J=3; *n=0.721559163361354e2; break;
				case 26 : *I=-2; *J=10; *n=-0.306367307532219e15; break;
				case 27 : *I=-1; *J=0; *n=0.265839618885530e-4; break;
				case 28 : *I=-1; *J=1; *n=0.253392392889754e-1; break;
				case 29 : *I=-1; *J=3; *n=-0.214443041836579e3; break;
				case 30 : *I=0; *J=0; *n=0.937846601489667; break;
				case 31 : *I=0; *J=1; *n=0.223184043101700e1; break;
				case 32 : *I=0; *J=2; *n=0.338401222509191e2; break;
				case 33 : *I=0; *J=12; *n=0.494237237179718e21; break;
				case 34 : *I=1; *J=0; *n=-0.198068404154428; break;
				case 35 : *I=1; *J=16; *n=-0.141415349881140e31; break;
				case 36 : *I=2; *J=1; *n=-0.993862421613651e2; break;
				case 37 : *I=4; *J=0; *n=0.125070534142731e3; break;
				case 38 : *I=5; *J=0; *n=-0.996473529004439e3; break;
				case 39 : *I=5; *J=1; *n=0.473137909872765e5; break;
				case 40 : *I=6; *J=14; *n=0.116662121219322e33; break;
				case 41 : *I=10; *J=4; *n=-0.315874976271533e16; break;
				case 42 : *I=10; *J=12; *n=-0.445703369196945e33; break;
				case 43 : *I=14; *J=10; *n=0.642794932373694e33; break;
			} break;
		}
		
		case region3m :
		{
			switch(i)
			{
				case 1 : *I=0; *J=0; *n=0.811384363481847; break;
				case 2 : *I=3; *J=0; *n=-0.568199310990094e4; break;
				case 3 : *I=8; *J=0; *n=-0.178657198172556e11; break;
				case 4 : *I=20; *J=2; *n=0.795537657613427e32; break;
				case 5 : *I=1; *J=5; *n=-0.814568209346872e5; break;
				case 6 : *I=3; *J=5; *n=-0.659774567602874e8; break;
				case 7 : *I=4; *J=5; *n=-0.152861148659302e11; break;
				case 8 : *I=5; *J=5; *n=-0.560165667510446e12; break;
				case 9 : *I=1; *J=6; *n=0.458384828593949e6; break;
				case 10 : *I=6; *J=6; *n=-0.385754000383848e14; break;
				case 11 : *I=2; *J=7; *n=0.453735800004273e8; break;
				case 12 : *I=4; *J=8; *n=0.939454935735563e12; break;
				case 13 : *I=14; *J=8; *n=0.266572856432938e28; break;
				case 14 : *I=2; *J=10; *n=-0.547578313899097e10; break;
				case 15 : *I=5; *J=10; *n=0.200725701112386e15; break;
				case 16 : *I=3; *J=12; *n=0.185007245563239e13; break;
				case 17 : *I=0; *J=14; *n=0.185135446828337e9; break;
				case 18 : *I=1; *J=14; *n=-0.170451090076385e12; break;
				case 19 : *I=1; *J=18; *n=0.157890366037614e15; break;
				case 20 : *I=1; *J=20; *n=-0.202530509748774e16; break;
				case 21 : *I=28; *J=20; *n=0.368193926183570e60; break;
				case 22 : *I=2; *J=22; *n=0.170215539458936e18; break;
				case 23 : *I=16; *J=22; *n=0.639234909918741e42; break;
				case 24 : *I=0; *J=24; *n=-0.821698160721956e15; break;
				case 25 : *I=5; *J=24; *n=-0.795260241872306e24; break;
				case 26 : *I=0; *J=28; *n=0.233415869478510e18; break;
				case 27 : *I=3; *J=28; *n=-0.600079934586803e23; break;
				case 28 : *I=4; *J=28; *n=0.594584382273384e25; break;
				case 29 : *I=12; *J=28; *n=0.189461279349492e40; break;
				case 30 : *I=16; *J=28; *n=-0.810093428842645e46; break;
				case 31 : *I=1; *J=32; *n=0.188813911076809e22; break;
				case 32 : *I=8; *J=32; *n=0.111052244098768e36; break;
				case 33 : *I=14; *J=32; *n=0.291133958602503e46; break;
				case 34 : *I=0; *J=36; *n=-0.329421923951460e22; break;
				case 35 : *I=2; *J=36; *n=-0.137570282536696e26; break;
				case 36 : *I=3; *J=36; *n=0.181508996303902e28; break;
				case 37 : *I=4; *J=36; *n=-0.346865122768353e30; break;
				case 38 : *I=8; *J=36; *n=-0.211961148774260e38; break;
				case 39 : *I=14; *J=36; *n=-0.128617899887675e49; break;
				case 40 : *I=24; *J=36; *n=0.479817895699239e65; break;
			} break;
		}
		
		case region3n :
		{
			switch(i)
			{
				case 1 : *I=0; *J=-12; *n=0.280967799943151e-38; break;
				case 2 : *I=3; *J=-12; *n=0.614869006573609e-30; break;
				case 3 : *I=4; *J=-12; *n=0.582238667048942e-27; break;
				case 4 : *I=6; *J=-12; *n=0.390628369238462e-22; break;
				case 5 : *I=7; *J=-12; *n=0.821445758255119e-20; break;
				case 6 : *I=10; *J=-12; *n=0.402137961842776e-14; break;
				case 7 : *I=12; *J=-12; *n=0.651718171878301e-12; break;
				case 8 : *I=14; *J=-12; *n=-0.211773355803058e-7; break;
				case 9 : *I=18; *J=-12; *n=0.264953354380072e-2; break;
				case 10 : *I=0; *J=-10; *n=-0.135031446451331e-31; break;
				case 11 : *I=3; *J=-10; *n=-0.607246643970893e-23; break;
				case 12 : *I=5; *J=-10; *n=-0.402352115234494e-18; break;
				case 13 : *I=6; *J=-10; *n=-0.744938506925544e-16; break;
				case 14 : *I=8; *J=-10; *n=0.189917206526237e-12; break;
				case 15 : *I=12; *J=-10; *n=0.364975183508473e-5; break;
				case 16 : *I=0; *J=-8; *n=0.177274872361946e-25; break;
				case 17 : *I=3; *J=-8; *n=-0.334952758812999e-18; break;
				case 18 : *I=7; *J=-8; *n=-0.421537726098389e-8; break;
				case 19 : *I=12; *J=-8; *n=-0.391048167929649e-1; break;
				case 20 : *I=2; *J=-6; *n=0.541276911564176e-13; break;
				case 21 : *I=3; *J=-6; *n=0.705412100773699e-11; break;
				case 22 : *I=4; *J=-6; *n=0.258585887897486e-8; break;
				case 23 : *I=2; *J=-5; *n=-0.493111362030162e-10; break;
				case 24 : *I=4; *J=-5; *n=-0.158649699894543e-5; break;
				case 25 : *I=7; *J=-5; *n=-0.525037427886100; break;
				case 26 : *I=4; *J=-4; *n=0.220019901729615e-2; break;
				case 27 : *I=3; *J=-3; *n=-0.643064132636925e-2; break;
				case 28 : *I=5; *J=-3; *n=0.629154149015048e2; break;
				case 29 : *I=6; *J=-3; *n=0.135147318617061e3; break;
				case 30 : *I=0; *J=-2; *n=0.240560808321713e-6; break;
				case 31 : *I=0; *J=-1; *n=-0.890763306701305e-3; break;
				case 32 : *I=3; *J=-1; *n=-0.440209599407714e4; break;
				case 33 : *I=1; *J=0; *n=-0.302807107747776e3; break;
				case 34 : *I=0; *J=1; *n=0.159158748314599e4; break;
				case 35 : *I=1; *J=1; *n=0.232534272709876e6; break;
				case 36 : *I=0; *J=2; *n=-0.792681207132600e6; break;
				case 37 : *I=1; *J=4; *n=-0.869871364662769e11; break;
				case 38 : *I=0; *J=5; *n=0.354542769185671e12; break;
				case 39 : *I=1; *J=6; *n=0.400849240129329e15; break;
			} break;
		}
		
		case region3o :
		{
			switch(i)
			{
				case 1 : *I=0; *J=-12; *n=0.128746023979718e-34; break;
				case 2 : *I=0; *J=-4; *n=-0.735234770382342e-11; break;
				case 3 : *I=0; *J=-1; *n=0.289078692149150e-2; break;
				case 4 : *I=2; *J=-1; *n=0.244482731907223; break;
				case 5 : *I=3; *J=-10; *n=0.141733492030985e-23; break;
				case 6 : *I=4; *J=-12; *n=-0.354533853059476e-28; break;
				case 7 : *I=4; *J=-8; *n=-0.594539202901431e-17; break;
				case 8 : *I=4; *J=-5; *n=-0.585188401782779e-8; break;
				case 9 : *I=4; *J=-4; *n=0.201377325411803e-5; break;
				case 10 : *I=4; *J=-1; *n=0.138647388209306e1; break;
				case 11 : *I=5; *J=-4; *n=-0.173959365084772e-4; break;
				case 12 : *I=5; *J=-3; *n=0.137680878349369e-2; break;
				case 13 : *I=6; *J=-8; *n=0.814897605805513e-14; break;
				case 14 : *I=7; *J=-12; *n=0.425596631351839e-25; break;
				case 15 : *I=8; *J=-10; *n=-0.387449113787755e-17; break;
				case 16 : *I=8; *J=-8; *n=0.139814747930240e-12; break;
				case 17 : *I=8; *J=-4; *n=-0.171849638951521e-2; break;
				case 18 : *I=10; *J=-12; *n=0.641890529513296e-21; break;
				case 19 : *I=10; *J=-8; *n=0.118960578072018e-10; break;
				case 20 : *I=14; *J=-12; *n=-0.155282762571611e-17; break;
				case 21 : *I=14; *J=-8; *n=0.233907907347507e-7; break;
				case 22 : *I=20; *J=-12; *n=-0.174093247766213e-12; break;
				case 23 : *I=20; *J=-10; *n=0.377682649089149e-8; break;
				case 24 : *I=24; *J=-12; *n=-0.516720236575302e-10; break;
			} break;
		}
		
		case region3p :
		{
			switch(i)
			{
				case 1 : *I=0; *J=-1; *n=-0.982825342010366e-4; break;
				case 2 : *I=0; *J=0; *n=0.105145700850612e1; break;
				case 3 : *I=0; *J=1; *n=0.116033094095084e3; break;
				case 4 : *I=0; *J=2; *n=0.324664750281543e4; break;
				case 5 : *I=1; *J=1; *n=-0.123592348610137e4; break;
				case 6 : *I=2; *J=-1; *n=-0.561403450013495e-1; break;
				case 7 : *I=3; *J=-3; *n=0.856677401640869e-7; break;
				case 8 : *I=3; *J=0; *n=0.236313425393924e3; break;
				case 9 : *I=4; *J=-2; *n=0.972503292350109e-2; break;
				case 10 : *I=6; *J=-2; *n=-0.103001994531927e1; break;
				case 11 : *I=7; *J=-5; *n=-0.149653706199162e-8; break;
				case 12 : *I=7; *J=-4; *n=-0.215743778861592e-4; break;
				case 13 : *I=8; *J=-2; *n=-0.834452198291445e1; break;
				case 14 : *I=10; *J=-3; *n=0.586602660564988; break;
				case 15 : *I=12; *J=-12; *n=0.343480022104968e-25; break;
				case 16 : *I=12; *J=-6; *n=0.816256095947021e-5; break;
				case 17 : *I=12; *J=-5; *n=0.294985697916798e-2; break;
				case 18 : *I=14; *J=-10; *n=0.711730466276584e-16; break;
				case 19 : *I=14; *J=-8; *n=0.400954763806941e-9; break;
				case 20 : *I=14; *J=-3; *n=0.107766027032853e2; break;
				case 21 : *I=16; *J=-8; *n=-0.409449599138182e-6; break;
				case 22 : *I=18; *J=-8; *n=-0.729121307758902e-5; break;
				case 23 : *I=20; *J=-10; *n=0.677107970938909e-8; break;
				case 24 : *I=22; *J=-10; *n=0.602745973022975e-7; break;
				case 25 : *I=24; *J=-12; *n=-0.382323011855257e-10; break;
				case 26 : *I=24; *J=-8; *n=0.179946628317437e-2; break;
				case 27 : *I=36; *J=-12; *n=-0.345042834640005e-3; break;
			} break;
		}
		
		case region3q :
		{
			switch(i)
			{
				case 1 : *I=-12; *J=10; *n=-0.820433843259950e5; break;
				case 2 : *I=-12; *J=12; *n=0.473271518461586e11; break;
				case 3 : *I=-10; *J=6; *n=-0.805950021005413e-1; break;
				case 4 : *I=-10; *J=7; *n=0.328600025435980e2; break;
				case 5 : *I=-10; *J=8; *n=-0.356617029982490e4; break;
				case 6 : *I=-10; *J=10; *n=-0.172985781433335e10; break;
				case 7 : *I=-8; *J=8; *n=0.351769232729192e8; break;
				case 8 : *I=-6; *J=6; *n=-0.775489259985144e6; break;
				case 9 : *I=-5; *J=2; *n=0.710346691966018e-4; break;
				case 10 : *I=-5; *J=5; *n=0.993499883820274e5; break;
				case 11 : *I=-4; *J=3; *n=-0.642094171904570; break;
				case 12 : *I=-4; *J=4; *n=-0.612842816820083e4; break;
				case 13 : *I=-3; *J=3; *n=0.232808472983776e3; break;
				case 14 : *I=-2; *J=0; *n=-0.142808220416837e-4; break;
				case 15 : *I=-2; *J=1; *n=-0.643596060678456e-2; break;
				case 16 : *I=-2; *J=2; *n=-0.428577227475614e1; break;
				case 17 : *I=-2; *J=4; *n=0.225689939161918e4; break;
				case 18 : *I=-1; *J=0; *n=0.100355651721510e-2; break;
				case 19 : *I=-1; *J=1; *n=0.333491455143516; break;
				case 20 : *I=-1; *J=2; *n=0.109697576888873e1; break;
				case 21 : *I=0; *J=0; *n=0.961917379376452; break;
				case 22 : *I=1; *J=0; *n=-0.838165632204598e-1; break;
				case 23 : *I=1; *J=1; *n=0.247795908411492e1; break;
				case 24 : *I=1; *J=3; *n=-0.319114969006533e4; break;
			} break;
		}
		
		case region3r :
		{
			switch(i)
			{
				case 1 : *I=-8; *J=6; *n=0.144165955660863e-2; break;
				case 2 : *I=-8; *J=14; *n=-0.701438599628258e13; break;
				case 3 : *I=-3; *J=-3; *n=-0.830946716459219e-16; break;
				case 4 : *I=-3; *J=3; *n=0.261975135368109; break;
				case 5 : *I=-3; *J=4; *n=0.393097214706245e3; break;
				case 6 : *I=-3; *J=5; *n=-0.104334030654021e5; break;
				case 7 : *I=-3; *J=8; *n=0.490112654154211e9; break;
				case 8 : *I=0; *J=-1; *n=-0.147104222772069e-3; break;
				case 9 : *I=0; *J=0; *n=0.103602748043408e1; break;
				case 10 : *I=0; *J=1; *n=0.305308890065089e1; break;
				case 11 : *I=0; *J=5; *n=-0.399745276971264e7; break;
				case 12 : *I=3; *J=-6; *n=0.569233719593750e-11; break;
				case 13 : *I=3; *J=-2; *n=-0.464923504407778e-1; break;
				case 14 : *I=8; *J=-12; *n=-0.535400396512906e-17; break;
				case 15 : *I=8; *J=-10; *n=0.399988795693162e-12; break;
				case 16 : *I=8; *J=-8; *n=-0.536479560201811e-6; break;
				case 17 : *I=8; *J=-5; *n=0.159536722411202e-1; break;
				case 18 : *I=10; *J=-12; *n=0.270303248860217e-14; break;
				case 19 : *I=10; *J=-10; *n=0.244247453858506e-7; break;
				case 20 : *I=10; *J=-8; *n=-0.983430636716454e-5; break;
				case 21 : *I=10; *J=-6; *n=0.663513144224454e-1; break;
				case 22 : *I=10; *J=-5; *n=-0.993456957845006e1; break;
				case 23 : *I=10; *J=-4; *n=0.546491323528491e3; break;
				case 24 : *I=10; *J=-3; *n=-0.143365406393758e5; break;
				case 25 : *I=10; *J=-2; *n=0.150764974125511e6; break;
				case 26 : *I=12; *J=-12; *n=-0.337209709340105e-9; break;
				case 27 : *I=14; *J=-12; *n=0.377501980025469e-8; break;
			} break;
		}
		
		case region3s :
		{
			switch(i)
			{
				case 1 : *I=-12; *J=20; *n=-0.532466612140254e23; break;
				case 2 : *I=-12; *J=24; *n=0.100415480000824e32; break;
				case 3 : *I=-10; *J=22; *n=-0.191540001821367e30; break;
				case 4 : *I=-8; *J=14; *n=0.105618377808847e17; break;
				case 5 : *I=-6; *J=36; *n=0.202281884477061e59; break;
				case 6 : *I=-5; *J=8; *n=0.884585472596134e8; break;
				case 7 : *I=-5; *J=16; *n=0.166540181638363e23; break;
				case 8 : *I=-4; *J=6; *n=-0.313563197669111e6; break;
				case 9 : *I=-4; *J=32; *n=-0.185662327545324e54; break;
				case 10 : *I=-3; *J=3; *n=-0.624942093918942e-1; break;
				case 11 : *I=-3; *J=8; *n=-0.504160724132590e10; break;
				case 12 : *I=-2; *J=4; *n=0.187514491833092e5; break;
				case 13 : *I=-1; *J=1; *n=0.121399979993217e-2; break;
				case 14 : *I=-1; *J=2; *n=0.188317043049455e1; break;
				case 15 : *I=-1; *J=3; *n=-0.167073503962060e4; break;
				case 16 : *I=0; *J=0; *n=0.965961650599775; break;
				case 17 : *I=0; *J=1; *n=0.294885696802488e1; break;
				case 18 : *I=0; *J=4; *n=-0.653915627346115e5; break;
				case 19 : *I=0; *J=28; *n=0.604012200163444e50; break;
				case 20 : *I=1; *J=0; *n=-0.198339358557937; break;
				case 21 : *I=1; *J=32; *n=-0.175984090163501e58; break;
				case 22 : *I=3; *J=0; *n=0.356314881403987e1; break;
				case 23 : *I=3; *J=1; *n=-0.575991255144384e3; break;
				case 24 : *I=3; *J=2; *n=0.456213415338071e5; break;
				case 25 : *I=4; *J=3; *n=-0.109174044987829e8; break;
				case 26 : *I=4; *J=18; *n=0.437796099975134e34; break;
				case 27 : *I=4; *J=24; *n=-0.616552611135792e46; break;
				case 28 : *I=5; *J=4; *n=0.193568768917797e10; break;
				case 29 : *I=14; *J=24; *n=0.950898170425042e54; break;
			} break;
		}
		
		case region3t :
		{
			switch(i)
			{
				case 1 : *I=0; *J=0; *n=0.155287249586268e1; break;
				case 2 : *I=0; *J=1; *n=0.664235115009031e1; break;
				case 3 : *I=0; *J=4; *n=-0.289366236727210e4; break;
				case 4 : *I=0; *J=12; *n=-0.385923202309848e13; break;
				case 5 : *I=1; *J=0; *n=-0.291002915783761e1; break;
				case 6 : *I=1; *J=10; *n=-0.829088246858083e12; break;
				case 7 : *I=2; *J=0; *n=0.176814899675218e1; break;
				case 8 : *I=2; *J=6; *n=-0.534686695713469e9; break;
				case 9 : *I=2; *J=14; *n=0.160464608687834e18; break;
				case 10 : *I=3; *J=3; *n=0.196435366560186e6; break;
				case 11 : *I=3; *J=8; *n=0.156637427541729e13; break;
				case 12 : *I=4; *J=0; *n=-0.178154560260006e1; break;
				case 13 : *I=4; *J=10; *n=-0.229746237623692e16; break;
				case 14 : *I=7; *J=3; *n=0.385659001648006e8; break;
				case 15 : *I=7; *J=4; *n=0.110554446790543e10; break;
				case 16 : *I=7; *J=7; *n=-0.677073830687349e14; break;
				case 17 : *I=7; *J=20; *n=-0.327910592086523e31; break;
				case 18 : *I=7; *J=36; *n=-0.341552040860644e51; break;
				case 19 : *I=10; *J=10; *n=-0.527251339709047e21; break;
				case 20 : *I=10; *J=12; *n=0.245375640937055e24; break;
				case 21 : *I=10; *J=14; *n=-0.168776617209269e27; break;
				case 22 : *I=10; *J=16; *n=0.358958955867578e29; break;
				case 23 : *I=10; *J=22; *n=-0.656475280339411e36; break;
				case 24 : *I=18; *J=18; *n=0.355286045512301e39; break;
				case 25 : *I=20; *J=32; *n=0.569021454413270e58; break;
				case 26 : *I=22; *J=22; *n=-0.700584546433113e48; break;
				case 27 : *I=22; *J=36; *n=-0.705772623326374e65; break;
				case 28 : *I=24; *J=24; *n=0.166861176200148e53; break;
				case 29 : *I=28; *J=28; *n=-0.300475129680486e61; break;
				case 30 : *I=32; *J=22; *n=-0.668481295196808e51; break;
				case 31 : *I=32; *J=32; *n=0.428432338620678e69; break;
				case 32 : *I=32; *J=36; *n=-0.444227367758304e72; break;
				case 33 : *I=36; *J=36; *n=-0.281396013562745e77; break;
			} break;
		}
		
		case region3u :
		{
			switch(i)
			{
				case 1 : *I=-12; *J=14; *n=0.122088349258355e18; break;
				case 2 : *I=-10; *J=10; *n=0.104216468608488e10; break;
				case 3 : *I=-10; *J=12; *n=-0.882666931564652e16; break;
				case 4 : *I=-10; *J=14; *n=0.259929510849499e20; break;
				case 5 : *I=-8; *J=10; *n=0.222612779142211e15; break;
				case 6 : *I=-8; *J=12; *n=-0.878473585050085e18; break;
				case 7 : *I=-8; *J=14; *n=-0.314432577551552e22; break;
				case 8 : *I=-6; *J=8; *n=-0.216934916996285e13; break;
				case 9 : *I=-6; *J=12; *n=0.159079648196849e21; break;
				case 10 : *I=-5; *J=4; *n=-0.339567617303423e3; break;
				case 11 : *I=-5; *J=8; *n=0.884387651337836e13; break;
				case 12 : *I=-5; *J=12; *n=-0.843405926846418e21; break;
				case 13 : *I=-3; *J=2; *n=0.114178193518022e2; break;
				case 14 : *I=-1; *J=-1; *n=-0.122708229235641e-3; break;
				case 15 : *I=-1; *J=1; *n=-0.106201671767107e3; break;
				case 16 : *I=-1; *J=12; *n=0.903443213959313e25; break;
				case 17 : *I=-1; *J=14; *n=-0.693996270370852e28; break;
				case 18 : *I=0; *J=-3; *n=0.648916718965575e-8; break;
				case 19 : *I=0; *J=1; *n=0.718957567127851e4; break;
				case 20 : *I=1; *J=-2; *n=0.105581745346187e-2; break;
				case 21 : *I=2; *J=5; *n=-0.651903203602581e15; break;
				case 22 : *I=2; *J=10; *n=-0.160116813274676e25; break;
				case 23 : *I=3; *J=-5; *n=-0.510254294237837e-8; break;
				case 24 : *I=5; *J=-4; *n=-0.152355388953402; break;
				case 25 : *I=5; *J=2; *n=0.677143292290144e12; break;
				case 26 : *I=5; *J=3; *n=0.276378438378930e15; break;
				case 27 : *I=6; *J=-5; *n=0.116862983141686e-1; break;
				case 28 : *I=6; *J=2; *n=-0.301426947980171e14; break;
				case 29 : *I=8; *J=-8; *n=0.169719813884840e-7; break;
				case 30 : *I=8; *J=8; *n=0.104674840020929e27; break;
				case 31 : *I=10; *J=-4; *n=-0.108016904560140e5; break;
				case 32 : *I=12; *J=-12; *n=-0.990623601934295e-12; break;
				case 33 : *I=12; *J=-4; *n=0.536116483602738e7; break;
				case 34 : *I=12; *J=4; *n=0.226145963747881e22; break;
				case 35 : *I=14; *J=-12; *n=-0.488731565776210e-9; break;
				case 36 : *I=14; *J=-10; *n=0.151001548880670e-4; break;
				case 37 : *I=14; *J=-6; *n=-0.227700464643920e5; break;
				case 38 : *I=14; *J=6; *n=-0.781754507698846e28; break;
			} break;
		}
		
		case region3v :
		{
			switch(i)
			{
				case 1 : *I=-10; *J=-8; *n=-0.415652812061591e-54; break;
				case 2 : *I=-8; *J=-12; *n=0.177441742924043e-60; break;
				case 3 : *I=-6; *J=-12; *n=-0.357078668203377e-54; break;
				case 4 : *I=-6; *J=-3; *n=0.359252213604114e-25; break;
				case 5 : *I=-6; *J=5; *n=-0.259123736380269e2; break;
				case 6 : *I=-6; *J=6; *n=0.594619766193460e5; break;
				case 7 : *I=-6; *J=8; *n=-0.624184007103158e11; break;
				case 8 : *I=-6; *J=10; *n=0.313080299915944e17; break;
				case 9 : *I=-5; *J=1; *n=0.105006446192036e-8; break;
				case 10 : *I=-5; *J=2; *n=-0.192824336984852e-5; break;
				case 11 : *I=-5; *J=6; *n=0.654144373749937e6; break;
				case 12 : *I=-5; *J=8; *n=0.513117462865044e13; break;
				case 13 : *I=-5; *J=10; *n=-0.697595750347391e19; break;
				case 14 : *I=-5; *J=14; *n=-0.103977184454767e29; break;
				case 15 : *I=-4; *J=-12; *n=0.119563135540666e-47; break;
				case 16 : *I=-4; *J=-10; *n=-0.436677034051655e-41; break;
				case 17 : *I=-4; *J=-6; *n=0.926990036530639e-29; break;
				case 18 : *I=-4; *J=10; *n=0.587793105620748e21; break;
				case 19 : *I=-3; *J=-3; *n=0.280375725094731e-17; break;
				case 20 : *I=-3; *J=10; *n=-0.192359972440634e23; break;
				case 21 : *I=-3; *J=12; *n=0.742705723302738e27; break;
				case 22 : *I=-2; *J=2; *n=-0.517429682450605e2; break;
				case 23 : *I=-2; *J=4; *n=0.820612048645469e7; break;
				case 24 : *I=-1; *J=-2; *n=-0.188214882341448e-8; break;
				case 25 : *I=-1; *J=0; *n=0.184587261114837e-1; break;
				case 26 : *I=0; *J=-2; *n=-0.135830407782663e-5; break;
				case 27 : *I=0; *J=6; *n=-0.723681885626348e17; break;
				case 28 : *I=0; *J=10; *n=-0.223449194054124e27; break;
				case 29 : *I=1; *J=-12; *n=-0.111526741826431e-34; break;
				case 30 : *I=1; *J=-10; *n=0.276032601145151e-28; break;
				case 31 : *I=3; *J=3; *n=0.134856491567853e15; break;
				case 32 : *I=4; *J=-6; *n=0.652440293345860e-9; break;
				case 33 : *I=4; *J=3; *n=0.510655119774360e17; break;
				case 34 : *I=4; *J=10; *n=-0.468138358908732e32; break;
				case 35 : *I=5; *J=2; *n=-0.760667491183279e16; break;
				case 36 : *I=8; *J=-12; *n=-0.417247986986821e-18; break;
				case 37 : *I=10; *J=-2; *n=0.312545677756104e14; break;
				case 38 : *I=12; *J=-3; *n=-0.100375333864186e15; break;
				case 39 : *I=14; *J=1; *n=0.247761392329058e27; break;
			} break;
		}
		
		case region3w :
		{
			switch(i)
			{
				case 1 : *I=-12; *J=8; *n=-0.586219133817016e-7; break;
				case 2 : *I=-12; *J=14; *n=-0.894460355005526e11; break;
				case 3 : *I=-10; *J=-1; *n=0.531168037519774e-30; break;
				case 4 : *I=-10; *J=8; *n=0.109892402329239; break;
				case 5 : *I=-8; *J=6; *n=-0.575368389425212e-1; break;
				case 6 : *I=-8; *J=8; *n=0.228276853990249e5; break;
				case 7 : *I=-8; *J=14; *n=-0.158548609655002e19; break;
				case 8 : *I=-6; *J=-4; *n=0.329865748576503e-27; break;
				case 9 : *I=-6; *J=-3; *n=-0.634987981190669e-24; break;
				case 10 : *I=-6; *J=2; *n=0.615762068640611e-8; break;
				case 11 : *I=-6; *J=8; *n=-0.961109240985747e8; break;
				case 12 : *I=-5; *J=-10; *n=-0.406274286652625e-44; break;
				case 13 : *I=-4; *J=-1; *n=-0.471103725498077e-12; break;
				case 14 : *I=-4; *J=3; *n=0.725937724828145; break;
				case 15 : *I=-3; *J=-10; *n=0.187768525763682e-38; break;
				case 16 : *I=-3; *J=3; *n=-0.103308436323771e4; break;
				case 17 : *I=-2; *J=1; *n=-0.662552816342168e-1; break;
				case 18 : *I=-2; *J=2; *n=0.579514041765710e3; break;
				case 19 : *I=-1; *J=-8; *n=0.237416732616644e-26; break;
				case 20 : *I=-1; *J=-4; *n=0.271700235739893e-14; break;
				case 21 : *I=-1; *J=1; *n=-0.907886213483600e2; break;
				case 22 : *I=0; *J=-12; *n=-0.171242509570207e-36; break;
				case 23 : *I=0; *J=1; *n=0.156792067854621e3; break;
				case 24 : *I=1; *J=-1; *n=0.923261357901470; break;
				case 25 : *I=2; *J=-1; *n=-0.597865988422577e1; break;
				case 26 : *I=2; *J=2; *n=0.321988767636389e7; break;
				case 27 : *I=3; *J=-12; *n=-0.399441390042203e-29; break;
				case 28 : *I=3; *J=-5; *n=0.493429086046981e-7; break;
				case 29 : *I=5; *J=-10; *n=0.812036983370565e-19; break;
				case 30 : *I=5; *J=-8; *n=-0.207610284654137e-11; break;
				case 31 : *I=5; *J=-6; *n=-0.340821291419719e-6; break;
				case 32 : *I=8; *J=-12; *n=0.542000573372233e-17; break;
				case 33 : *I=8; *J=-10; *n=-0.856711586510214e-12; break;
				case 34 : *I=10; *J=-12; *n=0.266170454405981e-13; break;
				case 35 : *I=10; *J=-8; *n=0.858133791857099e-5; break;
			} break;
		}
		
		case region3x :
		{
			switch(i)
			{
				case 1 : *I=-8; *J=14; *n=0.377373741298151e19; break;
				case 2 : *I=-6; *J=10; *n=-0.507100883722913e13; break;
				case 3 : *I=-5; *J=10; *n=-0.103363225598860e16; break;
				case 4 : *I=-4; *J=1; *n=0.184790814320773e-5; break;
				case 5 : *I=-4; *J=2; *n=-0.924729378390945e-3; break;
				case 6 : *I=-4; *J=14; *n=-0.425999562292738e24; break;
				case 7 : *I=-3; *J=-2; *n=-0.462307771873973e-12; break;
				case 8 : *I=-3; *J=12; *n=0.107319065855767e22; break;
				case 9 : *I=-1; *J=5; *n=0.648662492280682e11; break;
				case 10 : *I=0; *J=0; *n=0.244200600688281e1; break;
				case 11 : *I=0; *J=4; *n=-0.851535733484258e10; break;
				case 12 : *I=0; *J=10; *n=0.169894481433592e22; break;
				case 13 : *I=1; *J=-10; *n=0.215780222509020e-26; break;
				case 14 : *I=1; *J=-1; *n=-0.320850551367334; break;
				case 15 : *I=2; *J=6; *n=-0.382642448458610e17; break;
				case 16 : *I=3; *J=-12; *n=-0.275386077674421e-28; break;
				case 17 : *I=3; *J=0; *n=-0.563199253391666e6; break;
				case 18 : *I=3; *J=8; *n=-0.326068646279314e21; break;
				case 19 : *I=4; *J=3; *n=0.397949001553184e14; break;
				case 20 : *I=5; *J=-6; *n=0.100824008584757e-6; break;
				case 21 : *I=5; *J=-2; *n=0.162234569738433e5; break;
				case 22 : *I=5; *J=1; *n=-0.432355225319745e11; break;
				case 23 : *I=6; *J=1; *n=-0.592874245598610e12; break;
				case 24 : *I=8; *J=-6; *n=0.133061647281106e1; break;
				case 25 : *I=8; *J=-3; *n=0.157338197797544e7; break;
				case 26 : *I=8; *J=1; *n=0.258189614270853e14; break;
				case 27 : *I=8; *J=8; *n=0.262413209706358e25; break;
				case 28 : *I=10; *J=-8; *n=-0.920011937431142e-1; break;
				case 29 : *I=12; *J=-10; *n=0.220213765905426e-2; break;
				case 30 : *I=12; *J=-8; *n=-0.110433759109547e2; break;
				case 31 : *I=12; *J=-5; *n=0.847004870612087e7; break;
				case 32 : *I=12; *J=-4; *n=-0.592910695762536e9; break;
				case 33 : *I=14; *J=-12; *n=-0.183027173269660e-4; break;
				case 34 : *I=14; *J=-10; *n=0.181339603516302; break;
				case 35 : *I=14; *J=-8; *n=-0.119228759669889e4; break;
				case 36 : *I=14; *J=-6; *n=0.430867658061468e7; break;
			} break;
		}
		
		case region3y :
		{
			switch(i)
			{
				case 1 : *I=0; *J=-3; *n=-0.525597995024633e-9; break;
				case 2 : *I=0; *J=1; *n=0.583441305228407e4; break;
				case 3 : *I=0; *J=5; *n=-0.134778968457925e17; break;
				case 4 : *I=0; *J=8; *n=0.118973500934212e26; break;
				case 5 : *I=1; *J=8; *n=-0.159096490904708e27; break;
				case 6 : *I=2; *J=-4; *n=-0.315839902302021e-6; break;
				case 7 : *I=2; *J=-1; *n=0.496212197158239e3; break;
				case 8 : *I=2; *J=4; *n=0.327777227273171e19; break;
				case 9 : *I=2; *J=5; *n=-0.527114657850696e22; break;
				case 10 : *I=3; *J=-8; *n=0.210017506281863e-16; break;
				case 11 : *I=3; *J=4; *n=0.705106224399834e21; break;
				case 12 : *I=3; *J=8; *n=-0.266713136106469e31; break;
				case 13 : *I=4; *J=-6; *n=-0.145370512554562e-7; break;
				case 14 : *I=4; *J=6; *n=0.149333917053130e28; break;
				case 15 : *I=5; *J=-2; *n=-0.149795620287641e8; break;
				case 16 : *I=5; *J=1; *n=-0.381881906271100e16; break;
				case 17 : *I=8; *J=-8; *n=0.724660165585797e-4; break;
				case 18 : *I=8; *J=-2; *n=-0.937808169550193e14; break;
				case 19 : *I=10; *J=-5; *n=0.514411468376383e10; break;
				case 20 : *I=12; *J=-8; *n=-0.828198594040141e5; break;
			} break;
		}
		
		case region3z :
		{
			switch(i)
			{
				case 1 : *I=-8; *J=3; *n=0.244007892290650e-10; break;
				case 2 : *I=-6; *J=6; *n=-0.463057430331242e7; break;
				case 3 : *I=-5; *J=6; *n=0.728803274777712e10; break;
				case 4 : *I=-5; *J=8; *n=0.327776302858856e16; break;
				case 5 : *I=-4; *J=5; *n=-0.110598170118409e10; break;
				case 6 : *I=-4; *J=6; *n=-0.323899915729957e13; break;
				case 7 : *I=-4; *J=8; *n=0.923814007023245e16; break;
				case 8 : *I=-3; *J=-2; *n=0.842250080413712e-12; break;
				case 9 : *I=-3; *J=5; *n=0.663221436245506e12; break;
				case 10 : *I=-3; *J=6; *n=-0.167170186672139e15; break;
				case 11 : *I=-2; *J=2; *n=0.253749358701391e4; break;
				case 12 : *I=-1; *J=-6; *n=-0.819731559610523e-20; break;
				case 13 : *I=0; *J=3; *n=0.328380587890663e12; break;
				case 14 : *I=1; *J=1; *n=-0.625004791171543e8; break;
				case 15 : *I=2; *J=6; *n=0.803197957462023e21; break;
				case 16 : *I=3; *J=-6; *n=-0.204397011338353e-10; break;
				case 17 : *I=3; *J=-2; *n=-0.378391047055938e4; break;
				case 18 : *I=6; *J=-6; *n=0.972876545938620e-2; break;
				case 19 : *I=6; *J=-5; *n=0.154355721681459e2; break;
				case 20 : *I=6; *J=-4; *n=-0.373962862928643e4; break;
				case 21 : *I=6; *J=-1; *n=-0.682859011374572e11; break;
				case 22 : *I=8; *J=-8; *n=-0.248488015614543e-3; break;
				case 23 : *I=8; *J=-4; *n=0.394536049497068e7; break;
			} break;
		}
	}
}


void water_properties_specific_volume_region3_get_constants2(water_properties_region region, double *v,
															 double *p, double *T, int *N, double *a,
															 double *b, double *c, double *d, double *e)
/*tables 2.103 and 2.129*/
{
	switch(region)
	{
		case region3a : *v=0.0024; *p=100.e6; *T=760.0; *N=30;
						*a=0.085; *b=0.817; *c=1.0; *d=1.0; *e=1.0;
						break;
		case region3b : *v=0.0041; *p=100.0e6; *T=860.0; *N=32;
						*a=0.280; *b=0.779; *c=1.0; *d=1.0; *e=1.0;
						break;
		case region3c : *v=0.0022; *p=40.0e6; *T=690.0; *N=35;
						*a=0.259; *b=0.903; *c=1.0; *d=1.0; *e=1.0;
						break;
		case region3d : *v=0.0029; *p=40.0e6; *T=690.0; *N=38;
						*a=0.559; *b=0.939; *c=1.0; *d=1.0; *e=4.0;
						break;
		case region3e : *v=0.0032; *p=40.0e6; *T=710.0; *N=29;
						*a=0.587; *b=0.918; *c=1.0; *d=1.0; *e=1.0;
						break;
		case region3f : *v=0.0064; *p=40.0e6; *T=730.0; *N=42;
						*a=0.587; *b=0.891; *c=0.5; *d=1.0; *e=4.0;
						break;
		case region3g : *v=0.0027; *p=25.0e6; *T=660.0; *N=38;
						*a=0.872; *b=0.971; *c=1.0; *d=1.0; *e=4.0;
						break;
		case region3h : *v=0.0032; *p=25.0e6; *T=660.0; *N=29;
						*a=0.898; *b=0.983; *c=1.0; *d=1.0; *e=4.0;
						break;
		case region3i : *v=0.0041; *p=25.0e6; *T=660.0; *N=42;
						*a=0.910; *b=0.984; *c=0.5; *d=1.0; *e=4.0;
						break;
		case region3j : *v=0.0054; *p=25.0e6; *T=670.0; *N=29;
						*a=0.875; *b=0.964; *c=0.5; *d=1.0; *e=4.0;
						break;
		case region3k : *v=0.0077; *p=25.0e6; *T=680.0; *N=34;
						*a=0.802; *b=0.935; *c=1.0; *d=1.0; *e=1.0;
						break;
		case region3l : *v=0.0026; *p=24.0e6; *T=650.0; *N=43;
						*a=0.908; *b=0.989; *c=1.0; *d=1.0; *e=4.0;
						break;
		case region3m : *v=0.0028; *p=23.0e6; *T=650.0; *N=40;
						*a=1.000; *b=0.997; *c=1.0; *d=0.25; *e=1.0;
						break;
		case region3n : *v=0.0031; *p=23.0e6; *T=650.0; *N=39;
						*a=0.976; *b=0.997; *c=0.0; *d=0.0; *e=0.0;
						break;
		case region3o : *v=0.0034; *p=23.0e6; *T=650.0; *N=24;
						*a=0.974; *b=0.996 ; *c=0.5; *d=1.0; *e=1.0;
						break;
		case region3p : *v=0.0041; *p=23.0e6; *T=650.0; *N=27;
						*a=0.972; *b=0.997; *c=0.5; *d=1.0; *e=1.0;
						break;
		case region3q : *v=0.0022; *p=23.0e6; *T=650.0; *N=24;
						*a=0.848; *b=0.983; *c=1.0; *d=1.0; *e=4.0;
						break;
		case region3r : *v=0.0054; *p=23.0e6; *T=650.0; *N=27;
						*a=0.874; *b=0.982; *c=1.0; *d=1.0; *e=1.0;
						break;
		case region3s : *v=0.0022; *p=21.0e6; *T=640.0; *N=29;
						*a=0.886; *b=0.990; *c=1.0; *d=1.0; *e=4.0;
						break;
		case region3t : *v=0.0088; *p=20.0e6; *T=650.0; *N=33;
						*a=0.803; *b=1.020; *c=1.0; *d=1.0; *e=1.0;
						break;
		case region3u : *v=0.0026; *p=23.0e6; *T=650.0; *N=38;
						*a=0.902; *b=0.988; *c=1.0; *d=1.0; *e=1.0;
						break;
		case region3v : *v=0.0031; *p=23.0e6; *T=650.0; *N=39;
						*a=0.960; *b=0.995; *c=1.0; *d=1.0; *e=1.0;
						break;
		case region3w : *v=0.0039; *p=23.0e6; *T=650.0; *N=35;
						*a=0.959; *b=0.995; *c=1.0; *d=1.0; *e=4.0;
						break;
		case region3x : *v=0.0049; *p=23.0e6; *T=650.0; *N=36;
						*a=0.910; *b=0.988; *c=1.0; *d=1.0; *e=1.0;
						break;
		case region3y : *v=0.0031; *p=22.0e6; *T=650.0; *N=20;
						*a=0.996; *b=0.994; *c=1.0; *d=1.0; *e=4.0;
						break;
		case region3z : *v=0.0038; *p=22.0e6; *T=650.0; *N=23;
						*a=0.993; *b=0.994; *c=1.0; *d=1.0; *e=4.0;
						break;
	}
}



/*------------------------------------------------------------------------*/

/*transport properties*/

double water_properties_surface_tension(double temperature)
{
	double reduced_temperature;
	
	reduced_temperature=temperature/647.096;
	
	return(235.8*power2(1.0-reduced_temperature,1.256)*(1.0-0.625*(1.0-reduced_temperature))*1.0e-3);
}


double water_properties_dynamic_viscosity(double temperature, double pressure)
{
	double reduced_temperature, reduced_density, result;
	
	reduced_temperature=temperature/647.096;
	reduced_density=1.0/322.0/water_properties_specific_volume(water_properties_get_region(temperature,pressure),temperature,pressure);
	
	
	result=water_properties_dynamic_viscosity_psi0(reduced_temperature);
	result=result*water_properties_dynamic_viscosity_psi1(reduced_temperature, reduced_density);
	return(result*1.0e-6);
}


double water_properties_dynamic_viscosity_psi0(double reduced_temperature)
{
	double result, n;
	int counter;
	
	result=0.0;
	
	for (counter=1;counter<=4;counter++)
	{
		water_properties_dynamic_viscosity_psi0_constants(counter, &n);
		result=result+n*power1(reduced_temperature,1-counter);
	}
	result=sqrt(reduced_temperature)/result;
	return(result);
}


double water_properties_dynamic_viscosity_psi1(double reduced_temperature, double reduced_density)
{
	double result, n;
	double aux_d, aux_t;
	int I, J, counter;
	
	result=0.0;
	
	aux_t=1.0/reduced_temperature-1.0;
	aux_d=reduced_density-1.0;
	
	for (counter=1;counter<=21;counter++)
	{
		water_properties_dynamic_viscosity_psi1_constants(counter, &I, &J, &n);
		result=result+n*power1(aux_d,I)*power1(aux_t,J);
	}
	
	result=exp(reduced_density*result);
	
	return(result);
}


void water_properties_dynamic_viscosity_psi0_constants(int i, double *n)
{
	const double nArray[]={0.167752e-1,0.220462e-1,0.6366564e-2,-0.241605e-2};
	
	if (i<=4 && i>=1)
	{
		*n=nArray[i-1];
	}
	else
	{
		*n=0.0;
	}
}


void water_properties_dynamic_viscosity_psi1_constants(int i, int *I, int *J, double *n)
{
	const int IArray[]={0,0,0,0,1,1,1,1,1,2,2,2,2,2,3,3,4,4,5,6,6};
	const int JArray[]={0,1,2,3,0,1,2,3,5,0,1,2,3,4,0,1,0,3,4,3,5};
	const double nArray[]={0.520094,0.850895e-1,-0.108374e1,-0.289555,
						   0.222531,0.999115,0.188797e1,0.126613e1,
						   0.120573,-0.281378,-0.906851,-0.772479,
						   -0.489837,-0.257040,0.161913,0.257399,
						   -0.325372e-1,0.698452e-1,0.872102e-2,
						   -0.435673e-2,-0.593264e-3};

	
	if (i<=21 && i>=1)
	{
		*I=IArray[i-1];
		*J=JArray[i-1];
		*n=nArray[i-1];
	}
	else
	{
		*I=0;
		*J=0;
		*n=0.0;
	}
}


double water_properties_thermal_conductivity(double temperature, double pressure)
{
	double reduced_temperature, reduced_density, result;
	
	reduced_temperature=temperature/647.26;
	reduced_density=1.0/317.7/water_properties_specific_volume(water_properties_get_region(temperature,pressure),temperature,pressure);
	
	
	result=water_properties_thermal_conductivity_lambda0(reduced_temperature);
	result=result+water_properties_thermal_conductivity_lambda1(reduced_density);
	result=result+water_properties_thermal_conductivity_lambda2(reduced_temperature, reduced_density);
	return(result);
}


double water_properties_thermal_conductivity_lambda0(double reduced_temperature)
{
	double result, n;
	int counter;
	
	result=0.0;
	
	for (counter=1; counter<=4; counter++)
	{
		water_properties_thermal_conductivity_lambda0_constants(counter, &n);
		result=result+n*power1(reduced_temperature,counter-1);
	}
	result=sqrt(reduced_temperature)*result;
	
	return(result);
}


double water_properties_thermal_conductivity_lambda1(double reduced_density)
{
	double n1, n2, n3, n4, n5;
	
	water_properties_thermal_conductivity_lambda1_constants(1, &n1);
	water_properties_thermal_conductivity_lambda1_constants(2, &n2);
	water_properties_thermal_conductivity_lambda1_constants(3, &n3);
	water_properties_thermal_conductivity_lambda1_constants(4, &n4);
	water_properties_thermal_conductivity_lambda1_constants(5, &n5);
	
	return(n1+n2*reduced_density+n3*exp(n4*(reduced_density+n5)*(reduced_density+n5)));
}


double water_properties_thermal_conductivity_lambda2(double reduced_temperature, double reduced_density)
{
	double n1, n2, n3, n4, n5, n6, n7, n8, n9, n10, A, B, DeltaTheta, result;
	
	water_properties_thermal_conductivity_lambda2_constants(1, &n1);
	water_properties_thermal_conductivity_lambda2_constants(2, &n2);
	water_properties_thermal_conductivity_lambda2_constants(3, &n3);
	water_properties_thermal_conductivity_lambda2_constants(4, &n4);
	water_properties_thermal_conductivity_lambda2_constants(5, &n5);
	water_properties_thermal_conductivity_lambda2_constants(6, &n6);
	water_properties_thermal_conductivity_lambda2_constants(7, &n7);
	water_properties_thermal_conductivity_lambda2_constants(8, &n8);
	water_properties_thermal_conductivity_lambda2_constants(9, &n9);
	water_properties_thermal_conductivity_lambda2_constants(10, &n10);
	
	DeltaTheta=fabs(reduced_temperature-1.0)+n10;
	A=2.0+n8*power2(DeltaTheta,-0.6);
	if (reduced_temperature>=1.0)
	{
		B=1.0/DeltaTheta;
	}
	else
	{
		B=n9*power2(DeltaTheta,-0.6);
	}
	result=(n1*power1(reduced_temperature,-10)+n2)*power2(reduced_density,1.8);
	result=result*exp(n3*(1.0-power2(reduced_density,2.8)));
	result=result+n4*A*power2(reduced_density,B)*exp(B/(1.0+B)*(1.0-power2(reduced_density,1.0+B)));
	result=result+n5*exp(n6*power2(reduced_temperature,1.5)+n7*power1(reduced_density,-5));
	
	return(result);
}


void water_properties_thermal_conductivity_lambda0_constants(int i, double *n)
{
	const double nArray[]={0.102811e-1,0.299621e-1,0.156146e-1,-0.422464e-2};
	
	if (i<=4 && i>=1)
	{
		*n=nArray[i-1];
	}
	else
	{
		*n=0.0;
	}
}


void water_properties_thermal_conductivity_lambda1_constants(int i, double *n)
{
	const double nArray[]={-0.397070,0.400302,0.106000e1,-0.171587,0.239219e1};
	
	if (i<=5 && i>=1)
	{
		*n=nArray[i-1];
	}
	else
	{	
		*n=0.0;
	}
}


void water_properties_thermal_conductivity_lambda2_constants(int i, double *n)
{
	const double nArray[]={0.701309e-1,0.118520e-1,0.642857,0.169937e-2,
						   -0.102000e1,-0.411717e1,-0.617937e1,0.822994e-1,
						   0.100932e2,0.308976e-2};
	if (i<=10 && i>=1)
	{
		*n=nArray[i-1];
	}
	else
	{
		*n=0.0;
	}
}


double water_properties_dielectric_constant(double temperature, double pressure)
{
	double reduced_temperature, reduced_density, rho, result, A, B;
	
	reduced_temperature=647.096/temperature;
	rho=1.0/water_properties_specific_volume(water_properties_get_region(temperature,pressure),temperature,pressure);
	reduced_density=rho/322.0;
	
	A=6.0221367e23*6.138e-30*6.138e-30*rho*water_properties_dielectric_constant_g(reduced_temperature,reduced_density);
	A=A/(0.018015268*8.854187817e-12*1.380658e-23*temperature);
	B=6.0221367e23*1.636e-40*rho/(3.0*0.018015268*8.854187817e-12);
	
	result=1.0+A+5.0*B+sqrt(9.0+2.0*A+18.0*B+A*A+10.0*A*B+9.0*B*B);
	result=result/(4.0*(1.0-B));
	
	return(result);
}


double water_properties_dielectric_constant_g(double reduced_temperature, double reduced_density)
{
	double result, n, J;
	int counter, I;
	
	water_properties_dielectric_constant_constants(12, &I, &J, &n);
	result=1.0+n*reduced_density*power2(647.096/228.0/reduced_temperature-1.0,-1.2);
	
	for (counter=1; counter<=11; counter++)
	{
		water_properties_dielectric_constant_constants(counter, &I, &J, &n);
		result=result+n*power1(reduced_density,I)*power2(reduced_temperature,J);
	}
	
	return(result);
}


void water_properties_dielectric_constant_constants(int i, int *I, double *J, double *n)
{
	const int IArray[]={1,1,1,2,3,3,4,5,6,7,10,0};
	const double JArray[]={0.25,1.0,2.5,1.5,1.5,2.5,2.0,2.0,5.0,0.5,10.0,0.0};
	const double nArray[]={0.978224486826,-0.957771379375,0.237511794148,0.714692244396,
						   -0.298217036956,-0.108863472196,0.949327488264e-1,-0.980469816509e-2,
						   0.165167634970e-4,0.937359795772e-4,-0.123179218720e-9,0.196096504426e-2};
	
	if (i<=12 && i>=1)
	{
		*I=IArray[i-1];
		*J=JArray[i-1];
		*n=nArray[i-1];
	}
	else
	{
		*I=0;
		*J=0.0;
		*n=0.0;
	}
}


double water_properties_refractive_index(double temperature, double pressure, double wavelength)
{
	double a0, a1, a2, a3, a4, a5, a6, a7, reduced_wavelength, A, reduced_density, reduced_temperature, aux;
	
	water_properties_refractive_index_constants(0, &a0);
	water_properties_refractive_index_constants(1, &a1);
	water_properties_refractive_index_constants(2, &a2);
	water_properties_refractive_index_constants(3, &a3);
	water_properties_refractive_index_constants(4, &a4);
	water_properties_refractive_index_constants(5, &a5);
	water_properties_refractive_index_constants(6, &a6);
	water_properties_refractive_index_constants(7, &a7);
	
	reduced_temperature=temperature/273.15;
	reduced_density=1.0/1000.0/water_properties_specific_volume(water_properties_get_region(temperature,pressure),temperature,pressure);
	reduced_wavelength=wavelength/0.589e-6;
	aux=reduced_wavelength*reduced_wavelength;
	
	A=a0+a1*reduced_density+a2*reduced_temperature+a3*aux*reduced_temperature;
	A=A+a4/aux+a5/(aux-0.229202*0.229202)+a6/(aux-5.432937*5.432937)+a7*reduced_density*reduced_density;
	A=A*reduced_density;
	
	return(sqrt((2.0*A+1.0)/(1.0-A)));
}


void water_properties_refractive_index_constants(int i, double *a)
{
	const double aArray[]={0.244257733,0.974634476e-2,-0.373234996e-2,0.268678472e-3,
						   0.158920570e-2,0.245934259e-2,0.900704920,-0.166626219e-1};

	if (i<=7 && i>=0)
	{
		*a=aArray[i];
	}
	else
	{
		*a=0.0;
	}
}



/*------------------------------------------------------------------------*/

/*testcases*/

void testcases_region23()
{
	printf("T=%f, should %f\n",water_properties_TB23(0.165291643e2*1.0e6), 0.62315e3);
	printf("p=%f, should %f\n",water_properties_pB23(623.15),0.165291643e2*1.0e6);
}

void testcases_one_region3(water_properties_region region, double T, double p, double should_v)
{
    double v;
    water_properties_region region_get;
    
    region_get=water_properties_specific_volume_region3_get_region(T, p);
	v=water_properties_specific_volume_region3(region, T, p);
	printf("p=%f\tT=%f\tv=%e\tshould=%e\nDelta=%e\tregion=%i\tget=%i\n",p/1.0e6,T,v,should_v,should_v-v,region,region_get);
}


void testcases_one_region(water_properties_region region, double T, double p)
{
	double v, h, cp, cv, s, u, w, a, k;
	v=water_properties_specific_volume(region, T, p);
	h=water_properties_specific_enthalpy(region, T, p);
	cp=water_properties_specific_isobaric_heat_capacity(region, T, p);
	cv=water_properties_specific_isochoric_heat_capacity(region, T, p);
	s=water_properties_specific_entropy(region, T, p);
	u=water_properties_specific_internal_energy(region, T ,p);
	w=water_properties_speed_of_sound(region, T, p);
	a=water_properties_isobaric_cubic_expansion_coefficient(region, T, p);
	k=water_properties_isothermal_compressibility(region, T, p);
	printf("T=%f\tp=%e\tregion=%i\tget=%i\n",T,p/1.0e6,region,water_properties_get_region(T,p));
	printf("\tv=%e\th=%e\tu=%e\n",v,h,u);
	printf("\ts=%e\tcp=%e\tcv=%e\n",s,cp,cv);
	printf("\tw=%e\ta=%e\tk=%e\n\n",w,a,k);
}


void testcases_volume_region3()
{
	
	testcases_one_region3(region3a, 630.0, 50.0e6, 1.470853100e-3);
	testcases_one_region3(region3a, 670.0, 80.0e6, 1.503831359e-3);
	printf("\n");
	
	testcases_one_region3(region3b, 710.0, 50.0e6, 2.204728587e-3);
	testcases_one_region3(region3b, 750.0, 80.0e6, 1.973692940e-3);
	printf("\n");
	
	testcases_one_region3(region3c, 630.0, 20.0e6, 1.761696406e-3);
	testcases_one_region3(region3c, 650.0, 30.0e6, 1.819560617e-3);
	printf("\n");
	
	testcases_one_region3(region3d, 656.0, 26.0e6, 2.245587720e-3);
	testcases_one_region3(region3d, 670.0, 30.0e6, 2.506897702e-3);
	printf("\n");
	
	testcases_one_region3(region3e, 661.0, 26.0e6, 2.970225962e-3);
	testcases_one_region3(region3e, 675.0, 30.0e6, 3.004627086e-3);
	printf("\n");
	
	testcases_one_region3(region3f, 671.0, 26.0e6, 5.019029401e-3);
	testcases_one_region3(region3f, 690.0, 30.0e6, 4.656470142e-3);
	printf("\n");
	
	testcases_one_region3(region3g, 649.0, 23.6e6, 2.163198378e-3);
	testcases_one_region3(region3g, 650.0, 24.0e6, 2.166044161e-3);
	printf("\n");
	
	testcases_one_region3(region3h, 652.0, 23.6e6, 2.651081407e-3);
	testcases_one_region3(region3h, 654.0, 24.0e6, 2.967802335e-3);
	printf("\n");
	
	testcases_one_region3(region3i, 653.0, 23.6e6, 3.273916816e-3);
	testcases_one_region3(region3i, 655.0, 24.0e6, 3.550329864e-3);
	printf("\n");
	
	testcases_one_region3(region3j, 655.0, 23.5e6, 4.545001142e-3);
	testcases_one_region3(region3j, 660.0, 24.0e6, 5.100267704e-3);
	printf("\n");
	
	testcases_one_region3(region3k, 660.0, 23.0e6, 6.109525997e-3);
	testcases_one_region3(region3k, 670.0, 24.0e6, 6.427325645e-3);
	printf("\n");
	
	testcases_one_region3(region3l, 646.0, 22.6e6, 2.117860851e-3);
	testcases_one_region3(region3l, 646.0, 23.0e6, 2.062374674e-3);
	printf("\n");
	
	testcases_one_region3(region3m, 648.6, 22.6e6, 2.533063780e-3);
	testcases_one_region3(region3m, 649.3, 22.8e6, 2.572971781e-3);
	printf("\n");
	
	testcases_one_region3(region3n, 649.0, 22.6e6, 2.923432711e-3);
	testcases_one_region3(region3n, 649.7, 22.8e6, 2.913311494e-3);
	printf("\n");
	
	testcases_one_region3(region3o, 649.1, 22.6e6, 3.131208996e-3);
	testcases_one_region3(region3o, 649.9, 22.8e6, 3.221160278e-3);
	printf("\n");
	
	testcases_one_region3(region3p, 649.4, 22.6e6, 3.715596186e-3);
	testcases_one_region3(region3p, 650.2, 22.8e6, 3.664754790e-3);
	printf("\n");
	

	testcases_one_region3(region3q, 640.0, 21.1e6, 1.970999272e-3);
	testcases_one_region3(region3q, 643.0, 21.8e6, 2.043919161e-3);
	printf("\n");
	
	testcases_one_region3(region3r, 644.0, 21.1e6, 5.251009921e-3);
	testcases_one_region3(region3r, 648.0, 21.8e6, 5.256844741e-3);
	printf("\n");
	
	testcases_one_region3(region3s, 635.0, 19.1e6, 1.932829079e-3);
	testcases_one_region3(region3s, 638.0, 20.0e6, 1.985387227e-3);
	printf("\n");
	
	testcases_one_region3(region3t, 626.0, 17.0e6, 8.483262001e-3);
	testcases_one_region3(region3t, 640.0, 20.0e6, 6.227528101e-3);
	printf("\n");
	
	testcases_one_region3(region3u, 644.6, 21.5e6, 2.268366647e-3);
	testcases_one_region3(region3u, 646.1, 22.0e6, 2.296350553e-3);
	printf("\n");
	
	testcases_one_region3(region3v, 648.6, 22.5e6, 2.832373260e-3);
	testcases_one_region3(region3v, 647.9, 22.3e6, 2.811424405e-3);
	printf("\n");
	
	testcases_one_region3(region3w, 647.5, 22.15e6, 3.694032281e-3);
	testcases_one_region3(region3w, 648.1, 22.3e6, 3.622226305e-3);
	printf("\n");
	
	testcases_one_region3(region3x, 648.0, 22.11e6, 4.528072649e-3);
	testcases_one_region3(region3x, 649.0, 22.3e6, 4.556905799e-3);
	printf("\n");
	
	testcases_one_region3(region3y, 646.84, 22.0e6, 2.698354719e-3);
	testcases_one_region3(region3y, 647.05, 22.064e6, 2.717655648e-3);
	printf("\n");
	
    testcases_one_region3(region3z, 646.89, 22.0e6, 3.798732962e-3);
    testcases_one_region3(region3z, 647.15, 22.064e6, 3.701940010e-3);
    printf("\n");
}


void testcases_regions()
{
	testcases_one_region(region1,300.0,3.0e6);
	testcases_one_region(region1,300.0,80.0e6);
	testcases_one_region(region1,500.0,3.0e6);	
	printf("\n");
	
	testcases_one_region(region2,300.0,0.0035e6);
	testcases_one_region(region2,700.0,0.0035e6);
	testcases_one_region(region2,700.0,30.0e6);	
	printf("\n");
	
	testcases_one_region(region2meta,450.0,1.0e6);
	testcases_one_region(region2meta,440.0,1.0e6);
	testcases_one_region(region2meta,450.0,1.5e6);
	printf("\n");
	
	testcases_one_region(region3,650.0,0.255837018e8);
	testcases_one_region(region3,650.0,0.222930643e8);
	testcases_one_region(region3,750.0,0.783095639e8);
	printf("\n");
	
	testcases_one_region(region5,1500.0,0.5e6);
	testcases_one_region(region5,1500.0,30.0e6);
	testcases_one_region(region5,2000.0,30.0e6);
	printf("\n");

}


void testcases_region4()
{
	printf("T=%f, should %f\n",water_properties_Ts(16.52916425e6),623.150000);
    printf("p=%e, should %e\n",water_properties_ps(623.150000),16.52916425e6);
	printf("\n");
}


void testcases_dynamic_viscosity()
{
	double eta, rho, T, p;
	
	T=298.15;
	p=0.1e6;
	eta=water_properties_dynamic_viscosity(T,p);
	rho=1.0/water_properties_specific_volume(water_properties_get_region(T,p),T,p);
	printf("T=%f\tp=%e\n",T,p);
	printf("rho=%e\teta=%e\n\n",rho,eta);
	
	T=873.15;
	p=20.0e6;
	eta=water_properties_dynamic_viscosity(T,p);
	rho=1.0/water_properties_specific_volume(water_properties_get_region(T,p),T,p);
	printf("T=%f\tp=%e\n",T,p);
	printf("rho=%e\teta=%e\n\n",rho,eta);
	
	T=673.15;
	p=60.0e6;
	eta=water_properties_dynamic_viscosity(T,p);
	rho=1.0/water_properties_specific_volume(water_properties_get_region(T,p),T,p);
	printf("T=%f\tp=%e\n",T,p);
	printf("rho=%e\teta=%e\n\n",rho,eta);
}


void testcases_thermal_conductivity()
{
	double lambda, rho, T, p;
	
	T=298.15;
	p=0.1e6;
	lambda=water_properties_thermal_conductivity(T,p);
	rho=1.0/water_properties_specific_volume(water_properties_get_region(T,p),T,p);
	printf("T=%f\tp=%e\n",T,p);
	printf("rho=%e\tlambda=%e\n\n",rho,lambda);
	
	T=873.15;
	p=10.0e6;
	lambda=water_properties_thermal_conductivity(T,p);
	rho=1.0/water_properties_specific_volume(water_properties_get_region(T,p),T,p);
	printf("T=%f\tp=%e\n",T,p);
	printf("rho=%e\tlambda=%e\n\n",rho,lambda);
	
	T=673.15;
	p=40.0e6;
	lambda=water_properties_thermal_conductivity(T,p);
	rho=1.0/water_properties_specific_volume(water_properties_get_region(T,p),T,p);
	printf("T=%f\tp=%e\n",T,p);
	printf("rho=%e\tlambda=%e\n\n",rho,lambda);
}


void testcases_surface_tension()
{
	double sigma, T;
	
	T=300;
	sigma=water_properties_surface_tension(T);
	printf("T=%f\tsigma=%e\n\n",T,sigma);
	
	T=450;
	sigma=water_properties_surface_tension(T);
	printf("T=%f\tsigma=%e\n\n",T,sigma);
	
	T=600;
	sigma=water_properties_surface_tension(T);
	printf("T=%f\tsigma=%e\n\n",T,sigma);
}


void testcases_dielectric_constant()
{
	double epsilon, rho, T, p;
	
	T=298.15;
	p=5.0e6;
	epsilon=water_properties_dielectric_constant(T,p);
	rho=1.0/water_properties_specific_volume(water_properties_get_region(T,p),T,p);
	printf("T=%f\tp=%e\n",T,p);
	printf("rho=%e\tepsilon=%e\n\n",rho,epsilon);
	
	T=873.15;
	p=10.0e6;
	epsilon=water_properties_dielectric_constant(T,p);
	rho=1.0/water_properties_specific_volume(water_properties_get_region(T,p),T,p);
	printf("T=%f\tp=%e\n",T,p);
	printf("rho=%e\tepsilon=%e\n\n",rho,epsilon);
	
	T=673.15;
	p=40.0e6;
	epsilon=water_properties_dielectric_constant(T,p);
	rho=1.0/water_properties_specific_volume(water_properties_get_region(T,p),T,p);
	printf("T=%f\tp=%e\n",T,p);
	printf("rho=%e\tepsilon=%e\n\n",rho,epsilon);
}


void testcases_refractive_index()
{
	double n, lambda, rho, T, p;
	
	T=298.15;
	p=0.1e6;
	lambda=0.2265e-6;
	n=water_properties_refractive_index(T,p,lambda);
	rho=1.0/water_properties_specific_volume(water_properties_get_region(T,p),T,p);
	printf("T=%f\tp=%e\tlambda=%e\n",T,p,lambda);
	printf("rho=%e\tn=%e\n\n",rho,n);
	
	T=298.15;
	p=0.1e6;
	lambda=0.5893e-6;
	n=water_properties_refractive_index(T,p,lambda);
	rho=1.0/water_properties_specific_volume(water_properties_get_region(T,p),T,p);
	printf("T=%f\tp=%e\tlambda=%e\n",T,p,lambda);
	printf("rho=%e\tn=%e\n\n",rho,n);
	
	T=773.15;
	p=10.0e6;
	lambda=0.2265e-6;
	n=water_properties_refractive_index(T,p,lambda);
	rho=1.0/water_properties_specific_volume(water_properties_get_region(T,p),T,p);
	printf("T=%f\tp=%e\tlambda=%e\n",T,p,lambda);
	printf("rho=%e\tn=%e\n\n",rho,n);
	
	T=773.15;
	p=10.0e6;
	lambda=0.5893e-6;
	n=water_properties_refractive_index(T,p,lambda);
	rho=1.0/water_properties_specific_volume(water_properties_get_region(T,p),T,p);
	printf("T=%f\tp=%e\tlambda=%e\n",T,p,lambda);
	printf("rho=%e\tn=%e\n\n",rho,n);
	
	T=673.15;
	p=40.0e6;
	lambda=0.2265e-6;
	n=water_properties_refractive_index(T,p,lambda);
	rho=1.0/water_properties_specific_volume(water_properties_get_region(T,p),T,p);
	printf("T=%f\tp=%e\tlambda=%e\n",T,p,lambda);
	printf("rho=%e\tn=%e\n\n",rho,n);
	
	T=673.15;
	p=40.0e6;
	lambda=0.5893e-6;
	n=water_properties_refractive_index(T,p,lambda);
	rho=1.0/water_properties_specific_volume(water_properties_get_region(T,p),T,p);
	printf("T=%f\tp=%e\tlambda=%e\n",T,p,lambda);
	printf("rho=%e\tn=%e\n\n",rho,n);
}

/*int main()
{*/
	/*testcases_region23();*/
	/*testcases_volume_region3();*/
	/*testcases_regions();*/
	/*testcases_region4();*/
	/*testcases_dynamic_viscosity();*/
	/*testcases_thermal_conductivity();*/
	/*testcases_surface_tension();*/
	/*testcases_dielectric_constant();*/
	/*testcases_refractive_index();*/

	/*return(0);
}*/
