function c = solar_declination(t)
% solar_declination calculates the declination of the sun in degree.
%
% syntax:   solar_declination(time)
% Input:    time in seconds                                                 
%      (January 1st 0:00:00 = 0 s; December 31st 24:00:00 = 365*24*3600 s) 
%                             
% The function calls the "solar_declination" in the CARNOT Library
% Carlib where the calculation is effectuated. The function
% solar_declination may be used in m-files. The carlib function 
% solar_declination is also used by the "solar_declination"-block in CARNOT.
% The equation was taken from Duffie, Beckmann: Solar Engineering of
% Thermal Processes, 2006. Orginaly the equation was derived by Spencer
% (Spencer: Fourier Series Representation of the Position of the Sun, 
%  Search Vol.2(5), page 172 , 1971). The error is below 0.035°.
%                                                                          
% See also CARLIB, solar_extraterrestrial, sunangles                  

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
% author list:      hf -> Bernd Hafner
%                   tw -> Thomas Wenzel
%
% version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
%
% Version  Author  Changes                                     Date
% 2.1.0    tw      created                                     31mar2000
% 5.1.0    hf      calculation moved to carlib                 01jan2009
%
% Copyright (c) 2000 Solar-Institut Juelich, Germany
%
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

c = calcsolar (t, 0, 0, 0, 2);
end % of function