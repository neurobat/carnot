function [t, p, mix, dref, dsim0] = data_waterglycol(prop)
% function [t, mix, dref, dsim0] = data_waterglycol(prop)
% define the reference data from literature and simulation standard for 
% fluid properites of water-ethylen-glycol mixtures, used to validate the 
% carnot material properties library carlib.c
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
% Literature: 
% M.Conde: Thermophysikals properties of Brines -  Engineering Zurich 2011
% TRCVP, Vapor Pressure Database, Version 2.2P, Thermodynamic 
%   Research Center, Texas A&M University, College Station, TX
% Teichrieb, H.: Bericht Carlib-Validierung, Hochschule Düsseldorf, 2016


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
% 6.1.0     hf      created with data Teichrieb 2016            16nov2016
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

% dref are the reference (literature) values
% dsim0 are the reference simulated values for the original Matlab version
% dref and dsim0 be a 3-dimensional matrix with:
% row 1..N, colon 1, page 1: ref-value for all temperatures at p(1), mix(1)
% row 1..N, colon 2, page 1: ref-value for all temperatures at p(2), mix(1)
% row 1..N, colon M, page 1: ref-value for all temperatures at p(M), mix(1)
% row 1..N, colon 1, page 2: ref-value for all temperatures at p(1), mix(2)
% row 1..N, colon 2, page 2: ref-value for all temperatures at p(2), mix(2)
% row 1..N, colon M, page 2: ref-value for all temperatures at p(M), mix(2)

mix = 0.5;          % mixture  ( = concentration )
p = 1e5;            % pressure is not relevant, assume atmospheric pressure
t = (-20:20:100)';  % temperature in °C
T = t+273.15;       % temperature in K

switch prop
    case 'heat_capacity' %  cp[J/kg/K]
        % M.Conde: Thermophysikals properties of Brines -  Engineering Zurich 2011
        % General Equation for Density, thermal conductivity, specific thermal capacity: 
        % Px = A1 + A2*Z + A3*273.15/T + A4*Z*273.15/T + A5*(273.15/T)^2
        % Z = Concetration; T[K]
        dref = 1e3*(5.36449 + 0.78863*mix + (-2.59001)*(273.15./T) + ...
            (-2.73187)*mix*(273.15./T) + 1.43759*(273.15./T).^2);
        dsim0 = [3129.84073329535;3235.10295125210;3335.88503222419; ...
            3432.74192993047;3526.22859808978;3616.89999042096;3705.31106064285];
        
    case 'density' % Density[kg/m3]
        % M.Conde: Thermophysikals properties of Brines -  Engineering Zurich 2011
        % General Equation for Density, thermal conductivity, specific thermal capacity: 
        % Px = A1 + A2*Z + A3*273.15/T + A4*Z*273.15/T + A5*(273.15/T)^2
        % Z = Concetration; T[K]
        dref = (658.49825 + (-54.81501)*mix + 664.71643*(273.15./T) + ...
            232.71643*mix*(273.15./T) + (-322.61661)*(273.15./T).^2);
        dsim0 = [1080.90306617029;1074.38155197017;1065.13025813983;...
            1053.72749005034;1040.75155307280;1026.78075257827;1012.39339393784];
        
    case 'kinematic_viscosity' % kinematic Viscosity[mm2/s]
        % M.Conde: Thermophysikals properties of Brines -  Engineering Zurich 2011
        % Dynamic Viscosoty, Prandl Number
        % LN(Px) = A1 + A2*Z + A3*273.15/T + A4*Z*273.15/T + A5*(273.15/T)^2
        % Z[%]=Concetration; T[K]; rho[kg/m^3]; cp[kJ/kg K]; lambda[W/mK]
        % Coefficients for the equation not available for the moment :-/
        t = (10:10:100)';
        dsim0 = [1.50e-05;8.65e-06;5.95e-06;4.05e-06;3.00e-06;2.30e-06;...
            1.90e-06;1.50e-06;1.25e-06;1.085e-06];
        dref = dsim0;
        disp('verifying kinematic_viscosity for water-glycol: using simulation data as reference')
        
    case 'thermal_conductivity' % thermalConductivity[W/mK]    
        % M.Conde: Thermophysikals properties of Brines -  Engineering Zurich 2011
        % General Equation for Density, thermal conductivity, specific thermal capacity: 
        % Px = A1 + A2*Z + A3*273.15/T + A4*Z*273.15/T + A5*(273.15/T)^2
        % Z[%]=Concetration; T[K]; rho[kg/m^3]; cp[kJ/kg K]; lambda[W/mK]
        %         dref = 0.83818 + (-1.37620)*mix + (-0.07629)*(273.15./T) + ...
        %             1.07720*mix*(273.15./T) + (-0.20174)*(273.15./T).^2;
        
        dsim0 = [0.331808217377394;0.342553318681867;0.336419618225734;...
            0.316629211341335;0.286404193361006;0.248966659617087;0.207538705441914];
        disp('verifying thermal_conductivity for water-glycol: using simulation data as reference')
        dref = dsim0; % could not find a proper reference (see Teichrieb 2016)

    case 'vapourpressure' % vapour pressure [Pa]
        t = (10:10:100)';
        dsim0 = [701.052481943900;556.941602082092;737.634970746014; ...
            1084.48288589423;1626.45010988781;2426.67703791473; ...
            3572.31597056491;5175.94509064409;7379.56597731482;10359.8070712145];
        dref = dsim0;
        disp('verifying vapourpressure for water-glycol: using simulation data as reference')
    
    case 'enthalpy' % Enthalpy in J/kg
        dsim0 = [-21618.0613234059;0;21302.6051627965;42149.0996020137;62445.0931843680;82142.4602062619;101239.339393784];
        dref = dsim0;
        disp('verifying enthalpy for water-glycol: using simulation data as reference')

    case 'entropy' % entropy in J/kg/K
        t = nan;
        dref = nan;
        dsim0 = nan;
    
    case 'specific_volume' % specific volume in m³/kg
        dsim0 = [0.000925152339092774;0.000930768029445620;0.000938852306896651;...
            0.000949011968884122;0.000960844110246598;0.000973917749713338;0.000987758322000071];
        dref = dsim0;
        disp('verifying enthalpy for water-glycol: using simulation data as reference')
    
    case 'evaporation_enthalpy' % vapour pressure [Pa]
        t = nan;
        dref = nan;
        dsim0 = nan;
    
    case 'saturationtemperature' % saturation temperature in °C
        p = [100 1000 1e5];
        dsim0 = [20.0054931640625 37.9681396484375 179.779663085938];
        dref = dsim0;
        disp('verifying saturationtemperature for water-glycol: using simulation data as reference')
    
    case 'temperature_conductivity' % temperature conductivity
        t = nan;
        dref = nan;
        dsim0 = nan;
    
    otherwise
        t = nan;
        dref = nan;
        dsim0 = nan;
end

