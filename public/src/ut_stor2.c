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
 * one loop pipe for heat exchange with earth
 *
 * Syntax  [sys, x0] = erdsonde(t,x,u,flag)
 *
 * Version  Author          Changes                                 Date
 * 0.1.0    Bernd Hafner    created                                 20mar98
 * 0.2.0    hf              reduced to two dimensions               05apr98
 * 0.4.0    hf              static pressure for flow-id > 10000     26apr98
 * 0.5.0    hf              toolbox name changed to CARNOT          30apr98
 * 0.5.1    hf              material properties from carlib         20mai98
 * 0.7.0    hf              switch pressure calculation             12jun98
 *                          ID <=10000 no pressure calculation
 *                          ID <=20000 only pressure drop
 *                          ID > 20000 pressure drop and static pressure
 * 0.7.1    hf              correct energy balance of heat          30jun98
 *                          exchanger before setting output vector
 * 0.8.0    hf              new pressure drop calculation           03jul98
 *                          dp = dp0 + dp1*mdot + dp2*mdot^2
 *                          function has new outputs dp0, dp1, dp2
 *
 *
 * Copyright (c) 1998 Solar-Institut Juelich, Germany
 *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *  D E S C R I P T I O N
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * modified from mex file for multi-input, multi-output state-space system.
 *         
 * The storage is devided into ZNODES nodes in z-direction and RNODES nodes
 * in radial direction. The energy-balance for every node is:
 *
 * rho*c*dT/dt =  cond/dz^2 *           (Tnode_up+Tnode_down - 2*Tnode)
 *              + cond*(r+dr/2)/(r*dr^2) * (Tnode_out        - Tnode)
 *              + cond*(r-dr/2)/(r*dr^2) * (Tnode_in         - Tnode)
 *
 *  symbol      used for                                        unit
 *	cond        effective heat conductivity                     W/(m*K)
 *  c           heat capacity                                   J/(kg*K)
 *  dr          radial between two nodes                        m
 *  dz          axial between two nodes                         m
 *  rho         density                                         kg/m^3
 *  T           temperature                                     K
 *  t           time                                            s
 *
 * Because we need to know the temperature at fixed places inside the
 * storage, a number of measurement points (M_PTS) is placed at
 * equidistant locations inside the storage, no matter how many nodes
 * are used for the calculation.
 *
 * The output vector y[] starts with the top-temperature (y[0]) and
 * ends with the bottom-temperature (y[M_PTS]).
 *
 *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * Definiton of inputs and outputs 
 *
 * structure of u (input vector)
 *  index       use                                     units
 *  0           ambient temperature                     degree centigrade
 *  1           heat transfer coefficient from ambient  W/(m^2*K)
 *  2           radiation on top surface                W/m^2
 *  3           inlet temperature heat exchanger        degree centigrade
 *  4           massflow in heat exchanger              kg/s
 *  5           pressure                                Pa
 *  6           fluid ID (defined in CARNOT.h)
 *  7           mixture  (defined in CARNOT.h)
 *  8           diameter at inlet                       m   
 *  9           T outside storage (top layer)           degree centigrade
 *  ...
 *  9+ZNODES-1 T outside storage (bottom layer )        degree centigrade
 *  9+ZNODES   T below storage                          degree centigrade
 *
 *
 * structure of y (output vector): all temperatures (T) in degree centigrade
 *  index       use                                         
 *  0           T 0.(top) measurement point, central column
 *  1           T 1. measurement point (MP), central column
 *  ...
 *  M_PTS-1     T M_PTS (lowest) MP, central column
 *
 *  M_PTS       T 0. MP, d_store/4 from center
 *  ...
 *  2*M_PTS-1   T M_PTS (lowest)MP, d_store/4 from center
 *
 *  2*M_PTS     T 0. MP, d_store/2 from center
 *  ...
 *  3*M_PTS-1   T M_PTS (lowest)MP, d_store/2 from center
 *
 *  3*M_PTS     outlet temperature of fluid
 *  3*M_PTS+1   pressure at outlet in Pascal
 *  3*M_PTS+2   constant pressure drop                      Pa
 *  3*M_PTS+3   linear pressure drop                        Pa/(kg/s)
 *  3*M_PTS+4   quadratic pressure drop                     Pa/(kg/s)^2
 *
 *
 * parameters
 *  index   use                                     units
 *  0       storage diameter                        m
 *  1       storage depth                           m
 *  2       heat capacity of earth                  J/(m^3*K)
 *  3       heat conductivity of earth              W/(m*K)
 *  4       diameter of pipe                        m
 *  5       diameter of hole                        m
 *  6       depth of hole                           m
 *  7       heat cap. hole filling                  J/(m^3*K) 
 *  8       heat cond. hole filling                 W/(m*K)
 *  9       heat cond. between pipes                W/(m*K)
 *  10      initial storage temperature             degree centigrade
 *  11      number of radial nodes 
 *  12      number of axial nodes 
 *  13      number of temperature measurement points
 *  
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * structure of the temperature-array (state-space vector x)
 * 0.slice            = top slice (row)
 * 0.radial_position  = inner column
 *  
 *  temperature(slice, radial_pos, angular_pos)
 *   = x(RNODES*slice + radial_pos)
 */


#define S_FUNCTION_NAME ut_stor2

#include "simstruc.h"
#include "tmwtypes.h"
#include "carlib.h"
#include <math.h>

#define PI       3.14159265358979
#define GRAV     9.81

#define D_STORE     *mxGetPr(ssGetArg(S,0))  /* storage diameter [m] */
#define H_STORE     *mxGetPr(ssGetArg(S,1))  /* storage depth    [m] */
#define CAP_EARTH   *mxGetPr(ssGetArg(S,2))  /* heat capacity of earth [J/(kg*K)] */
#define COND_EARTH  *mxGetPr(ssGetArg(S,3))  /* heat conductivity of earth [W/(m*K)] */
#define D_PIPE      *mxGetPr(ssGetArg(S,4))  /* diameter of pipe [m] */
#define D_HOLE      *mxGetPr(ssGetArg(S,5))  /* diameter of hole [m] */
#define H_HOLE      *mxGetPr(ssGetArg(S,6))  /* depth of hole    [m] */
#define CAP_HOLE    *mxGetPr(ssGetArg(S,7))  /* heat cap. hole filling [J/(kg*K)] */
#define COND_HOLE   *mxGetPr(ssGetArg(S,8))  /* heat cond. hole filling  [W/(m*K)] */
#define ROUGH       *mxGetPr(ssGetArg(S,9))  /* roughness of pipe in m */
#define T0          *mxGetPr(ssGetArg(S,10)) /* initial storage temperature in [°C]	*/
#define RNODES      *mxGetPr(ssGetArg(S,11)) /* number of radial nodes */
#define ZNODES      *mxGetPr(ssGetArg(S,12)) /* number of axial nodes */
#define M_PTS       *mxGetPr(ssGetArg(S,13)) /* number of temperature measurement points */
#define N_PARAMETER                     14   /* number of parameters */
 
#define T_TOP       u[0]       /* temperature above earth (ambient or building) */
#define U_TOP       u[1]       /* heat transfer coefficient from ambient */
#define I_TOP       u[2]       /* radiation on top surface (by sun) W/m^2 */
#define FLOW_ID     u[3]       /* inlet temperature heat exchanger */
#define TFLUIDIN    u[4]       /* inlet temperature heat exchanger */
#define MDOT        u[5]       /* massflow in heat exchanger */
#define PRESS       u[6]       /* pressure */
#define FLUID_ID    u[7]       /* fluid ID */
#define PERCENTAGE  u[8]       /* mixture */
#define D_INLET     u[9]       /* diameter at inlet */
#define DPCON       u[10]      /* constant term in pressure drop */
#define DPLIN       u[11]      /* linear term in pressure drop */
#define DPQUA       u[12]      /* quadratic term in pressure drop */
#define TBOUND      u[nz+13]   /* temperature at slice boundary */

#define TFLUID      RWork      /* fluid temperature in pipe is stored in RWork */
#define TCOND_H     RWork[2*znodes+1] /* temperature conductivity borehole */
#define TCOND_E     RWork[2*znodes+2] /* temperature conductivity earth */
#define OLDTIME     RWork[2*znodes+3]
#define OLDENERGY   RWork[2*znodes+4]

#define TIME        ssGetT(S)

#define TP          x[rnodes*nz+nr]     /* node temperature */
#define TEAST       x[rnodes*nz+nr]     /* T back in angular direction */
#define TWEST       x[rnodes*nz+nr]     /* T forwards in angular direction */
#define TUP         x[rnodes*(nz-1)+nr] /* T one slice up */
#define TDOWN       x[rnodes*(nz+1)+nr] /* T one slice down */
#define TIN         x[rnodes*nz+nr-1]   /* T one node inwards */
#define TOUT        x[rnodes*nz+nr+1]   /* T one node outwards */
#define DTDT        dx[rnodes*nz+nr]    /* dT/dt */

#define ENERGY      x[rnodes*znodes] /* energy input by heat exchanger */
#define DEDT        dx[rnodes*znodes]




double diameterchange(double dpipe, double dinlet)
/* pressure drop for diameter change at pipe inlet
 * dpipe is inner pipe diameter, dinlet diameter of last piece
 * from VDI Waermeatlas, 1988
 */
{   double k;
    if (dinlet-0.001 > dpipe)
	{
        k = 0.5;    /* entry from tank to pipe */
	}
    else if (dpipe > dinlet+0.001)
	{
        k = square(1.0-square(dpipe/MAX(dinlet, 0.001)));
	}
    else 
	{
        k = 0.0;
	}
    return k;
}



/*
 * mdlInitializeSizes - initialize the sizes array
 *
 * The sizes array is used by SIMULINK to determine the S-function block's
 * characteristics (number of inputs, outputs, states, etc.).
 */

static void mdlInitializeSizes(SimStruct *S)
{
    ssSetNumSFcnParams(S, N_PARAMETER);  /* Number of expected parameters */
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
        /* Return if number of expected != number of actual parameters */
        return;
    }
    ssSetNumContStates(S, (int_T)RNODES*(int_T)ZNODES+1); /* number of continuous states */
    ssSetNumDiscStates(S, 0);      /* number of discrete states */
    ssSetNumInputs(S, (int_T)ZNODES+14);  /* number of inputs */
    ssSetNumOutputs(S, 3*(int_T)M_PTS+5); /* number of outputs */
    ssSetDirectFeedThrough(S, 1);  /* direct feedthrough flag */
    ssSetNumSampleTimes(S, 1);     /* number of sample times */
    ssSetNumRWork(S, 2*(int_T)ZNODES+5);  /* number of real work vector elements */
    ssSetNumIWork(S, 0);        /* number of integer work vector elements */
    ssSetNumPWork(S, 0);        /* number of pointer work vector elements */
}


/*
 * mdlInitializeSampleTimes - initialize the sample times array
 *
 * This function is used to specify the sample time(s) for your S-function.
 * If your S-function is continuous, you must specify a sample time of 0.0.
 * Sample times must be registered in ascending order.
 */

static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTimeEvent(S, 0, 0.0);
    ssSetOffsetTimeEvent(S, 0, 0.0);
}


/*
 * mdlInitializeConditions - initialize the states
 *
 * In this function, you should initialize the continuous and discrete
 * states for your S-function block.  The initial states are placed
 * in the x0 variable.  You can also perIWork any other initialization
 * activities that your S-function may require.
 */

static void mdlInitializeConditions(real_T *x0, SimStruct *S)
{
    double t0 = T0;             /* initial temperature */
    double cap_e = CAP_EARTH;    /* heat capacity of earth [J/(kg*K)] */
    double cond_e = COND_EARTH;  /* heat conductivity of earth [W/(m*K)] */
    double cap_h = CAP_HOLE;     /* heat cap. hole filling [J/(kg*K)] */
    double cond_h = COND_HOLE;   /* heat cond. hole filling  [W/(m*K)] */
    int    rnodes = (int)RNODES;  /* numer of radial nodes */
    int    znodes = (int)ZNODES;  /* numer of axial nodes */

    double *RWork = ssGetRWork(S);  /* temperatures in heat exchanger */
    int    n;
    
    for (n = 0; n < rnodes*znodes; n++) 
        x0[n] = t0;     /* state-vector is initialized with T0 */

    for (n = 0; n <= 2*znodes; n++)
        TFLUID[n] = t0; /* Tfluid (RWork) is initialized with T0 */

    TCOND_H = cond_h/cap_h;
    TCOND_E = cond_e/cap_e;

    OLDTIME = TIME;
    OLDENERGY = 0.0;
}


/*
 * mdlOutputs - compute the outputs
 *
 * In this function, you compute the outputs of your S-function
 * block.  The outputs are placed in the y variable.
 */
static void mdlOutputs(real_T *y, const real_T *x, const real_T *u, 
                       SimStruct *S, int_T tid)
{
    double dpipe  = D_PIPE;       /* pipe diameter */
    double h_hole = H_HOLE;       /* depth of hole */
    double hstore = H_STORE;      /* depth of hole */
    double rough  = ROUGH;
    double time   = TIME;
    double dpcon = 0.0;
    double dplin = 0.0;
    double dpqua = 0.0;

    int    rnodes = (int)RNODES;  /* numer of radial nodes */
    int    znodes = (int)ZNODES;  /* numer of axial nodes */
    int    mpoints = (int)M_PTS;  /* numer of measurement points */

    double *RWork = ssGetRWork(S);  /* temperatures in heat exchanger */

    double p, interval_size, dz, rho, vis, v, re, fh, dirz, k, leq,
        tmean, flimit, hh;
    int    i, nz, nr, na, pipenodes;
    
    dz = hstore/(double)znodes;      /* height of one node */
    pipenodes = min(znodes, (int)(h_hole/dz+0.5)); /* nodes with pipe */
    flimit = 0.1*pow(rough/dpipe,0.22); /* lowest value of fh */

    /* average pipe temperature and static pressure */
    tmean = 0.0;
    dirz = dz * GRAV; /* positive for downwards flow */
    p = PRESS;
    for (nz = 0; nz < 2*pipenodes; nz++) {
        tmean += TFLUID[nz];
        if (FLOW_ID > 10000.0) {
            if (nz == pipenodes)
                dirz = - dirz; /* negative for upwards flow */
            hh = dirz * density(FLUID_ID, PERCENTAGE, TFLUID[nz], p);
            p += hh;
            dpcon -= hh;
        }
    }
    tmean = tmean/(double)znodes;

    /* pipe friction calculate only if there is massflow */
    if (MDOT > 0.0 && FLOW_ID > 10000.0)  {
        rho = density(FLUID_ID, PERCENTAGE, tmean, PRESS);
        vis = viscosity(FLUID_ID, PERCENTAGE, tmean, PRESS);
        v = 4.0*MDOT/(rho*PI*dpipe*dpipe);
        re = v*dpipe/vis;
        leq = 2.0*h_hole;

        /* friction from big diameter to pipe diameter */
        k = diameterchange(dpipe, D_INLET);

        /* developing flow correction */
        /* from Bohl: technische Stroemungslehre, Vogel Verlag */
        if (re < 2000.0) {
            fh = max(flimit, 64.0/re);
            k += 1.2;
            leq += 60.0*dpipe;  /* two bends in the pipe */
        } else if (re < 3000.0) {
            fh = max(flimit, 3.2e-2);
            k += 3.2 - 0.00114*(re-2000.0);
        } else {
            fh = max(flimit, (re <= 7000.0)? 3.2e-2 : 0.25*pow(re, -0.23));
            k += 2.06;
        }

        if (re < 100.0)  /* low reynolds number correction */
            k = 100.0*k/max(1.0,re);

        /* pressure drop */
        hh = rho*v*v*0.5;
        p -= (fh*leq/dpipe+k)*hh;
        if (re < 2000.0) {
            dplin = fh*leq/dpipe*hh/MDOT;
            dpqua = k*hh/(MDOT*MDOT);
        } else {
            dpqua = (fh*leq/dpipe+k)*hh/(MDOT*MDOT);
            dplin = 0.0;
        }
    } /* end if mdot */

    /* set temperature of every measurement-point from bottom (0) to top */
    interval_size = (double)znodes/(double)mpoints; /* nodes in measurement point */
    na = 0;
    for(i = 0; i < mpoints; i++) {
        nz = (int)((double)i*interval_size+0.5);
        nr = 0;
        y[i] = TP;
        nr = (int)(0.7071*rnodes);
        y[i+mpoints] = TP;
        nr = rnodes-1;
        y[i+2*mpoints] = TP;
    }

    /* temperatures and pressures */
    if (MDOT > 0.0 && time > OLDTIME){
        TFLUID[2*pipenodes-1] = TFLUIDIN-(ENERGY-OLDENERGY)/(time-OLDTIME);
        OLDENERGY = ENERGY;
    }
    y[3*mpoints]   = TFLUID[2*pipenodes-1];
    y[3*mpoints+1] = p;
    y[3*mpoints+2] = dpcon + DPCON;
    y[3*mpoints+3] = dplin + DPLIN;
    y[3*mpoints+4] = dpqua + DPQUA;

    OLDTIME = time;
} /* end mdlOutputs */


/*
 * mdlUpdate - perIWork action at major integration time step
 *
 * This function is called once for every major integration time step.
 * Discrete states are typically updated here, but this function is useful
 * for perIWorking any tasks that should only take place once per integration
 * step.
 */

static void mdlUpdate(real_T *x, const real_T *u, SimStruct *S, int_T tid)
{
}    /* nothing to do here */


/*
 * mdlDerivatives - compute the derivatives
 *
 * In this function, you compute the S-function block's derivatives.
 * The derivatives are placed in the dx variable.
 *
 */

static void mdlDerivatives(real_T *dx, const real_T *x, const real_T *u, 
                           SimStruct *S, int_T tid)
{
    /* get model parameters with ssGetParam(S), see define at top of file */
    double dstore = D_STORE;     /* storage diameter [m] */
    double hstore = H_STORE;     /* storage depth    [m] */
    double cap_e = CAP_EARTH;    /* heat capacity of earth [J/(kg*K)] */
    double cond_e = COND_EARTH;  /* heat conductivity of earth [W/(m*K)] */
    double cap_h = CAP_HOLE;     /* heat cap. hole filling [J/(kg*K)] */
    double cond_h = COND_HOLE;   /* heat cond. hole filling  [W/(m*K)] */
    double dpipe  = D_PIPE;      /* pipe diameter */
    double h_hole = H_HOLE;      /* depth of hole */
    double dhole = D_HOLE;       /* diameter of hole */
    int    rnodes = (int)RNODES; /* numer of radial nodes */
    int    znodes = (int)ZNODES; /* numer of axial nodes */

    double *RWork = ssGetRWork(S);  /* temperatures in heat exchanger */

    double lu, lo, li, dz, dr, rp, ro, ri, rh, cp, heatex;
    double drno, drni, roo, uhx, Apipe, dz2;
    int    i, nz, nr, na, pipenodes;

    na = 0;
    dz = hstore/(double)znodes;     /* height of one node */
    dz2 = dz*dz;
    rh = 0.5*dhole;                 /* radius of hole */
    pipenodes = min(znodes, (int)(h_hole/dz+0.5)); /* nodes with pipe */
    Apipe = dz*PI*dpipe; /* pipe surface for heat transfer */

    TFLUID[0] = TFLUIDIN;
    cp = heat_capacity (FLUID_ID, PERCENTAGE, TFLUIDIN, PRESS);

    /* START OF MAIN CALCULATION LOOP */

    /* inner column (borehole), boundary at borehole wall */
    /* radius of temperature point */
    rp = rh*0.5;
    /* radius of outer node boundary */
    ro = rh;
    /* radius of next outer node boundary */
    roo = rh + (0.5*dstore-rh)*square(1.0/(double)rnodes);
    /* radial distance between nodes (outwards) */
    drno = 0.5*(roo+ro) - rp;

    lu = TCOND_H/dz2;
    lo = 0.5*(cond_h+cond_e) / (rp*drno*cap_h); /* ro = dr */

    nr = 0; 
    for (nz = 0; nz < znodes; nz++) 
    {
        DTDT = lo*(TOUT-TP);

        if (nz > 0)
            DTDT += lu*(TUP-TP);
        else
            DTDT += ((U_TOP/dz+4.0*cond_h/dz2)*
                (T_TOP-TP)+I_TOP)/cap_h;

        if (nz < znodes-1)
            DTDT += lu*(TDOWN-TP);
        else
            DTDT += lu*(TBOUND-TP);
    } /* end for nr */

    /* outer columns */
    lu = TCOND_E/dz2;
    for (nr = 1; nr < rnodes; nr++) 
    {
        /* radial distance between nodes (inwards) = outwards from last step */
        drni = drno;
        /* radius of inner node boundary = outer from last step */
        ri = ro;
        /* radius of outer node boundary = next outer from last step */
        ro = roo;
        /* radius of next outer node boundary */
        roo = rh + (0.5*dstore-rh)*square((double)(nr+2)/(double)rnodes);
        /* radius of temperature point */
        rp = 0.5*(ri+ro);
        /* radial distance between boundaries */
        dr = ro - ri;
        /* radial distance between nodes (outwards) */
        drno = 0.5*(roo+ro) - rp;

        lo = TCOND_E*ro/(rp*drno*dr);
        li = TCOND_E*ri/(rp*drni*dr);

        for (nz = 0; nz < znodes; nz++) 
        {
            DTDT = li*(TIN-TP);
            if (nr < rnodes-1)
                DTDT += lo*(TOUT-TP);
            else
                DTDT += lo*(TBOUND-TP);

            if (nz > 0)
                DTDT += lu*(TUP-TP);
            else
                DTDT += ((U_TOP/dz+4.0*cond_e/dz2)*
                    (T_TOP-TP)+I_TOP)/cap_e;

            if (nz < znodes-1)
                DTDT += lu*(TDOWN-TP);
            else
                DTDT += lu*(TBOUND-TP);
        } /* end for nz */
    } /* end for nr */

    /* convective heat transfer */
    DEDT = 0.0; /* energy balance */
    nr = 0;
    if (MDOT == 0.0) {
        nz = 0;
        TFLUID[2*pipenodes-1] = TP;
    } else {
        for (i = 0; i <= 2*(pipenodes-1); i++) 
        {
            nz = (i >= pipenodes)? 2*pipenodes-i-1 : i;
        
            /* equations from: 
               Wagner: Waermeuebertragung, Vogel-Verlag, 1991 */
            /* nuss = 4 for laminar flow in pipes */
            /* heat transfer in W/(m^2*K) = (nuss*co)/dpipe; */
            uhx = 30; /* approximate value */
        
            /* following equation is derived from
                mdot * cp * dThx = U * dA * (Tnode - Thx)
               replace (Tnode-Thx) by teta, than dThx is -dteta
                mdot * cp * dteta = - U * dA * teta
                dteta / teta = - U * dA / (mdot * cp)
               integrate from inlet position to outlet position
                ln(teta(out)/teta(in)) = - U * A / (mdot * cp)
               exponentiate and solve for teta(out)
                 teta(out) = teta(in) * exp(-U*A/(mdot*cp))
               replace teta by (Tnode - Thx) and solve for 
               Thx(out), the outlet temperature of the 
               heat exchanger in one node
                 Thx(out) = Tnode(out) +
                    ((Thx(in) - Tnode(in)) * exp(-U*A/(mdot*cp))
               Tnode(in) and Tnode(out) are the same since nodes
               are fully mixed. Remember that in the following
               equation Tnode must refer to one node upwars in
               flowdirection.
            */
        
            /* distance from pipe to temperature node is (2*(rh/2)^2)^0.5 */
            heatex = 1.0/(1.0/(uhx*Apipe) + (rh*rh)/(2.0*cond_h));
            DTDT += heatex*(TFLUID[i]-TP)/(PI*rh*rh*dz*cap_h);
            DEDT += heatex*(TFLUID[i]-TP)/(MDOT*cp);
        
            /* new heat exchanger temperature for next node */
            TFLUID[i+1] = TP + (TFLUID[i]-TP)*exp(-heatex/(MDOT*cp));
        
        } /* for i */
    } /* end if mdot */
} /* mdlDerivatives()... */



/*
 * mdlTerminate - called when the simulation is terminated.
 *
 * In this function, you should perIWork any actions that are necessary
 * at the termination of a simulation.  For example, if memory was allocated
 * in mdlInitializeConditions, this is the place to free it.
 */

static void mdlTerminate(SimStruct *S)
{}       /* NOP */

#ifdef	MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif
