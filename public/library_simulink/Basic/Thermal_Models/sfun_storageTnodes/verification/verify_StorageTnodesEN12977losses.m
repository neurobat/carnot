function [v, s] = verify_StorageTnodesEN12977losses(varargin)
% Validation of the s-function StorageTnodes in the Carnot Toolbox by
% using the benchmark defined in EN 12977-3 Annex A. The benchmark is the
% comparison of the temperatures during a standby phase with the analytical
% solution of the storage losses.
% 
% Syntax:   [v, s] = validate_StorageTnodes(show)
% 
% Inputs    show - optional flag for display 
%               0 : show results only if verification fails
%               1 : show results allways
% Outputs:  v - true if verification passed, false otherwise
%           s - text string with verification result
%                                                                          
% Literature:   EN 12977-3

% all comments above appear with 'help validate_StorageTnodesEN12977losses' 
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
% author list:      hf -> Bernd Hafner
%
% version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
%
% Version   Author  Changes                                     Date
% 6.1.0     hf      created                                     12dec2014
% 6.1.1     hf      filename validate_ replaced by verify_      09jan2015
% 6.1.2     hf      new version of block "sfun_Tnodes"          24feb2015
% 6.1.3     hf      close system without saving it              16may2016
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

% ---- check input arguments ----------------------------------------------
if nargin == 0
    show = 0;
elseif nargin == 1
    show = varargin{1};
else
    error('verify_StorageTnodesEN12977losses:%s',' too many input arguments')
end

%% ---------- set your specific model or function parameters here
% ----- set error tolerances ----------------------------------------------
max_error = 0.001;      % max error between simulation and reference (EN12977)
max_simu_error = 1e-5;  % max error between initial and current simu

% ---------- set model file or functi0n name ------------------------------
functionname = 'verify_StorageTnodesEN12977losses_mdl';
functionnamedisp = strrep(functionname,'_',' ');

% parameters for benchmar according to EN 12977-3 Annex A
Tamb = 20;
cp = 4181.0;    % heat capacity of fluid (water, constant)
rho = 998.21;   % density of fluid (water, constant)
Cap = 2e6;      % capacitiy of storage (defined by EN)
volume = Cap/(rho*cp);
dia = 0.6;
Atop = (dia/2)^2*pi;
Acyl = dia*pi*volume/Atop;
standing = true;
uloss = 7.0; % W/m²/K -- Awall is 1 m²
ubot = 0;
utop = 0;
cond = 0;
tini  = 60;
nodes = 1;
nconnect = 1;
UA = uloss*Acyl + (ubot+utop)*Atop;

% ----------------- set the literature reference values -------------------
t0m = (0:60:400*3600)';     % reference time vector with 1 minute timestep
t0h = (0:3600:400*3600)';   % reference time vector with 1 hour timestep
y0m = Tamb + (tini-Tamb).*exp(-(UA/Cap).*t0m);            % reference results for 1 minute timestep
y0h = Tamb + (tini-Tamb).*exp(-(UA/Cap).*t0h);            % reference results for 1 h stimestep

% ----------------- set reference values initial simulation ---------------
load BenchmarkDataEN12977

%% ------------------------------------------------------------------------
%  -------------- simulate the model or call the function -----------------
%  ------------------------------------------------------------------------
load_system(functionname)

% set parameters
% set_param([functionname,'/sfun_storageTnodes'], 'parameters', ...
%     [num2str(dia), ', ', num2str(volume), ', ', num2str(standing), ', ', ...
%     num2str(uloss), ', ', num2str(ubot), ', ', num2str(utop), ', ', ...
%     num2str(cond), ', ', num2str(tini), ', ', num2str(nodes), ', ', ...
%     num2str(nconnect)]); 
set_param([functionname,'/sfun_storageTnodes'], 'dia', num2str(dia));
set_param([functionname,'/sfun_storageTnodes'], 'volume', num2str(volume));
set_param([functionname,'/sfun_storageTnodes'], 'standing', num2str(standing));
set_param([functionname,'/sfun_storageTnodes'], 'uloss', num2str(uloss));
set_param([functionname,'/sfun_storageTnodes'], 'ubot', num2str(ubot));
set_param([functionname,'/sfun_storageTnodes'], 'utop', num2str(utop));
set_param([functionname,'/sfun_storageTnodes'], 'cond', num2str(cond));
set_param([functionname,'/sfun_storageTnodes'], 'tini', num2str(tini));
set_param([functionname,'/sfun_storageTnodes'], 'nodes', num2str(nodes));
set_param([functionname,'/sfun_storageTnodes'], 'nconnect', num2str(nconnect));


% set max stepsize to 60 s (according to EN 12977 benchmark)
set_param(functionname, 'MaxStep', '60')
simOut = sim(functionname, 'SrcWorkspace','current','SaveOutput','on','OutputSaveName','yout');
y = simOut.get('yout'); % get the whole output vector (one value per simulation timestep)
t = simOut.get('tout'); % get the whole time vector from simu
yy = timeseries(y,t);
yt = resample(yy,t0m);
y2m = yt.data;

% set max stepsize to 3600 s (according to EN 12977 benchmark)
set_param(functionname, 'MaxStep', '3600')
simOut = sim(functionname, 'SrcWorkspace','current','SaveOutput','on','OutputSaveName','yout');
y = simOut.get('yout'); % get the whole output vector (one value per simulation timestep)
t = simOut.get('tout'); % get the whole time vector from simu
yy = timeseries(y,t);
yt = resample(yy,t0h);
y2h = yt.data;

close_system(functionname, 0)   % close system, but do not save it


%% -------- calculate the errors -------------------------------------------

%   r    - 'relative' error or 'absolute' error
%   s    - 'sum' - e is the sum of the individual errors of ysim 
%          'mean' - e is the mean of the individual errors of ysim
%          'max' - e is the maximum of the individual errors of ysim
r = 'absolute'; 
s = 'max';

% error between reference and initial simu 
[e1m, ye1m] = calculate_verification_error(y0m, y1m, r, s);
[e1h, ye1h] = calculate_verification_error(y0h, y1h, r, s);
% error between reference and current simu
[e2m, ye2m] = calculate_verification_error(y0m, y2m, r, s);
[e2h, ye2h] = calculate_verification_error(y0h, y2h, r, s);
% error between initial and current simu
[e3m, ye3m] = calculate_verification_error(y1m, y2m, r, s);
[e3h, ye3h] = calculate_verification_error(y1h, y2h, r, s);

% ------------- decide if verification is ok --------------------------------
% ------ check the 60 s timestep results first ------------
if e2m > max_error
    v = false;
    s = sprintf('verification 60 s timestep %s with reference FAILED: error %3.3f K > allowed %3.3f', ...
        functionnamedisp, e2m, max_error);
    show = true;
elseif e3m > max_simu_error
    v = false;
    s = sprintf('verification 60 s timestep %s with 1st calculation FAILED: error %5.3g K > allowed %5.3g', ...
        functionnamedisp, e3m, max_simu_error);
    show = true;
else
    v = true;
    s = sprintf('60 s timestep of %s OK: error %5.3g K < %5.3g K EN12977', functionnamedisp, e2m, max_error);
end

% diplay and plot if required
if (show)
    disp(s)
    disp(['Initial error = ', num2str(e1m)])
    sx = 'time in h';                       % x-axis label
    st = 'Validation storage model with 60 s timestep';       % title
    sy1 = 'Temperature in °C';              % y-axis label in the upper plot
    sy2 = 'Difference';                     % y-axis label in the lower plot
    % upper legend
    sleg1 = {'reference data','initial simulation','current simulation'};
    % lower legend
    sleg2 = {'ref. vs initial simu','ref. vs current simu','initial simu vs current'};
    %   y - matrix with y-values (reference values and result of the function call)
    %   ye - matrix with error values for each y-value
    display_verification_error(t0m/3600, [y0m, y1m, y2m], [ye1m,ye2m,ye3m], st, sx, sy1, sleg1, sy2, sleg2, s)
end

% ------------ now check the 3600 s timestep results -----------
if e2h > max_error
    v = false;
    s = sprintf('verification 3600 s timestep of %s with reference FAILED: error %3.3f K > allowed error %3.3f', ...
        functionnamedisp, e2h, max_error);
    show = true;
elseif e3h > max_simu_error
    v = false;
    s = sprintf('verification 3600 s timestep of  %s with 1st calculation FAILED: error %5.3g K > allowed error %5.3g', ...
        functionnamedisp, e3h, max_simu_error);
    show = true;
elseif v == true % verification of minute results was ok
    s = sprintf('60s, 3600s timestep of %s OK: error %5.3g K < %5.3g K EN12977', functionnamedisp, e2m, max_error);
end

% ------------ diplay and plot options if required ------------------------
if (show)
    disp(s)
    disp(['Initial error = ', num2str(e1h)])
    sx = 'time in h';                       % x-axis label
    st = 'Validation storage model with 3600 s timestep';       % title
    sy1 = 'y-label up';                     % y-axis label in the upper plot
    sy2 = 'Difference';                     % y-axis label in the lower plot
    % upper legend
    sleg1 = {'reference data','initial simulation','current simulation'};
    % lower legend
    sleg2 = {'ref. vs initial simu','ref. vs current simu','initial simu vs current'};
    %   y - matrix with y-values (reference values and result of the function call)
    %   ye - matrix with error values for each y-value
    display_verification_error(t0h/3600, [y0h, y1h, y2h], [ye1h,ye2h,ye3h], st, sx, sy1, sleg1, sy2, sleg2, s)
end

