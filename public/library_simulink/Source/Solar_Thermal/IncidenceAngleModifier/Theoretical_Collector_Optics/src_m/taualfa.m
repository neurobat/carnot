function f = taualfa(ncover, refin, teta, KL, alfa)
% taualfa(ncover,refin,teta,KL,alfa) calculates the 
% transmittance - absorbance product for collector cover and absorber.
%    symbol     purpose
%    ncover     number of covers (> 0)
%    refin      refraction index (scalar or vector for each cover)
%    teta       incidence angle in radian
%    KL         extinction coefficient * thickness of cover
%               (scalar or vector for each cover)
%               K = 4/m (extra white glass), K = 16/m (usual float glass)
%    alfa       absorption coefficient of absorber (0..1)
% 
% output is a vector with taualfa for each incidence angle specified
% 
% For the calculation of the incidence angle modifier (IAM) divide 
%    the result by taualfa(teta = 0) since by definition
%    IAM = 1 for teta = 0.

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
% 1.0.0     hf      created                                     1999
% 6.1.0     hf      updated help text and error handling        2014

if nargin ~= 5
    help taualfa
    error('taualfa requires 5 parameters') 
end

if length(refin) > 1 && length(refin) ~= ncover
    error('specify ONE refraction index "refin" or one for EACH cover')
end   
if length(KL) > 1 && length(KL) ~= ncover
    error('specify ONE extinction coefficient "KL" or one for EACH cover')
end   
      

f = alfa*ones(length(teta),1);
if ncover > 0
    for i = 1:length(teta)
        if teta(i) < 1e-6
            teta(i) = 1e-6;
        end
        tetacov = asin(sin(teta(i))./refin);
    	w = [tetacov-teta(i)  tetacov+teta(i)];
    	r = sin(w);
    	t = tan(w);
        rho = [r(1:length(r)/2) / r(length(r)/2+1:length(r)) ...
            t(1:length(r)/2) / t(length(r)/2+1:length(r))].^2;
        taua = exp(-KL./cos(tetacov));
        tt = ((1-rho).^2 ./ (1 - (rho.*taua).^2)) .* taua;
    	rr = rho .* (1 + tt.*taua);
    	tau = tt;
        ref = rr;
        for n = 2:ncover
            tau = tau .* tt ./ (1 - ref.*rr);
            ref = ref + tau.^2 .* rr ./ (1 - ref.*rr);
        end
        rhod = mean(ref);
        f(i) = mean(tau) * alfa ./ (1 - (1-alfa) * rhod);
    end
end