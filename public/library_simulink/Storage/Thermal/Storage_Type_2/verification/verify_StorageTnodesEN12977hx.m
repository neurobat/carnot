function [v, s] = verify_StorageTnodesEN12977hx(varargin)
% Verification of the s-function StorageTnodes in the Carnot Toolbox by
% using the benchmark defined in EN 12977-3 Annex A. The benchmark is the
% use of the storage as counter-current heat exchanger. For fixed inlet
% conditions (massflow, temperature) and heat transfer UA the
% analytical solution is given by the EN.
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

% all comments above appear with 'help verify_StorageTnodesEN12977hx' 
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
% author list:      hf -> Bernd Hafner
%
% version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
%
% Version   Author  Changes                                     Date
% 6.1.0     hf      created                                     15dec2014
% 6.1.1     hf      filename validate_ replaced by verify_      09jan2015
% 6.1.2     hf      close system without saving it              16may2016
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

% ---- check input arguments ----------------------------------------------
if nargin == 0
    show = 0;
elseif nargin == 1
    show = varargin{1};
else
    error('verify_StorageTnodesEN12977hx:%s',' too many input arguments')
end

%% ---------- set your specific model or function parameters here
% ----- set error tolerances ----------------------------------------------
max_error = 0.2;        % max error between simulation and reference
max_rerror = 0.01;      % max relative error between simulation and reference
max_simu_error = 1e-5;  % max error between initial and current simu

% ---------- set model file or functi0n name ------------------------------
functionname = 'verify_StorageTnodesEN12977hx_mdl.mdl';
functionnamedisp = strrep(functionname(1:end-4),'_','');

% parameters for benchmark according to EN 12977-3 Annex A
% cp = 4181.0;    % heat capacity of fluid (water, constant)
% T1in = 90;      % °C
% mdot1 = 200;    % kg/h
% T2in = 20;      % °C
% mdot2 = 600;    % kg/h

% ----------------- set the literature reference values -------------------
t0 = 0:3600:24*3600;
y0t = [43.202, 20.391];             % reference results temperature
y0q = 16165;                        % reference results power
y0t = repmat(y0t,length(t0),1);
y0q = repmat(y0q,length(t0),1);

% ----------------- set reference values initial simulation ---------------
y1t = [30,30.0458487469041;43.5019904758258,20.4267265675654;...
    43.1800071328117,20.4144750693930;43.1965892433199,20.4144159103454;...
    43.1972331037349,20.4143851705050;43.1928935356682,20.4142281658268;...
    43.1829580740032,20.4143612352337;43.2138500429794,20.4144258542579;...
    43.2042787419760,20.4144350651695;43.1783430975269,20.4144349381241;...
    43.1843866472142,20.4144348800243;43.1807800751032,20.4144347882462;...
    43.1644979256298,20.4144342791989;43.1803233871452,20.4144347802448;...
    43.1848463716637,20.4144349051262;43.1784340977708,20.4144347372061;...
    43.1716595611632,20.4144345556000;43.1683227696410,20.4144344627943;...
    43.1799885227956,20.4144347747101;43.1859347878036,20.4144349325763;...
    43.1761818486324,20.4144346744851;43.1720057474942,20.4144342483325;...
    43.1747794934378,20.4144346349828;43.1843277471231,20.4144348892981;...
    43.1909682296600,20.4144350675218;];
y1q = [13926.0170216219;16160.3253456116;16163.1710963816;16163.1848377137;...
    16163.1919778955;16163.2284465932;16163.1975375271;16163.1825279638;...
    16163.1803884737;16163.1804179835;16163.1804314788;16163.1804527968;...
    16163.1805710372;16163.1804546554;16163.1804256482;16163.1804646523;...
    16163.1805068354;16163.1805283921;16163.1804559409;16163.1804192721;...
    16163.1804792210;16163.1805782068;16163.1804883965;16163.1804293247;...
    16163.1803879273;];

%% ------------------------------------------------------------------------
%  -------------- simulate the model or call the function -----------------
%  ------------------------------------------------------------------------
load_system(functionname)

% set parameters
simOut = sim(functionname, 'SrcWorkspace','current','SaveOutput','on','OutputSaveName','yout');
y = simOut.get('yout'); % get the whole output vector (one value per simulation timestep)
t = simOut.get('tout'); % get the whole time vector from simu
yy = timeseries(y,t);
yt = resample(yy,t0);
y2t = yt.data(:,1:2);
y2q = yt.data(:,3);
close_system(functionname, 0)   % close system, but do not save it


%% -------- calculate the errors -------------------------------------------

%   r    - 'relative' error or 'absolute' error
%   s    - 'sum' - e is the sum of the individual errors of ysim 
%          'mean' - e is the mean of the individual errors of ysim
%          'max' - e is the maximum of the individual errors of ysim
%          'last' - e is the last value in ysim
rt = 'absolute'; 
rq = 'relative'; 
s = 'last';

% error between reference and initial simu 
[e1t(:,1) ye1t(:,1)] = calculate_verification_error(y0t(:,1), y1t(:,1), rt, s);
[e1t(:,2) ye1t(:,2)] = calculate_verification_error(y0t(:,2), y1t(:,2), rt, s);
E1 = max(e1t(end,:));
[e1q ye1q] = calculate_verification_error(y0q, y1q, rq, s);
% error between reference and current simu
[e2t(:,1) ye2t(:,1)] = calculate_verification_error(y0t(:,1), y2t(:,1), rt, s);
[e2t(:,2) ye2t(:,2)] = calculate_verification_error(y0t(:,2), y2t(:,2), rt, s);
E2 = max(e2t(end,:));
[e2q ye2q] = calculate_verification_error(y0q, y2q, rq, s);
E2Q = max(e2q(end,:));
% error between initial and current simu
[e3t(:,1) ye3t(:,1)] = calculate_verification_error(y1t(:,1), y2t(:,1), rt, s);
[e3t(:,2) ye3t(:,2)] = calculate_verification_error(y1t(:,2), y2t(:,2), rt, s);
E3 = max(e3t(end,:));
[e3q ye3q] = calculate_verification_error(y1q, y2q, rq, s);
E3Q = max(e3q(end,:));

% ------------- decide if verification is ok --------------------------------
% ------ check the temperature results first ------------
if E2 > max_error
    v = false;
    s = sprintf('validate temperature %s with reference FAILED: error %3.3g K > allowed error %3.3g', ...
        functionnamedisp, E2, max_error);
    show = true;
elseif E3 > max_simu_error
    v = false;
    s = sprintf('validate temperature %s with 1st calculation FAILED: error %3.3g K > allowed error %3.3g', ...
        functionnamedisp, E3, max_simu_error);
    show = true;
else
    v = true;
    s = sprintf('temperature %s OK: error %3.3g K, allowed %3.3g K', functionnamedisp, E2, max_error);
end

% diplay and plot if required
if (show)
    disp(s)
    disp(['Initial error = ', num2str(E1)])
    sx = 'Outlet postion';                       % x-axis label
    st = 'verification storage heat exchanger model';       % title
    sy1 = 'Temperature in °C';              % y-axis label in the upper plot
    sy2 = 'Difference';                     % y-axis label in the lower plot
    % upper legend
    sleg1 = {'reference data','initial simulation','current simulation'};
    % lower legend
    sleg2 = {'ref. vs initial simu','ref. vs current simu','initial simu vs current'};
    %   y - matrix with y-values (reference values and result of the function call)
    %   ye - matrix with error values for each y-value
    display_verification_error(t0/3600, [y0t, y1t, y2t], [ye1t,ye2t,ye3t], st, sx, sy1, sleg1, sy2, sleg2, s)
end

% ------ now check the power results ------------
if E2Q > max_rerror
    v = false;
    s = sprintf('validate power %s with reference FAILED: error %3.3g > allowed error %3.3g', ...
        functionnamedisp, E2Q, max_rerror);
    show = true;
elseif E3Q > max_simu_error
    v = false;
    s = sprintf('validate power %s with 1st calculation FAILED: error %3.3g > allowed error %3.3g', ...
        functionnamedisp, E3Q, max_simu_error);
    show = true;
elseif v == true
    s = sprintf('power %s OK: error %1.3g %%, allowed %1.3g %%', functionnamedisp, E2Q*100, max_rerror*100);
end

% diplay and plot if required
if (show)
    disp(s)
    disp(['Initial error = ', num2str(max(e1q(end,:)))])
    sx = 'time in h';                       % x-axis label
    st = 'verification storage heat exchanger model';       % title
    sy1 = 'Power in W';              % y-axis label in the upper plot
    sy2 = 'Difference';                     % y-axis label in the lower plot
    % upper legend
    sleg1 = {'reference data','initial simulation','current simulation'};
    % lower legend
    sleg2 = {'ref. vs initial simu','ref. vs current simu','initial simu vs current'};
    %   y - matrix with y-values (reference values and result of the function call)
    %   ye - matrix with error values for each y-value
    display_verification_error(t0/3600, [y0q, y1q, y2q], [ye1q,ye2q,ye3q], st, sx, sy1, sleg1, sy2, sleg2, s)
end