% script file to determine the temperature dependant function for the
% density, heat capacity, kinematic viscosity 
% of Tyfocor LS
% data from Tyforop Chemie, Hamburg

% This file is part of the CARNOT Blockset.
% 
% Copyright (c) 1998-2015, Solar-Institute Juelich of the FH Aachen.
% Additional Copyright for this file see list auf authors.
% All rights reserved.
% 
% Redistribution and use in source and binary forms, with or without 
% modification, are permitted provided that the following conditions are 
% met:
% 
% 1. Redistributions of source code must retain the above copyright notice, 
%    this list of conditions and the following disclaimer.
% 
% 2. Redistributions in binary form must reproduce the above copyright 
%    notice, this list of conditions and the following disclaimer in the 
%    documentation and/or other materials provided with the distribution.
% 
% 3. Neither the name of the copyright holder nor the names of its 
%    contributors may be used to endorse or promote products derived from 
%    this software without specific prior written permission.
% 
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE 
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF 
% THE POSSIBILITY OF SUCH DAMAGE.
% file history
% author list: hf -> Bernd Hafner
%
% version: MajorVersionOfFunction.SubversionOfFunction
% 
% version   author  changes                                     date
% 1.0     hf      created                                     11feb2009


% T[°C] Chaleur massique [kJ/kgK]	Densité [kg/m3]	
%       Viscosité cinématique [mm2/s]	Conductivité thermique [W/mK]
%       Coefficient d’expansion cubique [x 10-5/K]   

data = [-25    3420    1055    85.0    0.382    41.5; ...
        -20    3440    1053    57.1    0.385    43  ; ...
        -10    3480    1049    26.9    0.392    46  ; ...
          0    3520    1045    14.5    0.399    49  ; ...
         10    3560    1040    7.90    0.406    52.5; ... 
         20    3600    1034    4.95    0.413    56  ; ...
         30    3640    1029    3.40    0.420    59  ; ...
         40    3680    1021    2.52    0.427    62.5; ...
         50    3720    1015    1.91    0.434    66  ; ...
         60    3760    1008    1.66    0.442    69  ; ...
         70    3800    1001    1.42    0.449    72  ; ...
         80    3840     993    1.08    0.456    75  ; ...
         90    3880     986    0.81    0.462    78  ; ...
        100    3920     977    0.59    0.469    81  ; ...
        110    3960     969    0.38    0.476    84  ; ...
        120    3990     959    0.19    0.483    87  ];

% T [°C]    Pression de vapeur [Pa]
datap = [40    0.04e5; ...
         50    0.12e5; ...
         60    0.19e5; ...
         70    0.29e5; ...
         80    0.42e5; ...
         90    0.62e5; ...
         100   0.90e5; ...
         110   1.40e5; ...
         120   1.80e5; ...
         130   2.50e5; ...
         140   3.20e5; ...
         150   4.20e5; ...
         160   5.60e5; ...
         170   7.10e5; ...
         180   9.20e5; ...
         190   12.0e5; ...
         200   14.9e5  ]; 

% heat capacity
T = data(:,1);
M = data(:,2);
Tfit = -30:150;
cp = polyfit(T, M, 1);
% sum(abs(M - polyval(cp, M)))
% disp(M')
cpd = polyval(cp, T);
disp(' ')
disp('heat capacity')
disp(cpd)
figure(1)
plot(T,M,'x', Tfit,polyval(cp, Tfit))
title('Heat Capacity Tyfocor LS')
xlabel('Temperature in °C')
ylabel('heat capacity in J/(kg*K)')
legend('measurement','polyfit')
s = sprintf('cp = (%e) *T + (%e)', cp(1), cp(2));
text(0.3, 0.1, s, 'Units','normalized')
disp(s)
set(gcf, 'Name', 'Heat_Capacity');

% density in kg/m³
T = data(:,1);
M = data(:,3);
Tfit = -30:150;
rho = polyfit(T, M, 3);
% sum(abs(M - polyval(rho, T)))
% disp(M')
rhod = polyval(rho, T);
disp(' ')
disp('density')
disp(rhod)
figure(2)
plot(T,M,'x', Tfit,polyval(rho, Tfit))
title('Density Tyfocor LS')
xlabel('Temperature in °C')
ylabel('density in kg/m³')
legend('measurement','polyfit')
s = sprintf('rho = (%e)*T^3 + (%e)*T^2 + (%e)*T + (%e)', rho(1), rho(2), rho(3), rho(4));
disp(s)
s = sprintf('rho = (%e)*T^3 + (%e)*T^2 ', rho(1), rho(2));
text(0.05, 0.2, s, 'Units','normalized')
s = sprintf('      + (%e)*T + (%e)', rho(3), rho(4));
text(0.05, 0.1, s, 'Units','normalized')
set(gcf, 'Name', 'Density');

% thermal conductivity
T = data(:,1);
M = data(:,5);
Tfit = -30:150;
lambda = polyfit(T, M, 1);
% sum(abs(M - polyval(lambda, T)))
% disp(M')
ld = polyval(lambda, T);
disp(' ')
disp('thermal conductivity')
disp(ld)
figure(3)
plot(T,M,'x', Tfit,polyval(lambda, Tfit))
title('Thermal Conductivity Tyfocor LS')
xlabel('Temperature in °C')
ylabel('thermal conductivity in W/(m*K)')
legend('measurement','polyfit')
s = sprintf('lambda = (%e)*T + (%e)', lambda(1), lambda(2));
text(0.1, 0.1, s, 'Units','normalized')
disp(s)
set(gcf, 'Name', 'thermal_conductivity');

% viscosity
T = data(:,1);
M = log(data(:,4)*1e-6);
Tfit = -30:150;
nue = polyfit(T, M, 5);
% sum(abs(M - polyval(nue, T)))
% disp(exp(M)')
nued = exp(polyval(nue, T));
disp(' ')
disp('viscosity')
disp(nued)
figure(4)
plot(T,M,'x', Tfit,polyval(nue, Tfit))
title('Kinematic Viscosity Tyfocor LS')
xlabel('Temperature in °C')
ylabel('log(viscosity) in m²/s')
legend('measurement','polyfit')
s = sprintf('nue = exp [ (%e)*T^4 + (%e)*T^3 + (%e)*T^2 + (%e)*T + (%e)]', nue(1), nue(2), nue(3), nue(4), nue(5));
disp(s)
s = sprintf('nue = exp [ (%e)*T^4 + (%e)*T^3 ', nue(1), nue(2));
text(0.05, 0.2, s, 'Units','normalized')
s = sprintf('    + (%e)*T^2 + (%e)*T + (%e) ]', nue(3), nue(4), nue(5));
text(0.05, 0.1, s, 'Units','normalized')
set(gcf, 'Name', 'Kinematic_Viscosity_Fit');

T = data(:,1);
M = data(:,4)*1e-6;
Tfit = -30:150;
figure(5)
plot(T,M,'x', Tfit,exp(polyval(nue, Tfit)))
title('Kinematic Viscosity Tyfocor LS')
xlabel('Temperature in °C')
ylabel('viscosity in m²/s')
legend('measurement','polyfit')
s = sprintf('nue = exp [ (%e)*T^4 + (%e)*T^3 + (%e)*T^2 + (%e)*T + (%e)]', nue(1), nue(2), nue(3), nue(4), nue(5));
s = sprintf('nue = exp [ (%e)*T^4 + (%e)*T^3 ', nue(1), nue(2));
text(0.1, 0.8, s, 'Units','normalized')
s = sprintf('    + (%e)*T^2 + (%e)*T + (%e) ]', nue(3), nue(4), nue(5));
text(0.1, 0.7, s, 'Units','normalized')
set(gcf, 'Name', 'Kinematic_Viscosity_Data');


% vapour pressure
T = datap(:,1).^0.25;
M = log(datap(:,2));
Tfit = [30:200].^0.25;
vp = polyfit(T, M, 1);
% sum(abs(M - polyval(vp, T)))
% disp(exp(M)')
vpd = exp(polyval(vp, T));
disp(' ')
disp('vapour pressure')
disp(vpd)
figure(6)
plot(T,M,'x', Tfit,polyval(vp, Tfit))
title('Vapour Pressure Tyfocor LS')
xlabel('(Temperature)^0^.^2^5 in °C')
ylabel('log(vapour pressure) in Pa')
legend('measurement','polyfit','Location','Best')
s = sprintf('vp = exp [ (%e)*T^0^.^2^5 + (%e) ]', vp(1), vp(2));
disp(s)
text(0.2, 0.1, s, 'Units','normalized')
set(gcf, 'Name', 'Vapour_Pressure_Fit');

T = datap(:,1);
M = datap(:,2);
Tfit = [30:200];
figure(7)
plot(T,M,'x', Tfit,exp(polyval(vp, Tfit.^0.25)))
title('Vapour Pressure Tyfocor LS')
xlabel('Temperature in °C')
ylabel('Vapour Pressure in Pa')
legend('measurement','polyfit','Location','Best')
s = sprintf('vp = exp [ (%e)*T^0^.^2^5 + (%e) ]', vp(1), vp(2));
text(0.05, 0.5, s, 'Units','normalized')
set(gcf, 'Name', 'Vapour_Pressure_Data');

% PDF Datei erzeugen
% for fig = 1:7
%     set(fig,'PaperType','A3','NumberTitle','off','PaperOrientation','landscape', ... 
%        'PaperUnits','centimeters', 'PaperPosition',[0.5 0.5 41.45 29.18]); 
%     print(fig, '-dpdf', '-r100', [get(fig, 'Name'),'.pdf']);
%     % print(fig, '-djpeg', [outFile(1:end-4),'_hist1.jpg']);
%     % close(fig);
% end
