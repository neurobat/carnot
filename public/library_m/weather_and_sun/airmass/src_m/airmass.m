function m = airmass(time, latitude, longitude, longitude0)
% This function calulates the airmass at a specific time and for a specific
% location.
%
% m = airmass(time, latitude, longitude, longitude0)
%
% 1. time          : second in the year (january, 1st, 0:00 = 0 s)
% 2. latitude      :   [-90,90],north positive
% 3. longitude     :   [-180,180],west positive
% 4. longitude0    :   reference longitude (timezone)
% 
% Literature: Duffie, Beckmann: Solar Engineering of Thermal Processes, 2006


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
% AUTHORS:        Bernd Hafner (hf)
%                 
% HISTORY:     	  
% hf    created                                                 21jun2009
%
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

if nargin ~= 4
   help airmass
   return
end

% start calculation
[~, alt, ~, zen, ~] = sunangles(time,latitude, longitude, longitude0);

altsin = sin(alt*pi/180);    % sine of altitude of the sun in radian

if 0 < zen < 70 
   m = 1./altsin;
else
   m = ((1229+(614.*altsin).^2).^(0.5)) - 614.*altsin;
end
