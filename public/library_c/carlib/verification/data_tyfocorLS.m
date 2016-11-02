function [t, p, mix, dref, dsim0] = data_tyfocorLS(prop)
% function [t, mix, dref, dsim0] = data_tyfocorLS(prop)
% define the reference data from literature and simulation standard for 
% fluid properites of Tyfocor LS (C), used to validate the carnot material 
% properties library carlib.c
% Simulation standard is the result of the fluid properties functions
% with the original Matlab version during the development of the function.
%   prop =  'heat_capacity' in J/kg/K
%           'density' in kg/m³
%           'kinematic_viscosity' in mm²/s
%           'thermal_conductivity' in W/m/K
%           'vapourpressure' in Pa
% output:
%   t       vector with temperatures for the reference point
%   p       vector with the pressures (same length as t)
%   mix     vector with fluid_mixtures (same length as t)
%   dref    vector with the reference data (same length as t)
%   dsim0   vector with the data from initial simulation (same length as t)
% 
% function calls:
% function is used by: verify_density, verify_heat_capacity,
% this function calls:  --
% 
% Literature: Reference data from Tyforop Chemie Hamburg for Tyfocor LS, a 
%             propylenglycol - water mixture. 42-Vol% of Glycol.
% Tyforop is a registered trademark of Tyforop Chemie Hamburg

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
% author list:     hf -> Bernd Hafner
%
% version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
%
% Version   Author  Changes                                     Date
% 6.1.0     hf      created                                     17nov2013
% 6.2.1     hf      filename validate_ replaced by verify_      09jan2015
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

% not used for the moment: cubic expansion coeff[x 10-5/K]  
% kapa = [41.5;43;46;49;52.5;56;59;62.5;66;69;72;75;78;81;84;87;]

t = [-25;-20;-10;0;10;20;30;40;50;60;70;80;90;100;110;120;]; % T[°C] 
mix = 0;    % no fluid mixture, tyfocor LS is ready made mixture
p = 3e5;    % pressure is not relevant, just be above vapour pressure for all temperatures

% dref are the reference (literature) values
% dsim0 are the reference simulated values for the original Matlab version
% dref and dsim0 be a 3-dimensional matrix with:
% row 1..N, colon 1, page 1: ref-value for all temperatures at p(1), mix(1)
% row 1..N, colon 2, page 1: ref-value for all temperatures at p(2), mix(1)
% row 1..N, colon M, page 1: ref-value for all temperatures at p(M), mix(1)
% row 1..N, colon 1, page 2: ref-value for all temperatures at p(1), mix(2)
% row 1..N, colon 2, page 2: ref-value for all temperatures at p(2), mix(2)
% row 1..N, colon M, page 2: ref-value for all temperatures at p(M), mix(2)


switch prop
    case 'heat_capacity' %  cp[J/kg/K]
        dref = [3420;3440;3480;3520;3560;3600;3640;3680;3720;3760; ...
            3800;3840;3880;3920;3960;3990;];
        dsim0 = [3420.95317500000;3440.84094000000;3480.61647000000; ...
                 3520.39200000000;3560.16753000000;3599.94306000000; ...
                 3639.71859000000;3679.49412000000;3719.26965000000; ...
                 3759.04518000000;3798.82071000000;3838.59624000000; ...
                 3878.37177000000;3918.14730000000;3957.92283000000; ...
                 3997.69836000000;];
    case 'density' % Density[kg/m3]
        dref = [1055;1053;1049;1045;1040;1034;1029;1021;1015;1008; ...
            1001;993;986;977;969;959;];
        dsim0 = [1055.06240832813;1053.20951378400;1049.13390097300; ...
                 1044.58100000000;1039.56978302700;1034.11922221600; ...
                 1028.24828972900;1021.97595772800;1015.32119837500; ...
                 1008.30298383200;1000.94028626100;993.252077824000; ...
                 985.257330683000;976.975017000000;968.424108937000; ...
                 959.623578656000;];
    case 'kinematic_viscosity' % kinematic Viscosity[mm2/s]
        dref = [85;57.1000000000000;26.9000000000000;14.5000000000000; ...
            7.90000000000000;4.95000000000000;3.40000000000000; ...
            2.52000000000000;1.91000000000000;1.66000000000000; ...
            1.42000000000000;1.08000000000000;0.810000000000000; ...
            0.590000000000000;0.380000000000000;0.190000000000000;]*1e-6;
        dsim0 = [8.46943810575000e-05;5.72536835199438e-05; ...
            2.73291391255087e-05;1.40985303007818e-05; ...
            7.97324128428243e-06;4.96614603988320e-06; ...
            3.39314068440604e-06;2.51397919491650e-06; ...
            1.98346851861789e-06;1.62744870588779e-06; ...
            1.35005599093139e-06;1.09691708751967e-06; ...
            8.43530565358618e-07;5.92398669798553e-07; ...
            3.66429108124748e-07;1.92637793796475e-07;];
    
    case 'thermal_conductivity' % thermalConductivity[W/mK]    
        dref = [0.382000000000000;0.385000000000000;0.392000000000000; ...
            0.399000000000000;0.406000000000000;0.413000000000000; ...
            0.420000000000000;0.427000000000000;0.434000000000000; ...
            0.442000000000000;0.449000000000000;0.456000000000000; ...
            0.462000000000000;0.469000000000000;0.476000000000000; ...
            0.483000000000000;];
        dsim0 = [0.381636567500000;0.385142414000000;0.392154107000000; ...
            0.399165800000000;0.406177493000000;0.413189186000000; ...
            0.420200879000000;0.427212572000000;0.434224265000000; ...
            0.441235958000000;0.448247651000000;0.455259344000000; ...
            0.462271037000000;0.469282730000000;0.476294423000000; ...
            0.483306116000000;];
        
    case 'vapourpressure' % vapour pressure [Pa]
        % other temperatures for this property, still in °C
        t = [40;50;60;70;80;90;100;110;120;130;140;150;160;170;180;190;200;];
        dref = [4000;12000;19000;29000;42000;62000;90000;140000;180000; ...
            250000;320000;420000;560000;710000;920000;1200000;1490000;];
        dsim0 = [5013.25287591257;9649.39463632078;16940.4657026138; ...
            27826.3272735237;43450.0160944199;65184.6127009517; ...
            94662.3331032056;133805.966030124;184862.781135704; ...
            250441.037583489;333549.226830422;437638.188075238; ...
            566646.239655124;725047.474639508;917903.373969837; ...
            1150917.89572509;1430496.20445388;];
    
    otherwise
        t = nan;
        dref = nan;
        dsim0 = nan;
end
