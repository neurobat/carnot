function CarnotCallbacks_create_mdot(action,pathname)
% This functions opens a window to input the distribution of the water consumption.
% The distribution can vary during a year and also varies during a day.
% This functions is usually called from the mask of the create_mdot subsystem.
% Then the function reads the values in this subsystems and writes the values
% when the window is closed
%
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
% *************************************************************************
% D O C U M E N T A T I O N
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
% author list:      tw -> Thomas Wenzel
%                   hf -> Bernd Hafner
%
% version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
%
% Version   Author  Changes                                     Date
% 1.1.0     tw      created                                     around2000
% 6.1.0     hf      changed name "loadprofile" to new           27nov2014
%                   name "Carnot_create_mdot_Callbacks"
% 6.1.1     hf      help text modified ("loadprofile" replaced  03jan2015
%                   by "Carnot_create_mdot_Callbacks")
% 6.1.2     hf      name changed to CarnotCallbacks_create_mdot 21feb2015
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

if nargin<1
   disp('CarnotCallbacks_create_mdot: needs at least one argument')
   help CarnotCallbacks_create_mdot
%   action='initialize';   
elseif strcmp(action,'initialize') && nargin<2
      disp('when first argument is initialize, the second argument has to be the pathname')
elseif strcmp(action,'initialize'),
      
   mat_month = 'January   100|February   98|March      99.5|April     100.4|May       102|June      105|July      108|August    110|September 107|October   104|November  102|December  100';
   mat_weekday = '00:00  0.5|00:30  0.5|01:00  0.5|01:30  0.5|02:00  0.5|02:30  0.5|03:00  1.0|03:30  1.0|04:00  1.0|04:30  1.0|05:00  2.0|05:30  2.0|06:00  3.0|06:30  3.0|07:00  5.0|07:30  5.0|08:00  5.0|08:30  5.0|09:00  4.0|09:30  4.0|10:00  3.0|10:30  2.0|11:00  2.0|11:30  2.0|12:00  3.0|12:30  3.0|13:00  4.0|13:30  4.0|14:00  3.0|14:30  2.0|15:00  2.0|15:30  1.0|16:00  1.0|16:30  2.0|17:00  2.0|17:30  3.0|18:00  3.0|18:30  3.0|19:00  3.0|19:30  2.0|20:00  2.0|20:30  2.0|21:00  2.0|21:30  2.0|22:00  1.0|22:30  1.0|23:00  1.0|23:30  1.0';
   mat_sunday =  '00:00  0.5|00:30  0.5|01:00  0.5|01:30  0.5|02:00  0.5|02:30  0.5|03:00  1.0|03:30  1.0|04:00  1.0|04:30  1.0|05:00  2.0|05:30  2.0|06:00  2.0|06:30  2.0|07:00  2.0|07:30  4.0|08:00  5.0|08:30  5.0|09:00  4.0|09:30  3.0|10:00  3.0|10:30  2.0|11:00  2.0|11:30  2.0|12:00  3.0|12:30  3.0|13:00  3.0|13:30  3.0|14:00  3.0|14:30  2.0|15:00  2.0|15:30  1.0|16:00  1.0|16:30  2.0|17:00  2.0|17:30  3.0|18:00  3.0|18:30  3.0|19:00  3.0|19:30  2.0|20:00  2.0|20:30  2.0|21:00  2.0|21:30  2.0|22:00  1.0|22:30  1.0|23:00  1.0|23:30  1.0';
   
h0 = figure('Units','points', ...
	'Color',[0.8 0.8 0.8], ...
	'FileName','CarnotCallbacks_create_mdot.m', ...
	'PaperPosition',[18 180 576 432], ...
   'PaperUnits','points', ...
 	'MenuBar','none', ...
	'Name','load profile', ...
	'NumberTitle','off', ...
	'Position',[283.5 81 311.25 334.5], ...
   'Tag','Fig2', ...
	'ToolBar','none');
volumeHndl = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[1 1 1], ...
	'ListboxTop',0, ...
	'Position',[126 285.75 86.25 16.5], ...
	'String','150', ...
	'Style','edit', ...
	'Tag','EditText1');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[.8 .8 .8], ...
	'HorizontalAlignment','left', ...
	'ListboxTop',0, ...
	'Position',[14.25 289.5 112 12.75], ...
	'String','reference: daily consumption [l]', ...
	'Style','text', ...
	'Tag','StaticText1');
listboxHndlMonth = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[1 1 1], ...
	'Callback','CarnotCallbacks_create_mdot(''monthclick'')', ...
	'Max',12, ...
	'Position',[14.25 99 83.25 121.5], ...
	'String',mat_month, ...
	'Style','listbox', ...
	'Tag','Listbox1', ...
	'UserData','[ ]', ...
	'Value',1);
inputHndlMonth = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[1 1 1], ...
	'Callback','CarnotCallbacks_create_mdot(''monthchange'')', ...
	'ListboxTop',0, ...
	'Position',[16.125 225.75 79.5 15], ...
	'String','123', ...
	'Style','edit', ...
	'Tag','EditText2');
outputHndlAverageMonth = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[.8 .8 .8], ...
	'ListboxTop',0, ...
	'Position',[36 66.75 39.75 10.5], ...
	'String','Mittelwert', ...
	'Style','text', ...
	'Tag','StaticText2');
h1 = uicontrol('Parent',h0, ...
   'Units','points', ...
   'BackgroundColor',[.8 .8 .8], ...
	'ListboxTop',0, ...
	'Position',[23.25 81.75 65.25 9.75], ...
	'String','average [%]', ...
	'Style','text', ...
   'Tag','StaticText3');
pathnameHndl = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[.8 .8 .8], ...
	'ListboxTop',0, ...
	'Position',[98.25 313.5 239.5 30.5], ...
	'String','pathname', ...
	'Style','text', ...
	'Tag','StaticText2');
endbuttonHndl = uicontrol('Parent',h0, ...
	'Units','points', ...
	'ListboxTop',0, ...
	'Callback','CarnotCallbacks_create_mdot(''ende_ok'')', ...
	'Position',[28.5 15.75 60.75 21.75], ...
   'String','OK', ...
	'Tag','Pushbutton1');
inputHndlweekday = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[1 1 1], ...
	'Callback','CarnotCallbacks_create_mdot(''weekdaychange'')', ...
	'ListboxTop',0, ...
	'Position',[119.625 225.75 79.5 15], ...
	'String','123', ...
	'Style','edit', ...
	'Tag','EditText2');
listboxHndlweekday = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[1 1 1], ...
	'Callback','CarnotCallbacks_create_mdot(''weekdayclick'')', ...
	'Max',12, ...
	'Position',[117.75 99 83.25 121.5], ...
	'String',mat_weekday, ...
	'Style','listbox', ...
	'Tag','Listbox1', ...
	'UserData','[ ]', ...
	'Value',1);
outputHndlSumweekday = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[.8 .8 .8], ...
	'ListboxTop',0, ...
	'Position',[122.25 66.75 74.25 10.5], ...
	'String','SummeWochentag', ...
	'Style','text', ...
	'Tag','StaticText2');
sumtestHndlWeekday = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[.8 .8 .8], ...
	'ListboxTop',0, ...
	'Position',[126.75 81.75 65.25 9.75], ...
	'String','sum [%]', ...
	'Style','text', ...
   'Tag','StaticText3');
inputHndlSunday = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[1 1 1], ...
	'Callback','CarnotCallbacks_create_mdot(''sundaychange'')', ...
	'ListboxTop',0, ...
	'Position',[214.125 225.75 79.5 15], ...
	'String','123', ...
	'Style','edit', ...
	'Tag','EditText2');
listboxHndlSunday = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[1 1 1], ...
	'Callback','CarnotCallbacks_create_mdot(''sundayclick'')', ...
	'Max',12, ...
	'Position',[212.25 99 83.25 121.5], ...
	'String',mat_sunday, ...
	'Style','listbox', ...
	'Tag','Listbox1', ...
	'UserData','[ ]', ...
	'Value',1);
outputHndlSumSunday = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[.8 .8 .8], ...
	'ListboxTop',0, ...
	'Position',[216.75 66.75 74.25 10.5], ...
	'String','SummeWochentag', ...
	'Style','text', ...
	'Tag','StaticText2');
sumtestHndlSunday = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[.8 .8 .8], ...
	'ListboxTop',0, ...
	'Position',[221.25 81.75 65.25 9.75], ...
	'String','sum [%]', ...
	'Style','text', ...
   'Tag','StaticText3');
percentHndl = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[0.8 .8 .8], ...
	'Callback','CarnotCallbacks_create_mdot(''percentchange'')', ...
	'ListboxTop',0, ...
	'Position',[14.25 266.25 77.25 16.5], ...
	'String','daily values [%]', ...
	'Style','checkbox', ...
	'Tag','Checkbox1', ...
   'Value',1);
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[0.752941176470588 0.752941176470588 0.752941176470588], ...
	'Callback','CarnotCallbacks_create_mdot(''close'')', ...
	'ListboxTop',0, ...
	'Position',[126.75 15.75 60.75 21.75], ...
	'String','Cancel', ...
	'Tag','Pushbutton1');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[0.752941176470588 0.752941176470588 0.752941176470588], ...
	'Callback','CarnotCallbacks_create_mdot(''help'')', ...
	'ListboxTop',0, ...
	'Position',[224.25 15.75 60.75 21.75], ...
	'String','Help', ...
	'Tag','Pushbutton1');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[.8 .8 .8], ...
	'HorizontalAlignment','left', ...
	'ListboxTop',0, ...
	'Position',[14.25 311.25 76.5 12.75], ...
	'String','load profile for block:', ...
	'Style','text', ...
	'Tag','StaticText4');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[.8 .8 .8], ...
	'ListboxTop',0, ...
	'Position',[120.375 245.25 78 11.25], ...
	'String','weekday', ...
	'Style','text', ...
	'Tag','StaticText5');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[0.8 .8 .8], ...
	'ListboxTop',0, ...
	'Position',[214.875 245.25 78 11.25], ...
	'String','weekend', ...
	'Style','text', ...
	'Tag','StaticText5');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[0.8 .8 .8], ...
	'ListboxTop',0, ...
	'Position',[14.625 243.75 82.5 12.75], ...
	'String','monthly consumption', ...
	'Style','text', ...
	'Tag','StaticText6');


%	'String','00:00  0.5|00:30  0.5|01:00  0.5|01:30  0.5|02:00  0.5|02:30  0.5|03:00  1.0|03:30  1.0|04:00  1.0|04:30  1.0|05:00  2.0|05:30  2.0|06:00  3.0|06:30  3.0|07:00  5.0|07:30  5.0|08:00  5.0|08:30  5.0|09:00  4.0|09:30  4.0|10:00  3.0|10:30  2.0|11:00  2.0|11:30  2.0|12:00  3.0|12:30  3.0|13:00  4.0|13:30  4.0|14:00  3.0|14:30  2.0|15:00  2.0|15:30  1.0|16:00  1.0|16:30  2.0|17:00  2.0|17:30  3.0|18:00  3.0|18:30  3.0|19:00  3.0|19:30  2.0|20:00  2.0|20:30  2.0|21:00  2.0|21:30  2.0|22:00  1.0|22:30  1.0|23:00  1.0|23:30  1.0', ...


   % Uncover the figure
   hndlList=[inputHndlMonth listboxHndlMonth outputHndlAverageMonth inputHndlweekday ...
         listboxHndlweekday outputHndlSumweekday inputHndlSunday listboxHndlSunday ...
      outputHndlSumSunday volumeHndl pathnameHndl percentHndl sumtestHndlWeekday ...
      sumtestHndlSunday];
   
   set(h0,'Visible','on', ...
      'UserData',hndlList);

   if (nargin>1)
      rsmonth = strcat(pathname,'/RS Month')  ;      
      rsweekday = strcat(pathname,'/RS Weekday');
      rssunday = strcat(pathname,'/RS Sunday');   
      rsmdot0 = strcat(pathname,'/mdot0');
      
      set(pathnameHndl,'String',pathname);


      mat2 = get_param(rsmonth,'rep_seq_y');
      mat3 = str2num(mat2);
   
      inStr=get(listboxHndlMonth,'String');
      for activemonth=1:12
         s = size(inStr);
   
         inStr(activemonth,11:s(2)) = ' ';        % Stellen für Zahl im String löschen
         out = num2str(mat3(activemonth*2));               % Zahl in String umwandeln
         for i=1:length(out)                     % und in Liste einfügen  
            inStr(activemonth,10+i) = out(i);
         end
         set(listboxHndlMonth,'String',inStr)
      end   
      
      mat2 = get_param(rsweekday,'rep_seq_y');
      mat3 = str2num(mat2);
   
      inStr=get(listboxHndlweekday,'String');
      for activehour=1:48
         s = size(inStr);
   
         inStr(activehour,7:s(2)) = ' ';        % Stellen für Zahl im String löschen
         out = num2str(mat3(activehour*2));               % Zahl in String umwandeln
         for i=1:length(out)                     % und in Liste einfügen  
            inStr(activehour,6+i) = out(i);
         end
      end   
      set(listboxHndlweekday,'String',inStr);
      
      mat2 = get_param(rssunday,'rep_seq_y');
      mat3 = str2num(mat2);
   
      inStr=get(listboxHndlSunday,'String');
      for activehour=1:48
         s = size(inStr);
   
         inStr(activehour,7:s(2)) = ' ';        % Stellen für Zahl im String löschen
         out = num2str(mat3(activehour*2));               % Zahl in String umwandeln
         for i=1:length(out)                     % und in Liste einfügen  
            inStr(activehour,6+i) = out(i);
         end
      end   
         set(listboxHndlSunday,'String',inStr)
   
   
   
      mat2 = get_param(rsmdot0,'Value');
      mat3 = str2num(mat2);
      set(volumeHndl,'String',num2str(str2num(mat2)*1800))
   
   end

 
   
   CarnotCallbacks_create_mdot('monthclick')            % Mittelwert aktualisieren ...
   CarnotCallbacks_create_mdot('weekdayclick')            % Summe Wochentag aktualisieren ...
   CarnotCallbacks_create_mdot('sundayclick')            % Summe Wochentag aktualisieren ...
   
if nargout > 0, fig = h0; end




%*****************************************************************************
%
%  monthchange
%
%  after input of monthly value in edit box
%  change value in listbox
%
%*****************************************************************************
elseif strcmp(action,'monthchange'),
      
   hndlList=get(gcf,'UserData');
   
   inputHndlMonth = hndlList(1);
   listboxHndlMonth = hndlList(2);
   outputHndlAverageMonth = hndlList(3);
   
   inStrM=get(inputHndlMonth,'String');
   monthrate = str2double(inStrM);
   activemonth = get(listboxHndlMonth,'Value');
   
   inStr=get(listboxHndlMonth,'String');
   s = size(inStr);

   inStr(activemonth,11:s(2)) = ' ';        % Stellen für Zahl im String löschen

   out = num2str(monthrate);               % Zahl in String umwandeln
   for i=1:length(out)                     % und in Liste einfügen  
      inStr(activemonth,10+i) = out(i);
   end
      
   set(listboxHndlMonth,'String',inStr)
      
   CarnotCallbacks_create_mdot('monthclick')            % Mittelwert aktualisieren ...
   
   
   
%*****************************************************************************
%
%  monthclick
%
%  when clicked on listbox or called by monthchange,
%  then copy value from listbox in editbox and new calculation of average
%
%*****************************************************************************
elseif strcmp(action,'monthclick'),
      
   hndlList=get(gcf,'UserData');
   
   inputHndlMonth=hndlList(1);
   listboxHndlMonth=hndlList(2);
   outputHndlAverageMonth = hndlList(3);
   
   activemonth = get(listboxHndlMonth,'Value');   % Nummer des Monats
   
   inStr=get(listboxHndlMonth,'String');          % Liste der Monate
   s = size(inStr);         
   if length(activemonth)==1 
      str2 = inStr(activemonth,1:s(2));              % gew. Monat + Nummer
      a = sscanf(str2,'%s %f');                      % Monatsnamen und Zahl auslesen
      v = a(length(a));                              % letzte Position in a ist Zahl
   else
      v = 0;
   end
   set(inputHndlMonth,'String',v);                % Zahl in inputFeld kopieren
   
   summe = 0;
   for i=1:12
      str2 = inStr(i,1:s(2));
      a = sscanf(str2,'%s %f');
      summe = summe+ a(length(a));
   end
   mittel = summe/12;
      
   set(outputHndlAverageMonth,'String',mittel)
   
   


%*****************************************************************************
%
%  weekdaychange
%
%  after input of value in edit box
%  change value in listbox
%
%*****************************************************************************
elseif strcmp(action,'weekdaychange'),
      
   hndlList=get(gcf,'UserData');
   
   inputHndlweekday = hndlList(4);
   listboxHndlweekday = hndlList(5);
   outputHndlSumweekday = hndlList(6);
   
   inStrM=get(inputHndlweekday,'String');
   halfhourrate = str2double(inStrM);
   activehour = get(listboxHndlweekday,'Value');
   
   inStr=get(listboxHndlweekday,'String');
   s = size(inStr);

   inStr(activehour,7:s(2)) = ' ';        % Stellen für Zahl im String löschen

   out = num2str(halfhourrate);               % Zahl in String umwandeln
   for i=1:length(out)                     % und in Liste einfügen  
      inStr(activehour,6+i) = out(i);
   end
      
   set(listboxHndlweekday,'String',inStr)
      
   CarnotCallbacks_create_mdot('weekdayclick')            % Summe Wochentag aktualisieren ...
   
   
   
%*****************************************************************************
%
%  weekdayclick
%
%  when clicked on listbox or called by weekdaychange,
%  then copy value from listbox in editbox and new calculation of daily sum
%
%*****************************************************************************  
elseif strcmp(action,'weekdayclick'),
   
   
   hndlList=get(gcf,'UserData');
   
   inputHndlweekday =hndlList(4);
   listboxHndlweekday=hndlList(5);
   outputHndlSumweekday = hndlList(6);
   
   activehour = get(listboxHndlweekday,'Value');   % Nummer des Monats
   
   inStr=get(listboxHndlweekday,'String');          % Liste der Monate
   s = size(inStr);         
   if length(activehour)==1 
      str2 = inStr(activehour,1:s(2));              % gew. Monat + Nummer
      a = sscanf(str2,'%s %f');                      % Monatsnamen und Zahl auslesen
      v = a(length(a));                              % letzte Position in a ist Zahl
   else
      v = 0;
   end
   set(inputHndlweekday,'String',v);                % Zahl in inputFeld kopieren
   
   summe = 0;
   for i=1:48
      str2 = inStr(i,1:s(2));
      a = sscanf(str2,'%s %f');
      summe = summe+ a(length(a));
   end
      
   set(outputHndlSumweekday,'String',summe)
   
   
   
%*****************************************************************************
%
%  sundaychange
%
%  after input of value in edit box
%  change value in listbox
%
%*****************************************************************************
elseif strcmp(action,'sundaychange'),
      
   hndlList=get(gcf,'UserData');
   
   inputHndlSunday = hndlList(7);
   listboxHndlSunday = hndlList(8);
   outputHndlSumSunday = hndlList(9);
   
   inStrM=get(inputHndlSunday,'String');
   halfhourrate = str2double(inStrM);
   activehour = get(listboxHndlSunday,'Value');
   
   inStr=get(listboxHndlSunday,'String');
   s = size(inStr);

   inStr(activehour,7:s(2)) = ' ';        % Stellen für Zahl im String löschen

   out = num2str(halfhourrate);               % Zahl in String umwandeln
   for i=1:length(out)                     % und in Liste einfügen  
      inStr(activehour,6+i) = out(i);
   end
      
   set(listboxHndlSunday,'String',inStr)
      
   CarnotCallbacks_create_mdot('sundayclick')            % Summe Wochentag aktualisieren ...
   
   
   
%*****************************************************************************
%
%  sundayclick
%
%  when clicked on listbox or called by sundaychange,
%  then copy value from listbox in editbox and new calculation of daily sum
%
%*****************************************************************************  
elseif strcmp(action,'sundayclick'),
   
   
   hndlList=get(gcf,'UserData');
   
   inputHndlSunday =hndlList(7);
   listboxHndlSunday=hndlList(8);
   outputHndlSumSunday = hndlList(9);
   
   activehour = get(listboxHndlSunday,'Value');   % Nummer des Monats
   
   inStr=get(listboxHndlSunday,'String');          % Liste der Monate
   s = size(inStr);         
   if length(activehour)==1 
      str2 = inStr(activehour,1:s(2));              % gew. Monat + Nummer
      a = sscanf(str2,'%s %f');                      % Monatsnamen und Zahl auslesen
      v = a(length(a));                              % letzte Position in a ist Zahl
   else
      v = 0;
   end
   set(inputHndlSunday,'String',v);                % Zahl in inputFeld kopieren
   
   summe = 0;
   for i=1:48
      str2 = inStr(i,1:s(2));
      a = sscanf(str2,'%s %f');
      summe = summe+ a(length(a));
   end
      
   set(outputHndlSumSunday,'String',summe)
   
   
   
   
%*****************************************************************************
%
%  percentchange
%
%  change display from percent to liter or vice versa
%
%*****************************************************************************
elseif strcmp(action,'percentchange'),
   
   hndlList = get(gcf,'UserData');
   percentHndl          = hndlList(12);
   listboxHndlWeekday   = hndlList(5);
   outputHndlSumweekday = hndlList(6);
   listboxHndlSunday    = hndlList(8);
   outputHndlSumSunday  = hndlList(9);
   volumeHndl           = hndlList(10);
   percentHndl          = hndlList(12);
   sumtestHndlWeekday   = hndlList(13);
   sumtestHndlSunday    = hndlList(14);
   
   p_check = get(percentHndl,'Value');                 % get checkbox setting
      
   inStr=get(volumeHndl,'String');                     % get volume out of editbox
   s = size(inStr);         
   a = sscanf(inStr,'%f');
   volume = [a(length(a))];
   
   if p_check==0                                       % convert percent to liter      
    
      inStr=get(listboxHndlWeekday,'String');          % list of weekday     
      s = size(inStr);               
      
      for activehour=1:48
         str2 = inStr(activehour,1:s(2));  
         a = sscanf(str2,'%s %f');                     % read percent
         inStr(activehour,7:s(2)) = ' ';               % delete last positions in string
         out = num2str(a(length(a))/100*volume);       % percent -> liter
         for i=1:length(out)                           % add liter to list  
            inStr(activehour,6+i) = out(i);
         end
      end
      set(listboxHndlWeekday,'String',inStr);
      set(sumtestHndlWeekday,'String','sum [l]');
      
      
      inStr=get(listboxHndlSunday,'String');          % list of sunday     
      s = size(inStr);               
      
      for activehour=1:48
         str2 = inStr(activehour,1:s(2));  
         a = sscanf(str2,'%s %f');                     % read percent
         inStr(activehour,7:s(2)) = ' ';               % delete last positions in string
         out = num2str(a(length(a))/100*volume);       % percent -> liter
         for i=1:length(out)                           % add liter to list  
            inStr(activehour,6+i) = out(i);
         end
      end
      set(listboxHndlSunday,'String',inStr);
      set(sumtestHndlSunday,'String','sum [l]');
      
   else                                               % change liter number to percent
   
      inStr=get(listboxHndlWeekday,'String');          % list of weekday
      s = size(inStr);               
      
      for activehour=1:48
         str2 = inStr(activehour,1:s(2));             
         a = sscanf(str2,'%s %f');                     % read liter number
         inStr(activehour,7:s(2)) = ' ';               % delete last position in string
         out = num2str(a(length(a))/volume*100);       % calculate liter -> percent 
         for i=1:length(out)                           % add percent in list
            inStr(activehour,6+i) = out(i);
         end
      end
      set(outputHndlSumweekday,'String',num2str(volume))
      set(listboxHndlWeekday,'String',inStr)
      set(sumtestHndlWeekday,'String','sum [%]');
      
      inStr=get(listboxHndlSunday,'String');          % list of sunday
      s = size(inStr);               
      
      for activehour=1:48
         str2 = inStr(activehour,1:s(2));             
         a = sscanf(str2,'%s %f');                     % read liter number
         inStr(activehour,7:s(2)) = ' ';               % delete last position in string
         out = num2str(a(length(a))/volume*100);       % calculate liter -> percent 
         for i=1:length(out)                           % add percent in list
            inStr(activehour,6+i) = out(i);
         end
      end
      set(outputHndlSumSunday,'String',num2str(volume))
      set(listboxHndlSunday,'String',inStr)
      set(sumtestHndlSunday,'String','sum [%]');
      
   end
      

   CarnotCallbacks_create_mdot('weekdayclick')            % Summe Wochentag aktualisieren ...
   CarnotCallbacks_create_mdot('sundayclick')            % Summe Wochentag aktualisieren ...
   
   
   
   
   
%*****************************************************************************
%
%  ende_ok
%
%  when clicked on OK-Button,
%  scan numbers from listboxes, write in strings and 
%  set numbers as parameters in repeating_sequences, ..., then close figure
%
%*****************************************************************************
elseif strcmp(action,'ende_ok'),
      
   hndlList=get(gcf,'UserData');
   listboxHndlMonth   = hndlList(2);
   listboxHndlWeekday = hndlList(5);
   listboxHndlSunday  = hndlList(8);
   volumeHndl         = hndlList(10);
   pathnameHndl       = hndlList(11);
   percentHndl        = hndlList(12);
   
   p_check = get(percentHndl,'Value');           % get checkbox setting
   
   inStr=get(volumeHndl,'String');               % get volume out of volume box
   s = size(inStr);         
   a = sscanf(inStr,'%f');
   volume = [a(length(a))];
   
   
   pathold = get(pathnameHndl,'String');         % when more than one String as Pathname
                                                 % concatenate strings with separating
   si = size(pathold);                           % special character 10
   pathname = strcat(pathold(1,:));
   if (si(1)>1)
      for i=2:si(1)
         pathname = strcat(pathname,char(10),pathold(i,:));
      end
   end
      
   rsmonth = strcat(pathname,'/RS Month');
   rsweekday = strcat(pathname,'/RS Weekday');
   rssunday = strcat(pathname,'/RS Sunday');
   rsmdot0 = strcat(pathname,'/mdot0');

   
   set_param(rsmdot0,'Value',num2str(volume/1800)); 
   
   out = [];   
   inStr=get(listboxHndlMonth,'String');          % Liste der Monate
   s = size(inStr);         
   for i=1:12                                     % 12 Zahlen auslesen
      str2 = inStr(i,1:s(2));
      a = sscanf(str2,'%s %f');
      out = [out a(length(a)) a(length(a))];      % Monatswerte jeweils doppelt in Liste ausgeben
   end
   out = num2str(out);                            % Zahlenvektor in String verwandeln
   while (length(findstr(out,'  '))>0)            % und alle überflüssigen Leerzeichen
      out=strrep(out,'  ',' ');                   % entfernen
   end
   out = strcat('[',out,']');
   set_param(rsmonth,'rep_seq_y',out);            % Monatswertliste in Modell einfügen
   
   
   out = [];   
   inStr=get(listboxHndlWeekday,'String');          % Liste der Wochentage
   s = size(inStr);         
   for i=1:48                                     % 48 Zahlen auslesen
      str2 = inStr(i,1:s(2));
      a = sscanf(str2,'%s %f');
      p = a(length(a));
      out = [out p p];      % Wochentagswerte jeweils doppelt in Liste ausgeben
   end
   
   if (p_check==0)
      out = out/volume*100;
   end
   
   out = num2str(out);                            % Zahlenvektor in String verwandeln
   while (length(findstr(out,'  '))>0)            % und alle überflüssigen Leerzeichen
      out=strrep(out,'  ',' ');                   % entfernen
   end  
   out = strcat('[',out,']');
   set_param(rsweekday,'rep_seq_y',out);            % Wochentagswertliste in Modell einfügen
   
   
   
   out = [];   
   inStr=get(listboxHndlSunday,'String');          % Liste der Sams- und Sonntage
   s = size(inStr);         
   for i=1:48                                     % 48 Zahlen auslesen
      str2 = inStr(i,1:s(2));
      a = sscanf(str2,'%s %f');
      p = a(length(a));
      out = [out p p];      % Sonntagswerte jeweils doppelt in Liste ausgeben
   end
   
   if (p_check==0)
      out = out/volume*100;
   end
   
   out = num2str(out);                            % Zahlenvektor in String verwandeln
   while (~isempty(findstr(out,'  ')))            % und alle überflüssigen Leerzeichen
      out=strrep(out,'  ',' ');                   % entfernen
   end  
   
   out = strcat('[',out,']');
   set_param(rssunday,'rep_seq_y',out);            % Sonntagswertliste in Modell einfügen
           
   fig = 0;
   close(gcf);
   
   
   
   
%*****************************************************************************
%
%  close
%
%  close figure without changing values in subsystem
%
%*****************************************************************************
elseif strcmp(action,'close')
      
   hndlList=get(gcf,'UserData');
   close(gcf);
   
   
   
%*****************************************************************************
%
%  help
%
%  call html-help file
%
%*****************************************************************************
elseif strcmp(action,'help')
   web(fullfile(path_carnot('help'),'create_mdot.html'),'-helpbrowser')
end
