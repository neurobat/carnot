% script to define the tapping cycles

% **********************************************************************
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
% 6.1.0     hf      created                                     2015


for eu_tap = 1:10

% copy this part of the file to the mask of the block

% times in h, energies in kWh, massflow in kg/min
% will be transformed to s, J at kg/s the end
switch(eu_tap)
    case 1  % profile 3XS   0.345 kWh
        times =    [7.000   7.083   7.250   7.433   7.500   9.000   9.500   11.50   11.75   12.00   12.50   12.75   14.50   15.00   15.50   16.00   18.50   19.00   19.50   21.25   21.50   21.58   21.75 ];
        energies = [0.015   0.015   0.015   0.015   0.015   0.015   0.015   0.015   0.015   0.015   0.015   0.015   0.015   0.015   0.015   0.015   0.015   0.015   0.015   0.015   0.015   0.015   0.015 ];
        dT_set =   [30      30      30      30      30      30      30      30      30      30      30      30      30      30      30      30      30      30      30      30      30      30      30  ];
        mdot =     [2       2       2       2       2       2       2       2       2       2       2       2       2       2       2       2       2       2       2       2       2       2       2   ];

    case 2  % profile XXS   2.1 kWh
        times =    [7.000   7.500   8.500   9.500   11.50   11.75   12.00   12.50   12.75   18.00   18.25   18.50   19.00   19.50   20.00   20.75   21.00   21.25   21.58   21.75 ];
        energies = [0.105   0.105   0.105   0.105   0.105   0.105   0.105   0.105   0.105   0.105   0.105   0.105   0.105   0.105   0.105   0.105   0.105   0.105   0.105   0.105 ];
        dT_set =   [30      30      30      30      30      30      30      30      30      30      30      30      30      30      30      30      30      30      30      30    ];
        mdot =     [2       2       2       2       2       2       2       2       2       2       2       2       2       2       2       2       2       2       2       2     ];

    case 3  % profile XS    2.1 kWh
        times =    [7.500   12.75   21.50   ];
        energies = [0.525   0.525   1.05    ];
        dT_set =   [30      30      30      ];
        mdot =     [3       3       3       ];
    
    case 4  % profile S     2.1 kWh
        times =    [7.000   7.500   8.500   9.500   11.50   11.75   12.75   18.00   18.25   20.50   21.50   ];
        energies = [0.105   0.105   0.105   0.105   0.105   0.105   0.315   0.105   0.105   0.420   0.525   ];
        dT_set =   [30      30      30      30      30      30      45      30      30      45      30      ];
        mdot =     [3       3       3       3       3       3       4       3       3       4       5       ];
    
    case 5 % Profile M      5.845 kWh
        times =    [7.000 7.083 7.500 8.016 8.250 8.5   8.750 9.000 9.500 10.50 11.50 11.75 12.75 14.50 15.50 16.50 18.00 18.25 18.50 19.00 20.50 21.25 21.5];
        energies = [0.105 1.4   0.105 0.105 0.105 0.105 0.105 0.105 0.105 0.105 0.105 0.105 0.315 0.105 0.105 0.105 0.105 0.105 0.105 0.105 0.735 0.105 1.4 ];
        dT_set =   [30    30    30    30    30    30    30    30    30    30    30    30    45    30    30    30    30    30    30    30    45    30    30  ];
        mdot   =   [3     6     3     3     3     3     3     3     3     3     3     3     4     3     3     3     3     3     3     3     4     3     6   ];
        
    case 6 % profile L      11.655 kWh
        times =    [7.000 7.083 7.500 7.750 8.083 8.416 8.500 8.750 9.000 9.500 10.50 11.50 11.75 12.75 14.50 15.50 16.50 18.00 18.25 18.50 19.00 20.50 21.00 21.5 ];
        energies = [0.105 1.4   0.105 0.105 3.605 0.105 0.105 0.105 0.105 0.105 0.105 0.105 0.105 0.315 0.105 0.105 0.105 0.105 0.105 0.105 0.105 0.735 3.605 0.105];
        dT_set   = [30    30    30    30    30    30    30    30    30    30    30    30    30    45    30    30    30    30    30    30    30    45    30    30   ];
        mdot     = [3     6     3     3     10    3     3     3     3     3     3     3     3     4     3     3     3     3     3     3     3     4     10    3    ];
        
    case 7  % profile XL      19.07 kWh
        times =    [7.000 7.25  7.433 7.75  8.016 8.250 8.500 8.750 9.000 9.500 10.00 10.50 11.00 11.50 11.75 12.75 14.50 15.00 15.50 16.00 16.50 17.00 18.00 18.25 18.50 19.00 20.50 20.76 21.25 21.5 ];
        energies = [0.105 1.82  0.105 4.42  0.105 0.105 0.105 0.105 0.105 0.105 0.105 0.105 0.105 0.105 0.105 0.735 0.105 0.105 0.105 0.105 0.105 0.105 0.105 0.105 0.105 0.105 0.735 4.420 0.105 4.42 ];
        dT_set   = [30    35    30    30    30    30    30    30    30    30    30    30    30    30    45    45    30    30    30    30    30    30    30    35    35    30    45    35    30    35   ];
        mdot     = [3     6     3     10    3     3     3     3     3     3     3     3     3     4     3     3     3     3     3     3     3     4     10    3     3     3     4     10    3     10   ];
        
    case 8  % profile XXL      24.53 kWh
        times =    [7.000 7.25  7.433 7.75  8.016 8.250 8.500 8.750 9.000 9.500 10.00 10.50 11.00 11.50 11.75 12.75 14.50 15.00 15.50 16.00 16.50 17.00 18.00 18.25 18.50 19.00 20.50 20.76 21.25 21.5 ];
        energies = [0.105 1.82  0.105 6.24  0.105 0.105 0.105 0.105 0.105 0.105 0.105 0.105 0.105 0.105 0.105 0.735 0.105 0.105 0.105 0.105 0.105 0.105 0.105 0.105 0.105 0.105 0.735 6.240 0.105 6.24 ];
        dT_set   = [30    35    30    35    30    30    30    30    30    30    30    35    30    45    45    45    30    30    30    30    30    30    30    35    35    30    45    35    35    35   ];
        mdot     = [3     6     3     10    3     3     3     3     3     3     3     3     4     3     3     4     3     3     3     3     3     3     3     3     3     3     4     16    10    16   ];
        
    case 9  % profile 3XL      46.76 kWh
        times =    [7.00  8.016 9.000 10.50 11.75 12.75 15.50 18.50 20.50 21.5 ];
        energies = [11.2  5.04  1.68  0.840 1.68  2.520 2.520 3.36  5.88  12.04];
        dT_set   = [35    30    30    35    30    45    30    30    45    35   ];
        mdot     = [48    24    24    24    24    32    24    24    32    48   ];
        
    case 10 % profile 4XL      93.52 kWh
        times =    [7.000 8.016 9.000 10.50 11.75 12.75 15.50 18.50 20.50 21.5 ];
        energies = [22.40 10.08 3.36  1.680 3.360 5.04  5.04  6.72  11.76 24.08];
        dT_set   = [35    30    30    30    30    45    30    30    45    35   ];
        mdot     = [96    48    48    10    48    64    48    48    64    96   ];
        
    otherwise
        disp('Wrong definition of tapping profile')
end
energies = energies*36e5;
times = times*3600;
mdot = mdot/60;

% copy till here

%% verify them ...
disp(' ')
switch eu_tap
    case 1
        disp('Cycle 3XS should be 0.345 kWh')
    case 2
        disp('Cycle XXS should be 2.1 kWh')
    case 3
        disp('Cycle XS should be 2.1 kWh')
    case 4
        disp('Cycle S should be 2.1 kWh')
    case 5
        disp('Cycle M should be 5.845 kWh')
    case 6
        disp('Cycle L should be 11.655 kWh')
    case 7
        disp('Cycle XL should be 19.07 kWh')
    case 8
        disp('Cycle XXL should be 24.53 kWh')
    case 9
        disp('Cycle 3XL should be 46.76 kWh')
    case 10
        disp('Cycle 4XL should be 93.52 kWh')
end
disp(['sum of energy ', num2str(sum(energies)/36e5), ' kWh'])
disp(['length times ', num2str(length(times))])
disp(['length energies ', num2str(length(energies))])
disp(['length dT_set ', num2str(length(dT_set))])
disp(['length mdot ', num2str(length(mdot))])
disp(' ')

end % end for