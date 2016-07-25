function [v, s] = verify_Simple_House_SFH15(varargin)
% verification of the Simple House Model with ISO Ground Model in the Carnot 
% Toolbox by using the benchmark of the IEA SHC TASK 44 and IEA HPP ANNEX 38. 
% The benchmark is the % comparison of simulation results from TRNSYS.
% 
% Syntax:   [v, s] = verify_Simple_House_SFH15(show)
% 
% Inputs    show - optional flag for display 
%               0 : show results only if verification fails
%               1 : show results allways
% Outputs:  v - true if verification passed, false otherwise
%           s - text string with verification result
%                                                                          
% Literature:   reports of IEA SHC TASK 44 and IEA HPP ANNEX 38

% all comments above appear with 'help verify_Simple_House_SFH15' 
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
% 6.1.0     hf      created                                     27dec2014
% 6.1.1     hf      load weather data before simulation         03jan2015
% 6.1.2     hf      comparision of y1 and y2 not valid because  06jan2015
%                   of different models, corrected if e3 > ...
% 6.1.3     hf      filename validate_ replaced by verify_      09jan2015
% 6.1.4     hf      close system without saving it              16may2016
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

% ---- check input arguments ----------------------------------------------
if nargin == 0
    show = 0;
elseif nargin == 1
    show = varargin{1};
else
    error('verify_Simple_House_SFH15:%s',' too many input arguments')
end

%% ---------- set your specific model or function parameters here
% ----- set error tolerances ----------------------------------------------
max_error = 2.2;        % max error between TRNSYS and Carnot in kWh/m²
max_simu_error = 0.05;  % max error between initial and current Carnot simu

% ---------- set model file or functi0n name ------------------------------
functionname = 'verify_Simple_House_SFH15_mdl';
functionnamedisp = strrep(functionname,'_',' ');

% ----------------- set the literature reference values -------------------
mm = [0 31 28 31 30 31 30 31 31 30 31 30 31]; % end of month
t0 = zeros(1,12);
for n = 1:length(mm)
    t0(n) = sum(mm(1:n))*24*3600;
end

% reference results from TRNSYS simulation (Type 56 building model)
% Single family house with ~15 kWh/m² in Strasbourg
% columns: month TRNSYS Simulink AbsError RelError
Q015 = [  1, 5.6, 5.7, 0.1, 1.8; ...
        2, 3.2, 3.7, 0.6, 17.8; ...
        3, 0.7, 1, 0.3, 50.7; ...
        4, 0, 0, 0, 0; ...
        5, 0, 0, 0, 0; ...
        6, 0, 0, 0, 0; ...
        7, 0, 0, 0, 0; ...
        8, 0, 0, 0, 0; ...
        9, 0, 0, 0, 0; ...
        10, 0, 0.2, 0.2, 450; ...
        11, 2.8, 3.5, 0.6, 22.6; ...
        12, 5.3, 5.4, 0.1, 2.2];
y0 = Q015(:,2); % compare to TRNSYS

% ----------------- set reference values initial simulation ---------------
% reference results from initial simulation with ode45 (Dormand-Prince)
y1 = [5.82674422451541;3.49214126008928;1.65016619338347;0;0;0;0;0;0;...
    0.0522460674139822;3.29655091626547;5.43937115984786;];

%% ------------------------------------------------------------------------
%  -------------- simulate the model or call the function -----------------
%  ------------------------------------------------------------------------
load_system(functionname)
load('FR_Strasbourg.mat');      % load weather data
simOut = sim(functionname, 'SrcWorkspace','current','SaveOutput','on','OutputSaveName','yout');
% simOut = sim(functionname, 'SaveOutput','on','OutputSaveName','yout');
y = simOut.get('yout'); % get the whole output vector (one value per simulation timestep)
t = simOut.get('tout'); % get the whole time vector from simu
yy = timeseries(y,t);
yt = resample(yy,t0);
y2 = diff(yt.data(:,1));     % monthly energy balance
close_system(functionname, 0)   % close system, but do not save it


%% -------- calculate the errors -------------------------------------------

%   r    - 'relative' error or 'absolute' error
%   s    - 'sum' - e is the sum of the individual errors of ysim 
%          'mean' - e is the mean of the individual errors of ysim
%          'max' - e is the maximum of the individual errors of ysim
r = 'absolute'; 
s = 'sum';

% error between TRNSYS reference and inital simu 
[e1, ye1] = calculate_verification_error(y0, y1, r, s);
% error between TRNSYS reference and current simu
[e2, ye2] = calculate_verification_error(y0, y2, r, s);
% error between initial and current simu
% [e3 ye3] = calculate_verification_error(y1, y2, r, s);
[~, ye3] = calculate_verification_error(y1, y2, r, s);

% ------------- decide if verification is ok --------------------------------
if e1 > max_error
    v = false;
    s = sprintf('verification %s initial simulation with TRNSYS FAILED: error %3.3g kWh/m² > allowed error %3.3g', ...
        functionnamedisp, e2, max_error);
    show = true;
elseif e2 > max_error
    v = false;
    s = sprintf('verification %s current simulation with TRNSYS FAILED: error %3.3g kWh/m² > allowed error %3.3g', ...
        functionnamedisp, e2, max_error);
    show = true;
% elseif e3 > max_simu_error 
elseif e2 > e1+max_simu_error % corrected because refence is not the same model
    v = false;
    s = sprintf('verification %s initial with current simulation FAILED: error %3.3g kWh/m² > allowed error %3.3g', ...
        functionnamedisp, e2, e1+max_simu_error);
    show = true;
else
    v = true;
    s = sprintf('%s OK: error %3.3g kWh/m²', functionnamedisp, e2);
end

% diplay and plot if required
if (show)
    disp(s)
    disp(['Initial error = ', num2str(e1)])
    sx = 'time in h';               % x-axis label
    st = 'verification simple house model';       % title
    sy1 = 'Energy in kWh/m²';       % y-axis label in the upper plot
    sy2 = 'Difference';             % y-axis label in the lower plot
    % upper legend
    sleg1 = {'TRNSYS','initial','current'};
    % lower legend
    sleg2 = {'TRNSYS vs. initial','TRNSYS vs. current','initial vs. current'};
    %   y - matrix with y-values (reference values and result of the function call)
    %   ye - matrix with error values for each y-value
    display_verification_error(t0(2:end)/(24*3600), [y0, y1, y2], [ye1,ye2,ye3], ...
        st, sx, sy1, sleg1, sy2, sleg2, s)
end
