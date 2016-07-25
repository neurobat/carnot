function outmat = try2wformat(infile,outfile,lat,long,long0,station,country,comment)
% try2wformat converts weather data which is given by the German DWD
% into the Carnot-Format. The solar position is calculated by carlib
% functions since TRY do not have this information.
%
% SYNTAX: outmat = ...
%   try2wformat(infile, outfile,  lat, long, long0, station, country, comment)
%
% altenative SYNTAX:   outmat = try2wformat
%   opens dialog windows for the parameters
%
% infile      : character string of the input file name, created by Meteonorm
%  The values of inmat have to be in following order:
%  1 RG TRY-Region                                                           {1..15}
%  2 IS Standortinformation                                                  {1,2}
%  3 MM Monat                                                                {1..12}
%  4 DD Tag                                                                  {1..28,30,31}
%  5 HH Stunde (MEZ)                                                         {1..24}
%  6 N  Bedeckungsgrad                                              [Achtel] {0..8;9}
%  7 WR Windrichtung in 10 m Höhe über Grund                        [°]      {0;10..360;999}
%  8 WG Windgeschwindigkeit in 10 m Höhe über Grund                 [m/s]
%  9 t  Lufttemperatur in 2m Höhe über Grund                        [°C]
% 10 p  Luftdruck in Stationshöhe                                   [hPa]
% 11 x  Wasserdampfgehalt, Mischungsverhältnis                      [g/kg]
% 12 RF Relative Feuchte in 2 m Höhe über Grund                     [%]      {1..100} 
% 13 W  Wetterereignis der aktuellen Stunde                                  {0..99}  
% 14 B  Direkte Sonnenbestrahlungsstärke (horiz. Ebene)             [W/m²]   abwärts gerichtet: positiv 
% 15 D  Difuse Sonnenbetrahlungsstärke (horiz. Ebene)               [W/m²]   abwärts gerichtet: positiv
% 16 IK Information, ob B und oder D Messwert/Rechenwert                     {1;2;3;4;9}
% 17 A  Bestrahlungsstärke d. atm. Wärmestrahlung (horiz. Ebene)    [W/m²]   abwärts gerichtet: positiv
% 18 E  Bestrahlungsstärke d. terr. Wärmestrahlung                  [W/m²]   aufwärts gerichtet: negativ
% 19 IL Qualitätsbit für die langwelligen Strahlungsgrößen                   {1;2;3;4;5;6;7;8;9}
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
% comment     : free comment
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
% version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
% author list:  hf -> Bernd Hafner
% 
% version   author  changes                                     date
% 6.1.0     hf      created from Meteonorm2wformat              29nov2013
% 6.1.1     hf      added outfile to title of figures           05jan2015

if nargin == 0     % no parameter given
    [infile, pathname, filter] = ...
        uigetfile({'*.dat','TRY data file'; ...
            '*.mat', 'MAT-files'; '*.*', 'All files'}, ...
            'Select input data file');
    if filter == 0  
        return
    end
    infile = fullfile(pathname,infile);
    outfile = input('Name for output weather data file : ', 's');
    station = input('Name of the station : ', 's');
    country = input('Name of the country : ', 's');
    comment = input('Comment : ', 's');
    lat = input('Geographical latitude [-90,90] north positive : '); 
    long = input('Geographical longitude [-180,180] west positive : '); 
    long0 = input('Geographical longitude of the timezone [-180,180] west positive : '); 
elseif nargin ~= 8
  help try2wformat
  error('Number of input arguments must be 0 or 8')
end

inmat = txt2mat(infile);
if size(inmat,1) < size(inmat,2)
    inmat = inmat';
end

outmat = zeros(size(inmat,1),19);
outmat(:,1) = 3600:3600:(3600*8760);    % time in s
outmat(:,2) = tvalue(outmat(:,1));      % tstring

% solar postion from carlib since TRY have no sun information
[~,~,zenith,azimuth,~] = sunangles(outmat(:,1),lat,long,long0);
fb = cos(pi/180*zenith);                % factor for normal beam radiation is cos
fb = max(fb,0.001);                     % limit to 0.001

outmat(:,3) = zenith;                   % zenith from carlib calculation
outmat(:,4) = azimuth;                  % azimuth from carlib calculation
outmat(:,5) = min(1350,inmat(:,14)./fb);% I_dir_norm
outmat(:,6) = inmat(:,15); 				% I_dfu_hor
outmat(:,7) = inmat(:,9);				% Tamb
outmat(:,8) = skytemperature(inmat(:,9),inmat(:,12),inmat(:,6)/8); % tsky
outmat(:,9) = inmat(:,12);				% humiditiy
outmat(:,10) = -9999;               	% precipitation is not known
outmat(:,11) = inmat(:,6)/8;			% cloud index
outmat(:,12) = inmat(:,10)*100;		    % pressure hPa - Pa
outmat(:,13) = inmat(:,8);			    % wind speed
outmat(:,14) = inmat(:,7);			    % wind direction
outmat(:,15) = zenith;					% collector incidence is zenith angle
outmat(:,16) = -9999;					% teta rise is not known
outmat(:,17) = -9999;					% teta head is not known
outmat(:,18) = inmat(:,14);             % Idir on horizontal surface 
outmat(:,19) = inmat(:,15);             % Idfu on surface

% plot sun angles to verify geographical position and time reference
figure
plot([(90-zenith).*10, outmat(:,18)+outmat(:,19)])
s = strrep(outfile,'_','');
title(['sunposition and global radiation ' s])
legend('solar horizon angle * 10', 'global radiation')
figure
plot([(90-zenith).*10, outmat(:,5)])
title(['sunposition and direct beam radiation ' s])
legend('solar horizon angle * 10', 'beam radiation')
disp(' ')
disp('try2wformat: Please check sun position and solar radiation in the figure.')
disp('             Solar height and radiation should be 0 an the same moment at sunrise and sunset.')
disp('             If not check longitude, latitude and time reference.')
disp(' ')

% copy first row to assure interpolation 
outmat = [outmat(1,:); outmat(:,:)];
outmat(1,1) = 0;                        % first row has time 0
outmat(length(outmat),1) = 8760*3600;   % last row is end of the year

outmat = outmat';
fout = fopen(outfile,'w');
fprintf(fout,'%% Format of weather data in CARNOT.\n');
fprintf(fout,'%%   station name:  %s   country: %s\n', station, country);
fprintf(fout,'%%   geographical positon: longitude: %f , latitude: %f\n', lat, long);
fprintf(fout,'%%   reference meridian for time (example: 0° = Greenwich Mean Time): %f\n', long0);
fprintf(fout,'%% Data converted from Test Reference Year. %s \n', comment);
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