function varargout = CarnotCallbacks_PMV_PPD(varargin)
% varargout = CarnotCallbacks_PMV_PPD(varargin)

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
% author list:     aw -> Arnold Wohlfeil
%
% version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
%
% Version   Author  Changes                                     Date
% 6.0.0     aw      created                                     19jul2016

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


function [DEBUGLEVEL, MAXTOTALWARNINGS, MAXCONSECUTIVEWARNINGS, WRITETOFILE, FILENAME] = CheckDebugLevels(LOCALDEBUGLEVEL, LOCALMAXTOTALWARNINGS, LOCALMAXCONSECUTIVEWARNINGS, LOCALWRITETOFILE, LOCALFILENAME)
    SystemParameters = fieldnames(get_param(bdroot,'ObjectParameters'));
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


function LoadFcn(block)
    [~, EnumCell] = enumeration('MessageLevelEnum');
    MaskStyles = get_param(gcb, 'MaskStyles');
    
    MaskStyles{1} = 'popup(';
    for Count = 1:numel(EnumCell)
        MaskStyles{1} = [MaskStyles{1}, EnumCell{Count}]; 
        if Count < numel(EnumCell)
            MaskStyles{1} = [MaskStyles{1}, '|'];
        else
           MaskStyles{1} = [MaskStyles{1}, ')']; 
        end
    end
    
    set_param(block, 'MaskStyles', MaskStyles);
end


function MaskVisibilities
    SystemParameters = fieldnames(get_param(bdroot,'ObjectParameters'));
    if sum(ismember(SystemParameters, 'DEBUGGLOBALLEVEL')) && ...
                sum(ismember(SystemParameters, 'DEBUGMAXTOTALWARNINGS')) && ...
                sum(ismember(SystemParameters, 'DEBUGMAXCONSECUTIVEWARNINGS')) && ...
                sum(ismember(SystemParameters, 'DEBUGWRITETOFILE')) && ...
                sum(ismember(SystemParameters, 'DEBUGFILENAME'))
        MaskVisibilities={'off', 'off', 'off', 'off', 'off'};
    else
        MaskVisibilities={'on', 'on', 'on', 'on', 'on'};
    end
    set_param(gcb, 'MaskVisibilities', MaskVisibilities);
end
