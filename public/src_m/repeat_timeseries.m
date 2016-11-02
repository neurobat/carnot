function y = repeat_timeseries(u, n)
% y = repeat_timeseries(u,n))
% Inputs:       u - original matrix, first column must be the time in s
%               n - repeat the matrix n times
% Outputs:      y - matrix with n times the matrix u, time is in increasing
%                   order
% Description:  Repeat the matrix u for n times, keep the time in the first
%               column in ascending oder. 
%
% See also: --
% Function Calls: --
% Literature: --

% all comments above appear with 'help repeat_timeseries' 
% *************************************************************************
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
% *************************************************************************
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
% 6.1.0     hf      created                                     05oct2014
%
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

% ---- check input arguments ----------------------------------------------
if nargin ~= 2
    help repeat_timeseries
    error('repeat_timeseries:%s',' check numer of input arguments')
end

% --------- start main calculation ----------------------------------------
% get initial and final time
t = u(:,1);         % get time from first column
tstart = t(1);
tend = t(end);

if tstart == 0              % when timeseries starts with 0
    uu = u(1:end-1,:);      % skip last line when series starts with 0
else                        % else: timeseries start above 0
    uu = u;      % skip last line when series starts with 0
end

[nrow, ncol] = size(uu); 
y = repmat(uu,n,1);   % matrix is a repetition of the original matrix
t0 = 0:tend:(n-1)*tend;
tt = ones(nrow,1)*t0;
tt = reshape(tt,[],1);

y(:,1) = tt + y(:,1);

