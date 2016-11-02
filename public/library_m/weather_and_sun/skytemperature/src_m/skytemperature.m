function Tsky = skytemperature(Tamb,hum,cloud)
%
% FUNCTION:    calculation of the sky temperature
%
%              INPUT:
%              1. Tamb     :  ambient temperature [°C]
%              2. hum      :  relative humidity [%]
%              3. cloud    :  cloudness index [0..1]
%
%              OUTPUT:
%              1. Tsky     :  radiation temperature of sky [°C]

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
% ------------------- history --------------------------------------
% version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
% author list:  hf -> Bernd Hafner
%               gf -> Gaelle Faure
%               tw -> thomas Wenzel
% 
% version   author  changes                                     date
% 1.1.0     tw      created, based on metcalc.m / Markus Werner 18oct1999
% 4.1.0     hf      adapted to Carnot 4.0                       2009
% 4.1.1     hf      vectorized version                          2010

insize = size(Tamb);        % input size

if nargin ~= 3              % check for correct input
    help skytemperature
    error('skytemperature: number of input arguments must be 3')
elseif (insize ~= size(hum) + insize ~= size(cloud))
    help skytemperature
    error('skytemperature: number of  arguments must be 3')
elseif nargout > 1         % check for correct output
    help skytemperature
    error('skytemperature: too many output arguments')
end

% ------------------------------------------------------------------------------- 
% 	"Tdew"			Taupunkttemperatur 
% 	"Tsky"			Himmelstemperatur 
%	"CloudIndex"	Bedeckungsgrad, Diskretisierung in Okta [0, 1/8, 2/8, ... ,8/8]
% ------------------------------------------------------------------------------- 
e = exp(-1000/8200); % für "Tsky"-Berechnung nach BERDAHL (TIEFE Wolken, 1000 m) 
sigma = 5.67e-8; % für "Tsky"-Berechnung nach UNSWORTH (Stefan-Boltzmann-Konstante)

% Himmelstemperatur "Tsky" nach BERDAHL oder UNSWORTH (je nach Wetterdatenbasis):
Tamb4 = (Tamb+273.15).^4;

if hum > 0              % got some data for the relative humidity
    % dew point temperature from carlib
    % saturationtemperature(temperature, pressure, 
    %   fluid_ID = 2 for Air, fluid_mix in kg water / kg dry air)
    Tdew = saturationtemperature(1e5, 2, rel_hum2x(Tamb,1e5,hum));
   % Himmelstemperatur "Tsky" nach BERDAHL für tiefe Wolken (1000 m)
   % (OHNE cos-Term, s. Feist,1994,S.290ff):
   F = 0.711 + Tdew.*(0.0056 + 7.3e-5.*Tdew);
   Tsky = (Tamb4 .* ((1-F).*cloud.*e + F)).^0.25 - 273.15;
else
    % es liegen KEINE Feuchtewerte vor! -> Himmelstemperatur "Tsky" nach UNSWORTH
    % (mit korrigierten Parametern, s. Feist,1994,S.290ff):
    Tsky = ( -(150/sigma) .* (1 - cloud.*0.9) + ...
             (1.2 - 0.18.*cloud)*Tamb4 ).^0.25 - 273.15;
end % if hum