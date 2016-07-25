% density_solid calculates the density [kg/m3] 
%
% Inputs:             
%               temperature [°C]                                                    
%               type of solid (ID see below)                                              
%                                                                      
% Syntax:       r = density(temperature, ID)
%                                                                          
% Description:  The density is calculated from values of VDI /1/
%               rho = rho0 + T*rho1
%
%  symbol      used for                                        unit
%  rho         density                                         kg/m^3
%  T           temperature                                     K
%  rho0        constant density                                kg/m^3
%  rho1        linear temperature dependant density            kg/m^3/K
%                                                                          
%  ID  Solid            REMARKS
%  1   wood             only up to 200°C
%  2   sand stone
%  3   concrete         
%                                                                          
% See also: density
% 
% Function Calls:
% function is used by: nn.m
% this function calls: cc.m
% 
% Literature: /1/  VDI Waermeatlas 1991

% all comments above appear with 'help density_solid' 
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
% Carnot model and function m-files should use a name which gives a 
% hint to the model of function (avoid names like testfunction1.m).
% 
% author list:     xn -> Xaver Noname
%
% version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
%
% Version   Author  Changes                                     Date
% 1.0.0     xn      created                                     35may1899
% 6.1.0     xn      results verified (see report in MyThesis)   35jun1899
%
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
