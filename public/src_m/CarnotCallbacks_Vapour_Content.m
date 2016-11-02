function varargout = CarnotCallbacks_Vapour_Content(varargin)
% varargout = CarnotCallbacks_Vapour_Content(varargin)

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
% author list:     aw -> Arnold Wohlfeil
%
% version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
%
% Version   Author  Changes                                     Date
% 6.1.0     awn     created                                     may2015

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


function CreateInports
    Inports=find_system(gcb,'LookUnderMasks','all','FollowLinks','on','SearchDepth',1,'BlockType','Inport');
    Constants=find_system(gcb,'LookUnderMasks','all','FollowLinks','on','SearchDepth',1,'BlockType','Constant');
    Selectors=find_system(gcb,'LookUnderMasks','all','FollowLinks','on','SearchDepth',1,'BlockType','Selector');
    BusSelectors=find_system(gcb,'LookUnderMasks','all','FollowLinks','on','SearchDepth',1,'BlockType','BusSelector');
    Demuxes=find_system(gcb,'LookUnderMasks','all','FollowLinks','on','SearchDepth',1,'BlockType','Demux');
    Terminators=find_system(gcb,'LookUnderMasks','all','FollowLinks','on','SearchDepth',1,'BlockType','Terminator');

    %%delete lines, Demuxes, Selectors, Bus Selectors, Constants
    %delete all lines
    for Count=1:numel(Inports)
        AuxVar=get_param(Inports{Count},'LineHandles');
        for Count2=1:numel(AuxVar.Outport)
            if AuxVar.Outport>=0
                delete_line(AuxVar.Outport(Count2));
            end
        end
    end
    for Count=1:numel(Constants)
        AuxVar=get_param(Constants{Count},'LineHandles');
        for Count2=1:numel(AuxVar.Outport)
            if AuxVar.Outport>=0
                delete_line(AuxVar.Outport(Count2));
            end
        end
    end
    for Count=1:numel(Selectors)
        AuxVar=get_param(Selectors{Count},'LineHandles');
        for Count2=1:numel(AuxVar.Outport)
            if AuxVar.Outport>=0
                delete_line(AuxVar.Outport(Count2));
            end
        end
    end
    for Count=1:numel(BusSelectors)
        AuxVar=get_param(BusSelectors{Count},'LineHandles');
        for Count2=1:numel(AuxVar.Outport)
            if AuxVar.Outport>=0
                delete_line(AuxVar.Outport(Count2));
            end
        end
    end
    for Count=1:numel(Demuxes)
        AuxVar=get_param(Demuxes{Count},'LineHandles');
        for Count2=1:numel(AuxVar.Outport)
            if AuxVar.Outport>=0
                delete_line(AuxVar.Outport(Count2));
            end
        end
    end
    clear Count Count2 AuxVar;

    %delete all constants, selectos, bus selectors and demuxes
    for Count=1:numel(Constants)
        delete_block(Constants{Count})
    end
    for Count=1:numel(Selectors)
        delete_block(Selectors{Count})
    end
    for Count=1:numel(BusSelectors)
        delete_block(BusSelectors{Count})
    end
    for Count=1:numel(Demuxes)
        delete_block(Demuxes{Count})
    end
    for Count=1:numel(Terminators)
        delete_block(Terminators{Count})
    end
    clear Count;
    
    %%add / delete inports and add constants and lines
    if strcmp(get_param(gcb,'INPUTARGUMENTS'), 'state variables (classic)') || strcmp(get_param(gcb,'INPUTARGUMENTS'), 'state variables (reduced)') %T p ID Mix
        %delete all unused inports
        for Count=6:numel(Inports)
            delete_block(Inports{Count});
        end

        if numel(Inports)>=1
            set_param(Inports{1},'Name','T');
        else
            add_block('built-in/Inport',[gcb,'/T']);
        end
        set_param([gcb,'/T'],'Position',[55   243    85   257]);
        add_line(gcb,'T/1','SFunction/3');
        if numel(Inports)>=2
            set_param(Inports{2},'Name','p');
        else
            add_block('built-in/Inport',[gcb,'/p']);
        end
        set_param([gcb,'/p'],'Position',[55   313    85   327]);
        add_line(gcb,'p/1','SFunction/4');
        if numel(Inports)>=3
            set_param(Inports{3},'Name','Fluid_Type');
        else
            add_block('built-in/Inport',[gcb,'/Fluid_Type']);
        end
        set_param([gcb,'/Fluid_Type'],'Position',[55   103    85   117]);
        add_line(gcb,'Fluid_Type/1','SFunction/1');
        if numel(Inports)>=4
            set_param(Inports{4},'Name','Fluid_Mix');
        else
            add_block('built-in/Inport',[gcb,'/Fluid_Mix']);
        end
        set_param([gcb,'/Fluid_Mix'],'Position',[55   173    85   187]);
        add_line(gcb,'Fluid_Mix/1','SFunction/2');
        if numel(Inports)>=5
            set_param(Inports{5},'Name','value');
        else
            add_block('built-in/Inport',[gcb,'/value']);
        end
        set_param([gcb,'/value'],'Position',[55   383    85   397]);
        add_line(gcb,'value/1','SFunction/5');
    elseif strcmp(get_param(gcb,'INPUTARGUMENTS'), 'THV') %THV
        %delete all unused inports
        for Count=3:numel(Inports)
            delete_block(Inports{Count});
        end        
        if numel(Inports)>=1
            set_param(Inports{1},'Name','THV');
        else
            add_block('built-in/Inport',[gcb,'/THV']);
        end
        set_param([gcb,'/THV'],'Position',[55   208    85   222]);
        add_block('built-in/Selector',[gcb,'/Selector']); %add a selector
        set_param([gcb,'/Selector'],'Position',[125   196   165   234]);
        set_param([gcb,'/Selector'],'InputPortWidth','-1')
        set_param([gcb,'/Selector'],'Indices','[5 6 2 4]');
        add_block('built-in/Demux',[gcb,'/Demux']); %add a demux
        set_param([gcb,'/Demux'],'Position',[220    73   225   357]);
        set_param([gcb,'/Demux'],'Outputs','4');
        add_line(gcb,'THV/1','Selector/1');
        add_line(gcb,'Selector/1','Demux/1');
        add_line(gcb,'Demux/1','SFunction/1');
        add_line(gcb,'Demux/2','SFunction/2');
        add_line(gcb,'Demux/3','SFunction/3');
        add_line(gcb,'Demux/4','SFunction/4');
        if numel(Inports)>=2
            set_param(Inports{2},'Name','value');
        else
            add_block('built-in/Inport',[gcb,'/value']);
        end
        set_param([gcb,'/value'],'Position',[55   383    85   397]);
        add_line(gcb,'value/1','SFunction/5');
    elseif strcmp(get_param(gcb,'INPUTARGUMENTS'), 'THB') %THB
        %delete all unused inports
        for Count=3:numel(Inports)
            delete_block(Inports{Count});
        end

        if numel(Inports)>=1
            set_param(Inports{1},'Name','THB');
        else
            add_block('built-in/Inport',[gcb,'/THB']);
        end
        set_param([gcb,'/THB'],'Position',[55   208    85   222]);
        add_block('built-in/BusSelector',[gcb,'/BusSelector']); %add a bus selector
        set_param([gcb,'/BusSelector'],'Position',[220    73   225   357]);
        set_param([gcb,'/BusSelector'],'OutputSignals','FluidType,FluidMix,Temperature,Pressure');
        add_line(gcb,'THB/1','BusSelector/1');
        add_line(gcb,'BusSelector/1','SFunction/1');
        add_line(gcb,'BusSelector/2','SFunction/2');
        add_line(gcb,'BusSelector/3','SFunction/3');
        add_line(gcb,'BusSelector/4','SFunction/4');
        
        if numel(Inports)>=2
            set_param(Inports{2},'Name','value');
        else
            add_block('built-in/Inport',[gcb,'/value']);
        end
        set_param([gcb,'/value'],'Position',[55   383    85   397]);
        add_line(gcb,'value/1','SFunction/5');
    end
end


function MyEnum = Str2MessageLevelEnum(MyString)
    [EnumContent, EnumCell] = enumeration('MessageLevelEnum');
    MyEnum = 0;
    EnumSet = false;
    
    Count = 0;
    while (Count < numel(EnumCell)) && ~EnumSet
        Count = Count + 1;
        if strcmpi(MyString, EnumCell{Count})
            MyEnum = EnumContent(Count);
            EnumSet = true;
        end
    end
end


function [DEBUGLEVEL, MAXTOTALWARNINGS, MAXCONSECUTIVEWARNINGS, WRITETOFILE, FILENAME] = CheckDebugLevels(LOCALDEBUGLEVEL, LOCALMAXTOTALWARNINGS, LOCALMAXCONSECUTIVEWARNINGS, LOCALWRITETOFILE, LOCALFILENAME)
    SystemParameters = fieldnames(get_param(bdroot,'ObjectParameters'));
    if sum(ismember(SystemParameters, 'DEBUGGLOBALLEVEL')) && ...
            sum(ismember(SystemParameters, 'DEBUGMAXTOTALWARNINGS')) && ...
            sum(ismember(SystemParameters, 'DEBUGMAXCONSECUTIVEWARNINGS')) && ...
            sum(ismember(SystemParameters, 'DEBUGWRITETOFILE')) && ...
            sum(ismember(SystemParameters, 'DEBUGFILENAME'))
        if isempty(str2num(get_param(bdroot, 'DEBUGGLOBALLEVEL')))
            DEBUGLEVEL = int32(Str2MessageLevelEnum(get_param(bdroot, 'DEBUGGLOBALLEVEL')));
        else
            DEBUGLEVEL = int32(str2num(get_param(bdroot, 'DEBUGGLOBALLEVEL')));
        end
        MAXTOTALWARNINGS = str2num(get_param(bdroot, 'DEBUGMAXTOTALWARNINGS'));
        MAXCONSECUTIVEWARNINGS = str2num(get_param(bdroot, 'DEBUGMAXCONSECUTIVEWARNINGS'));
        WRITETOFILE = str2num(get_param(bdroot, 'DEBUGWRITETOFILE'));
        FILENAME = get_param(bdroot, 'DEBUGFILENAME');
    else
        DEBUGLEVEL = LOCALDEBUGLEVEL;
        MAXTOTALWARNINGS = LOCALMAXTOTALWARNINGS;
        MAXCONSECUTIVEWARNINGS = LOCALMAXCONSECUTIVEWARNINGS;
        WRITETOFILE = LOCALWRITETOFILE;
        FILENAME = LOCALFILENAME;
    end
    clear SystemParameters;
end


function LoadFcn
    [~, EnumCell] = enumeration('MessageLevelEnum');
    MaskStyles = get_param(gcb, 'MaskStyles');
    
    MaskStyles{3} = 'popup(';
    for Count = 1:numel(EnumCell)
        MaskStyles{3} = [MaskStyles{3}, EnumCell{Count}]; 
        if Count < numel(EnumCell)
            MaskStyles{3} = [MaskStyles{3}, '|'];
        else
           MaskStyles{3} = [MaskStyles{3}, ')']; 
        end
    end
    
    set_param(gcb, 'MaskStyles', MaskStyles);
end


function MaskVisibilities
    SystemParameters = fieldnames(get_param(bdroot,'ObjectParameters'));
    if sum(ismember(SystemParameters, 'DEBUGGLOBALLEVEL')) && ...
                sum(ismember(SystemParameters, 'DEBUGMAXTOTALWARNINGS')) && ...
                sum(ismember(SystemParameters, 'DEBUGMAXCONSECUTIVEWARNINGS')) && ...
                sum(ismember(SystemParameters, 'DEBUGWRITETOFILE')) && ...
                sum(ismember(SystemParameters, 'DEBUGFILENAME'))
        MaskVisibilities={'on','on','off','off','off','off','off'};
    else
        MaskVisibilities={'on','on','on','on','on','on','on'};
    end
    set_param(gcb, 'MaskVisibilities', MaskVisibilities);
end
