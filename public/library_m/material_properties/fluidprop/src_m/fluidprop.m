%fluidprop (temperature, pressure, fluid_type, fluid_mix,property_ID)
%
%Purpose
%Interface to make the property functions from the Carlib Library
%accessible from the matlab command window.
%
%Description
%fluidprop is a C-MEX function to make the property function of the
%Carlib Library accessible from the MATLAB Command window. In the
%Carnot main directory, m-function that are named like the SIMULINK
%material blocks are contained. (density.m, heat_capacity.m.etc.)
%These m-functions use fluidprop as interface to use the property
%functions of the Carlib Library. The function call in the m-function
%is
%
%density (temperature, pressure, fluid_type, fluid_mix)
%
%i.e. with the same variable as in the Simulink blocks.
%Internally the MEX-function fluidprop is called
%
%rho = fluidprop (temperature, pressure, fluid_type, fluid_mix, property_ID)
%
%The property_ID defines the property, e.g the density, that you want
%to be promted. For the definition of the property_ID see chapter 2.1
%of the manual (Carnot vector definitions).
%The function call of can also be performed directly from the MATLAB
%command window:
%
%fluidprop (temperature, pressure, fluid_type, fluid_mix, property_ID)
%
%If you call fluidprop with a respective negative property_ID, the function
%returns the saturationproperties of the respective property in
%vectorial form. The first output component is the value for saturated
%steam at the specified conditions, the second value the one of boiling
%fluid. To get the saturationproperty the function call of fluidprop
%has to be effectuated in the following way:
%
%fluidprop (temp, pres, fluid_id, fluid_mix, property_type = -1)
%
%More detailed information about the function fluidprop are in the manual.
%
%All material functions are vectorised, they can be specified with more
%than one fluid property, i.e. with a vector of temperatures. In this
%case either all input vectors must be of the same length or they must
%be a scalar. A scalar is interpreted as a vector, which contains the
%adequate number of components of the specified value.

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
% Version   Author  Changes                                     Date
% 1.0.0     hf      created                                     1999
% 6.1.0     hf      updated help text and error handling        03oct2014