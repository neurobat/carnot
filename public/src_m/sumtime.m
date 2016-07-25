function erg=sumtime(YEAR,MONTH,DAY,HOUR,MINUTE,SECOND)
% sumtime(YEAR,MONTH,DAY,HOUR,MINUTE,SECOND) calculates for a given date 
% the sum of seconds, minutes, in the year.
% example: 02 January 1999  12:00:00  
%            input vector : [99 01 02 12 00 00]
%            output vector: [0.0041 0.048 1.5 36 2160 129600]
%            
%            year   :      0.0041
%            month  :      0.048
%            day    :      1.5
%            hour   :     36
%            minute :   2160            
%            second : 129600
%
%   ATTENTION: The year may be given with 2 digits, so the program calculates every
%              year which is divisible by four as a leap year.
%              Therefore errors are made in ..., 1900, 2100, 2200, ... but not in 2000.

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
%   
%   Th. Wenzel, 10.1.2000
%
    year = floor (YEAR+0.5);
    day = 0;
    
    for month=1:MONTH-1
      if ( ( month<=7 && mod(month,2)>0) || (month>=8 && mod(month,2)==0) )
         day = day+31;
      elseif (month==2 && mod(year,4)==0)
         day = day+29;
      elseif (month==2 && mod(year,4)~=0)
         day = day+28;
      else
         day = day+30;
      end
    end
         
    second = (((day+DAY-1)*24+HOUR)*60+MINUTE)*60+SECOND;
    SECOND_SUM = second;
    MINUTE_SUM = (second/60);
    HOUR_SUM   = (second/3600);
    DAY_SUM    = (second/86400);

    month = floor( MONTH+0.5);
     
    if ( ( month<=7 && mod(month,2)>0) || (month>=8 && mod(month,2)==0) )
         this_month = 31;
    elseif (month==2 && mod(year,4)==0)
         this_month = 29;
    elseif (month==2 && mod(year,4)~=0)
         this_month = 28;
    else
         this_month = 30;
    end
       
    this_month = this_month*86400;

    MONTH_SUM  = MONTH -1 + ((((DAY-1)*24+HOUR)*60+MINUTE)*60+SECOND)/this_month;
    
    if (mod(year,4)>0)
      YEAR_SUM = second/31536000;
   else
      YEAR_SUM = second/31622400;   
    end

erg(1) = YEAR_SUM;
erg(2) = MONTH_SUM;
erg(3) = DAY_SUM;
erg(4) = HOUR_SUM;
erg(5) = MINUTE_SUM;
erg(6) = SECOND_SUM;
