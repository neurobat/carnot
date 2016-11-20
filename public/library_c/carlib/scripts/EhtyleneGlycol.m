%EthyleneGlycol

%%Quelle: Thermophysikals properties of Brines - M.Code Engineering Zurich 2011
%General Equation for Density, thermal conductivity, specific thermal capacity: 
%Px = A1 + A2*Z + A3*273.15/T + A4*Z*273.15/T + A5*(273.15/T)^2
%Dynamic Viscosoty, Prandl Number
%LN(Px) = A1 + A2*Z + A3*273.15/T + A4*Z*273.15/T + A5*(273.15/T)^2
%Freezing Temperature Equation:
%T_f/273.15 = A0 + A1*Z + A2*Z^2

%Z[%]=Concetration; T[K]; rho[kg/m^3]; cp[kJ/kg K]; lambda[W/mK]

rho_EG_F = 658.49825 + (-54.81501)*Z + 664.71643*273.15/T + 232.71643*Z*273.15/T + (-322.61661)*(273.15/T)^2;
cp_EG_F = 5.36449 + 0.78863*Z + (-2.59001)*273.15/T + (-2.73187)*Z*273.15/T + 1.43759*(273.15/T)^2;
lambda_EG_F = 0.83818 + (-1.37620)*Z + (-0.07629)*273.15/T + 1.07720*Z*273.15/T + (-0.20174)*(273.15/T)^2;

%%Density WATER!!!
%2003, The Dow Chemical Company, A Guide to Glycols
rho_PG_T = [-20 -10 0 1 2 3 4 5 6 7 8 9 10 15 20 25 30 35 40 50 60 70 80 90 95 100]; %in °C
rho_PG_D = [0.993490 0.998137 0.999868 0.999927 0.999968 0.999992 1.000000 0.999992 0.999968 0.999930 0.999877 0.999809 0.999728 0.999129 0.998234 0.997075 0.995678 0.994063 0.992247 0.988066 0.983226 0.977793 0.971819 0.965340 0.961920 0.958384]; % in g/ml
rho_PG_D = rho_PG_D';

%%Vaporpressure
% Quelle: TRCVP, Vapor Pressure Database, Version 2.2P, Thermodynamic Research Center, Texas A&M University, College Station, TX.
vp_EG_D = [1 10 100 1000 10000 100000]; %in Pa
t_EG_D = [2 24 51.1 86.1 132.5 196.9]; %in °C
t_EG_D = t_EG_D';

%Freezing Limit
%Quelle: Brine Properties
Tf = (1 - 0.06982*Xi - 0.35780*Xi^2)*273.15;


