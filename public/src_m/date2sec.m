function [second] = date2sec(t)
% DATE2SEC transforms a date to seconds of year
%
% syntax:
%
% date2sec(date)
%
% second 0 is 00:00:00 on first of january in the year 1970
% date in vector [[year] month day hour minute second]
%
% The year as first input is optional. If not given, the year is counted
% with 0 s. If given, the counting of the year starts with 1970.
% The input may be a matrix where each row is interpreted as indvidual date
% vector.

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
% author list:  gf -> Gaelle Faure
%               hf -> Bernd Hafner
%               mm -> Marie Michel
% 
% version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
%
% Version  Author   Changes                                     Date
% 1.1.0    hf       created                                     1999
% 5.2.0    gf       replace length(t) by size(t,2)              11jan2011
%                   to vectorialize the function
% 5.2.1    hf       year starts in 1970                         30aug2013
% 6.2.2    mm       take into account the leap years            25oct2013
% **********************************************************************+

% -- check for correct number of inputs -- %
if nargin ~= 1
    help date2sec
    error('date2sec: 1 input argument required')
end

if size(t,2) > 6 || size(t,2) < 5
    help date2sec
    error('date2sec: input vector must have 5 or 6 entries')
end

if size(t,2) == 5
    t = [1970 t];
end
second = round((datenum(t) - datenum([1970,1,1]))*24*3600);

% % -- initialize variables -- %
% nr = size(t,1);
% MZ = zeros(nr,1);
% cyear = 1970*ones(nr,1); % year number after 1970 (1970 is 0)
% nlp = MZ;   % nlp=number of leap years before current year
% 
% % -- year valid only from 1970 -- %
% if size(t,2) == 6       % set year if required
%     cyear = t(:,1);     
%     t = t(:,2:end);     % skip year in input matrix
% end
% % cyear(cyear<1970) = 1970;  % years anterior to 1970 are set to 1970
% % check if current year is leap year
% d4 = mod(cyear, 4) == MZ;        % divided by 4 without rest ?
% d100 = mod(cyear,100) == MZ;     % divided by 100 without rest ?
% d400 = mod(cyear,400) == MZ ;    % devided by 400 without rest ?
% % rule: leap year if diveded by 4 and not by 100, or if devided by 400
% % fl = 1 for leap years, 0 for normal years
% fl = (d4 & ~d100) | d400;
% % calculate number of leap years before current year (and after 1970)
% nlp = fix((abs(cyear-1970) + 1)/4);  % valid until 2400 only..
% 
% year = cyear - 1970;    % 1970 is a normal year (fl=0 and nlp=0)
% day = t(:,2) - 1;       % day number in the current year (01.01 is 0)
% 
% % no need to check for jan, start with feb 
% day(t(:,1) >  1) = day(t(:,1) >  1)+31;
% day(t(:,1) >  2) = day(t(:,1) >  2)+28+fl(t(:,1) > 2);
% day(t(:,1) >  3) = day(t(:,1) >  3)+31;
% day(t(:,1) >  4) = day(t(:,1) >  4)+30;
% day(t(:,1) >  5) = day(t(:,1) >  5)+31;
% day(t(:,1) >  6) = day(t(:,1) >  6)+30;
% day(t(:,1) >  7) = day(t(:,1) >  7)+31;
% day(t(:,1) >  8) = day(t(:,1) >  8)+31;
% day(t(:,1) >  9) = day(t(:,1) >  9)+30;
% day(t(:,1) > 10) = day(t(:,1) > 10)+31;
% day(t(:,1) > 11) = day(t(:,1) > 11)+30;
% 
% second = (365*3600*24*year + nlp*3600*24) + ((day*24 + t(:,3))*60 + t(:,4))*60 + t(:,5);

end % of function