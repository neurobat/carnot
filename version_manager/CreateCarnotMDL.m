function CreateCarnotMDL
% function CreateCarnotMDL
% Use this function to assemle the atomic libraries in the public
% and internal folder to carnot.slx.

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

    VersionManagerDirectory = pwd;
    addpath(pwd);
    cd('..');

    %%set up paths
    CarnotDirectory = pwd;
    LibDirectoryPublic=[CarnotDirectory,'\public\library_simulink'];
    LibDirectoryInternal=[CarnotDirectory,'\internal\library_simulink'];
    
    %%set up information
    CarnotVersion='6.0.0';
    CarnotAnnotation='Carnot 6.0';
    SimulinkVersion='R2013b';
    Copyright='Copyright Solar-Institute Juelich';
    
    %%close all libaries
    bdclose('all');
    
    %%check if carnot already existis
    if exist('carnot.mdl','file') || exist('carnot.slx','file')
        button = questdlg('Carnot already exists. ','Question','abort','delete','rename','abort');
        if strcmpi(button, 'delete')
            
        elseif strcmpi(button, 'rename')
            defAns{1,1} = 'carnot_old.mdl';
            ok=false;
            while (ok==false)
                newName = inputdlg('Please enter the filename:','Filename:',1,defAns);
                if isempty(newName)
                    fprintf('aborted\n');
                    return;
                end
                defAns{1,1}=newName{1};
                if length(dir(newName{1})) == 0
                    ok=true;
                    if exist('carnot.mdl','file')
                        movefile('carnot.mdl', newName{1});
                    end
                    if exist('carnot.slx','file')
                        movefile('carnot.slx', newName{1});
                    end
                else
                    uiwait(msgbox('File already exists.'));
                end
            end
        else
            error('Aborting ...')
        end
    end

    
    %%create new carnot libary file
    
    new_system('carnot','Library');
    
    %%add auxblocks
    add_block('built-in/SubSystem','carnot/Help');
    set_param('carnot/Help','Position', [30 118 58 146]);
    set_param('carnot/Help','OpenFcn','manual');
    set_param('carnot/Help','MaskDisplay','disp(''?'');');
    
    add_block('built-in/SubSystem','carnot/License');
    set_param(gcb,'Position', [216 111 388 161]);
    set_param('carnot/License','ShowName','off');
    set_param('carnot/License','MaskDisplay',['disp(''',CarnotAnnotation,'\n','for MATLAB ',SimulinkVersion,'\n',Copyright,''');']);
    MyText=sprintf('%s\n\t%s\n\t%s\n\t%s\n\t%s\n\t%s\n\t%s\n\t%s\n\t%s\n\t%s\n\t%s\n\t%s\n\n%s\n%s\n',...
        'This file is part of the CARNOT Blockset.',...
        'Copyright (c) 1998-2015, Solar-Institute Juelich of the FH Aachen.',...
        'Additional Copyright for file and models see list auf authors.',...
        'All rights reserved.',...
        'Redistribution and use in source and binary forms, with or without ',...
        'modification, are permitted provided that the following conditions are met:',...
        '1. Redistributions of source code must retain the above copyright notice, ',...
        '   this list of conditions and the following disclaimer.',...
        '2. Redistributions in binary form must reproduce the above copyright ',...
        '   notice, this list of conditions and the following disclaimer in the ',...
        '   documentation and//or other materials provided with the distribution.',...
        '3. Neither the name of the copyright holder nor the names of its ',...
        '   contributors may be used to endorse or promote products derived from ',...
        '   this software without specific prior written permission.',...
        'THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" ',...
        'AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE ',...
        'IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ',...
        'ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE ',...
        'LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR ',...
        'CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF ',...
        'SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS ',...
        'INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN ',...
        'CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ',...
        'ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF ',...
        'THE POSSIBILITY OF SUCH DAMAGE.');
    add_block('built-in/Note',['carnot/License/',MyText], 'Position', [50 0 20 0],'FontSize',12,'HorizontalAlignment','left');


    add_block('built-in/SubSystem','carnot/examples');
    set_param(gcb,'Position', [510 114 623 157]);
    set_param('carnot/examples','OpenFcn', ...
        sprintf('filepath = ''\\public\\tutorial\\examples'';\noldpath = pwd;\ncd(fullfile(path_carnot(''root''),filepath));\n[filename, pathname, filterindex] = ...\nuigetfile( { ''*.mdl'', ...\n''house examples''; ...\n''*.mdl'',''MAT-files (*.mat)''; ...\n''*.*'',  ''All Files (*.*)''},  ''Pick an example'');\nif (filterindex > 0)\n   open_system(fullfile(pathname,filename));\nend\ncd(oldpath);'));
    set_param('carnot/examples','ShowName','off');
    set_param('carnot/examples','MaskDisplay','disp(''double click \nto load examples'');');
    
    save_system('carnot','carnot');
    close_system('carnot', 0);
    
    %%add public blocks
    PositionPublic=AddToCarnotMDL(LibDirectoryPublic, CarnotDirectory, 0, 0,[]);
    
    %%add internal blocks
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
    else
        if numel(dir(fullfile(path_carnot('root'), 'internal', 'library_simulink'))) <= 2 % directory contains only . and ..
            DirectoriesExist = false;
        end
        if ~exist(fullfile(path_carnot('root'), 'internal', 'library_simulink', 'status.txt'), 'file')
            DirectoriesExist = false;
        end
    end
    
    if ~DirectoriesExist
        fprintf('Directories for internal models do not exist ... skipping\n');
    else
        AddToCarnotMDL(LibDirectoryInternal, CarnotDirectory, 0, 180,PositionPublic);
    end

    
    %%save library in the desired Simulink version
    %load_system('carnot');
    %save_system('carnot', 'carnot', 'ExportToVersion', SimulinkVersion);
    %close_system('carnot', 0);
    
    cd(VersionManagerDirectory);
end





