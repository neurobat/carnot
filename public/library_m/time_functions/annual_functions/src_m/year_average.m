function erg = year_average(data,timeclass)
% Function year_average calculates the average of a given weather data 
% matrix for a specified time interval.
% The first column from the input matrix has to be the time in seconds.
%
% syntax:     mat2 = year_average(data,timeclass)

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


if  nargin ~= 2
   help year_average
   return
end

switch timeclass
    case 1                  % one class = year
        classnumber = 1;
        limit = 9e99;
    
    case 2                  % 12 classes = 12 monthes
        classnumber = 12;
        limit =  [2678400 5097600 7776000 10368000 13046400 15638400 ...
             18316800 20995200 23587200 26265600 28857600 9e99];

    case 3                  % 53 classes = 52.14 weeks
        classnumber = 53;
        limit = (1:classnumber)*7*86400;
        limit(classnumber) = 9e99;        % all remaining values in last class
    
    case 4                  % 366 classes = 365-366 days
        classnumber = 366;
        limit = (1:classnumber)*86400;
        limit(classnumber) = 9e99;        % all remaining values in last class

    case 5         % 366*24 classes = 8784 hours
        classnumber = 366*24;
        limit = (1:classnumber)*3600;
        limit(classnumber) = 9e99;        % all remaining values in last class
    
    otherwise
        help year_average
        return
end

class = 1;
number(1:classnumber+1) = 0;
width = size(data);

if width(2) < 2
    disp('Error in year_average: column 1 of the input matrix must be the time')
    disp('                       column 2 and further columns contain the data')
    return
end

summation(1:classnumber, 1:(width(2)-1)) = 0;
erg = summation;                                % just to init the size

% time = cputime

for i = 1:length(data)
    %    if mod(i,1000) == 0
    %       [i i/length(data)*100]
    %    end
   
   while data(i,1)>limit(class)      % when limit of actual class reached
      class = class+1;               % find next class
   end
   number(class) = number(class)+1;   
   summation(class,:) = summation(class,:) + data(i,2:end);
end

% time = cputime-time  

for i = 1:class                     % calculated averages
    %    if mod(i,100)==0
    %       [i i/class*100]
    %    end
   erg(i,:) = summation(i,:)./number(i);
end

end % of function