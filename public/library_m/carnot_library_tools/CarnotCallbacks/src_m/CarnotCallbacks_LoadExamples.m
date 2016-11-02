% Carnot_LoadExamples_Callbacks is a callback script to load the examples
% in the carnot/public/tutorial/examples folder
%
% Inputs:       -
% Outputs:      -
% Syntax:       Carnot_LoadExamples_Callbacks
%                                                                          
% Function Calls:
% function is used by: Examples button in the carnot library
% 
% Literature:   -

% all comments above appear with 'help Carnot_LoadExamples_Callbacks' 
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
% D O C U M E N T A T I O N
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
% Carnot model and function m-files should use a name which gives a 
% hint to the model of function (avoid names like testfunction1.m).
% 
% author list:     hf -> Bernd Hafner
%
% version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
%
% Version   Author  Changes                                     Date
% 6.1.0     hf      created from callback properties            16dec2014
%                   of the example button                         
% 6.1.1     hf      added storage examples                      21dec2014
% 6.1.2     hf      mat files replaced by mdl, slx added        08jan2015
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

filepath = fullfile('public', 'tutorial', 'examples');
oldpath = pwd;                                     
cd(fullfile(path_carnot('root'),filepath))                 
[filename, pathname, filterindex] = ...            
   uigetfile( { ...
   'example*.*', 'all examples'; ...                           
   'example_house*.*', 'house models'; ...                           
   'example_storage*.*', 'storage examples'; ...                           
   '*.mdl','models (*.mdl)'; ...                
   '*.slx','models (*.slx)'; ...                
   '*.*',  'All Files (*.*)'},  ...
   'Pick a Carnot example');
if (filterindex > 0)                               
   open_system(fullfile(pathname,filename))        
end                                                
cd(oldpath)                                        