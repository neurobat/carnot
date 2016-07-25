function [v, s] = verification_density(fluid,show)
% verify the m-function "density.m", the Carnot library block "Density" 
% and their calls to the carnot material properties library carlib.c
% 
% [v,s] = verify_density(fluid,show)
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
% 
% outputs
%   v - result of verification
%       0 : failed
%       1 : ok
%   s - text string with the verification result
% 
% function calls: 
% function is used by: verify_carlib
% this function calls: display_verification_error, calculate_verification_error
% 
% Literature: ---

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
% Version  Author  Changes                                     Date
% 6.1.0    hf      created                                     17nov2013
% 6.2.0     hf      return argument is [v, s]                   03oct2014
% 6.2.1     hf      filename verify_ replaced by verification_  09jan2015
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

%% ---------- set your specific model or function parameters here
% ----- set error tolerances ----------------------------------------------
max_error = 0.0004;     % max error between simulation and reference
max_simu_error = 1e-7;  % max error between initial and current simu
functionname = 'density';

% Fluids
WATER       = 1;
AIR         = 2;
COTOIL      = 3;
SILOIL      = 4;
WATERGLYCOL = 5;
TYFOCOR_LS  = 6;
WATER_CONSTANT = 7;
AIR_CONSTANT = 8;

% ----------------- get the reference values ------------------------------
% t     temperature vector in °C
% p     pressure vector in Pa
% mix   fluid mixture (defined in THB)
% ref   literature reference values
% ref   literature reference values
% rho0  reference simulated values for the original Matlab version
% 
% ref and rho0 be a 3-dimensional matrix with:
% row 1..N, colon 1, page 1: ref-value for all temperatures at p(1), mix(1)
% row 1..N, colon 2, page 1: ref-value for all temperatures at p(2), mix(1)
% row 1..N, colon M, page 1: ref-value for all temperatures at p(M), mix(1)
% row 1..N, colon 1, page 2: ref-value for all temperatures at p(1), mix(2)
% row 1..N, colon 2, page 2: ref-value for all temperatures at p(2), mix(2)
% row 1..N, colon M, page 2: ref-value for all temperatures at p(M), mix(2)

switch fluid
    case WATER
        [t, p, mix, y0, y1] = data_water('density');
    case AIR
        [t, p, mix, y0, y1] = data_air('density');
    case COTOIL
        [t, p, mix, y0, y1] = data_cottonoil('density');
    case SILOIL
        [t, p, mix, y0, y1] = data_siliconoil('density');
    case WATERGLYCOL  % propylen-glycol - water mixture
        [t, p, mix, y0, y1] = data_waterglycol('density');
    case TYFOCOR_LS
        [t, p, mix, y0, y1] = data_tyfocorLS('density');
    case WATER_CONSTANT
        [t, p, mix, y0, y1] = data_waterconstant('density');
    case AIR_CONSTANT
        [t, p, mix, y0, y1] = data_airconstant('density');
end

%% --------- validate function call by the .m file ------------------------
y2 = zeros(size(y0));   % current result initialized a matrix of zeros
for n = 1:length(mix)
    for m = 1:length(p)
        y2(:,m,n) = density(t, p(m), fluid, mix(n));
    end
end

% -------- calculate the errors -------------------------------------------
% error between reference and initial simu 
[e1 ye1] = calculate_verification_error(y0, y1, 'relative', 'mean');
% error between reference and current simu
[e2 ye2] = calculate_verification_error(y0, y2, 'relative', 'mean');
% error between initial and current simu
[e3 ye3] = calculate_verification_error(y1, y2, 'relative', 'mean');

% ------------- decide if verification is ok --------------------------------
if e2 > max_error
    v = false;
    s = sprintf('verification %s with reference FAILED: error %3.4f > allowed error %3.4f', ...
        functionname, e2, max_error);
    show = true;
elseif e3 > max_simu_error
    v = false;
    s = sprintf('verification %s with 1st calculation FAILED: error %3.4f > allowed error %3.4f', ...
        functionname, e3, max_simu_error);
    show = true;
else
    v = true;
    s = sprintf('%s OK: error %3.4f', functionname, e2);
end

% ------------ diplay and plot options if required ------------------------
if (show)
    u0 = t;
    disp(s)
    disp(['m-file initial error = ', num2str(e1)])
    sx = 'Temperature in °C';       % x label
    sy1 = 'density in kg/m³';       % upper y label
    sy2 = 'Difference';             % lower y label
    sleg1 = {'reference data','initial simulation','current simulation'};
    sleg2 = {'ref. vs initial simu','ref. vs current simu','initial simu vs current'};
    x = reshape(u0,length(u0),1);
    y = [reshape(y0,length(y0),1), reshape(y1,length(y1),1), reshape(y2,length(y2),1)];
    ye = [reshape(ye1,length(ye1),1), reshape(ye2,length(ye2),1), reshape(ye3,length(ye3),1)];
    display_verification_error(x, y, ye, 'm-Function', sx, sy1, sleg1, sy2, sleg2, s)
end

% ---- no need to continue if first verification failed ---------------------
if v == false
    return
end

%% ------------- validate Simulink block "density" ------------------------
y2 = zeros(size(y0));   % current result initialized a matrix of zeros
for n = 1:length(mix)
    fmix = mix(n);
    for m = 1:length(p)
        press = p(m);
        simOut = sim('verify_density_mdl', 'SrcWorkspace','current', ...
            'SaveOutput','on','OutputSaveName','yout');
        rr = simOut.get('yout');
        y2(:,m,n) = rr(end,:)';
    end
end

% -------- calculate the errors -------------------------------------------
% error between reference and current simu
[e2 ye2] = calculate_verification_error(y0, y2, 'relative', 'mean');
% error between initial and current simu
[e3 ye3] = calculate_verification_error(y1, y2, 'relative', 'mean');

% ------------- decide if verification is ok --------------------------------
if e2 > max_error
    v = false;
    s = sprintf('verification %s with reference FAILED: error %3.4f > allowed error %3.4f', ...
        functionname, e2, max_error);
    show = true;
elseif e3 > max_simu_error
    v = false;
    s = sprintf('verification %s with 1st calculation FAILED: error %3.4f > allowed error %3.4f', ...
        functionname, e3, max_simu_error);
    show = true;
else
    v = true;
    s = sprintf('%s OK: error %3.4f', functionname, e2);
end

% ------------ diplay and plot options if required ------------------------
if (show)
    u0 = t;
    disp(s)
    disp(['Simulink Block initial error = ', num2str(e1)])
    st = 'Simulink Block verification';
    sx = 'Temperature in °C';       % x label
    sy1 = 'density in kg/m³';  % upper y label
    sy2 = 'Difference';             % lower y label
    sleg1 = {'reference data','initial simulation','current simulation'};
    sleg2 = {'ref. vs initial simu','ref. vs current simu','initial simu vs current'};
    x = reshape(u0,length(u0),1);
    y = [reshape(y0,length(y0),1), reshape(y1,length(y1),1), reshape(y2,length(y2),1)];
    ye = [reshape(ye1,length(ye1),1), reshape(ye2,length(ye2),1), reshape(ye3,length(ye3),1)];
    display_verification_error(x, y, ye, st, sx, sy1, sleg1, sy2, sleg2, s)
end
