% CARNOT TOOLBOX
% Version 6.0  20-02-2016
% ***********************************************************************
% The CARNOT Toolbox (Conventional and Regenerative Energy System 
% Optimization Toolbox)is designed for optimization of Energy 
% Systems in particular house heating systems.
% ***********************************************************************
% Simulink blockset:
%   carnot                - opens the CARNOT fundamental Library Carnot
%
% Definitions of Carnot formats:
% AIB_format              - definition of the air infiltration bus (see Carnot house models)
% Carnot_Fluid_Types      - definition of the fluid types for material property calculation   
% FluidEnum               - enumeration of the fluid types
% MessageLevelEnum        - enumeration of the error messages in Carnot
% PhaseEnum               - enumeration of the fluid phase (solid, liquid, gas)                   
% PropertyEnum            - material property enumeration             
% wformat                 - definition of the carnot weather data format
%
% Carnot utility functions:
% annualcosts             - function to calculate the the annual costs of the system
% BlockIsInCarnotLibrary  - answer to the question if a block is still in the library                
% CarnotCallbacks_*       - Callback functions of different Carnot blocks
% calculate_verification_error - support function for the verification            
% dir2                    - dir command for search in folders and subfolders (file from Mathworks homepage)
% display_verification_error - utility function for the verification proces
% example_annualcosts     - example for the annualcosts function            
% helpcarnot              - opens the carnot manual
% init_carnot             - init_carnot() adds the paths needed for carnot to run to your MATLAB path
% init_carnot_savepath    - init_carnot_savepath() adds the paths needed for CARNOT to your MATLAB
% link_breaker            - save all Simlink models is a folder without libray links
% path_carnot             - management of the pathes for Carnot library
% root_carnot             - Root directory of CARNOT installation.       
% txt2mat                 - read ascii data in a matrix (file form Mathworks homepage)             
%
% Material property functions and characteristic numbers
% CARLIB                  - material properties and solar position                
% density                 - density [kg/m^3]
% enthalpy                - specific enthalpy in J/kg              
% enthalpy2temperature    - temperature of water/steam for a given enthalpy in °C     
% entropy                 - specific entropy in J/kg/K  
% evaporation_enthalpy    - evaporation enthalpy [J/kg]
% fluidprop               - interface function to Carlib for fluid property calculations           
% grashof                 - Grashof number        
% heat_capacity           - heat capacity [J/(kg*K)]
% kinematic_viscosity     - viscosity [m^2/s]
% thermal_conductivity    - heat conductivity [W/(m*K)]
% prandtl                 - Prandtl number  
% rel_hum2x               - calculates the absolute humidity 
% reynolds                - Reynolds number                
% saturationtemperature   - saturation temperature of steam and moist air [°C]
% specific_volume         - specific_volume [m^3/kg]
% temperature_conductivity  - temperature conductivity in [m^2/s]           
% thermal_conductivity    - thermal conductivity in W/m/K  
% unitconv_carnot         - convert physical units                
% unitconv_temperature    - convert tempeture units
% vapourpressure          - vapourpressure of water and other fluids [Pa]
% velocity                - velocity of a fluid in a pipe or duct in m/s       
% x2rel_hum               - calculates the relative humidity 
%
% Weather data handling:
% convert_weather         - convert weather data in old Carnot format (up to version 5.)to format version 6.
% Meteonorm2wformat       - transform Meteonorm data to Carnot weather format
% MeteonormMinute2wformat - transform Meteonorm minute data to Carnot weather format          
% repeat_timeseries       - repeat a timeseries several tims (e.g. create 2 year weather data)          
% timecomment             - file with the timecomment in Carnot weather data
% tmy2wformat             - convert TMY weather data to Carnot weather data             
% try2wformat             - convert TRY weather data to Carnot weather data
%
% Weather data and solar functions:
% airmass                 - calculate the airmass according to geographical position
% angles2time             - finds the time to two specified solar angles
% cloudindex              - calculate the cloud index from other weather data 
% hourangle2time          - solar hour angle to time    
% radiationdivision       - divide global solar radiation in direct and diffuse        
% ratiograph              - plots a graph to show the ratio of direct radiation      
% skytemperature          - radiation temperature of the sky in °C                
% solar_declination       - declination angle of the sun in °          
% solar_extraterrestrial  - extraterrestrial solar radiation in W/m²
% sungraph                - graph of the solar postion in the year            
% sunset                  - time of sunset and sunrise for a given date         
% time2hourangle          - legal time to solar hour angle in °  
% year_average            - average of weather data for a specified interval
% year_sum                - sum and average of weather data for a specified interval
%
% Time and date functions:
% date2sec                - convert date information to seconds in the year 
% legaltime2solartime     - convert legal time in a timezone to solar time         
% sec2date                - determine the date from the number of seconds since 1st January
% solartime2legaltime     - convert solar time to legal time             
% sumtime                 - sum of seconds and minutes in the year              
% tvalue                  - converts a date in seconds to the time comment format
%
% Fitting functions for Carnot models:
% acm_param               - data fitting for absorption chiller model in Carnot 
% colpdrop                - pressure drop of a header riser in a solar collector 
% hp_param                - fitting function for the Carnot heat pump model
% taualfa                 - tranmittance absorbtance for solar thermal collector        


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
