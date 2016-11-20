function [t, p, mix, dref, dsim0] = data_siliconoil(prop)
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
% function is used by: verify_fluidproperty
% this function calls:  --
% 
% Literature: 
% /1/   Teichrieb, H.: Bericht Carlib-Validierung, 
%       Hochschule Düsseldorf, 2016
% /2/   Syltherm 800 - Hersteller DOW - Productinformation

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
% 6.1.0     hf      created with data source of FHD             15nov2016
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

mix = 0;    % no fluid mixture, silicon oil is pure
p = 1e5;    % pressure is not relevant, assume atmospheric pressure
t = [-40 0 40 80 120 160 200 240 280 320 360 400]'; % temperature in °C

switch prop
    case 'heat_capacity' %  cp[J/kg/K]
        dref = [1.506 1.574 1.643 1.711 1.779 1.847 1.916 1.984 2.052 ...
            2.121 2.189 2.257]'*1e3; %[J/kg.K]
        dsim0 = [1402;1470;1538;1606;1674;1742;1810;1878;1946;2014;2082;2150];
        
    case 'density' % Density[kg/m3]
        dref = [990.61 953.16 917.07 881.68 846.35 810.45 773.33 734.35 ...
            692.87 648.24 599.83 547.00]'; % [kg/m³]
        dsim0 = [1020.028;983.1000;946.1720;909.2440;872.3160;835.3880;...
            798.4600;761.5320;724.6040;687.6760;650.7480;613.820];
        
    case 'kinematic_viscosity' % kinematic Viscosity[mm2/s]
        dsim0 = [0.000321647825102500;8.10152448562593e-05;2.97138134985953e-05;...
            1.47364499659231e-05;9.20358593191592e-06;6.76495212267503e-06;...
            5.53756718338442e-06;4.85490884730221e-06;4.44552866976055e-06;...
            4.18568100184567e-06;4.01352055036061e-06;3.89570192699692e-06];
        disp('verifying kinematic_viscosity for silicon oir: using simulation data as reference')
        dref = dsim0;

    case 'thermal_conductivity' % thermalConductivity[W/m/K]    
        dref = [0.1463 0.1388 0.1312 0.1237 0.1162 0.1087 0.1012 0.0936 ...
            0.0861 0.0786 0.0711 0.0635]'; %[W/m.K]
        dsim0 = [0.146293589743590;0.138770512820513;0.131247435897436; ...
            0.123724358974359;0.116201282051282;0.108678205128205; ...
            0.101155128205128;0.0936320512820515;0.0861089743589746; ...
            0.0785858974358976;0.0710628205128207;0.0635397435897438];
        
    case 'vapourpressure' % vapour pressure [Pa]
        dref = [0.00 0.00 0.10 1.46 9.30 35 94.60 204.80 380.2 630.5 ...
            961.2 1373]'*1e3;
        dsim0 = [0;0;325.048492703459;4027.05972600475;17553.9732568430;...
            49891.6635543497;112178.141922352;217478.008115202;380626.603687328;...
            618113.030742144;947987.712661314;1389786.71679514];
    
    case 'enthalpy' % Enthalpy in 
        dsim0 = [-40801.120;0;37846.880;72739.520;104677.92;...
            133662.08;159692;182767.68;202889.12;220056.32;...
            234269.28;245528.0];
        dref = dsim0;
        disp('verifying enthalpy for silicon oir: using simulation data as reference')

    case 'saturationtemperature'
        %Satturationtemperature - Daten aus Vapourpressure übernommen
        dref = [-40 0 40 80 120 160 200 240 280 320 360 400]; %[°C]
        p = [0.02 0.06 0.10 1.46 9.30 35 94.60 204.80 380.2 630.5 961.2 1373]*1e3; %[Pa]  
        %t = 20; % temperature as dummy argument
        dsim0 = [-40 0 40 79.4593645733151 121.141649997190 159.860207377095 ...
            199.095995529893 239.419457999438 280.326624050780 320.944688613028 ...
            360.668415944534 399.016206176181];
        
    otherwise
        t = nan;
        dref = nan;
        dsim0 = nan;
end

