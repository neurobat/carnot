function [v, s] = verify_carlib(varargin)
% function verify_carlib(show)
% Inputs: (optional) show:  0 - no results displayed
%                           1 - results displayed
%                                                                          
% Description:  script for the verification of the carlib (carnot library)
% See also: carlib
% Literature:   /1/  VDI Waermeatlas 1991
%               /2/  www.iapws.org

% all comments above appear with 'help verify_carlib' 
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
%  .... something to do later ....
% 
% author list:      aw -> Arnold Wohlfeil
%                   hf -> Bernd Hafner
%
% version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
%
% Version  Author   Changes                                     Date
% 5.0.0    hf       created                                     20aug2013
% 6.1.0    hf       variable number of input arguments          02apr2014
% 6.2.0     hf      return argument is [v, s]                   03oct2014
% 6.2.1     hf      filename verify_ replaced by verification_  09jan2015
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

% ---- check input arguments ----------------------------------------------
if nargin == 0
    show = 0;
elseif nargin == 1
    show = varargin{1};
else
    error('verification_carlib:%s',' too many input arguments')
end

%% ---------- set your specific model or function parameters here
% Fluids
WATER       = 1;
AIR         = 2;
COTOIL      = 3;
SILOIL      = 4;
WATERGLYCOL = 5;
TYFOCOR_LS  = 6;
WATER_CONSTANT = 7;
AIR_CONSTANT = 8;


%% ---------- check fluid properties --------------------------------------
for fluid = TYFOCOR_LS:TYFOCOR_LS
    % --------------- density ---------------------------------------------
    [v, s] = verification_density(fluid,show);
    if ~v 
        break
    end
    disp(['    ' s])
    % --------------- heat capactiy ---------------------------------------
    [v, s] = verification_heat_capacity(fluid,show);
    if ~v 
        break
    end
    disp(['    ' s])
    % --------------- kinematic viscostiy ---------------------------------
    [v, s] = verification_kinematic_viscosity(fluid,show);
    if ~v 
        break
    end
    disp(['    ' s])
    % --------------- thermal conductivity --------------------------------
    [v, s] = verification_thermal_conductivity(fluid,show);
    if ~v 
        break
    end
    disp(['    ' s])
    % --------------- vapour pressure -------------------------------------
    [v, s] = verification_vapour_pressure(fluid,show);
    if ~v 
        break
    end
    disp(['    ' s])
end

s = 'verification of CARLIB ok';
