function teta = ...
    test_incidence_angles(AZIMUT, ZENITH, COLAZIMUT, COLANGLE, COLROTATE)
% function to test the sunlight incidence anles on a collector plane

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
% **********************************************************************
% D O C U M E N T A T I O N
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
% author list:     hf -> Bernd Hafner
%
% version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
%
% Version   Author  Changes                                     Date
% 6.1.0     hf      created                                     2014

DEG2RAD = pi/180;
RAD2DEG = 180/pi;

as = DEG2RAD * AZIMUT;
zs = DEG2RAD * ZENITH;
zc = DEG2RAD * COLANGLE;
ac = DEG2RAD * COLAZIMUT;
rc = DEG2RAD * COLROTATE;
    
szs = sin(zs);      % sine ZENITH angle of sun */
czs = cos(zs);      % cosine ZENITH angle of sun */
sda = sin(as-ac);   % difference of azimut */
cda = cos(as-ac); 
szc = sin(zc);      % sine ZENITH angle of collector (inclination) */
czc = cos(zc);      % cosine ZENITH angle of collector (inclination) */
src = sin(rc);      % sine rotation angle of collector */
crc = cos(rc);      % cosine rotation angle of collector */

% incidence angle between sun and normal of the collector plane
costeta = src*sda*szs+crc*(szc*cda*szs+czc*czs);    % cos of incidence angle on surface */

% old functions of carnot surfrad.c
% incidence angle in longitudinal collector plane (direction riser - vertical on window) */
tetalong = acos(costeta/sqrt((czc*cda*szs-szc*czs)^2+costeta^2));
% incidence angle in transversal collector plane (direction header - vertical on window) */
tetatrans = acos(costeta/sqrt((crc*sda*szs-src*(szc*cda*szs+czc*czs))^2+costeta^2));
s = sprintf('SUN: AZIMUT %f   ZENITH %f', AZIMUT, ZENITH);
disp(s)
s = sprintf('COLAZIMUT %f   COLANGLE %f   COLROTATE %f', COLAZIMUT, COLANGLE, COLROTATE);
disp(s)

% plot coordinates
plot3([0 0],[0 1],[0 0],'b',[0 1],[0 0],[0 0],'b',[0 0],[0 0],[0 1],'b')
hold on
% plot sun
plot3([0 0],[0 szs],[0 czs],'y')
% plot collector frame
plot3([-cda cda]/2,                 [-sda sda]/2,                   [0 0],'r')
plot3([-cda cda]/2-[sda sda]*czs/2, [-sda sda]/2+[-cda -cda]*czs/2, [szc szc]/2,'r')
plot3([-cda cda]/2+[sda sda]*czs/2, [-sda sda]/2+[cda cda]*czs/2,   [-szc -szc]/2,'r')
plot3([-sda sda]*czs/2,             [-cda cda]*czs/2,               [szc -szc]/2,'g')
plot3([cda cda]/2,                  [-cda cda]*czs/2,               [szc -szc]/2,'g')
plot3([-cda -cda]/2,                [-cda cda]*czs/2,               [szc -szc]/2,'g')
hold off

% set outputs
teta(1) = RAD2DEG*acos(costeta);
teta(2) = RAD2DEG*tetalong;
teta(3) = RAD2DEG*tetatrans;
