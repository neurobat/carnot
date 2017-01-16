function MakeMEX
    
% function MakeMex
% MakeMex is used to programmatically compile all of CARNOT's s-Functions.
% It moves the carlib library (and other libraries) from public\library_c\
% to the public\src\libraries folder so they can be included for each
% s-Functions' individual mex operation.
% The function works for both public and internal s-Functions.
% Compiled s-Functions will be placed as mexw64/32 in the respective bin folder.


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
% 6.1.1		aw		changed call of mex for Linux gcc			16nov2016
%					compability

    
    %%save currentdirectory
    VersionManagerDirectory = pwd;
    addpath(pwd);
    cd('..');
    
    %% public
    
    %get directory names
    mexdirectory_public = fullfile(path_carnot('root'), 'public', 'bin');
    srcdirectory_public = fullfile(path_carnot('root'), 'public', 'src');
    libdirectory_public = fullfile(path_carnot('root'), 'public', 'src', 'libraries');
    if ~exist(libdirectory_public, 'dir')
        mkdir(libdirectory_public);
    end
    
    %move all library_m-files to src
    cfiles = SearchFiles(fullfile(path_carnot('root'), 'public', 'library_m'), 'c', 'src');
    for Count=1:numel(cfiles)
        movefile(cfiles{Count},srcdirectory_public);
    end
    
    
    %get all C - Files from the directories
    clibfiles_public = SearchFiles(fullfile(path_carnot('root'), 'public', 'library_c'), 'c', 'src');
    hlibfiles_public = SearchFiles(fullfile(path_carnot('root'), 'public', 'library_c'), 'h', 'src');
    cfiles_simulink = SearchFiles(fullfile(path_carnot('root'), 'public', 'library_simulink'), 'c', 'src');
    cfiles_src = SearchFiles(fullfile(path_carnot('root'), 'public', 'src'), 'c', 'src');
    hfiles_simulink = SearchFiles(fullfile(path_carnot('root'), 'public', 'library_simulink'), 'h', 'src');
    hfiles_src = SearchFiles(fullfile(path_carnot('root'), 'public', 'src'), 'h', 'src');
    hfiles_all = SearchFiles(fullfile(path_carnot('root'), 'public'), 'h', 'src');
    
    
    cfiles = cfiles_simulink;
    for Count1 = 1:numel(cfiles_src)
    	cfiles(numel(cfiles)+1)=cfiles_src(Count1);
    end
    
    %compile all C-files
    CompileCFiles(cfiles, clibfiles_public, hfiles_all, mexdirectory_public);
    
    %move all C-files to src
    for Count=1:numel(cfiles_simulink)
        movefile(cfiles_simulink{Count},srcdirectory_public);
    end
    
    %move all H-files to src
    for Count=1:numel(hfiles_simulink)
        movefile(hfiles_simulink{Count},srcdirectory_public);
    end
    
    %move all library C-files
    for Count=1:numel(clibfiles_public)
        movefile(clibfiles_public{Count},libdirectory_public);
    end
    
    %move all library H-files
    for Count=1:numel(hlibfiles_public)
        movefile(hlibfiles_public{Count},libdirectory_public);
    end
    
    %create rtwmakecfg.m
    LibraryFiles_public = SearchFiles(libdirectory_public, 'c', libdirectory_public);
    MakeRTWConfigFile(mexdirectory_public, {srcdirectory_public}, LibraryFiles_public);
    
    
    
    
    
    
    
    %%internal
    DirectoriesExist = true;
    if ~exist(fullfile(path_carnot('root'), 'internal', 'bin'), 'dir')
        DirectoriesExist = false;
    end
    if ~exist(fullfile(path_carnot('root'), 'internal', 'src'), 'dir')
        DirectoriesExist = false;
    end
    if ~exist(fullfile(path_carnot('root'), 'internal', 'src', 'libraries'), 'dir')
        DirectoriesExist = false;
    end
    if ~exist(fullfile(path_carnot('root'), 'internal', 'library_c'), 'dir')
        DirectoriesExist = false;
    end
    if ~exist(fullfile(path_carnot('root'), 'internal', 'library_simulink'), 'dir')
        DirectoriesExist = false;
    end
    
    if ~DirectoriesExist
        fprintf('Directories for internal models do not exist ... skipping\n');
    else
        mexdirectory_internal = fullfile(path_carnot('root'), 'internal', 'bin');
        srcdirectory_internal = fullfile(path_carnot('root'), 'internal', 'src');
        libdirectory_internal = fullfile(path_carnot('root'), 'internal', 'src', 'libraries');
        if ~exist(libdirectory_internal, 'dir')
            mkdir(libdirectory_internal);
        end
        
        
        %move all library_m-files to src
        if exist(fullfile(path_carnot('root'), 'internal', 'library_m'), 'dir')
            cfiles = SearchFiles(fullfile(path_carnot('root'), 'internal', 'library_m'), 'c', 'src');
            for Count=1:numel(cfiles)
                movefile(cfiles{Count},srcdirectory_internal);
            end
        end

        %get all C - Files
        clibfiles_internal = SearchFiles(fullfile(path_carnot('root'), 'internal', 'library_c'), 'c', 'src');
        hlibfiles_internal = SearchFiles(fullfile(path_carnot('root'), 'internal', 'library_c'), 'h', 'src');
        cfiles_simulink = SearchFiles(fullfile(path_carnot('root'), 'internal', 'library_simulink'), 'c', 'src');
        cfiles_src = SearchFiles(fullfile(path_carnot('root'), 'internal', 'src'), 'c', 'src');
        hfiles_simulink = SearchFiles(fullfile(path_carnot('root'), 'internal', 'library_simulink'), 'h', 'src');
        hfiles_src = SearchFiles(fullfile(path_carnot('root'), 'internal', 'src'), 'h', 'src');
        hfiles_all = SearchFiles(fullfile(path_carnot('root'), 'internal'), 'h', 'src');

        clibfiles_public = SearchFiles(libdirectory_public, 'c', libdirectory_public);
        hlibfiles_public = SearchFiles(libdirectory_public, 'h', libdirectory_public);


        cfiles = cfiles_simulink;
        for Count = 1:numel(cfiles_src)
            cfiles{numel(cfiles)+1}=cfiles_src{Count};
        end

        for Count = 1:numel(hlibfiles_public)
            hfiles_all{numel(hfiles_all)+1} = hlibfiles_public{Count};
        end



        %compile all C-files
        CompileCFiles(cfiles, {clibfiles_public{:} clibfiles_internal{:}}, hfiles_all, mexdirectory_internal);

        %move all C-files to src
        for Count=1:numel(cfiles_simulink)
            movefile(cfiles_simulink{Count},srcdirectory_internal);
        end

        %move all H-files to src
        for Count=1:numel(hfiles_simulink)
            movefile(hfiles_simulink{Count},srcdirectory_internal);
        end

        %move all library C-files
        for Count=1:numel(clibfiles_internal)
            movefile(clibfiles_internal{Count},libdirectory_internal);
        end

        %move all library H-files
        for Count=1:numel(hlibfiles_internal)
            movefile(hlibfiles_internal{Count},libdirectory_internal);
        end

        %create rtwmakeconfig.m
        LibraryFiles_internal = SearchFiles(libdirectory_internal, 'c', libdirectory_internal);
        MakeRTWConfigFile(mexdirectory_internal, {srcdirectory_internal}, {LibraryFiles_public{:}; LibraryFiles_internal{:}});
    end

    %%return zu VersionManagerDirectory
    cd(VersionManagerDirectory);
end




function CompileCFiles(cfiles, clibfiles, hlibfiles, mexdirectory)

    %create library string
    LibraryFiles = '';
    for Count = 1:numel(clibfiles)
        LibraryFiles = [LibraryFiles, '  ', clibfiles{Count}];
    end
    
    %create include pathes
    libdirectories = hlibfiles;
    for Count = 1:numel(libdirectories)
        positions = strfind(strrep(libdirectories{Count}, '\', '/'), '/');
        libdirectories{Count} = libdirectories{Count}(1:positions(end)-1);
    end
    libdirectories = unique(libdirectories);
    IncludeDirectories = '';
    for Count = 1:numel(libdirectories)
        IncludeDirectories = [IncludeDirectories, ' -I', libdirectories{Count}];
    end
    
    %compile all files
    for Count = 1:numel(cfiles)
        fprintf('compiling %s \n', cfiles{Count});
        if ispc || ismac
            try
                eval(['mex ', cfiles{Count}, ' ', LibraryFiles, ' -outdir ', mexdirectory, IncludeDirectories]);
            catch
                warning(['Unable to build mex file for ' cfiles{Count}]);
            end
        elseif isunix
            try
                eval(['mex CFLAGS="\$CFLAGS -std=c99"', cfiles{Count}, ' ', LibraryFiles, ' -v -largeArrayDims -outdir ', mexdirectory, IncludeDirectories]);
            catch
                warning(['Unable to build mex file for ' cfiles{Count}]);
            end
        else
            %do nothing
        end
        fprintf('\n');
    end
end








function MakeRTWConfigFile(mexdirectory, srcdirectories, LibraryFiles)

    srcdirectories = strrep(srcdirectories, path_carnot('root'), '');
    LibraryFiles = strrep(LibraryFiles, path_carnot('root'), '');
    
    fid=fopen([mexdirectory, filesep, 'rtwmakecfg.m'], 'wt');
    fprintf(fid, '%s\n', 'function makeInfo = rtwmakecfg()');
	fprintf(fid, '\t%s\n', 'makeInfo = lct_rtwmakecfg();');
    for Count = 1:numel(srcdirectories)
        fprintf(fid, '\t%s\n', ['makeInfo.sourcePath{', num2str(Count),'} = fullfile(path_carnot(''root''), ''', srcdirectories{Count}, ''');']);
        fprintf(fid, '\t%s\n', ['makeInfo.includePath{', num2str(Count),'} = fullfile(path_carnot(''root''), ''', srcdirectories{Count}, ''');']);
    end
    
    LibraryDirectories = LibraryFiles;
    for Count = 1:numel(LibraryDirectories)
        positions = strfind(LibraryDirectories{Count}, filesep);
        LibraryDirectories{Count} = LibraryFiles{Count}(1:positions(end)-1);
    end
    LibraryDirectories = unique(LibraryDirectories);
    for Count = 1:numel(LibraryDirectories)
        fprintf(fid, '\t%s\n', ['makeInfo.sourcePath{', num2str(Count)+numel(srcdirectories),'} = fullfile(path_carnot(''root''), ''', LibraryDirectories{Count}, ''');']);
        fprintf(fid, '\t%s\n', ['makeInfo.includePath{', num2str(Count)+numel(srcdirectories),'} = fullfile(path_carnot(''root''), ''', LibraryDirectories{Count}, ''');']);
    end
    

    for Count = 1:numel(LibraryFiles)
        positions = strfind(LibraryFiles{Count}, filesep);
        filename = LibraryFiles{Count}(positions(end)+1:end);
        filename = strrep(filename, '.c', '');
        directory = LibraryFiles{Count}(1:positions(end)-1);
        fprintf(fid, '\t%s\n', ['makeInfo.library(', num2str(Count), ').Name=''', filename, ''';']);
        fprintf(fid, '\t%s\n', ['makeInfo.library(', num2str(Count), ').Location=fullfile(path_carnot(''root''), ''', directory, ''');']);
        fprintf(fid, '\t%s\n', ['makeInfo.library(', num2str(Count), ').Modules{1}=''', filename, ''';']);
    end
    
	fprintf(fid, '\t%s\n', 'makeInfo.precompile=0;');
    
    fprintf(fid, '%s\n', 'end');
    fclose(fid);
end
