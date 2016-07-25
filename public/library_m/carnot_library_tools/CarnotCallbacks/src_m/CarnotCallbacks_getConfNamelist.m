function [namelist, lib] = CarnotCallbacks_getConfNamelist(intpath,pubpath)
% [namelist, lib] = Carnot_getConfNamelist_Callbacks(intpath,pubpath)
% returns the namelist for configurated blocks. 
% input: intpath - path to the *.mat files with internal parameter sets
%        pubpath - path to the *.mat files with internal parameter sets
%        csref - path to the block in the carnot library
% output: namelist - character strings of the filenames
%         lib - true, if block is still in a library
%                                                                          
% See also: --
% 
% Function Calls:
% function is used by: all _CONF blocks of Carnot
% this function calls: --
% 
% Literature: -

% all comments above appear with 'help Carnot_getConfNamelist_Callbacks' 
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
% **********************************************************************
% D O C U M E N T A T I O N
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
% author list:     hf -> Bernd Hafner
%
% version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
%
% Version   Author  Changes                                     Date
% 6.1.0     hf      created                                     18dec2014
% 6.1.1     hf      integrated "lib" as return argument         19dec2014
% 6.1.2     hf      new name CarnotCallbacks_getConfNamelist    23feb2015
% 6.1.3     hf      works also when public namelist is empty    08mar2015
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

% get public parameter files
pubfiles = dir(fullfile(pubpath,'*.mat'));
% set names in the popup mask
if ~isempty(pubfiles)
    namelist = pubfiles(1).name(1:end-4);
end

% if not in the library any more, add internal parameters sets to the list
if  BlockIsInCarnotLibrary       % if located in library
    lib = true;
else
    lib = false;
    intfiles = dir(fullfile(intpath,'*.mat'));

    % add names from files to namelist
    for n = 2:length(pubfiles)
        namelist = [namelist,'|',pubfiles(n).name(1:end-4)];
    end
    for n = 1:length(intfiles)
        if ~exist('namelist', 'var')
            namelist = intfiles(n).name(1:end-4);
        else
            namelist = [namelist,'|',intfiles(n).name(1:end-4)];
        end
    end
end
