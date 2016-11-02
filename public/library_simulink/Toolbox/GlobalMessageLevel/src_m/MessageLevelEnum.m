classdef MessageLevelEnum < Simulink.IntEnumType
% $Revision$
% $Author$
% $Date$
% $HeadURL$
	enumeration
		DEBUGLEVEL(1)
        INFOLEVEL(2)
        WARNINGLEVEL(3)
        ERRORLEVEL(4)
        FATALLEVEL(5)
        NOLEVEL(6)
    end
end