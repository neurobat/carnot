function B = CarnotCallbacks_CondensingBoilerConf(parameterfile)
% Carnot_StorageConf_Callbacks(storagetype,parameterfile)
% Inputs:                                                              
% Output:                                                                  
% Description:  
%
% See also: --
% 
% Function Calls:
% function is used by: condensing_boiler
% this function calls: --
% 
% Literature: --

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
% Carnot model and function m-files should use a name which gives a 
% hint to the model of function (avoid names like testfunction1.m).
% 
% author list:      hf -> Bernd Hafner
%                   js -> Jan Strubel
%
% version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
%
% Version   Author  Changes                                     Date
% 6.1.0     hf      created                                     26jun2015
% 6.1.1     js      added try set_Param catch ...               08nov2016
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

% path definitions
intpath = fullfile(path_carnot('intlibsl'), 'Source','Boiler', ...
    'Condensing_Boiler_CONF','parameter_set');
pubpath = fullfile(path_carnot('libsl'), 'Source','Boiler', ...
    'Condensing_Boiler_CONF','parameter_set');

[namelist, lib] = CarnotCallbacks_getConfNamelist(intpath,pubpath);

if ~lib
    myMaskStylesVar{1} = ['popup(', namelist,')'];
    myMaskStylesVar{2} = 'edit';
    set_param(gcb, 'MaskStyles', myMaskStylesVar)
end

if exist(fullfile(intpath,[parameterfile '.mat']),'file')
    B = importdata(fullfile(intpath,[parameterfile '.mat']));
else
    B = importdata(fullfile(pubpath,[parameterfile '.mat']));
end

% set mask parameters for efficiency table temperature selector
a = get_param([gcb '/Condensing_Boiler'],'DialogParameters');

try
    set_param([gcb '/Condensing_Boiler'], 'whichTforEfficiency', ...
        a.whichTforEfficiency.Enum{B.whichTforEfficiency});
catch
    disp('Could not finalize call to CarnotCallbacks_CondensingBoilerConf - trying a different way...')
    hndl = getSimulinkBlockHandle([gcb '/Condensing_Boiler']);
    tstr = a.whichTforEfficiency.Enum{B.whichTforEfficiency};
    if ~strcmp(get_param(hndl, 'whichTforEfficiency'), a.whichTforEfficiency.Enum{B.whichTforEfficiency})    
        set_param(hndl, 'whichTforEfficiency', tstr);
    end
end
