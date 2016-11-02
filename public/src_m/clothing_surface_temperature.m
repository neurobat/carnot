function result = clothing_surface_temperature(m, w, i_cl, v_ar, t_a, t_r, t_cl)
% surface temperature of the clothing - equation (2) of DIN EN ISO 7730:2005
% target function for fminsearch: substract t_cl in order to get a value 
% of zero and use square of original equation
% original name: calculate_t_cl_tf

f_cl = clothing_area_factor(i_cl);
h_c = heat_transfer_clothing(v_ar, t_cl, t_a);
aux1 = 3.96e-8 * f_cl * ((t_cl+273.0).^4 - (t_r+273.0).^4);
aux2 = f_cl * h_c * (t_cl-t_a);
% result = 35.7 - 0.028*(m-w) - i_cl*(aux1 + aux2) - t_cl;
% use square of original equation for fminsearch
result = (35.7 - 0.028*(m-w) - i_cl*(aux1 + aux2) - t_cl).^2;

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
% 6.1.0     hf      created form s-function comfortsfcn.c of aw     23oct2016
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *