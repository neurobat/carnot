function [v, s] = template_verify_Function(varargin)
% Template for Simulink-Block or Matlab Function verification in the Carnot 
% Toolbox. If your Block uses functions which may also be used as m-functions,
% please use this template for both calls (Simulink-Block and m-function).
% Change the name of the function to "verfiy_YourBlockName" otherwise it
% will not be found be the verify_carnot.m skript in the version_manager
% folder.
% Syntax:   [v, s] = template_verify_Function(show)
% 
% Inputs    show - optional flag for display 
%               0 : show results only if verification fails
%               1 : show results allways
% Outputs:  v - true if verification passed, false otherwise
%           s - text string with verification result
%                                                                          
% Literature:   --

% all comments above appear with 'help template_verify_Function' 
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
% 6.2.2     hf      comments corrected                          18sep2015
% 6.2.3     hf      added resampling of timeseries              27nov2015
% 6.2.4     hf      close system without saving it              16may2016
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

% ---- check input arguments ----------------------------------------------
if nargin == 0
    show = 0;
elseif nargin == 1
    show = varargin{1};
else
    error('template_verify_Function:%s',' too many input arguments')
end

%% ---------- set your specific model or function parameters here
% ----- set error tolerances ----------------------------------------------
max_error = 0.2;        % max error between simulation and reference
max_simu_error = 1e-7;  % max error between initial and current simu

% ---------- set model file or function name ------------------------------
m_function = false; % set to 'true' if it is an m-function
functionname = 'template_verify_SimulinkBlock_mdl';

% m_function = true; % set to 'true' if it is an m-function
% functionname = 'myM_Function_verificationDemo';

% ----------------- set the literature reference values -------------------
u0 = 1:10;                  % reference input values
% t0 = 0:10;                  % reference time vector
y0 = 11:20;                 % reference results

% ----------------- set reference values initial simulation ---------------
y1 = 11.1:20.1;             % result from call at creation of function

%% ------------------------------------------------------------------------
%  -------------- simulate the model or call the function -----------------
%  ------------------------------------------------------------------------
% y2 = zeros(length(t0),length(u0));
if m_function
    eval(['y2 = ' functionname '(u0);'])   % current result
else
    y2 = zeros(1,length(u0));
    load_system(functionname)
    for n = 1:length(u0)
        set_param([gcs, '/Constant'], 'Value', num2str(u0(n)));
        simOut = sim(functionname, 'SrcWorkspace','current', ...
            'SaveOutput','on','OutputSaveName','yout');
        yy = simOut.get('yout'); % get the whole output vector (one value per simulation timestep)
        % tt = simOut.get('tout'); % get the whole time vector from simu
        % yy_ts = timeseries(yy,tt);
        % yt = resample(yy_ts,t0);
        y2(n) = yy(end);       % in this example, only the final value is interesting
        % y2(:,n) = yt.data;     % in this example, the timedepandant output is interesting
    end
    close_system(functionname, 0)   % close system, but do not save it
end


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
    sx = 'x-label';                         % x-axis label
    if m_function
        st = 'm-Function verification';       % title
    else
        st = 'Simulink block verification';   % title
    end
    sy1 = 'y-label up';                     % y-axis label in the upper plot
    sy2 = 'Difference';                     % y-axis label in the lower plot
    % upper legend
    sleg1 = {'reference data','initial simulation','current simulation'};
    % lower legend
    sleg2 = {'ref. vs initial simu','ref. vs current simu','initial simu vs current'};
    %   x - vector with x values for the plot
    x = reshape(u0,length(u0),1);
    %   y - matrix with y-values (reference values and result of the function call)
    y = [reshape(y0,length(y0),1), reshape(y1,length(y1),1), reshape(y2,length(y2),1)];
    % y = [y0, y1, y2]; 
    %   ye - matrix with error values for each y-value
    ye = [reshape(ye1,length(ye1),1), reshape(ye2,length(ye2),1), reshape(ye3,length(ye3),1)];
    % ye = [ye1, ye2, ye3]; 
    sz = strrep(s,'_',' ');
    display_verification_error(x, y, ye, st, sx, sy1, sleg1, sy2, sleg2, sz)
end
