function temp_conv = unitconv_temperature(init_unit, final_unit, value)
% This m-function converts a temperature form a unit to another.
% 
% Syntax : temp_conv = conv_temperatur(init_unit, final_unit, value)
%   where :
%          init_unit  is the initial unit
%          final_unit is the final unit
%          value      is the temperature to convert
% 
% init_unit and final_unit should be one of the following characters :
%  - 'C' : Celsius
%  - 'K' : Kelvin
%  - 'F' : Farenheit
% 
% Warning : a difference of temperature doesn't need to be convert from
% Kelvin to Celsius.

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
% Version  Author              Changes                             Date
% 0.1.0    Gaelle Faure        created                            13jan11
% 6.1.0    Bernd Hafner        check number of input arguments    27nov2014

if nargin ~= 3              % check for correct input
    help unitconv_temperatur
    error('unitconv_temperatur: number of input arguments must be 3')
end

if (strcmp(init_unit,'C'))
    %     conversion : C -> K
    temp_conv = value + 273.15;
elseif (strcmp(init_unit,'F'))
    %     conversion : F -> K
    temp_conv = (value + 459.67) * 5/9;
elseif (strcmp(init_unit,'K'))
    temp_conv = value;
else
    error('The initial unit must be : C, K or F.');
end

% Here, temp_conv is in Kelvins

if (strcmp(final_unit,'C'))
    %     conversion : K -> C
    temp_conv = temp_conv - 273.15;
elseif (strcmp(final_unit,'F'))
    %     conversion : K -> F
    temp_conv = (temp_conv * 9/5) - 459.67;
elseif (~strcmp(final_unit,'K'))
    error('The final unit must be : C, K or F.');
end

end