function re = reynolds(t, v, p, ft, fm, d)
% reynolds(temperature, velocity, pressure, fluid_type, fluid_mix, dimension)
% calculates the reynolds number [-] according to the inputs 
% (scalar or vector): 
%    * temperature [�C]
%    * velocity
%    * pressure [Pa]  
%    * fluid_ID (link below)
%    * fluid_mix 
%    * dimension [m]
% Re = v .* d ./ kinematic_viscosity
%
% The function calls the function "kinematic_viscosity" in the CARNOT library Carlib.
% The Carlib function is also used by the "Reynolds"-block in CARNOT library.
%                                                                          
% See also Carnot_Fluid_Types, CARLIB, 
%   prandtl, grashof,
%   kinematic_viscosity

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

if (nargin ~= 6)
  help reynolds
  error('6 input arguments required: reynolds(t,v,p,ID,mix,d)')
end

re = v .* d ./ fluidprop (t, p, ft, fm, 4);