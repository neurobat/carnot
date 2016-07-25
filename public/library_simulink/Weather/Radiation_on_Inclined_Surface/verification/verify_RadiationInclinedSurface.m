function [v, s] = verify_RadiationInclinedSurface(varargin)
% verification for the RadiationInclinedSurface block in the Carnot Toolbox.
% 
% Syntax:   [v, s] = validate_RadiationInclinedSurface(show)
% 
% Inputs    show - optional flag for display 
%               0 : show results only if verification fails
%               1 : show results allways
% Outputs:  v - true if verification passed, false otherwise
%           s - text string with verification result
%                                    
% Literature: /1/ Duffie, Beckmann: Solar engineering of thermal processes,
%                 John Wiley, 2006

% all comments above appear with 'help validate_RadiationInclinedSurface' 
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
% 6.1.0     hf      created                                     25jul2014
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
    error('verify_RadiationInclinedSurface:%s',' too many input arguments')
end

%% ---------- set your specific model or function parameters here
% ----- set error tolerances ----------------------------------------------
max_error = 0.6;        % max error between simulation and reference
max_simu_error = 1e-7;  % max error between initial and current simu
functionname = 'RadiationOnInclinedSurface';
modelfile = 'verify_RadiationInclinedSurface_mdl';

% ----------------- set the literature reference values -------------------
lat = 45;               % reference input values for latitude
lst = 0;                % reference meridian
local = 0;              % local meridian
slope = 30;             % collector slope
azimu = 20;             % collector azimuth
rotat = 0;              % collector rotation
nday = 1:30:365;        % calculate one day for each month
u0 = nday;

brad = slope*pi/180;
gamarad = azimu*pi/180;

standardtime = 10;      % calculate for 10 a.m.
latirad = lat*pi/180;
b = ((nday-81)*360/364)*pi/180;
E = (9.87*sin(2*b)-7.53*cos(b)-1.5*sin(b))/60;
solartime = standardtime+E+(lst-local)/15;
del = 23.45*sin((360*(nday+284)/365)*pi/180);
delrad = del*pi/180;
wdegree = (solartime-12)*15;
wrad = wdegree*(pi/180);
% zenrad = acos(sin(delrad)*sin(latirad)+cos(delrad)*cos(latirad)*cos(wrad));
% zenith = zenrad*(180/pi);
% azimuth = sign(wrad).*(180/pi).*acos((sin(latirad)*cos(zenrad)-sin(delrad))./ ...
%     (cos(latirad)*sin(zenrad)));

% equation from /1/
coosincidenceangle = sin(delrad).*sin(latirad).*cos(brad) - ...
    sin(delrad).*cos(latirad).*sin(brad).*cos(gamarad) + ...
    cos(delrad).*cos(latirad).*cos(brad).*cos(wrad) + ...
    cos(delrad).*sin(latirad).*sin(brad).*cos(gamarad).*cos(wrad) + ...
    cos(delrad).*sin(brad).*sin(gamarad).*sin(wrad);
incidence = (180/pi)*acos(coosincidenceangle);

y0 = incidence';             % reference results

% ----------------- reference values initial simulation -------------------
% result from call at creation of function
%     incidence angle, longitudinal angle, transversal angle
y1 = [56.1861499550134,35.5369290005956,52.6657172114546; ...
    54.4516993994012,27.0388807099601,52.4965734251524; ...
    48.8022377011838,11.6994942724980,48.3273625207398; ...
    42.0416139579096,3.07751332805516,41.9908771762026; ...
    37.9329359394634,14.0272675623824,36.4375574183784; ...
    37.7757893322350,21.0079433997537,33.9471970047625; ...
    39.2141104209522,23.0665342384101,34.8401164152587; ...
    39.9653420043555,18.7972959789592,37.4461985503017; ...
    40.0619591940214,7.84731737346617,39.6781850050673; ...
    41.6553872761548,7.34921460773973,41.3533356821497; ...
    46.4250186473023,22.2895021544269,44.0622131365570; ...
    52.4403659788654,32.9526202500226,48.4254900164251; ...
    56.0117124395848,35.9722226386173,52.2924880353463;];

% --------- validate by simulating the model ------------------------
y2 = zeros(length(nday),3);
load_system(modelfile)
for n = 1:length(nday)
    % maskStr = get_param([gcs, '/Constant'],'DialogParameters');
    set_param([modelfile, '/Add_Solar_Position'], 'lati', num2str(lat));
    set_param([modelfile, '/Add_Solar_Position'], 'longi', '0');
    set_param([modelfile, '/Add_Solar_Position'], 'timezone', '0');
    set_param([modelfile, '/Fixed_Surface'], 'colangle', num2str(slope));
    set_param([modelfile, '/Fixed_Surface'], 'colazi', num2str(azimu));
    set_param([modelfile, '/Fixed_Surface'], 'colrot', num2str(rotat));
    set_param(modelfile, 'Starttime', num2str(nday(n)*24*3600), 'StopTime', num2str((nday(n)+1)*24*3600))

    simOut = sim(modelfile, 'SrcWorkspace','current', ...
        'SaveOutput','on','OutputSaveName','yout');
    xx = simOut.get('yout'); % get the whole output vector (one value per simulation timestep)
%     t = simOut.get('tout'); % get the whole time vector from simu
%     yy = timeseries(xx,t);
%     yt = resample(yy,t0);
%     xx = yt.data;
    y2(n,:) = xx(standardtime+1,:);
end
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

% a_err1 = (y0-y1(:,1));  % error between reference data and initial simulation
% a_err2 = (y0-y2(:,1));  % error between reference data and current simulation
% a_err3 = (y1-y2);       % error between initial simulation and current simulation

% error between reference and initial simu 
[e1, ye1] = calculate_verification_error(y0, y1(:,1), r, s);
% error between reference and current simu
[e2, ye2] = calculate_verification_error(y0, y2(:,1), r, s);
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
    s = sprintf('%s OK: error %3.3f°', functionname, e2);
end

% ------------ diplay and plot options if required ------------------------
if (show)
    disp(s)
    disp(['Initial error = ', num2str(e1)])
    sx = 'Day';                         % x-axis label
    st = 'Simulink block verification';   % title
    sy1 = 'Angles in °';                    % y-axis label in the upper plot
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

