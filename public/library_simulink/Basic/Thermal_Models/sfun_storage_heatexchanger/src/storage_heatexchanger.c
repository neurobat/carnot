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
 *                         M O D E L 
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * Heat exchangers for the multiport storage. This file is working together 
 * with the model "storage_Tnodes.c".
 *
 * Syntax  [sys, x0] = storage_heatexchanger(t,x,u,flag)
 *
 * author list:     hf -> Bernd Hafner
 *                  aw -> Arnold Wohlfeil
 *
 * version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
 *
 * Version  Author  Changes                                     Date
 * 5.0.1    hf      created, based on generic_store.c           31mar2013
 * 5.0.2    hf      added stratified discharging                16apr2013
 *                  array TS_OLD to avoid iteration  
 * 6.1.0    hf      limit NO_MASSFLOW for logthx calculation    19aug2014
 * 6.1.1    hf      Thx_out = Tstorage_node when no massflow    02dec2014
 * 6.2.0    hf      adapted equation for theoretical heat       10dec2014
 *                  exchangers, heat transfer inside the pipe
 *                  is included
 * 6.2.1    aw      RWork replaced by DWork vectors             11aug2015
 *                  SimstateCompiliance and
 *                  MultipleInstancesExec activated
 * 6.2.2    aw      implicit casts replaced by explicit casts,  10sep2015
 *                  unused variables deleted
 *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *                    D E S C R I P T I O N
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * The storage is devide into "NODES" nodes. For each node with an internal
 * heat exchanger this function calculates the power input to the storage 
 * nodes. The energy-balance for every node is:
 *
 * (rho*cp) * dT/dt = Uhx * Ahx / Vnode *  (Thx_node    - Tnode)
 *                   + ...
 *
 *  symbol      used for                                        unit
 *  Ahx         surface area of heat exchanger per storage node m^2
 *  cp          heat capacity                                   J/(kg*K)
 *  rho         density                                         kg/m^3
 *  t           time                                            s
 *  Tnode       temperature of the storage node                 degree C
 *  Thx_node    temperature of the heat exchanger node          degree C
 *  Uhx         heat transfer coefficient of heat exchanger     W/(m^2*K)
 *	Vnode       node volume                                     m^3
 *
 * The output vector y[] starts with the bottom-temperature (y[0]) and
 * ends with the top-temperature (y[M_PTS]).
 *
 * ----- Stratified charging heat exchangers and pipes ------
 * An inlet position above the outlet position should be specified, 
 * otherwise stratified charging does not make much sense. Set the inlet
 * position to the realtive height of the highest outlet of the stratifier.
 * The stratified charging heat exchangers start charging in the first
 * node where temperaure is below heat exchanger temperature. Nodes with 
 * higher temperatures are disregarded. Also the heat exchanger surface 
 * in these nodes is disregarded.
 * So an almost charged storage with a small cold water reservoir at the
 * bottom receives an other power from a stratified charging heat exchanger
 * than a completely cold storage. This calculation was choosen to model
 * the increase in buoyancy with the height of the cold water colum.
 *
 * WARNING : a stratified heat exchanger or pipe doesn't work with inlet 
 * and outlet in the same node.
 *
 *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *           Definiton of inputs and outputs 
 *
 * structure of y, output vector
 *  port    index               use
 *  0       0..nodes-1          power entering node from outside, vector with one element per node
 *  1       0..nodes-1          temperature of the heat exchanger at node
 *
 * structure of u, input vector
 *  port    index               use
 *  0       0..nodes-1          temperatures of storage nodes   degree C 
 *  1       0                   inlet temperature               degree C 
 *          1                   massflow                        kg/s 
 *          2                   pressure                        Pa
 *          3                   fluid ID (defined in CARNOT.h)
 *          4                   mixture  (defined in CARNOT.h)
 */


#define S_FUNCTION_NAME  storage_heatexchanger
#define S_FUNCTION_LEVEL 2

#include "simstruc.h"
#include "carlib.h"

#include <math.h>

/*  general parameters  */
#define PORT_ID     *mxGetPr(ssGetSFcnParam(S,0 ))  /* portID */
#define NODES       *mxGetPr(ssGetSFcnParam(S,1 ))  /* number of nodes                                      */
#define START_NODE  *mxGetPr(ssGetSFcnParam(S,2 ))  /* start node                                           */
#define END_NODE    *mxGetPr(ssGetSFcnParam(S,3 ))  /* end node                                             */

/*  smooth tube heat exchanger (theoretical model)     portID = 201, = 301 for stratified charging          */
#define DIA_PIPE    *mxGetPr(ssGetSFcnParam(S,4 ))  /* outer diameter of heat exchanger pipe       m        */
#define S_WALL      *mxGetPr(ssGetSFcnParam(S,5 ))  /* wall thickness                              m        */
#define LENGTH      *mxGetPr(ssGetSFcnParam(S,6 ))  /* length of pipe                              m        */
#define COND_WALL   *mxGetPr(ssGetSFcnParam(S,7 ))  /* conductivity  heat exch. material           W/(m²*K) */

/*  finned tube heat exchanger (theoretical model)     portID = 202, = 302 for stratified charging          */
#define DIA_FIN     *mxGetPr(ssGetSFcnParam(S,8 ))  /* total diameter of pipe with fins            m        */
#define S_WALL_FIN  *mxGetPr(ssGetSFcnParam(S,9 ))  /* wallthickness fin                           m        */
#define N_FIN       *mxGetPr(ssGetSFcnParam(S,10))  /* number of fins per meter                    1/m      */

/* heat exchanger, heat transfer fitted to measurement   */
/*   UA = uac+mdot*uam+(Theatexchanger-Tstorage)*uat   portID = 203, = 303 for stratified charging     */
/* EN 12977 heat exchanger, heat transfer fitted to measurement    */
/*   UA = uac * mdot^uam * ((Theatexchanger+Tstorage)/2)^uat     portID = 204, = 304 for stratified charging    */
#define UA_C        *mxGetPr(ssGetSFcnParam(S,4 ))  /* uac : constant heat transfer rate           W/K          */
#define UA_M        *mxGetPr(ssGetSFcnParam(S,5 ))  /* uam : massflow dependant heat transfer      W*s/(kg*K)   */
#define UA_T        *mxGetPr(ssGetSFcnParam(S,6 ))  /* uat : temperature dependant heat transfer   W/K/°C       */

#define NPARAMS     11                              /* longest parameter list */

/* defines for inputs              port   index             */
#define TS(n)    (*u0[n])       /*  0     0..nodes-1     temperatures of storage nodes   degree C */
#define T_IN     (*u1[0])       /*  1     0              inlet temperature               degree C */
#define MDOT     (*u1[1])       /*        1              massflow                        kg/s     */
#define PRESS    (*u1[2])       /*        2              pressure                        Pa       */
#define FLUID    (*u1[3])       /*        3              fluid ID (defined in CARNOT.h)           */
#define MIX      (*u1[4])       /*        4              fluid mix (defined in CARNOT.h)          */



#define DWORK_TS_OLD_NR             0 /* old storage node temperature */
#define DWORK_A_HX_NR               1 /* heat exchanger surface per node (only used for the theoretical models) */
#define TS_OLD(n)                   dwork_ts_old[n]
#define A_HX                        dwork_a_hx[0]


/* Calculate the power of the heat exchanger (logarithmic difference) */
real_T calculate_power_for_heatex(double mdot, double cphx, double *thx, 
        double t_store, double heatex)
{
    real_T logthx, qhx, thxn;
    
    /* following equation is derived from
     * mdot * cp * dThx = U * dA * (Tnode - Thx)
     * replace (Tnode-Thx) by teta, than dThx is -dteta
     * mdot * cp * dteta = - U * dA * teta
     * dteta / teta = - U * dA / (mdot * cp)
     * integrate from inlet position to outlet position
     * ln(teta(out)/teta(in)) = - U * A / (mdot * cp)
     * exponentiate and solve for teta(out)
     * teta(out) = teta(in) * exp(-U*A/(mdot*cp))
     * replace teta by (Tnode - Thx) and solve for
     * Thx(out), the outlet temperature of the
     * heat exchanger in one node
     * Thx(out) = Tnode(out) +
     * ((Thx(in) - Tnode(in)) * exp(-U*A/(mdot*cp))
     * Tnode(in) and Tnode(out) are the same since nodes
     * are fully mixed. Remember that in the following
     * equation Tnode must refer to one node upwars in
     * flowdirection.
     */

    if (mdot > NO_MASSFLOW)     /* avoid division by zero */
    {
        /* outlet temperature Thx(out) of the heat exchanger  node */
        thxn = t_store + (*thx-t_store)*exp(-heatex/(mdot*cphx));
    
        /* logaritmic temperature difference */
        if (fabs(thxn-t_store) > 1.0e-10      /* hx-temperature <> node temperature */
            && fabs(*thx-t_store) > 1.0e-10)  /* inlet temperature <> node temperature -> avoid 0/0 */
        {
            logthx = (*thx-t_store)/(thxn-t_store);
            logthx = (logthx < 0.0)? log(-logthx) : log(logthx);
            qhx = heatex*(*thx-thxn)/logthx; /* heat transfer in W */
            /* printf("T different: thxn %f  thx %f  t_store %f  qhx %f  mdot  %f\n", thxn,*thx,t_store,qhx,mdot); */
        } else { /* else temperatures are equal */
            qhx = 0.0;
            thxn = *thx;
            /* printf("T equal: thxn %f  thx %f  t_store %f  qhx %f  mdot  %f\n", thxn,*thx,t_store,qhx,mdot); */
        }
    } else /* no massflow */
    {
        qhx = 0.0;          /* power is zero */
        thxn = t_store;     /* outlet temperature is node temperature */
        /* printf("no mdot: thxn %f  thx %f  t_store %f  qhx %f  mdot  %f\n", thxn,*thx,t_store,qhx,mdot); */
    }
    *thx = thxn;            /* put value of thxn in thx as info of node temperature */
    return qhx;
} /* end calculate_power_for_heatex */
      
       

#define MDL_CHECK_PARAMETERS
#if defined(MDL_CHECK_PARAMETERS) && defined(MATLAB_MEX_FILE)
  /* Function: mdlCheckParameters =============================================
   * Abstract:
   *    Validate our parameters to verify they are okay.
   */
  static void mdlCheckParameters(SimStruct *S)
  {
      int_T port_id    = (int_T)PORT_ID;
      int_T start_node = (int_T)START_NODE;
      int_T end_node   = (int_T)END_NODE;
      
      
        /* check port ID */
        {
            if (port_id  != 201 && port_id  != 301 && port_id  != 202 && port_id  != 302 
                && port_id  != 203 && port_id  != 303 && port_id  != 204 && port_id  != 304) 
            {
                ssSetErrorStatus(S,"storage_heatexchanger: unknown port");
                return;
            }
        }
        /* */
        {
            if (start_node < 1) 
            {
                ssSetErrorStatus(S,"storage_heatexchanger: start node must be > 0");
                return;
            }
        }
        /* */
        {
            if (end_node < 1) 
            {
                ssSetErrorStatus(S,"storage_heatexchanger: end node must be > 0");
                return;
            }
        }
        
  }
#endif /* MDL_CHECK_PARAMETERS */

 

/* Function: mdlInitializeSizes ===============================================
 * Abstract:
 *   Setup sizes of the various vectors.
 */
static void mdlInitializeSizes(SimStruct *S)
{
    ssSetNumSFcnParams(S, NPARAMS);
#if defined(MATLAB_MEX_FILE)
    if (ssGetNumSFcnParams(S) == ssGetSFcnParamsCount(S))
    {
        mdlCheckParameters(S);
        if (ssGetErrorStatus(S) != NULL)
        {
            return;
        }
    } else
    {
        return; /* Parameter mismatch will be reported by Simulink */
    }
#endif
    
    ssSetNumContStates(S, 0);   /* number of continuous states */
    ssSetNumDiscStates(S, 0);   /* number of discrete states */

    if (!ssSetNumInputPorts(S, 2))
    {
        return;
    }
    ssSetInputPortWidth(S, 0, (int_T)NODES);
    ssSetInputPortDirectFeedThrough(S, 0, 1);
    ssSetInputPortWidth(S, 1, 5);
    ssSetInputPortDirectFeedThrough(S, 1, 1);

    if (!ssSetNumOutputPorts(S, 2))
    {
        return;
    }
    ssSetOutputPortWidth(S, 0, (int_T)NODES);
    ssSetOutputPortWidth(S, 1, (int_T)NODES);
    
    ssSetNumSampleTimes(S, 1);
    ssSetNumRWork(S, 0);
    ssSetNumIWork(S, 0);
    ssSetNumPWork(S, 0);
    
    ssSetNumDWork(S, 2);
    ssSetDWorkWidth(S, 0, (int)(NODES+0.5));
    ssSetDWorkDataType(S, 0, SS_DOUBLE);
    ssSetDWorkName(S, 0, "DWORK_TS_OLD");
    ssSetDWorkUsageType(S, 0, SS_DWORK_USED_AS_DSTATE);
    ssSetDWorkWidth(S, 1, 1);
    ssSetDWorkDataType(S, 1, SS_DOUBLE);
    ssSetDWorkName(S, 1, "DWORK_A_HX");
    ssSetDWorkUsageType(S, 1, SS_DWORK_USED_AS_DSTATE);
    
    
    ssSetNumModes(S, 0);
    ssSetNumNonsampledZCs(S, 0);
    
    ssSetSimStateCompliance(S, USE_DEFAULT_SIM_STATE);
    ssSetSimStateVisibility(S, 1);
    ssSupportsMultipleExecInstances(S, true);

    /* Take care when specifying exception free code - see sfuntmpl.doc */
#ifdef  EXCEPTION_FREE_CODE
    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE);
#endif
}


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
    real_T *dwork_ts_old     = (real_T *)ssGetDWork(S, DWORK_TS_OLD_NR);
    real_T *dwork_a_hx       = (real_T *)ssGetDWork(S, DWORK_A_HX_NR);
    int_T  port_id = (int_T)PORT_ID;        /* portID           */
    int_T  nodes  = (int_T)NODES;           /* number of nodes  */
    int_T  nstart = (int_T)START_NODE-1;    /* start node       */
    int_T  nend   = (int_T)END_NODE-1;      /* end node         */
    int_T  n;

    switch (port_id)
    { 
        default:            
            A_HX = 1.0;     /* default value for surface */
            break;

        case 201: case 301:
            /*  smooth tube heat exchanger (theoretical model) portID = 201, = 301 stratified charging */
        case 202: case 302:
            /*  finned tube heat exchanger (theoretical model) portID = 202, = 302 stratified charging */
            A_HX = PI*DIA_PIPE*LENGTH/((real_T)(abs(nstart-nend)+1));  /* surface = PI * D * L / number_of_nodes */
            break;
    }

    for (n = 0; n < nodes; n++)
        TS_OLD(n) = -10.0;
    
  } /* end mdl_start */
#endif /*  MDL_START */

#undef MDL_INITIALIZE_CONDITIONS   /* Change to #undef to remove function */
#if defined(MDL_INITIALIZE_CONDITIONS)
  /* Function: mdlInitializeConditions ========================================
   * Abstract:
   *    In this function, you should initialize the continuous and discrete
   *    states for your S-function block.  The initial states are placed
   *    in the state vector, ssGetContStates(S) or ssGetDiscStates(S).
   */
  static void mdlInitializeConditions(SimStruct *S)
  {
  }
#endif /* MDL_INITIALIZE_CONDITIONS */


#define MDL_UPDATE  /* Change to #undef to remove function */
#if defined(MDL_UPDATE)
  /* Function: mdlUpdate ======================================================
   * Abstract:
   *    This function is called once for every major integration time step.
   *    Discrete states are typically updated here, but this function is useful
   *    for performing any tasks that should only take place once per
   *    integration step.
   */
  static void mdlUpdate(SimStruct *S, int_T tid)
  {
    InputRealPtrsType u0 = ssGetInputPortRealSignalPtrs(S,0);
    real_T *dwork_ts_old     = (real_T *)ssGetDWork(S, DWORK_TS_OLD_NR);
    /*real_T *dwork_a_hx       = (real_T *)ssGetDWork(S, DWORK_A_HX_NR);*/
    int_T  nodes = (int_T)NODES;   /* number of nodes  */
    int_T  n;

    /* update node temperatures for stratified charging ports */
    for (n = 0; n < nodes; n++) /* loop over all storage nodes */
    {
        TS_OLD(n) = TS(n);      /* node temperature update */
    }
  }
#endif /* MDL_UPDATE */


/* Function: mdlOutputs =======================================================
 */
static void mdlOutputs(SimStruct *S, int_T tid)
{
    real_T              *qdot = ssGetOutputPortRealSignal(S,0);
    real_T              *thx  = ssGetOutputPortRealSignal(S,1);
    InputRealPtrsType    u0  = ssGetInputPortRealSignalPtrs(S,0);
    InputRealPtrsType    u1  = ssGetInputPortRealSignalPtrs(S,1);
    real_T *dwork_ts_old     = (real_T *)ssGetDWork(S, DWORK_TS_OLD_NR);
    real_T *dwork_a_hx       = (real_T *)ssGetDWork(S, DWORK_A_HX_NR);
    
    real_T dpipe, swall, lpipe, conwall, dfin, sfin, uac, uam, uat, re, pr;
    real_T xnfin, heatex, xnodes, tin, cp, nuss, m, v, nu_in, u_in, u_out;
    int_T  inc, n;

    int_T  port_id = (int_T)PORT_ID;        /* portID           */
    int_T  nodes   = (int_T)NODES;          /* number of nodes  */
    int_T  nstart  = (int_T)START_NODE-1;   /* start node       */
    int_T  nend    = (int_T)END_NODE-1;     /* end node         */


    /* start calculation */
    xnodes = (real_T)(abs(nstart-nend)+1);  /* number of nodes concerned by heat exchanger  */
    inc = (nend > nstart)? +1 : -1;         /* increment positive or negative */
    
    for (n = 0; n < nodes; n++)
    {
        thx[n] = 0.0;
        qdot[n] = 0.0;
    }
    tin = T_IN;                             /* heat exchanger temperature at inlet */
    
    for (n = nstart; n != nend+inc; n+=inc)
    {
        heatex = 0.0;
        
        if (port_id < 300                   	/* if not stratified charging */
            || ((tin > TS_OLD(n)) && inc < 0)   /* or inlet temperature above node temperature and statified charging */
            || ((tin < TS_OLD(n)) && inc > 0))  /* or inlet temperature below node temperature and statified discharging */
        {
            switch (port_id)
            { 
                case 201: case 301: case 202: case 302:
                    /*  smooth tube heat exchanger (theoretical model) portID = 201, = 301 stratified charging */
                    /*  finned tube heat exchanger (theoretical model) portID = 202, = 302 stratified charging */
                    dpipe   = DIA_PIPE;         /* outer diameter of heat exchanger pipe       m        */
                    swall   = S_WALL;           /* wall thickness                              m        */
                    lpipe   = LENGTH;           /* length of pipe                              m        */
                    conwall = COND_WALL;        /* conductivity  heat exch. material           W/(m²*K) */
                    dfin    = DIA_FIN;          /* total diameter of pipe with fins            m        */
                    sfin    = S_WALL_FIN;       /* wallthickness fin                           m        */
                    xnfin   = N_FIN;            /* number of fins per meter                    1/m      */

                    /* heat transfer calculation */
                    /* from Wagner: Waermeuebertragung, Vogel-Verlag, 1991 */
                    v = MDOT/density(1.0,0.0,tin,PRESS)*4.0/(PI*square(dpipe-2.0*swall));
                    re = reynolds(1.0,0.0,tin,PRESS,v,dpipe-2.0*swall);
                    pr = prandtl(1.0, 0.0, (tin+TS(n))*0.5, PRESS);
                    nu_in = 0.0235*(pow(re,0.8)-230)*pow(pr,0.48); /* equation from Wagner */
                    nuss = 0.5 * pow(grashof(1.0, 0.0, tin, TS(n), PRESS, dpipe*PI/2)*pr,0.25); /* nusselt for water */
                    u_out = (nuss*thermal_conductivity(1.0,0.0,TS(n),PRESS))
                        /(dpipe*PI/2);            /* outer heat transfer in W/(m^2*K) */
                    u_in = (nu_in*thermal_conductivity(1.0,0.0,tin,PRESS))/dpipe; /* inner heat transfer in W/(m^2*K) */

                    if (port_id == 202 || port_id == 302)       /* finned tube, see Wagner 1991: page 83 */
                    {
                        m = sqrt(2.0*u_out/(conwall*sfin));
                        u_out = u_out*(1.0 - sfin*xnfin)      /* heat transfer remaining from the pipe */
                            + sfin*xnfin * m * conwall          /* + heat transfer of the fin */
                            *tanh(m*0.5*(dfin-dpipe));
                    }
                    heatex = A_HX/(1/u_out + swall/conwall + 1/u_in);
                    break;

                case 203: case 303:     /* portID = 203, = 303 for stratified charging */
                    /* heat exchanger, heat transfer fitted to measurement: UA = uac+mdot*uam+(Thx-Tstore)*uat */
                    uac = UA_C;                 /* uac : constant heat transfer rate           W/K      */
                    uam = UA_M;                 /* uam : massflow dependant heat transfer      W*s/kg/K */
                    uat = UA_T;                 /* uat : temperature dependant heat transfer   W/K/°C   */
            
                    /* heat transfer calculation */
                    heatex = (uac+uam*MDOT+uat*(tin-TS(n)))/xnodes;
                    break;            


                case 204: case 304:     /* portID = 204, = 304 for stratified charging    */
                    /* EN 12977 heat exchanger, heat transfer fitted to measurement UA = uac * mdot^uam * t^uat */
                    uac = UA_C;                 /* uac : constant heat transfer rate           W/K      */
                    uam = UA_M;                 /* uam : massflow dependant heat transfer      W*s/kg/K */
                    uat = UA_T;                 /* uat : temperature dependant heat transfer   W/K/°C   */

                    /* heat transfer calculation */
                    heatex = (uac*pow(MDOT,uam)
                        *pow((TS(n)+tin)/2,uat))/xnodes;    /* mdot is in fact in kg/s */
                    break;            
                              
                default: 
                    heatex = 500.0/xnodes;                      /* heat transfer is 500 W/K */
                    break;
            } /* end switch */
        } /* end if */

        if (heatex > 0.0)
        {
            cp = heat_capacity(FLUID, MIX, tin, PRESS);         /* heat capacity of fluid in the heat exchanger */
            qdot[n] = calculate_power_for_heatex
                (MDOT, cp, &tin, TS(n), heatex);                /* inlet temperature is modified by function ! */
        }
        thx[n] = tin;                                           /* new inlet temperature is heat exchanger node temperature */
        /* printf("thx[%i]  %3.3f   TS[%i]  %3.3f   heatex %3.1f \n", n, thx[n], n, TS(n), heatex); */
    } /* end for n */

} /* end mdlOutputs */


#undef MDL_DERIVATIVES  /* Change to #undef to remove function */
#if defined(MDL_DERIVATIVES)
  /* Function: mdlDerivatives =================================================
   * Abstract:
   *    In this function, you compute the S-function block's derivatives.
   *    The derivatives are placed in the derivative vector, ssGetdX(S).
   */
  static void mdlDerivatives(SimStruct *S)
  {
  }
#endif /* MDL_DERIVATIVES */



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
