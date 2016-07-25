function [v, s] = verify_StorageType3(varargin)
% Verification of the block Storage_Type3 in the Carnot library. 
% 
% Syntax:   [v, s] = verify_StorageType3(show)
% 
% Inputs    show - optional flag for display 
%               0 : show results only if verification fails
%               1 : show results allways
% Outputs:  v - true if verification passed, false otherwise
%           s - text string with verification result
%                                                                          
% Literature:   -

% all comments above appear with 'help validate_StorageTnodesDataFitHX' 
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
% 6.1.0     hf      created                                     22sep2015
% 6.1.1     hf      close system without saving it              16may2016
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

% ---- check input arguments ----------------------------------------------
if nargin == 0
    show = 0;
elseif nargin == 1
    show = varargin{1};
else
    error('verify_StorageType3:%s',' too many input arguments')
end

%% ---------- set your specific model or function parameters here
% ----- set error tolerances ----------------------------------------------
max_error = 0.2;            % max error between simulation and reference
max_simu_error = 1.0e-6;    % max error between initial and current simu

% ---------- set model file or functi0n name ------------------------------
functionname = 'verify_StorageType3_mdl.slx';
functionnamedisp = strrep(functionname(1:end-4),'_','');


% ----------------- set the literature reference values -------------------
t0 = 0:3600:24*3600;
% reference results temperature
% reference scenario is first simulation for the moment :-/
% if a new reference is defined, use y0 as y1
y0 = [55;57.3965381119442;59.2579995850278;59.6491693184766;59.7311739056364; ...
    59.7483315807007;59.7519178621092;59.7562163754091;58.9387582782468; ...
    59.5796371492643;59.7165818493570;59.7452751767550;59.7546445109171; ...
    59.5496370622376;59.7077344292575;59.7434343194617;59.7508951650724; ...
    59.7524534872846;59.7527788454926;59.7553872025578;58.9385721568887; ...
    59.5796007475456;59.7165742729155;59.7452735991745;59.7546441017179];

% ----------------- set reference values initial simulation ---------------
y1 = y0; % reference scenario is first simulation for the moment

%% ------------------------------------------------------------------------
%  -------------- simulate the model or call the function -----------------
%  ------------------------------------------------------------------------
load_system(functionname)

% set parameters
% simOut = sim(functionname, 'SrcWorkspace','current','SaveOutput','on','OutputSaveName','yout');
simOut = sim(functionname, 'SaveOutput','on','OutputSaveName','yout');
y = simOut.get('yout'); % get the whole output vector (one value per simulation timestep)
t = simOut.get('tout'); % get the whole time vector from simu
yy = timeseries(y,t);
yy = resample(yy,t0);
y2 = yy.data;
close_system(functionname, 0)   % close system, but do not save it


%% -------- calculate the errors -------------------------------------------

%   r    - 'relative' error or 'absolute' error
%   s    - 'sum' - e is the sum of the individual errors of ysim 
%          'mean' - e is the mean of the individual errors of ysim
%          'max' - e is the maximum of the individual errors of ysim
%          'last' - e is the last value in ysim
r = 'absolute'; 
s = 'max';

% error between reference and initial simu 
% [e1, ye1] = calculate_verification_error(y0(:,1), y1(:,1), rt, s);
% comparison not necessary for the moment as y0 = y1 ...

% error between reference and current simu
[e2, ye2] = calculate_verification_error(y0, y2, r, s);

% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
% !!! remove the next two lines if you have a different reference !!!
e1 = e2;    % comparison not necessary for the moment as y0 = y1  !!!
ye1 = ye2;  %                                                     !!!
% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

% error between initial and current simu
[e3, ye3] = calculate_verification_error(y1, y2, r, s);

% ------------- decide if verification is ok ------------------------------
% ------ check the temperature results ------------------------------------
if e2 > max_error
    v = false;
    s = sprintf('validate temperature %s with reference FAILED: error %3.3g K > allowed error %3.3g', ...
        functionnamedisp, e2, max_error);
    show = true;
elseif e3 > max_simu_error
    v = false;
    s = sprintf('validate temperature %s with 1st calculation FAILED: error %3.3g K > allowed error %3.3g', ...
        functionnamedisp, e3, max_simu_error);
    show = true;
else
    v = true;
    s = sprintf('temperature %s OK: error %3.3g K, allowed %3.3g K', ...
        functionnamedisp, e2, max_error);
end

% diplay and plot if required
if (show)
    disp(s)
    disp(['Initial error = ', num2str(e1)])
    sx = 'Temperature in °C';               % x-axis label
    st = 'verify Storage Type 3';           % title
    sy1 = 'time in h';                      % y-axis label in the upper plot
    sy2 = 'Difference in K';                % y-axis label in the lower plot
    % upper legend
    sleg1 = {'reference data','initial simulation','current simulation'};
    % lower legend
    sleg2 = {'ref. vs initial simu','ref. vs current simu','initial simu vs current'};
    %   y - matrix with y-values (reference values and result of the function call)
    %   ye - matrix with error values for each y-value
    display_verification_error(t0/3600, [y0, y1, y2], [ye1,ye2,ye3], ...
        st, sx, sy1, sleg1, sy2, sleg2, s)
end
