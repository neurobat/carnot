function ratiograph(month, latitude, longitude, longitude0, ClearIndex, ...
    Skymodel, Greflect, location)
% ratiograph plots a graph to show the ratio of direct radiation on tilted
% surface to that on horizontal surface depending on slope and surface
% azimuth angle.
% Syntax:
% ratiograph(month,lat,long,long0,ClearIndex,Sky,Greflect,[location])
% 
% Input:
%   1. month      : [1..12]
%   2. lat        : gegraphical latitude [-90,90], North positive
%   3. long       : geographical longitude [-180,180], West positive
%   4. long0      : reference longitude (timezone)
%   5. ClearIndex : [0..1], clearness index (ratio of extraterrestrial
%                     radiation to global radiation on horizontal)
%   6. Sky        : Skymodel 1 - isotropic
%                            2 - Hay-Davies
%   7. Greflect   : reflection of ground [0..1]
%                     0.2 for usual ground, 0.3 .. 0.5 for sand or snow
%   8. location   :   optional descriptive name of location
 
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
% Authors   tw -> Thomas Wenzel
%           hf -> Bernd Hafner
% Version author    Changes                                         Date
% 0.01.0  tw        created                                         11apr2000
% 4.1.0   hf        adaptation to Carnot 4                          26jan2009
% 6.1.0   hf        adaptation to Carnot 6                          26jan2009
%
% Copyright (c) 1998-2014 Solar-Institut Juelich, Germany
% All Rights Reserved


% ------------ check the inputs -------------------------------------------
if nargin < 7
   help ratiograph
   return
elseif nargin < 8
   location = '';
elseif nargin > 8
   help ratiograph
   return
end

if month<0 || month>12 || latitude<-90 || latitude > 90 || longitude < -180 ...
      || longitude > 180 || longitude0 < -180 || longitude0 > 180  ...
      || ClearIndex < 0 || ClearIndex > 1 ...
      || Greflect < 0 || Greflect > 1
   disp('error: invalid value in input parameters')
   help ratiograph
   return
end

% ----------------------- program code ------------------------------------

% calculate all ratios of radiation for various slopes and azimuth angles
R = radiationratio(month,latitude,longitude,longitude0,ClearIndex,Skymodel,Greflect);

% set some initial variables
s = size(R);
max_slope = s(1);
max_angle = s(2);
x_factor = 13;
x_move_diagram = -300;
y_move_diagram = +200;
DEG2RAD = pi/180;

% set the classwidth from 40% to max. percentage in steps of 10 or 20%
maxR = (max(max(R))*100);
if maxR > 200
   V_step = 20;
else
   V_step = 10;
end
V = (40:V_step:(max(max(R))*100)+1*V_step)./100;

class_number =  length(V)-1;
M = hsv(round((class_number+1)*1.3)); % create more colors than used
                                      % -> no use of magenta

% plot contour lines and save their coordinates
[con,h] = contour(R,V);
if (h == -9999)         % just to avoid warnings
    disp(h);
end

% plot the title and other description 
diagram_title(month,location,latitude,longitude,ClearIndex,Skymodel,Greflect);

%
%  half circle in last color
%
slope = 90*x_factor;
angle = (0:5:180);
x = sin(angle*DEG2RAD)*slope+x_move_diagram;
y = -cos(angle*DEG2RAD)*slope+y_move_diagram;
for i = 1:length(angle)
   patch(x,y,M(class_number+1,:));
end

%
% iteration over all classes
% draws for all classes a polygon (patch), where the coordinates of the
% polygon are the coordinates of the contour lines in polar coordinates
%


i1 = 1;
percentage = 1:class_number;
for c=1:class_number
   n = round(con(2,i1));
   percentage(c) = con(1,i1);
   %[c percentage(c) n i1]
   
   iangle = con(1,i1+1:i1+n);           % get contour line
   islope = con(2,i1+1:i1+n);
   write_percentage(iangle(1),islope(1),max_slope,max_angle, ...
       percentage(c),x_factor,x_move_diagram,y_move_diagram)
   i1 = i1+n+1;
   
   while i1<length(con) && percentage(c) == con(1,i1)  % eventually get further contour
      n = round(con(2,i1));                           % lines for same percentage
      percentage(c) = con(1,i1);      
      %[c percentage(c) n  i1]      
      write_percentage(con(1,i1+1),con(2,i1+1),max_slope,max_angle, ...
          percentage(c),x_factor,x_move_diagram,y_move_diagram)
      iangle = [iangle con(1,i1+1:i1+n)];
      islope = [islope con(2,i1+1:i1+n)];
      i1 = i1+n+1;         
      [y,I] = sort(iangle);                 % sort ascending by surface_angle
      iangle = y;                           % because different contour lines may be
      islope = islope(I);                   % sorted different
      if latitude<0
         for i=1:length(iangle)/2                   % on southern hemisphere
            temp = iangle(i);                       % sort descending
            iangle(i) = iangle(length(iangle)-i+1);
            iangle(length(iangle)-i+1)= temp;
            temp = islope(i);
            islope(i) = islope(length(islope)-i+1);
            islope(length(islope)-i+1)= temp;
         end
      end
  end % while
  
  if latitude>=0                       % on northern hemisphere
     while (iangle(1)>=2)               % add angles until 0° to contour line
        iangle = [ceil(iangle(1))-1 iangle];
        islope = [max_slope islope];
     end
  else                                  % on southern hemisphere
     if iangle(1)~=1 || iangle(length(iangle))~=max_angle %islope(length(islope))<max_slope
       while (iangle(1)<=max_angle-1)  % add angles until 180° to contour line
          iangle = [ floor(iangle(1))+1 iangle];
          islope = [ max_slope islope];
       end
     end
  end
  i = 0;
  
  while i<length(iangle)-1             % fill empty spaces (>1°) 
     i = i+1;
     if (iangle(i+1)-iangle(i))>1
  %      [i iangle(i+1) iangle(i)]
        iangle = [iangle(1:i) iangle(i)+1 iangle(i+1:length(iangle))];
        islope = [islope(1:i) max_slope islope(i+1:length(islope))];
     elseif (iangle(i)-iangle(i+1))>1
  %      [i iangle(i) iangle(i+1) iangle(i)-iangle(i+1)]
        iangle = [iangle(1:i) iangle(i)-1 iangle(i+1:length(iangle))];
        islope = [islope(1:i) max_slope islope(i+1:length(islope))];
     end
  end
  
  % convert coordinates of one contour line from
  % cartesic coordinates to polar coordinates
  a = sin(180/(max_angle-1)*(iangle-1)*DEG2RAD);
  b = -cos(180/(max_angle-1)*(iangle-1)*DEG2RAD);
  slope = 90/(max_slope-1)*(islope-1)*x_factor;
  x = a.*slope+x_move_diagram;         % save polar coordinates in vector
  y = b.*slope+y_move_diagram;
  
  patch(x,y,M(class_number-c+1,:))    % plot filled polygon  
%  xx = input('xx')	
end

%
% find max. R and plot a filled black circle
%

for islope=1:max_slope
    for iangle=1:max_angle
        if R(islope,iangle)*100 == maxR
            a = sin(180/(max_angle-1)*(iangle-1)*DEG2RAD);
            b = -cos(180/(max_angle-1)*(iangle-1)*DEG2RAD);
            slope = 90/(max_slope-1)*(islope-1)*x_factor;
            x = a.*slope+x_move_diagram;         % save polar coordinates in vector
            y = b.*slope+y_move_diagram;
            s = sprintf('%.0f%%',R(islope,iangle)*100);
            text(x-150,y,s)
            % circle coordinates
            x = x+[0    50    87   100    87    50     0   -50   -87  -100   -87   -50 0]/15;
            y = y+[   100    87    50     0   -50   -87  -100   -87   -50     0    50    87 100]/15;
            patch(x,y,'k')
        end
    end
end

         


%
% plot colorbar with percentage
%
a = [1 1 0 0];
b = [1 0 0 1];
x_bar = 140;                 % width
y_bar = 1800/class_number;   % height
for c=1:class_number+1
   x = a*x_bar-900;
   y = b*y_bar+c*y_bar-1000;
   patch(x,y,M(class_number-c+2,:))
   if (c>1 && c<class_number+1)
      s = sprintf('%.0f-%.0f%%',percentage(c-1)*100,percentage(c)*100);
   elseif c==1
      s = sprintf('< %.0f%%',percentage(c)*100);
   else
      s = sprintf('> %.0f%%',percentage(c-1)*100);
   end       
%   [c class_number-c+2]
   text(x(1)+20,(y(1)+y(2))/2,s)
end

%
% plot white wiremesh
%   
white_wire(x_factor,latitude,x_move_diagram,y_move_diagram)
   

%colorbar
axis off
hold off
set(gcf,'PaperPosition',[.25 .25 8 10.5]) % Figure / File / PageSetup / PaperPosition = Fill
end % function ratiograph



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%
%  write_percentage in diagramm
%
%
%
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function write_percentage(iangle,islope,max_slope,max_angle, ...
    percentage,x_factor,x_move_diagram,y_move_diagram)
   %
   % write percentage in diagram
   %
   DEG2RAD = pi/180;
   a = sin(180/(max_angle-1)*(iangle-1)*DEG2RAD);
   b = -cos(180/(max_angle-1)*(iangle-1)*DEG2RAD);
   if a<1e-5
      x = -10*x_factor+x_move_diagram;
      slope = 90/(max_slope-1)*(islope-1)*x_factor;   
   else
      slope = 90/(max_slope-1)*(islope-1)*x_factor+30;   
      x = a*slope+x_move_diagram;
   end
   
   y = b*slope+y_move_diagram;
   s = sprintf('%.0f%%',percentage*100);
   text(x,y,s);
end % function write_percentage



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%
%  diagram_title
%
%
%
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function diagram_title(month,location,latitude,longitude,ClearIndex,Skymodel,Greflect)

% LineWidth1 = .1;
% LineWidth2 = .75;
FontSize2 = 12;
% FontSize3 = 18;
% FontSizeTitle = 18;

%
%  title of diagramm
%
plot([-1000 1000],[1600 1600],'k');
hold on

switch month
   case 0
      sm = 'of one year';
   case 1
      sm = 'in January';
   case 2
      sm = 'in February';
   case 3
      sm = 'in March';
   case 4
      sm = 'in April';
   case 5
      sm = 'in May';
   case 6
      sm = 'in June';
   case 7
      sm = 'in July';
   case 8
      sm = 'in August';
   case 9
      sm = 'in September';
   case 10
      sm = 'in October';
   case 11
      sm = 'in November';
   case 12
      sm = 'in December';
end
s = sprintf('Global solar radiation on tilted surface %s',sm);
% text(-1000,-1700,s,'Fontsize',FontSize2);
text(-1000,1700,s,'Fontsize',FontSize2);
% text(-1000,1700,'ratio of radiation','Fontsize',FontSizeTitle);
if exist('sij-logo200x.jpg','file')
    [C,map] = imread('sij-logo200x.jpg','JPG');
    image(800,1630,C);
    colormap(map);
end

%
%  describtive texts below diagram
%
plot([-800 800],[-1200 -1200],'k');

s = sprintf('location : %s',location);          % location
text(-1000,-1300,s,'Fontsize',FontSize2);

if (latitude<0)                                      % latitude
   s = sprintf('latitude : %.2f° S',-latitude); 
else
   s = sprintf('latitude : %.2f° N',latitude);
end
text(-1000,-1450,s,'Fontsize',FontSize2);

if (longitude<0)                                     % longitude
   s = sprintf('longitude : %.2f° E',-longitude);
else
   s = sprintf('longitude : %.2f° W',longitude);
end
text(-1000,-1600,s,'Fontsize',FontSize2);


s = sprintf('index of clearness : %.2f',ClearIndex);          % ClearIndex
text(000,-1300,s,'Fontsize',FontSize2);
if (Skymodel==1)                                            % SkyModel
   s = sprintf('sky model : isotropic sky');
elseif Skymodel==2
   s = sprintf('sky model : Hay-Davies');
else
   s = sprintf('sky model : no model');
end
text(000,-1450,s,'Fontsize',FontSize2);
s = sprintf('reflection of ground : %.2f',Greflect);            % Greflect
text(000,-1600,s,'Fontsize',FontSize2);

text(400,-1800,'© Solar-Institut Jülich, 2000') % copyright

end % function diagram_title




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% draws a white wiremesh over the diagram
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function white_wire(x_factor,latitude,x_move_diagram,y_move_diagram)

DEG2RAD = pi/180;

%
% plot white rays
%
slope = 20:10:90;
for angle=0:10:180
    x = sin(angle*DEG2RAD)*slope*x_factor+x_move_diagram;
    y = -cos(angle*DEG2RAD)*slope*x_factor+y_move_diagram;
    plot(x,y,'w');
end

slope = 10:10:90;
for angle=0:30:180
    x = sin(angle*DEG2RAD)*slope*x_factor+x_move_diagram;
    y = -cos(angle*DEG2RAD)*slope*x_factor+y_move_diagram;
    plot(x,y,'w');
end

slope = 0:10:10;
for angle = 0:90:180
    x = sin(angle*DEG2RAD)*slope*x_factor+x_move_diagram;
    y = -cos(angle*DEG2RAD)*slope*x_factor+y_move_diagram;
    plot(x,y,'w');
end

%
% plot white circle
%
for slope=10:10:90
   clear x y z
   i = 0;
   for angle=0:5:180
      i = i+1;
      x(i) = sin(angle*DEG2RAD)*slope*x_factor+x_move_diagram;
      y(i) = -cos(angle*DEG2RAD)*slope*x_factor+y_move_diagram;
   end
   plot(x,y,'w');
end

%
%  print slope [°] on left margin
%
for slope = 0:10:90
   x = -10*x_factor+x_move_diagram;
   y = slope*x_factor*sign(latitude)+y_move_diagram;
   s = sprintf('%2d°',slope);
   text(x,y,s);
end

%
% plot cardinal points in diagram
%
   angle = 0;
   direction_radius = 100*x_factor;
   a = sin(angle*DEG2RAD)*direction_radius+x_move_diagram;
   b = -cos(angle*DEG2RAD)*direction_radius+y_move_diagram;
   text(a,b,'S');
   angle = 45;
   a = sin(angle*DEG2RAD)*direction_radius+x_move_diagram;
   b = -cos(angle*DEG2RAD)*direction_radius+y_move_diagram;
   text(a,b,'SO/SW');
   angle = 90;
   a = sin(angle*DEG2RAD)*direction_radius+x_move_diagram;
   b = -cos(angle*DEG2RAD)*direction_radius+y_move_diagram;
   text(a,b,'O/W');
   angle = 135;
   a = sin(angle*DEG2RAD)*direction_radius+x_move_diagram;
   b = -cos(angle*DEG2RAD)*direction_radius+y_move_diagram;
   text(a,b,'NO/NW');
   angle = 180;
   a = sin(angle*DEG2RAD)*direction_radius+x_move_diagram;
   b = -cos(angle*DEG2RAD)*direction_radius+y_move_diagram;
   text(a,b,'N');
end % function white_wire
