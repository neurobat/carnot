function [t, p, mix, dref, dsim0] = data_cottonoil(prop)
% function [t, mix, dref, dsim0] = data_cottonoil(prop)
% define the reference data from literature and simulation standard for 
% fluid properites of cotton oil, used to validate the carnot material 
% properties library carlib.c
% Simulation standard is the result of the fluid properties functions
% with the original Matlab version during the development of the function.
%   prop =  'heat_capacity' in J/kg/K
%           'density' in kg/m³
%           'kinematic_viscosity' in mm²/s
%           'thermal_conductivity' in W/m/K
%           'vapourpressure' in Pa
% output:
%   t       vector with temperatures for the reference point
%   p       vector with the pressures (same length as t)
%   mix     vector with fluid_mixtures (same length as t)
%   dref    vector with the reference data (same length as t)
%   dsim0   vector with the data from initial simulation (same length as t)
% 
% function calls:
% function is used by: verify_density, verify_heat_capacity,
% this function calls:  --
% 
% Literature: 
% /1/   Ester C. de Souza*1, Luiz F. O. Friedel2, George E. Totten3, 
%       Lauralice C. F. Canale: Quenching and Heat Transfer Properties of 
%       Aged and Unaged Vegetable Oils
%       Journal of Petroleum Science Research (JPSR) Volume 2 Issue 1, January 2013
% /2/   Magne, Hughes, Skau: Density-composition for Cottenseed
%       Oil-Solvents Mixtures; The Journal of the American Oil Chemistry
%       Society, December 1950

% ***********************************************************************
% This file is part of the CARNOT Blockset.
% 
% Copyright (c) 1998-2016, Solar-Institute Juelich of the FH Aachen.
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
% **********************************************************************
% D O C U M E N T A T I O N
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
% author list:     hf -> Bernd Hafner
%
% version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
%
% Version   Author  Changes                                     Date
% 6.1.0     hf      created with data source of FHD             12nov2016
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

mix = 0;    % no fluid mixture, cotton seed oil is pure - a pure mixture of approx. 1e4 components ;-)
p = 1e5;    % pressure is not relevant, assume atmospheric pressure

% dref are the reference (literature) values
% dsim0 are the reference simulated values for the original Matlab version
% dref and dsim0 be a 3-dimensional matrix with:
% row 1..N, colon 1, page 1: ref-value for all temperatures at p(1), mix(1)
% row 1..N, colon 2, page 1: ref-value for all temperatures at p(2), mix(1)
% row 1..N, colon M, page 1: ref-value for all temperatures at p(M), mix(1)
% row 1..N, colon 1, page 2: ref-value for all temperatures at p(1), mix(2)
% row 1..N, colon 2, page 2: ref-value for all temperatures at p(2), mix(2)
% row 1..N, colon M, page 2: ref-value for all temperatures at p(M), mix(2)


switch prop
    case 'heat_capacity' %  cp[J/kg/K]
        t1 = -50:-30;
        t2 = 22:50;
        t = [t1'; t2'];
        %Quelle: Handbuch Verfahrenstechnik und Anlagenbau von Hans G. Hirschberg
        dref1 = 2060 + 11.5*t1;     % Bereich: -50 + -30 °C
        dref2 = 1930 + 1.25*t2;     % Bereich: 22 + 50 °C
        dref = [dref1'; dref2'];
        dsim0 = [1438.28;1442.4944;1446.7088;1450.9232;1455.1376;1459.352;...
            1463.5664;1467.7808;1471.9952;1476.2096;1480.424;1484.6384;...
            1488.8528;1493.0672;1497.2816;1501.496;1505.7104;1509.9248;...
            1514.1392;1518.3536;1522.568;1741.7168;1745.9312;1750.1456;...
            1754.360;1758.5744;1762.7888;1767.0032;1771.2176;1775.432;...
            1779.6464;1783.8608;1788.0752;1792.2896;1796.504;1800.7184;...
            1804.9328;1809.1472;1813.3616;1817.576;1821.7904;1826.0048;...
            1830.2192;1834.4336;1838.648;1842.8624;1847.0768;1851.2912;...
            1855.5056;1859.72];
        
    case 'density' % Density[kg/m3]
        % Quellen: 
        % Wassertechnik - Abscheideranlagen von Fetten Ausschnitt aus DIN EN 1825-2:2002(D)
        % Frank C. Magne: Density-Composition Data for Cottonseed
        %       Oil-solvent Mixtures, New Orleans louisiana
        t = [0; 10; 20; 25; 40; 59.8; 79.8; 80.4; 101.1];
        dref = [931.9; 924.7; 920; 914.5; 904.4; 891.2; 878; 877.8; 864.1];
        dsim0 = [935; 928.1940; 921.3880; 917.9850; ...
            907.7760; 894.30012; 880.68812; 880.27976; 866.19134];
        
    case 'kinematic_viscosity' % kinematic Viscosity[mm2/s]
        t = (10:10:150)';
        dsim0 = [0.000679900280000000;7.33780300000000e-05;4.76773417283951e-05;...
            3.37962800000000e-05;2.47452400000000e-05;1.87027028395062e-05;...
            1.45435094877135e-05;1.15889108593750e-05;9.42862872732815e-06;...
            7.80863000000000e-06;6.56682121986203e-06;5.59662182098766e-06;...
            4.82596789608207e-06;4.20488526863807e-06;3.69792246913580e-06];
        disp('verifying kinematic_viscosity for cotton oil: using simulation data as reference')
        dref = dsim0;
        
    case 'thermal_conductivity' % thermalConductivity[W/mK]    
        t = (10:10:150)';
        dsim0 = [0.167658000000000;0.166316000000000;0.164974000000000; ...
            0.163632000000000;0.162290000000000;0.160948000000000;0.159606000000000; ...
            0.158264000000000;0.156922000000000;0.155580000000000;0.154238000000000; ...
            0.152896000000000;0.151554000000000;0.150212000000000;0.148870000000000];
        disp('verifying thermal_conductivity for cotton oil: using simulation data as reference')
        dref = dsim0;
        
    case 'vapourpressure' % vapour pressure [Pa]
        % no data available for vapour pressure of cotton oil
        t = nan;
        dref = nan;
        dsim0 = nan;
    
    case 'enthalpy' % Enthalpy in 
        t = [0 5 10 15 20 25 30 35]';
        dsim0 = [0;4657.98500000000;9281.94000000000;13871.8650000000; ...
            18427.7600000000;22949.6250000000;27437.4600000000;31891.2650000000];
        dref = dsim0;
        disp('verifying enthalpy for cotton oil: using simulation data as reference')
        
    otherwise
        t = nan;
        dref = nan;
        dsim0 = nan;
end

