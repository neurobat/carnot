function convert_weather(infilename,outfilename)
% convert_weather converts old weather Carnot-Format data file into the new
% Carnot-Format. The function assumes that the direct irradiation is on a
% horizontal surface (the data file is not yet modified by surfrad).
%
% SYNTAX: outmat = convert_weather(infilename,outfilename)
%
% The infilename is the name of the old file. 
% The format of the file have to be as the following format:
%
% col(file) description                                         units
%  1        time                                                s
%  2        timevalue (comment line) format YYYYMMDDHHMM        -
%           Y is the year, M the month, D the day, H the hour
%  3        zenith angle of sun (at time, not averaged)         degree
%           (continue at night to get time of sunrise by
%           linear interpolation)
%  4        azimuth angle of sun (0°=south, east negative)      degree
%           (at time, not average in timestep)
%  5        incidence angle on surface (0° = vertical)          degree
%  6        direct solar radiation on surface                   W/m^2
%  7        diffuse solar radiation on a horizontal surface     W/m^2
%  8        ambient temperature                                 degree centigrade
%  9        radiation temperature of sky                        degree centigrade
% 10        relative humidity                                   percent
% 11        precipitation                                       m/s
% 12        cloud index (0=no cloud, 1=covered sky)             -
% 13        station pressure                                    Pa
% 14        mean wind speed                                     m/s
% 15        wind direction (north=0° west=270°)                 degree
% 16        incidence angle in a vertical plane on the collecor degree
%           orientation of the plane is parallel to the risers,
%           referred as longitudinal plane in EN 12975
% 17        incidence angle in a vertical plane on the collecor degree
%           orientation of the plane is parallel to the headers
%           referred as transversal plane in EN 12975
%           (= -9999, if surface orientation is unknown)
%
% outfilename : character string of the output file name
% The output file has the CARNOT form as described in "wformat.txt".

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
% version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
% author list:  hf -> Bernd Hafner
%               gf -> Gaelle Faure
%               tw -> Thomas Wenzel
% 
% version   author  changes                                     date
% 1.0.0     gf      created                                     15jun11
% 


if nargin ~= 2
  help convert_weather
  return
end

inmat = load(infilename);

outmat = zeros(size(inmat,1),19);
outmat(:,1:4) = inmat(:,1:4);     % time - timevalue - zenith - azimuth
outmat(:,6:14) = inmat(:,7:15);			% Idfu - Tamb - tsky - humiditiy - precipitation - cloud index
                                        % pressure - wind speed - wind direction
outmat(:,15) = inmat(:,5);				% collector incidence
outmat(:,16:17) = inmat(:,16:17);		% teta rise - teta head
outmat(:,18) = -9999;                   % Idir on surface : not konwn 
outmat(:,19) = -9999;    				% Idfu on surface : not konwn 

% Calculation of the direct irradiation on a normal plane
Idir_hor = inmat(:,6);
zenith = inmat(:,3);
outmat(:,5) = max(0,Idir_hor./cosd(zenith));

output = outmat';
fout = fopen(outfilename,'w');

% copy of the beginning of the header
fin = fopen(infilename);
for i=1:14
     line = fgets(fin);
     fprintf(fout,'%s',line);
end

   fprintf(fout,'%%\n%%\n');
   fprintf(fout,'%% col   description                                       units\n');
   fprintf(fout,'%% 1     time                                                s\n');
   fprintf(fout,'%% 2     timevalue (comment line) format YYYYMMDDHHMM        -\n');
   fprintf(fout,'%%       Y is the year, M the month, D the day, H the hour\n');
   fprintf(fout,'%% 3     zenith angle of sun (at time, not averaged)         degree\n');
   fprintf(fout,'%%       (continue at night to get time of sunrise by\n');
   fprintf(fout,'%%       linear interpolation)\n');
   fprintf(fout,'%% 4     azimuth angle of sun (0°=south, east negative)      degree\n');
   fprintf(fout,'%%       (at time, not average in timestep)\n');
   fprintf(fout,'%% 5     direct solar radiation on a normal surface          W/m^2\n');             
   fprintf(fout,'%% 6     diffuse solar radiation on surface                  W/m^2\n');             
   fprintf(fout,'%% 7     ambient temperature                                 degree centigrade\n'); 
   fprintf(fout,'%% 8     radiation temperature of sky                        degree centigrade\n'); 
   fprintf(fout,'%% 9     relative humidity                                   percent\n');           
   fprintf(fout,'%% 10    precipitation                                       m/s\n');               
   fprintf(fout,'%% 11    cloud index (0=no cloud, 1=covered sky)             -\n');                 
   fprintf(fout,'%% 12    station pressure                                    Pa\n');                
   fprintf(fout,'%% 13    mean wind speed                                     m/s\n');               
   fprintf(fout,'%% 14    wind direction (north=0° west=270°)                 degree\n');            
   fprintf(fout,'%% 15    incidence angle on surface (0° = vertical)          degree\n');          
   fprintf(fout,'%%       (= -9999, if surface orientation is unknown)\n');                        
   fprintf(fout,'%% 16    incidence angle in plane of vertical and main       degree\n');            
   fprintf(fout,'%%       surface axis (the main axis is parallel to heat\n');                       
   fprintf(fout,'%%       collecting pipes in a collector, it is pointing\n');                       
   fprintf(fout,'%%       to the center of the earth)\n');                                           
   fprintf(fout,'%% 17    incidence angle in plane of vertical and second     degree\n');            
   fprintf(fout,'%%       surface axis (the second axis is in the surface\n');                       
   fprintf(fout,'%%       and a vertical on the heat collecting pipes in \n');                   
   fprintf(fout,'%%       a collector, it is pointing to the horizon)\n%%\n');                   
   fprintf(fout,'%% 18    direct solar radiation on surface                   W/m^2\n');   
   fprintf(fout,'%% 19    diffuse solar radiation on surface                  W/m^2\n');   
   fprintf(fout,'%% UNKNOWN: set -9999 for unknown values\n%%\n');
   fprintf(fout,'%% time[s]   tvalue    zenit[°]   azimuth[°]  Idir[W/m²]  Idfu[W/m²] Tamb[°C]  Tsky[°C]  hum  prec[m/s]   cloud[0..1]    p[Pa]   speed[m/s]  dir[°]   incidence[°]   tetarise[°]   tetahead[°]  IdirSurf[W/m²]   IdfuSurf[W/m²]\n');

% write try-matrix row by row to define formats
fprintf(fout,'%8.0f  %12.0f  %10.2f  %7.2f  %13.1f  %11.1f  %8.1f  %8.1f  %5.0f  %10.0f  %12.2f  %6.0f  %10.2f  %10.1f  %10.0f  %12.0f  %12.0f %13.1f  %11.1f\n',output);

fclose(fin);
fclose(fout);