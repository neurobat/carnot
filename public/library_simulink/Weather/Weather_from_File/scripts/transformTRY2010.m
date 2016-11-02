% The script transformTRY2010 converts the 2010 TRY of the German DWD
% into the Carnot-Format. Weather data in the TRY format must be available
% as ASCII file (.dat). It will be stored under the name of the region and
% the reference (average year, hot summer, cold winter) in ASCII format.
%
% SYNTAX: transformTRY2010
%
% literature
% function calls:try2wformat
%
%   see also try2wformat

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
% ***********************************************************************

% version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
% author list:  hf -> Bernd Hafner
% 
% version   author  changes                                     date
% 6.1.0     hf      created                                     04jan2015

% choose data folder
[infile, pathname, filter] = ...
    uigetfile({'*.dat','TRY data file'; '*.*', 'All files'}, ...
        'Select TRY data file', 'MultiSelect','on');
if filter == 0  
    error('transformTRY2010: Input data not valid or cancelled by user')
end

nfiles = length(infile);                    % number of files selected

for n = 1:nfiles                            % loop over all files
    filename = infile{n};                   % get filename in a string
    % example of a filename 'TRY2010_01_Jahr.dat'

    % ---------- determine type of the year ------------------------------
    if strcmp(filename(end-7:end-4),'Jahr')
        yeartype = 'averageYear';
    elseif strcmp(filename(end-7:end-4),'Somm')
        yeartype = 'extremeSummer';
    else
        yeartype = 'extremeWinter';
    end

    % --------- determine perdiod ----------------------------------------
    if strcmp(filename(4:7),'2010')         % filename is 2010
        comment = ['Period 1988-2007 ', yeartype];
    else                                    % filename is 2035
        comment = ['Period 2021-2015 ', yeartype];
    end
        
    % ---------- Set name of the station according to the region ---------
    region = filename(9:10);
    switch region
        case '01'
            % TRY01   Nordseekueste                     (Klimaregion  1)
            % Station: Bremerhaven                     WMO-Nummer: 10129
            % Lage: 53°32'N <- B.   8°35'O <- L.     7 Meter ueber NN
            station = 'TRY01 Nordseekueste, Bremerhaven, WMO 10129, alti 7 m';
            lat = 53 + 32/60;       % Geographical latitude [-90,90] north positive
            long = -8 - 35/60;      % Geographical longitude [-180,180] west positive

        case '02'
            % TRY02   Ostseekueste                      (Klimaregion  2)
            % Station: Rostock                         WMO-Nummer: 10170
            % Lage: 54°11'N <- B.  12°05'O <- L.     4 Meter ueber NN
            station = 'TRY02 Ostseekueste, Rostock, WMO 10170, alti 4 m';
            lat = 54 + 11/60;       % Geographical latitude [-90,90] north positive
            long = -12 - 5/60;      % Geographical longitude [-180,180] west positive

        case '03'
            % TRY03   Nordwestdeutsches Tiefland       (Klimaregion  3)
            % Station: Hamburg                         WMO-Nummer: 10147
            % Lage: 53°38'N <- B.  10°00'O <- L.    13 Meter ueber NN
            station = 'TRY03 Nordwestdeutsches Tiefland, Hamburg, WMO 10147, alti 13 m';
            lat = 53 + 38/60;       % Geographical latitude [-90,90] north positive
            long = -10 - 0/60;      % Geographical longitude [-180,180] west positive

        case '04'
            % TRY04   Nordostdeutsches Tiefland        (Klimaregion  4)
            % Station: Potsdam                         WMO-Nummer: 10379
            % Lage: 52°23'N <- B.  13°04'O <- L.    81 Meter ueber NN
            station = 'TRY04 Nordostdeutsches Tiefland, Potsdam, WMO 10379, alti 81 m';
            lat = 52 + 23/60;       % Geographical latitude [-90,90] north positive
            long = -13 - 4/60;      % Geographical longitude [-180,180] west positive

        case '05'
            % TRY05   Niederrheinisch-westfaelische Bucht und Emsland (Klimaregion  5)
            % Station: Essen                           WMO-Nummer: 10410
            % Lage: 51°24'N <- B.   6°58'O <- L.   152 Meter ueber NN
            station = 'TRY05 Niederrheinisch-westfaelische Bucht und Emsland, Essen, WMO 10410, alti 152 m';
            lat = 51 + 24/60;       % Geographical latitude [-90,90] north positive
            long = -6 - 58/60;      % Geographical longitude [-180,180] west positive
 
        case '06'
            % TRY06   Noerdliche und westliche Mittelgebirge, Randgebiete (Klimaregion  6)
            % Station: Bad Marienberg                  WMO-Nummer: 10526
            % Lage: 50°40'N <- B.   7°58'O <- L.   547 Meter ueber NN
            station = 'TRY06 Noerdliche und westliche Mittelgebirge, Bad Marienberg, WMO 10526, alti 547 m';
            lat = 50 + 40/60;       % Geographical latitude [-90,90] north positive
            long = -7 - 58/60;      % Geographical longitude [-180,180] west positive
 
        case '07'
            % TRY07   Noerdliche und westliche Mittelgebirge, zentrale Bereiche (Klimaregion  7)
            % Station: Kassel                          WMO-Nummer: 10438
            % Lage: 51°18'N <- B.   9°27'O <- L.   231 Meter ueber NN
            station = 'TRY07 Noerdliche und westliche Mittelgebirge zentrale Bereiche, Kassel, WMO 10438, alti 231 m';
            lat = 51 + 18/60;       % Geographical latitude [-90,90] north positive
            long = -9 - 27/60;      % Geographical longitude [-180,180] west positive
 
        case '08'
            % TRY08   Oberharz und Schwarzwald (mittlere Lagen) (Klimaregion  8)
            % Station: Braunlage                       WMO-Nummer: 10452
            % Lage: 51°44'N <- B.  10°36'O <- L.   607 Meter ueber NN
            station = 'TRY08 Oberharz und Schwarzwald mittlere Lagen, Braunlage, WMO 10452, alti 607 m';
            lat = 51 + 44/60;       % Geographical latitude [-90,90] north positive
            long = -10 - 36/60;     % Geographical longitude [-180,180] west positive
 
        case '09'
            % TRY09 Thueringer Becken und Saechsisches Huegelland (Klimaregion  9)
            % Station: Chemnitz                        WMO-Nummer: 10577
            % Lage: 50°48'N <- B.  12°52'O <- L.   418 Meter ueber NN
            station = 'TRY09 Thueringer Becken und Saechsisches Huegelland, Chemnitz, WMO 10577, alti 418 m';
            lat = 50 + 48/60;       % Geographical latitude [-90,90] north positive
            long = -12 - 52/60;     % Geographical longitude [-180,180] west positive
 
        case '10'
            % TRY10 Suedoestliche Mittelgebirge bis 1000 m (Klimaregion 10)
            % Station: Hof                             WMO-Nummer: 10685
            % Lage: 50°19'N <- B.  11°53'O <- L.   567 Meter ueber NN
            station = 'TRY10 Suedoestliche Mittelgebirge bis 1000 m, Hof, WMO 10685, alti 567 m';
            lat = 50 + 19/60;       % Geographical latitude [-90,90] north positive
            long = -11 - 53/60;      % Geographical longitude [-180,180] west positive
 
        case '11'
            % TRY11   Erzgebirge, Boehmer- und Schwarzwald oberhalb 1000 m (Klimaregion 11)
            % Station: Fichtelberg                     WMO-Nummer: 10578
            % Lage: 50°26'N <- B.  12°57'O <- L.  1213 Meter ueber NN
            station = 'TRY11 Erzgebirge, Boehmer- und Schwarzwald oberhalb 1000 m, Fichtelberg, WMO 10578, alti 1213 m';
            lat = 50 + 26/60;       % Geographical latitude [-90,90] north positive
            long = -12 - 57/60;      % Geographical longitude [-180,180] west positive
 
        case '12'
            % TRY12   Oberrheingraben und unteres Neckartal (Klimaregion 12)
            % Station: Mannheim                        WMO-Nummer: 10729
            % Lage: 49°31'N <- B.   8°33'O <- L.    96 Meter ueber NN
            station = 'TRY12 Oberrheingraben und unteres Neckartal, Mannheim, WMO 10729, alti 96 m';
            lat = 49 + 31/60;       % Geographical latitude [-90,90] north positive
            long = -8 - 33/60;      % Geographical longitude [-180,180] west positive
 
        case '13'
            % TRY13   Schwaebisch-fraenkisches Stufenland und Alpenvorland (Klimaregion 13)
            % Station: Muehldorf                       WMO-Nummer: 10875
            % Lage: 48°17'N <- B.  12°30'O <- L.   405 Meter ueber NN
            station = 'TRY13 Schwaebisch-fraenkisches Stufenland und Alpenvorland, Muehldorf, WMO 10875, alti 405 m';
            lat = 48 + 17/60;       % Geographical latitude [-90,90] north positive
            long = -12 - 30/60;      % Geographical longitude [-180,180] west positive
 
        case '14'
            % TRY14   Schwaebische Alb und Baar        (Klimaregion 14)
            % Station: Stoetten                        WMO-Nummer: 10836
            % Lage: 48°40'N <- B.   9°52'O <- L.   734 Meter ueber NN
            station = 'TRY14 Schwaebische Alb und Baar, Stoetten, WMO 10836, alti 734 m';
            lat = 48 + 40/60;       % Geographical latitude [-90,90] north positive
            long = -9 - 52/60;      % Geographical longitude [-180,180] west positive
 
        case '15'
            % TRY15   Alpenrand und -taeler            (Klimaregion 15)
            % Station: Garmisch-Partenkirchen          WMO-Nummer: 10963
            % Lage: 47°29'N <- B.  11°04'O <- L.   719 Meter ueber NN
            station = 'TRY15 Alpenrand und -taeler, Garmisch-Partenkirchen, WMO 10963, alti 719 m';
            lat = 47 + 29/60;       % Geographical latitude [-90,90] north positive
            long = -11 - 4/60;      % Geographical longitude [-180,180] west positive
        
        otherwise
            % unkown station
            station = 'xxx';
            lat = 0 + 0/60;       % Geographical latitude [-90,90] north positive
            long = 0 - 0/60;      % Geographical longitude [-180,180] west positive
            warning('MATLAB:FilenameUnknown','transformTRY2010 - region unknown')
    end
    
    % ------------- other constant parameters ----------------------------
    outfile = ['DE_', filename(1:11), yeartype, '.dat'];
    long0 = -15;    % Geographical longitude of the timezone [-180,180] west positive, for Germany -15°
    country = 'Germany';

    % call try2wformat to transform the data
    try2wformat(fullfile(pathname,filename),outfile, ...
        lat,long,long0,station,country,comment);
end