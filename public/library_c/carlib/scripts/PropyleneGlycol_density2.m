function [fitresult, gof] = PropyleneGlycol_density2(rho_PG_T, rho_PG_D)

%  Messdaten Laden
load('PropyleneGlycolData.mat');

%% Fit: 'untitled fit 1'.
%%Density WATER!!!
%2003, The Dow Chemical Company, A Guide to Glycols
rho_PG_D=rho_PG_D*1000;
[xData, yData] = prepareCurveData( rho_PG_T, rho_PG_D );

% Set up fittype and options.
ft = fittype( 'poly4' );
opts = fitoptions( ft );
opts.Lower = [-Inf -Inf -Inf -Inf -Inf];
opts.Upper = [Inf Inf Inf Inf Inf];

% Fit model to data.
[fitresult, gof] = fit( xData, yData, ft, opts );
disp('Goodness:');
disp(gof);

%Quelle: Thermophysikals properties of Brines - M.Code Engineering Zurich 2011
%General Equation for Density, thermal conductivity, specific thermal capacity: 
%Px = A1 + A2*Z + A3*273.15/T + A4*Z*273.15/T + A5*(273.15/T)^2
%Dynamic Viscosoty, Prandl Number
%LN(Px) = A1 + A2*Z + A3*273.15/T + A4*Z*273.15/T + A5*(273.15/T)^2
%Freezing Temperature Equation:
%T_f/273.15 = A0 + A1*Z + A2*Z^2

%Z[%]=Concetration; T[K]; rho[kg/m^3]; cp[kJ/kg K]; lambda[W/mK]

Trho_PG = [-50:5:200]+273.15;
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

%%Freezing Temperature
%Quelle: Brine Properties
Xi=[0 0.1 0.2 0.3 0.4 0.5 0.6];
Tf = (1 - 0.03736*Xi - 0.40050*Xi.*Xi)*273.15;
Tf_C=Tf-273.15; %in °C
rho_PG_Tf = 508.41109 + (-182.40820)*Xi + 965.76507*273.15./Tf + 280.29104*Xi*273.15./Tf + (-472.22510)*(273.15./Tf).^2;

            
%% Plot fit with data.
%subplot( 2, 1, 1 );
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
plot(Tf_C,rho_PG_Tf,'m-d','linewidth',1.5);
plot(fitresult, xData, yData,'k-s');
title('Propyleneglycole Source: M. Conde Engineering 2011');
legend( 'Xi=0.6','Xi=0.5','Xi=0.4','Xi=0.3','Xi=0.2','Xi=0.1','Xi=0','Xi carlib=0.6','Xi carlib=0','Freezing','DataWater');
% Label axes
xlabel( 'T [°C]' );
ylabel( 'rho [kg/m³]' );
grid on
hold off

% Plot fit with data.
% figure( 'Name', 'untitled fit 1' );
% h = plot( fitresult, xData, yData );
% legend( h, 'rho_PG_D vs. rho_PG_T', 'untitled fit 1', 'Location', 'NorthEast' );

%%Messwerte dichte Propyleneglycole
%Quelle: King Saud University
%xi=1==100% Propyleneglycol

for i=1:11
    for j=1:7
        rho_PG_xi01(1,j)=rho_PG_D2(1,j)*1000; %*1000=> EInheit auf kg/m³
        rho_PG_xi02(1,j)=rho_PG_D2(2,j)*1000;
        rho_PG_xi03(1,j)=rho_PG_D2(3,j)*1000;
        rho_PG_xi04(1,j)=rho_PG_D2(4,j)*1000;
        rho_PG_xi05(1,j)=rho_PG_D2(5,j)*1000;
        rho_PG_xi06(1,j)=rho_PG_D2(6,j)*1000;
        rho_PG_xi07(1,j)=rho_PG_D2(7,j)*1000;
        rho_PG_xi08(1,j)=rho_PG_D2(8,j)*1000;
        rho_PG_xi09(1,j)=rho_PG_D2(9,j)*1000;
        rho_PG_xi10(1,j)=rho_PG_D2(10,j)*1000;
        rho_PG_xi11(1,j)=rho_PG_D2(11,j)*1000;
    end
end
figure();
%subplot( 2, 1, 2 );
plot(t_KSU-273.15,rho_PG_xi01,'k--o');
hold on;
plot(t_KSU-273.15,rho_PG_xi02,'g--o');
plot(t_KSU-273.15,rho_PG_xi03,'b--o');
plot(t_KSU-273.15,rho_PG_xi04,'r--o');
plot(t_KSU-273.15,rho_PG_xi05,'c--o');
plot(t_KSU-273.15,rho_PG_xi06,'k--x');
plot(t_KSU-273.15,rho_PG_xi07,'g--x');
plot(t_KSU-273.15,rho_PG_xi08,'b--x');
plot(t_KSU-273.15,rho_PG_xi09,'r--x');
plot(t_KSU-273.15,rho_PG_xi10,'c--d');
plot(t_KSU-273.15,rho_PG_xi11,'g--d');
plot(Trho_PG-273.15,rho_PG_carF06,'k-s');
plot(Trho_PG-273.15,rho_PG_carF0,'r-s');
plot(Trho_PG-273.15,rho_PG_F06,'k');
plot(Trho_PG-273.15,rho_PG_F01,'b');
title('Propyleneglycole density Source:King Saud University');
legend('Xi=0.000','Xi=0.027','Xi=0.058','Xi=0.095','Xi=0.141','Xi=0.197','Xi=0.269','Xi=0.364','Xi=0.495','Xi=0.688','Xi=1.000','Xi carlib=0.6','Xi carlib=0','M.Conde Xi=0.6','M.Conde Xi=0.1');
% Label axes
xlabel( 'T [°C]' );
ylabel( 'rho [kg/m³]' );
grid on
hold off

%% Formel mit Nachkommastellen ausgeben
%coeffnames(fitresult)
coeff = coeffvalues(fitresult);
disp ('Coefficients with 10 decimal places:')
fprintf('p# %0.10f \n',coeff)

