/***********************************************************************
 * This file is part of the CARNOT Blockset.
 * Copyright (c) 1998-2015, Solar-Institute Juelich of the FH Aachen.
 * Additional Copyright for this file see list auf authors.
 * All rights reserved.
 * Redistribution and use in source and binary forms, with or without 
 * modification, are permitted provided that the following conditions are 
 * met:
 * 1. Redistributions of source code must retain the above copyright notice, 
 *    this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright 
 *    notice, this list of conditions and the following disclaimer in the 
 *    documentation and/or other materials provided with the distribution.
 * 3. Neither the name of the copyright holder nor the names of its 
 *    contributors may be used to endorse or promote products derived from 
 *    this software without specific prior written permission.
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE 
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF 
 * THE POSSIBILITY OF SUCH DAMAGE.
 ***********************************************************************
 *  M O D E L    O R    F U N C T I O N
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * Carnot model and function c-files should use a name which gives a 
 * hint to the model of function (avoid names like mytestmodel1.c).
 * If you use header files related to the model, they should have the 
 * same name as the model file. Use _int in the header file name if it
 * concerns only model file internal definitions, use _ext if the header
 * file is used by several models. 
 * Example: store_sample.c store_sample_int.h
 * If your model has several c-files, give the mdl-function file the major
 * name and the other files an appendix.
 * Example store_sample.c, store_samle_hx.c
 * 
 * [TO ADAPT] stratified thermal storage without any use
 *
 * Syntax  [sys, x0] = store_sample(t,x,u,flag)
 *
 * related header files: store_samle_int.h
 *
 * related c-files: 
 *  store_sample.c      Simulink mdl functions (mdlOutputs, ...)
 *  store_sample_hx.c   functions for heat exchanger calculations
 *
 * compiler command (Matlab): 
 * mex store_sample.c store_samle_hx.c carlib.lib
 *
 * author list:     xn -> Xaver Noname
 *
 * version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
 *
 * Version  Author  Changes                                     Date
 * 5.0.0    xn      created                                     35may1899
 * 5.1.0    xn      model validated (see report in MyThesis)    35jun1899
 *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *  D E S C R I P T I O N
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * The storage is devided into "NODES" nodes 
 * energy-balance for every node with the differential equation:
 *
 * (rho*cp) * dT/dt = U * Aloss / Vnode *      (Tamb        - Tnode)
 *
 *  symbol      used for                                        unit
 *  Aloss       surface area for losses of one storage node     m^2
 *  cp          heat capacity                                   J/(kg*K)
 *  dh          distance between two nodes                      m
 *  rho         density                                         kg/m^3
 *  T           temperature                                     K
 *  t           time                                            s
 *  U           heat loss coefficient                           W/(m^2*K)
 *	Vnode       node volume                                     m^3
 *
 *
 * Definiton of INPUTS and OUTPUTS 
 *
 * structure of the input vector u
 * port 1 : input
 *  index               use
 *  0                   ambient temperature
 *
 * port 2 : input
 *  index               use
 *  0..19               THV1
 *
 * port 3 : input
 *  index               use
 *  0..19               THV2
 *
 * structure of the output vector y
 * port 1:
 *  index           use
 *  0               temperature of 0.(lowest) measurement point
 *  1               temperature of 1. measurement point
 *  ...
 *  10              temperature of 10 measurement point
 *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *  L I T E R A T U R E
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * /1/  VDI Waermeatlas 1991
 * /2/  Patankar: Numerical Heat Transfer, 1983
 * /3/  Wager: Waemeuebertragung, Vogel Verlag, 2003
 * /4/   * Duffie, Beckman: Solar Engineering of Thermal Processes, 2006
 */
 
#define S_FUNCTION_NAME  store_sample
#define S_FUNCTION_LEVEL 2

#include "simstruc.h"
#include "carlib.h"
#include "store_sample_int.h"

#include <math.h>
