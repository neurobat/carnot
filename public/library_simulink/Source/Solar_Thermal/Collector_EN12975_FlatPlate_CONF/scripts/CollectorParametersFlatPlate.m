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
% Version   Author  Changes                                     Date
% 6.1.0     hf      created                                     29nov2014
%
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

FPC.Acoll = 2.5;    % brutto collector surface in m²
FPC.len = 2.3;      % length between inlet and outlet in m
FPC.fta = 0.75;     % optcal efficiency F' x Tau x Alpha
FPC.c1 = 3.5;       % heat loss coefficient c1 in W/m²/K
FPC.c2 = 0.01;      % heat loss coefficient c2 in W/m²/K²
FPC.c3 = 0.0;       % wind speed dependant heat loss in W*s/m³/K
FPC.c4 = 0.0;       % long wave radiation loss coefficient in W/m²/K 
FPC.c5 = 7000;      % effective thermal capacity in J/m²/K
FPC.c6 = 0.0;       % wind dependance of conversion factor s/m
FPC.b0 = 0.1;       % b0 value for IAM
FPC.Kd = 0.92;      % IAM for diffuse radiation
FPC.lin = 10;       % linear pressure drop coefficient
FPC.qua = 10;       % quadratic pressure drop coefficient

save DefaultCollectorFlatPlate.mat FPC