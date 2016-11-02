function erg = angles2time(latitude,longitude,longitude0,name1,angle1,name2,angle2)
% This function finds the time to two specified angles.
% Angles can be     - declination and zenith 
%                   - azimuth and zentih
%                   - declination and azimuth
%
% angles2time(latitude,longitude,longitude0,name1,angle1,name2,angle2)
%
% latitude      : [-90;90], north positive
% longitude     : [-180;180], west positive
% longitude0    : reference longitude (timezone)
% name1, name2  : letter specifiying angle
%                 'd' = declination
%                 'z' = zenith
%                 'a' = azimuth
%                 's' = altitude of sun
% angle1, angle2: values of specified angles

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
%
% author list:      tw -> Thomas Wenzel
%                   hf -> Bernd Hafner
% version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
%
% Version   Author  Changes                                     Date
% 1.1.0     tw      created                                     07apr2000
% 3.1.0     hf      comment changed, warnings removed           01jan2008
% 6.1.0     hf      call of find_declination_time corrected     27nov2014
%                   call is now find_declination_time_alt
%

if nargin ~= 7 
   help angles2time
   error('angles2time needs 7 input arguments')
end


[declination altitude zenith azimuth helptext] = initialization(name1,angle1,name2,angle2);
if helptext==1
   help angles2time
   return
end

%
%  declination and zenith given
%
if declination>-9999 && zenith>-9999
    t = find_declination_time_alt(1,declination,latitude,longitude,longitude0); % find time of declination in first half of year
%   t = find_declination_time(declination);
  t = floor(t/86400.)*86400;                                              % find beginning of that day
  t1 = find_zenith_time(t,zenith,latitude,longitude,longitude0);          % find forenoon time of zenith
  t2 = mirror_time_at_noon(t1,longitude,longitude0);                      % find afternoon time of zenith
  
  t = find_declination_time_alt(2,declination,latitude,longitude,longitude0); % find time of declination in second half of year
  t = floor(t/86400.)*86400;                                              % find beginning of that day
%   t = find_declination_time(declination);
  t3 = find_zenith_time(t,zenith,latitude,longitude,longitude0);          % find forenoon time of zenith
  t4 = mirror_time_at_noon(t3,longitude,longitude0);                      % find afternoon time of zenith
  
  nerg = 4;
  
%
% declination and azimuth given
%
elseif declination>-9999 && azimuth>-9999

%   t = find_declination_time(1,declination,latitude,longitude,longitude0); % find time of declination in first half of year
  t = find_declination_time_alt(1,declination,latitude,longitude,longitude0); % find time of declination in first half of year
  t = floor(t/86400.)*86400;                                              % find beginning of that day
  t1 = find_azimuth_time(t,azimuth,latitude,longitude,longitude0);        % find time of azimuth
  
%   t = find_declination_time(2,declination,latitude,longitude,longitude0); % find time of declination in second half of year
  t = find_declination_time_alt(2,declination,latitude,longitude,longitude0); % find time of declination in second half of year
  t = floor(t/86400.)*86400;                                              % find beginning of that day
  t2 = find_azimuth_time(t,azimuth,latitude,longitude,longitude0);        % find time of azimuth
  
  nerg = 2;
  
%
% zenith and azimuth given
%
elseif zenith>-9999 && azimuth>-9999
   tday=find_first_zenith_day(1,zenith,latitude,longitude,longitude0);        % find first possible day in first half of year for zenith
   t1 = find_zen_azi_time(tday,zenith,azimuth,latitude,longitude,longitude0); % find day+time with zenith and azimuth hit in first half of year
   tday=find_first_zenith_day(2,zenith,latitude,longitude,longitude0);        % find second possible day in first half of year for zenith
   t2 = find_zen_azi_time(tday,zenith,azimuth,latitude,longitude,longitude0); % find day+time with zenith and azimuth hit in second half of year
      
   nerg = 2;
end

%
% Output
%
  
  sec2date(t1)
%   [decl altitude zen azimuth hourangle] = sunangles(t1,latitude,longitude,longitude0);
%   disp([decl altitude zen azimuth hourangle])
  erg(1) = t1;
  
  sec2date(t2)
%   [decl altitude zen azimuth hourangle] = sunangles(t2,latitude,longitude,longitude0);
%   disp([decl altitude zen azimuth hourangle])
  erg(2) = t2;
  
  if nerg>=3
    sec2date(t3)
%     [decl altitude zen azimuth hourangle] = sunangles(t3,latitude,longitude,longitude0);
%     disp([decl altitude zen azimuth hourangle])
    erg(3) = t3;
  end
  if nerg>=4
    sec2date(t4)
%     [decl altitude zen azimuth hourangle] = sunangles(t4,latitude,longitude,longitude0);
%     disp([decl altitude zen azimuth hourangle])
    erg(4) = t4;
  end  
end % of function  
  
  
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  intialization
%
%  This functions reads the angles names and then sets the angle values
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [declination,altitude,zenith,azimuth,helptext] = initialization(name1,angle1,name2,angle2)

declination = -9999;
altitude    = -9999;
zenith      = -9999;
azimuth     = -9999;
helptext    = -9999;

if strcmp(name1,'d')==1
   declination = angle1;
elseif strcmp(name1,'z')==1
   zenith = angle1;
elseif strcmp(name1,'a')==1
   azimuth = angle1;
elseif strcmp(name1,'s')==1
   altitude = angle1;
   zenith = 90-altitude;
else
   helptext = 1;
end

if strcmp(name2,'d')==1
   declination = angle2;
elseif strcmp(name2,'z')==1
   zenith = angle2;
elseif strcmp(name2,'a')==1
   azimuth = angle2;
elseif strcmp(name2,'s')==1
   altitude = angle2;
   zenith = 90-altitude;
else
   helptext = 1;
end

if ~((declination>-9999 && zenith>-9999) || ...
     (declination>-9999 && azimuth>-9999) || ...
     (azimuth>-9999 && zenith>-9999) )
   helptext = 1;
end
end % of function  



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% find_declination_time
%
% This functions looks for the time in a year, when a specified declination
% is reached.
% The function is looking for either in the first or the second half of the year.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function t = find_declination_time(declination)
%    t = asin(declination/23.45)*180/pi*365/360-284;
%    while t<0
%       t = t+365;
%    end
%    t = t*86400;
%    sec2date(t)
%    t = floor(t/86400.)*86400;                                              % find beginning of that day
% end % of function  
  
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% find_declination_time
%
% This functions looks for the time in a year, when a specified declination
% is reached.
% The function is looking for either in the first or the second half of the year.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
function t = find_declination_time_alt(half,declination,latitude,longitude,longitude0)  

  if half==1                   % first half of year
     ta = -11*86400; 
     tb = 15638400;
  else                         % second half of year
     tb = 365*24*3600;
     ta = 15638400;
  end
  
  while (tb-ta>60)
     tm = (tb+ta)/2;
     [decl altitude zen azimuth hourangle] = sunangles(tm,latitude,longitude,longitude0);
     
     if (decl<declination && half==1) || (decl>declination && half==2)
       ta = tm;
     else
       tb = tm;
     end
  end
  t = tm;
   while t<0
      t = t+365*86400;
   end
end % of function  
  
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% find_zenith_time
%
% This function looks for the time of a specified day, when the zenith angles
% reaches a specified value. 
% The function is looking for only at forenoon.
% The day has to be specified as the time in seconds at 0:00 in the night.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function tz = find_zenith_time(t,zenith,latitude,longitude,longitude0)  
  ta = t;
  tb = ta+14*3600; % ???
  i=0;
  while (tb-ta>60)
     tm = (tb+ta)/2;
     [decl altitude zen azimuth hourangle] = sunangles(tm,latitude,longitude,longitude0);
%     [ta tm tb zen zenith]
     i=i+1;
     if zen>zenith
        ta = tm;
     else
       tb = tm;
     end
  end
  tz = tm;
end % of function  
  
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% find_azimuth_time
%
% This function looks for the time of a specified day, when the azimuth angles
% reaches a specified value. 
% The day has to be specified as the time in seconds at 0:00 in the night.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tz = find_azimuth_time(t,azimuth,latitude,longitude,longitude0)  
  ta = t;
  tb = ta+24*3600; 
  while (tb-ta>60)
     tm = (tb+ta)/2;
     [decl altitude zen azi hourangle] = sunangles(tm,latitude,longitude,longitude0);
     if (azi<azimuth && latitude>=0) || (azi>azimuth && latitude<0) 
        ta = tm;
     else
       tb = tm;
     end
  end
  tz = tm;
end % of function  
  
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% mirror_time_at_noon
%
% This function looks for a time after noon, which has the opposite time distance 
% to the solar noon than a specified forenoon time.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function t2=mirror_time_at_noon(t,longitude,longitude0)
  ts = legaltime2solartime(t,longitude0,longitude);     % calculate solar time of t1 : ts
  ts = sec2date(ts);
  delta_t = 43200-(ts(3)*3600+ts(4)*60+ts(5)); % calculated time distance to 12:00
  t2 = t+delta_t*2;                            % add time distance twice to t1 => t2
end % of function  
  
  
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% find_first_zenith_day
%
% This function looks for the first day in the year, when the zenith angles
% reaches a specified value.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tday=find_first_zenith_day(half,zenith,latitude,longitude,longitude0)
   
  if half==1                   % first half of year
     ta = 1; 
     tb = 15638400;
  else                         % second half of year
     ta = 15638400;
     tb = 365*24*3600;
  end
 
  while tb-ta>86400
      tm = floor(((ta+tb)/2)/86400.)*86400;
      t = find_zenith_time(tm,zenith,latitude,longitude,longitude0);
      [decl altitude zen azi hourangle] = sunangles(t,latitude,longitude,longitude0);
      if zen>zenith+1
         ta = tm;
      else
         tb = tm;
      end
   end
      
   tday = floor(tm/86400.)*86400;   % return the found day at 0:00 in the night
end % of function  
  
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% find_zen_azi_time
%
% This function looks for the day, when the zenith and azimuth reaches their
% specified values at the same time.
% The seach starts at a day, which has to be specified in seconds at 0:00 in
% the night.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function   tz = find_zen_azi_time(tday,zenith,azimuth,latitude,longitude,longitude0)

  tz = find_zenith_time(tday,zenith,latitude,longitude,longitude0);
  ta = find_azimuth_time(tday,azimuth,latitude,longitude,longitude0);
      
  while abs(tz-ta)>60
     tday = tday+86400;
     tz = find_zenith_time(tday,zenith,latitude,longitude,longitude0);
     ta = find_azimuth_time(tday,azimuth,latitude,longitude,longitude0);
  end   
end % of function 