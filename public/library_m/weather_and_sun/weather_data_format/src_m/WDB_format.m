% Format of weather data in the CARNOT toolbox.
%  
% Weather data for Carnot should be saved in ASCII-format.
% Each row contains a dataset for a specific time. Column limiter is
% a tabulator or a space.
% Load them to MATLAB Workspace with "load dataname.dat" and use with the 
% Simulink block "from Workspace".
% Or use directely the the Carnot block "weather_from_file". This block
% loads the weather data automatically.
%
% The dataname.dat should follow the definition:
%   CC_city.dat 
% where
%   CC = 2-letter (Alpha 2) code of the country according to ISO 3166-1
%   city = name of the city, use the english name if available
%
% ** The following lines should be the header of each weather data file **
% 
% station name:     country:
% geographical positon: longitude: , latitude:
% reference meridian for time (example: 0° = Greenwich Mean Time):
% mark type of data collection: measured/calculated/satellite
%
% the column old_col refers to the old weather data format (up to Carnot 4.6)
%
% col       description                                         units
%  1        time                                                s
%  2        timevalue (comment line) format YYYYMMDDHHMM        -
%           Y is the year, M the month, D the day, H the hour
%  3        zenith angle of sun (at time, not averaged)         degree
%           (continue at night to get time of sunrise by
%           linear interpolation)
%  4        azimuth angle of sun (0°=south, east negative)      degree
%           (at time, not average in timestep)
%  5        direct beam solar radiation on a normal surface     W/m^2
%  6        diffuse solar radiation on a horizontal surface     W/m^2
%  7        ambient temperature                                 degree Celsius
%  8        radiation temperature of sky                        degree Celsius
%  9        relative humidity                                   percent
% 10        precipitation                                       m/s
% 11        cloud index (0=no cloud, 1=covered sky)             -
% 12        station pressure                                    Pa
% 13        mean wind speed                                     m/s
% 14        wind direction (north=0° west=270°)                 degree
% 15        incidence angle on surface (0° = vertical)          degree
% 16        incidence angle in a vertical plane on the collecor degree
%           orientation of the plane is parallel to the risers,
%           referred as longitudinal plane in EN 12975
% 17        incidence angle in a vertical plane on the collecor degree
%           orientation of the plane is parallel to the headers
%           referred as transversal plane in EN 12975
%           (= -9999, if surface orientation is unknown)
% 18        direct solar radiation on surface                   W/m^2
% 19        diffuse solar radiation on surface                  W/m^2
%
% UNKNOWN: set -9999 for unknown values
%
% time tvalue zenit azimut Idir Idfu Tamb Tsky hum prec cloud p speed dir indice tetarise tetahead IdirSurf IdfuSurf


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
