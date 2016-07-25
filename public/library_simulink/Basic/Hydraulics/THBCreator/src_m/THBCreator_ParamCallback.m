function THBCreator_ParamCallback
% Parameter callback for the block THBCreator
% Inputs: -
% Syntax:       THBCreator_ParamCallback
%                                                                          
% Description:  Used by the block "THBCreator" to set the mask parameters
% (callback of each mask parameter)

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
% author list:     aw -> Arnold Wohlfeil
%
% version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
%
% Version  Author  Changes                                     Date
% 5.1.0    aw      created                                     30aug2013
%
% Copyright (c) Solar-Institut Juelich, Germany
%
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *


    MaskValues = get_param(gcb,'MaskValues');
    MaskVisibilities={'on';'on';'on';'on';'on';'on';'on';'on';'on';'on';'on';'on';'on';'on';'on';'on';'on';'on';'on';'on';'on';'on';'on';'on';'on';'on';'on';'on';'on';'on';'on';'on';'on';'on';'on';'on'};

    %deactivate parameters

    if strcmp(MaskValues{1},'on') %ID
        MaskVisibilities{13}='off';
        MaskVisibilities{25}='off';
    end
    
    if strcmp(MaskValues{2},'on') %T
        MaskVisibilities{14}='off';
        MaskVisibilities{26}='off';
    end
    
    if strcmp(MaskValues{3},'on') %mdot
        MaskVisibilities{15}='off';
        MaskVisibilities{27}='off';
    end
    
    if strcmp(MaskValues{4},'on') %p
        MaskVisibilities{16}='off';
        MaskVisibilities{28}='off';
    end
    
    if strcmp(MaskValues{5},'on') %type
        MaskVisibilities{17}='off';
        MaskVisibilities{29}='off';
    end
    
    if strcmp(MaskValues{6},'on') %mix
        MaskVisibilities{18}='off';
        MaskVisibilities{30}='off';
    end
    
    if strcmp(MaskValues{7},'on') %d
        MaskVisibilities{19}='off';
        MaskVisibilities{31}='off';
    end
    
    if strcmp(MaskValues{8},'on') %c
        MaskVisibilities{20}='off';
        MaskVisibilities{32}='off';
    end
    
    if strcmp(MaskValues{9},'on') %l
        MaskVisibilities{21}='off';
        MaskVisibilities{33}='off';
    end
    
    if strcmp(MaskValues{10},'on') %q
        MaskVisibilities{22}='off';
        MaskVisibilities{34}='off';
    end
    
    if strcmp(MaskValues{11},'on') %LH
        MaskVisibilities{23}='off';
        MaskVisibilities{35}='off';
    end

    if strcmp(MaskValues{12},'on') %H
        MaskVisibilities{24}='off';
        MaskVisibilities{36}='off';
    end

    set_param(gcb,'MaskVisibilities',MaskVisibilities);
    
    
    %annotations
    AnnotationString='';
    if ~strcmp(MaskValues{1},'on') && strcmp(MaskValues{25},'on') %ID
        if ~isempty(AnnotationString)
            AnnotationString=[AnnotationString,sprintf('\n')];
        end
        AnnotationString=[AnnotationString,'ID ',MaskValues{12}];
    end
    
    if ~strcmp(MaskValues{2},'on') && strcmp(MaskValues{26},'on') %T
        if ~isempty(AnnotationString)
            AnnotationString=[AnnotationString,sprintf('\n')];
        end
        AnnotationString=[AnnotationString,MaskValues{13}, ' °C temperature'];
    end
    
    if ~strcmp(MaskValues{3},'on') && strcmp(MaskValues{27},'on') %T
        if ~isempty(AnnotationString)
            AnnotationString=[AnnotationString,sprintf('\n')];
        end
        AnnotationString=[AnnotationString,MaskValues{14}, ' kg/s mass flow rate'];
    end
    
    if ~strcmp(MaskValues{4},'on') && strcmp(MaskValues{28},'on') %p
        if ~isempty(AnnotationString)
            AnnotationString=[AnnotationString,sprintf('\n')];
        end
        AnnotationString=[AnnotationString,MaskValues{15}, ' Pa pressure'];
    end

    if ~strcmp(MaskValues{5},'on') && strcmp(MaskValues{29},'on') %type
        if ~isempty(AnnotationString)
            AnnotationString=[AnnotationString,sprintf('\n')];
        end
        AnnotationString=[AnnotationString,'fluid type ',MaskValues{16}];
    end
    
    if ~strcmp(MaskValues{6},'on') && strcmp(MaskValues{30},'on') %mix
        if ~isempty(AnnotationString)
            AnnotationString=[AnnotationString,sprintf('\n')];
        end
        AnnotationString=[AnnotationString,MaskValues{17}, ' fluid mix'];
    end
    
    if ~strcmp(MaskValues{7},'on') && strcmp(MaskValues{31},'on') %d
        if ~isempty(AnnotationString)
            AnnotationString=[AnnotationString,sprintf('\n')];
        end
        AnnotationString=[AnnotationString,MaskValues{18}, ' m diameter last piece'];
    end
    
    if ~strcmp(MaskValues{8},'on') && strcmp(MaskValues{32},'on') %c
        if ~isempty(AnnotationString)
            AnnotationString=[AnnotationString,sprintf('\n')];
        end
        AnnotationString=[AnnotationString,MaskValues{19}, ' Pa constant pressure loss coefficient'];
    end
    
    if ~strcmp(MaskValues{9},'on') && strcmp(MaskValues{33},'on') %l
        if ~isempty(AnnotationString)
            AnnotationString=[AnnotationString,sprintf('\n')];
        end
        AnnotationString=[AnnotationString,MaskValues{20}, ' Pa/(kg/s) linear pressure loss coefficient'];
    end
    
    if ~strcmp(MaskValues{10},'on') && strcmp(MaskValues{34},'on') %q
        if ~isempty(AnnotationString)
            AnnotationString=[AnnotationString,sprintf('\n')];
        end
        AnnotationString=[AnnotationString,MaskValues{21}, ' Pa/(kg/s)² quadratic pressure loss coefficient'];
    end
    
    if ~strcmp(MaskValues{11},'on') && strcmp(MaskValues{35},'on') %LH
        if ~isempty(AnnotationString)
            AnnotationString=[AnnotationString,sprintf('\n')];
        end
        AnnotationString=[AnnotationString,MaskValues{22}, ' 1/m hydraulic inductance'];
    end
    
    if ~strcmp(MaskValues{12},'on') && strcmp(MaskValues{36},'on') %H
        if ~isempty(AnnotationString)
            AnnotationString=[AnnotationString,sprintf('\n')];
        end
        AnnotationString=[AnnotationString,MaskValues{22}, ' m geodetic height'];
    end
    
    set_param(gcb,'AttributesFormatString',AnnotationString);
    
    
    clear MaskValues MaskVisibilities AnnotationString;
end
