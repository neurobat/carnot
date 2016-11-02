function CleanUp

% function CleanUp
% Use this function to delete files, which are not needed any more in the
% release. E.g. the atomic libraries are not needed any more once the
% they have been assembled to carnot.slx.


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
% author list:     aw -> Arnold Wohlfeil
%
% version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
%
% Version   Author  Changes                                     Date
% 6.1.0     aw      created                                     oct2015



    %save directory
    VersionManagerDirectory = pwd;
    addpath(pwd);
    cd('..');

	%delete status.txt
	delete('public/library_simulink/status.txt');
	if exist('internal/library_simulink/status.txt','file')
		delete('internal/library_simulink/status.txt');
	end

    %delete public src folders
    Directories = SearchDirectory(fullfile('public', 'library_simulink'), 'src');
    for Count = 1:numel(Directories)
        rmdir(Directories{Count}, 's');
    end
    
    %delete public library_atomic folders
    Directories = SearchDirectory(fullfile('public', 'library_simulink'), 'library_atomic');
    for Count = 1:numel(Directories)
        rmdir(Directories{Count}, 's');
    end
    
    %delete public parameter_set folders
    Directories = SearchDirectory(fullfile('public', 'library_simulink'), 'parameter_set');
    for Count = 1:numel(Directories)
        rmdir(Directories{Count}, 's');
    end
    
    %delete public doc folders
    Directories = SearchDirectory(fullfile('public', 'library_simulink'), 'doc');
    for Count = 1:numel(Directories)
        rmdir(Directories{Count}, 's');
    end
    
    %delete public data folders
    Directories = SearchDirectory(fullfile('public', 'library_simulink'), 'data');
    for Count = 1:numel(Directories)
        rmdir(Directories{Count}, 's');
    end
    


    %delete internal src folders
    Directories = SearchDirectory(fullfile('internal', 'library_simulink'), 'src');
    for Count = 1:numel(Directories)
        rmdir(Directories{Count}, 's');
    end
    
    %delete internal library_atomic folders
    Directories = SearchDirectory(fullfile('internal', 'library_simulink'), 'library_atomic');
    for Count = 1:numel(Directories)
        rmdir(Directories{Count}, 's');
    end
    
    %delete internal parameter_set folders
    Directories = SearchDirectory(fullfile('internal', 'library_simulink'), 'parameter_set');
    for Count = 1:numel(Directories)
        rmdir(Directories{Count}, 's');
    end
    
    %delete internal doc folders
    Directories = SearchDirectory(fullfile('internal', 'library_simulink'), 'doc');
    for Count = 1:numel(Directories)
        rmdir(Directories{Count}, 's');
    end
    
    %delete public data folders
    Directories = SearchDirectory(fullfile('internal', 'library_simulink'), 'data');
    for Count = 1:numel(Directories)
        rmdir(Directories{Count}, 's');
    end
    
    cd(VersionManagerDirectory);
end

