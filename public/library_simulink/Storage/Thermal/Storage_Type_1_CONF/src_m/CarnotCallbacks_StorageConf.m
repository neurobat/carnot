function CarnotCallbacks_StorageConf(storagetype,parameterfile)
% Carnot_StorageConf_Callbacks(storagetype,parameterfile)
% Inputs:   pos - 1 = horizontal cylinder; 2 = vertical cylinder
%           volume - volume of water in m�
%           dia - diameter of cylinder in m
%           nodes - number of nodes in the storage model     
%           mpoints - number of measurement points
%           t0 - initial temperature vector [�C]
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
% Version   Author  Changes                                     Date
% 6.1.0     hf      created                                     03oct2014
% 6.1.1     hf      direct subsystem mask parameters and        20dec2014
%                   storage sensor position is taken from s.Tsensor
% 6.1.2     hf      integrated getConfNamelist                  15feb2015
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

if  ~BlockIsInCarnotLibrary       % if not located in library
    % block name definition
    switch storagetype
        case 1
            blockname = 'Storage_Type_1';
            foldername = 'Storage_Type_1_CONF';
            Ncon = '2';
        case 2
            blockname = 'Storage_Type_2';
            foldername = 'Storage_Type_2_CONF';
            Ncon = '2';
        case 3
            blockname = 'Storage_Type_3';
            foldername = 'Storage_Type_3_CONF';
            Ncon = '3';
        case 4
            blockname = 'Storage_Type_4';
            foldername = 'Storage_Type_4_CONF';
            Ncon = '4';
        case 5
            blockname = 'Storage_Type_5';
            foldername = 'Storage_Type_5_CONF';
            Ncon = '5';
        otherwise
            error('Unknown storage type')
    end
    
    % path definitions
    parampath = fullfile('Storage','Thermal',foldername,'parameter_set');  
    intpath = fullfile(path_carnot('intlibsl'), parampath);
    pubpath = fullfile(path_carnot('libsl'), parampath);

    % get parameter files
    [namelist, lib] = getConfNamelist(intpath,pubpath);

    % set names in the popup mask
    if ~lib
        myMaskStylesVar{1} = ['popup(', namelist,')'];
        myMaskStylesVar{2} = 'edit';
        set_param(gcb, 'MaskStyles', myMaskStylesVar);
    end

    if exist(fullfile(intpath, [parameterfile '.mat']), 'file')
        load(fullfile(intpath, parameterfile));
    else
        load(fullfile(pubpath, parameterfile));
    end

    % set mask parameters
    % temperature sensor positions
    set_param([gcb '/T_Sensor_Surface'], 'pos', ...
        ['[', num2str(s.Tsensor), ']']);
    % top mask (same for all storage tanks)
    set_param([gcb '/' blockname], 'uloss', num2str(s.uwall), ...
        'ubot', num2str(s.ubot), 'utop', num2str(s.utop), ...
        'cond', num2str(s.axcond), ...
        'volume', num2str(s.vol) , 'dia', num2str(s.dia), ...
        'pos', 'standing cylinder', 'nconnect', Ncon, ...
        'nodes', num2str(s.nodes), 'mpoints', num2str(s.mpts));

    % connections, individual for each tank
    switch storagetype
        case 1
            set_param([gcb '/Storage_Type_1/pipe_charge'], ...
                'h_in', num2str(s.pipe_charge.inlet), ...
                'h_out', num2str(s.pipe_charge.outlet), ...
                'dplin', num2str(s.pipe_charge.dplin), ...
                'dpqua', num2str(s.pipe_charge.dpqua));
            set_param([gcb '/Storage_Type_1/pipe_discharge'], ...
                'h_in', num2str(s.pipe_discharge.inlet), ...
                'h_out', num2str(s.pipe_discharge.outlet), ...
                'dplin', num2str(s.pipe_discharge.dplin), ...
                'dpqua', num2str(s.pipe_discharge.dpqua));

        case 2
            set_param([gcb '/Storage_Type_2/pipe'], ...
                'h_in', num2str(s.pipe.inlet), ...
                'h_out', num2str(s.pipe.outlet), ...
                'dplin', num2str(s.pipe.dplin), ...
                'dpqua', num2str(s.pipe.dpqua));
            set_param([gcb '/Storage_Type_2/HX_data_fit'], ...
                'h_in', num2str(s.HX_data_fit.inlet), ...
                'h_out', num2str(s.HX_data_fit.outlet), ...
                'ua0', num2str(s.HX_data_fit.uac), ...
                'uam', num2str(s.HX_data_fit.uam), ...
                'uat', num2str(s.HX_data_fit.uat), ...
                'dplin', num2str(s.HX_data_fit.dplin), ...
                'dpqua', num2str(s.HX_data_fit.dpqua));

        case 3
            set_param([gcb '/Storage_Type_3/pipe'], ...             
                'h_in', num2str(s.pipe.inlet), ...
                'h_out', num2str(s.pipe.outlet), ...
                'dplin', num2str(s.pipe.dplin), ...
                'dpqua', num2str(s.pipe.dpqua));
            set_param([gcb '/Storage_Type_3/HX_EN12977_bkp'], ...
                'h_in', num2str(s.HX_EN12977_bkp.inlet), ...
                'h_out', num2str(s.HX_EN12977_bkp.outlet), ...
                'ua0', num2str(s.HX_EN12977_bkp.uac), ...
                'uam', num2str(s.HX_EN12977_bkp.uam), ...
                'uat', num2str(s.HX_EN12977_bkp.uat), ...
                'dplin', num2str(s.HX_EN12977_bkp.dplin), ...
                'dpqua', num2str(s.HX_EN12977_bkp.dpqua));
            set_param([gcb '/Storage_Type_3/HX_EN12977_solar'], ...
                'h_in', num2str(s.HX_EN12977_solar.inlet), ...
                'h_out', num2str(s.HX_EN12977_solar.outlet), ...
                'ua0', num2str(s.HX_EN12977_solar.uac), ...
                'uam', num2str(s.HX_EN12977_solar.uam), ...
                'uat', num2str(s.HX_EN12977_solar.uat), ...
                'dplin', num2str(s.HX_EN12977_solar.dplin), ...
                'dpqua', num2str(s.HX_EN12977_solar.dpqua));
        
        case 4
            set_param([gcb '/Storage_Type_4/HX_EN12977_dhw'], ...       
                'h_in', num2str(s.HX_EN12977_dhw.inlet), ...
                'h_out', num2str(s.HX_EN12977_dhw.outlet), ...
                'ua0', num2str(s.HX_EN12977_dhw.uac), ...
                'uam', num2str(s.HX_EN12977_dhw.uam), ...
                'uat', num2str(s.HX_EN12977_dhw.uat), ...
                'dplin', num2str(s.HX_EN12977_dhw.dplin), ...
                'dpqua', num2str(s.HX_EN12977_dhw.dpqua));
            set_param([gcb '/Storage_Type_4/pipe_bkp_dhw'], ...
                'h_in', num2str(s.pipe_bkp_dhw.inlet), ...
                'h_out', num2str(s.pipe_bkp_dhw.outlet), ...
                'dplin', num2str(s.pipe_bkp_dhw.dplin), ...
                'dpqua', num2str(s.pipe_bkp_dhw.dpqua));
            set_param([gcb '/Storage_Type_4/pipe_heating'], ...
                'h_in', num2str(s.pipe_heating.inlet), ...
                'h_out', num2str(s.pipe_heating.outlet), ...
                'dplin', num2str(s.pipe_heating.dplin), ...
                'dpqua', num2str(s.pipe_heating.dpqua));
            set_param([gcb '/Storage_Type_4/HX_EN12977_solar'], ...
                'h_in', num2str(s.HX_EN12977_solar.inlet), ...
                'h_out', num2str(s.HX_EN12977_solar.outlet), ...
                'ua0', num2str(s.HX_EN12977_solar.uac), ...
                'uam', num2str(s.HX_EN12977_solar.uam), ...
                'uat', num2str(s.HX_EN12977_solar.uat), ...
                'dplin', num2str(s.HX_EN12977_solar.dplin), ...
                'dpqua', num2str(s.HX_EN12977_solar.dpqua));

        case 5
            set_param([gcb '/Storage_Type_5/HX_EN12977_dhw'], ...       
                'h_in', num2str(s.HX_EN12977_dhw.inlet), ...
                'h_out', num2str(s.HX_EN12977_dhw.outlet), ...
                'ua0', num2str(s.HX_EN12977_dhw.uac), ...
                'uam', num2str(s.HX_EN12977_dhw.uam), ...
                'uat', num2str(s.HX_EN12977_dhw.uat), ...
                'dplin', num2str(s.HX_EN12977_dhw.dplin), ...
                'dpqua', num2str(s.HX_EN12977_dhw.dpqua));
            set_param([gcb '/Storage_Type_5/pipe_bkp_dhw'], ...
                'h_in', num2str(s.pipe_bkp_dhw.inlet), ...
                'h_out', num2str(s.pipe_bkp_dhw.outlet), ...
                'dplin', num2str(s.pipe_bkp_dhw.dplin), ...
                'dpqua', num2str(s.pipe_bkp_dhw.dpqua));
            set_param([gcb '/Storage_Type_5/pipe_heating'], ...
                'h_in', num2str(s.pipe_heating.inlet), ...
                'h_out', num2str(s.pipe_heating.outlet), ...
                'dplin', num2str(s.pipe_heating.dplin), ...
                'dpqua', num2str(s.pipe_heating.dpqua));
            set_param([gcb '/Storage_Type_5/pipe_bkp_heating'], ...
                'h_in', num2str(s.pipe_bkp_heating.inlet), ...
                'h_out', num2str(s.pipe_bkp_heating.outlet), ...
                'dplin', num2str(s.pipe_bkp_heating.dplin), ...
                'dpqua', num2str(s.pipe_bkp_heating.dpqua));
            set_param([gcb '/Storage_Type_5/HX_EN12977_solar'], ...
                'h_in', num2str(s.HX_EN12977_solar.inlet), ...
                'h_out', num2str(s.HX_EN12977_solar.outlet), ...
                'ua0', num2str(s.HX_EN12977_solar.uac), ...
                'uam', num2str(s.HX_EN12977_solar.uam), ...
                'uat', num2str(s.HX_EN12977_solar.uat), ...
                'dplin', num2str(s.HX_EN12977_solar.dplin), ...
                'dpqua', num2str(s.HX_EN12977_solar.dpqua));
    end
end

function [namelist, lib] = getConfNamelist(intpath,pubpath)
% [namelist, lib] = getConfNamelist_Callbacks(intpath,pubpath)
% returns the namelist for configurated blocks. 
% input: intpath - path to the *.mat files with internal parameter sets
%        pubpath - path to the *.mat files with internal parameter sets
%        csref - path to the block in the carnot library
% output: namelist - character strings of the filenames
%         lib - true, if block is still in a library
%                                                                          
% See also: --
% 
% Function Calls:
% function is used by: all _CONF blocks of Carnot
% this function calls: --
% 
% Literature: -

% get public parameter files
pubfiles = dir(fullfile(pubpath,'*.mat'));
% set names in the popup mask
namelist = pubfiles(1).name(1:end-4);

% if not in the library any more, add internal parameters sets to the list
if  BlockIsInCarnotLibrary       % if located in library
    lib = true;
else
    lib = false;
    for n = 2:length(pubfiles)
        namelist = [namelist,'|',pubfiles(n).name(1:end-4)];
    end
    intfiles = dir(fullfile(intpath,'*.mat'));
    for n = 1:length(intfiles)
        namelist = [namelist,'|',intfiles(n).name(1:end-4)];
    end
end

