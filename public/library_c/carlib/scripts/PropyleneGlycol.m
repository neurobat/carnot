%PropyleneGlycol

%%Quelle: Thermophysikals properties of Brines - M.Code Engineering Zurich 2011
%General Equation for Density, thermal conductivity, specific thermal capacity: 
%Px = A1 + A2*Z + A3*273.15/T + A4*Z*273.15/T + A5*(273.15/T)^2
%Dynamic Viscosoty, Prandl Number
%LN(Px) = A1 + A2*Z + A3*273.15/T + A4*Z*273.15/T + A5*(273.15/T)^2
%Freezing Temperature Equation:
%T_f/273.15 = A0 + A1*Z + A2*Z^2

%Z[%]=Concetration; T[K]; rho[kg/m^3]; cp[kJ/kg K]; lambda[W/mK]

rho_PG_F = 508.41109 + (-182.40820)*Z + 965.76507*273.15/T + 280.29104*Z*273.15/T + -472.22510*(273.15/T)^2;
cp_PG_F = 4.47642 + 0.60863*Z + (-0.71497)*273.15/T + (-1.93855)*Z*273.15/T + 0.47873*(273.15/T)^2;
lambda__PG_F = 1.18886 + (-1.49110)*Z + (-0.69682)*273.15/T + 1.13633*Z*273.15/T + 0.06735*(273.15/T)^2;

%%Density WATER!!!
%2003, The Dow Chemical Company, A Guide to Glycols
rho_PG_T = [-20 -10 0 1 2 3 4 5 6 7 8 9 10 15 20 25 30 35 40 50 60 70 80 90 95 100]; %in °C
rho_PG_D = [0.993490 0.998137 0.999868 0.999927 0.999968 0.999992 1.000000 0.999992 0.999968 0.999930 0.999877 0.999809 0.999728 0.999129 0.998234 0.997075 0.995678 0.994063 0.992247 0.988066 0.983226 0.977793 0.971819 0.965340 0.961920 0.958384]; % in g/ml
rho_PG_D = rho_PG_D';

%%Vaporpressure
% Quelle: TRCVP, Vapor Pressure Database, Version 2.2P, Thermodynamic Research Center, Texas A&M University, College Station, TX.
p_PG_D = [1 10 100 1000 10000 100000]; %in Pa
vp_PG_D = [-11 13 42 78 125 187.2]; %in °C
vp_PG_D = vp_PG_D';

%Freezing Limit
%Quelle: Brine Properties
Tf = (1 - 0.03736*Xi - 0.40050*Xi^2)*273.15;

%%Messwerte dichte Propyleneglycole
%Quelle: King Saud University
%xi=1==100% Propyleneglycol
xi_KSU = [0.000 0.027 0.058 0.095 0.141 0.197 0.269 0.364 0.495 0.688 1.000]; %Zeilen lines
t_KSU = [293 298 303 308 313 318 323 ]; %Spalten columns
rho_PG_D2=[0.9978 0.9958 0.9938 0.9918 0.9884 0.9840 0.9715
1.0051 1.0031 1.0007 0.9983 0.9951 0.9912 0.9826
1.0136 1.0113 1.0086 1.0063 1.0029 0.9989 0.9917
1.0227 1.0202 1.0166 1.0136 1.0103 1.0065 1.0009 
1.0312 1.0282 1.0242 1.0207 1.0167 1.0125 1.0065
1.0365 1.0333 1.0294 1.0253 1.0233 1.0151 1.0107
1.0408 1.0376 1.0329 1.0288 1.0244 1.0200 1.0160
1.0427 1.0393 1.0347 1.0317 1.0294 1.0216 1.0159 
1.0425 1.0389 1.0342 1.0302 1.0257 1.0177 1.0119
1.0401 1.0367 1.0335 1.0285 1.0233 1.0142 1.0082
1.0353 1.0323 1.0276 1.0231 1.0197 1.0114 1.0069];
