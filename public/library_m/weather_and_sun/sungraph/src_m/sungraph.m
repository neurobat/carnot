function sungraph(lat,long,long0,location)
% SUNGRAPH plots a position diagram of the sun.
%
% syntax:
%
%   sungraph(lat, long, long0, ['location'])
%
% lat      : latitude  [ -90; 90], north positive
% long     : longitude [-180;180], west positive
% long0    : reference longitude (timezone)
% location : optional descriptive string

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
% Carnot model and function m-files should use a name which gives a 
% hint to the model of function (avoid names like testfunction1.m).
%
%  Version   Author         Changes                             Date
%  0.1       Thomas Wenzel  created                             14mar2000
%  3.0       Bernd Hafner   blue dotted line removed            01jan2009
%  4.0       hf             include time equation               06jan2009
%


% check number of input arguments
if nargin < 3
    help sungraph
    error('sungraph: 3 or 4 input arguments required')
elseif nargin < 4        % when location is missing, set variable empty
    location='';
elseif nargin > 4
    help sungraph
    error('sungraph: 3 or 4 input arguments required')
end

LineWidth1 = 0.1;
LineWidth2 = 0.75;
FontSize2 = 12;
FontSize3 = 18;
FontSizeTitle = 18;

%
%  basic plot of diagram
%
j = 1;
X = ones(730);
Y = X;
for z = 0:10:90                        % plot circles
   for a = 0:5:360
      X(j) = sin((a)/180*pi)*z*10;
      Y(j) = cos((a)/180*pi)*z*10;
      j = j+1;
   end
end
plot(X,Y,'k','LineWidth',LineWidth1);
hold on
clear X Y
for a=0:10:359                       % plot azimuth lines all 10°
   X(1) = sin(a/180*pi)*100;
   Y(1) = cos(a/180*pi)*100;
   X(2) = sin(a/180*pi)*z*10;
   Y(2) = cos(a/180*pi)*z*10;
   plot(X,Y,'k','LineWidth',LineWidth1)
end
for a=0:90:359                       % plot in inner circle only 4 azimuth lines
   X(1) = sin(a/180*pi)*0;
   Y(1) = cos(a/180*pi)*0;
   X(2) = sin(a/180*pi)*z*10;
   Y(2) = cos(a/180*pi)*z*10;
   plot(X,Y,'k','LineWidth',LineWidth1)
end

for z=10:10:80                              % write sun angle [°]
   s = sprintf('%d°',90-z);
   text(-20,z*10,s)
end
text(-100,880,'sun angle');

text(-10,1000,'N','Fontsize',FontSize3);    % write cardinal points
text(-10,-1000,'S','Fontsize',FontSize3);
text(950,0,'E','Fontsize',FontSize3);
text(-1000,0,'W','Fontsize',FontSize3);

%
%  title of diagramm
%

text(-1000,1200,'solar position diagram','Fontsize',FontSizeTitle);
% [C,map] = imread('sij-logo200x.jpg','JPG');
% image(800,1130,C);
% colormap(map);
plot([-1000 1000],[1100 1100],'k');

%
%  describtive texts below diagram
%

plot([-800 800],[-1200 -1200],'k');

s = sprintf('location : %s',location);          % location
text(-1000,-1300,s,'Fontsize',FontSize2);

if (lat<0)                                      % latitude
   s = sprintf('latitude : %.2f° S',-lat); 
else
   s = sprintf('latitude : %.2f° N',lat);
end
text(-1000,-1450,s,'Fontsize',FontSize2);

if (long<0)                                     % longitude
   s = sprintf('longitude : %.2f° E',-long);
else
   s = sprintf('longitude : %.2f° W',long);
end
text(-1000,-1600,s,'Fontsize',FontSize2);

% text(400,-1600,'© Solar-Institut Jülich, 2000') % copyright

if long0<0                                      % timezone
   sign = '+';
else
   sign = '-';
end
hour = round(abs(long0)/15);
s = sprintf('time = GMT %c%d h',sign,hour);
text(600,-1000,s,'Fontsize',FontSize2);

s = sprintf('first half of the year:');         % kind of lines
text(-1000,-1000,s);
plot([-500 -250],[-990 -990],'-r');
plot([-500 -250],[-1010 -1010],'-b');
s = sprintf('second half of the year:');
text(-1000,-1100,s);
plot([-500 -250],[-1090 -1090],':r');
plot((-500:50:-250),-1110*ones(1,length((-500:50:-250))), ...
    'LineWidth',LineWidth2,'LineStyle','none','Marker','.')
axis([-1000,1000,-1600,1250]);
   
%
% set dates for ploting
%
number_of_dates = 13;
datum(1) = date2sec([1,5,0,0,0]);
datum(2) = date2sec([2,4,0,0,0]);
datum(3) = date2sec([3,6,0,0,0]);
datum(4) = date2sec([4,5,0,0,0]);
datum(5) = date2sec([5,5,0,0,0]);
datum(6) = date2sec([6,4,0,0,0]);
datum(7) = date2sec([6,21,0,0,0]);
datum(8) = date2sec([7,21,0,0,0]);
datum(9) = date2sec([8,20,0,0,0]);
datum(10) = date2sec([9,19,0,0,0]);
datum(11) = date2sec([10,19,0,0,0]);
datum(12) = date2sec([11,18,0,0,0]);
datum(13) = date2sec([12,21,0,0,0]);

%clear X1 Y1 x

%
% save sun graphs for specified dates during a day in vector X1,Y1
%

length1 = 1:number_of_dates;    % preallocation for length1
X1 = zeros(number_of_dates, 48);  % preallocation
Y1 = X1;

for d = 1:number_of_dates
    j = 1;
    fertig = 0;
    t = datum(d);
    while (t < datum(d)+24*3600) && (fertig == 0)
        [decl,sunangle,zenith,azimuth,hourangle] = sunangles(t,lat,long,long0);
        %while zenith is larger than 90°, find where graph enters/leaves diagramm at 90°
        if (zenith >= 90)
            if t < datum(d)+12*3600                         % before sunrise
                while zenith>=90                            % large steps until after
                    t = t+3600;                             % sunrise
                    [decl,sunangle,zenith,azimuth,hourangle] = ...
                        sunangles(t,lat,long,long0);
                end        
                while zenith < 90                           % small steps back until
                    t = t-300;                              % before sunrise
                    [decl,sunangle,zenith,azimuth,hourangle] = ...
                        sunangles(t,lat,long,long0);
                end
            elseif t > datum(d)+12*3600                     % after sunset
                while zenith >= 90                          % small steps back until
                    t = t-300;                              % sunset
                    [decl,sunangle,zenith,azimuth,hourangle] = ...
                        sunangles(t,lat,long,long0);
                end        
                fertig = 1;
            end   
        end
     
        a = azimuth+180;  % south: 0° -> 180°
        X1(d,j) = sin(a/180*pi)*zenith*10;  % radian coordinates to cartesian
        Y1(d,j) = cos(a/180*pi)*zenith*10;
        j = j+1;
        t = t+1800;
    end
    length1(d) = j-1;
end

%
% set parameter for hourly diagram
%
hour_start = 5;
hour_end = 20;
step_of_days = 6;

%
% save sun graphs for specified hours during a year to vectos X2,Y2,X3,Y3
length2 = hour_start:hour_end;  % prealloctation for length2
length3 = length2;              % prealloctation for length3
X2 = zeros(length(length2),length(1:step_of_days:182));
Y2 = X2;
X3 = zeros(length(length2),length(183:step_of_days:365));
Y3 = X2;
for h = hour_start:hour_end
    %
    % first half of year: X2,Y2
    %
    j = 1;
    for d=1:step_of_days:182
        t = d*24*3600+h*3600;
        [decl,sunangle,zenith,azimuth,hourangle] = sunangles(t,lat,long,long0);
        a = azimuth+180;  % south : 0° -> 180°
        if (zenith<90)
            X2(h,j) = sin(a/180*pi)*zenith*10; % radian coordinates to cartesian
            Y2(h,j) = cos(a/180*pi)*zenith*10;
            j = j+1;
        end  
    end
    length2(h)=j-1;
   
    %
    % second half of year: X3,Y3
    %
    j = 1;
    for d=183:step_of_days:365
        t = d*24*3600+h*3600;
        %      x  = radiationdivision(t,100,lat,long,long0);
        [decl,sunangle,zenith,azimuth,hourangle] = sunangles(t,lat,long,long0);
        a = azimuth+180;  % south : 0° -> 180°C      
        if (zenith<90)
            X3(h,j) = sin(a/180*pi)*zenith*10; % radian coordinates to cartesian
            Y3(h,j) = cos(a/180*pi)*zenith*10;
            j = j+1;
        end  
    end
    length3(h)=j-1;
end   % for h=hour_start:hour_end

%
% plot saved data 
%
for d=1:number_of_dates
    if d<7                                              % data in first half of year solid
        plot(X1(d,1:length1(d)),Y1(d,1:length1(d)),'-r','LineWidth',LineWidth2);      
        dat = sec2date(datum(d));
        s = sprintf('%d.%d.',dat(3),dat(2));
        if (Y1(d,length1(d)) > 0)
            text(X1(d,length1(d))-100,Y1(d,length1(d))*1.1,s);
        else 
            text(X1(d,length1(d))-100,Y1(d,length1(d)),s);
        end
    else                                                % data in second half of year dashed
        plot(X1(d,1:length1(d)),Y1(d,1:length1(d)),':r','LineWidth',LineWidth2);
        dat = sec2date(datum(d));
        s = sprintf('%d.%d.',dat(3),dat(2));
        text(X1(d,1)+20,Y1(d,1),s);
    end
end

for h=hour_start:hour_end                              % plot hourly data
    if length2(h)>0
        plot(X2(h,1:length2(h)),Y2(h,1:length2(h)),'LineWidth',LineWidth2)
    end
    if length3(h)>0   
        plot(X3(h,1:length3(h)),Y3(h,1:length3(h)),'LineWidth', ...
            LineWidth2,'LineStyle','none','Marker','.')
        s = sprintf('%d:00',h);
        text(X3(h,1),Y3(h,1),s);
    end  
end

axis off
hold off
set(gcf,'PaperPosition',[.25 .25 8 10.5]) % Figure / File / PageSetup / PaperPosition = Fill

if hourangle < -999
    disp(' ') % just to avoid warnings
end

end % of function