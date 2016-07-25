% Checks the parameters of the radiator model from EN442 adapted to the current model.
% ----- Might be used in future for a callback function: ------------------
%   function [pnom,dTnom,expo] = Carnot_RadiatorBasic_Callbacks(pnomEN,dTnomEN,expoEN)
%   Inputs:       pnomEN, dTnomEN, expoEN
%   Syntax:       [pnom,dtnom,expo] = Carnot_RadiatorBasic_Callbacks(pnomEN,dTnomEN,expoEN)
% -------------------------------------------------------------------------
% Description of the model:  
% qdot = pnom * ((Tm-Troom)/(dtnom)^expo
% nominal temperature difference = 50K with flowline 75°C, return 65°C and room 20°C
% EN 442: Tm = 0.5*(Tin+Tout)
% Here:   Tm = Tout
% 
%  symbol      used for                                     unit
%  pnom        nominal heating power                        W
%  Tm          mean temperature                             °C
%  dTnom       nominal temperature difference               K
%  expo        exponent of the radiator                     -
%                                                                          
% See also: --
% 
% Function Calls:
% function is used by: Simulink/Carnot block "Radiator_basic"
% this function calls: --
% 
% Literature: EN 442

% all comments above appear with 'help Carnot_RadiatorBasic_Callbacks' 
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
% 6.1.0     hf      created                                     18dec2014
%
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

% parameters for test
Troom = 20;
Ts = 75;

% EN 442 equation
expoEN = 1.3;
pnomEN = 1000;
dTnomEN = 50;
mdotnom = pnomEN/4182/10;   % Ts is 75°C, Tr is 65°C

Tm = (30:5:80)';
dTEN = Tm-Troom;
QdotEN = pnomEN .* (dTEN/dTnomEN).^expoEN;
TsTr = QdotEN/4182/mdotnom;
Tr = Tm - TsTr/2;  % TsTr=Ts-Tr -> Ts=TsTr+Tr in Tm=(Ts+Tr)/2 -> 2*Tm=2*Tr+TsTr

dTnom = dTnomEN-5;
dT = Tr-Troom;
pnom = pnomEN;
expo = expoEN;
Qdot = pnom .* (dT/dTnom).^expo;

a = polyfit(Tr,QdotEN,2);
QdotFit = polyval(a,Tr);

% plot test sequence
plot(Tr, [QdotEN, Qdot, QdotFit])
legend('EN442','current','Fit')

