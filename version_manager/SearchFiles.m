function foundfiles = SearchFiles(directory, extension, parentdirectory)


% function SearchFiles
% Parameters:
% directory: Directory, where files shall be seached for
% extension: look only for files with this extension
% parentdirectory: Only in this sub-directory is searched for the files
% This function searches for all files subfolders recursively.


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
% 6.1.0     aw      created                                     oct2015


    foundfiles={};
    
    ThisDirectory = pwd;
    
    cd(directory);
    DirContent = dir;
    for Count = 1:numel(DirContent)
        if ~strcmp(DirContent(Count).name, '..') && ~strcmp(DirContent(Count).name,'.') && DirContent(Count).isdir
            Here = pwd;
            cd(ThisDirectory)
            foundfiles1 = SearchFiles(fullfile(directory, DirContent(Count).name), extension, parentdirectory);
            cd(Here);
            for Count1 = 1:numel(foundfiles1)
                foundfiles(numel(foundfiles)+1)=foundfiles1(Count1);
            end
        elseif length(DirContent(Count).name) > length(extension)+1 %+1: '.'
            Here = pwd;
            if (DirContent(Count).name(end-length(extension))=='.') && (strcmpi(Here(end-length(parentdirectory)+1:end), parentdirectory))
                if strcmpi(DirContent(Count).name(end-length(extension)+1:end), extension)
                    foundfiles{numel(foundfiles)+1} = fullfile(directory, DirContent(Count).name);
                end
            end
        else
            %nothing to do
        end
    end

    cd(ThisDirectory);
end