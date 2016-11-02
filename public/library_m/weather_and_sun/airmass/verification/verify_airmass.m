function [v, s] = verify_airmass(varargin)
% function to validate the function 'airmass'
% 
% v = validate_airmass([show])
% inputs
%   show - optional flag for display 
%       0 : show results only if verification fails
%       1 : show results allways
% 
% outputs
%   v - result of verification
%       0 : failed
%       1 : ok
% 
% function calls: 
% function is used by: --
% this function calls: --
% Literature: Duffie, Beckmann: Solar Engineering of Thermal Processes, 2006

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
% author list:     hf -> Bernd Hafner
%
% version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
%
% Version  Author   Changes                                     Date
% 6.1.0    hf       created                                     25mar2014
% 6.1.1    hf       variable number of input arguments          02apr2014
% 6.2.0    hf       return argument is [v, s]                   03oct2014
% 6.2.1     hf      filename validate_ replaced by verify_      09jan2015
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

% ---- check input arguments ----------------------------------------------
if nargin == 0
    show = 0;
elseif nargin == 1
    show = varargin{1};
else
    error('verify_airmass:%s',' too many input arguments')
end

%% ---------- set your specific model or function parameters here
% ----- set error tolerances ----------------------------------------------
max_error = 0.07;      % max error between simulation and reference
max_simu_error = 1e-7;  % max error between initial and current simu

% ---------- set model file or functin name -------------------------------
% initial values and constants
t = 3600*(12+24*(1:30:365));        % legal time is noon at different days
u0 = t/24/3600;                     % input for plots
latitude = 50;
longitude = 0;
longitude0 = 0;
functionname = 'airmass';

% ----------------- set the literature reference values -------------------
n = t./(24*3600);
del=23.45*sin((360*(n+284)/365)*pi/180);
delrad=del*pi/180;
wdegree = time2hourangle(t);
wrad=wdegree*(pi/180);
zenith=(180/pi)*acos(sin(delrad).*sin(latitude*pi/180) + ...
    cos(delrad).*cos(latitude*pi/180).*cos(wrad));
if(0 < zenith < 70) 
   y0 = 1./(cos(zenith*pi/180));
else
   a=90-zenith;
   a=a*pi/180;
   y0 = ((1229+(614*sin(a)).^2).^(.5))-614*sin(a);
end
y0=y0';

% ----------------- set reference values initial simulation ---------------
y1 = [3.40865367285932;2.58680138038784;1.83563326618712;1.41885617849450;...
    1.21665171662139;1.13241373515914;1.12097973546722;1.17509864389308;...
    1.32280850216878;1.63621941245962;2.23875270830329;3.12166715164075;...
    3.47492956146556;];    % reference simu

%% ------------------------------------------------------------------------
%  -------------- simulate the model or call the function -----------------
%  ------------------------------------------------------------------------
y2 = airmass(t, latitude, longitude, longitude0);    % simu

% ------------- decide if verification is ok --------------------------------
% -------- calculate the errors -------------------------------------------
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
    disp(['Initial error', num2str(e1)])
    sx = 'Day';
    sy1 = 'Airmass';
    sy2 = 'Difference';
    sleg1 = {'reference data','initial simulation','current simulation'};
    sleg2 = {'ref. vs initial simu','ref. vs current simu','initial simu vs current'};
    x = reshape(u0,length(u0),1);
    y = [reshape(y0,length(y0),1), reshape(y1,length(y1),1), reshape(y2,length(y2),1)];
    ye = [reshape(ye1,length(ye1),1), reshape(ye2,length(ye2),1), reshape(ye3,length(ye3),1)];
    display_verification_error(x, y, ye, functionname, sx, sy1, sleg1, sy2, sleg2, s)
    % display_verification_error(x, y, ye, st, sx, sy1, sleg1, sy2, sleg2, stxt)
    %   x - vector with x values for the plot
    %   y - matrix with y-values (reference values and result of the function call)
    %   ye - matrix with error values for each y-value
    %   st - string with title for upper window
    %   sx  - string for the x-axis label
    %   sy1  - string for the y-axis label in the upper window
    %   sleg1 - strings for the upper legend (number of strings must be equal to
    %          number of columns in y-Matrix, e.g. {'firstline','secondline'}
    %   sy2 - string for the y-label of the lower window
    %   sleg2 - strings for the lower legend (number of strings must be equal to
    %          number of columns in y-Matrix, e.g. {'firstline','secondline'}
    %   stxt - string with the verification result information
end