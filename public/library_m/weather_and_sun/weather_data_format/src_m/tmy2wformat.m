function output = tmy2wformat(filename, outfilename)
% TMY22wformat converts weather data which are stored in TMY2 format 
% (.tm2 files), into the Carnot-Format. 
% for more information on the TMY2 format, see:
%       http://rredc.nrel.gov/solar/pubs/tmy2/tmy2_index.html
%
% The function takes solar position from carlib since the TMY2 files have 
% no solar position.
% There are always 8760 lines with hourly values.
%
% SYNTAX: outmat = TMY22wformat(filename)
% filename    : character string of the input TMY2 file name
% outfilename : character string of the output file name
% lat         : [-90,90],north positive
% long        : [-180,180],west positive
% long0       : reference longitude (timezone)
%
% The output matrix has the CARNOT form as described in "wformat.txt".

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
% version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
% author list:  gf -> Gaelle Faure
% 
% version   author  changes                                     date
% 5.0.0     gf      created                                     21fev2012


if nargin ~= 2
  help TMY2wformat
  return
end

try

%% Reading of header line %%
fid = fopen(filename);
header = textscan(fid,'%s %s %s %f %s %f %f %s %f %f %f',1);
station_name = char(header{2});
country = char(header{3});
long0 = header{4};
latzone = header{5};
if strcmp(latzone,'N')
    lat = header{6}+header{7}/60;
elseif strcmp(latzone,'S')
    lat = -header{6}+header{7}/60;
else
    error('Error in TMY2wformat : header line format not correct : ''N'' or ''S'' expected.');
end
longzone = header{8};
if strcmp(longzone,'W')
    long = header{9}+header{10}/60;
elseif strcmp(longzone,'E')
    long = -header{9}+header{10}/60;
else
    error('Error in TMY2wformat : header line format not correct : ''W'' or ''E'' expected.');
end

%% Solar position %%
% take solar postion from carlib since the TMY2 files have no solar position.
% There are always 8760 lines with hourly values.
[~,~,zenith,azimuth,~] = sunangles(0:3600:3600*24*365-3600,lat,long,long0);

%% Reading of weather data %%
% create a temporary file which can be properly read
fid2 = fopen('temp.txt','w+');
tline = fgetl(fid);
while ischar(tline)
    IND = strfind(tline,'-');
    if (size(IND,2)>0)
        new_line = tline(1:IND(1)-1);
        for i=1:size(IND,2)-1
            new_line = [new_line ' ' tline(IND(i):IND(i+1)-1)];
        end
        new_line = [new_line ' ' tline(IND(end):end)];
        fprintf(fid2,'%s\n',new_line);
    else
        fprintf(fid2,'%s\n',tline);
    end
    
    tline = fgetl(fid);
end
fclose(fid);
fclose(fid2);
clear fid;
clear fid2;

fid2=fopen('temp.txt');
format = ['%2f%2f%2f%2f%4f%4f%4f%1s%1f%4f%1s%1f%4f%1s%1f%4f%1s%1f%4f%1s%1f%4f%1s' ...
    '%1f%4f%1s%1f%2f%1s%1f%2f%1s%1f%4f%1s%1f%4f%1s%1f%3f%1s%1f%4f%1s%1f%3f' ...
    '%1s%1f%3f%1s%1f%4f%1s%1f%5f%1s%1f%10s%3f%1s%1f%3f%1s%1f%3f%1s%1f%2f%1s%1f'];
inmat = textscan(fid2,format);
fclose (fid2);
clear fid2;

delete('temp.txt');

%% Prepare the output matrix %%
outmat = zeros(8760,19);
outmat(:,1) = 0:3600:3600*24*365-3600;
outmat(:,2) = tvalue(outmat(:,1));      % tstring

outmat(:,3) = zenith;                   % zenith from carlib calculation
outmat(:,4) = azimuth;                  % azimuth from carlib calculation
outmat(:,5) = inmat{10};           % Idir
outmat((find(outmat(:,5)>=9999)),5) = -9999;
outmat(:,6) = inmat{13}; 	    	% Idfu
outmat((find(outmat(:,6)>=9999)),6) = -9999;
outmat(:,7) = inmat{34}/10;				% Tamb
outmat((find(outmat(:,7)>=999.9)),7) = -9999;
outmat(:,8) = skytemperature(inmat{34}/10,inmat{40},inmat{28}/10); % tsky
outmat(:,9) = inmat{40};				% humiditiy
outmat((find(outmat(:,9)>=999)),9) = -9999;
outmat(:,10) = inmat{59}/3.6e6;         % precipitation
outmat((find(outmat(:,10)>=999/3.6e6)),10) = -9999;
outmat(:,11) = inmat{28}/10;			% cloud index
outmat((find(outmat(:,11)>=9.9)),11) = -9999;
outmat(:,12) = inmat{43}*100;		    % pressure Pa
outmat((find(outmat(:,12)>=999900)),12) = -9999;
outmat(:,13) = inmat{49}/10;     	    % wind speed
outmat((find(outmat(:,13)>=99.9)),13) = -9999;
outmat(:,14) = inmat{46};			    % wind direction
outmat((find(outmat(:,14)>=999)),14) = -9999;
outmat(:,15) = -9999;					% collector incidence is not known
outmat(:,16) = -9999;					% teta rise is not known
outmat(:,17) = -9999;					% teta head is not known
outmat(:,18) = -9999;                   % Idir on surface : not konwn 
outmat(:,19) = -9999;    				% Idfu on surface : not konwn 

%% Write the wformat file %%
output = outmat';
fout = fopen(outfilename,'w');
   fprintf(fout,'%% Format of weather data in the CARNOT toolbox.\n%%\n');
   fprintf(fout,'%% Each row contains a dataset for a specific time. Column limiter is\n');
   fprintf(fout,'%% a tabulator or a space.\n');
   fprintf(fout,'%% Load Matrix to MATLAB Workspace with "load dataname.dat".\n');
   fprintf(fout,'%% Use in Simulink with the "from Workspace" block.\n%%\n');
   fprintf(fout,'%% Information on the dataset\n%% station name:  %s   country:  %s\n', station_name, country);
   fprintf(fout,'%% geographical positon: longitude: %f , latitude: %f\n', lat, long);
   fprintf(fout,'%% reference meridian for time (example: 0° = Greenwich Mean Time): %f\n', long0);
   fprintf(fout,'%% Data converted from TMY2 file\n');
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

fclose (fout);
clear fout;
output = output';

catch me
    %TODO : à améliorer
    if (exist('fid','var') && fid>-1) ; fclose(fid); end;
    if (exist('fid2','var') && fid2>-1) ; fclose(fid2); end;
    if (exist('fout','var') && fout>-1) ; fclose(fout); end;
    throw(me);
    
end