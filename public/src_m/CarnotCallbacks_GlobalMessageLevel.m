function varargout = CarnotCallbacks_GlobalMessageLevel(varargin)
% varargout = CarnotCallbacks_GlobalMessageLevel(varargin)

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
% 6.1.0     aw      created                                     may2015

% Switch for command line calls
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


function LoadFcn
    [~, EnumCell] = enumeration('MessageLevelEnum');
    MaskStyles = get_param(gcb, 'MaskStyles');
    MaskStyles{2} = 'popup(';
    for Count = 1:numel(EnumCell)
        MaskStyles{2} = [MaskStyles{2}, EnumCell{Count}]; 
        if Count < numel(EnumCell)
            MaskStyles{2} = [MaskStyles{2}, '|'];
        else
           MaskStyles{2} = [MaskStyles{2}, ')']; 
        end
    end
    set_param(gcb, 'MaskStyles', MaskStyles);
end

function SetData
    Parameters = fieldnames(get_param(bdroot, 'ObjectParameters'));    
    
    if strcmpi(get_param(gcb, 'GLOBALLOCAL'), 'GLOBAL')
        if sum(ismember(Parameters, 'DEBUGGLOBALLEVEL'))
            set_param(bdroot, 'DEBUGGLOBALLEVEL', get_param(gcb, 'DEBUGLEVEL'));
        else
            add_param(bdroot, 'DEBUGGLOBALLEVEL', get_param(gcb, 'DEBUGLEVEL'));
        end
        if sum(ismember(Parameters, 'DEBUGMAXTOTALWARNINGS'))
            set_param(bdroot, 'DEBUGMAXTOTALWARNINGS', get_param(gcb, 'MAXTOTALWARNINGS'));
        else
            add_param(bdroot, 'DEBUGMAXTOTALWARNINGS', get_param(gcb, 'MAXTOTALWARNINGS'));
        end
        if sum(ismember(Parameters, 'DEBUGMAXCONSECUTIVEWARNINGS'))
            set_param(bdroot, 'DEBUGMAXCONSECUTIVEWARNINGS', get_param(gcb, 'MAXCONSECUTIVEWARNINGS'));
        else
            add_param(bdroot, 'DEBUGMAXCONSECUTIVEWARNINGS', get_param(gcb, 'MAXCONSECUTIVEWARNINGS'));
        end
        if sum(ismember(Parameters, 'DEBUGWRITETOFILE'))
            set_param(bdroot, 'DEBUGWRITETOFILE', get_param(gcb, 'WRITETOFILE'));
        else
            add_param(bdroot, 'DEBUGWRITETOFILE', get_param(gcb, 'WRITETOFILE'));
        end
        if sum(ismember(Parameters, 'DEBUGFILENAME'))
            set_param(bdroot, 'DEBUGFILENAME', get_param(gcb, 'FILENAME'));
        else
            add_param(bdroot, 'DEBUGFILENAME', get_param(gcb, 'FILENAME'));
        end
    else
        if sum(ismember(Parameters, 'DEBUGGLOBALLEVEL'))
            delete_param(bdroot, 'DEBUGGLOBALLEVEL');
        end
        if sum(ismember(Parameters, 'DEBUGMAXTOTALWARNINGS'))
            delete_param(bdroot, 'DEBUGMAXTOTALWARNINGS');
        end
        if sum(ismember(Parameters, 'DEBUGMAXCONSECUTIVEWARNINGS'))
            delete_param(bdroot, 'DEBUGMAXCONSECUTIVEWARNINGS');
        end
        if sum(ismember(Parameters, 'DEBUGWRITETOFILE'))
            delete_param(bdroot, 'DEBUGWRITETOFILE');
        end
        if sum(ismember(Parameters, 'DEBUGFILENAME'))
            delete_param(bdroot, 'DEBUGFILENAME');
        end
    end
    
    
end



function MaskCallback
    if strcmpi(get_param(gcb, 'GLOBALLOCAL'), 'global')
        MaskVisibilities = {'on'; 'on'; 'on'; 'on'; 'on'; 'on'};
    else
        MaskVisibilities = {'on'; 'off'; 'off'; 'off'; 'off'; 'off'};
    end
    set_param(gcb, 'MaskVisibilities', MaskVisibilities);
end