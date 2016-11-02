function CopyRemainingFiles

% function CopyRemainingFiles
% Use this function to copy files from the directories of the atomic
% libraries to the release directories, e.g. help files, m-files, ...


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

    %public .m files
    CopyFileType(fullfile(pwd, 'public', 'library_simulink'), 'scripts', fullfile(pwd, 'public', 'src_m'), 'm');
    CopyFileType(fullfile(pwd,'public', 'library_m'), 'src_m', fullfile(pwd, 'public', 'src_m'), 'm');
    %internal .m files
    CopyFileType(fullfile(pwd,'internal', 'library_simulink'), 'scripts', fullfile(pwd, 'internal', 'src_m'), 'm');
    CopyFileType(fullfile(pwd,'internal', 'library_m'), 'src_m', fullfile(pwd, 'internal', 'src_m'), 'm');

    %public examples
    CopyFileType(fullfile(pwd,'public', 'library_simulink'), 'examples', fullfile(pwd, 'public', 'tutorial', 'examples'), 'mdl');
    CopyFileType(fullfile(pwd,'public', 'library_simulink'), 'examples', fullfile(pwd, 'public', 'tutorial', 'examples'), 'slx');
    
    %internal examples
    CopyFileType(fullfile(pwd,'internal', 'library_simulink'), 'examples', fullfile(pwd, 'internal', 'tutorial', 'examples'), 'mdl');
    CopyFileType(fullfile(pwd,'internal', 'library_simulink'), 'examples', fullfile(pwd, 'internal', 'tutorial', 'examples'), 'slx');
    
    %public html files
    CopyFileType(fullfile(pwd,'public', 'library_simulink'), 'doc', fullfile(pwd, 'public', 'tutorial', 'doc'), 'html');
    CopyFileType(fullfile(pwd,'public', 'library_simulink'), 'doc', fullfile(pwd, 'public', 'tutorial', 'doc'), 'htm');
    
    %internal html files
    CopyFileType(fullfile(pwd,'internal', 'library_simulink'), 'doc', fullfile(pwd, 'internal', 'tutorial', 'doc'), 'html');
    CopyFileType(fullfile(pwd,'internal', 'library_simulink'), 'doc', fullfile(pwd, 'internal', 'tutorial', 'doc'), 'htm');
    
    %public pdf files
    CopyFileType(fullfile(pwd,'public', 'library_simulink'), 'doc', fullfile(pwd, 'public', 'tutorial', 'doc', 'pdf'), 'pdf');
    
    %internal pdf files
    CopyFileType(fullfile(pwd,'internal', 'library_simulink'), 'doc', fullfile(pwd, 'internal', 'tutorial', 'doc', 'pdf'), 'pdf');
    
    cd(VersionManagerDirectory);
end


function CopyFileType(SearchDir, InDir, TargetDir, Extension)
    FoundFiles = SearchFiles(SearchDir, Extension, InDir);
    FoundFiles = strrep(FoundFiles, '\', '/');
    for Count = 1:numel(FoundFiles)
        copyfile(FoundFiles{Count}, TargetDir);
    end

end



function MoveFileType(SearchDir, InDir, TargetDir, Extension)
    FoundFiles = SearchFiles(SearchDir, Extension, InDir);
    FoundFiles = strrep(FoundFiles, '\', '/');
    for Count = 1:numel(FoundFiles)
        movefile(FoundFiles{Count}, TargetDir);
    end

end

