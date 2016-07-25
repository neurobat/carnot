function [e, ye] = calculate_verification_error(yref, ysim, r, s)
% calulates the error of a verification process for a function or model
% [e ye] = calculate_verification_error(yref, ysim, r, s)
% inputs:  
%   yref - reference ('correct') values for the result of the function
%   ysim - simulated or calculated results of the function
%   r    - 'relative' error or 'absolute' error
%   s    - 'sum' - e is the sum of the individual errors of ysim 
%          'mean' - e is the mean of the individual errors of ysim
%          'max' - e is the maximum of the individual errors of ysim
%          'last' - e is the last value in ysim
% outputs
%   e   - scalar error (absolute or relative error over the total dataset)
%   ye  - individual error (absolute or relative) of each value in y
% 
% function calls:
% function is used by: verify_<BlockNameOrFunctionName>
% this function calls: --
% 
% Literature: ---

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
% Version   Author  Changes                                       Date
% 6.1.0     hf      created                                       17nov2013
% 6.1.1     hf      'max' error calculation integrated            04oct2014
% 6.2.0     hf      'last' integrated, changed it to switch       15dec2014
% 6.2.1     hf      name verification_ replaced by verification   09jan2015
% 6.2.2     hf      separate arguments of function call by comma  28jul2015
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

[nrow, ncol, npage] = size(yref);       % input may be a matrix or array
yref = reshape(yref,1,numel(yref))';    % reshape to column vector
ysim = reshape(ysim,1,numel(ysim))';

switch s
    case 'sum'                          % error is sum of individual errors
        ye = ysim-yref;                 % error is difference of sim and ref
        e = sum(abs(ye));               % result is sum of the absolute values
        de = sum(yref);                 % sum of reference values as error is relative to sum of reference
        dye = de;                       % individual error is also relative
    case 'mean'                         % 'mean' error calculation
        ye = ysim-yref;                 % error is difference of sim and ref
        e = mean(abs(ye));              % error is mean of absolute individual values
        de = mean(yref);                % error is mean of error divided by mean of reference
        dye = yref;                     % individual error is error value divided by reference
    case 'max'                          % 'max' error calculation    
        ye = ysim-yref;                 % error is difference of sim and ref
        e = max(abs(ye));               % error is maximum of absolute individual values
        de = mean(yref);                % error is mean of error divided by mean of reference
        dye = yref;                     % individual error is error value divided by reference
    case 'last'                         % 'last' error calculation    
        ye = ysim-yref;                 % error is difference of sim and ref
        ea = abs(ye(end));              % error is from the last values
        e = repmat(ea,numel(yref),1);   % make it a matrix
        de = yref(end);                 % error is mean of error divided by mean of reference
        dye = yref(end);                % individual error is error value divided by reference
    otherwise                           % default error calculation    
        ye = ysim-yref;                 % error is difference of sim and ref
        e = max(abs(ye));               % error is maximum of absolute individual values
        de = mean(yref);                % error is mean of error divided by mean of reference
        dye = yref;                     % individual error is error value divided by reference
end

if (strcmp(r,'relative'))       % if relative error is wanted
    e = e./de;                  % error is relative to sum of reference
    ye = ye./dye;               % individual error is also relative
end

ye = reshape(ye,nrow,ncol,npage);   % reshape result to original yref format

