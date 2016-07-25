rem /***********************************************************************
rem  * This file is part of the CARNOT Blockset.
rem  * This file is part of the CARNOT Blockset.
rem  * Copyright (c) 1998-2015, Solar-Institute Juelich of the FH Aachen.
rem  * Additional Copyright for this file see list auf authors.
rem  * All rights reserved.
rem  * Redistribution and use in source and binary forms, with or without 
rem  * modification, are permitted provided that the following conditions are 
rem  * met:
rem  * 1. Redistributions of source code must retain the above copyright notice, 
rem  *    this list of conditions and the following disclaimer.
rem  * 2. Redistributions in binary form must reproduce the above copyright 
rem  *    notice, this list of conditions and the following disclaimer in the 
rem  *    documentation and/or other materials provided with the distribution.
rem  * 3. Neither the name of the copyright holder nor the names of its 
rem  *    contributors may be used to endorse or promote products derived from 
rem  *    this software without specific prior written permission.
rem  * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
rem  * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
rem  * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
rem  * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE 
rem  * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
rem  * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
rem  * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
rem  * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
rem  * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
rem  * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF 
rem  * THE POSSIBILITY OF SUCH DAMAGE.
rem  ***********************************************************************

rem makecarlib, edited BowB 03.12.2008
rem added MS Visual Studio 2008 Express and Borland C++ 5.5 by DrWoA 2010-01-21
rem PahM 2012-09-12
rem      - msexpress8 set as default (MS Visual Studio 2008/2010 (Express))
rem      - fixed msexpress8 to work with Win7 64bit + MATLAB 32bit combination

rem *** choose the goto for following compiler ***

rem *** for MS Visual Studio 2005 ***
rem goto msstudio7

rem *** for MS Visual Studio 2008 Express (2010 compatible!) ***
goto msexpress8

rem *** for Borland C++ 5.5 ***
rem goto bcc

goto ende


:msstudio7
rem call pathdefinitions for MS Visual Studio 2005
@call "C:\Program Files\Microsoft Visual Studio 8\Common7\Tools\vsvars32.bat"
@call "C:\Program Files\Microsoft Visual Studio 8\Common7\Tools\vsvars32.bat"

rem cleanup
@del carlib.obj
@del carlib.lib
@del carlib.dll

rem define entrypoints for lib file (if changed, also change for msexpress8!!)
@echo  EXPORTS                          > carlib.def
@echo  density                          >> carlib.def
@echo  density_solid                    >> carlib.def
@echo  enthalpy                         >> carlib.def
@echo  enthalpy2temperature             >> carlib.def
@echo  entropy                          >> carlib.def
@echo  evaporation_enthalpy             >> carlib.def
@echo  extraterrestrial_radiation       >> carlib.def
@echo  grashof                          >> carlib.def
@echo  heat_capacity                    >> carlib.def
@echo  heat_capacity_solid              >> carlib.def
@echo  mixViscosity                     >> carlib.def
@echo  prandtl                          >> carlib.def
@echo  rangecheck                       >> carlib.def
@echo  relativeHumidity2waterContent    >> carlib.def
@echo  reynolds                         >> carlib.def
@echo  saturationproperty               >> carlib.def
@echo  saturationtemperature            >> carlib.def
@echo  solar_declination                >> carlib.def
@echo  solar_time                       >> carlib.def
@echo  solve_massflow_equation          >> carlib.def
@echo  specific_volume                  >> carlib.def
@echo  square                           >> carlib.def
@echo  temperature_conductivity         >> carlib.def
@echo  thermal_conductivity             >> carlib.def
@echo  thermal_conductivity_solid       >> carlib.def
@echo  unitconv_temp                    >> carlib.def
@echo  vapourcontent                    >> carlib.def
@echo  vapourpressure                   >> carlib.def
@echo  viscosity                        >> carlib.def
@echo  waterContent2relativeHumidity    >> carlib.def

rem call MS Visual Studio 2005 Compiler
cl -c -Zp8 -GR -W3 -EHs -D_CRT_SECURE_NO_DEPRECATE -D_SCL_SECURE_NO_DEPRECATE -D_SECURE_SCL=0 -DMATLAB_MEX_FILE -nologo carlib.c

rem call MS Visual Studio 2005 Linker
link /DLL carlib.obj /DEF:carlib.def

goto ende


:bcc
C:\Borland\BCC55\Bin\bcc32 -IC:\Borland\BCC55\Include -LC:\Borland\BCC55\Lib -WDR -DMATLAB_MEX_FILE c:\progra~1\matlab\r2007b\toolbox\simulink\carnot\carlib\carlib.c
impdef carlib.def carlib.dll
tlib carlib.lib +carlib.obj
goto ende


:msexpress8
rem *** call path definitions for MS Visual Studio 2008/2010 ***
@call c:\progra~1\micros~1.0\Common7\Tools\vsvars32.bat
rem progra~2 ensures compatibility with Win7 64bit (MATLAB 32bit)
@call c:\progra~2\micros~1.0\Common7\Tools\vsvars32.bat

rem *** cleanup ***
@del carlib.obj
@del carlib.lib
@del carlib.dll

rem *** define entry points for lib file (if changes, also change for msstudio7!!)***
@echo  EXPORTS                          > carlib.def
@echo  density                          >> carlib.def
@echo  density_solid                    >> carlib.def
@echo  enthalpy                         >> carlib.def
@echo  enthalpy2temperature             >> carlib.def
@echo  entropy                          >> carlib.def
@echo  evaporation_enthalpy             >> carlib.def
@echo  extraterrestrial_radiation       >> carlib.def
@echo  grashof                          >> carlib.def
@echo  heat_capacity                    >> carlib.def
@echo  heat_capacity_solid              >> carlib.def
@echo  mixViscosity                     >> carlib.def
@echo  prandtl                          >> carlib.def
@echo  rangecheck                       >> carlib.def
@echo  relativeHumidity2waterContent    >> carlib.def
@echo  reynolds                         >> carlib.def
@echo  saturationproperty               >> carlib.def
@echo  saturationtemperature            >> carlib.def
@echo  solar_declination                >> carlib.def
@echo  solar_time                       >> carlib.def
@echo  solve_massflow_equation          >> carlib.def
@echo  specific_volume                  >> carlib.def
@echo  square                           >> carlib.def
@echo  temperature_conductivity         >> carlib.def
@echo  thermal_conductivity             >> carlib.def
@echo  thermal_conductivity_solid       >> carlib.def
@echo  unitconv_temp                    >> carlib.def
@echo  vapourcontent                    >> carlib.def
@echo  vapourpressure                   >> carlib.def
@echo  viscosity                        >> carlib.def
@echo  waterContent2relativeHumidity    >> carlib.def


rem *** call MS Visual Studio 2008/2010 Compiler ***
cl -c -Zp8 -GR -W3 -EHs -D_CRT_SECURE_NO_DEPRECATE -D_SCL_SECURE_NO_DEPRECATE -D_SECURE_SCL=0 -DMATLAB_MEX_FILE -nologo carlib.c

rem *** call MS Visual Studio 2008/2010 Linker ***
link /DLL carlib.obj /DEF:carlib.def

goto ende


:ende
