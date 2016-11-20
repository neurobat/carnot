function [t, p, mix, dref, dsim0] = data_air(prop)
% function [t, mix, dref, dsim0] = data_air(prop)
% define the reference data from literature and simulation standard for 
% fluid properites of water, used to validate the carnot material 
% properties library carlib.c
% Simulation standard is the result of the fluid properties functions
% with the original Matlab version during the development of the function.
%   prop =  'density' in kg/m³
%           'heat_capacity' in J/kg/K
%           'thermal_conductivity' in W/m/K
%           'kinematic_viscosity' in mm²/s
%           'vapourpressure' in Pa
%           'enthalpy' in J/kg
%           'entropy' in J/K/kg
%           'specific_volume' in m³/kg
%           'evaporation_enthalpy' in J/kg
%           'saturation_temperature' in °C
%           'temperature_conductivity' in m^2/s
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
% Literature: --

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

mix = [0, 0.001];   % kg of water per kg of dry air
p = 1e5;            % pressure is atmospheric pressure
t = (20:20:80)';   % temperature in °C

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
        A = [1006.79562666400 1008.67074462440;1007.46648751200 1009.36334405920; ...
            1008.50712904800 1010.43308276680;1009.91209777600 1011.88096220960];
        dsim0(:,1,1) = A(:,1);
        dsim0(:,1,2) = A(:,2);
        disp('verifying heat capacity of air: using simulation data as reference')
        dref = dsim0;
        
    case 'density' % Density[kg/m3]
        A = [1.18932455597276 1.18591802412115;1.11336577864734 1.11017681229799;...
            1.04652707063910 1.04352954756451;0.987258936948650 0.984431173074090];
        dsim0(:,1,1) = A(:,1);
        dsim0(:,1,2) = A(:,2);
        disp('verifying density of air: using simulation data as reference')
        dref = dsim0;
        
    case 'kinematic_viscosity' % kinematic Viscosity[mm2/s]
        A = [1.53494677724000e-05 1.58967804314426e-05;1.72649636992000e-05 1.74491456731621e-05;1.92645312948000e-05 1.93291728757400e-05;2.13464140736000e-05 2.13646187192797e-05];
        dsim0(:,1,1) = A(:,1);
        dsim0(:,1,2) = A(:,2);
        disp('verifying kinematic viscosity of air: using simulation data as reference')
        dref = dsim0;
        
    case 'thermal_conductivity' % thermalConductivity[W/mK]    
        A = [0.0262898119350861 0.0262817454632947;0.0275875517948211 0.0275795692347217; ...
            0.0288789672672013 0.0288712871690940;0.0301639812461953 0.0301568434988194];
        dsim0(:,1,1) = A(:,1);
        dsim0(:,1,2) = A(:,2);
        disp('verifying thermal conductivity of air: using simulation data as reference')
        dref = dsim0;

    case 'vapourpressure' % vapour pressure [Pa]
        A = [0 160.513643659711;0 160.513643659711;0 160.513643659711;0 160.513643659711];
        dsim0(:,1,1) = A(:,1);
        dsim0(:,1,2) = A(:,2);
        disp('verifying vapourpressure of air: using simulation data as reference')
        dref = dsim0;
    
    case 'enthalpy' % Enthalpy in J/kg
        A = [20082.8211482003 22621.4113082003;40183.2958380965 42758.9716580965;...
            60307.2142298088 62919.9757098088;80460.1976104145 83110.0447504145];
        dsim0(:,1,1) = A(:,1);
        dsim0(:,1,2) = A(:,2);
        disp('verifying enthalpy of air: using simulation data as reference')
        dref = dsim0;

    case 'entropy' % entropy in J/kg/K
        A = [6847.28740959562 6840.75810591160;6913.61564662908 6907.26877849908;...
            6975.90865941901 6969.74262694716;7034.65360633607 7028.66632295481];
        dsim0(:,1,1) = A(:,1);
        dsim0(:,1,2) = A(:,2);
        disp('verifying entropy of air: using simulation data as reference')
        dref = dsim0;
    
    case 'specific_volume' % specific volume in m³/kg
        A = [0.840813380147598 0.843228604052183;0.898177417681120 0.900757418928675;...
            0.955541455214642 0.958286233805168;1.01290549274816 1.01581504868166];
        dsim0(:,1,1) = A(:,1);
        dsim0(:,1,2) = A(:,2);
        disp('verifying specific volume of air: using simulation data as reference')
        dref = dsim0;
    
    case 'evaporation_enthalpy' % vapour pressure [Pa]
        t = nan;
        dref = nan;
        dsim0 = nan;
    
    case 'saturationtemperature' % saturation temperature in °C
        A = [-273.150000000000 -15.3120223918958];
        dsim0(:,1,1) = A(:,1);
        dsim0(:,1,2) = A(:,2);
        disp('verifying saturationtemperature of air: using simulation data as reference')
        dref = dsim0;
    
    case 'temperature_conductivity' % temperature conductivity
        A = [2.19556234166694e-05 2.19710144833447e-05; ...
            2.45948786767177e-05 2.46120505021783e-05; ...
            2.73622759946639e-05 2.73812858251039e-05; ...
            3.02533877499907e-05 3.02740901261199e-05];
        dsim0(:,1,1) = A(:,1);
        dsim0(:,1,2) = A(:,2);
        disp('verifying temperature_conductivity of air: using simulation data as reference')
        dref = dsim0;
    
    otherwise
        t = nan;
        dref = nan;
        dsim0 = nan;
end

