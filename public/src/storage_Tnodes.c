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
 * $Revision$
 * $Author$
 * $Date$
 * $HeadURL$
 ***********************************************************************
 *  M O D E L    O R    F U N C T I O N
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * multiport stratified thermal storage with heatexchangers and an
 * optional storage-in-storage solution to seperate the fluid of the house
 * heating system from the drinking water for the bathroom.
 *
 * Syntax  [sys, x0] = generic_store(t,x,u,flag)
 *
 * author list:     aw -> Arnold Wohlfeil
 *                  hf -> Bernd Hafner
 *
 * version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
 *
 * Version  Author  Changes                                     Date
 * 5.0.1    hf      created, based on generic_store.c           17dec2012
 * 6.0.1    hf      reduced second output to node temperature   10oct2013
 *                  (removed density and heat_capacity)
 * 6.1.0    hf      comments and literature added               24nov2014
 * 6.1.1    aw/hf   STANDING, NCONNECT are integer, rounded     12feb2015
 * 6.1.2    aw      Work vectors converted to DWORK             24aug2015
 *                  SimstateCompiliance and
 *                  MultipleExecInstances activated
 * 6.1.3    aw      implicit casts replaced by explicit casts   10sep2015
 * 6.1.4    hf      ssSetInputPortDirectFeedThrough to 1        03jan2017
 *                  for all inports
 * 6.1.5    hf      ssSetInputPortDirectFeedThrough to 0        13jan2017
 *                  for all inports, was not the reason for
 *                  Matlab crash
 *
 * Copyright (c) 1998-2017 Solar-Institut Juelich, Germany
 * additional copyright by the authors
 * 
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *  D E S C R I P T I O N
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * The storage is devide into "NODES" nodes 
 * energy-balance for every node with the differential equation:
 *
 * (rho*cp) * dT/dt = U * Aloss / Vnode *      (Tamb        - Tnode)
 *                  + cond / dh^2 *            (Tnode_above - Tnode)          
 *                  + cond / dh^2 *            (Tnode_below - Tnode)          
 *                  + mdot_up  * cp / Vnode *  (Tnode_below - Tnode)
 *                  + mdot_down * cp / Vnode * (Tnode_above - Tnode)
 *                  + mdot_in * cp / Vnode *   (Tin         - Tnode)
 *                  + Qdot2node
 * 
 * 
 *  symbol      used for                                        unit
 *  Aloss       surface area for losses of one storage node     m^2
 *  Ahx         surface area of heat exchanger per storage node m^2
 *	cond        effective axial heat conduction                 W/(m*K)
 *  cp          heat capacity                                   J/(kg*K)
 *  dh          distance between two nodes                      m
 *  mdot_up     mass flow rate                                  kg/s
 *  mdot_down      -- " --                                      kg /s
 *              mdot_up or mdot_down is zero according to sum of flowrates
 *  Qdot2node   power input to node from external source / sink W
 *  rho         density                                         kg/m^3
 *  T           temperature                                     °C
 *  Tin         temperature of flow entering a node from outside °C
 *  t           time                                            s
 *  U           heat loss coefficient                           W/(m^2*K)
 *	Vnode       node volume                                     m^3
 *
 * The differential equation is derived from the energy conservation 
 * equation by using the finite volume method [Patankar: Numerical Heat
 * Transfer and Fluid Flow, 1980].
 *
 * ----- Inversed thermocline -----
 * An inversed thermocline is a node with lower density below a node with
 * higher density. At typical temperatures it can be translated to a node
 * with higher temperature below a node with lower temperature. Exception
 * is water below 4°C. 
 * An inversed thermocline exists in the model, if the temperature of the
 * lower node is more than LIMIT_T_INVERSED degrees above the upper node.
 * In that case the temperatures of the nodes are mixed. For the geometry
 * of a laying cylinder the different volumes of the nodes are taken in 
 * account.
 *
 * ----- Number of nodes -----
 * The temperature for every node (slice) is calculated by the above
 * equation. The number of nodes is variable and can be set as a
 * parameter of the s-function from Simulink.
 *
 * ----- Number of measurement points -----
 * Because we need to know the temperature at fixed places inside the
 * storage, a number of measurement points (M_PTS) is placed at
 * equidistant locations inside the storage, no matter how many nodes
 * are used for the calculation.
 *
 * The output vector y[] starts with the bottom-temperature (y[0]) and
 * ends with the top-temperature (y[M_PTS]).
 *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *           Definiton of inputs and outputs 
 *
 * structure of u (input vector)
 *  port    index               use
 *  0       0                   ambient temperature
 *
 *  1       0*nodes..1*nodes-1  temperature of flow entering from outside, vector with one element per node
 *          1*nodes..2*nodes-1  massflow entering from outside, vector with one element per node
 *          2*nodes..3*nodes-1  inner massflow upwards
 *          3*nodes..4*nodes-1  inner massflow downwards
 *          4*nodes..5*nodes-1  power entering node from outside, vector with one element per node
 *          5*nodes+0           pressure in storage
 *          5*nodes+1           fluid_id of fluid in the storage
 *          5*nodes+2           fluid_mix of fluid in the storage
 *
 *  2       0*nodes..1*nodes-1  temperature of flow entering from outside, vector with one element per node
 *          1*nodes..2*nodes-1  massflow entering from outside, vector with one element per node
 *          2*nodes..3*nodes-1  inner massflow upwards
 *          3*nodes..4*nodes-1  inner massflow downwards
 *          4*nodes..5*nodes-1  power entering node from outside, vector with one element per node
 *          5*nodes+0           pressure in storage
 *          5*nodes+1           fluid_id of fluid in the storage
 *          5*nodes+2           fluid_mix of fluid in the storage
 * ...
 * NCONNECT 0*nodes..1*nodes-1  temperature of flow entering from outside, vector with one element per node
 *          1*nodes..2*nodes-1  massflow entering from outside, vector with one element per node
 *          2*nodes..3*nodes-1  inner massflow upwards
 *          3*nodes..4*nodes-1  inner massflow downwards
 *          4*nodes..5*nodes-1  power entering node from outside, vector with one element per node
 *          5*nodes+0           pressure in storage
 *          5*nodes+1           fluid_id of fluid in the storage
 *          5*nodes+2           fluid_mix of fluid in the storage
 *
 * structure of y, output vector
 *  port    index               use
 *  0       0                   internal change of energy
 *          1                   energy lost to ambient
 *  1       0*nodes..1*nodes-1  temperatures of nodes
 *          1*nodes..2*nodes-1  density of fluid at nodes
 *          2*nodes..3*nodes-1  heat capacity of fluid at nodes
 *
 */

#define S_FUNCTION_NAME  storage_Tnodes
#define S_FUNCTION_LEVEL 2

#include "simstruc.h"
#include "carlib.h"
#include <math.h>

/* defines for parameters */
#define DIA             *mxGetPr(ssGetSFcnParam(S, 0))      /* storage diameter [m] */
#define VOLUME          *mxGetPr(ssGetSFcnParam(S, 1))      /* storage volume [m^3] */
#define STANDING  (int)(*mxGetPr(ssGetSFcnParam(S, 2))+0.5) /* = 1 for standing cylinder */
#define ULOSS           *mxGetPr(ssGetSFcnParam(S, 3))      /* heat loss coefficient U in [W/(m^2*K)] 	*/
#define UBOT            *mxGetPr(ssGetSFcnParam(S, 4))      /* heat loss coefficient by the bottom U in [W/(m^2*K)] 	*/
#define UTOP            *mxGetPr(ssGetSFcnParam(S, 5))      /* heat loss coefficient by the top U in [W/(m^2*K)] 	*/
#define COND            *mxGetPr(ssGetSFcnParam(S, 6))      /* axial heat conductivity [W/(m*K)] */
#define TINI                     ssGetSFcnParam(S, 7)       /* initial storage temperature in [°C], is a pointer - might be a vector */
#define NODES           *mxGetPr(ssGetSFcnParam(S, 8))      /* number of nodes */
#define NCONNECT  (int)(*mxGetPr(ssGetSFcnParam(S, 9))+0.5) /* number of connections */
#define NPARAMS                                   10

/* defines for inputs */
#define TAMB            (*u0[0])            /* ambient temperature is first input */
#define T_IN(n)         (*u1[n])            /* temperature of flow entering from outside */
#define MDOT_IN(n)      (*u1[n+nodes])      /* massflow entering from outside */
#define MDOT_UP(n)      (*u1[n+2*nodes])    /* inner massflow upwards, index 0 for flow from node 0 to node 1 */
#define MDOT_DOWN(n)    (*u1[n+3*nodes])    /* inner massflow down, index 0 for flow from node 1 to node 0 */
#define QDOT_IN(n)      (*u1[n+4*nodes])    /*  power entering node from outside */
#define FLUID_PRESSURE  (*u1[5*nodes])
#define FLUID_ID        (*u1[5*nodes+1])
#define FLUID_MIX       (*u1[5*nodes+2])
#define N_INPUTS        (5*(int_T)NODES+3)
#define N_INPUT_PORTS   ((int_T)NCONNECT+1)


/* defines for derivatves and internal states */
#define DTDT(n) dx[n]               /* dT/dt derivative of node temperature */
#define T(n)     x[n]               /* actual node temperature */

#define QLOSS    x[nodes]           /* energy losses */
#define DLOSSDT dx[nodes]           /* time derivative of energy losses = lost power)*/

#define ENERGY   x[nodes+1]         /* internal change of energy */
#define DEDT    dx[nodes+1]         /* time derivative of internal energy = power */

#define N_CONT_STATES  ((int_T)NODES+2)



#define DWORK_DH_NR             0     /* heigth of one node */
#define DWORK_HCON_NR           1     /* heat transport by conductivity */
#define DWORK_FLUID_NR          2     /* fluid type in the storage */
#define DWORK_MIX_NR            3     /* fluid mixture in the storage */
#define DWORK_PRESS_NR          4     /* fluid pressure in the storage */
#define DWORK_V_NODE_NR         5     /* volume of the nodes */
#define DWORK_LOSS_NR           6     /* losses of the nodes */
#define DWORK_CP_NODE_NR        7     /* heat capacity of node in J/kg/K */
#define DWORK_RHO_NODE_NR       8     /* density of node in kg/m³ */
#define DWORK_MDOTIN_NR         9     /* entering massflow  */
#define DWORK_MDOTUP_NR         10    /* massflow upwards   */
#define DWORK_MDOTDOWN_NR       11    /* massflow downwards */
#define DWORK_QDOTIN_NR         12    /* entering power */
#define DWORK_TIN_NR            13    /* entering temperature */
#define DWORK_CHECK_FLUIDS_NR   14    /* flag for checking incomming fluids (once per simulation) */

#define DH                      dwork_dh[0]           /* heigth of one node */
#define HCON                    dwork_hcon[0]         /* heat transport by conductivity */
#define FLUID                   dwork_fluid[0]        /* fluid type in the storage */
#define MIX                     dwork_mix[0]          /* fluid mixture in the storage */
#define PRESS                   dwork_press[0]        /* fluid pressure in the storage */
#define V_NODE(n)               dwork_v_node[n]       /* volume of the nodes */
#define LOSS(n)                 dwork_loss[n]         /* losses of the nodes */
#define CP_NODE(n)              dwork_cp_node[n]      /* heat capacity of node in J/kg/K */
#define RHO_NODE(n)             dwork_rho_node[n]     /* density of node in kg/m³ */
#define MDOTIN(n)               dwork_mdotin[n]       /* entering massflow  */
#define MDOTUP(n)               dwork_mdotup[n]       /* massflow upwards   */
#define MDOTDOWN(n)             dwork_mdotdown[n]     /* massflow downwards */
#define QDOTIN(n)               dwork_qdotin[n]       /* entering power */
#define TIN(n)                  dwork_tin[n]          /* entering temperature */
#define CHECK_FLUIDS            dwork_check_fluids[0] /* flag for checking incomming fluids (once per simulation) */

/* other defines */
#define TOP                 (nodes-1)
#define BOTTOM              0
#define LIMIT_T_INVERSED    1.0e-4

#define MDL_CHECK_PARAMETERS
#if defined(MDL_CHECK_PARAMETERS) && defined(MATLAB_MEX_FILE)
  /* Function: mdlCheckParameters =============================================
   * Abstract:
   *    Validate our parameters to verify they are okay.
   */
static void mdlCheckParameters(SimStruct *S)
{
      int_T sizet0 = (int_T)mxGetNumberOfElements(TINI);
    // printf("start check param");   // *************
      /* */
      {
          if (DIA < 1.0e-3) {
              ssSetErrorStatus(S,"Diameter must be > 1 mm");
              return;
          }
      }
      /* */
      {
          if (VOLUME < 1.0e-5) {
              ssSetErrorStatus(S,"Volume must be > 1e-5 m^3");
              return;
          }
      }
      /* */
      {
          if (STANDING != 0 && STANDING != 1) {
              ssSetErrorStatus(S,"Position must be 0 = lying or 1 = standing");
              return;
          }
      }
      /* */
      {
          if (ULOSS < 0.0) {
              ssSetErrorStatus(S,"Cylinder wall loss coefficient must be >= 0");
              return;
          }
      }
      /* */
      {
          if (UBOT < 0.0) {
              ssSetErrorStatus(S,"Bottom loss coefficient must be >= 0");
              return;
          }
      }
      /* */
       {
          if (UTOP < 0.0) {
              ssSetErrorStatus(S,"Top loss coefficient must be >= 0");
              return;
          }
      }
      /* */
      {
          if (COND < 0.0) {
              ssSetErrorStatus(S,"Vertical heat conductivity must be >= 0");
              return;
          }
      }
      /* look for proper size of t0-vector */
      {
          if (sizet0 > 1 && sizet0 != NODES) {
              ssSetErrorStatus(S,"Inititial temperture must be a scalar or a vector of lenght NODES");
              return;
          }
      }
      /* number of nodes */
      {
          if (NODES < 1) {
              ssSetErrorStatus(S,"Number of nodes must be >= 1");
              return;
          }
      }
      /* number of connections */
      {
          if (NCONNECT < 1) {
              ssSetErrorStatus(S,"Number of connections must be >= 1");
              return;
          }
      }
    // printf("end check param");   // *************
}
#endif /* MDL_CHECK_PARAMETERS */
 


/* Function: mdlInitializeSizes ===============================================
 * Abstract:
 *   Setup sizes of the various vectors.
 */
static void mdlInitializeSizes(SimStruct *S)
{
    int_T n;

    // printf("start initialize");   // *************

    ssSetNumSFcnParams(S, NPARAMS);
    #if defined(MATLAB_MEX_FILE)
    if (ssGetNumSFcnParams(S) == ssGetSFcnParamsCount(S))
    {
        mdlCheckParameters(S);
        if (ssGetErrorStatus(S) != NULL)
        {
            return;
        }
    }
    else
    {
        return; /* Parameter mismatch will be reported by Simulink */
    }
    #endif

    ssSetNumContStates(S, N_CONT_STATES);   /* number of continuous states */
    ssSetNumDiscStates(S, 0);               /* number of discrete states */

    if (!ssSetNumInputPorts(S, N_INPUT_PORTS)) return;

    ssSetInputPortWidth(S, 0, 1);
    ssSetInputPortDirectFeedThrough(S, 0, 0);
//     ssSetInputPortDirectFeedThrough(S, 0, 1);       // changed Hf, 03jan2017

    for (n = 1; n <= NCONNECT; n++)
    {
        ssSetInputPortWidth(S, n, N_INPUTS);
        ssSetInputPortDirectFeedThrough(S, n, 0);
//         ssSetInputPortDirectFeedThrough(S, n, 1);   // changed Hf, 03jan2017
    }

    if (!ssSetNumOutputPorts(S, 2)) return;
    ssSetOutputPortWidth(S, 0, 2);
    ssSetOutputPortWidth(S, 1, (int_T)NODES);
    
    ssSetNumSampleTimes(S, 1);

    ssSetNumDWork(S, 15);
    ssSetDWorkWidth(S, 0, 1); /* heigth of one node */
    ssSetDWorkDataType(S, 0, SS_DOUBLE);
    ssSetDWorkName(S, 0, "DWORK_DH");
    ssSetDWorkUsageType(S, 0, SS_DWORK_USED_AS_DSTATE);
    ssSetDWorkWidth(S, 1, 1); /* heat transport by conductivity */
    ssSetDWorkDataType(S, 1, SS_DOUBLE);
    ssSetDWorkName(S, 1, "DWORK_HCON");
    ssSetDWorkUsageType(S, 1, SS_DWORK_USED_AS_DSTATE);
    ssSetDWorkWidth(S, 2, 1); /* fluid type in the storage */
    ssSetDWorkDataType(S, 2, SS_DOUBLE);
    ssSetDWorkName(S, 2, "DWORK_FLUID");
    ssSetDWorkUsageType(S, 2, SS_DWORK_USED_AS_DSTATE);
    ssSetDWorkWidth(S, 3, 1); /* fluid mixture in the storage */
    ssSetDWorkDataType(S, 3, SS_DOUBLE);
    ssSetDWorkName(S, 3, "DWORK_MIX");
    ssSetDWorkUsageType(S, 3, SS_DWORK_USED_AS_DSTATE);
    ssSetDWorkWidth(S, 4, 1); /* fluid pressure in the storage */
    ssSetDWorkDataType(S, 4, SS_DOUBLE);
    ssSetDWorkName(S, 4, "DWORK_PRESS");
    ssSetDWorkUsageType(S, 4, SS_DWORK_USED_AS_DSTATE);
    ssSetDWorkWidth(S, 5, (int)NODES); /* volume of the nodes */
    ssSetDWorkDataType(S, 5, SS_DOUBLE);
    ssSetDWorkName(S, 5, "DWORK_V_NODE");
    ssSetDWorkUsageType(S, 5, SS_DWORK_USED_AS_DSTATE);
    ssSetDWorkWidth(S, 6, (int)NODES); /* losses of the nodes */
    ssSetDWorkDataType(S, 6, SS_DOUBLE);
    ssSetDWorkName(S, 6, "DWORK_LOSS");
    ssSetDWorkUsageType(S, 6, SS_DWORK_USED_AS_DSTATE);
    ssSetDWorkWidth(S, 7, (int)NODES); /* heat capacity of node in J/kg/K */
    ssSetDWorkDataType(S, 7, SS_DOUBLE);
    ssSetDWorkName(S, 7, "DWORK_CP_NODE");
    ssSetDWorkUsageType(S, 7, SS_DWORK_USED_AS_DSTATE);
    ssSetDWorkWidth(S, 8, (int)NODES); /* density of node in kg/m³ */
    ssSetDWorkDataType(S, 8, SS_DOUBLE);
    ssSetDWorkName(S, 8, "DWORK_RHO_NODE");
    ssSetDWorkUsageType(S, 8, SS_DWORK_USED_AS_DSTATE);
    ssSetDWorkWidth(S, 9, (int)NODES); /* entering massflow */
    ssSetDWorkDataType(S, 9, SS_DOUBLE);
    ssSetDWorkName(S, 9, "DWORK_MDOTIN");
    ssSetDWorkUsageType(S, 9, SS_DWORK_USED_AS_DSTATE);
    ssSetDWorkWidth(S, 10, (int)NODES); /* massflow upwards */
    ssSetDWorkDataType(S, 10, SS_DOUBLE);
    ssSetDWorkName(S, 10, "DWORK_MDOTUP");
    ssSetDWorkUsageType(S, 10, SS_DWORK_USED_AS_DSTATE);
    ssSetDWorkWidth(S, 11, (int)NODES); /* massflow downwards */
    ssSetDWorkDataType(S, 11, SS_DOUBLE);
    ssSetDWorkName(S, 11, "DWORK_MDOTDOWN");
    ssSetDWorkUsageType(S, 11, SS_DWORK_USED_AS_DSTATE);
    ssSetDWorkWidth(S, 12, (int)NODES); /* entering power */
    ssSetDWorkDataType(S, 12, SS_DOUBLE);
    ssSetDWorkName(S, 12, "DWORK_QDOTIN");
    ssSetDWorkUsageType(S, 12, SS_DWORK_USED_AS_DSTATE);
    ssSetDWorkWidth(S, 13, (int)NODES); /* entering temperature */
    ssSetDWorkDataType(S, 13, SS_DOUBLE);
    ssSetDWorkName(S, 13, "DWORK_TIN");
    ssSetDWorkUsageType(S, 13, SS_DWORK_USED_AS_DSTATE);
    ssSetDWorkWidth(S, 14, 1); /* entering temperature */
    ssSetDWorkDataType(S, 14, SS_UINT8);
    ssSetDWorkName(S, 14, "DWORK_CHK_FLU");
    ssSetDWorkUsageType(S, 14, SS_DWORK_USED_AS_DSTATE);
    
    ssSetNumRWork(S, 0);
    ssSetNumIWork(S, 0);
    ssSetNumPWork(S, 0);
    ssSetNumModes(S, 0);
    ssSetNumNonsampledZCs(S, 0);
    
    ssSetSimStateCompliance(S, USE_DEFAULT_SIM_STATE);
    ssSetSimStateVisibility(S, 1);
    ssSupportsMultipleExecInstances(S, true);

    // printf("end initialize");   // *************
} /* end mdlInitializeSizes */


/* Function: mdlInitializeSampleTimes =========================================
 * Abstract:
 *    Specifiy that we inherit our sample time from the driving block.
 */
static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, CONTINUOUS_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, 0.0);
}


#define MDL_START  /* Change to #undef to remove function */
#if defined(MDL_START)
  /* Function: mdlStart =======================================================
   * Abstract:
   *    This function is called once at start of model execution. If you
   *    have states that should be initialized once, this is the place
   *    to do it.
   */
static void mdlStart(SimStruct *S)
{
    real_T *dwork_dh     = (real_T *)ssGetDWork(S, DWORK_DH_NR);
    real_T *dwork_hcon   = (real_T *)ssGetDWork(S, DWORK_HCON_NR);
    real_T *dwork_fluid  = (real_T *)ssGetDWork(S, DWORK_FLUID_NR);
    real_T *dwork_v_node = (real_T *)ssGetDWork(S, DWORK_V_NODE_NR);
    real_T *dwork_loss   = (real_T *)ssGetDWork(S, DWORK_LOSS_NR);
    
    real_T vol   = VOLUME;      /* storage volume   */
    real_T dia   = DIA;         /* storage diameter */
    real_T uloss = ULOSS;       /* heat loss coefficient */
    real_T ubot  = UBOT;        /* heat loss coefficient of the bottom */
    real_T utop  = UTOP;        /* heat loss coefficient of the top */
    real_T cond  = COND;        /* vertical conductivity */
    int_T  nodes = (int_T)NODES;/* numer of nodes   */
    int_T  standing = (int_T)STANDING;
    
    int_T n;
    real_T Aloss, h1, a1, a2;

    // printf("start mdlStart");   // *************

    FLUID = 0.0;                /* no fluid in the storage at the beginning */
    
    /* height of one node */
    if (standing)
        DH = 4.0*vol/(PI*dia*dia*(real_T)nodes);
    else
        DH = dia/(real_T)nodes;
    
    /* heat transport terms */
    HCON  = cond/(DH*DH);                   /* by conductivity in W/m^3/K */
    
    /* volume and loss of one node */
    if (standing)                           /* geometry of a vertical cylinder */
    {
        for (n = BOTTOM; n <= TOP; n++) 
        {
            V_NODE(n) = vol/(real_T)nodes;  /* volume of node */
            Aloss = PI*dia*DH;
            LOSS(n) = uloss*Aloss/V_NODE(n); /* storage losses per node in W/m^3 */     
        }
        LOSS(TOP)    += utop/DH;            /* extra losses of top */
        LOSS(BOTTOM) += ubot/DH;            /* extra losses of bottom */
    } 
    else                                    /* values for lying cylinder */
    {
        h1 = 0.0;
        a1 = 0.0;
        
        Aloss = (4.0*vol/dia + 0.5*PI*dia*dia)/(real_T)nodes;
        
        for (n = BOTTOM; n <= TOP; n++) 
        {
            h1 += DH;
            a2 = a1;                                        /* crosssection surface of slice below */ 
            a1 = 0.5*(0.25*dia*dia*2.0*acos(1.0-2.0*h1/dia)
                - 2.0*sqrt(dia*h1-h1*h1)*(0.5*dia-h1));
            V_NODE(n) = (a1-a2)*4.0*vol/(PI*dia*dia);       /* volume of slice without inner storage*/
            LOSS(n)  = uloss*Aloss/V_NODE(n);               /* loss of side walls in W/m^3 */
            
            //printf("n=%i  a1=%3.2f  a2=%3.2f  h1=%3.2f  V=%3.2f  LOSS=%3.2f \n", n, a1, a2, h1, V_NODE(n), LOSS(n));
            
            /* bottom and top losses are not evaluated for lying cylinder */
        } /* end for */
    } /* end if ... else ... */
    // printf("end mdlStart");   // *************
} /* end mdl_start */
#endif /*  MDL_START */


#define MDL_INITIALIZE_CONDITIONS
/* Function: mdlInitializeConditions ========================================
 * Abstract:
 * The mdlInitializeConditions method is called at simulation start.
 * Initialize states here.
 */
#if defined(MDL_INITIALIZE_CONDITIONS)
static void mdlInitializeConditions(SimStruct *S)
{
    real_T *x0    = ssGetContStates(S);
    uint8_T *dwork_check_fluids = (uint8_T*)ssGetDWork(S, DWORK_CHECK_FLUIDS_NR);
    const real_T *t0 = mxGetPr(TINI);                   /* access to vector: see simulink\src\vlimitint.c */
    int_T sizet0 = (int_T)mxGetNumberOfElements(TINI);
    int_T nodes = (int_T)NODES;                         /* numer of nodes as parameter */
    int_T n;
    
    // printf("start mdlInitializeConditions");   // *************
    CHECK_FLUIDS = (uint8_T)1;               /* check incomming fluids once in mdlDerivatives */
    
    /* state-vector is initialized with TINI */
    if (sizet0 == 1)
    {              /* nodes have same temperature t0 */
        for (n = BOTTOM; n <= TOP; n++) 
        {
            x0[n] = t0[0];
        }
    }
    else
    {                        /* nodes have inidvidual temperature in vector t0 */
        for (n = BOTTOM; n <= TOP; n++) 
        {
            x0[n] = t0[n];
        }
    } /* endif sizet0 */

    for (n = nodes; n < nodes+2; n++)
    {
        x0[n] = 0.0;                /* energy states are initialized with 0 */
    }
    // printf("end mdlInitializeConditions");   // *************
} /* end mdlInitializeConditions */
#endif /* MDL_INITIALIZE_CONDITIONS */



/* Function: mdlOutputs =======================================================
 */
static void mdlOutputs(SimStruct *S, int_T tid)
{
    real_T *q = ssGetOutputPortRealSignal(S,0);
    real_T *y = ssGetOutputPortRealSignal(S,1);
    real_T *x = ssGetContStates(S);
    real_T *dwork_v_node = (real_T*)ssGetDWork(S, DWORK_V_NODE_NR);
    int_T  nodes = (int_T)NODES;    /* numer of nodes   */
    int_T  standing = (int_T)STANDING;
    real_T tmix, vol;
    int_T  n, i, inverse, ind;
    
    // printf("start mdlOutputs");   // *************
    /*  port    index               use
     *  0       0                   internal change of energy
     *          1                   energy lost to ambient
     *  1       0*nodes..1*nodes-1  temperatures of nodes
     *          1*nodes..2*nodes-1  density of fluid at nodes
     *          2*nodes..3*nodes-1  heat capacity of fluid at nodes
     */
    /* set node temperatures */
    for (n = BOTTOM; n <= TOP; n++)
    {
        y[n] = T(n);
        //y[n+nodes] = RHO_NODE(n);
        //y[n+2*nodes] = CP_NODE(n);
    }
    /* energy balance */
    q[0] = ENERGY;   /* internal change of energy */
    q[1] = QLOSS;     /* thermal losses */

    /*****************************
     * inversed thermocline *
     *****************************/
    do {
        inverse = 0;
        n = TOP;
        do {
            if (T(n-1)-1.0e-4 > T(n))     /* if there is an inversed thermocline */
            {
                inverse = 1;
                
                if (standing)             /* simple version for standing cylinder, all nodes have the same volume */
                {
                    /* find inversed layers above */
                    ind = n;
                    do {
                        ind++;
                        /* mix all inversed layers */
                        tmix = T(n-1);
                        for (i = n; i < ind; i++)
                            tmix += T(i);
                        tmix /= ind-n+1;
                        for (i = n-1; i < ind; i++)
                            T(i) = tmix;
                    } while (T(ind)+LIMIT_T_INVERSED < T(n-1) && ind <= TOP);
                }
                else            /* laying cylinder, individual volume */
                {
                    /* find inversed layers above */
                    ind = n;
                    do {
                        ind++;
                        /* mix all inversed layers */
                        tmix = T(n-1)*V_NODE(n-1);
                        vol = V_NODE(n-1);
                        for (i = n; i < ind; i++) {
                            tmix += T(i)*V_NODE(i);
                            vol += V_NODE(i);
                        }
                        tmix /= (real_T)(ind-n+1)*vol;
                        for (i = n-1; i < ind; i++)
                            T(i) = tmix;
                    } while ((T(n-1)-1.0e-4 > T(n)) && (ind <= TOP));
                } /* end if standing ... else ... */
            } /* end if RHO_NODE */
            n--;
        } while (n > BOTTOM);
    } while (inverse); /* end do */

    // printf("end mdlOutputs");   // *************
} /* end mdlOutputs */



#define MDL_DERIVATIVES
/* Function: mdlDerivatives ================================================= */
static void mdlDerivatives(SimStruct *S)
{
    real_T            *dx = ssGetdX(S);
    real_T            *x  = ssGetContStates(S);
    real_T *dwork_dh            = (real_T*)ssGetDWork(S, DWORK_DH_NR);
    real_T *dwork_hcon          = (real_T*)ssGetDWork(S, DWORK_HCON_NR);
    real_T *dwork_fluid         = (real_T*)ssGetDWork(S, DWORK_FLUID_NR);
    real_T *dwork_mix           = (real_T*)ssGetDWork(S, DWORK_MIX_NR);
    real_T *dwork_press         = (real_T*)ssGetDWork(S, DWORK_PRESS_NR);
    real_T *dwork_mdotin        = (real_T*)ssGetDWork(S, DWORK_MDOTIN_NR);
    real_T *dwork_mdotup        = (real_T*)ssGetDWork(S, DWORK_MDOTUP_NR);
    real_T *dwork_mdotdown      = (real_T*)ssGetDWork(S, DWORK_MDOTDOWN_NR);
    real_T *dwork_qdotin        = (real_T*)ssGetDWork(S, DWORK_QDOTIN_NR);
    real_T *dwork_tin           = (real_T*)ssGetDWork(S, DWORK_TIN_NR);
    real_T *dwork_loss          = (real_T*)ssGetDWork(S, DWORK_LOSS_NR);
    real_T *dwork_v_node        = (real_T*)ssGetDWork(S, DWORK_V_NODE_NR);
    real_T *dwork_cp_node       = (real_T*)ssGetDWork(S, DWORK_CP_NODE_NR);
    real_T *dwork_rho_node      = (real_T*)ssGetDWork(S, DWORK_RHO_NODE_NR);
    uint8_T *dwork_check_fluids = (uint8_T*)ssGetDWork(S, DWORK_CHECK_FLUIDS_NR);
    InputRealPtrsType u0  = ssGetInputPortRealSignalPtrs(S,0);
    InputRealPtrsType u1;

    /* get model parameters */
    real_T vol  = VOLUME;
    real_T dia  = DIA;
    real_T dh   = DH;
    real_T hcon = HCON;
    int_T  nodes = (int_T)NODES;
    int_T  standing = (int_T)STANDING;
    real_T uhx, loss;
    int_T  n, nc;

    // printf("start mdlDerivatives");   // *************

    /* At the first function call: check the fluids entering the storage by a pipe connection */
    if (CHECK_FLUIDS)                           /* check incomming fluids once */
    {
        for (nc = 1; nc <= NCONNECT; nc++)           /* loop over all connections */
        {
            u1 = ssGetInputPortRealSignalPtrs(S,nc); /* get correct input vector for port nc */
            
            if (FLUID < 1.0)                /* if not yet set */
            {
                FLUID = FLUID_ID;           /* set fluid to first pipe fluid_id */
                MIX   = FLUID_MIX;
                PRESS = FLUID_PRESSURE;
                CHECK_FLUIDS = (uint8_T)0;           /* do not check fluids any more */
            }

            if (FLUID_ID > 0.0 && FLUID != FLUID_ID)
            {
                ssSetErrorStatus(S,"storage_Tnodes: all entering fluids must be of the same type");
                return;
            }
        } /* end if CHECK_FLUIDS */
    }
    
    /*******************************
     * pre-calculate arrays        *
     *******************************/
    for (n = BOTTOM; n <= TOP; n++)  /* n counts from BOTTOM (0) to TOP (nodes-1) */
    {
        MDOTIN(n)   = 0.0;                  /* set arrays to 0 */
        MDOTUP(n)   = 0.0;
        MDOTDOWN(n) = 0.0;
        QDOTIN(n)   = 0.0;
        DTDT(n)     = 0.0;
        TIN(n)      = 0.0;
    }
    DLOSSDT = 0.0;                          /* energy loss of storage is 0 */
    DEDT = 0.0;                             /* energy change of storage is 0 */

    /* sum up massflow and power   */
    for (nc = 1; nc <= NCONNECT; nc++)      /* loop over all connections */
    {
        u1 = ssGetInputPortRealSignalPtrs(S,nc); /* get correct input vector for port nc */

        for (n = BOTTOM; n <= TOP; n++)  /* n counts from BOTTOM (0) to TOP (nodes-1) */
        {
            //printf("MDOT_IN(%i) (*u1[n+nodes]) %3.1f \n", n, n+nodes], MDOT_IN(n));
            if (MDOT_IN(n) > 0.0)
            {
                TIN(n) = (T_IN(n)*MDOT_IN(n)+TIN(n)*MDOTIN(n)); /* mix temperatures */
                MDOTIN(n) += MDOT_IN(n);    /* sum up incomming massflows */
                TIN(n) /= MDOTIN(n);        /* devide mixed temperature by total massflow */
            }
            MDOTUP(n)   += MDOT_UP(n);      /* sum up massflow upwards */
            MDOTDOWN(n) += MDOT_DOWN(n);    /* sum up massflow downwards */
            QDOTIN(n)   += QDOT_IN(n);      /* sum up power */
        } /* loop over nodes */
    } /* loop over connections */

    /**********************************
     * start of main calculation loop *
     **********************************/

    /*******************************
     * heat losses and conduction  *
     *******************************/
    for (n = BOTTOM; n <= TOP; n++)  /* n counts from BOTTOM (0) to TOP (nodes-1) */
    {
        /* heat losses */
        loss = LOSS(n)*(TAMB-T(n));             /* losses */
        DTDT(n) += loss;
        DLOSSDT += loss*V_NODE(n);              /* sum of losses for energy balance */

        /* axial conduction */
        if (n < TOP) 
            DTDT(n) += hcon*(T(n+1)-T(n));      /* heat conduction upwards in W/m^3	*/
        if (n > BOTTOM)
            DTDT(n) += hcon*(T(n-1)-T(n));      /* heat conduction downwards in W/m^3 */
        
        DEDT += DTDT(n)*V_NODE(n);
        
        //printf("Verluste DTDT(%i) %3.1f   V_NODE(%i) %3.3f   TAMB %3.1f  loss %3.1f \n", n, DTDT(n), n, V_NODE(n), TAMB, loss);
    } /* for n = BOTTOM to TOP */
    
    
    /*******************************
     *          fluid flow         *
     *******************************/
    for (n = BOTTOM; n <= TOP; n++)  /* n counts from BOTTOM (0) to TOP (nodes-1) */
    {
        uhx = 0.0;                   
        CP_NODE(n) = heat_capacity(FLUID,MIX,T(n),PRESS);   /* fluid property at node temperature */
        RHO_NODE(n) = density(FLUID, MIX, T(n), PRESS);

        /* massflow entering from outside */
        if (MDOTIN(n) > 0.0)                            /* if there is a massflow */
            uhx =  CP_NODE(n)*MDOTIN(n)*(TIN(n)-T(n));  /* power balance qdot = mdot * cp * T_diff */

        if (n < TOP                                     /* if not top : inner massflow array only for N-1 interfaces */
            && MDOTUP(n) < MDOTDOWN(n))                 /* and massflow upwards is smaller than massflow downwards : check interface to upper node */
        {
            uhx +=  CP_NODE(n)*(MDOTDOWN(n)-MDOTUP(n))*(T(n+1)-T(n)); /* power balance qdot = mdot * cp * T_diff */
        }

        if (n > BOTTOM                                  /* if not bottom : check interface to lower node */
            && MDOTUP(n-1) > MDOTDOWN(n-1))             /* and if massflow upwards is bigger than massflow downwards */
        {
                uhx +=  CP_NODE(n)*(MDOTUP(n-1)-MDOTDOWN(n-1))*(T(n-1)-T(n)); /* power balance qdot = mdot * cp * T_diff */
        }
        DTDT(n) += uhx/V_NODE(n);
        DEDT += uhx;

        //printf("Fluid flow DTDT(%i) %3.1f   TIN(%i) %3.1f   MDOTIN(%i) %3.3f \n", n, DTDT(n), n, TIN(n), n, MDOTIN(n));
    } /* for n = BOTTOM to TOP */

    
    /*****************************
     * heat from heat exchangers *
     *****************************/
    for (n = BOTTOM; n <= TOP; n++)                     /* n counts from BOTTOM (0) to TOP (nodes-1) */
    {
        DEDT += QDOTIN(n);
        DTDT(n) += QDOTIN(n)/V_NODE(n);
    } /* for n = BOTTOM to TOP */


    /***********************************
     * at last : adjust energy balance *
     ***********************************/
    for (n = BOTTOM; n <= TOP; n++)                     /* n counts from BOTTOM (0) to TOP (nodes-1) */
    {
        DTDT(n) /= (RHO_NODE(n)*CP_NODE(n));            /* divide by density*capacity */
        //         printf("adjusted: QDOTIN(%i) %3.1f  DTDT(%i) %5.5f \n", n, QDOTIN(n), n, DTDT(n));
    }
    // printf("end mdlDerivatives");   // *************
} /* end mdlDerivatives */


/* Function: mdlTerminate =====================================================
 * Abstract:
 *    No termination needed, but we are required to have this routine.
 */
static void mdlTerminate(SimStruct *S)
{
}


#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif

