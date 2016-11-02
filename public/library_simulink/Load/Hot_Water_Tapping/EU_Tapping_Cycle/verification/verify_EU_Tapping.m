function [v, s] = verify_EU_Tapping(varargin)
% function to verify the the tapping cycles
% Inputs    show - optional flag for display 
%               0 : show results only if verification fails
%               1 : show results allways
% Outputs:  v -  true if verification passed, false otherwise
%           s - text string with verification result
% Syntax:   [v, s] = validate_EU_Tapping(varargin)
%                                                                          
% Literature:   /1/  VERORDNUNG (EU) Nr. 814/2013 DER KOMMISSION vom 2. August 2013

% all comments above appear with 'help verify_EU_Tapping' 
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
% 
% author list:      hf -> Bernd Hafner
%
% version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
%
% Version   Author  Changes                                     Date
% 6.1.0     hf      created                                     10feb2014
% 6.2.0     hf      return argument is [v, s]                   03oct2014
% 6.2.1     hf      filename validate_ replaced by verify_      09jan2015
% 6.2.2     hf      close system without saving it              16may2016
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

% ---- check input arguments ----------------------------------------------
if nargin == 0
    show = 0;
elseif nargin == 1
    show = varargin{1};
else
    error('verify_EU_Tapping:%s',' too many input arguments')
end

%% ---------- set your specific model or function parameters here
% ----- set error tolerances ----------------------------------------------
max_error =  0.004;     % max error between simulation and reference
max_simu_error = 1e-7;  % max error between initial and current simu
functionname = 'EU tapping';
modelfile = 'verify_EU_Tapping_mdl';

% ----------------- set the literature reference values -------------------
%      {'3XS', 'XXS', 'XS', 'S', 'M',   'L',    'XL',  'XXL', '3XL', '4XL'};
y0 =  [0.345, 2.1,   2.1,  2.1, 5.845, 11.655, 19.07, 24.53, 46.76, 93.52];
% ----------------- set reference values initial simulation ---------------
y1 = [0.339666217870627,2.09536186541692,2.09895646472686,2.09524781647252, ...
    5.83561159506495,11.6439879626246,19.0544255999835,24.5121264986460,...
    46.7187276677564,93.4427879012581;];

%% ------------------------------------------------------------------------
%  -------------- simulate the model or call the function -----------------
%  ------------------------------------------------------------------------
load_system(modelfile)
y2 = zeros(1,10);

for n = 1:10
    % times in h, energies in kWh, massflow in kg/min
    % will be transformed to s, J at kg/s the end
    switch(n)
        case 1  % profile 3XS   0.345 kWh
            times =    [7.000   7.083   7.250   7.433   7.500   9.000   9.500   11.50   11.75   12.00   12.50   12.75   14.50   15.00   15.50   16.00   18.50   19.00   19.50   21.25   21.50   21.58   21.75 ];
            energies = [0.015   0.015   0.015   0.015   0.015   0.015   0.015   0.015   0.015   0.015   0.015   0.015   0.015   0.015   0.015   0.015   0.015   0.015   0.015   0.015   0.015   0.015   0.015 ];
            % dT_set = [30      30      30      30      30      30      30      30      30      30      30      30      30      30      30      30      30      30      30      30      30      30      30  ];
            mdot =     [2       2       2       2       2       2       2       2       2       2       2       2       2       2       2       2       2       2       2       2       2       2       2   ];
    
        case 2  % profile XXS   2.1 kWh
            times =    [7.000   7.500   8.500   9.500   11.50   11.75   12.00   12.50   12.75   18.00   18.25   18.50   19.00   19.50   20.00   20.75   21.00   21.25   21.58   21.75 ];
            energies = [0.105   0.105   0.105   0.105   0.105   0.105   0.105   0.105   0.105   0.105   0.105   0.105   0.105   0.105   0.105   0.105   0.105   0.105   0.105   0.105 ];
            % dT_set = [30      30      30      30      30      30      30      30      30      30      30      30      30      30      30      30      30      30      30      30    ];
            mdot =     [2       2       2       2       2       2       2       2       2       2       2       2       2       2       2       2       2       2       2       2     ];
    
        case 3  % profile XS    2.1 kWh
            times =    [7.500   12.75   21.50   ];
            energies = [0.525   0.525   1.05    ];
            % dT_set = [30      30      30      ];
            mdot =     [3       3       3       ];
        
        case 4  % profile S     2.1 kWh
            times =    [7.000   7.500   8.500   9.500   11.50   11.75   12.75   18.00   18.25   20.50   21.50   ];
            energies = [0.105   0.105   0.105   0.105   0.105   0.105   0.315   0.105   0.105   0.420   0.525   ];
            % dT_set = [30      30      30      30      30      30      45      30      30      45      30      ];
            mdot =     [3       3       3       3       3       3       4       3       3       4       5       ];
        
        case 5 % Profile M      5.845 kWh
            times =    [7.000 7.083 7.500 8.016 8.250 8.5   8.750 9.000 9.500 10.50 11.50 11.75 12.75 14.50 15.50 16.50 18.00 18.25 18.50 19.00 20.50 21.25 21.5];
            energies = [0.105 1.4   0.105 0.105 0.105 0.105 0.105 0.105 0.105 0.105 0.105 0.105 0.315 0.105 0.105 0.105 0.105 0.105 0.105 0.105 0.735 0.105 1.4 ];
            % dT_set = [30    30    30    30    30    30    30    30    30    30    30    30    45    30    30    30    30    30    30    30    45    30    30  ];
            mdot   =   [3     6     3     3     3     3     3     3     3     3     3     3     4     3     3     3     3     3     3     3     4     3     6   ];
            
        case 6 % profile L      11.655 kWh
            times =    [7.000 7.083 7.500 7.750 8.083 8.416 8.500 8.750 9.000 9.500 10.50 11.50 11.75 12.75 14.50 15.50 16.50 18.00 18.25 18.50 19.00 20.50 21.00 21.5 ];
            energies = [0.105 1.4   0.105 0.105 3.605 0.105 0.105 0.105 0.105 0.105 0.105 0.105 0.105 0.315 0.105 0.105 0.105 0.105 0.105 0.105 0.105 0.735 3.605 0.105];
            % dT_set = [30    30    30    30    30    30    30    30    30    30    30    30    30    45    30    30    30    30    30    30    30    45    30    30   ];
            mdot     = [3     6     3     3     10    3     3     3     3     3     3     3     3     4     3     3     3     3     3     3     3     4     10    3    ];
            
        case 7  % profile XL      19.07 kWh
            times =    [7.000 7.25  7.433 7.75  8.016 8.250 8.500 8.750 9.000 9.500 10.00 10.50 11.00 11.50 11.75 12.75 14.50 15.00 15.50 16.00 16.50 17.00 18.00 18.25 18.50 19.00 20.50 20.76 21.25 21.5 ];
            energies = [0.105 1.82  0.105 4.42  0.105 0.105 0.105 0.105 0.105 0.105 0.105 0.105 0.105 0.105 0.105 0.735 0.105 0.105 0.105 0.105 0.105 0.105 0.105 0.105 0.105 0.105 0.735 4.420 0.105 4.42 ];
            % dT_set = [30    35    30    30    30    30    30    30    30    30    30    30    30    30    45    45    30    30    30    30    30    30    30    35    35    30    45    35    30    35   ];
            mdot     = [3     6     3     10    3     3     3     3     3     3     3     3     3     4     3     3     3     3     3     3     3     4     10    3     3     3     4     10    3     10   ];
            
        case 8  % profile XXL      24.53 kWh
            times =    [7.000 7.25  7.433 7.75  8.016 8.250 8.500 8.750 9.000 9.500 10.00 10.50 11.00 11.50 11.75 12.75 14.50 15.00 15.50 16.00 16.50 17.00 18.00 18.25 18.50 19.00 20.50 20.76 21.25 21.5 ];
            energies = [0.105 1.82  0.105 6.24  0.105 0.105 0.105 0.105 0.105 0.105 0.105 0.105 0.105 0.105 0.105 0.735 0.105 0.105 0.105 0.105 0.105 0.105 0.105 0.105 0.105 0.105 0.735 6.240 0.105 6.24 ];
            % dT_set = [30    35    30    35    30    30    30    30    30    30    30    35    30    45    45    45    30    30    30    30    30    30    30    35    35    30    45    35    35    35   ];
            mdot     = [3     6     3     10    3     3     3     3     3     3     3     3     4     3     3     4     3     3     3     3     3     3     3     3     3     3     4     16    10    16   ];
            
        case 9  % profile 3XL      46.76 kWh
            times =    [7.00  8.016 9.000 10.50 11.75 12.75 15.50 18.50 20.50 21.5 ];
            energies = [11.2  5.04  1.68  0.840 1.68  2.520 2.520 3.36  5.88  12.04];
            % dT_set = [35    30    30    35    30    45    30    30    45    35   ];
            mdot     = [48    24    24    24    24    32    24    24    32    48   ];
            
        case 10 % profile 4XL      93.52 kWh
            times =    [7.000 8.016 9.000 10.50 11.75 12.75 15.50 18.50 20.50 21.5 ];
            energies = [22.40 10.08 3.36  1.680 3.360 5.04  5.04  6.72  11.76 24.08];
            % dT_set = [35    30    30    30    30    45    30    30    45    35   ];
            mdot     = [96    48    48    10    48    64    48    48    64    96   ];
            
        otherwise
            disp('Wrong definition of tapping profile')
    end
  
    energies = energies*36e5;
    times = times*3600;
    mdot = mdot/60;

    maskStr = get_param([modelfile, '/EU_Tapping_Cycle'],'DialogParameters');
    set_param([modelfile, '/EU_Tapping_Cycle'], 'MaskValues', maskStr.eu_tap.Enum(n));
    simOut = sim(modelfile, 'SrcWorkspace','current', ...
        'SaveOutput','on','OutputSaveName','yout');
    rr = simOut.get('yout');
    y2(n) = rr(end)/36e5;  % result is energy in J, transformed to kWh
end
close_system(modelfile, 0)   % close system, but do not save it


% err1 = (y0-y2)./y0;  % old equation

%% -------- calculate the errors -------------------------------------------
% error between reference and initial simu 
[e1, ye1] = calculate_verification_error(y0, y1, 'relative', 'max');
% error between reference and current simu
[e2, ye2] = calculate_verification_error(y0, y2, 'relative', 'max');
% error between initial and current simu
[e3, ye3] = calculate_verification_error(y1, y2, 'relative', 'max');

% ------------- decide if verification is ok --------------------------------
if e2 > max_error
    v = false;
    s = sprintf('verification %s with reference FAILED: error %3.3f > allowed error %3.3f', ...
        functionname, e2, max_error);
    show = true;
elseif e3 > max_simu_error
    v = false;
    s = sprintf('verification %s with 1st calculation FAILED: error %3.3f > allowed error %3.3f', ...
        functionname, e3, max_simu_error);
    show = true;
else
    v = true;
    s = sprintf('%s OK: error %3.3f', functionname, e2);
end

% ------------ diplay and plot options if required ------------------------
if (show)
    disp(s)
    disp(['Initial error = ', num2str(e1)])
    sx = 'Tapping cycle';                   % x-axis label
    st = 'Simulink block verification';       % title
    sy1 = 'Energy in kWh';                  % y-axis label in the upper plot
    sy2 = 'Relative Error';                 % y-axis label in the lower plot
    % upper legend
    sleg1 = {'reference data','initial simulation','current simulation'};
    % lower legend
    sleg2 = {'ref. vs initial simu','ref. vs current simu','initial simu vs current'};
    %   x - vector with x values for the plot
    x = (1:length(y2))';
    %   y - matrix with y-values (reference values and result of the function call)
    y = [reshape(y0,length(y0),1), reshape(y1,length(y1),1), reshape(y2,length(y2),1)];
    %   ye - matrix with error values for each y-value
    ye = [reshape(ye1,length(ye1),1), reshape(ye2,length(ye2),1), reshape(ye3,length(ye3),1)];
    display_verification_error(x, y, ye, st, sx, sy1, sleg1, sy2, sleg2, s)
end