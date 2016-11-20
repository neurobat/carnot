%Baumwollsamenöl
%Cottonseed oil

%Datensammlung

%Dichte: g/cm³
rho_cot_D = [0.9319 0.9247 0.92 0.9145 0.9044 0.8912 0.8780 0.8778 0.8641];
%T in °C
Trho_cot_D = [0 10 20 25 40 59.8 79.8 80.4 101.1];
%Quellen: 
%      Wassertechnik - Abscheideranlagen von Fetten Ausschnitt aus DIN EN 1825-2:2002(D)
%       Density-Composition Data for Cottonseed Oil-solvent Mixtures von
%       Frank C. Magne New Orleans louisiana


%Wärmekapazität
%Quelle: Handbuch Verfahrenstechnik und Anlagenbau von Hans G. Hirschberg
cp_cot_F = 2060 + 11.5*t; %Bereich: -50 + -30 °C
cp_cot_F = 1930 + 1.25*t; %Bereich: 22 + 50 °C


%Enthalpie
%Quelle: Handbuch Verfahrenstechnik und Anlagenbau von Hans G. Hirschberg
h_cot_D = [-124.6 -106.5 -84.7 -71 -58.6 -39.1 -16.6 0 17 30.4 41.3 50.5 61.5 71.3 81.2];
Th_cot_D = [-40 -30 -25 -20 -15 -10 -5 0 5 10 15 20 25 30 35];