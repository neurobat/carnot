function v = verification_carnot(~)
% v = verification_carnot 
% Calls all verify_*.m functions. It uses dir2 to search for all 
% verification functions (verify_*.m) and than calls the functions. 
% Result is true (1) when verification passed, false (0) otherwise.
% Input:        none
% Output:       v - True if verification is ok, False otherwise
% Syntax:       v = verification_carnot
%                                                                          
% Function Calls:
% function is used by: --
% this function calls: dir2, verify_*.m
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
% $Revision$
% $Author$
% $Date$
% $HeadURL$
% **********************************************************************
% D O C U M E N T A T I O N
% author list:     hf -> Bernd Hafner
% version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
% Version   Author  Changes                                     Date
% 6.1.0     hf      created                                     02apr2014
% 6.1.1     hf      including printout to screen                25jul2014
% 6.1.2     hf      path_carnot_6 replaced by path_carnot       16dec2014
% 6.1.3     hf      validate_ replaced by verify_               09jan2015
%                   function name changed to verification_
% 6.1.4     hf      modified help text                          28jul2915
% **********************************************************************

disp('--- starting verification of CARNOT library and functions ---')
old_wd = pwd;                   % keep current working directory
car_wd = path_carnot('root'); % get carnot root directory

% get all files which start with validate_ with the recursive search dir2
% d2 = dir2(car_wd,'-r','template_verify_*.m'); % only for test
d2 = dir2(car_wd,'-r','verify_*.m');

ntot = length(d2);              % number of functions to validate
vtot = true;                    % result of all verifications
v = true;                       % be optimistic, assume that it is ok

for n = 1:ntot
    [fd, fn] = fileparts(fullfile(car_wd,d2(n).name));
    cd(fd)
    eval(['[v, s1] = ' fn ';'])
    s2 = sprintf('%i of %i: %s \n', n, ntot, s1);
    disp(s2)
    if v == false
        vtot = false;
        break                   % force end of loop
    end
end

if vtot == true
    disp('**** Verification of CARNOT library and functions passed ****')
else
    disp('!!!!! VERIFICATION OF CARNOT LIBRARY AND FUNCTIONS FAILED !!!!!')
end

cd(old_wd)                      % go back to old working directory