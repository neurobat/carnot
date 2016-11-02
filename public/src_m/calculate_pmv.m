function pmv = calculate_pmv(meta, work, i_cl, v_air, p_h2o, t_air, t_rad)
% calculate_pmv: predictive mean vote for room temperature comfort
%% Description
%  calculation of pmv - equation (1) in DIN EN ISO 7730:2005
%  See also calculate_ppd
%  Literature: /1/  DIN EN ISO 7730:2005
%% Function Call
%  pmv = calculate_pmv(meta, work, i_cl, v_air, p_h2o, t_air, t_rad)
%% Inputs
%  meta:         metabolic rate [W/m²]; 1 met = 58.2 W/m² */
%  work:         effective mechanical power [W/m²] */
%  i_cl:         clothing isolation [m²/kW]; 1 clo = 0.155 W/m² */
%  t_air         air temperature [°C] */
%  t_rad         mean radiation temperature [°C] */
%  v_air         relative air velocity [m/s] */
%  p_h2o         partial pressure of water [Pa] */
%% Outputs
%  pmv - predicitve mean vote
%        -3 = too cold
%         0 = perfect comfort level
%        +3 = too hot

% -> all comments till the first calculation appear with "help function"
%% Calculations
% original function in comfortsfcn.c:
% static double calculate_pmv(double m, double w, double f_cl, double h_c, double p_a, double t_a, double t_r, double t_cl)

la = length(t_air);
lr = length(t_rad);

if lr == 1
    N = la;
    t_rad = t_rad*ones(la,1);
elseif la == 1
    N = lr;
    t_air = t_air*ones(lr,1);
elseif la == lr
    N = la;
else
    error('calculate_pmv:InputLength','t_air and t_rad must be scalar or of same length)')
end

pmv = zeros(N,1);  % initialize variable

for n = 1:N
    % 	/* calculate the clothing surface temperature t_cl */
    % t_cl = calculate_t_cl(meta, work, i_cl, t_air(n), t_rad(n), v_air);
    t_cl = fminsearch(@(t_cl) ...
        clothing_surface_temperature(meta, work, i_cl, v_air, t_air(n), t_rad(n), t_cl), ...
        (t_air(n) + t_rad(n))/2);
    f_cl = clothing_area_factor(i_cl);
    h_c  = heat_transfer_clothing(v_air, t_cl, t_air(n));

    % 	/* calculate pmv */
    aux1 = (meta-work)-3.05e-3*(5733.0-6.99*(meta-work)-p_h2o(n))-0.42*((meta-work)-58.15);
    aux2 = -1.7e-5*meta*(5867.0-p_h2o(n))-0.0014*meta*(34.0-t_air(n));
    aux3 = -3.96e-8*f_cl*((t_cl+273.0).^4 - (t_rad(n)+273.0).^4) - f_cl*h_c*(t_cl-t_air(n));
    aux4 = 0.303*exp(-0.036*meta) + 0.028;
    pmv(n) = aux4 * (aux1 + aux2 + aux3);
end

%% Copyright and Versions
% This file is part of the CARNOT Blockset.
% 
% Copyright (c) 1998-2016, Solar-Institute Juelich of the FH Aachen.
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
% author list:      hf -> Bernd Hafner
%                   aw -> Arnold Wohlfeil
%
% version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
%
% Version   Author  Changes                                         Date
% 6.1.0     hf      created form s-function comfortsfcn.c of aw     18oct2016
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *