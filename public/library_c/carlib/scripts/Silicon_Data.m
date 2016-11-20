%Silicon
%Quelle: Syltherm 800 - Hersteller DOW - Productinformation

%Density - Dichte
rho_S_T = [-40 0 40 80 120 160 200 240 280 320 360 400];
rho_S_D = [990.61 953.16 917.07 881.68 846.35 810.45 773.33 734.35 692.87 648.24 599.83 547.00]; % [kg/m³]

%specifi heat - Wärmekapazität
cp_S_T = [-40 0 40 80 120 160 200 240 280 320 360 400];
cp_S_D = [1.506 1.574 1.643 1.711 1.779 1.847 1.916 1.984 2.052 2.121 2.189 2.257]; %[kj/kg.K]

%Thermal Conductivity - Wärmeleitfähigkeit
c_S_T = [-40 0 40 80 120 160 200 240 280 320 360 400];
c_S_D = [0.1463 0.1388 0.1312 0.1237 0.1162 0.1087 0.1012 0.0936 0.0861 0.0786 0.0711 0.0635]; %[W/m.K]

%Vaporpressure - Sättigungsdruck
vp_S_T = [-40 0 40 80 120 160 200 240 280 320 360 400]; %[°C]
vp_S_D = [0.00 0.00 0.10 1.46 9.30 35 94.60 204.80 380.2 630.5 961.2 1373]; %[kPa]

%Satturationtemperature - Daten aus Vapourpressure übernommen
st_S_T = [40 80 120 160 200 240 280 320 360 400]; %[°C]
st_S_D = [0.10 1.46 9.30 35 94.60 204.80 380.2 630.5 961.2 1373]; %[kPa]