%This is an example file for Carnot callbacks.
%These files are used to create mask parameters automatically.

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
% author list:     aw -> Arnold Wohlfeil
%
% version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
%
% Version   Author  Changes                                     Date
% 6.0.0     aw      created                                     23feb2015
%
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *


%This the the base function. It calles the other function in this file
%depending on the first input parameter. The advantage is that only one
%file for all functions is needed
function varargout = CarnotCallbacks_SimplePipeMessages(varargin)
    %Check if the number of input arguments is bigger than one.
    %The first input argument is the name of the function called.
    if nargin >= 1 && ischar(varargin{1})
        FunctionName = varargin{1};

        % Call the function
        if nargout > 0
            [varargout{1:nargout}] = feval(FunctionName, varargin{2:end});
        else
            feval(FunctionName, varargin{2:end});
        end
    else
        error('First argument must be a valid function name. Second argument must be the blockpath.')
        
    end
end


%This function is an utility function.
%It converts a string to an enum type for the message level.
function MyEnum = Str2MessageLevelEnum(MyString)
    [EnumContent, EnumCell] = enumeration('MessageLevelEnum');
    MyEnum = 0;
    EnumSet = false;
    
    Count = 0;
    while (Count < numel(EnumCell)) && ~EnumSet
        Count = Count + 1;
        if strcmpi(MyString, EnumCell{Count})
            MyEnum = EnumContent(Count);
            EnumSet = true;
        end
    end
end


%This function checks if a global message level is set.
%If so, the local values are overwritten, otherwise the local settings are
%used.
function [DEBUGLEVEL, MAXTOTALWARNINGS, MAXCONSECUTIVEWARNINGS, WRITETOFILE, FILENAME] = CheckDebugLevels(LOCALDEBUGLEVEL, LOCALMAXTOTALWARNINGS, LOCALMAXCONSECUTIVEWARNINGS, LOCALWRITETOFILE, LOCALFILENAME)
    %The global message level is set by model parameters.
    %So first we have to get all parameters of the model (not the block)
    SystemParameters = fieldnames(get_param(bdroot,'ObjectParameters'));
    %As next step we check if all parameters for the message management are
    %present.
    %If they are present, the output of the function is set to these
    %values, otherwise the local (input) values are kept.
    if sum(ismember(SystemParameters, 'DEBUGGLOBALLEVEL')) && ...
            sum(ismember(SystemParameters, 'DEBUGMAXTOTALWARNINGS')) && ...
            sum(ismember(SystemParameters, 'DEBUGMAXCONSECUTIVEWARNINGS')) && ...
            sum(ismember(SystemParameters, 'DEBUGWRITETOFILE')) && ...
            sum(ismember(SystemParameters, 'DEBUGFILENAME'))
        if isempty(str2num(get_param(bdroot, 'DEBUGGLOBALLEVEL')))
            DEBUGLEVEL = int32(Str2MessageLevelEnum(get_param(bdroot, 'DEBUGGLOBALLEVEL')));
        else
            DEBUGLEVEL = int32(str2num(get_param(bdroot, 'DEBUGGLOBALLEVEL')));
        end
        MAXTOTALWARNINGS = str2num(get_param(bdroot, 'DEBUGMAXTOTALWARNINGS'));
        MAXCONSECUTIVEWARNINGS = str2num(get_param(bdroot, 'DEBUGMAXCONSECUTIVEWARNINGS'));
        WRITETOFILE = str2num(get_param(bdroot, 'DEBUGWRITETOFILE'));
        FILENAME = get_param(bdroot, 'DEBUGFILENAME');
    else
        DEBUGLEVEL = LOCALDEBUGLEVEL;
        MAXTOTALWARNINGS = LOCALMAXTOTALWARNINGS;
        MAXCONSECUTIVEWARNINGS = LOCALMAXCONSECUTIVEWARNINGS;
        WRITETOFILE = LOCALWRITETOFILE;
        FILENAME = LOCALFILENAME;
    end
    clear SystemParameters;
end


%This is the load function callback.
%It reads the content of the MessageLevelEnum and copies it to the mask
%parameter 5.
function LoadFcn(block)
    %get the names of the enum
    [~, EnumCell] = enumeration('MessageLevelEnum');
    %get the mask styles of the block
    MaskStyles = get_param(block, 'MaskStyles');
    
    %assembles a string for the mask
    MaskStyles{5} = 'popup(';
    for Count = 1:numel(EnumCell)
        MaskStyles{5} = [MaskStyles{5}, EnumCell{Count}]; 
        if Count < numel(EnumCell)
            MaskStyles{5} = [MaskStyles{5}, '|'];
        else
           MaskStyles{5} = [MaskStyles{5}, ')']; 
        end
    end
    
    %set the new mask information
    set_param(block, 'MaskStyles', MaskStyles);
end


%This function sets the visibility of the mask parameters.
%If the global messge level is set, the corresponding parameters 5-10 are
%not visible
function MaskVisibilities(block)
    %As in the function 'CheckDebugLevels' we check if a global message
    %level is set
    %The first four parameters belong to the tab 'thermal' and have to be
    %visible. The last five parameters belong to the tab 'messages' and
    %shall only be visible of no global message information is set.
    SystemParameters = fieldnames(get_param(bdroot,'ObjectParameters'));
    if sum(ismember(SystemParameters, 'DEBUGGLOBALLEVEL')) && ...
                sum(ismember(SystemParameters, 'DEBUGMAXTOTALWARNINGS')) && ...
                sum(ismember(SystemParameters, 'DEBUGMAXCONSECUTIVEWARNINGS')) && ...
                sum(ismember(SystemParameters, 'DEBUGWRITETOFILE')) && ...
                sum(ismember(SystemParameters, 'DEBUGFILENAME'))
        MaskVisibilities={'on','on','on','on','off','off','off','off','off'};
    else
        MaskVisibilities={'on','on','on','on','on','on','on','on','on'};
    end
    set_param(block, 'MaskVisibilities', MaskVisibilities);
end

