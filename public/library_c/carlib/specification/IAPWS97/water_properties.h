#ifndef WATER_PROPERTIES_HEADER
#define WATER_PROPERTIES_HEADER

#define water_properties_R_water 461.526

#ifndef PI
#define PI 3.14159
#endif


/*typedefs*/
typedef enum
{
	none=0,
	region1,
	region2,
	region3,
	region4,
	region5,
	region23,
	region2meta,
	region3a,
	region3b,
	region3c,
	region3d,
	region3e,
	region3f,
	region3g,
	region3h,
	region3i,
	region3j,
	region3k,
	region3l,
	region3m,
	region3n,
	region3o,
	region3p,
	region3q,
	region3r,
	region3s,
	region3t,
	region3u,
	region3v,
	region3w,
	region3x,
	region3y,
	region3z,
	boundary_ab,
	boundary_cd,
	boundary_ef,
	boundary_gh,
	boundary_ij,
	boundary_jk,
	boundary_mn,
	boundary_op,
	boundary_qu,
	boundary_rx,
	boundary_uv,
	boundary_wx
} water_properties_region;




/*declatation of functions*/
double power1(double x, int y);
double power2(double x, double y);
double ln(double x);
water_properties_region water_properties_get_region(double temperature, double pressure);
double water_properties_specific_volume(water_properties_region region, double temperature, double pressure);
double water_properties_specific_isobaric_heat_capacity(water_properties_region region, double temperature, double pressure);
double water_properties_specific_isochoric_heat_capacity(water_properties_region region, double temperature, double pressure);
double water_properties_specific_internal_energy(water_properties_region region, double temperature, double pressure);
double water_properties_specific_enthalpy(water_properties_region region, double temperature, double pressure);
double water_properties_specific_entropy(water_properties_region region, double temperature, double pressure);
double water_properties_speed_of_sound(water_properties_region region, double temperature, double pressure);
double water_properties_isobaric_cubic_expansion_coefficient(water_properties_region region, double temperature, double pressure);
double water_properties_isothermal_compressibility(water_properties_region region, double temperature, double pressure);
double water_properties_Ts(double pressure);
double water_properties_ps(double temperature);
double water_properties_TB23(double pressure);
double water_properties_pB23(double temperature);
void water_properties_constans_region23(int i, double *n);
void water_properties_constants_region1(int i, int *I, int *J, double *n);
void water_properties_constants_region2_0(int i, int *J, double *n);
void water_properties_constants_region2_r(int i, int *I, int *J, double *n);
void water_properties_constants_region2_meta_0(int i, int *J, double *n);
void water_properties_constants_region2_meta_r(int i, int *I, int *J, double *n);
void water_properties_constants_region3(int i, int *I, int *J, double *n);
void water_properties_constants_region4(int i, double *n);
void water_properties_constants_region5_0(int i, int *J, double *n);
void water_properties_constants_region5_r(int i, int *I, int *J, double *n);

void water_properties_specific_volume_region3_get_constants2(water_properties_region region, double *v,
															 double *p, double *T, int *N, double *a,
															 double *b, double *c, double *d, double *e);
void water_properties_specific_volume_region3_get_constants(water_properties_region region,
															int i, int *I, int *J, double *n);
water_properties_region water_properties_specific_volume_region3_get_region(double temperature, double pressure);
double water_properties_region3_temperature_boundary(water_properties_region boundary, double pressure);
void water_properties_specific_volume_region3_get_boundary_constants(water_properties_region boundary,
																	 int i, int *I, double *n);
double water_properties_specific_volume_region3(water_properties_region region,
												double temperature, double pressure);

double water_properties_surface_tension(double temperature);
double water_properties_dynamic_viscosity(double temperature, double pressure);
double water_properties_dynamic_viscosity_psi0(double reduced_temperature);
double water_properties_dynamic_viscosity_psi1(double reduced_temperature, double reduced_density);
void water_properties_dynamic_viscosity_psi0_constants(int i, double *n);
void water_properties_dynamic_viscosity_psi1_constants(int i, int *I, int *J, double *n);
double water_properties_thermal_conductivity(double temperature, double pressure);
double water_properties_thermal_conductivity_lambda0(double reduced_temperature);
double water_properties_thermal_conductivity_lambda1(double reduced_density);
double water_properties_thermal_conductivity_lambda2(double reduced_temperature, double reduced_density);
void water_properties_thermal_conductivity_lambda0_constants(int i, double *n);
void water_properties_thermal_conductivity_lambda1_constants(int i, double *n);
void water_properties_thermal_conductivity_lambda2_constants(int i, double *n);
double water_properties_dielectric_constant(double temperature, double pressure);
double water_properties_dielectric_constant_g(double reduced_temperature, double reduced_density);
void water_properties_dielectric_constant_constants(int i, int *I, double *J, double *n);
double water_properties_refractive_index(double temperature, double pressure, double wavelength);
void water_properties_refractive_index_constants(int i, double *a);

#endif