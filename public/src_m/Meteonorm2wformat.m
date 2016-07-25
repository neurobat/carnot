function outmat = Meteonorm2wformat(infile,outfile,lat,long,long0,station,country,comment)
% Meteonorm2wformat converts weather data which is calculated by METEONORM,
% into the Carnot-Format. The function takes solar position from carlib 
% since Meteonorm puts solar altitude and azimuth angle to zero between 
% sunset and sunrise. 
%
% SYNTAX: outmat = 
%   Meteonorm2wformat(infile, outfile,  lat, long, long0, station, country, comment)
%
% altenative SYNTAX:   outmat = Meteonorm2wformat
%   opens dialog windows for the parameters
%
% Use the "user defined" weather data format in Meteonorm. For convenience
% the format file can be used in Meteonorm
% "Meteonorm_carnot_format.muf -> created with Meteonorm 6.1
% "Meteonorm_7_carnot_format.muf -> created with Meteonorm 7.0
%
% infile      : character string of the input file name, created by Meteonorm
%   The values of inmat have to be in following order:
%    1 - time [h]
%    2 - hs : solar altitude angle [°]
%    3 - gammas : solar azimuth angle [°]
%    4 - G_Bn : direct beam radiation on a normal plane [W/m²]
%    5 - G_Gh global horizontal radiation in W/m²
%    6 - G_Dh : diffuse radiation on a horizontal plane [W/m²]
%    7 - Ta : air temperature [°C]
%    8 - RH : humidity [%]
%    9 - N : cloud index [0..8]
%   10 - p : air pressure [hPa]
%   11 - FF : wind speed [m/s]
%   12 - DD : wind direction [°]
%
% outfile     : character string of the output file name
%               The outfile should follow the definition:
%                   CC_city.dat 
%               where
%               CC = 2-letter (Alpha 2) code of the country (ISO 3166-1)
%               city = name of the city, use english name if available
% lat         : [-90,90] north positive
% long        : [-180,180] west positive
% long0       : reference longitude (timezone), [-180,180] west positive
% station     : name of the station
% country     : name of the country
% comment     : free comment (e.g. Meteonorm version)
%
% The output matrix has the CARNOT form as described in "wformat.txt". As
% no collector position is defined, a horizontal plane is assumed.

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
% ***********************************************************************
% Meteonorm is a commercial sóftware of Meteotest Genossenschaft, Bern, Switzerland 
% ***********************************************************************

% version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
% author list:  hf -> Bernd Hafner
%               gf -> Gaelle Faure
%               tw -> Thomas Wenzel
%               rd -> Ralf Dott
% 
% version   author  changes                                     date
% 1.0.0     hf      created as meteoconv.m                      20th century
% 2.0.0     tw      call of metskym.m replaced by skytemperature.m 
%                   new file names has to be specified          27oct2000
% 4.1.0     hf      renamed to Meteonorm2wformat                04jan2011
%                   take solar angles from carlib
% 4.1.1     gf      modify in order to create new data files    15jun2011
%                   (direct irradiation on a normal surface)
% 4.1.2     rd      corrected cloud format %12.0f to %12.2f     10jun2011
%                   changed [~,~,zenith,azimuth,~] 
%                   to [aaa,bbb,zenith,azimuth,ccc] with clear aaa bbb ccc;
%                   to be compatible with Matlab2007b
% 5.1.0     hf      global horizontal radiation added           11apr2012
% 5.2.0     hf      filename from uigetfile if not specified    11dec2012
%                   4.1.2 compatibility with matlab 2007b as comment
% 5.2.1     hf      plot of zenith angle and radiation added    14mar2013
%                   comment for meteonorm version added
%                   changed input from matrix to filename 'infile'
%                   station name and comment added as input

if nargin == 0     % no parameter given
    [infile, pathname, filter] = ...
        uigetfile({'*.dat','Meteonorm output file'; ...
            '*.mat', 'MAT-files'; '*.*', 'All files'}, ...
            'Select input data file');
    if filter == 0  
        return
    end
    infile = [pathname, infile];
    outfile = input('Name for output weather data file : ', 's');
    station = input('Name of the station : ', 's');
    country = input('Name of the country : ', 's');
    comment = input('Comment (Meteonorm version ...) : ', 's');
    lat = input('Geographical latitude [-90,90] north positive : '); 
    long = input('Geographical longitude [-180,180] west positive : '); 
    long0 = input('Geographical longitude of the timezone [-180,180] west positive : '); 
elseif nargin ~= 8
  help Meteonorm2wformat
  error('Number of input arguments must be 1 or 6')
end

inmat = load (infile);
if size(inmat,1) < size(inmat,2)
    inmat = inmat';
end

outmat = zeros(size(inmat,1),19);
outmat(:,1) = inmat(:,1)*3600-1800;     % time: h -> s
outmat(:,2) = tvalue(outmat(:,1));      % tstring

% take solar postion from carlib since Meteonorm has the bad habit to put
% solar altitude and azimuth angle to 0 or 90 beween sunset and sunrise. 
% No sun position at night -> problems with interpolation of the sun 
% positon at sunrise and sunset.
[~,~,zenith,azimuth,~] = sunangles(outmat(:,1),lat,long,long0);
% start compatibility with Matlab2007b :
%[aaa,bbb,zenith,azimuth,ccc] = sunangles(outmat(:,1),lat,long,long0);
%clear aaa bbb ccc; 
% end compatibility with Matlab2007b

outmat(:,3) = zenith;                   % zenith from carlib calculation
outmat(:,4) = azimuth;                  % azimuth from carlib calculation
outmat(:,5) = inmat(:,4);               % I_dir_norm
outmat(:,6) = inmat(:,6); 				% I_dfu_hor
outmat(:,7) = inmat(:,7);				% Tamb
outmat(:,8) = skytemperature(inmat(:,7),inmat(:,8),inmat(:,9)/8); % tsky
outmat(:,9) = inmat(:,8);				% humiditiy
outmat(:,10) = -9999;               	% precipitation is not known
outmat(:,11) = inmat(:,9)/8;			% cloud index
outmat(:,12) = inmat(:,10)*100;		    % pressure hPa - Pa
outmat(:,13) = inmat(:,11);			    % wind speed
outmat(:,14) = inmat(:,12);			    % wind direction
outmat(:,15) = zenith;					% collector incidence is zentih angle
outmat(:,16) = -9999;					% teta rise is not known
outmat(:,17) = -9999;					% teta head is not known
outmat(:,18) = inmat(:,5)-inmat(:,6);   % Idir on surface : Iglb - Idfu
outmat(:,19) = inmat(:,6); 				% Idfu on surface

% plot sun angles to verify geographical position and time reference
figure
plot([zenith, 90-inmat(:,2)])
title('zenith angle')
legend('Carnot', 'Meteonorm')
figure
plot([azimuth, inmat(:,3)])
title('azimuth angle')
legend('Carnot', 'Meteonorm')
figure
plot([(90-zenith).*10, outmat(:,18)+outmat(:,19)])
title('compare sunposition to radiation')
legend('solar horizon angle * 10', 'global radiation')
disp(' ')
disp('Meteonorm2wformat: Please check sun position in the figures.')
disp('                   Results should be identical during daytime.')
disp('                   If not check longitude, latitude and time reference.')
disp(' ')

% copy first and last row to assure interpolation 
outmat = [outmat(1,:); outmat(:,:); outmat(length(outmat),:)];
outmat(1,1) = 0;                        % first row has time 0
outmat(length(outmat),1) = 8760*3600;   % last row is end of the year

outmat = outmat';
fout = fopen(outfile,'w');
fprintf(fout,'%% Format of weather data in CARNOT.\n');
fprintf(fout,'%%   station name:  %s   country: %s\n', station, country);
fprintf(fout,'%%   geographical positon: longitude: %f , latitude: %f\n', lat, long);
fprintf(fout,'%%   reference meridian for time (example: 0° = Greenwich Mean Time): %f\n', long0);
fprintf(fout,'%% Data converted from Meteonorm. %s \n', comment);
fprintf(fout,'%% Use the Carnot block "weather_from_file" to get the data in your model.\n');
fprintf(fout,'%%\n');
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
fprintf(fout,'%%   time        tvalue    zenith   azimuth   Ibn Idfuhor Tamb   Tsky   hum    prec  cloud   p      wspeed  wdir  incidence  tetal   tetat   Idirhor Idfuhor\n');
   
% write matrix row by row to define formats
%             time   tvalue  zenit  azimut  Ibn    Idfuh  Tamb   Tsky   hum    prec   cloud  press  wspeed wdir   incid  tetal  tetat  Idirh  Idfuh
fprintf(fout,'%8.0f  %12.0f  %8.2f  %8.2f  %4.0f  %4.0f  %5.1f  %5.1f  %5.1f  %5.0f  %5.3f  %6.0f  %6.2f  %5.1f  %7.1f  %7.1f  %7.1f  %4.0f  %4.0f\n', ...
       outmat);

status = fclose (fout);
if (status == 0)
    outmat = outmat';
else
    outmat = status;
end