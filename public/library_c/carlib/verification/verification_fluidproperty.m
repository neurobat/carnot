function [v, s] = verification_fluidproperty(fluid, show, functionname, max_error, error_type)
% verify the m-functions of fluid properties in the carlib 
% and their corresponding block in carnot
% [v,s] = verify_vapour_pressure(fluid,show)
% inputs
%   fluid
%       WATER       = 1;
%       AIR         = 2;
%       COTOIL      = 3;
%       SILOIL      = 4;
%       WATERGLYCOL = 5;
%       TYFOCOR_LS  = 6;
%       WATER_CONSTANT = 7;
%       AIR_CONSTANT = 8;
%   show - flag for display options 
%       0 : plot results only if verification fails
%       1 : plot results allways
%   property - property to be checked
%   max_error -  max error between simulation and reference
%   error_type - type of error evaluation ('relative', 'absolute')
% 
% outputs
%   v - result of verification
%       0 : failed
%       1 : ok
%   s - text string with the verification result
% 
% fluid properties to be checked:
%           'density' in kg/m³
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
% 
% this function is used by: verify_carlib
% this function calls: display_verification_error,
% calculate_verification_error, data_water, data_air, data_cottonoil,
% data_waterglycol, data_tyfocorLS, data_siliconoil
% 
% Literature:
% Teichrieb, H.: Bericht Carlib-Validierung, Hochschule Düsseldorf, 2016
%   see: public\library_c\carlib\doc\pdf\Bericht Carlib-Validierung HSD.pdf

% ***********************************************************************
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
% **********************************************************************
% D O C U M E N T A T I O N
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
% author list:     hf -> Bernd Hafner
%
% version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
%
% Version   Author  Changes                                     Date
% 6.1.0     hf      created                                     13nov2016
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

%% ---------- set your specific model or function parameters here
% ----- set error tolerances ----------------------------------------------
max_simu_error = 1e-7;  % max error between initial and current simu

% Fluids
WATER       = 1;
AIR         = 2;
COTOIL      = 3;
SILOIL      = 4;
WATERGLYCOL = 5;
TYFOCOR_LS  = 6;
WATER_CONSTANT = 7;
AIR_CONSTANT = 8;

% -------------- get the reference values ---------------------------------
switch fluid
    case WATER
        [t, p, mix, y0, y1] = data_water(functionname);
        sfluid = 'Water';
    case AIR
        [t, p, mix, y0, y1] = data_air(functionname);
        sfluid = 'Air';
    case COTOIL
        [t, p, mix, y0, y1] = data_cottonoil(functionname);
        sfluid = 'CottonOil';
    case SILOIL
        [t, p, mix, y0, y1] = data_siliconoil(functionname);
        sfluid = 'SiliconOil';
    case WATERGLYCOL                    % propylen-glycol - water mixture
        [t, p, mix, y0, y1] = data_waterglycol(functionname);
        sfluid = 'WaterGlycolMix';
    case TYFOCOR_LS
        [t, p, mix, y0, y1] = data_tyfocorLS(functionname);
        sfluid = 'TyfocorLS';
    case WATER_CONSTANT
        [t, p, mix, y0, y1] = data_waterconstant(functionname);
        sfluid = 'WaterConst';
    case AIR_CONSTANT
        [t, p, mix, y0, y1] = data_airconstant(functionname);
        sfluid = 'AirConst';
    otherwise 
        y0 = nan;
end
if isnan(y0)
    v = true;
    s = ['property ' functionname ' not available for fluid' fluid];
    return
end

%% ------------- validate function call by the .m file --------------------
y2 = zeros(size(y0));     % current result initialized a matrix of zeros
for n = 1:length(mix)
    switch functionname
        case {'vapourpressure'}
            eval(['y2(:,1,n) = ' functionname '(t, fluid, mix(n));'])
        case {'saturationtemperature'}
            eval(['y2(1,:,n) = ' functionname '(p, fluid, mix(n));'])
        otherwise
            for m = 1:length(p)
                eval(['y2(:,m,n) = ' functionname '(t, p(m), fluid, mix(n));'])
            end
    end
end

% -------- calculate the errors -------------------------------------------
% error between reference and initial simu 
[e1, ye1] = calculate_verification_error(y0, y1, error_type, 'max');
% error between reference and current simu
[e2, ye2] = calculate_verification_error(y0, y2, error_type, 'max');
% error between initial and current simu
[e3, ye3] = calculate_verification_error(y1, y2, error_type, 'max');

% ------------- decide if verification is ok --------------------------------
if e2 > max_error
    v = false;
    s = sprintf('verification %s of %s with reference FAILED: error %3.3f > allowed error %3.3f', ...
        functionname, sfluid, e2, max_error);
    show = true;
elseif e3 > max_simu_error
    v = false;
    s = sprintf('verification %s of %s with 1st calculation FAILED: error %3.3f > allowed error %3.3f', ...
        functionname, sfluid, e3, max_simu_error);
    show = true;
else
    v = true;
    s = sprintf('%s of %s OK: error %3.3f', functionname, sfluid, e2);
end

% ------------ diplay and plot options if required ------------------------
if (show)
    u0 = t;
    disp(s)
    disp(['m-file initial error = ', num2str(e1)])
    st = ['m-file ', functionname, ' of ', sfluid];
    sx = 'Temperature in °C';       % x label
    sy1 = functionname;             % upper y label
    sy2 = 'Difference';             % lower y label
    sleg1 = {'reference data','initial simulation','current simulation'};
    sleg2 = {'ref. vs initial simu','ref. vs current simu','initial simu vs current'};
    x = reshape(u0,length(u0),1);
    y = [reshape(y0,numel(y0),1), reshape(y1,numel(y1),1), reshape(y2,numel(y2),1)];
    ye = [reshape(ye1,numel(ye1),1), reshape(ye2,numel(ye2),1), reshape(ye3,numel(ye3),1)];
    display_verification_error(x, y, ye, st, sx, sy1, sleg1, sy2, sleg2, s)
end

% ---- no need to continue if first verification failed -------------------
if v == false
    return
end


%% ---------- validate Simulink block   -----------------------------------
% check if the function is avaible in carnot library
if strcmp(functionname, 'temperature_conductivity')
    disp('function temperature_conductivity not available as Simulink block')
    return
end
% loop over temperatures, pressure and mixtures
modelname = ['verify_' functionname '_mdl']; % create modelname from functionname
for n = 1:length(mix)
    fmix = mix(n);          %#ok<NASGU> variable is used in simulation model
    for m = 1:length(p)
        press = p(m);       %#ok<NASGU> variable is used in simulation model
        simOut = sim(modelname, 'SrcWorkspace','current', ...
            'SaveOutput','on','OutputSaveName','yout');
        rr = simOut.get('yout');
        y2(:,m,n) = rr(end,:)';
    end
end

% -------- calculate the errors -------------------------------------------
% error between reference and current simu
[e2, ye2] = calculate_verification_error(y0, y2, error_type, 'max');
% error between initial and current simu
[e3, ye3] = calculate_verification_error(y1, y2, error_type, 'max');

% ------------- decide if verification is ok --------------------------------
if e2 > max_error
    v = false;
    s = sprintf('verification %s of %s with reference FAILED: error %3.3f > allowed error %3.3f', ...
        functionname, sfluid, e2, max_error);
    show = true;
elseif e3 > max_simu_error
    v = false;
    s = sprintf('verification %s of %s with 1st calculation FAILED: error %3.3f > allowed error %3.3f', ...
        functionname, sfluid, e3, max_simu_error);
    show = true;
else
    v = true;
    s = sprintf('%s of %s OK: error %3.3f', functionname, sfluid, e2);
end

% ------------ diplay and plot options if required ------------------------
if (show)
    u0 = t;
    disp(s)
    disp(['Simulink Block initial error = ', num2str(e1)])
    st = ['Simulink Block of ', sfluid];
    sx = 'Temperature in °C';       % x label
    sy1 = functionname;             % upper y label
    sy2 = 'Difference';             % lower y label
    sleg1 = {'reference data','initial simulation','current simulation'};
    sleg2 = {'ref. vs initial simu','ref. vs current simu','initial simu vs current'};
    x = reshape(u0,length(u0),1);
    y = [reshape(y0,length(y0),1), reshape(y1,length(y1),1), reshape(y2,length(y2),1)];
    ye = [reshape(ye1,length(ye1),1), reshape(ye2,length(ye2),1), reshape(ye3,length(ye3),1)];
    display_verification_error(x, y, ye, st, sx, sy1, sleg1, sy2, sleg2, s)
end
