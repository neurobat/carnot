function v = velocity(t,p,fluid,mix,d,mdot)
% function velocity(t,p,fluid,mix,d,mdot)                         
%  (Simulink Block and m-function)                                                                
%  Calculates the velocity in a pipe according to the inputs:      
%                                                                  
%     * temperature [degree centigrade]                            
%     * pressure [Pa]                                              
%     * fluid_ID (see below)                                       
%     * fluid_mix percentage                                       
%     * inner pipe diameter in [m]                                 
%     * mass flow rate [kg/s]                                       
%                                                                  
% and the relation v = mdot/(density*cross section)
%                                                                  
%  Definition of the fluid types                                   
%   fluid_ID  fluid          remarks                                   
%   1         water                                                  
%   2         air                                                    
%   3         cotton oil                                             
%   4         silicone oil                                           
%   5         water-glycol   fluid_mix gives the percentage of glycol  

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

v = mdot./(density(t,p,fluid,mix).*pi.*(d./2).^2);
