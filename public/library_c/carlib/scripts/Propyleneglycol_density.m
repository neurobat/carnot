%Propyleneglycol_density

%Quelle: Thermophysikals properties of Brines - M.Code Engineering Zurich 2011
%General Equation for Density, thermal conductivity, specific thermal capacity: 
%Px = A1 + A2*Z + A3*273.15/T + A4*Z*273.15/T + A5*(273.15/T)^2
%Dynamic Viscosoty, Prandl Number
%LN(Px) = A1 + A2*Z + A3*273.15/T + A4*Z*273.15/T + A5*(273.15/T)^2
%Freezing Temperature Equation:
%T_f/273.15 = A0 + A1*Z + A2*Z^2

%Z[%]=Concetration; T[K]; rho[kg/m^3]; cp[kJ/kg K]; lambda[W/mK]

Trho_PG = [-50:5:150]+273.15;
T=Trho_PG';
Z=0;
rho_PG_F0 = 508.41109 + (-182.40820)*Z + 965.76507*273.15./T + 280.29104*Z*273.15./T + (-472.22510)*(273.15./T).^2;
Z=0.1;
rho_PG_F01 = 508.41109 + (-182.40820)*Z + 965.76507*273.15./T + 280.29104*Z*273.15./T + (-472.22510)*(273.15./T).^2;
Z=0.2;
rho_PG_F02 = 508.41109 + (-182.40820)*Z + 965.76507*273.15./T + 280.29104*Z*273.15./T + (-472.22510)*(273.15./T).^2;
Z=0.3;
rho_PG_F03 = 508.41109 + (-182.40820)*Z + 965.76507*273.15./T + 280.29104*Z*273.15./T + (-472.22510)*(273.15./T).^2;
Z=0.4;
rho_PG_F04 = 508.41109 + (-182.40820)*Z + 965.76507*273.15./T + 280.29104*Z*273.15./T + (-472.22510)*(273.15./T).^2;
Z=0.5;
rho_PG_F05 = 508.41109 + (-182.40820)*Z + 965.76507*273.15./T + 280.29104*Z*273.15./T + (-472.22510)*(273.15./T).^2;
Z=0.6;
rho_PG_F06 = 508.41109 + (-182.40820)*Z + 965.76507*273.15./T + 280.29104*Z*273.15./T + (-472.22510)*(273.15./T).^2;

%%CARLIB
xi = 60;   
t=T-273.15;
			rho_PG_car = t.*(-6.845166114722718e-003  + xi.*( 1.598552881093090e-004 + xi.*(-2.500513947679818e-006 + xi.*( 1.353169632549166e-008))) + t.*( 2.199819078440755e-005  + xi.*(-9.643408179314126e-007 +xi.*( 2.189831042031030e-008 + xi.*(-1.318311789959629e-010)))));
			rho_PG_carF06 = 9.998510249903282e+002 + xi.*( 1.402898851698828e+000 + xi.*( 4.720597537855296e-003 + xi.*(-5.932727559791945e-005))) + t.*( 5.547642027503766e-002  + xi.*(-8.269670418186260e-003 + xi.*(-4.776070860890714e-005 + xi.*( 6.261556797531848e-007))) + rho_PG_car);
xi = 0;
			rho_PG_car = t.*(-6.845166114722718e-003  + xi.*( 1.598552881093090e-004 + xi.*(-2.500513947679818e-006 + xi.*( 1.353169632549166e-008))) + t.*( 2.199819078440755e-005  + xi.*(-9.643408179314126e-007 +xi.*( 2.189831042031030e-008 + xi.*(-1.318311789959629e-010)))));
			rho_PG_carF0 = 9.998510249903282e+002 + xi.*( 1.402898851698828e+000 + xi.*( 4.720597537855296e-003 + xi.*(-5.932727559791945e-005))) + t.*( 5.547642027503766e-002  + xi.*(-8.269670418186260e-003 + xi.*(-4.776070860890714e-005 + xi.*( 6.261556797531848e-007))) + rho_PG_car);

% Plot fit with data.
plot(Trho_PG-273.15,rho_PG_F06,'k')
hold on
plot(Trho_PG-273.15,rho_PG_F05,'--g')
plot(Trho_PG-273.15,rho_PG_F04,'--b')
plot(Trho_PG-273.15,rho_PG_F03,'--r')
plot(Trho_PG-273.15,rho_PG_F02,'g')
plot(Trho_PG-273.15,rho_PG_F01,'b')
plot(Trho_PG-273.15,rho_PG_F0,'r')
plot(Trho_PG-273.15,rho_PG_carF06,'k-o');
plot(Trho_PG-273.15,rho_PG_carF0,'r-o');
title('Propyleneglycole Source: M. Conde Engineering 2011');
legend( 'Xi=0.6','Xi=0.5','Xi=0.4','Xi=0.3','Xi=0.2','Xi=0.1','Xi=0','Xi carlib=0.6','Xi carlib=0');
% Label axes
xlabel( 'T [�C]' );
ylabel( 'rho [kg/m�]' );
grid on
