function display_verification_error(x, y, ye, st, sx, sy1, sleg1, sy2, sleg2, stxt)
% Function to plot the verification error creates 2 windows showing the
% values and the resulting error.
% display_verification_error(x, y, ye, st, sx, sy1, sleg1, sy2, sleg2, stxt)
%   x - vector with x values for the plot
%   y - matrix with y-values (reference values and result of the function call)
%   ye - matrix with error values for each y-value
%   st - string with title for upper window
%   sx  - string for the x-axis label
%   sy1  - string for the y-axis label in the upper window
%   sleg1 - strings for the upper legend (number of strings must be equal to
%          number of columns in y-Matrix, e.g. {'firstline','secondline'}
%   sy2 - string for the y-label of the lower window
%   sleg2 - strings for the lower legend (number of strings must be equal to
%          number of columns in y-Matrix, e.g. {'firstline','secondline'}
%   stxt - string with the verification result information
% 
% function calls:
% function is used by: verfy_<BlockNameOrFunctionName>
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
% $Revision$
% $Author$
% $Date$
% $HeadURL$
% **********************************************************************
% D O C U M E N T A T I O N
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
% author list:     hf -> Bernd Hafner
%
% version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
%
% Version   Author  Changes                                       Date
% 6.1.0     hf      created                                       17nov2013
% 6.2.1     hf      name _verification_ replaced by verification  09jan2015
% 6.2.2     hf      correct help text                             28jul2015
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

figure              % open a new figure

subplot(2,1,1)      % divide in subplots (lower and upper one)
if size(y,2) == 3
    plot(x,y(:,1),'x',x,y(:,2),'o',x,y(:,3),'-')
else
    plot(x,y,'-')
end
title(st)          
ylabel(sy1)
legend(sleg1,'Location','BestOutside')
text(0,-0.2,stxt,'Units','normalized')  % display valiation text

subplot(2,1,2)      % choose lower window
if size(y,2) == 3
    plot(x,ye(:,1),'x',x,ye(:,2),'o',x,ye(:,3),'-')
else
    plot(x,ye,'-')
end
legend(sleg2,'Location','BestOutside')
xlabel(sx)
ylabel(sy2)