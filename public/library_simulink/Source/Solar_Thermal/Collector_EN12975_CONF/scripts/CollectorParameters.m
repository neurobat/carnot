% creates and saves the parameter set for the configurated Solar Thermal 
% Collector  model "Collector_EN12975_FlatPlate_CONF"
%
% Inputs:       none
% Syntax:       CollectorParametersFlatPlate
%                                                                          
% Literature: EN ISO 12975
%             ISO 22975

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
% author list:     hf -> Bernd Hafner
%
% version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
%
% Version   Author  Changes                                     Date
% 6.1.0     hf      created                                     29nov2014
%
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

STC.Acoll = 3.5;    % brutto collector surface in m²
STC.len = 0.1;      % length between inlet and outlet in m
STC.fta = 0.7;      % optcal efficiency F' x Tau x Alpha
STC.c1 = 0.7;       % heat loss coefficient c1 in W/m²/K
STC.c2 = 0.001;     % heat loss coefficient c2 in W/m²/K²
STC.c3 = 0.0;       % wind speed dependant heat loss in W*s/m³/K
STC.c4 = 0.0;       % long wave radiation loss coefficient in W/m²/K 
STC.c5 = 7000;      % effective thermal capacity in J/m²/K
STC.c6 = 0.0;       % wind dependance of conversion factor s/m
STC.KbAngles = [0:5:90]; % longitudinal IAM values
STC.KbL = [1.0000    1.0000    0.9999    0.9996    0.9991    0.9982    ...
    0.9965  0.9935    0.9886    0.9807    0.9678    0.9473    0.9148    ...
    0.8638   0.7846    0.6644    0.4907    0.2599    0.0000];
STC.KbT = [1.00000 1.00000 1.00000 1.00000 1.00000 1.00000 1.00000 ...
    1.00000 1.00000 1.00000 1.00000 0.87500 0.75000 0.62500 0.50000 ...
    0.37500 0.25000 0.12500 0];
STC.Kd = 0.92;      % IAM for diffuse radiation
STC.lin = 10;       % linear pressure drop coefficient
STC.qua = 10;       % quadratic pressure drop coefficient

save DefaultCollector.mat STC
