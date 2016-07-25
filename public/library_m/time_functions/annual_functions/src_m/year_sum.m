function erg = year_sum(data,timeclass)
% This function calculates the sum and average of a given weather data 
% matrix for a specified time interval.
% The first column from the input matrix has to be the time in seconds.
%
% syntax:
% 
% [matrix_sum, matrix_mean] = year_sum(data,timeclass)

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
% timeclass = 1 : year
%             2 : monthly
%             3 : weekly
%             4 : daily
%             5 : hourly

% 22.05.2001 Th. Wenzel
% 01jan2008  Bernd Hafner: help year_average changed to year_sum

if nargin ~= 2
   help year_sum
   return
end


if timeclass==1             % one class = year
   classnumber = 1;
   limit = 9e99;
elseif timeclass==2         % 12 classes = 12 monthes
   classnumber = 12;
   limit =  [2678400 5097600 7776000 10368000 13046400 15638400 ...
             18316800 20995200 23587200 26265600 28857600 9e99];
elseif timeclass==3         % 53 classes = 52.14 weeks
   classnumber = 53;
   limit = (1:classnumber)*7*86400;
   limit(classnumber) = 9e99;        % all remaining values in last class
elseif timeclass==4         % 366 classes = 365-366 days
   classnumber = 365;
   limit = (1:classnumber)*86400;
   limit(classnumber) = 9e99;        % all remaining values in last class
elseif timeclass==5         % 366*24 classes = 8784 hours
   classnumber = 366*24;
   limit = (1:classnumber)*3600;
   limit(classnumber) = 9e99;        % all remaining values in last class
else
   help year_sum
   return
end

delta_time = data(2:length(data),1)-data(1:length(data)-1,1);
delta_time(length(delta_time)+1) = median(delta_time);
m_sum = zeros(classnumber, size(data,2)-1);
sum_time = zeros(classnumber);
m_mean = m_sum;

limit_before = 0;

for class=1:classnumber
    p = logical(data(:,1) >= limit_before & data(:,1) < limit(class));
    m_sum(class,:) = (data(p,2:end)'*delta_time(p))';
    sum_time(class) = sum(delta_time(p));
    m_mean(class,:) = m_sum(class,:)./sum_time(class);
    limit_before = limit(class);
end

erg = [m_sum, m_mean];

end % of function