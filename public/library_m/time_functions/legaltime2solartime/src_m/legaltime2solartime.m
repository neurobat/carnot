function erg = legaltime2solartime(time, longitude, longitudenull)
% FUNCTION legaltime2solartime : Calculate solar time of a location on the
% base of the legal time.
%
% SYNTAX:
%
%  solartime = legaltime2solartime(time,longitude,longitudenull)
%
%  INPUT
%  1. time          :   official time [s]
%  2. longitude     :   [-180,180] , west positive
%  3. longitudenull :   reference longitude (timezone)
%					
%  OUTPUT
%  1. solartime          :   solar time [s]
% 
% Literature: Duffie, Beckmann: Solar Engineering of Thermal Processes, 2006
% see also: solartime2legaltime

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
% ***********************************************************************
% D O C U M E N T A T I O N
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
% author list:      hf -> Bernd Hafner
%                   tw -> Thomas Wenzel
%
% version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
%
% Version  Author  Changes                                     Date
% 2.1.0    tw      created                                     31mar2000
% 5.1.0    hf      calculation moved to carlib                 01jan2009
%
% Copyright (c) 2000 Solar-Institut Juelich, Germany
%
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

if nargin ~= 3
   help legaltime2solartime
   return
end

erg = calcsolar(time, 0, longitude, longitudenull, 3) ...   % solar time of the day
    + 24.*3600.*floor(time./24./3600);                          % add number of days

end % of function