/***********************************************************************
 *  M O D E L    O R    F U N C T I O N
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * multinode termal wall model according to the Beuken Modell
 *
 * Author list
 *  Thomas Wenzel -> tw
 *  Bernd Hafner -> hf
 *  Christian Winteler -> wic
 *  Arnold Wohlfeil -> aw
 *
 * Version  Author  Changes                                     Date
 * 0.9.0    hf      created                                     19jul1998
 *          tw      changed to level 2 s-function               11jun1999 
 *                  dyn. sized vector: power per node
 *                  conductivity + capacity in RWORK   
 * 1.0.0    tw      created new, following matwall.m            06jul1999
 * 1.0.1    hf      corrected power in active layers            16jul99
 * 6.1.0    hf      Power to active layer distributed between   03apr2014
 *                  nodes if active node is not exactly on a node.
 *                  Added define for iwork.
 * 6.1.1    wic     If active node is not exactly on a existing 07apr14
 *                  node, an additional node is created.
 *                  corrected if-clause in derivatives to 
 *                  prevent strange behaviour if active layer
 *                  is in first or last layer.
 * 6.1.2    hf      Corrected parameter check, layerwall can    11apr2014
 *                  also be used for walls, not only for floors
 *                  so active layers must be arranged in in-
 *                  creasing depth (not from top to bottom)
 * 6.1.3    aw      line 355, NUMACTIVE changed to numactive    11nov2014
 * 6.2.0    aw      restructured and changed to DWork           24jun2016
 * 6.2.1    hf      comments revised                            29jun2016
 *                  unnecessary lines eleminated
 * 6.2.2	aw		unused parameter deleted					01jul2016
 *					SPLint warnings checked
 * 6.2.3    hf      NODES replaced by NDNODE                    02jul2016
 *
 ***********************************************************************
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
 
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *  D E S C R I P T I O N
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * The wall is devided into "NODES" nodes according to the Beuken-Model
 * Each layer of the wall is connected to one node on each side. So there
 * are one more nodes than layers.
 * Furthermore, each layer is devided into sublayers, depending on the
 * expected time constant.
 *
 *        ------------ W A L L -----------
 *        |    Layer 1    |   Layer 2    | 
 *        |               |              | 
 *        |   --------    |   --------   |
 *  Q1 -> T1 -|  R1  |-   T2 -|  R2  |-  T3  <- Q3
 *        |   --------    |   --------   |
 *        |               |              | 
 *      ______         ______          ______
 *      __C1__         __C2__          __C3__
 *        |               |              | 
 *        |               |              | 
 *
 * Energy-balance for every node with the differential equation:
 *
 * rho*cp*d_node * dT/dt =
 *        q_outside                               % only first node
 *      + q_inside                                % only last node
 *      + cond/d_node * (Tnextnode - Tnode)       % not last node
 *      + cond/d_node * (Tpreviousnode - Tnode)   % not first node
 *      + qdot_heating
 *
 *  symbol      used for                                        unit
 *	cond        effective axial heat conduction                 W/(m*K)
 *  cp          heat capacity of layer material                 J/(kg*K)
 *  d_node      distance between two layer nodes                m
 *  rho         density of layer material                       kg/m³
 *  T           temperature                                     K
 *  t           time                                            s
 *  q_          power per surface (positive for energy gain)    W/(m^2)
 *
 * structure of u (input vector): see defines below
 *
 * Literature: 
 * Feist, W.: Thermische Gebaeudesimulation, Dissertation Uni Kassel, 
 *              Müller 2004
 * Wimmer, A.: Thermoaktive Bauteilsysteme, ein neuer simulationstechnischer
 *              Berechnungsansatz, Dissertation Uni Kassel, 2004
 */

#define S_FUNCTION_NAME     layerwall
#define S_FUNCTION_LEVEL    2

#include <stdio.h>
#include <math.h>
#include <float.h>
#include "simstruc.h"

/*
 *   Defines for easy access to the parameters
 */

// #define NODES       (uint16_T)(*mxGetPr(ssGetSFcnParam(S,0)))   /* number of nodes */
#define TAU         *mxGetPr(ssGetSFcnParam(S,0)) 				/* time-constant */
#define TINI        *mxGetPr(ssGetSFcnParam(S,1)) 				/* initial temperature [°C]  */
#define S_DNODE              ssGetSFcnParam(S,2)  				/* thickness of node in m */
#define S_COND               ssGetSFcnParam(S,3)  				/* conductivity [W/(m*K)] */
#define S_CWALL              ssGetSFcnParam(S,4)  				/* capacity [J/(kg*K)] */
#define S_RHO                ssGetSFcnParam(S,5)  				/* density [kg/m^3] */
#define S_DEPTH              ssGetSFcnParam(S,6)  				/* depth of active layers [m] */
#define NPARAMS                               7

#define NDNODE              mxGetN(S_DNODE)      
#define NCOND               mxGetN(S_COND)
#define NCWALL              mxGetN(S_CWALL)
#define NRHO                mxGetN(S_RHO)
#define NDEPTH              mxGetN(S_DEPTH)

#define Q_OUTSIDE           (*u0[0])    /* power per surface outside node */
#define POWER_PER_NODE(n)   (*u1[n])    /* power per node */
#define Q_INSIDE            (*u2[0])    /* power per surface inside node */

#define DWORK_NONODES_NO            0     			  /* number of overall cells */
#define DWORK_ACTIVE_NO             1     			  /* number of active layers */
#define DWORK_CAP_NO                2     			  /* thermal capacity of layers */
#define DWORK_COND_NO               3     			  /* thermal conductivity of layers */
#define DWORK_NUMACTIVE_NO          4     			  /* number of active layers */

#define NONODES               dwork_nocells[0]        /* number of overall cells */
#define ACTIVE(n)             dwork_active[n]         /* number of active layers */
#define CAP(n)                dwork_cap[n]            /* thermal capacity of layers */
#define COND(n)           	  dwork_cond[n]       	  /* thermal conductivity of layers */
#define CONDLEFT(n)       	  dwork_cond[n]       	  /* thermal conductivity of layers to the left*/
#define CONDRIGHT(n)          dwork_cond[(n+1)]    	  /* thermal conductivity of layers to the right */
#define NUMACTIVE             dwork_numactive[0]      /* number of active layers */

#define MAXNODES                    ((uint16_T)20)            /* maximum number of layers */
#define MAX_LAYERS                  ((uint16_T)10)            /* Layers per Layer */
#define MAX_L                       ((uint16_T)(MAXNODES*MAX_LAYERS+2)) /* has to be at least MAXNODES * MAX_LAYERS !!! */
#define DMAX_ACTIVE_LAYER_TO_NODE   0.00999 			      /* maximum distance from active layer to node in m *
														       * if bigger, an additional node is added          */

#define MDL_CHECK_PARAMETERS
#if defined(MDL_CHECK_PARAMETERS) && defined(MATLAB_MEX_FILE)
  /* Function: mdlCheckParameters =============================================
   * Abstract:
   *    Validate our parameters to verify they are okay.
   */
static void mdlCheckParameters(SimStruct *S)
{
	uint16_T i;
	double sum = 0.0;
	
	/* check sizes of vectos */
	if ( (NDNODE!=NCOND) || (NDNODE!=NCWALL) || (NDNODE!=NRHO) )
	{
		ssSetErrorStatus(S, "Error in wall: number of elements for thickness of nodes, heat capacity of nofes, conductivity of nodes and density of nodes must be identical to the number of nodes!");
        return;
    }
	/* Check 1st parameter: number of layers */
    if (NDNODE <= 0)
	{
        ssSetErrorStatus(S,"Error in wall: number of layers must be > 0");
        return;
    }
    if (NDNODE > MAXNODES)
	{
        printf("WARNING: Wall cannot have more than %u nodes. \n", MAXNODES);
        ssSetErrorStatus(S,"Error in wall: number of layers too high");
        return;
    }
    /* Check 2nd parameter: time-constant */
    if (TAU <= 0.0)
	{
        ssSetErrorStatus(S,"Error in wall: time-constant must be > 0 s");
        return;
    }
    /* Check parameters per layer */ 
	for (i = 0; i < NDNODE; i++)
	{   /*Check 4th parameter: thickness of layers in m */
        if (mxGetPr(S_DNODE)[i] <= 0.0)	
        {
            ssSetErrorStatus(S,"Error in wall: thickness of layers must be > 0");
            return;
        }
        /* Check 5th parameter: conductivity [W/(m*K)] */
		if (mxGetPr(S_COND)[i] < 0.0)
        {
			ssSetErrorStatus(S,"Error in wall: heat conductivity must be >= 0");
            return;
        }
        /* Check 6th parameter: capacity [J/(kg*K)] */
        if (mxGetPr(S_CWALL)[i] <= 0.0)
		{
            ssSetErrorStatus(S,"Error in wall: heat capacity must be > 0");
            return;
        }
        /* Check 7th parameter: density [kg/m^3] */
        if (mxGetPr(S_RHO)[i] <= 0.0)
		{
            ssSetErrorStatus(S,"Error in wall: density must be > 0");
            return;
        }
    } /* end for */
    
	
	/* Check 8th parameter: depth of active layers [m] */
    if (NDEPTH > (size_t)MAXNODES)
	{
        ssSetErrorStatus(S,"Error in wall: number of acitve nodes exceeds maximum number of nodes."
            " Recompile layerwall.c with higher number for MAXNODES.");
        return;
    }
	
	sum = 0.0;
	for (i = 0; i < NDNODE; i++)
	{
		sum += mxGetPr(S_DNODE)[i];
	}
	
    if (sum < mxGetPr(S_DEPTH)[NDEPTH-1])
	{
        ssSetErrorStatus(S,"Error in wall: position of last active layer is outside of wall. "
            "Reduce depth of active layer or increase dimension of layers.");
        return;
    }
	
	if (NDEPTH>1) /* if there is only one defined layer with a negative value, no active layer is defined; otherwise the values must be positive */
	{
		for(i=0;i<NDEPTH;i++)
		{
			if (mxGetPr(S_DEPTH)[i] < 0.0)
			{
				ssSetErrorStatus(S,"Error in wall: depth of active layers must be positive.");
				return;
			}
		}
	}
	
    for (i=1;i<NDEPTH;i++)
	{
        if (mxGetPr(S_DEPTH)[i] < mxGetPr(S_DEPTH)[i-1])
		{
            ssSetErrorStatus(S,"Error in wall: depth of active layers must be monotonicaly increasing.");
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
    }
	else
	{
        return; /* Parameter mismatch will be reported by Simulink */
    }
#endif

    ssSetNumContStates(S, MAX_L);  /* number of continuous states */
    ssSetNumDiscStates(S, 0);      /* number of discrete states */

    if (!ssSetNumInputPorts(S, 3))
	{
		return;
	}
    ssSetInputPortWidth(S, 0, 1);
    ssSetInputPortDirectFeedThrough(S, 0, 0);
    ssSetInputPortWidth(S, 1, (int_T)NDEPTH);
    ssSetInputPortDirectFeedThrough(S, 1, 0);
    ssSetInputPortWidth(S, 2, 1);
    ssSetInputPortDirectFeedThrough(S, 2, 0);

    if (!ssSetNumOutputPorts(S,3))
	{
		return;
	}
    ssSetOutputPortWidth(S, 0, 1);
    ssSetOutputPortWidth(S, 1, (int_T)NDEPTH);
    ssSetOutputPortWidth(S, 2, 1);

    ssSetNumSampleTimes(S, 1);

    ssSetNumIWork(S, 0);
	ssSetNumRWork(S, 0);
    ssSetNumPWork(S, 0);
    ssSetNumModes(S, 0);
    ssSetNumNonsampledZCs(S, 0);
	
	
	ssSetNumDWork(S, 5);
    ssSetDWorkWidth(S, DWORK_NONODES_NO, 1);
    ssSetDWorkDataType(S, DWORK_NONODES_NO, SS_UINT16);
    ssSetDWorkName(S, DWORK_NONODES_NO, "DWORK_NONODES");
    ssSetDWorkUsageType(S, DWORK_NONODES_NO, SS_DWORK_USED_AS_DSTATE);
    ssSetDWorkWidth(S, DWORK_ACTIVE_NO, (int_T)NDEPTH);
    ssSetDWorkName(S, DWORK_ACTIVE_NO, "DWORK_ACTIVE");
    ssSetDWorkUsageType(S, DWORK_ACTIVE_NO, SS_DWORK_USED_AS_DSTATE);
    ssSetDWorkDataType(S, DWORK_ACTIVE_NO, SS_UINT16);
    ssSetDWorkWidth(S, DWORK_CAP_NO, MAX_L);
    ssSetDWorkName(S, DWORK_CAP_NO, "DWORK_CAP");
    ssSetDWorkUsageType(S, DWORK_CAP_NO, SS_DWORK_USED_AS_DSTATE);
    ssSetDWorkDataType(S, DWORK_CAP_NO, SS_DOUBLE);
    ssSetDWorkWidth(S, DWORK_COND_NO, MAX_L);
    ssSetDWorkDataType(S, DWORK_COND_NO, SS_DOUBLE);
    ssSetDWorkName(S, DWORK_COND_NO, "DWORK_COND");
    ssSetDWorkUsageType(S, DWORK_COND_NO, SS_DWORK_USED_AS_DSTATE);
	ssSetDWorkWidth(S, DWORK_NUMACTIVE_NO, 1);
    ssSetDWorkDataType(S, DWORK_NUMACTIVE_NO, SS_UINT16);
    ssSetDWorkName(S, DWORK_NUMACTIVE_NO, "DWORK_NUMACTIVE");
    ssSetDWorkUsageType(S, DWORK_NUMACTIVE_NO, SS_DWORK_USED_AS_DSTATE);

    /* Take care when specifying exception free code - see sfuntmpl.doc */
    /* ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE); */
	
	ssSetSimStateCompliance(S, USE_DEFAULT_SIM_STATE);
    ssSetSimStateVisibility(S, 1);
    ssSupportsMultipleExecInstances(S, true);
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


#define MDL_INITIALIZE_CONDITIONS
/* Function: mdlInitializeConditions ========================================
 * Abstract:
 *    Initialize both states to one
 */
static void mdlInitializeConditions(SimStruct *S)
{
    real_T *x0   = ssGetContStates(S);
    real_T t0    = TINI;
	
	uint16_T *dwork_nocells    = (uint16_T *)ssGetDWork(S, DWORK_NONODES_NO);
	uint16_T *dwork_active     = (uint16_T *)ssGetDWork(S, DWORK_ACTIVE_NO);
	real_T   *dwork_cap        = (real_T   *)ssGetDWork(S, DWORK_CAP_NO);
	real_T   *dwork_cond       = (real_T   *)ssGetDWork(S, DWORK_COND_NO);
	uint16_T *dwork_numactive  = (uint16_T *)ssGetDWork(S, DWORK_NUMACTIVE_NO);

    real_T   *dnode    = mxGetPr(S_DNODE);
    real_T   *cond     = mxGetPr(S_COND);
    real_T   *cwall    = mxGetPr(S_CWALL);
    real_T   *rho      = mxGetPr(S_RHO);
    real_T   *depth    = mxGetPr(S_DEPTH);

    uint16_T numlayer,
		     StartCell,
			 EndCell,
			 j, i, n;
          
    real_T delx,				/* distance between two nodes */
           celldepth[MAXNODES], /* position of the cell */
           k[MAX_L],			/* heat transfer by conduction in W/m²/K */
           c[MAX_L],			/* heat capacity of a layer per surface in J/m²*/
           MatLambda1[MAX_L],	/* thermal conductivity of each node; beginning and ending with 0.0 for the boundary */
           MatCap1[MAX_L],		/* heat capacity of each sublayer */
           MatCap[MAX_L];		/* heat capacity for each node */
		   
	uint16_T m[MAX_L]; 			/* number of sub layers per layer */

    numlayer = (uint16_T)NDNODE; /* number of major layers */
	
	/* no active layer if depth of active layer < 0*/
    if (depth[0] < 0.0)
	{
        NUMACTIVE=0;
	}
	else
	{
		NUMACTIVE = (uint16_T)NDEPTH;
	}
	
    /* layer capacities, layer resistances und layer conductivities:*/
	NONODES = 0;
    for (j = 0;j<numlayer;j++)
    {
        /* m is the number of nodes per layer, equation from Feist */
        m[j] = (uint16_T)(ceil(sqrt(rho[j]*cwall[j] / (2.0*cond[j]*TAU)) * dnode[j]) + 0.1);
        if (m[j] < 1)
		{
           m[j] = 1;
		}
        else if (m[j] > MAX_LAYERS)
		{
           m[j] = MAX_LAYERS;
		}
        
        c[j] = rho[j]*cwall[j]*dnode[j]/(2.0*(double)m[j]); /* thermal capacity of node (half at each surface node) C = d*rho*cp */
        k[j] = cond[j]*(double)m[j]/dnode[j];               /* heat transfer by conduction */
		NONODES = NONODES + m[j];							/* number of nodes increase by number of sublayers per layer */
    }
	NONODES = NONODES + 1; /* we have one node more than layers */
     
    /* depth of cells from upper surface*/
    celldepth[0] = 0.0;
    n = 1;
    for (i=0; i<numlayer; i++)
    {
		for (j=1; j<=m[i]; j++)
		{
			celldepth[n] = celldepth[n-1]+dnode[i]/(double)m[i];
            n++;
        }
    }
     

    /* occupy elements of "MatCap" */
	for(j=0; j<NONODES; j++)
    {
        MatCap1[j] = 0.0;
        MatCap[j] = 0.0;
        MatLambda1[j] = 0.0;
    }
	MatLambda1[NONODES] = 0.0;
 
    /* set initial MatCap for all (SUB-)LAYERS (i.e. NONODES-1)
	 * j is the number of the main layer, whereas i is the number of the sublayers.
	 * Afterwards, only the sublayers will be processed.
	 */
    StartCell = 0;
    for (j=0; j<numlayer; j++)
    {
        EndCell = StartCell + m[j]-1; /* -1: The layer starts with the current element */
     
        for (i = StartCell; i<=EndCell; i++)
        {
            MatCap1[i] = c[j];
        }

        StartCell = EndCell + 1;
    }
	

    /* occupy elements of "MatLambda" for each LAYER plus the boundary:
	 * MatLambda1 has two elements more than MatCap1:
	 * Additional to each layer one element on the right and one on the left side (0.0)
	 * will be added. This is the thermal conductivity from left and from right.
	 */
     StartCell = 1;
     for (j=0; j<numlayer; j++) 
     {
        EndCell = StartCell + (int_T)m[j];
        for (i = StartCell; i<EndCell; i++)
		{
			MatLambda1[i] = k[j];
		}

        StartCell = i;
     }
     MatLambda1[StartCell] = 0.0;

     /*which of the layers are active layers? store in ACTIVE(...)
			 insert new nodes if necessary */
    j = 0;
    for (i=0; i<NUMACTIVE; i++)
    {
        /* find the cell, where to place the active layer */
		while (depth[i] > celldepth[j])
		{
			j++;
		}		
		ACTIVE(i) = j;
        
        /* if we have an active layer, we have to decide if the active layer become layer j, layer j-1 or if we have to add one layer */
		if (fabs(depth[i] - celldepth[j])<DBL_EPSILON)
		{ /* nothing else to do, we are exactly at the right position */
			continue;
		}
        else if (depth[i]-celldepth[j-1] > DMAX_ACTIVE_LAYER_TO_NODE)
        {
            if (celldepth[j]-depth[i] > DMAX_ACTIVE_LAYER_TO_NODE)
            {
                /* Insert a new node for the active layer at curent position */
                
                /* shift elements after current position to the right */
				for (n=NONODES+1;n>=j;n--)
                {
                    celldepth[n+1] = celldepth[n];
                    MatCap1[n+1] = MatCap1[n];
                    MatLambda1[n+1] = MatLambda1[n];
                }
				NONODES++;
				if (NONODES > MAX_L-2)
				{
					ssSetErrorStatus(S, "Error in wall: number of layers exeeded due to active layers!");
					return;
				}
                
                celldepth[j] = depth[i]; /* insert element at current position*/
                delx = (depth[i]-celldepth[j-1])/(celldepth[j+1]-celldepth[j-1]);
                MatCap1[j] = MatCap1[j-1]*(1.0-delx); /*distribute capacity on two nodes*/
                MatCap1[j-1] = MatCap1[j-1]-MatCap1[j];
                MatLambda1[j] = 1.0/(delx/MatLambda1[j+1]); /* distribute lambda on two nodes */
                MatLambda1[j+1] = 1.0/(1.0/MatLambda1[j+1] - 1.0/MatLambda1[j]);
            }
        }
        else
		{
			ACTIVE(i)=j-1;
		}
    }

    /* create final MatCap by summing up capacities of inner nodes */
    /* i.e. except first and last element*/
    MatCap[0] = MatCap1[0];
    for (j=1;j<NONODES-1;j++)
	{
        MatCap[j] = MatCap1[j-1]+MatCap1[j];
	}
	MatCap[NONODES-1] = MatCap1[NONODES-2];
	
	for(j=0; j<NONODES; j++)
	{
		CAP(j) = MatCap[j];
		COND(j) = MatLambda1[j];
	}
	COND(NONODES) = MatLambda1[NONODES];

    for (n = 0; n <NDNODE*MAX_LAYERS; n++)
	{
        x0[n] = t0;             /* state-vector is initialized with TINI */ 
	}		
}



/* Function: mdlOutputs =======================================================
 */
static void mdlOutputs(SimStruct *S, int_T tid)
{
    real_T   *y0   = ssGetOutputPortRealSignal(S, 0);
    real_T   *y1   = ssGetOutputPortRealSignal(S, 1);
    real_T   *y2   = ssGetOutputPortRealSignal(S, 2);
    real_T   *Tn   = ssGetContStates(S);

	uint16_T *dwork_nocells    = (uint16_T *)ssGetDWork(S, DWORK_NONODES_NO);
	uint16_T *dwork_active     = (uint16_T *)ssGetDWork(S, DWORK_ACTIVE_NO);
	uint16_T *dwork_numactive  = (uint16_T *)ssGetDWork(S, DWORK_NUMACTIVE_NO);
   
    uint16_T n;

    y0[0] = Tn[0];                   	/* temperature first node */
    for (n = 0; n < NUMACTIVE; n++) 	/* all node temperatures for active layers */
	{
        y1[n] = Tn[ACTIVE(n)];  		/* = x[ pos[n] ];   */
	}
	y2[0] = Tn[NONODES-1];            	/* temperature last node */
   
}



#define MDL_DERIVATIVES 
/* Function: mdlDerivatives =================================================
 * Abstract:
 *      xdot = Ax + Bu
 */
static void mdlDerivatives(SimStruct *S)
{
    real_T            *dTdt = ssGetdX(S);
    real_T            *Tn   = ssGetContStates(S);
    InputRealPtrsType u0    = ssGetInputPortRealSignalPtrs(S, 0);
    InputRealPtrsType u1    = ssGetInputPortRealSignalPtrs(S, 1);
    InputRealPtrsType u2    = ssGetInputPortRealSignalPtrs(S, 2);
	
	uint16_T *dwork_nocells    = (uint16_T *)ssGetDWork(S, DWORK_NONODES_NO);
	uint16_T *dwork_active     = (uint16_T *)ssGetDWork(S, DWORK_ACTIVE_NO);
	uint16_T *dwork_numactive  = (uint16_T *)ssGetDWork(S, DWORK_NUMACTIVE_NO);
	real_T   *dwork_cap        = (real_T   *)ssGetDWork(S, DWORK_CAP_NO);
	real_T   *dwork_cond       = (real_T   *)ssGetDWork(S, DWORK_COND_NO);
    
    real_T qinside   = Q_INSIDE;
    real_T qoutside  = Q_OUTSIDE;
    uint16_T  n;

    /* loop over all nodes */
    for (n=0; n<NONODES; n++)   
    { /* conduction and boundary */
        dTdt[n] = 0.0;
       
        if (n>0)
		{ /* conduction to the left */
			dTdt[n] = dTdt[n] + CONDLEFT(n)*(Tn[n-1]-Tn[n])/CAP(n);
		}
		
        if (n < NONODES-1)
		{ /* conduction to the right */
            dTdt[n] = dTdt[n] + CONDRIGHT(n)*(Tn[n+1]-Tn[n])/CAP(n);
		}

        if (n == 0)
		{ /* left side boundary */
            dTdt[n] = dTdt[n] + qoutside/CAP(n);
		}			
        
		if (n == NONODES-1)
		{ /* right side boundary */
            dTdt[n] = dTdt[n] + qinside/CAP(n);
		}
    } /* end for n */

	
	/* active layers */
	for(n=0; n<NUMACTIVE; n++)
	{
		dTdt[ACTIVE(n)] = dTdt[ACTIVE(n)] + POWER_PER_NODE(n)/CAP(ACTIVE(n));
	}
	
	
	/* set the other derivatives to zero */
    for (n=NONODES; n<MAX_L; n++)
	{
        dTdt[n] = 0.0;
	}
}




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
