% This m-script is an example how the input parameters can be set for the 
% m-function "annualcosts.m".
% If you used the economy_ecology block in your model, the parameter FuelCosts_RunTime
% is already available for the component you specified. If not, you have to give it here.
% Insert all of the parameters and then run the script. 
% Usetime      :  time of use of the system                      [y]
% IntRate      :  Interest rate per year                         [1/y]
% IncFuel      :  Expected annual increase of fuel costs         [1/y]
% IncMat       :  Expected annual increase of permanent costs    [1/y]
% CompLifeTime :  lifetime of component                          [y] 
% InvestCosts  :  Investment costs                               [-]
% ContOpCosts  :  Continuous operation costs                     [-]
% RunOpCosts   :  Operation costs depending on the run time      [1/s]
% FuelCosts    :  Fuel costs within one year                     [1/y]
% RunTime      :  Annual opertion time of component              [s]
% RunTimeDep   :  Dependence of the lifetime of the component
%                 on its annual operation time (yes = 1, no = 0) [-]
% see also: annualcosts


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
% 1.1.0     hf      created                                     around1999


UseTime = 10;                               % scalar
IntRate = 0.08;                             % scalar
IncPerm =0.00;                              % scalar
IncDisc = 0.00;                             % scalar
% component Nr.     1       2               3
CompLifeTime    = [ 2 		3               10];    % to be defined for each component
InvestCosts     = [ 10 		10              10];	%  "
ContOpCosts     = [ 1 		1               1];     %  "
RunOpCosts      = [ 0       1/(3600*8760)   0];     %  "
FuelCosts       = [ 0       3               0];     %  "
RunTime         = [ 0       8760*3600       0];     %  "
RunTimeDep      = [ 0       1               0];     %  "

% If you used the economy_ecology block in the simulation e.g. for the first component
% it will be replaced here:
if exist('input_annual_costs')
   FuelCosts(1) = FuelCosts_RunTime(1);
   RunTime(1) = FuelCosts_RunTime(2);
end

% call of the functon annualcosts
Annuity = annualcosts(UseTime,IntRate,IncPerm,IncDisc,InvestCosts,...
   CompLifeTime,ContOpCosts,RunOpCosts,RunTimeDep,FuelCosts,RunTime)
