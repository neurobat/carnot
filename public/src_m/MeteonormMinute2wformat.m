function outmat = MeteonormMinute2wformat(infile,outfile,lat,long,long0,station,country,comment,infile2)
% MeteonormMinute2wformat converts weather data in 1 minutes time 
% resolution which is calculated by METEONORM into the Carnot-Format. 
% The function takes solar position from carlib since Meteonorm values show 
% some strange movements (returns) of the sun.
%
% SYNTAX: 
%   outmat = 
%   MeteonormMinute2wformat(infile,outfile,lat,long,long0,station,country,comment,infile2)
%
% altenative SYNTAX:   outmat = MeteonormMinute2wformat(0)
%   opens dialog windows for the parameters
%   inmat, outfile, lat, long, long0, wdata
% 
% infile      : character string of the input file name, created by Meteonorm
%   The values of inmat have to be in following order:
%  1 - month
%  2 - day of month
%  3 - day of year
%  4 - hour
%  5 - minute
%  6 - G_Gh global horizontal radiation in W/m²
%  7 - hs solar altitude angle in degree
%  8 - G_Gex extraterrestrial global horizontal solar radiation in W/m²
%  9 - G_Gh_hr hourly average of global horizontal radiation in W/m²
% 10 - G_Dh diffuse horizontal radiation in W/m²
% 11 - G_Gk global inclined radiation in W/m²
% 12 - G_Dk diffuse inclined radiation in W/m²
% 13 - G_Bn direct normal radiation in W/m²
% 14 - Ta ambient temperature in degree C
% 15 - FF wind speed in m/s
% 
% infile2 : optional CARNOT weather data file for additional informations
%           (Meteonorm minute data has no humidity, 
%
% outfile : character string of the output file name
%               The outfile should follow the definition:
%                   CC_city.dat 
%               where
%               CC = 2-letter (Alpha 2) code of the country (ISO 3166-1)
%               city = name of the city, use english name if available
% lat         : [-90,90],north positive
% long        : [-180,180],west positive
% long0       : reference longitude (timezone)
% [wdata]     : OPTIONAL: matrix with weather data of the same location 
%               in standard Carnot format with data which is not given by
%               the Meteonorm minute output files (relative humitiy, 
%               cloud index, air pressure and wind direction)
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
% history
% version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
% author list:  hf -> Bernd Hafner
%               gf -> Gaelle Faure
% 
% version   author  changes                                     date
% 4.1.0     hf      created, based on meteoconv.m               03jan2011
% 4.1.1     gf      modify in order to create new data files    15jun2011
%                   (direct irradiation on a normal surface)
% 4.1.2     gf      debug : move calcul for humidity in the     26sep2011
%                   "if moredata" loop to have a really
%                   optionnal input 'wdata'
% 4.1.3     gf      debug : correction of the column numbers    28sep2011
% 5.1.0     hf      corrected help                              11apr2012
% 5.2.0     hf      filename from uigetfile if not specified    11dec2012
% 5.2.1     hf      plot of zenith angle and radiation added    14mar2013
%                   changed input from matrix to filename 'infile'
%                   station name and comment added as input

if nargin == 0                      % no parameter given
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
    
    [infile2, pathname, filter] = ...
        uigetfile({'*.dat','Carnot weather file'; ...
            '*.*','All files'}, ...
            'Select Carnot weather data file (Cancel for no file)');
    infile2 = [pathname, infile2];
    
    if filter == 0  
        moredata = false;
    else
        moredata = true;
    end
elseif nargin == 8
    moredata = false;
elseif nargin == 9
    moredata = true;
else
    help MeteonormMinute2wformat
    error('Number of input arguments must be 0 ')
end

% load data file
inmat = load (infile);
if size(inmat,1) < size(inmat,2)    % sometimes weather comes in rows, sometimes in colums
    inmat = inmat';                 % we only use colums
end

if moredata                         % if additional data is given
    wdata = load (infile2);         % load also this file
end

outmat = zeros(size(inmat,1),19);
outmat(:,1) = ((inmat(:,3)-1)*24 + inmat(:,4))*3600 + ...
                inmat(:,5)*60 - 30;     % time: h -> s

% Take solar postion from carlib since Meteonorm minute values show some
% strange moevements (returns) of the sun.
[~,~,zenith,azimuth,~] = sunangles(outmat(:,1),lat,long,long0);

outmat(:,2) = tvalue(outmat(:,1));      % string with time comment
outmat(:,3) = zenith;                   % zenith
outmat(:,4) = azimuth;       			% azimuth
outmat(:,5) = inmat(:,13);              % I beam normal
outmat(:,6) = inmat(:,10); 				% Idfu
outmat(:,7) = inmat(:,14);				% Tamb in °C
outmat(:,8) = inmat(:,14)-6;            % tsky  in °C
outmat(:,9) = -9999;                    % humiditiy
outmat(:,10) = -9999;               	% precipitation is not known
outmat(:,11) = -9999;	        		% cloud index is not known
outmat(:,12) = 101300;      		    % pressure in Pa
outmat(:,13) = inmat(:,15);			    % wind speed
outmat(:,14) = -9999;	        	    % wind direction is not known
outmat(:,15) = zenith;					% collector incidence is zenith angle
outmat(:,16) = -9999;					% teta rise is not known
outmat(:,17) = -9999;					% teta head is not known
outmat(:,18) = inmat(:,6)-inmat(:,10);  % Idir on horizontal = global - diffuse
outmat(:,19) = inmat(:,10);    			% Idfu on horizontal

if moredata
    if size(wdata,2) < 18    % old data format
        outmat(:,9)  = interp1(wdata(:,1),wdata(:,10),outmat(:,1));             % humiditiy
        outmat(:,11) = interp1(wdata(:,1),wdata(:,12),outmat(:,1));             % cloud index
        outmat(:,8)  = skytemperature(outmat(:,8),outmat(:,10),outmat(:,12));   % sky temperature
        outmat(:,12) = interp1(wdata(:,1),wdata(:,13),outmat(:,1));             % air pressure
        outmat(:,14) = interp1(wdata(:,1),wdata(:,15),outmat(:,1));             % wind direction
    else
        outmat(:,9)  = interp1(wdata(:,1),wdata(:,9),outmat(:,1));              % humiditiy
        outmat(:,11) = interp1(wdata(:,1),wdata(:,11),outmat(:,1));             % cloud index
        outmat(:,8)  = skytemperature(outmat(:,7),outmat(:,9),outmat(:,11));    % sky temperature
        outmat(:,12) = interp1(wdata(:,1),wdata(:,12),outmat(:,1));             % air pressure
        outmat(:,14) = interp1(wdata(:,1),wdata(:,14),outmat(:,1));             % wind direction
    end
end

% plot sun angles to verify geographical position and time reference
plot([zenith, 90-inmat(:,7)])
title('zenith angle')
legend('Carnot', 'Meteonorm')
figure
plot([(90-zenith).*10, outmat(:,18)+outmat(:,19)])
title('compare sunposition to radiation')
legend('solar horizon angle * 10', 'global radiation')
disp(' ')
disp('MeteonormMinute2wformat: Please check sun position in the figures.')
disp('               Results should be identical during daytime.')
disp('               If not check longitude, latitude and time reference.')
disp(' ')

%duplicate first and last line
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
   