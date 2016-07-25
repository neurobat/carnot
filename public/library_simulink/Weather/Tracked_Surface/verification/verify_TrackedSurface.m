function [v, s] = verify_TrackedSurface(varargin)
% verification for the TrackedSurface block in the Carnot Toolbox.
% Syntax:   [v, s] = validate_TrackedSurface(show)
% 
% Inputs    show - optional flag for display 
%               0 : show results only if verification fails
%               1 : show results allways
% Outputs:  v - true if verification passed, false otherwise
%           s - text string with verification result
%                                                                          
% Literature: --

% all comments above appear with 'help verify_TrackedSurface' 
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
% 
% author list:      hf -> Bernd Hafner
%
% version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
%
% Version   Author  Changes                                     Date
% 6.1.0     hf      created                                     29aug2014
% 6.2.0     hf      return argument is [v, s]                   03oct2014
% 6.2.1     hf      filename validate_ replaced by verify_      09jan2015
% 6.2.2     hf      close system without saving it              16may2016
%
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

% ---- check input arguments ----------------------------------------------
if nargin == 0
    show = 0;
elseif nargin == 1
    show = varargin{1};
else
    error('verify_TrackedSurface:%s',' too many input arguments')
end

%% ---------- set your specific model or function parameters here
% ----- set error tolerances ----------------------------------------------
max_error = 1e-7;       % max error between simulation and reference
max_simu_error = 1e-7;  % max error between initial and current simu
functionname = 'TrackedSurface';
modelfile = 'verify_TrackedSurface_mdl';

% ----------------- set the literature reference values -------------------
% reference results are solar postion
y0 = [158.049588481248,-178.212462399104,0; ...
    155.157528303400,-147.328439293636,0; ...
    147.616041120619,-122.876646684085,0; ...
    137.972881650591,-106.412079719390,0; ...
    127.548698231866,-94.0385790050784,0; ...
    116.960837673282,-83.5489412523234,0; ...
    106.576215625215,-73.7523933631472,0; ...
    96.6963889150905,-63.9107734617564,0; ...
    87.4992266432172,-53.6033039223486,0; ...
    79.7858022722747,-42.0702501884054,0; ...
    73.5865219703469,-29.3983228726138,0; ...
    69.5292757916896,-15.4925963428615,0; ...
    68.0226563466847,-0.776268806831890,0; ...
    69.2413783176795,13.9854385011313,0; ...
    73.0430161501285,28.0064726627130,0; ...
    79.0366087490562,40.8193735054165,0; ...
    86.7365176476975,52.3654935607108,0; ...
    95.3515438682981,63.1545311096205,0; ...
    105.490186412069,72.7681944448890,0; ...
    115.833018974190,82.5486785701998,0; ...
    126.410805947038,92.9326224970444,0; ...
    136.868265981058,105.044745020828,0; ...
    146.627094506201,120.945539643601,0; ...
    154.470846035833,144.349978229375,0; ...
    157.967676734909,-177.943203308683,0;];             
% corrected: collector position is [0 0 0] during nighttime (zenith > 90)
idx = logical(y0(:,1)>90); % find index to zenith > 90
y0(idx,:)=zeros(sum(idx),3); % set these lines to 0

% ----------------- reference values initial simulation -------------------
% result from call at creation of function
y1 = [0,0,0;0,0,0;0,0,0;0,0,0;0,0,0;0,0,0;0,0,0;0,0,0; ...
    87.4992266432172,-53.6033039223486,0; ...
    79.7858022722747,-42.0702501884054,0; ...
    73.5865219703469,-29.3983228726138,0; ...
    69.5292757916896,-15.4925963428615,0; ...
    68.0226563466847,-0.776268806831890,0; ...
    69.2413783176795,13.9854385011313,0; ...
    73.0430161501285,28.0064726627130,0; ...
    79.0366087490562,40.8193735054165,0; ...
    86.7365176476975,52.3654935607108,0; ...
    0,0,0;0,0,0;0,0,0;0,0,0;0,0,0;0,0,0;0,0,0;0,0,0;];

%% ------------------------------------------------------------------------
%  -------------- simulate the model or call the function -----------------
%  ------------------------------------------------------------------------
load_system(modelfile)
simOut = sim(modelfile, 'SrcWorkspace','current', ...
        'SaveOutput','on','OutputSaveName','yout');
y2 = simOut.get('yout'); % get the whole output vector (one value per simulation timestep)
u0 = simOut.get('tout')/3600; % get the whole time vector
close_system(modelfile, 0)   % close system, but do not save it


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
[e1 ye1] = calculate_verification_error(y0, y1, r, s);
% error between reference and current simu
[e2 ye2] = calculate_verification_error(y0, y2, r, s);
% error between initial and current simu
[e3 ye3] = calculate_verification_error(y1, y2, r, s);

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
    sx = 'Time in h';                         % x-axis label
    st = 'Simulink block verification';   % title
    sy1 = 'Angle in �';                     % y-axis label in the upper plot
    sy2 = 'Difference';                     % y-axis label in the lower plot
    % upper legend
    sleg1 = {'reference data','initial simulation','current simulation'};
    % lower legend
    sleg2 = {'ref. vs initial simu','ref. vs current simu','initial simu vs current'};
    %   x - vector with x values for the plot
    x = reshape(u0,length(u0),1);
    %   y - matrix with y-values (reference values and result of the function call)
    y = [y0, y1, y2]; 
    %   ye - matrix with error values for each y-value
    ye = [ye1, ye2, ye3]; 
    display_verification_error(x, y, ye, st, sx, sy1, sleg1, sy2, sleg2, s)
end
