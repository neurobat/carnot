function [v, s] = verify_carlib(varargin)
% verify_carlib(show) for verification of carlib fluid properties
% function call: [v, s] = verify_carlib(show)
% Inputs: (optional) show:  0 - no results displayed
%                           1 - results displayed
% Outputs:  v - true if validation is ok
%               false, if validation failed      
%           s - text string with the validation result and in case of a 
%               negative result also the name of the property function
% See also carlib, verification_fluidproperty

% ***********************************************************************
% This file is part of the CARNOT Blockset.
% 
% Copyright (c) 1998-2016, Solar-Institute Juelich of the FH Aachen.
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
%  .... something to do later ....
% 
% author list:      aw -> Arnold Wohlfeil
%                   hf -> Bernd Hafner
%
% version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
%
% Version   Author  Changes                                     Date
% 5.0.0     hf      created                                     20aug2013
% 6.1.0     hf      variable number of input arguments          02apr2014
% 6.2.0     hf      return argument is [v, s]                   03oct2014
% 6.2.1     hf      filename verify_ replaced by verification_  09jan2015
% 6.3.0     hf      added validation of FH Duesseldorf          12nov2016
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
% AIR         = 2;
% COTOIL      = 3;
% SILOIL      = 4;
% WATERGLYCOL = 5;
% TYFOCOR_LS  = 6;
% WATER_CONSTANT = 7;
AIR_CONSTANT = 8;

property = {'density', 'heat_capacity', 'thermal_conductivity', ...
    'kinematic_viscosity', 'vapourpressure', 'enthalpy', 'entropy', ...
    'specific_volume', 'evaporation_enthalpy', 'saturationtemperature' ...
    'temperature_conductivity'};

% fluid type    WATER  AIR   COTOIL SILOIL WATERGLYCOL TYFOCOR_LS WATER_CONSTANT AIR_CONSTANT
max_error = [   5e-4,  1e-7, 4e-3,  0.1,   2e-2,       1e-3,      4e-6,          1e-7; ... % maximum error for density
                4e-3,  1e-7, 0.12,  0.1,   3e-2,       3e-3,      1e-3,          1e-7; ... % maximum error for heat_capacity
                2e-2,  1e-7, 1e-7,  5e-4,  1e-7,       2e-3,      2e-3,          1e-7; ... % maximum error for thermal_conductivity
                8e-3,  1e-7, 1e-7,  1e-7,  1e-7,       4e-2,      7e-4,          1e-7; ... % maximum error for kinematic_viscosity
                4e-3,  1e-7, 1e-7,  6e-2,  1e-7,       0.16,      1e-7,          1e-7; ... % maximum error for vapourpressure
                1.1e3, 1e-7, 1e-7,  1e-7,  1e-7,       1e-7,      1e-7,          1e-7; ... % maximum error for enthalpy
                8e-3,  1e-7, 1e-7,  1e-7,  1e-7,       1e-7,      1e-7,          1e-7; ... % maximum error for entropy
                1e-3,  1e-7, 1e-7,  1e-7,  1e-7,       1e-7,      4e-6,          1e-7; ... % maximum error for specific volume
                7e-4,  1e-7, 1e-7,  1e-7,  1e-7,       1e-7,      1e-7,          1e-7; ... % maximum error for evaporation_enthalpy
                2e-2,  1e-7, 1e-7,  1.2,   1e-7,       1e-7,      4e-2,          1e-7; ... % maximum error for saturation_temperature
                2e-2,  1e-7, 1e-7,  1e-7,  1e-7,       1e-7,      1e-3,          1e-7; ... % maximum error for temperature_conductivity
            ]; 
error_type = {'relative', ...  % error evaluation type for density
              'relative', ...  % error evaluation type for heat_capacity
              'relative', ...  % error evaluation type for thermal_conductivity
              'relative', ...  % error evaluation type for kinematic_viscosity
              'relative', ...  % error evaluation type for vapourpressure
              'absolute', ...  % error evaluation type for enthalpy
              'relative', ...  % error evaluation type for entropy
              'relative', ...  % error evaluation type for specific volume
              'relative', ...  % error evaluation type for evaporation_enthalpy
              'absolute', ...  % error evaluation type for saturation_temperature
              'relative', ...  % error evaluation type for temperature_conductivity
            }; 
        
%% ---------- check fluid properties --------------------------------------
for fluid = WATER:AIR_CONSTANT
    for n = 1:length(property)
        [v, s] = verification_fluidproperty(fluid,show,property{n}, ...
            max_error(n,fluid),error_type{n});
        if ~v 
            return
        end
        disp(['    ' s])
    end
end


s = 'verification of CARLIB fluid property functions ok';
