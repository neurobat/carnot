function erg=radiationdivision(time,I,latitude,longitude,longitudenull)
% FUNCTION: Berechnug von direkter und diffuser Strahlung auf die Horizontale
%  
%  INPUT
%         
%  1. time          :   Zeit in Sekunden
%  2. I             :   Globalstrahlung auf eine HORIZONTALE Fläche, W/m2
%  3. latitude      :   Breitengrad ([-90,90],Nord positiv)
%  4. longitude     :   Längengrad ([-180,180],West positiv)
%  5. longitudenull :   Referenzlängengrad (Zeitzone)
%					
%  OUTPUT
%
%  1. Idir          :   direkte Strahlung auf Horizontale, W/m2
%  2. Idfu          :   diffuse Strahlung auf Horizontale, W/m2
%  3. SunAngle      :   Sonnenhöhenwinkel
%  4. Zenith        
%  5. Azimuth
%

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
% Modifizierung des M-Skriptes metcalc.m von Markus Werner, Solar-Institut Juelich
%
% Thomas Wenzel, 18.10.1999
% Bernd Hafner: adaptation to Carnot 4                          26jan2009
%

% ------------ check the inputs -------------------------------------------
if nargin ~= 2 && nargin ~= 3
    help radiationdivision
    error('number of input arguments must be 5')
end

%------------------------------------ program code ------------------------------------

% Besetzen diverser Variablen mit Default-Werten:
SunHour = 0;	% Kennung für Tagesstunden; "0" = NACHTstunden
ClearIndex = -1; % Erkennungsmarke für NACHT-Interpolation

Idfu = 0;	% Default: "0" = NACHT

% cosLat 			= cos(latitude * pi/180);
% sinLat 			= sin(latitude * pi/180);
DeclDayAmpl = -23.45 * pi/180; 
% HourAngleAmpl 	= 15 * pi/180;

%TageProMonat = [31  28  31  30  31  30  31  31  30  31  30  31]
Tagebisher  = [0 31  59  90 120 151 181 212 243 273 304 334 365];

DEG2RAD =  0.01745329251994;
RAD2DEG =  57.29577951308232;

SunAngle = 0;
zenith = 0;
azimuth = 0;


if (I<0)       % wenn negative Einstrahlung, dann Einstrahlungen = 0
   Idir = 0;
   Idfu = 0;
else
   
   Datum = sec2date(time);
   day = Datum(2) + Tagebisher(Datum(1));  % Tag + Tage in den Vormonaten

   % Tägliche Deklination der Sonne "DeclDay" (nach Meliß,1988,S.32):
   DeclDay = DeclDayAmpl * cos(2*pi*(day+10)/365);
   
   % Tagesmittelwert der extraterrestrischen Strahlung "IextraDay", die senkrecht
   % auf eine zur Sonne orientierten Fläche fällt (nach Duffie/Beckman,1993,S.10):
   IextraDay = 1353 * (1+0.033*cos(2*pi*day/365));   
   
   % ------------------------------------------------------------------------------- 
	% 	"Decl"			Deklination der Sonne
	%	"HourAngle" 	Stundenwinkel der Sonne 
	%	"zenit"			Zenithwinkel 
   %	"SunAngle"		Sonnenhöhenwinkel
	% 	"azimut"			Azimutwinkel 
	%	"Iextra"			Extraterrestrische Strahlung auf HORIZONTALE Fläche
   %	"SunHour"		Tag-/Nachterkennung Êrkennung
   %	"dimness"		Trübungsfaktor der Atmosphäre
   % 	"Idirclear"		direkte Strahlung auf der Erdoberfläche für KLAREN Himmel 
	% 	"Idfuclear"		diffuse Strahlung auf der Erdoberfläche für KLAREN Himmel 
   % ------------------------------------------------------------------------------- 
    zeitgz = Datum(3)*3600+Datum(4)*60+Datum(5);        % standard time in seconds */
    
    % declination of the sun */
    xj = 0.9856*(time/86400.)-2.72;
    xbogen = DEG2RAD*xj;
    arg2 = DEG2RAD*(xj - 77.51 + 1.92*sin(xbogen));
    arg3 = sin(arg2);
    delta = asin(0.3978*arg3);                      % declination angle */
    deltaangle = RAD2DEG*delta;

    arg5 = DEG2RAD*2.0*xj+24.99+3.83*sin(xbogen);

    % determine solar hour angle in radian (noon = 0,  6 a.m. = -PI) */
    z   = 60.0*(-7.66*sin(xbogen)-9.87*sin(arg5));  % z is in seconds */
    moz = zeitgz + (longitudenull-longitude)*240.0;
    woz = moz + z;                                  % true local time */
    HourAngle = DEG2RAD*(woz - 43200.0)*0.00416666666667; % is in seconds */
    
    latitude  = DEG2RAD*latitude;
    
    % solar zenith angle in degrees (0° = zenith position, 90° = horizont) */
    coszenit = sin(latitude)*sin(delta) ...
        + cos(latitude)*cos(delta)*cos(HourAngle);
     zenith  =  acos(coszenit)*RAD2DEG;   
     if zenith > 90
        zenith = 90;
     end
     

    % solar azimuth angle */
    if (acos(coszenit) ~= 0.0) 
       azimuth = RAD2DEG*acos((sin(latitude)*coszenit ...
          -sin(delta))/(cos(latitude)*sin(acos(coszenit))));
       if HourAngle < 0
          azimuth = -azimuth;
       end       
     else
        azimuth = 0.0;
     end   
%     if (tetaz != 0.0) {
%        azimuth = RAD2DEG*acos((sin(latitude)*cos(tetaz)
%            -sin(delta))/(cos(latitude)*sin(tetaz)));
%        azimuth = (hourangle < 0.0)? -azimuth : azimuth; /* same sign as hourangle */
%    } else
%        azimuth = 0.0;
 
    
    % Sonnenhöhenwinkel "SunAngle":
    SunAngle = 90 - zenith;
    if SunAngle < .01
       SunAngle = .01; % da sonst Warnung "log(0)" (s.u.), falls SunAngle = 0.
    end
    
    % Auf eine HORIZONTALE (= der Erdoberfläche parallelen) Fläche unter dem
    % Winkel "zenit" treffende extraterrestrische Strahlung "Iextra":
    Iextra = IextraDay * coszenit;
    
    % Kennung für Tagesstunden "SunHour":
    if (Iextra > 0)
       SunHour = 1;
    else
       SunHour = 0;
    end
    
    % Unterdrückung von nächtlichen Offset-Werten in "I":
    if (SunHour == 0)&(I > 0)
       I = 0;
    end
   	
    % ------------------------------------------------------------------------------- 
    % 	"ClearIndex"	Klarheitsindex der Atmosphäre (TAG)
    % 	"Idir"			direkte Strahlung auf der Erdoberfläche
    % 	"Idfu"			diffuse Strahlung auf der Erdoberfläche
    % ------------------------------------------------------------------------------- 
    
    Idfu = 0;
    if SunHour == 1
       ClearIndex = I/Iextra;
       
       if ClearIndex > 1
          % ggfs. Korrektur, damit "ClearIndex" <= 1 bleibt:
          ClearIndex = 1;
       end
       
       % Diffuse Strahlung auf HORIZONTALE Fläche "Idfu" ... 
       if ClearIndex <= 0.3
          Idfu = I * (1 - 0.2 * ClearIndex);
       elseif (ClearIndex > 0.3)&(ClearIndex <= 0.79)
          Idfu = I * (1.423-1.612 * ClearIndex);
       else
          Idfu = I * 0.15;
       end
    end
    
    % Direkte Strahlung auf HORIZONTALE Fläche "Idir"
    Idir = I - Idfu;

end % else if I>=0

erg(1) = Idir;
erg(2) = Idfu;
erg(3) = SunAngle;
erg(4) = zenith;   
erg(5) = azimuth;