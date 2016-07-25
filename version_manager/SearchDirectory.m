function founddirs = SearchDirectory(searchdirectory, directory)

% function SearchDirectory
% Parameters:
% searchdirectory: Directory, where .c and .h files shall be seached for
% directory: Only in this sub-directory is searched for the files (i.e.
% normally the src directory)
% This function searches for all .c and .h files in src subfolders
% recursively.


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


    founddirs={};
    
    ThisDirectory = pwd;
    
    cd(searchdirectory);
    DirContent = dir;
    for Count = 1:numel(DirContent)
        if ~strcmp(DirContent(Count).name, '..') && ~strcmp(DirContent(Count).name,'.') && DirContent(Count).isdir && ~strcmpi(DirContent(Count).name, directory)
            Here = pwd;
            cd(ThisDirectory)
            founddirs1 = SearchDirectory([searchdirectory,'\',DirContent(Count).name], directory);
            cd(Here);
            for Count1 = 1:numel(founddirs1)
                founddirs(numel(founddirs)+1)=founddirs1(Count1);
            end
        elseif strcmpi(DirContent(Count).name, directory) && DirContent(Count).isdir
        	founddirs{numel(founddirs)+1}=[searchdirectory,'\',DirContent(Count).name];
        else
            %nothing to do
        end
    end

    cd(ThisDirectory);
end
