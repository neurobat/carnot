function p = prandtl(t, p, ft, fm)
% prandtl(temperature, pressure, fluid_ID, fluid_mix)
% calculates the Prandtl number [-] according to the inputs 
% (scalar or vector): 
%    * temperature [�C]
%    * pressure [Pa]  
%    * fluid_ID (link below)
%    * fluid_mix 
%                                                                              
% Pr = cp*eta/cond                                                             
% with:
%     cp - heat capacity                                                           
%     eta - dynamic viscosity                                                              
%     cond - thermal conductivity                                                     
%                                                                          
% See also Carnot_Fluid_Types, CARLIB, 
%   prandtl, grashof, reynolds,
%   density, kinematic_viscosity

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
% 1.0.0     hf      created                                     1999
% 6.1.0     hf      updated help text and error handling        03oct2014

if (nargin ~= 4)
  help prandtl
  error('4 input arguments required: prandtl(t, p, ID, mix)')
end

p = fluidprop (t, p, ft, fm, 7);