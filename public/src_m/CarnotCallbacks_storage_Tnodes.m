function varargout = Carnot_storage_Tnodes_Callbacks(varargin)
% varargout = Carnot_storage_Tnodes_Callbacks(varargin)

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



function InitCallback(block, nconnect)
    
    Inports = find_system(block, 'LookUnderMasks', 'on', 'FollowLinks', 'on', 'BlockType', 'Inport');
    
    if numel(Inports)-1 ~= nconnect
        %delete all lines to the S-function
        for Count = 1:numel(Inports)
            LineHandle=get_param(Inports{Count}, 'LineHandles');
            delete_line(LineHandle.Outport);
        end
        
        %delete all lines from the S-function
        delete_line(block, 'sfun_storageTnodes/1', 'Energy/1');
        delete_line(block, 'sfun_storageTnodes/2', 'Tnodes/1');
        
        %save data of the S-function
        SFunctionParameters = get_param([block, '/sfun_storageTnodes'], 'Parameters');
        SFunctionName = get_param([block, '/sfun_storageTnodes'], 'FunctionName');
        
        %delete S-function
        delete_block([block, '/sfun_storageTnodes']);
        clear mex;
        
        %add S-function
        add_block('built-in/S-Function', [block, '/sfun_storageTnodes']);
        set_param([block, '/sfun_storageTnodes'], 'Parameters', SFunctionParameters);
        set_param([block, '/sfun_storageTnodes'], 'FunctionName', SFunctionName);
        set_param([block, '/sfun_storageTnodes'], 'Position', [130 020 280 200]);
        
        %add outport lines
        add_line(block, 'sfun_storageTnodes/1', 'Energy/1');
        add_line(block, 'sfun_storageTnodes/2', 'Tnodes/1');
        
        %add or delete ports
        if numel(Inports)-1 > nconnect %more ports than needed
            for Count = nconnect+1+1:numel(Inports)
                delete_block(Inports{Count});
            end
        else %less ports than needed
            for Count = 1+numel(Inports):1+nconnect
                add_block('built-in/Inport',[block, '/port', num2str(Count-1)]);
                set_param([block, '/port', num2str(Count-1)], 'Position', [20 8+Count*30 50 22+Count*30]);
            end
        end
        
        %connect inports
        Inports = find_system(block, 'LookUnderMasks', 'on', 'FollowLinks', 'on', 'BlockType', 'Inport');
        for Count = 1:numel(Inports)
            Slashs = strfind(Inports{Count}, '/');
            ThisPort = Inports{Count};
            ThisPort = ThisPort(Slashs(end)+1:end);
            add_line(block, [ThisPort, '/1'], ['sfun_storageTnodes/', num2str(Count)]);
        end
        
    else %correct number of ports
        %do nothing
    end



end