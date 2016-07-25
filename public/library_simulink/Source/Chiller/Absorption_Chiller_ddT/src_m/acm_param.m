function K = acm_param(M)
% This file calculates the characteristic paramaters A, E, s_e, r_e, s_g and r_g 
% for the acm-model based on the fitted deltadelta_t' model from A. Kühn
% (2005).
% WARNING : use this model with caution because it is not very precise and
% not validated.
% 
% syntax:   acm_param(M)
%
% input: a matrix M where each row has five elements
%       (specify at least seven rows for M)
%
%       [Qdot_E     Qdot_G     t_E     t_G     t_AC]
%
%   first element is the cooling capacity of the evaporator in kW
%         Qdot_E = M(:,1);
%
%   second element is the corresponding driving heat of the generator in kW
%         Qdot_G = M(:,2);
%
%   third element is the corresponding arithmetic mean temperature of the
%   external waterloop of the evaporator in °C
%         t_E = M(:,3);
%
%   fourth element is the corresponding arithmetic mean temperature of the external waterloop of the
%   generator in °C
%         t_G = M(:,4);
%
%   fifth element is the corresponding arithmetic mean temperature of the
%   external waterloop of absorber and condenser in °C
%         t_AC = M(:,5);
% 
% Linear model:
% deltadelta_t'=t_G - A*t_AC + E*t_E
% Qdot_E = s_e * deltadelta_t' + r_e
% Qdot_G = s_g * deltadelta_t' + r_g 
%
% output: [A  E  s_E  s_G  r_E  r_G]
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
% **********************************************************************
% D O C U M E N T A T I O N
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
% Carnot model and function m-files should use a name which gives a 
% hint to the model of function (avoid names like testfunction1.m).
%
% file history
% author list:  eva -> Eva Hennig   ??? bitte Kürzel korrigieren
%               hf -> Bernd Hafner
%
% version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
% 
% version   author  changes                                     date
% 4.1.0     eva     created                                     12jan2010
% 4.1.1     hf      in acm_param_func: (sum(...))^2             13jan2010
%                       changed to: sum((...).^2)
%                   in comment: syntax:   acm_param(M, order)
%                       changed to: syntax:   acm_param(M)
% 4.1.2     hf      in acm_param_func changed to:               20jan2010
%                   sum((Qdot_E-M(:,1)).^2)+sum((Qdot_G-M(:,2)).^2)

if nargin ~= 1
   help acm_param
   return
end

K = fminsearch(@(x) acm_param_func(x, M), [1 1 0.5 0.5 1 1]);

end % of function

% -------------------------------------------------------------------------
%      subfunctions in this file
% -------------------------------------------------------------------------

function f = acm_param_func(x, M)
deltadelta_t = (M(:,4) - x(1).*M(:,5) + x(2).*M(:,3));
Qdot_E = x(3).*deltadelta_t + x(5);
% Qdot_E'
% M(:,1)'
Qdot_G = x(4).*deltadelta_t + x(6);
% Qdot_G'
% M(:,2)'
f = sum((Qdot_E-M(:,1)).^2)+sum((Qdot_G-M(:,2)).^2);
% f = sum(((M(:,4) - x(1).*M(:,5) + x(2).*M(:,3))*(x(3) + x(4)) + x(5) + x(6) - M(:,1) - M(:,2)).^2);
% Version 4.1.0 : f = (sum((M(:,4) - x(1).*M(:,5) + x(2).*M(:,3))*(x(3) + x(4)) + x(5) + x(6) - M(:,1) - M(:,2)))^2;
end