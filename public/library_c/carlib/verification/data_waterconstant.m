function [t, p, mix, dref, dsim0] = data_waterconstant(prop)
% function [t, mix, dref, dsim0] = data_waterconstant(prop)
% define the reference data from literature and simulation standard for 
% constant fluid properites of water (at T=temperature 20°C, p=1013hPa), 
% used to validate the carnot material properties library carlib.c
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
% Wohlfeil, A.: c-code and Simulink model of the IAPWS97 equations, 2016
% IAPWS: www.iapws.org
% H.D. Baehr, K. Stephan, Wärme- und Stoffübertragung, 4th edition, Springer


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
% 6.1.0     hf      created                                     18nov2016
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

mix = 0;        % no fluid mixture for the moment
p = 1e5;        % pressure is not relevant, assume atmospheric pressure
t = 20:20:80;   % temperature as a vector in °C
e = ones(length(t),1);

switch prop
    case 'heat_capacity' %  cp[J/kg/K]
        % Source: IAPWS97, values for pressure 1013 hPa, temperature 20°C
        dref = 4184.79417263427*e;
        dsim0 = [4181;4181;4181;4181];
        
    case 'density' % Density[kg/m3]
        % Source: IAPWS97, values for pressure 1013 hPa, temperature 20°C
        dref = 998.206081032297*e;
        dsim0 = [998.21;998.21;998.21;998.21];
        
    case 'kinematic_viscosity' % kinematic Viscosity[mm2/s]
        % Source: IAPWS97, values for pressure 1013 hPa, temperature 20°C
        dref = 1.00339687499979e-06*e;
        dsim0 = [1.004e-06;1.004e-06;1.004e-06;1.004e-06];
        
    case 'thermal_conductivity' % thermalConductivity[W/mK]    
        % Source: IAPWS97, values for pressure 1013 hPa, temperature 20°C
        dref = 0.599528292878701*e;
        dsim0 = [0.59840;0.59840;0.59840;0.59840];

    case 'vapourpressure' % vapour pressure [Pa]
        % Source: IAPWS97, values for pressure 1013 hPa, temperature 20°C
        dref = 2339.21476677690*e;
        dsim0 = [2339.21476677690;2339.21476677690;2339.21476677690;2339.21476677690];
    
    case 'enthalpy' % Enthalpy in J/kg
        % Source: IAPWS97, values for pressure 1013 hPa, temperature 20°C
        dref = 84013.0346245843*e;
        dsim0 = [84013.0346245843;84013.0346245843;84013.0346245843;84013.0346245843];

    case 'entropy' % entropy in J/kg/K
        % Source: IAPWS97, values for pressure 1013 hPa, temperature 20°C
        dref = 296.482651731789*e;
        dsim0 = [296.482651731789;296.482651731789;296.482651731789;296.482651731789];
    
    case 'specific_volume' % specific volume in m³/kg
        % Source: IAPWS97, values for pressure 1013 hPa, temperature 20°C
        dref = 0.00100179714289643*e;
        dsim0 = [0.00100179320984562;0.00100179320984562;0.00100179320984562;0.00100179320984562];
    
    case 'evaporation_enthalpy' % vapour pressure [Pa]
        % Source: IAPWS97, values for pressure 1013 hPa, temperature 20°C
        dref = 2454158.62854583*e;
        dsim0 = [2454158.62854583;2454158.62854583;2454158.62854583;2454158.62854583];
    
    case 'saturationtemperature' % saturation temperature in °C
        % Source: IAPWS97, values for pressure 1013 hPa, temperature 20°C
        p = [1e4 1e5 1e6 1e7];
        dref = 373.117386427333*e' - 273.15;
        dsim0 = [100 100 100 100];
    
    case 'temperature_conductivity' % temperature conductivity
        % Source: IAPWS97, values for pressure 1013 hPa, temperature 20°C
        dref = 1.43520972863854e-07*e;
        dsim0 = [1.43380305374700e-07;1.43380305374700e-07;1.43380305374700e-07;1.43380305374700e-07];
    
    otherwise
        t = nan;
        dref = nan;
        dsim0 = nan;
end

