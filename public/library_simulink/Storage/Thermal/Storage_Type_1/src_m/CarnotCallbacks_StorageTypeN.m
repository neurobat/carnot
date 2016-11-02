function [standing, dh, height, mpts, tini] ...
    = CarnotCallbacks_StorageTypeN(pos, volume, dia, nodes,mpoints,t0)
% [standing, dh, height, mpts, tini] ...
%     = Carnot_StorageTypeN_CallBacks(pos, volume, dia, nodes, mpoints, t0)
% Inputs:   pos - 1 = horizontal cylinder; 2 = vertical cylinder
%           volume - volume of water in m³
%           dia - diameter of cylinder in m
%           nodes - number of nodes in the storage model     
%           mpoints - number of measurement points
%           t0 - initial temperature vector [°C]
%                                                                      
% Output:   standing - true, if vertical cyliner
%           dh - height of one node in m
%           height - height of storage tank in m
%           mpts - vector with relative postion of measurement points
%           tini - initial temperature vector of length nodes
%                                                                          
% Description:  stes geometry values and sets the initial temperature 
%           vector to a vector with the length of the storage nodes. 
%           The input initial temperature vector can be of any size.
%
% See also: --
% 
% Function Calls:
% function is used by: storage mask (Storage_Type_1 ... Storage_Type_5)
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
% Carnot model and function m-files should use a name which gives a 
% hint to the model of function (avoid names like testfunction1.m).
% 
% author list:     hf -> Bernd Hafner
%
% version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
%
% Version  Author  Changes                                      Date
% 6.1.0    hf      created                                      03oct2014
% 6.1.1    hf      help text corrected                          20dec2014
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

standing = pos-1;

if standing
    dh = volume/(0.25*dia^2*pi*nodes);
else
    dh = dia/nodes;
end

height = dh*nodes;

mpoints = max(mpoints,1);
mpts = round(nodes/mpoints/2:nodes/mpoints:nodes);

% nodes = 88; % only for test
% t0 = 10:5:55; % only for test

n0 = length(t0);
x = linspace(0,1,n0);
xx = linspace(0,1,nodes);
if n0 > 1
    tini = spline(x,t0,xx);
else
    tini = ones(1,nodes).*t0;
end

% plot(x,y,'o',xx,yy,'x') % only for test