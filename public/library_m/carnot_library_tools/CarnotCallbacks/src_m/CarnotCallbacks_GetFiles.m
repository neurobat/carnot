% CarnotCallbacks_GetFiles is a callback script to load files and write the
% filename in a From_Workspace Block.
% The variable parampath can be used to hand over the path to files which
% are not stored on the Matlab-path.
%
% Inputs:       -
% Outputs:      -
% Syntax:       CarnotCallbacks_GetFiles
%                                                                          
% Function Calls:
% function is used by: Load_from_File, Weather_from_File
% 
% Literature:   -

% all comments above appear with 'help CarnotCallbacks_GetFiles' 
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
% author list:     hf -> Bernd Hafner
%                  rd -> Ralf Dott
%
% version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
%
% Version   Author  Changes                                     Date
% 6.1.0     hf      created                                     02jun2015
% 6.1.2     hf      evaluation of timeseries                    03dec2015
% 6.2.0     hf      general application also for weather data   03dec2015
% 6.2.1     rd      use importdata for .mat-files               21jan2016
%                   use load for txt/csv-files
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

if ~exist('parampath','var')
    parampath = '';
end
if ~exist('file','var')
    file = 'default';
end
if ~exist('ext','var')
    ext = '.mat';
end
t_sample = 3600;        % assume a sample time of the data (3600 s)

if ~BlockIsInCarnotLibrary          % not in carnot library any more
    filename = [file, ext];
    intfile = fullfile(path_carnot('intlibsl'), parampath, filename);
    pubfile = fullfile(path_carnot('libsl'), parampath, filename);
    flag = false;
    
    if exist(filename,'file')       % search file on matlab path
        if strcmp(ext,'.mat')
            data = importdata(filename);
        else
            data = load(filename);
        end
        flag = true;
    elseif exist(intfile,'file')    % search on internal path
        if strcmp(ext,'.mat')
            data = importdata(intfile);
        else
            data = load(intfile);
        end
        flag = true;
    elseif exist(pubfile,'file')    % search on public path
        if strcmp(ext,'.mat')
            data = importdata(pubfile);
        else
            data = load(pubfile);
        end
        flag = true;
    end

    set_param([gcb '/From_Workspace'], 'VariableName', file);
    
    % sample time is timestep of data
    if flag == true                 % if the file exists
        if isa(data,'double')                   % if variable is a real matrix
            t_sample = data(3,1) - data(2,1);
        else                                    % else: variable is a timeseries
            t_sample = data.Time(2) - data.Time(1);
        end
        
        % assign data to the base workspace for the From_Workspace block
        assignin('base',file,data)  
        % evalin('base',['load(''' file2 ''');'])
        clear data
    else
        assignin('base',file,[0 0; 3600 0]) % no data available: assign a flat line of zeros  
    end
end
