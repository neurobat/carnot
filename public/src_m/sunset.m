function erg = sunset(latitude, longitude, longitudenull, year, month, day)
% [time_sunrise, time_sunset] 
%       = sunset(lat, long, long0, year, month, day)
% SUNSET calculates the time of sunrise and sunset and the maximal sun 
% angle of the day.
% Inputs:   lat      : latitude  [ -90; 90], north positive
%           long     : longitude [-180;180], west positive
%           long0    : reference longitude (timezone)
%           year, month, day
% Outputs:  time_sunrise : time of sunrise in s
%           time_sunset  : time of sunrise in s

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
%
%  Version   Author           Changes                  Date
%  0.1       Thomas Wenzel    created                  20mar2000

% 
% formulas :  Deutscher Wetterdienst
%


%------------------------------------ program code ------------------------------------

if nargin<6
   help sunset
   return
end

%TageProMonat = [31  28  31  30  31  30  31  31  30  31  30  31]
if mod(year,4)==0
   Tagebisher  = [0 31  60  91 121 152 182 213 244 274 305 335 366];
else
   Tagebisher  = [0 31  59  90 120 151 181 212 243 273 304 334 365];
end

DEG2RAD =  0.01745329251994;
RAD2DEG =  57.29577951308232;
ndays = day+ Tagebisher(month);  % Tag + Tage in den Vormonaten
  
% declination of the sun */
xj = 0.9856*(ndays)-2.72;
xbogen = DEG2RAD*xj;
% arg2 = DEG2RAD*(xj - 77.51 + 1.92*sin(xbogen));
% arg3 = sin(arg2);
% delta = asin(0.3978*arg3);                      % declination angle */
delta = DEG2RAD*solar_declination(ndays*24*3600);
arg5 = DEG2RAD*(2.0*xj+24.99+3.83*sin(xbogen));
z   = 60.0*(-7.66*sin(xbogen)-9.87*sin(arg5));  % z is in seconds */
moz = (longitudenull-longitude)*240;            % 240 s = 1 h / 15°

lat  = DEG2RAD*latitude;
omega_s = RAD2DEG*acos(-tan(lat)*tan(delta));       % hour angle to sunrise/sunset
erg(1) = hourangle2time(+omega_s-(moz+z)/3600*15);  % sunset
erg(2) = hourangle2time(-omega_s-(moz+z)/3600*15);  % sunrise