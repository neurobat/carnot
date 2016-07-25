function helpcarnot(varargin)
% helpcarnot(brosertype) opens the CARNOT manual from the command line
% optional parameter
%   browsertype     'browser' - opens help page in sytem web browser
%                   no value  - Matlab help browser
%                   'xx'      - any other string: Matlab help browser

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
%<topic> is an optional string variable, that must correspond exactly to the 
%blockname about that you want to receive Online help.
% 
% Author    Date        Description
% FarG      2010-02-28  created
% wic       2014-11-04  modified path to comply with carnot 6.0 folder
%                       structure
%  hf       2015-02-21  removed parameter 'page', use web command

if nargin == 0
    web(fullfile(path_carnot('help'),'Manual.html'),'-helpbrowser')
elseif strcmp(varargin{1},'browser')
    web(fullfile(path_carnot('help'),'Manual.html'),'-browser')
else
    web(fullfile(path_carnot('help'),'Manual.html'),'-helpbrowser')
end

