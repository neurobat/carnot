function varargout = CarnotCallbacks_THBCreator(varargin)
% function varargout = CarnotCallbacks_THBCreator(varargin) is used by the
% Carnot THBCreator blocks. 
% The file contains also other subfunctions:
% function CreateMaskAnnotations(block)
% function CreateMaskVisibilities(block)
% function CreateInports(block)
%
%
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
% Version   Author  Changes                                     Date
% 6.1.0     aw      created                                     21sep2016
%
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

% Switch for command line calls
    if nargin >= 1 && ischar(varargin{1})
        FunctionName = varargin{1};

        % Call the function
        if nargout > 0
            [varargout{1:nargout}] = feval(FunctionName, varargin{2:end});
        else
            feval(FunctionName, varargin{2:end});
        end
    else
        error('First argument must be a valid function name. Second argument must be the blockpath.')
        
    end
end



function CreateMaskVisibilities(block)
    MaskValues = get_param(block, 'MaskValues');
    MaskVisibilities={'on';'on';'on';'on';'on';'on';'on';'on';'on';'on'; ...
                      'on';'on';'on';'on';'on';'on';'on';'on';'on';'on'; ...
                      'on';'on';'on';'on';'on';'on';'on';'on';'on';'on'; ...
                      'on';'on';'on';'on';'on';'on';'on';'on';'on';'on'; ...
                      'on';'on'};

    %deactivate parameters

    if strcmp(MaskValues{1},'on') %ID
        MaskVisibilities{15}='off';
        MaskVisibilities{29}='off';
    end
    
    if strcmp(MaskValues{2},'on') %T
        MaskVisibilities{16}='off';
        MaskVisibilities{30}='off';
    end
    
    if strcmp(MaskValues{3},'on') %mdot
        MaskVisibilities{17}='off';
        MaskVisibilities{31}='off';
    end
    
    if strcmp(MaskValues{4},'on') %p
        MaskVisibilities{18}='off';
        MaskVisibilities{32}='off';
    end
    
    if strcmp(MaskValues{5},'on') %type
        MaskVisibilities{19}='off';
        MaskVisibilities{33}='off';
    end
    
    if strcmp(MaskValues{6},'on') %mix
        MaskVisibilities{20}='off';
        MaskVisibilities{34}='off';
    end
    
    if strcmp(MaskValues{7},'on') %mix2
        MaskVisibilities{21}='off';
        MaskVisibilities{35}='off';
    end
    
    if strcmp(MaskValues{8},'on') %mix3
        MaskVisibilities{22}='off';
        MaskVisibilities{36}='off';
    end
    
    if strcmp(MaskValues{9},'on') %d
        MaskVisibilities{23}='off';
        MaskVisibilities{37}='off';
    end
    
    if strcmp(MaskValues{10},'on') %c
        MaskVisibilities{24}='off';
        MaskVisibilities{38}='off';
    end
    
    if strcmp(MaskValues{11},'on') %l
        MaskVisibilities{25}='off';
        MaskVisibilities{39}='off';
    end
    
    if strcmp(MaskValues{12},'on') %q
        MaskVisibilities{26}='off';
        MaskVisibilities{40}='off';
    end
    
    if strcmp(MaskValues{13},'on') %LH
        MaskVisibilities{27}='off';
        MaskVisibilities{41}='off';
    end

    if strcmp(MaskValues{14},'on') %H
        MaskVisibilities{28}='off';
        MaskVisibilities{42}='off';
    end

    set_param(block, 'MaskVisibilities', MaskVisibilities);
end



function CreateMaskAnnotations(block)
    %annotations
    AnnotationString='';
    MaskValues = get_param(block, 'MaskValues');
    
    if ~strcmp(MaskValues{1},'on') && strcmp(MaskValues{29},'on') %ID
        if ~isempty(AnnotationString)
            AnnotationString=[AnnotationString,sprintf('\n')];
        end
        AnnotationString=[AnnotationString,'ID ',MaskValues{15}];
    end
    
    if ~strcmp(MaskValues{2},'on') && strcmp(MaskValues{30},'on') %T
        if ~isempty(AnnotationString)
            AnnotationString=[AnnotationString,sprintf('\n')];
        end
        AnnotationString=[AnnotationString,MaskValues{16}, ' °C temperature'];
    end
    
    if ~strcmp(MaskValues{3},'on') && strcmp(MaskValues{31},'on') %T
        if ~isempty(AnnotationString)
            AnnotationString=[AnnotationString,sprintf('\n')];
        end
        AnnotationString=[AnnotationString,MaskValues{17}, ' kg/s mass flow rate'];
    end
    
    if ~strcmp(MaskValues{4},'on') && strcmp(MaskValues{32},'on') %p
        if ~isempty(AnnotationString)
            AnnotationString=[AnnotationString,sprintf('\n')];
        end
        AnnotationString=[AnnotationString,MaskValues{18}, ' Pa pressure'];
    end

    if ~strcmp(MaskValues{5},'on') && strcmp(MaskValues{33},'on') %type
        if ~isempty(AnnotationString)
            AnnotationString=[AnnotationString,sprintf('\n')];
        end
        AnnotationString=[AnnotationString,'fluid type ',MaskValues{19}];
    end
    
    if ~strcmp(MaskValues{6},'on') && strcmp(MaskValues{34},'on') %mix
        if ~isempty(AnnotationString)
            AnnotationString=[AnnotationString,sprintf('\n')];
        end
        AnnotationString=[AnnotationString,MaskValues{20}, ' fluid mix'];
    end
    
    if ~strcmp(MaskValues{7},'on') && strcmp(MaskValues{35},'on') %mix2
        if ~isempty(AnnotationString)
            AnnotationString=[AnnotationString,sprintf('\n')];
        end
        AnnotationString=[AnnotationString,MaskValues{21}, ' fluid mix2'];
    end
    
    if ~strcmp(MaskValues{8},'on') && strcmp(MaskValues{36},'on') %mix3
        if ~isempty(AnnotationString)
            AnnotationString=[AnnotationString,sprintf('\n')];
        end
        AnnotationString=[AnnotationString,MaskValues{22}, ' fluid mix3'];
    end
    
    if ~strcmp(MaskValues{9},'on') && strcmp(MaskValues{37},'on') %d
        if ~isempty(AnnotationString)
            AnnotationString=[AnnotationString,sprintf('\n')];
        end
        AnnotationString=[AnnotationString,MaskValues{23}, ' m diameter last piece'];
    end
    
    if ~strcmp(MaskValues{10},'on') && strcmp(MaskValues{38},'on') %c
        if ~isempty(AnnotationString)
            AnnotationString=[AnnotationString,sprintf('\n')];
        end
        AnnotationString=[AnnotationString,MaskValues{24}, ' Pa constant pressure loss coefficient'];
    end
    
    if ~strcmp(MaskValues{11},'on') && strcmp(MaskValues{39},'on') %l
        if ~isempty(AnnotationString)
            AnnotationString=[AnnotationString,sprintf('\n')];
        end
        AnnotationString=[AnnotationString,MaskValues{25}, ' Pa/(kg/s) linear pressure loss coefficient'];
    end
    
    if ~strcmp(MaskValues{12},'on') && strcmp(MaskValues{40},'on') %q
        if ~isempty(AnnotationString)
            AnnotationString=[AnnotationString,sprintf('\n')];
        end
        AnnotationString=[AnnotationString,MaskValues{26}, ' Pa/(kg/s)² quadratic pressure loss coefficient'];
    end
    
    if ~strcmp(MaskValues{13},'on') && strcmp(MaskValues{41},'on') %LH
        if ~isempty(AnnotationString)
            AnnotationString=[AnnotationString,sprintf('\n')];
        end
        AnnotationString=[AnnotationString,MaskValues{27}, ' 1/m hydraulic inductance'];
    end
    
    if ~strcmp(MaskValues{14},'on') && strcmp(MaskValues{42},'on') %H
        if ~isempty(AnnotationString)
            AnnotationString=[AnnotationString,sprintf('\n')];
        end
        AnnotationString=[AnnotationString,MaskValues{28}, ' m geodetic height'];
    end
    
    set_param(block, 'AttributesFormatString',AnnotationString);
end


function CreateInports(block)
    MaskValue = get_param(block,'MaskValues');

    if strcmp(MaskValue{1},'on') %ID
        if ~strcmp(get_param([block,'/ID'],'BlockType'),'Inport')
            delete_line(block,'ID/1','BusCreator/1'); %delete connection
            delete_block([block,'/ID']); %delete block
            add_block('built-in/Inport',[block,'/ID']); %add new block
            set_param([block, '/ID'],'Position',[50   1*50+8   50+30   1*50+8+14]); %set new block's position
            add_line(block,'ID/1','BusCreator/1'); %add new connection
            handles=get_param([block, '/ID'],'LineHandles'); %get line handles
            set(handles.Outport(1),'Name','ID'); %set line name
        end
    else
        if ~strcmp(get_param([block,'/ID'],'BlockType'),'Constant')
            delete_line(block,'ID/1','BusCreator/1'); %delete connection
            delete_block([block,'/ID']); %delete block
            add_block('built-in/Constant',[block,'/ID']); %add new block
            set_param([block, '/ID'],'Position',[50   1*50   50+30   1*50+30]); %set new block's position
            set_param([block, '/ID'],'Value','ID'); %set mask varible as value
            add_line(block,'ID/1','BusCreator/1'); %add new connection
            handles=get_param([block, '/ID'],'LineHandles'); %get line handles
            set(handles.Outport(1),'Name','ID'); %set line name
        end
    end

    if strcmp(MaskValue{2},'on') %T
        if ~strcmp(get_param([block,'/Temperature'],'BlockType'),'Inport')
            delete_line(block,'Temperature/1','BusCreator/2'); %delete connection
            delete_block([block,'/Temperature']); %delete block
            add_block('built-in/Inport',[block,'/Temperature']); %add new block
            set_param([block, '/Temperature'],'Position',[50   2*50+8   50+30   2*50+8+14]); %set new block's position
            add_line(block,'Temperature/1','BusCreator/2'); %add new connection
            handles=get_param([block, '/Temperature'],'LineHandles'); %get line handles
            set(handles.Outport(1),'Name','Temperature'); %set line name
        end
    else
        if ~strcmp(get_param([block,'/Temperature'],'BlockType'),'Constant')
            delete_line(block,'Temperature/1','BusCreator/2'); %delete connection
            delete_block([block,'/Temperature']); %delete block
            add_block('built-in/Constant',[block,'/Temperature']); %add new block
            set_param([block, '/Temperature'],'Position',[50   2*50   50+30   2*50+30]); %set new block's position
            set_param([block, '/Temperature'],'Value','T'); %set mask varible as value
            add_line(block,'Temperature/1','BusCreator/2'); %add new connection
            handles=get_param([block, '/Temperature'],'LineHandles'); %get line handles
            set(handles.Outport(1),'Name','Temperature'); %set line name
        end
    end

    if strcmp(MaskValue{3},'on') %MassFlow
        if ~strcmp(get_param([block,'/MassFlow'],'BlockType'),'Inport')
            delete_line(block,'MassFlow/1','BusCreator/3'); %delete connection
            delete_block([block,'/MassFlow']); %delete block
            add_block('built-in/Inport',[block,'/MassFlow']); %add new block
            set_param([block, '/MassFlow'],'Position',[50   3*50+8   50+30   3*50+8+14]); %set new block's position
            add_line(block,'MassFlow/1','BusCreator/3'); %add new connection
            handles=get_param([block, '/MassFlow'],'LineHandles'); %get line handles
            set(handles.Outport(1),'Name','MassFlow'); %set line name
        end
    else
        if ~strcmp(get_param([block,'/MassFlow'],'BlockType'),'Constant')
            delete_line(block,'MassFlow/1','BusCreator/3'); %delete connection
            delete_block([block,'/MassFlow']); %delete block
            add_block('built-in/Constant',[block,'/MassFlow']); %add new block
            set_param([block, '/MassFlow'],'Position',[50   3*50   50+30   3*50+30]); %set new block's position
            set_param([block, '/MassFlow'],'Value','mdot'); %set mask varible as value
            add_line(block,'MassFlow/1','BusCreator/3'); %add new connection
            handles=get_param([block, '/MassFlow'],'LineHandles'); %get line handles
            set(handles.Outport(1),'Name','MassFlow'); %set line name
        end
    end

    if strcmp(MaskValue{4},'on') %Pressure
        if ~strcmp(get_param([block,'/Pressure'],'BlockType'),'Inport')
            delete_line(block,'Pressure/1','BusCreator/4'); %delete connection
            delete_block([block,'/Pressure']); %delete block
            add_block('built-in/Inport',[block,'/Pressure']); %add new block
            set_param([block, '/Pressure'],'Position',[50   4*50+8   50+30   4*50+8+14]); %set new block's position
            add_line(block,'Pressure/1','BusCreator/4'); %add new connection
            handles=get_param([block, '/Pressure'],'LineHandles'); %get line handles
            set(handles.Outport(1),'Name','Pressure'); %set line name
        end
    else
        if ~strcmp(get_param([block,'/Pressure'],'BlockType'),'Constant')
            delete_line(block,'Pressure/1','BusCreator/4'); %delete connection
            delete_block([block,'/Pressure']); %delete block
            add_block('built-in/Constant',[block,'/Pressure']); %add new block
            set_param([block, '/Pressure'],'Position',[50   4*50   50+30   4*50+30]); %set new block's position
            set_param([block, '/Pressure'],'Value','p'); %set mask varible as value
            add_line(block,'Pressure/1','BusCreator/4'); %add new connection
            handles=get_param([block, '/Pressure'],'LineHandles'); %get line handles
            set(handles.Outport(1),'Name','Pressure'); %set line name
        end
    end

    if strcmp(MaskValue{5},'on') %FluidType
        if ~strcmp(get_param([block,'/FluidType'],'BlockType'),'Inport')
            delete_line(block,'FluidType/1','BusCreator/5'); %delete connection
            delete_block([block,'/FluidType']); %delete block
            add_block('built-in/Inport',[block,'/FluidType']); %add new block
            set_param([block, '/FluidType'],'Position',[50   5*50+8   50+30   5*50+8+14]); %set new block's position
            add_line(block,'FluidType/1','BusCreator/5'); %add new connection
            handles=get_param([block, '/FluidType'],'LineHandles'); %get line handles
            set(handles.Outport(1),'Name','FluidType'); %set line name
        end
    else
        if ~strcmp(get_param([block,'/FluidType'],'BlockType'),'Constant')
            delete_line(block,'FluidType/1','BusCreator/5'); %delete connection
            delete_block([block,'/FluidType']); %delete block
            add_block('built-in/Constant',[block,'/FluidType']); %add new block
            set_param([block, '/FluidType'],'Position',[50   5*50   50+30   5*50+30]); %set new block's position
            set_param([block, '/FluidType'],'Value','FluidType'); %set mask varible as value
            add_line(block,'FluidType/1','BusCreator/5'); %add new connection
            handles=get_param([block, '/FluidType'],'LineHandles'); %get line handles
            set(handles.Outport(1),'Name','FluidType'); %set line name
        end
    end

    if strcmp(MaskValue{6},'on') %FluidMix
        if ~strcmp(get_param([block,'/FluidMix'],'BlockType'),'Inport')
            delete_line(block,'FluidMix/1','BusCreator/6'); %delete connection
            delete_block([block,'/FluidMix']); %delete block
            add_block('built-in/Inport',[block,'/FluidMix']); %add new block
            set_param([block, '/FluidMix'],'Position',[50   6*50+8   50+30   6*50+8+14]); %set new block's position
            add_line(block,'FluidMix/1','BusCreator/6'); %add new connection
            handles=get_param([block, '/FluidMix'],'LineHandles'); %get line handles
            set(handles.Outport(1),'Name','FluidMix'); %set line name
        end
    else
        if ~strcmp(get_param([block,'/FluidMix'],'BlockType'),'Constant')
            delete_line(block,'FluidMix/1','BusCreator/6'); %delete connection
            delete_block([block,'/FluidMix']); %delete block
            add_block('built-in/Constant',[block,'/FluidMix']); %add new block
            set_param([block, '/FluidMix'],'Position',[50   6*50   50+30   6*50+30]); %set new block's position
            set_param([block, '/FluidMix'],'Value','FluidMix'); %set mask varible as value
            add_line(block,'FluidMix/1','BusCreator/6'); %add new connection
            handles=get_param([block, '/FluidMix'],'LineHandles'); %get line handles
            set(handles.Outport(1),'Name','FluidMix'); %set line name
        end
    end

    if strcmp(MaskValue{7},'on') %FluidMix2
        if ~strcmp(get_param([block,'/FluidMix2'],'BlockType'),'Inport')
            delete_line(block,'FluidMix2/1','BusCreator/7'); %delete connection
            delete_block([block,'/FluidMix2']); %delete block
            add_block('built-in/Inport',[block,'/FluidMix2']); %add new block
            set_param([block, '/FluidMix2'],'Position',[50   7*50+8   50+30   7*50+8+14]); %set new block's position
            add_line(block,'FluidMix2/1','BusCreator/7'); %add new connection
            handles=get_param([block, '/FluidMix2'],'LineHandles'); %get line handles
            set(handles.Outport(1),'Name','FluidMix2'); %set line name
        end
    else
        if ~strcmp(get_param([block,'/FluidMix2'],'BlockType'),'Constant')
            delete_line(block,'FluidMix2/1','BusCreator/7'); %delete connection
            delete_block([block,'/FluidMix2']); %delete block
            add_block('built-in/Constant',[block,'/FluidMix2']); %add new block
            set_param([block, '/FluidMix2'],'Position',[50   7*50   50+30   7*50+30]); %set new block's position
            set_param([block, '/FluidMix2'],'Value','FluidMix2'); %set mask varible as value
            add_line(block,'FluidMix2/1','BusCreator/7'); %add new connection
            handles=get_param([block, '/FluidMix2'],'LineHandles'); %get line handles
            set(handles.Outport(1),'Name','FluidMix2'); %set line name
        end
    end
    if strcmp(MaskValue{8},'on') %FluidMix3
        if ~strcmp(get_param([block,'/FluidMix3'],'BlockType'),'Inport')
            delete_line(block,'FluidMix3/1','BusCreator/8'); %delete connection
            delete_block([block,'/FluidMix3']); %delete block
            add_block('built-in/Inport',[block,'/FluidMix3']); %add new block
            set_param([block, '/FluidMix3'],'Position',[50   8*50+8   50+30   8*50+8+14]); %set new block's position
            add_line(block,'FluidMix3/1','BusCreator/8'); %add new connection
            handles=get_param([block, '/FluidMix3'],'LineHandles'); %get line handles
            set(handles.Outport(1),'Name','FluidMix3'); %set line name
        end
    else
        if ~strcmp(get_param([block,'/FluidMix3'],'BlockType'),'Constant')
            delete_line(block,'FluidMix3/1','BusCreator/8'); %delete connection
            delete_block([block,'/FluidMix3']); %delete block
            add_block('built-in/Constant',[block,'/FluidMix3']); %add new block
            set_param([block, '/FluidMix3'],'Position',[50   8*50   50+30   8*50+30]); %set new block's position
            set_param([block, '/FluidMix3'],'Value','FluidMix3'); %set mask varible as value
            add_line(block,'FluidMix3/1','BusCreator/8'); %add new connection
            handles=get_param([block, '/FluidMix3'],'LineHandles'); %get line handles
            set(handles.Outport(1),'Name','FluidMix3'); %set line name
        end
    end


    if strcmp(MaskValue{9},'on') %DiameterLastPiece
        if ~strcmp(get_param([block,'/DiameterLastPiece'],'BlockType'),'Inport')
            delete_line(block,'DiameterLastPiece/1','BusCreator/9'); %delete connection
            delete_block([block,'/DiameterLastPiece']); %delete block
            add_block('built-in/Inport',[block,'/DiameterLastPiece']); %add new block
            set_param([block, '/DiameterLastPiece'],'Position',[50   9*50+8   50+30   9*50+8+14]); %set new block's position
            add_line(block,'DiameterLastPiece/1','BusCreator/9'); %add new connection
            handles=get_param([block, '/DiameterLastPiece'],'LineHandles'); %get line handles
            set(handles.Outport(1),'Name','DiameterLastPiece'); %set line name
        end
    else
        if ~strcmp(get_param([block,'/DiameterLastPiece'],'BlockType'),'Constant')
            delete_line(block,'DiameterLastPiece/1','BusCreator/9'); %delete connection
            delete_block([block,'/DiameterLastPiece']); %delete block
            add_block('built-in/Constant',[block,'/DiameterLastPiece']); %add new block
            set_param([block, '/DiameterLastPiece'],'Position',[50   9*50   50+30   9*50+30]); %set new block's position
            set_param([block, '/DiameterLastPiece'],'Value','d'); %set mask varible as value
            add_line(block,'DiameterLastPiece/1','BusCreator/9'); %add new connection
            handles=get_param([block, '/DiameterLastPiece'],'LineHandles'); %get line handles
            set(handles.Outport(1),'Name','DiameterLastPiece'); %set line name
        end
    end

    if strcmp(MaskValue{10},'on') %DPConstant
        if ~strcmp(get_param([block,'/DPConstant'],'BlockType'),'Inport')
            delete_line(block,'DPConstant/1','BusCreator/10'); %delete connection
            delete_block([block,'/DPConstant']); %delete block
            add_block('built-in/Inport',[block,'/DPConstant']); %add new block
            set_param([block, '/DPConstant'],'Position',[50   10*50+8   50+30   10*50+8+14]); %set new block's position
            add_line(block,'DPConstant/1','BusCreator/10'); %add new connection
            handles=get_param([block, '/DPConstant'],'LineHandles'); %get line handles
            set(handles.Outport(1),'Name','DPConstant'); %set line name
        end
    else
        if ~strcmp(get_param([block,'/DPConstant'],'BlockType'),'Constant')
            delete_line(block,'DPConstant/1','BusCreator/10'); %delete connection
            delete_block([block,'/DPConstant']); %delete block
            add_block('built-in/Constant',[block,'/DPConstant']); %add new block
            set_param([block, '/DPConstant'],'Position',[50   10*50   50+30   10*50+30]); %set new block's position
            set_param([block, '/DPConstant'],'Value','c'); %set mask varible as value
            add_line(block,'DPConstant/1','BusCreator/10'); %add new connection
            handles=get_param([block, '/DPConstant'],'LineHandles'); %get line handles
            set(handles.Outport(1),'Name','DPConstant'); %set line name
        end
    end

    if strcmp(MaskValue{11},'on') %DPLinear
        if ~strcmp(get_param([block,'/DPLinear'],'BlockType'),'Inport')
            delete_line(block,'DPLinear/1','BusCreator/11'); %delete connection
            delete_block([block,'/DPLinear']); %delete block
            add_block('built-in/Inport',[block,'/DPLinear']); %add new block
            set_param([block, '/DPLinear'],'Position',[50   11*50+8   50+30   11*50+8+14]); %set new block's position
            add_line(block,'DPLinear/1','BusCreator/11'); %add new connection
            handles=get_param([block, '/DPLinear'],'LineHandles'); %get line handles
            set(handles.Outport(1),'Name','DPLinear'); %set line name
        end
    else
        if ~strcmp(get_param([block,'/DPLinear'],'BlockType'),'Constant')
            delete_line(block,'DPLinear/1','BusCreator/11'); %delete connection
            delete_block([block,'/DPLinear']); %delete block
            add_block('built-in/Constant',[block,'/DPLinear']); %add new block
            set_param([block, '/DPLinear'],'Position',[50   11*50   50+30   11*50+30]); %set new block's position
            set_param([block, '/DPLinear'],'Value','l'); %set mask varible as value
            add_line(block,'DPLinear/1','BusCreator/11'); %add new connection
            handles=get_param([block, '/DPLinear'],'LineHandles'); %get line handles
            set(handles.Outport(1),'Name','DPLinear'); %set line name
        end
    end

    if strcmp(MaskValue{12},'on') %DPQuadratic
        if ~strcmp(get_param([block,'/DPQuadratic'],'BlockType'),'Inport')
            delete_line(block,'DPQuadratic/1','BusCreator/12'); %delete connection
            delete_block([block,'/DPQuadratic']); %delete block
            add_block('built-in/Inport',[block,'/DPQuadratic']); %add new block
            set_param([block, '/DPQuadratic'],'Position',[50   12*50+8   50+30   12*50+8+14]); %set new block's position
            add_line(block,'DPQuadratic/1','BusCreator/12'); %add new connection
            handles=get_param([block, '/DPQuadratic'],'LineHandles'); %get line handles
            set(handles.Outport(1),'Name','DPQuadratic'); %set line name
        end
    else
        if ~strcmp(get_param([block,'/DPQuadratic'],'BlockType'),'Constant')
            delete_line(block,'DPQuadratic/1','BusCreator/12'); %delete connection
            delete_block([block,'/DPQuadratic']); %delete block
            add_block('built-in/Constant',[block,'/DPQuadratic']); %add new block
            set_param([block, '/DPQuadratic'],'Position',[50   12*50   50+30   12*50+30]); %set new block's position
            set_param([block, '/DPQuadratic'],'Value','q'); %set mask varible as value
            add_line(block,'DPQuadratic/1','BusCreator/12'); %add new connection
            handles=get_param([block, '/DPQuadratic'],'LineHandles'); %get line handles
            set(handles.Outport(1),'Name','DPQuadratic'); %set line name
        end
    end

    if strcmp(MaskValue{13},'on') %HydraulicInductance
        if ~strcmp(get_param([block,'/HydraulicInductance'],'BlockType'),'Inport')
            delete_line(block,'HydraulicInductance/1','BusCreator/13'); %delete connection
            delete_block([block,'/HydraulicInductance']); %delete block
            add_block('built-in/Inport',[block,'/HydraulicInductance']); %add new block
            set_param([block, '/HydraulicInductance'],'Position',[50   13*50+8   50+30   13*50+8+14]); %set new block's position
            add_line(block,'HydraulicInductance/1','BusCreator/13'); %add new connection
            handles=get_param([block, '/HydraulicInductance'],'LineHandles'); %get line handles
            set(handles.Outport(1),'Name','HydraulicInductance'); %set line name
        end
    else
        if ~strcmp(get_param([block,'/HydraulicInductance'],'BlockType'),'Constant')
            delete_line(block,'HydraulicInductance/1','BusCreator/13'); %delete connection
            delete_block([block,'/HydraulicInductance']); %delete block
            add_block('built-in/Constant',[block,'/HydraulicInductance']); %add new block
            set_param([block, '/HydraulicInductance'],'Position',[50   13*50   50+30   13*50+30]); %set new block's position
            set_param([block, '/HydraulicInductance'],'Value','LH'); %set mask varible as value
            add_line(block,'HydraulicInductance/1','BusCreator/13'); %add new connection
            handles=get_param([block, '/HydraulicInductance'],'LineHandles'); %get line handles
            set(handles.Outport(1),'Name','HydraulicInductance'); %set line name
        end
    end

    if strcmp(MaskValue{14},'on') %GeodeticHeight
        if ~strcmp(get_param([block,'/GeodeticHeight'],'BlockType'),'Inport')
            delete_line(block,'GeodeticHeight/1','BusCreator/14'); %delete connection
            delete_block([block,'/GeodeticHeight']); %delete block
            add_block('built-in/Inport',[block,'/GeodeticHeight']); %add new block
            set_param([block, '/GeodeticHeight'],'Position',[50   14*50+8   50+30   14*50+8+14]); %set new block's position
            add_line(block,'GeodeticHeight/1','BusCreator/14'); %add new connection
            handles=get_param([block, '/GeodeticHeight'],'LineHandles'); %get line handles
            set(handles.Outport(1),'Name','GeodeticHeight'); %set line name
        end
    else
        if ~strcmp(get_param([block,'/GeodeticHeight'],'BlockType'),'Constant')
            delete_line(block,'GeodeticHeight/1','BusCreator/14'); %delete connection
            delete_block([block,'/GeodeticHeight']); %delete block
            add_block('built-in/Constant',[block,'/GeodeticHeight']); %add new block
            set_param([block, '/GeodeticHeight'],'Position',[50   14*50   50+30   14*50+30]); %set new block's position
            set_param([block, '/GeodeticHeight'],'Value','H'); %set mask varible as value
            add_line(block,'GeodeticHeight/1','BusCreator/14'); %add new connection
            handles=get_param([block, '/GeodeticHeight'],'LineHandles'); %get line handles
            set(handles.Outport(1),'Name','GeodeticHeight'); %set line name
        end
    end
    
end
