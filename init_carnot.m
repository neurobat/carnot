function init_carnot()
% init_carnot() adds the paths needed for carnot to run to your MATLAB path
% see also: init_carnot_savepath

% ***********************************************************************
% This file is part of the CARNOT Blockset.
% 
% Copyright (c) 1998-2016, Solar-Institute Juelich of the FH Aachen.
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
% author list:     hf -> Bernd Hafner
%                  pahm -> Marcel Paache
% version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
%
% Version   Author  Changes                                     Date
% 6.1.0     PahM    initial revision                            2014-08-12
% 6.1.1     PahM    fixed to work with old matlab versions      2014-08-15
% 6.1.2     hf      added rehash (see also init_carnot_savepath) 2014-11-24
% 6.1.3     hf      path_carnot_6 replaced by path_carnot       2014-12-16
% 6.1.3     pahm    added fprintf commands                      2016-01-12
% 6.1.4     hf      update of file documentation                2016-01-26
% 6.1.5     pahm    added OS check and 32bit check              2016-08-09

fprintf('################################################\n*Initializing CARNOT Toolbox\n\n')

cpath = pwd;
cd([fileparts(mfilename('fullpath')) filesep 'public' filesep 'src_m'])
path_carnot('setpaths')
rehash;
fprintf('\n*done\n\n')

% get names of compiled S-functions
cd(path_carnot('bin'))
binfiles = dir;
binfiles = struct2cell(binfiles);
binfiles = binfiles(1,:)';
% check OS
if isempty(strfind(computer,'PCWIN')) % non-Windows OS
    disp('It seems you are running MATLAB on a non-Windows OS. Please make sure you have got all S-functions recompiled for your platform (Linux, Mac).')
elseif  strcmp(computer,'PCWIN') && isempty(cell2mat(strfind(binfiles,'mexw32'))) % running 32bit MATLAB without mexw32-files
    warning('It seems you are running a 32bit MATLAB session without appropriate mex-files (compiled S-functions). Please use 64bit MATLAB or get a matching set of mexw32 files.')
end

% return
cd(cpath)
% hint on doc
fprintf('\nType "helpcarnot" to access the CARNOT documentation.\nSee ...\\<CARNOT>\\public\\tutorial\\guidelines to check guidelines applicable to CARNOT.\n################################################\n')