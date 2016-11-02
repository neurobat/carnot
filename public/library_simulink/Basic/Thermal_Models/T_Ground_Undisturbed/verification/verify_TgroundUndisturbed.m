function [v, s] = verify_TgroundUndisturbed(varargin)
% verification of the s-function T_Ground_Undisturbed. 
% Syntax:   [v, s] = verify_wallBasic(show)
% 
% Inputs    show - optional flag for display 
%               0 : show results only if verification fails
%               1 : show results allways
% Outputs:  v - true if verification passed, false otherwise
%           s - text string with verification result
% According to Heuser the propagation of a temperature front in a thermally
% conductive media is T(x,t) = A02 + A2 * e^(-a*x) * cos(w*t + p - a*x)
% depth and lateral extension of the media is infinite (e.g. earth
% surface). In this verification we add a temperature increase in the depth 
% of 0.03 K/m.
% 
% Literature:  Heuser, H.:Gewoehnliche Differentialgleichungen, 1991

% all comments above appear with 'help verify_TgroundUndisturbed' 
% ***********************************************************************
% This file is part of the CARNOT Blockset.
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
% $Revision$
% $Author$
% $Date$
% $HeadURL$
% **********************************************************************
% D O C U M E N T A T I O N
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
% 
% author list:      hf -> Bernd Hafner
%
% version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
%
% Version   Author  Changes                                     Date
% 6.1.0     hf      created                                     02jul2016
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

% ---- check input arguments ----------------------------------------------
if nargin == 0
    show = 0;
elseif nargin == 1
    show = varargin{1};
else
    error('verify_TgroundUndisturbed:%s',' too many input arguments')
end

%% ---------- set your specific model or function parameters here
% ----- set error tolerances ----------------------------------------------
max_error = 1e-3;       % max error between simulation and reference
max_simu_error = 1e-7;  % max error between initial and current simu

% ---------- set model file or function name ------------------------------
functionname = 'verify_TgroundUndisturbed_mdl';

%% ----------------- set the literature reference values -------------------
A02 = 0;                        % average surface temperature during period
A2 = 10;                        % temperature amplitude of sine wave
T = 365*24*3600;                % period is one year
lambda = 1;                     % thermal conductivity in W/m/K
rho =   2000;                   % density in kg/m³
cp = 1000;                      % heat capacity in J/kg/K
tau = lambda / rho / cp;        % temperature conductivity in m²/s
phi = pi;                       % phase shift, start with coldest day
dTdm =0.03;                     % temperature increase in the depth in K/m
a = sqrt(pi/tau/T);
x = 0:10;                       % distance of nodes from surface
t0 = (0:1:365)*24*3600;         % reference time vector
y0 = zeros(length(t0),length(x));

% reference results from Heuser, 1991
for n = 1:length(x)
    y0(:,n) = A02 + A2*exp(-a*x(n))*cos(2*pi/T*t0+phi-a*x(n)) + dTdm*x(n); 
end

% ----------------- set reference values initial simulation ---------------
% result from call at creation of function
y1 = importdata('ground_temperature_results.mat');     

%% -------------- simulate the model or call the function -----------------
load_system(functionname)
simOut = sim(functionname, 'SrcWorkspace','current', ...
        'SaveOutput','on','OutputSaveName','yout');
yy = simOut.get('yout');        % get the whole output vector (one value per simulation timestep)
tt = simOut.get('tout');        % get the whole time vector from simu
yy_ts = timeseries(yy,tt);
yt = resample(yy_ts,t0);
y2 = yt.data;                   % the timedepandant output is interesting
close_system(functionname, 0)   % close system, but do not save it


%% -------- calculate the errors -------------------------------------------
%   r    - 'relative' error or 'absolute' error
%   s    - 'sum' - e is the sum of the individual errors of ysim 
%          'mean' - e is the mean of the individual errors of ysim
%          'max' - e is the maximum of the individual errors of ysim
r = 'absolute'; 
% r = 'relative'; 
s = 'max';
% s = 'sum';
% s = 'mean';

% error between reference and initial simu 
[e1, ye1] = calculate_verification_error(y0, y1, r, s);
% error between reference and current simu
[e2, ye2] = calculate_verification_error(y0, y2, r, s);
% error between initial and current simu
[e3, ye3] = calculate_verification_error(y1, y2, r, s);

% ------------- decide if verification is ok --------------------------------
if e2 > max_error
    v = false;
    s = sprintf('verification %s with reference FAILED: error %3.3f > allowed error %3.3f', ...
        functionname, e2, max_error);
    show = true;
elseif e3 > max_simu_error
    v = false;
    s = sprintf('verification %s with 1st calculation FAILED: error %3.3f > allowed error %3.3f', ...
        functionname, e3, max_simu_error);
    show = true;
else
    v = true;
    s = sprintf('%s OK: error %3.3f', functionname, e2);
end

% ------------ diplay and plot options if required ------------------------
if (show)
    disp(s)
    disp(['Initial error = ', num2str(e1)])
    sx = 'time in h';                       % x-axis label
    st = 'Temperatures in node 5';          % title
    sy1 = 'Temperature in °C';              % y-axis label in the upper plot
    sy2 = 'Max difference over all nodes';  % y-axis label in the lower plot
    % upper legend
    sleg1 = {'reference data','initial simulation','current simulation'};
    % lower legend
    sleg2 = {'ref. vs initial simu','ref. vs current simu','initial simu vs current'};
    % x axis
    x = t0/3600;            % time in h
    %   y - matrix with y-values (reference values and result of the function call)
    y = [y0(:,5), y1(:,5), y2(:,5)];           % compare temperature in the middle 
    %   ye - matrix with error values for each y-value
    ye = [max(ye1,[],2), max(ye2,[],2), max(ye3,[],2)];   % compare max difference to current simu 
    sz = strrep(s,'_',' ');
    display_verification_error(x, y, ye, st, sx, sy1, sleg1, sy2, sleg2, sz)
end