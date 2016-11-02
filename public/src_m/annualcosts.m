function [Annuity] = annualcosts(UseTime,IntRate,IncFuel,IncMat,InvestCosts,...
   CompLifeTime,ContOpCosts,RunOpCosts,RunTimeDep,FuelCosts,RunTime)
% ANNUALCOSTS calculates the annual costs of a system all through its lifetime.
% It considers the investment costs, continuous operation costs and operation costs 
% which depend on the runtime and also fuel costs. Interest rate and 
% annual increase of permanent costs are also taken into consideration. 
% The output is calculated in the same currency
% as the given by the input. Remaining values of the components are calculated
% due to linear degression. 
% For the use together with a simulation model you can use the output of the 
% economy_ecology block to get the values for the parameters "FuelCosts" and
% RunTime". They are written to the workspace.
% The program refers to chapter 2.1. of [Hau]:
% Haubrich, Hans-Jürgen: Elektrische Energieversorgungssysteme. ISBN 3-86073-204-8, 1994.
%
% syntax:
%
% annualcosts(UseTime,IntRate,IncFuel,IncMat,InvestCosts,...
%   CompLifeTime,ContOpCosts,RunOpCosts,FuelCosts,RunTime,RunTimeDep);
%
% INPUT
% Parameters        description                                  unit
%
% Usetime      :  time of use of the system                      [y]
% IntRate      :  Interest rate per year                         [1/y]
% IncFuel      :  Expected annual increase of fuel costs         [1/y]
% IncMat       :  Expected annual increase of permanent costs    [1/y]
% CompLifeTime :  lifetime of component                          [y] 
% InvestCosts  :  Investment costs                               [-]
% ContOpCosts  :  Continuous operation costs                     [-]
% RunOpCosts   :  Operation costs depending on the run time      [1/s]
% FuelCosts    :  Fuel costs within one year                     [1/y]
% RunTime      :  Run time of component                          [s]
% RunTimeDep   :  Dependence of the lifetime of the comp. on
%                       its run time (yes = 1, no = 0)           [-]
%
% OUTPUT
% Annuity       :   Annuity of the whole system							[costs/y]

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
% Carnot model and function m-files should use a name which gives a 
% hint to the model of function (avoid names like testfunction1.m).
% edited        99/09/07 by JPM

% Check of the correct size of the parameters
if size(UseTime,2) ~=1
   error('Error: Time of use of the system can be only one value for the whole system')
elseif size(IntRate,2) ~=1
   error('Error: The interest rate can be only one value for the whole system')
elseif size(IncFuel,2) ~=1
   error('Error: The expected annual increase of fuel costs can be only one value for the whole system')
elseif size(IncMat,2) ~=1
   error('Error: The expected annual increase of material costs can only be one value for the whole system')
elseif size(InvestCosts,2) ~= size(CompLifeTime,2)
   error('Error: Please check if the component life time and invest costs are defined for each component')
elseif size(InvestCosts,2) ~= size(ContOpCosts,2)
   error('Error: Please check if continuous operation costs and invest costs are defined for each component')
elseif size(InvestCosts,2) ~= size(RunOpCosts,2)
   error('Error: Please check if operation costs depending on the run time of the component and invest costs are defined for each component')
elseif size(InvestCosts,2) ~= size(FuelCosts,2)
   error('Error: Please check if fuel costs of the component and invest costs are defined for each component')
elseif size(InvestCosts,2) ~= size(RunTime,2)
   error('Error: Please check if the run time and invest costs are defined for each component')
elseif size(InvestCosts,2) ~= size(RunTimeDep,2)
   error('Error: Please check if the run time dependence and invest costs are defined for each component')
end

% Rows into columns for further cost calculation
CompLifeTime = CompLifeTime';
InvestCosts = InvestCosts';
ContOpCosts = ContOpCosts';
RunOpCosts = RunOpCosts';
Fuelcosts = FuelCosts';
RunTime = RunTime';
RunTimeDep = RunTimeDep';

% Calculation when which component has to be replaced in between the time of use.
% Calculation of the remaining values at the end of the time of use.
NewComp = zeros(0,UseTime);
for k=1:size(InvestCosts,1),
   if RunTimeDep(k) == 0    % For components with a lifetime that does not depend 
                                % on the use of the component.
       Years = CompLifeTime(k)*[1:floor(UseTime/CompLifeTime(k))];
       if isempty(Years) 
          NewComp(k,:) = 0; 
          Years = 0;
       else 
          NewComp(k,ceil(Years)) = InvestCosts(k); 
       end
       % Remaining value of component at the end of time of use
      RemValComp(k,:) = (1-(UseTime-max(Years))/CompLifeTime(k))*InvestCosts(k);
   else                         % For components with a lifetime that depends 
                                % on the use of the component.
         RunTime_y(k) = RunTime(k)/(3600*8760); % RunTime has to be converted here from [s] into [y]
      if RunTime_y(k)==0 
         RemValComp(k,:) = 0;
      else  
         Years = CompLifeTime(k)/RunTime_y(k)*[1:floor(UseTime/CompLifeTime(k)*RunTime_y(k))];
         if isempty(Years) 
            NewComp(k,:) = 0; 
            Years = 0;
         else 
            NewComp(k,ceil(Years)) = InvestCosts(k); 
         end
         % Remaining value of component at the end of use time of the system
         RemValComp(k,:) = (1-(UseTime-max(Years))/CompLifeTime(k)*RunTime_y(k))*InvestCosts(k);
      end
    end      
end

% Calculation of maintenance costs for each year
for k = 1:size(InvestCosts,1)
   PermCosts(k) = ContOpCosts(k) + RunTime(k)*RunOpCosts(k);
end

% Calculation of financial factors
% Factor of interest rate (beta):
q = 1 + IntRate;                                        % [Hau] (2.5)
if q ~= 1
   beta = (q^UseTime - 1)/(q^UseTime*(q-1));    % [Hau] (2.12)
else
   beta = UseTime;                                      % Elimination of "zero" in denominator
end   

% Sum up of all expenses for the different components
TotalInvest = sum(InvestCosts);
TotalPerm = sum(PermCosts);
TotalFuel = sum(FuelCosts);
TotalDisc = sum(NewComp,1);
TotalRemVal = sum(RemValComp);


% Factors of interest rates for permanent and discrete costs (beta1):
qq = q./ (1 + [IncFuel;IncMat]);                    % [Hau] (2.11)
pos = find(qq == 1); qq(pos) = NaN;                 % Find position qq == 1 ("zero" in denominator)
beta1 = qq/q .* (qq.^UseTime - 1) ./ (qq.^UseTime .* (qq-1));   % [Hau] (2.10)
beta1(pos) = UseTime./q;                            % Elimination of "zero" in denominator

% Total permanent costs (fuel, maintainance) accumulating throughout system lifetime:
TotalPermCosts = [TotalFuel;TotalPerm] .* beta1;

% Total discrete costs (new components) accumulating throughout system lifetime:
TotalDiscrCosts = TotalDisc(1:UseTime) .* q.^(-[1:UseTime]);   % [Hau] (2.5)

% Sum of total costs:
TotalCosts = sum(TotalPermCosts) + sum(TotalDiscrCosts) + TotalInvest - ...
   TotalRemVal * q^(-UseTime);

% Annual costs:
Annuity = TotalCosts/beta;   % [Hau] (2.13)
