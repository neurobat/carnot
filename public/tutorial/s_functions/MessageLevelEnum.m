classdef MessageLevelEnum < Simulink.IntEnumType
	enumeration
		DEBUGLEVEL(1)
        INFOLEVEL(2)
        WARNINGLEVEL(3)
        ERRORLEVEL(4)
        FATALLEVEL(5)
        NOLEVEL(6)
        HALLO(7)
    end
end
