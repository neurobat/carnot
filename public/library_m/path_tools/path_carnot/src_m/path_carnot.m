function p = path_carnot(ctrl)
%PATH_CARNOT Management and definition of paths for carnot release 6.0
%   PATH_CARNOT() lists the defined paths and their SHORTCUTs 
%       (as defined by the cell array 'carnotpaths').  
%   PATH_CARNOT(SHORTCUT) returns the full path (on your machine) 
%       corresponding to the specified SHORTCUT.
%   PATH_CARNOT('setpaths') adds the paths needed for carnot to run to
%       your MATLAB path

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
% $Revision$
% $Author$
% $Date$
% $HeadURL$
% **********************************************************************
% Copyright (c) 1998-2014 Solar-Institut Juelich, Germany
% 
% Author   Date         Description
% hf       2014-02-03   initial version
% PahM     2014-07-10   rework path management
% PahM     2014-08-12   move to scripts; add documentation
% hf       2014-12-16   renamed to path_carnot (old name path_carnot_6)
% pahm     2015-06-02   changed cd('..\..')

% find root path of carnot
if exist('carnot','file') == 4
    rootpath = fileparts(which('carnot'));
else % paths might not be added yet, so carnot.mdl won't be found
    warning('MATLAB:Path', ...
        'carnot.mdl could not be found. Possibly its path has not been added yet. Trying to continue with alternative method.')
    ptemp = pwd;
    % assume we're in rootpath/public/srs_m
    cd([fileparts(mfilename('fullpath')) filesep '..' filesep '..']);
    if exist('carnot','file') ~= 4
        error('carnot.slx (or .mdl) could not be found. Check consistency of your installation and subpaths or use init_carnot.m first.')
    end
    rootpath = pwd;
    cd(ptemp)
end

% define standardized carnot paths
carnotpaths = {...
    'root'      fullfile(rootpath);...
    'pub'       fullfile(rootpath,'public');...
    'int'       fullfile(rootpath,'internal');...
    'src'       fullfile(rootpath,'public','src');...
    'intsrc'    fullfile(rootpath,'internal','src');...
    'bin'       fullfile(rootpath,'public','bin');...
    'intbin'    fullfile(rootpath,'internal','bin');...
    'm'         fullfile(rootpath,'public','src_m');...
    'intm'      fullfile(rootpath,'internal','src_m');...
    'data'      fullfile(rootpath,'public','data');...
    'intdata'   fullfile(rootpath,'internal','data');...
    'help'      fullfile(rootpath,'public','tutorial','doc');...
    'inthelp'   fullfile(rootpath,'internal','tutorial','doc');...
    'vm'        fullfile(rootpath,'version_manager');...
    'libc'      fullfile(rootpath,'public','library_c');...
    'libsl'     fullfile(rootpath,'public','library_simulink');...
    'intlibc'   fullfile(rootpath,'internal','library_c');...
    'intlibsl'  fullfile(rootpath,'internal','library_simulink');...
    'carlibsrc' fullfile(rootpath,'public','library_c','carlib','src');
    };

% display paths and break if no argin specified
if nargin < 1
    disp(carnotpaths)
    error('Input argument missing. Specify path reference or ''setpaths''')
end

% set paths mode: adds carnot paths to matlab path
if strcmp(ctrl,'setpaths')
    % specify which paths should be added
    paths2add = { ...               %first to add is last in path
        %'help','inthelp', ...    
        'src','intsrc', ...
        'm','intm', ...
        'data','intdata', ...
        'bin','intbin',...
        'root','int', ...
        };
    disp('Adding CARNOT paths...')
    for i = 1:length(paths2add)
        for j = 1:size(carnotpaths,1)
            if strcmp(carnotpaths(j,1),paths2add(i))
                addpath(cell2mat(carnotpaths(j,2)))
                disp(['  ... ' cell2mat(carnotpaths(j,2))])
                break
            end
        end
    end
else % return demanded path as string
    for i = 1:size(carnotpaths,1)
        if strcmp(carnotpaths(i,1),ctrl)
            p = cell2mat(carnotpaths(i,2));
            break
        end
    end
end