% timmecomment creates the timecomment for weather data
% In the carnot weather date format, the second column is a comment line
% for easier reading the time rows.
% The format is YYYYMMDDHHMM
%
% Output: the data will be stored as a text in the variable 'wcomment'
% See wformat.txt for more details.

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
% author list:      hf -> Bernd Hafner
%
% version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
%
% Version  Author  Changes                                      Date
% 1.1.0    hf      created                                      around 1999
% 6.1.0    hf      update documentation                         21feb2015
%
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *


hour = ['00.5'; '01.5'; '02.5'; '03.5'; '04.5'; '05.5'; '06.5'; ...
      '07.5'; '08.5'; '09.5'; '10.5'; '11.5'; '12.5'; '13.5'; ...
      '14.5'; '15.5'; '16.5'; '17.5'; '18.5'; '19.5'; '20.5'; ...
      '21.5'; '22.5'; '23.5'];

day = ['01'; '02'; '03'; '04'; '05'; '06'; '07'; '08'; '09'; '10'; '11'; '12'; '13'; ...
      '14'; '15'; '16'; '17'; '18'; '19'; '20'; '21'; '22'; '23'; '24'; '25'; ...
      '26'; '27'; '28'; '29'; '30'; '31'];

month = ['01'; '02'; '03'; '04'; '05'; '06'; '07'; '08'; '09'; '10'; '11'; '12'];

wcomment = ones(8762,12)*'0';
i = 1;

for m = 1:12
   if m == 1 || m == 3 || m == 5 || m == 7 || m == 8 || m == 10 || m == 12
      for d = 1:31
         for h = 1:24
            i = i+1;
            wcomment(i,:) = ['1989' month(m,:) day(d,:) hour(h,:)];
         end
      end
   end
   if m == 4 || m == 6 || m == 9 || m == 11
      for d = 1:30
         for h = 1:24
            i = i+1;
            wcomment(i,:) = ['1989' month(m,:) day(d,:) hour(h,:)];
         end
      end
   end
   if m == 2
      for d = 1:28
         for h = 1:24
            i = i+1;
            wcomment(i,:) = ['1989' month(m,:) day(d,:) hour(h,:)];
         end
      end
   end
end

wcomment(1,:) = wcomment(2,:);
wcomment(1,12) = '0';

wcomment(8762,:) = wcomment(8761,:);
wcomment(8762,10:12) = '4.0';
wcomment=char(wcomment);