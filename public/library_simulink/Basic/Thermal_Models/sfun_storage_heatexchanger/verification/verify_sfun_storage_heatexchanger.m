function [v, s] = verify_sfun_storage_heatexchanger(varargin)
% verification of Simulink-Block verify_sfun_storage_heatexchanger_mdl
% Syntax:   [v, s] = template_validate_Function(show)
% 
% Inputs    show - optional flag for display 
%               0 : show results only if validation fails
%               1 : show results allways
% Outputs:  v - true if verification passed, false otherwise
%           s - text string with verification result
%                                                                          
% Literature:   --

% all comments above appear with 'help template_validate_Function' 
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
% 6.1.0     hf      created                                     29may2014
% 6.2.0     hf      return argument is [v, s]                   03oct2014
% 6.2.1     hf      filename validate_ replaced by verify_      09jan2015
% 6.2.2     hf      close system without saving it              16may2016
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

% ---- check input arguments ----------------------------------------------
if nargin == 0
    show = 0;
elseif nargin == 1
    show = varargin{1};
else
    error('verify_sfun_storage_heatexchanger:%s',' too many input arguments')
end

%% ---------- model 1: validate energy balance for multinode model
% ----- set error tolerances ----------------------------------------------
max_error = 2e-3;       % max error between simulation and reference
max_simu_error = 1e-7;  % max error between initial and current simu

% ---------- set model file or functi0n name ------------------------------
functionname = 'verify_sfun_storage_heatexchanger_mdl';

% ----------------- set the literature reference values -------------------
u0 = [0 1 60 120 600 1200]/3600;            % massflow in kg/s
% reference results
y0 = [40,40,40,40,40,40;...
    39,39.0000000327440,39.7503323882074,39.8662135547480,39.9716847109081,39.9857402667959;...
    38,38.0000000327245,39.3133276287425,39.6165383289685,39.9158558302811,39.9574241254317;...
    37,37.0000000327082,38.7357525018684,39.2664764368083,39.8332922754498,39.9152519801004;...
    36,36.0000000326953,38.0526984643520,38.8294556318183,39.7247508387568,39.8594213571710;];
y0e = zeros(1,length(u0)); % energy balance will be set by the model as external balance in THB

% ----------------- set reference values initial simulation ---------------
% result from call at creation of function
y1 = [40,40,40,40,40,40;...
    39,39.0000000327440,39.7503323882074,39.8662135547480,39.9716847109081,39.9857402667959;...
    38,38.0000000327245,39.3133276287425,39.6165383289685,39.9158558302811,39.9574241254317;...
    37,37.0000000327082,38.7357525018684,39.2664764368083,39.8332922754498,39.9152519801004;...
    36,36.0000000326953,38.0526984643520,38.8294556318183,39.7247508387568,39.8594213571710;];
y1e = [0,4.64162551082997,135.584257005659,162.999018122366,191.650987806097,195.759175950488;];

%  -------------- simulate the model or call the function -----------------
y2 = zeros(5,length(u0));
y2e = zeros(1,length(u0));
load_system(functionname)
for n = 1:length(u0) % loop over massflows
    set_param([gcs, '/Constant'], 'Value', num2str(u0(n))); % set massflow
    simOut = sim(functionname, 'SrcWorkspace','current', ...
        'SaveOutput','on','OutputSaveName','yout');
    xx = simOut.get('yout'); % get the whole output vector (one value per simulation timestep)
    y2(:,n) = xx(end,1:5)';  % only the final value is interesting, column 1:5 are the temperatures
    %     y2e(:,n) = xx(end,6:7)';  % column 6:7 are the power
    y2e(n) = xx(end,6);  % column 6 is the power calculated by the s-function
    y0e(n) = -xx(end,7); % reference energy balance
end
close_system(functionname, 0)   % close system, but do not save it


% -------- calculate the errors -------------------------------------------
%   r    - 'relative' error or 'absolute' error
%   s    - 'sum' - e is the sum of the individual errors of ysim 
%          'mean' - e is the mean of the individual errors of ysim
%          'max' - e is the maximum of the individual errors of ysim
r = 'absolute'; 
s = 'max';

% error between reference and initial simu 
[e1e ye1e] = calculate_verification_error(y0e, y1e, r, s);
% [e1 ye1] = calculate_verification_error(y0, y1, r, s);
% error between reference and current simu
[e2e ye2e] = calculate_verification_error(y0e, y2e, r, s);
% [e2 ye2] = calculate_verification_error(y0, y2, r, s);
[e2 ~] = calculate_verification_error(y0, y2, r, s);
% error between initial and current simu
[e3e ye3e] = calculate_verification_error(y1e, y2e, r, s);
% [e3 ye3] = calculate_verification_error(y1, y2, r, s);
[e3 ~] = calculate_verification_error(y1, y2, r, s);

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
    sy1 = 'power balance in W';             % y-axis label in the upper plot
    sy2 = 'Difference in W';                % y-axis label in the lower plot
    % upper legend
    sleg1 = {'reference data','initial simulation','current simulation'};
    % lower legend
    sleg2 = {'ref. vs initial simu','ref. vs current simu','initial simu vs current'};
    %   x - vector with x values for the plot
    x = u0'*3600;
    %   y - matrix with y-values (reference values and result of the function call)
    y = [y0e', y1e', y2e'];
    %   ye - matrix with error values for each y-value
    ye = [ye1e',ye2e',ye3e'];
    display_verification_error(x, y, ye, st, sx, sy1, sleg1, sy2, sleg2, s)
end