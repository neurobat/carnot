function [v, s] = verify_StorageTnodesPipe(varargin)
% Validation of the s-function StorageTnodes in the Carnot Toolbox by
% using the benchmark defined in EN 12977-3 Annex A. The benchmark is the
% comparison of the temperatures during a standby phase with the analytical
% solution of the storage losses.
% 
% Syntax:   [v, s] = validate_StorageTnodesPipe(show)
% 
% Inputs    show - optional flag for display 
%               0 : show results only if verification fails
%               1 : show results allways
% Outputs:  v - true if verification passed, false otherwise
%           s - text string with verification result
%                                                                          
% Literature:   EN 12977-3

% all comments above appear with 'help validate_StorageTnodesPipe' 
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
% 6.1.0     hf      created                                     12dec2014
% 6.1.1     hf      filename validate_ replaced by verify_      09jan2015
% 6.1.2     hf      close system without saving it              16may2016
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

% ---- check input arguments ----------------------------------------------
if nargin == 0
    show = 0;
elseif nargin == 1
    show = varargin{1};
else
    error('verify_StorageTnodesPipe:%s',' too many input arguments')
end

%% ---------- set your specific model or function parameters here
% ----- set error tolerances ----------------------------------------------
max_error = 0.1;        % max error between internal and external balance
max_simu_error = 1e-5;  % max error between initial and current simu

% ---------- set model file or functi0n name ------------------------------
functionname = 'verify_StorageTnodesPipe_mdl';
functionnamedisp = strrep(functionname,'_',' ');

% ----------------- set the literature reference values -------------------
t0 = 0:300:4*3600;
% reference results from internal energy balance
y0 = [0;5649080.54045170;11292314.8819471;16935546.8885985;22579101.8574138; ...
    28221837.8096391;33842160.5065138;39288801.6594797;44214945.5076648; ...
    48138449.3833767;50962990.3491301;52868881.0625880;54071861.7480240; ...
    54071861.7480240;54071861.7480240;54071861.7480240;54071861.7480240; ...
    54071861.7480240;54071861.7480240;54071861.7480240;54071861.7480240; ...
    54071861.7480240;54071861.7480240;54071861.7480240;54071861.7480240; ...
    48453388.8371566;42836606.4358498;37227206.9606711;31637502.7967512; ...
    26082413.2580976;20602090.0754633;15374088.7286378;10734396.7211387; ...
    7046326.66522471;4449909.38033491;2729240.53684273;1662372.27020351; ...
    1016727.87887287;612409.329562787;369186.323927856;224326.690981794; ...
    136517.266354075;82907.5242756184;50452.4091857701;30887.0509984335; ...
    18424.3193723386;10854.3864635297;7233.91496850612;4016.90994044017;];            

% ----------------- set reference values initial simulation ---------------
% reference results from external energy balance
y1 = [0;5639204.85030568;11278409.7006114;16917614.5498167;22556812.7178581; ...
    28195025.6234093;33810812.4852289;39253460.0150136;44176983.0090768; ...
    48099477.5169758;50922921.8058628;52827896.6346567;54030882.0169393; ...
    54030882.0169393;54030882.0169393;54030882.0169393;54030882.0169393; ...
    54030882.0169393;54030882.0169393;54030882.0169393;54030882.0169393; ...
    54030882.0169393;54030882.0169393;54030882.0169393;54030882.0169393; ...
    48414385.8679753;42799072.2679770;37192256.1452294;31605319.1589649; ...
    26050619.1554835;20566264.2189666;15341446.6347552;10704852.5189531; ...
    7019300.39205457;4423569.15912875;2703077.28767175;1633837.07710369; ...
    985434.496235619;570405.912704651;322222.706557669;177368.495945716; ...
    89586.4851864718;35989.5921995747;4175.92292191068;-14825.2185710102; ...
    -26998.2108007191;-33245.6764677414;-36849.4818732678;-40416.7082710266;]; 


%% ------------------------------------------------------------------------
%  -------------- simulate the model or call the function -----------------
%  ------------------------------------------------------------------------
load_system(functionname)

simOut = sim(functionname, 'SrcWorkspace','current','SaveOutput','on','OutputSaveName','yout');
y = simOut.get('yout'); % get the whole output vector (one value per simulation timestep)
t = simOut.get('tout'); % get the whole time vector from simu
yy = timeseries(y,t);
yt = resample(yy,t0);
y2i  = yt.data(:,1);    % internal energy balance
y2e  = yt.data(:,2);    % external energy balance

close_system(functionname, 0)   % close system, but do not save it


%% -------- calculate the errors -------------------------------------------

%   r    - 'relative' error or 'absolute' error
%   s    - 'sum' - e is the sum of the individual errors of ysim 
%          'mean' - e is the mean of the individual errors of ysim
%          'max' - e is the maximum of the individual errors of ysim
r = 'absolute'; 
s = 'max';

% error between internal reference and inital simu 
[e1, ye1] = calculate_verification_error(y0, y2i, r, s);
% error between external reference and current simu
[e2, ye2] = calculate_verification_error(y1, y2e, r, s);
% error between internal and external balance
r = 'relative';
[e3, ye3] = calculate_verification_error(y2i, y2e, r, s);

% ------------- decide if verification is ok --------------------------------
if e1 > max_simu_error
    v = false;
    s = sprintf('validate internal balance %s with 1st calculation FAILED: error %3.3g kWh > allowed error %3.3g', ...
        functionnamedisp, e2, max_error);
    show = true;
elseif e2 > max_simu_error
    v = false;
    s = sprintf('validate exernal balance %s with 1st calculation FAILED: error %3.3g kWh > allowed error %3.3g', ...
        functionnamedisp, e3, max_simu_error);
    show = true;
elseif e3 > max_error
    v = false;
    s = sprintf('validate internal and external energy balance of %s FAILED: error %3.3g %% > allowed error %3.3g', ...
        functionnamedisp, e3, max_simu_error);
    show = true;
else
    v = true;
    s = sprintf('validate %s OK: error %3.3g %%', functionnamedisp, e3);
end

% diplay and plot if required
if (show)
    disp(s)
    disp(['Initial error = ', num2str(e1)])
    sx = 'time in h';               % x-axis label
    st = 'Validation pipe connection and storage model';       % title
    sy1 = 'Energy in J';            % y-axis label in the upper plot
    sy2 = 'Difference';             % y-axis label in the lower plot
    % upper legend
    sleg1 = {'internal initial','external initial','internal current','external current'};
    % lower legend
    sleg2 = {'internal initial vs current','external initial vs current','current internal vs external'};
    %   y - matrix with y-values (reference values and result of the function call)
    %   ye - matrix with error values for each y-value
    display_verification_error(t0/3600, [y0, y1, y2i y2e], [ye1,ye2,ye3], ...
        st, sx, sy1, sleg1, sy2, sleg2, s)
end