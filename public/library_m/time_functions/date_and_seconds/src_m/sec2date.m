function [date] = sec2date (second)
% SEC2DATE transforms seconds in a year to a date in the form
%
% syntax:
%
% sec2date(second)
%
%   Input:  second      0 for 00:00:00 on first january
%                       second can be a vector but not a matrix
% 
%   Output: vector with [year month day hour minute second]
%           the year starts with 1970 on january 1st
%           negative time values refer to years before 1970

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
% author list:  hf -> Bernd Hafner
%               mm -> Marie Michel
% 
% version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
% 
% version   author  changes                                     date
% 1.1.0     hf      created                                     ~1999
% 5.1.0     hf      transfer negative time to a correct date    2012
% 6.2.0     mm/hf   take into account the leap years            25oct2013
% 6.2.1     hf      corrected version for vector input          24mar2014
% 6.2.2     hf      does not accept parts of seconds, use fix   16jan2015

if nargin ~= 1
   help sec2date
   return
end

% [nr, nc] = size(second);

% if nr > 1 && nc > 1
if nnz(size(second) == 1) < 1
    error('Error in sec2date: Input can be a vector but not a matrix')
end

date = datevec(fix(second)/(3600*24) + datenum(1970,1,1));

% if nr > 1                               % reshape to a vector with one row
%     second = second';
%     nc = size(second,2);
% end
% 
% MZ = zeros(nc,1);
% MO = ones(nc,1);
% byear = 1969*MO;                        % beginn in 1969 = 1970-1)
% secondsperyear = (365*24*3600);
% 
% % % remove negative values
% % idx = second < 0;
% % ny1970 = fix(abs(second(idx)./secondsperyear)); % number of year before 1970
% % second(idx) = second(idx) + ny1970.*secondsperyear;
% % % shift start year
% % byear(idx) = byear(idx)-ny1970;
% 
% second = second+secondsperyear;          % add one year to skip negative values
% year = fix((second+1)/secondsperyear);
% date(:,1) = year' + byear;  % year
% 
% % check if current year is leap year
% d4 = mod(date(:,1), 4) == MZ;        % divided by 4 without rest ?
% d100 = mod(date(:,1),100) == MZ;     % divided by 100 without rest ?
% d400 = mod(date(:,1),400) == MZ ;    % devided by 400 without rest ?
% % rule: leap year if diveded by 4 and not by 100, or if devided by 400
% % fl = 1 for leap years, 0 for normal years
% fl = double((d4 & ~d100) | d400);
% 
% % count number of leap years between 1970 and today
% nlp = fix(year/4);                      % !!not for "exception years" like 2100
% 
% s = rem(second,secondsperyear);         % remaining seconds in the year
% s = s-nlp*24*3600;                      % substract number of leap years
% if s < 0                                % if value is negative now
%     date(:,1) = date(:,1)-1;            % year is one year less
%     s = s + secondsperyear;             % seconds are one year more
% end
% 
% date(:,3) = fix(s/(24*3600))+1;         % day of the year
% s = rem(s,24*3600);                     % second of the day
% date(:,4) = fix(s/3600);                % trunctate hour
% s = rem(s,3600);                    
% date(:,5) = fix(s/60);                  % trunctate minute
% date(:,6) = rem(s,60);                              
% 
% % set month
% date(:,2) = MO;                 % January (as an initial guess)
% date(date(:,3)> 31     ,2) =  2*MO(date(:,3)> 31     );
% date(date(:,3)>( 59+fl),2) =  3*MO(date(:,3)>( 59+fl));
% date(date(:,3)>( 90+fl),2) =  4*MO(date(:,3)>( 90+fl));
% date(date(:,3)>(120+fl),2) =  5*MO(date(:,3)>(120+fl));
% date(date(:,3)>(151+fl),2) =  6*MO(date(:,3)>(151+fl));
% date(date(:,3)>(181+fl),2) =  7*MO(date(:,3)>(181+fl));
% date(date(:,3)>(212+fl),2) =  8*MO(date(:,3)>(212+fl));
% date(date(:,3)>(243+fl),2) =  9*MO(date(:,3)>(243+fl));
% date(date(:,3)>(273+fl),2) = 10*MO(date(:,3)>(273+fl));
% date(date(:,3)>(304+fl),2) = 11*MO(date(:,3)>(304+fl));
% date(date(:,3)>(334+fl),2) = 12*MO(date(:,3)>(334+fl));
% 
% % date from day of the year (already correct for January)
% date(date(:,2)== 2,3) = date(date(:,2)== 2,3) -  31;
% date(date(:,2)== 3,3) = date(date(:,2)== 3,3) -  59;
% date(date(:,2)== 4,3) = date(date(:,2)== 4,3) -  90;
% date(date(:,2)== 5,3) = date(date(:,2)== 5,3) - 120;
% date(date(:,2)== 6,3) = date(date(:,2)== 6,3) - 151;
% date(date(:,2)== 7,3) = date(date(:,2)== 7,3) - 181;
% date(date(:,2)== 8,3) = date(date(:,2)== 8,3) - 212;
% date(date(:,2)== 9,3) = date(date(:,2)== 9,3) - 243;
% date(date(:,2)==10,3) = date(date(:,2)==10,3) - 273;
% date(date(:,2)==11,3) = date(date(:,2)==11,3) - 304;
% date(date(:,2)==12,3) = date(date(:,2)==12,3) - 334;
% 
% % correction for leap years
% idx = logical(date(:,2)>2);
% if idx
%     date(idx,3) = date(idx,3) - fl;
% end


% for n = 1:size(second,2)
%     if date(n,3) > 334
%         date(n,2) = 12;                 % december
%         date(n,3) = date(n,3) - 334;
%     elseif date(n,3) > 304
%         date(n,2) = 11;                 % november
%         date(n,3) = date(n,3) - 304;
%     elseif date(n,3) > 273
%         date(n,2) = 10;                 % october
%         date(n,3) = date(n,3) - 273;
%     elseif date(n,3) > 243
%         date(n,2) = 9;
%         date(n,3) = date(n,3) - 243;
%     elseif date(n,3) > 212
%         date(n,2) = 8;
%         date(n,3) = date(n,3) - 212;
%     elseif date(n,3) > 181
%         date(n,2) = 7;
%         date(n,3) = date(n,3) - 181;
%     elseif date(n,3) > 151
%         date(n,2) = 6;
%         date(n,3) = date(n,3) - 151;
%     elseif date(n,3) > 120
%         date(n,2) = 5;
%         date(n,3) = date(n,3) - 120;
%     elseif date(n,3) > 90
%         date(n,2) = 4;
%         date(n,3) = date(n,3) - 90;
%     elseif date(n,3) > 59
%         date(n,2) = 3;
%         date(n,3) = date(n,3) - 59;
%     elseif date(n,3) > 31 
%         date(n,2) = 2;
%         date(n,3) = date(n,3) - 31;
%     else
%         date(n,2) = 1 ;                 % january
%     end
% end

end % function