function [v, s] = verify_sfun_storage_heatexchanger2(varargin)
% verification of Simulink-Block verify_sfun_storage_heatexchanger_mdl
% Syntax:   [v, s] = template_validate_Function(show)
% 
% Inputs    show - optional flag for display 
%               0 : show results only if verification fails
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

%% --- model 2 validate the different functions----------------------------
% ----- set error tolerances ----------------------------------------------
max_error = 0.005;      % max error between simulation and reference
max_simu_error = 1e-7;  % max error between initial and current simu

% ---------- set model file or functi0n name ------------------------------
functionname = 'verify_sfun_storage_heatexchanger2_mdl';

% tube heat exchanger, theoretical model
% 4  DIA_PIPE    outer diameter of heat exchanger pipe       m        
% 5  S_WALL      wall thickness                              m        
% 6  LENGTH      length of pipe                              m        
% 7  COND_WALL   conductivity  heat exch. material           W/(m*K) 

% finned tube heat exchanger (theoretical model)
% 8  DIA_FIN     total diameter of pipe with fins            m        
% 9  S_WALL_FIN  wallthickness fin                           m        
% 10 N_FIN       number of fins per meter                    1/m      

% heat exchanger, heat transfer fitted to measurement  
%   UA = uac+mdot*uam+(Theatexchanger-Tstorage)*uat   portID = 203, = 303 for stratified charging   
% EN 12977 heat exchanger, heat transfer fitted to measurement    */
%   UA = uac * mdot^uam * ((Theatexchanger+Tstorage)/2)^uat     portID = 204, = 304 for stratified charging  
% 4  UA_C        constant heat transfer rate           W/K        
% 5  UA_M        massflow dependant heat transfer      W*s/(kg*K) 
% 6  UA_T        temperature dependant heat transfer   W/K/°C     

hxname = {'smooth tube theoretical', 'smooth tube theoretical - stratified', ...
    'finned tube theoretical', 'finned tube theoretical  - stratified', ...
    'heat transfer from data fit', 'heat transfer from data fit  - stratified', ...
    'heat transfer data fit EN12977', 'heat transfer data fit EN12977  - stratified'};

dpipe = 0.03325;
dwall = 0.001;
condwall = 50;
dfin = dpipe+0.02;
sfin = 0.001;
nfin = 100;

uac = 102.7;    % parameters for EN12977 from ITW Uni Stuttgart test report 04STO103
uam = 0.226;    % according to test report UA is around 450 W/K at 0.1 kg/s at 35°C
uat = 0.550;
Ahx = 1.5;

mdot = 0.1;
tin = 40;
tstg = 30;
L = Ahx/(pi*dpipe);

param = [ ...
    dpipe, dwall, L, condwall, 0,0,0; ... % smooth tube theoretical
    dpipe, dwall, L, condwall, 0,0,0; ... % smooth tube theoretical - stratified
    dpipe, dwall, L, condwall, dfin, sfin, nfin; ... % finned tube theoretical
    dpipe, dwall, L, condwall, dfin, sfin, nfin; ... % finned tube theoretical  - stratified
    100, 1, 1, 0,0,0,0; ... % heat transfer from data fit [ua0, uam, uat, 0,0,0,0]
    100, 1, 1, 0,0,0,0; ... % heat transfer from data fit  - stratified [ua0, uam, uat, 0,0,0,0]
    uac, uam, uat, 0,0,0,0; ... % heat transfer data fit EN12977
    uac, uam, uat, 0,0,0,0; ... % heat transfer data fit EN12977  - stratified
    ];
u0 = 1:size(param,1);            % heat exchanger type

% ----------------- set the literature reference values -------------------
% reference results
% ua for smooth tube theoretical
gr = grashof(tin,tstg,1e5,1,0,dpipe*pi/2);
pr = prandtl((tin+tstg)/2,1e5,1,0);
rho = density(tin,1e5,1,0);
v = mdot/rho/(pi/4*(dpipe-2*dwall)^2);
re = reynolds(tin,v,1e5,1,0,(dpipe-2*dwall));
nuss = 0.5*(gr*pr)^0.25;
% nuss = 0.3*(gr*pr)^0.25;
nu_in = 0.0235*(re^0.8-230)*pr^0.48; % original equation from Wagner
% nu_in = 0.3*re^0.8*pr^0.5; % adapted to coils
u_out = (nuss*thermal_conductivity(tstg,1e5,1,0))/(dpipe*pi/2);
u_in = nu_in*thermal_conductivity(tin,1e5,1,0)/dpipe;
% u_in = 1e9;
UA1 = Ahx/(1/u_out + dwall/condwall + 1/u_in); % heat transfer in W/K

% finned tube theoretical
m = sqrt(2.0*u_out/(condwall*sfin));
u_fin = (u_out*(1.0 - sfin*nfin) ...     % heat transfer remaining from the pipe */
    + sfin*nfin*m*condwall*tanh(m*0.5*(dfin-dpipe)));
UA2 = Ahx/(1/u_fin + dwall/condwall + 1/u_in); % heat transfer in W/K

% dat1 fit 1
UA3 = 100+mdot*1+(tin-tstg)*1;
% dat1 fit 1
UA4 = uac*mdot^uam*((tin+tstg)/2)^uat;
% heat exchagner surface is 1 m², so UA = U*1
ua = [UA1;UA1;UA2;UA2;UA3;UA3;UA4;UA4];
thxn = tstg + (tin-tstg)*exp(-ua/(mdot*heat_capacity(tin,1e5,1,0)));
%  logaritmic temperature difference */
logthx = log((tin-tstg)./(thxn-tstg));
y0 = ua.*(tin-thxn)./logthx; % heat transfer in W

% ----------------- set reference values initial simulation ---------------
% result from call at creation of function
y1 = [2759.82372467813;2759.82372467813;3357.52645889439;3357.52645889439;...
    967.865359821913;967.865359821913;2689.86581202153;2689.86581202153;];

%% ------------------------------------------------------------------------
%  -------------- simulate the model or call the function -----------------
%  ------------------------------------------------------------------------
y2 = zeros(length(u0),1);
load_system(functionname)
for n = 1:length(u0) % loop over hx types
    set_param([gcs, '/sfun_storage_heatexchanger'], 'idn', char(hxname(n))); % set hx-type
    set_param([gcs, '/sfun_storage_heatexchanger'], 'pp', ['[ ' num2str(param(n,:)) ' ]']); % set parameters
    
    simOut = sim(functionname, 'SrcWorkspace','current', ...
        'SaveOutput','on','OutputSaveName','yout');
    xx = simOut.get('yout'); % get the whole output vector (one value per simulation timestep)
    y2(n) = xx(end);  % only the final value is interesting, 
end
close_system(functionname, 0)   % close system, but do not save it


%% -------- calculate the errors -------------------------------------------

%   r    - 'relative' error or 'absolute' error
%   s    - 'sum' - e is the sum of the individual errors of ysim 
%          'mean' - e is the mean of the individual errors of ysim
%          'max' - e is the maximum of the individual errors of ysim
r = 'absolute'; 
s = 'max';

% error between reference and initial simu 
[e1 ye1] = calculate_verification_error(y0, y1, r, s);
% error between reference and current simu
[e2 ye2] = calculate_verification_error(y0, y2, r, s);
% error between initial and current simu
[e3 ye3] = calculate_verification_error(y1, y2, r, s);

% ------------- decide if verification is ok --------------------------------
if e2 > max_error
    v = false;
    s = sprintf('verification hx-models %s with reference FAILED: error %3.3f > allowed error %3.3f', ...
        functionname, e1, max_error);
    show = true;
elseif e3 > max_simu_error
    v = false;
    s = sprintf('verification hx-models %s with 1st calculation FAILED: error %3.3f > allowed error %3.3f', ...
        functionname, e3, max_simu_error);
    show = true;
else
    v = true;
    s = sprintf('hx-models %s OK: error %3.3f', functionname, e2);
end

% ------------ diplay and plot options if required ------------------------
if (show)
    disp(s)
    disp(['Initial error = ', num2str(e1)])
    sx = 'Heat exchanger model';            % x-axis label
    st = 'Simulink block verification';       % title
    sy1 = 'power in W';                     % y-axis label in the upper plot
    sy2 = 'Difference';                     % y-axis label in the lower plot
    % upper legend
    sleg1 = {'reference data','initial simulation','current simulation'};
    % lower legend
    sleg2 = {'ref. vs initial simu','ref. vs current simu','initial simu vs current'};
    %   y - matrix with y-values (reference values and result of the function call)
    % y = [reshape(y0,length(y0),5), reshape(y1,length(y1),5), reshape(y2,length(y2),5)];
    y = [y0, y1, y2];
    %   ye - matrix with error values for each y-value
    % ye = [reshape(ye1,length(ye1),5), reshape(ye2,length(ye2),5), reshape(ye3,length(ye3),5)];
    ye = [ye1,ye2,ye3];

    display_verification_error(u0', y, ye, st, sx, sy1, sleg1, sy2, sleg2, s)
end
