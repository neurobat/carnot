function r = evaporation_enthalpy(t, p, ft, fm)
% EVAPORATION_ENTHALPY calculates the evaporation enthalpy [J/kg] according to the inputs:             
%                                                                          
%    * temperature [°C]                                                    
%    * pressure [Pa]          (dummy argument)
%    * fluid type (see below)                                              
%    * fluid_mix [0..1]                                         
%                                                                          
% syntax:
%
% evaporation_enthalpy(temperature, pressure, fluid_ID, fluid_mix)
%                                                                          
% The block calls the function "evaporation_enthalpy" in the CARNOT library Carlib where
% the calculation is effectuated. The function evaporation_enthalpy may be used in m-files.
% The carlib function evaporation_enthalpy is also used by the "evaporation_enthalpy"-block in CARNOT.
%                                                                          
% Definition of the fluid types                                            
%  fluid_ID fluid           remarks                                 
%  1        water           temperature from 0°C to 374.15
%  2        air             FUNCTION IS NOT AVAILABLE
%  3        cotton oil      FUNCTION IS NOT AVAILABLE
%  4        silicone oil    FUNCTION IS NOT AVAILABLE
%  5        water-glycol    FUNCTION IS NOT AVAILABLE
%  6        Tyfocor LS      FUNCTION IS NOT AVAILABLE
%                                                                          
%                                                                          
% See also MATERIALS, CARLIB.      

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

if (nargin ~= 4)
  help evaporation_enthalpy
  return
end

r = fluidprop (t, p, ft, fm, 9);
