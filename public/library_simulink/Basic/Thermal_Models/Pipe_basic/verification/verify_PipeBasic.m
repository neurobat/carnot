function [v, s] = verify_PipeBasic(varargin)
% verification of Simulink-Block verify_PipeBasic_mdl
% Syntax:   [v, s] = verify_PipeBasic(show)
% 
% Inputs    show - optional flag for display 
%               0 : show results only if validation fails
%               1 : show results allways
% Outputs:  v - true if verification passed, false otherwise
%           s - text string with verification result
%                                                                          
% Literature:   --

% ---- check input arguments ----------------------------------------------
if nargin == 0
    show = 0;
elseif nargin == 1
    show = varargin{1};
else  
    error('verify_PipeBasic:%s',' too many input arguments')
end

%% ---------- model 1: validate energy balance for multinode model
% ----- set error tolerances ----------------------------------------------
max_error = 0.1;        % max error between simulation and reference
max_simu_error = 1e-7;  % max error between initial and current simu

% ---------- set model file or functi0n name ------------------------------
functionname = 'verify_PipeBasic_mdl';

% ----------------- set the literature reference values -------------------
t0 = 0:600:6*3600;   
% reference results
y0e = 1 * 10 * (20-40.0509); % Qloss = LossPerLength * L * dT

% ----------------- set reference values initial simulation ---------------
% result from call at creation of function
load('simdata_pipe.mat', 'y1', 'y1e');
y0 = y1;    % in this case the reference temperatures are the first simu

%  -------------- simulate the model or call the function -----------------
load_system(functionname)
simOut = sim(functionname, 'SrcWorkspace','current', ...
        'SaveOutput','on','OutputSaveName','yout');
xx = simOut.get('yout');            % get output vector
t2 = simOut.get('tout');            % get the time vector
tsy = timeseries(xx(:,1:10),t2);    % column 1:10 are the temperatures
tx = resample(tsy,t0);              % resample with t0
y2 = tx.data;
y2e = xx(end,end);                  % column 11 is the power
close_system(functionname, 0)       % close system, but do not save it

% -------- calculate the errors -------------------------------------------
%   r    - 'relative' error or 'absolute' error
%   s    - 'sum' - e is the sum of the individual errors of ysim 
%          'mean' - e is the mean of the individual errors of ysim
%          'max' - e is the maximum of the individual errors of ysim
r = 'absolute'; 
s = 'max';

% error between reference and initial simu 
[~, ye1] = calculate_verification_error(y0, y1, r, s);
[e1e, ~] = calculate_verification_error(y0e, y1e, r, s);
% error between reference and current simu
[e2, ye2] = calculate_verification_error(y0, y2, r, s);
[e2e, ~] = calculate_verification_error(y0e, y2e, r, s);
% error between initial and current simu
[e3, ye3] = calculate_verification_error(y1, y2, r, s);
[e3e, ~] = calculate_verification_error(y1e, y2e, r, s);

% ------------- decide if verification is ok --------------------------------
if e2 > max_error
    v = false;
    s = sprintf('verification temperatures %s with reference FAILED: error %3.3g K > allowed error %3.3g', ...
        functionname, e2, max_error);
    show = true;
elseif e3 > max_simu_error
    v = false;
    s = sprintf('verification temperatures %s with 1st calculation FAILED: error %3.3g K > allowed error %3.3g', ...
        functionname, e3, max_simu_error);
    show = true;
elseif e2e > max_error
    v = false;
    s = sprintf('verification power balance %s with reference FAILED: error %3.3g W > allowed error %3.3g', ...
        functionname, e2e, max_error);
    show = true;
elseif e3e > max_simu_error
    v = false;
    s = sprintf('verification power balance %s with 1st calculation FAILED: error %3.3g W > allowed error %3.3g', ...
        functionname, e3e, max_simu_error);
    show = true;
else
    v = true;
    s = sprintf('power balance %s OK: error %3.3g W', functionname, e2e);
end

% ------------ diplay and plot options if required ------------------------
if (show)
    disp(s)
    disp(['Initial error = ', num2str(e1e), ' W'])
    sx = 'massflow in kg/h';                % x-axis label
    st = 'Simulink block verification';       % title
    sy1 = 'Temperature in °C';             % y-axis label in the upper plot
    sy2 = 'Temperature difference';        % y-axis label in the lower plot
    % upper legend
    sleg1 = {'reference data','initial simulation','current simulation'};
    % lower legend
    sleg2 = {'ref. vs initial simu','ref. vs current simu','initial simu vs current'};
    %   x - vector with x values for the plot
    x = t0/3600;
    %   y - matrix with y-values (reference values and result of the function call)
    y = [y0, y1, y2];
    %   ye - matrix with error values for each y-value
    ye = [ye1,ye2,ye3];
    display_verification_error(x, y, ye, st, sx, sy1, sleg1, sy2, sleg2, s)
end

%% Copyright an file history
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
% Version   Author  Changes                                         Date
% 6.1.0     hf      created from verify_sfun_storage_heatexchanger  03oct2016
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *