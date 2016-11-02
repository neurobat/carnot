function p = colpdrop(tin, tout, mdot, p, fluid_id, fluid_mix, dhead, ...
    lhead, drise, lrise, nrise, Acol)
% COLPDROP calculates the pressuredrop in an absorber per apertur surface
% in [Pa/m^2]. The type of absorber is a header - riser construction.
%
% syntax:
% colpdrop(tin, tout, mdot, p, fluid_id, fluid_mix,dhead,...
%	lhead, drise, lrise, nrise, Acol)
%
% Parameters:
%	tin         temperature at inlet in degree centrigrade
%	tout        temperature at outlet in degree centrigrade
%	mdot        massflow per collector surface in kg/(s*m^2)
%	p           pressure in Pa
%	fluid_type  identifier for fluid (see Carnot_Fluid_Types)
%	fluid_mix   percentage of mixing for water glycol (0 = pure water)
%	dhead       diameter of header in m
%	lhead       length of header in m
%	drise       diameter of riser in m
%	lrise       length of riser in m
%	nrise       number of risers
%	Acol        collector suface in m^2
%
% An equation of Dunkle and Davey (1970) is used, who studied the problem of
% pressure drop analytically and experimentally. The basic assumption is that
% the flow is turblent in the headers and laminar in the risers, an assumption
% which according to Duffie and Beckman (1991) is true for many collectors 
% specially in thermosyphon and low-flow systems.
% Literature: Dunkle, Davey: Flow distribution in absorber banks, ISES Conference, 1970
% Duffie, Beckman: Solar Engineering of Thermal Processes, 1991
% See also Carnot_Fluid_Types



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
% version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
%
% Version   Author  Changes                                     Date
% 1.1.0     hf      created                                     around 1998
% 6.1.0     hf      documentation added                         26nov2014


if (nargin ~= 12)
  help colpdrop
  error('colpdrop requires 12 input arguments')
end

mdot_total = mdot.*Acol;

tbar = 0.5.*(tin+tout);

rho1 = density(tin,  p, fluid_id, fluid_mix);
rho2 = density(tout, p, fluid_id, fluid_mix);
rho  = density(tbar, p, fluid_id, fluid_mix);

vis1 = kinematic_viscosity(tin,  p, fluid_id, fluid_mix);
vis2 = kinematic_viscosity(tout, p, fluid_id, fluid_mix);
vis  = kinematic_viscosity(tbar, p, fluid_id, fluid_mix);

% coefficients for pressure drop in collector
s1 = 0;
s2 = 0;
for n = 1:nrise
    s1 = s1+n;
    s2 = s2+n^2;
end
s1 = s1/nrise^2;
s2 = s2/nrise^2;
    
% ---------- headers ------------
uin  = 4*mdot_total./(rho.*pi.*dhead.^2);   % velocity at inlet
uout = 4*mdot_total./(rho.*pi.*dhead.^2);   % velocity at inlet

% friction coefficient
fc = s1.*16.* lhead/dhead^2.* (-uin.*vis1 + uout.*vis2) ...
  	+ s2./4 .* (uin.^2 .* rho1 + uout.^2 .* rho2);
fc = max(0,fc);     % no friction below zero

% ---------- risers -------------
u = 4.*mdot_total./(nrise.*rho.*pi.*drise.^2);
re = u.*drise/vis;
% disp(['Reynolds number ' num2str(re)])
% developing flow factor
for i = 1:length(re)
   re(i) = max(0.01, re(i));
end
dev = 1 + 0.038./(lrise./(re.*drise)).^0.964;
fc = fc + 32./re.*lrise.*u.^2.*rho/drise.*dev;
drh = (drise/dhead).^2;
xkin = (-0.3259.*drh.^2-0.1784.*drh+0.5).*drh.^2;
xkout = 0.667.*drh.^2-2.667.*drh+2;
p = (fc+(xkin+xkout).*u.^2.*rho./2)./Acol;