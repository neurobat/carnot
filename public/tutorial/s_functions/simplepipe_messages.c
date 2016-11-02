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
 * H I S T O R Y
 * Version  Author  Changes                                     Date
 * 0.1.0    aw      created                                     08jan2015
 *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *  D E S C R I P T I O N
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *
 * This is a simple model of a pipe.
 * A liquid is flowing through the pipe, which exchanges heat with the
 * environment.
 * For simplicity, the UA value is given as a parameter and the thermal
 * mass of the pipe wall is neglected. Also, the heat conduction within
 * the fluid is not considered.
 *
 * V_node*rho*cp*dT/dt = UA * (Tamb - Tnode)
 *                     + mdot*cp*(Tlastnode - Tnode)
 *
 * symbol  used for                                        unit
 * cp      heat capacity of fluid                          J/(kg*K)
 * mdot    mass flow rate                                  kg/s
 * T       temperature                                     K
 * t       time                                            s
 * UA      heat loss coefficient                           W/K
 * 
 *         
 * structure of input vectors
 * port    use                                             unit
 * 0       ambient temperature                             degree Celsius
 * 1       temperature at inlet                            degree Celsius
 * 2       mass flow                                       kg/s
 * 3       pressure                                        Pa  
 * 4       fluid ID (defined in carlib.h)                 
 * 5       mixture  (defined in carlib.h)                 
 *
 *
 * structure output vectors
 * port    use                                             unit
 * 0       outlet temperature                              degree Celsius
 * 1       node temperatures                               degree Celsius
 * 2       power to the environment per node               W
 *
 *
 * parameters
 * port    use                                             unit
 * 0       heat transfer coefficient                       W/K
 * 1       volume of the fluid in the pipe                 m^3
 * 2       number of nodes                                 1
 * 3       initial temperatures of the nodes               degree C
 * The initial temperature is a vector. The size of the vector
 * must be the same as the number of nodes. 
 * 
 */
 
/*
 * The following #define is used to specify the name of this S-Function.
 */

#define S_FUNCTION_NAME     simplepipe_messages
#define S_FUNCTION_LEVEL    2

#include "simstruc.h"
/* the C library is the carlib.c . Include carlib.h as header file. */
#include "carlib.h"

/*
 *   Defines for easy access to the parameters
 */

/* The function mxGetPr returns a pointer to the parameter. In order to
 * access a parameter's value, use *mxGetPr. */
#define UA      (*mxGetPr(ssGetSFcnParam(S, 0)))        /* heat transfer coefficient */
#define VOLUME  (*mxGetPr(ssGetSFcnParam(S, 1)))       /* volume of the pipe */
/* The number of nodes is an integer value. The Simulink interface function
 * mxGetPr returns a pointer to a double. So we cast the value of the parameter
 * directly to int. */
#define NODES   ((int)(*mxGetPr(ssGetSFcnParam(S, 2)))) /* number of nodes */
/* The initial temperature can be set for each node individual. Consequently, we have
 * to use the parameter as an array. We can access the first node's initial temperature
 * by TINIT[0]. */
#define TINIT   (mxGetPr(ssGetSFcnParam(S, 3)))         /* initial temperatures of the nodes */

/* parameters for the messages */
#define MESSAGELEVELBLOCK		(int)(*mxGetPr(ssGetSFcnParam(S, 4)))	/* message level of the current block */
#define MAXTOTALMESSAGES		(*mxGetPr(ssGetSFcnParam(S, 5)))		/* maximum number of warnings */
#define MAXCONSECUTIVEMESSAGES	(*mxGetPr(ssGetSFcnParam(S, 6)))		/* maximum number of consecutive warnings */
#define WRITETOFILE				(int)(*mxGetPr(ssGetSFcnParam(S, 7)))	/* write messages to file */
#define DEBUGFILENAME			(*mxGetPr(ssGetSFcnParam(S, 8)))		/* filename for messages */
#define NPARAMS                           9


                
#define TAMB       (*u0[0])      /* ambient temperature */
#define TIN        (*u1[0])      /* inlet temperature */
#define MDOT       (*u2[0])      /* massflow */
#define PRESS      (*u3[0])      /* pressure */
#define FLUID_ID   (*u4[0])      /* fluid ID (defined in carlib.h) */
#define PERCENTAGE (*u5[0])      /* mixture  (defined in carlib.h) */

#define POWER      ((double*)ssGetDWork(S, 0)) /* power to each node */

/* DWork vectors for messages */
#define DWORK_FILENAME                    (char*)ssGetDWork(S, 1) 		/* filename */
#define DWORK_ORIGIN                      (char*)ssGetDWork(S, 2) 		/* name of the current file */
#define DWORK_PRINTEDTOTALMESSAGES        (uint32_T*)ssGetDWork(S, 3) 	/* number of total printed warnings */
#define DWORK_PRINTEDCONSECUTIVEMESSAGES  (uint32_T*)ssGetDWork(S, 4) 	/* number of consecutive printed warnings */


/* As long as the model is run in normal or accelerator mode, the parameters can be checked. */
#define MDL_CHECK_PARAMETERS
/* some functions are available in normal or accelerator mode only.
 * This can be checked by the following line */
#if defined(MDL_CHECK_PARAMETERS) && defined(MATLAB_MEX_FILE)
  /* Function: mdlCheckParameters =============================================
   * Abstract:
   *    Validate our parameters to verify they are okay.
   */
  static void mdlCheckParameters(SimStruct *S)
  {
      int n;
      
       /* The heat transfer coefficient must be positive (or zero) */
      if (UA < 0.0)
      {
          ssSetErrorStatus(S,"Error in simplepipe: loss coefficient must be >= 0");
          return;
      }
      
      
      /* Check the number of nodes */
      if (NODES < 1) {
          ssSetErrorStatus(S,"Error in simplepipe: number of nodes must be >= 1");
          return;
      }
      
      /* The initial temperature is a vector. So we must check if the temperature is higher than -273.15 deg C (0 K)
       *  and if the number of elements is the same as the number of nodes. */
      for(n=0; n<(int)mxGetN((ssGetSFcnParam(S, 2))); n++)
      {
          if (TINIT[n] < -273.15)
          {
              ssSetErrorStatus(S,"Error in simplepipe: initial temperature is below 0 K");
              return;
          }
      }
      if (NODES!=(int)mxGetN(ssGetSFcnParam(S, 3)))
      {
          ssSetErrorStatus(S,"Error in simplepipe: initial temperature vector must have NODES number of elements");
          return;
      }
  }
#endif /* MDL_CHECK_PARAMETERS */
 



/* Function: mdlInitializeSizes ===============================================
 * Abstract:
 *   Setup sizes of the various vectors.
 */
static void mdlInitializeSizes(SimStruct *S)
{
    ssSetNumSFcnParams(S, NPARAMS); /* set number of parameters */
    
    /* check the validity of the parameters */
    #if defined(MDL_CHECK_PARAMETERS) && defined(MATLAB_MEX_FILE)
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

    ssSetNumContStates(S, (int)NODES);  /* number of continuous states */
    ssSetNumDiscStates(S, 0);           /* number of discrete states */

    /* set the number of inports
     * All inports have size one.
     * If we would not report the power to environment (i.e. as output),
     * inport 0 would not require direct feedthrough.
     */
    if (!ssSetNumInputPorts(S, 6))
    {
        return;
    }
    ssSetInputPortWidth(S, 0, 1);
    ssSetInputPortDirectFeedThrough(S, 0, 1);
    ssSetInputPortWidth(S, 1, 1);
    ssSetInputPortDirectFeedThrough(S, 1, 0);
    ssSetInputPortWidth(S, 2, 1);
    ssSetInputPortDirectFeedThrough(S, 2, 0);
    ssSetInputPortWidth(S, 3, 1);
    ssSetInputPortDirectFeedThrough(S, 3, 0);
    ssSetInputPortWidth(S, 4, 1);
    ssSetInputPortDirectFeedThrough(S, 4, 0);
    ssSetInputPortWidth(S, 5, 1);
    ssSetInputPortDirectFeedThrough(S, 5, 0);

    if (!ssSetNumOutputPorts(S, 3))
    {
        return;
    }
    ssSetOutputPortWidth(S, 0, 1);
    ssSetOutputPortWidth(S, 1, (int)NODES);
    ssSetOutputPortWidth(S, 2, (int)NODES);

    ssSetNumSampleTimes(S, 1);
    
    /* set work vectors - one DWork-Vector */
    ssSetNumRWork(S, 0);
    ssSetNumIWork(S, 0);
    ssSetNumPWork(S, 0);
    ssSetNumDWork(S, 5);
    ssSetDWorkWidth(S, 0, NODES);
    ssSetDWorkDataType(S, 0, SS_DOUBLE);
    ssSetDWorkName(S, 0, "POWER");
    ssSetDWorkUsageType(S, 0, SS_DWORK_USED_AS_DSTATE);
    /* messages DWork vectors */
    ssSetDWorkWidth(S, 1, (int)mxGetN((ssGetSFcnParam(S, 8)))*sizeof(mxChar) + 1*sizeof(mxChar));
    ssSetDWorkDataType(S, 1, SS_UINT8);
    ssSetDWorkName(S, 1, "DWORK_FILENAME");
    ssSetDWorkUsageType(S, 2, SS_DWORK_USED_AS_DSTATE);
    ssSetDWorkWidth(S, 2, (int)(strlen(ssGetPath(S)) + strlen(ssGetModelName(S)) + 4)*sizeof(mxChar));
    ssSetDWorkName(S, 2, "DWORK_ORIGIN");
    ssSetDWorkUsageType(S, 2, SS_DWORK_USED_AS_DSTATE);
    ssSetDWorkDataType(S, 2, SS_UINT8);
    ssSetDWorkWidth(S, 3, 1);
    ssSetDWorkName(S, 3, "DWORK_TOTAL");
    ssSetDWorkUsageType(S, 3, SS_DWORK_USED_AS_DSTATE);
    ssSetDWorkDataType(S, 3, SS_UINT32);
    ssSetDWorkWidth(S, 4, 1);
    ssSetDWorkDataType(S, 4, SS_UINT32);
    ssSetDWorkName(S, 4, "DWORK_CON");
    ssSetDWorkUsageType(S, 4, SS_DWORK_USED_AS_DSTATE);
    
    
    ssSetNumModes(S, 0);
    ssSetNumNonsampledZCs(S, 0);

    /* SimStateCompiliance */
    ssSetSimStateCompliance(S, USE_DEFAULT_SIM_STATE);
    ssSetSimStateVisibility(S, 1);
    
    /* This flag is needed for ForEach subsystems */
    ssSupportsMultipleExecInstances(S, true);
}


/* Function: mdlInitializeSampleTimes =========================================
 * Abstract:
 *    Specify that we inherit our sample time from the driving block.
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
    uint32_T *D3 = DWORK_PRINTEDTOTALMESSAGES;
    uint32_T *D4 = DWORK_PRINTEDCONSECUTIVEMESSAGES;
    int_T  n;
 
    for (n = 0; n < NODES; n++) 
    {
        x0[n] = TINIT[n]; /* initial temperature */
        /* actually the power is calculated in mdlOutputs before use
         * but it is a good idea to get used to initialise work vectors as well */
        POWER[n] = 0.0;
    }
    
    /* fill the content of the message DWork vectors */
    mxGetString((ssGetSFcnParam(S, 8)), DWORK_FILENAME, (int)(mxGetN(ssGetSFcnParam(S, 26))+1)*sizeof(mxChar)); 
    sprintf(DWORK_ORIGIN, "%s/%s.c",ssGetPath(S), ssGetModelName(S));
    D3[0] = (uint32_T)0;
    D4[0] = (uint32_T)0;
}



/* Function: mdlOutputs =======================================================
 */
static void mdlOutputs(SimStruct *S, int_T tid)
{
    InputRealPtrsType u0 = ssGetInputPortRealSignalPtrs(S, 0);
    real_T   *y0    = ssGetOutputPortRealSignal(S, 0);
    real_T   *y1    = ssGetOutputPortRealSignal(S, 1);
    real_T   *y2    = ssGetOutputPortRealSignal(S, 2);
    real_T   *x     = ssGetContStates(S);
    int n;

    /* calculate the power to the environment for each node
     * and save them in the DWork vector */
    for(n=0; n<NODES; n++)
    {
        POWER[n] = UA*(TAMB-x[n])/(double)NODES;
    }
    
  
    /* set outputs */
    y0[0] = x[NODES-1];     /* temperature of the last node  */
    for(n=0; n<NODES; n++)
    {
        y1[n] = x[n];       /* node temperature */
        y2[n] = POWER[n];   /* power to environment */
    }
}


#define MDL_DERIVATIVES
/* Function: mdlDerivatives =================================================
 * Abstract:
 *      xdot = Ax + Bu
 */
static void mdlDerivatives(SimStruct *S)
{
    real_T   *dx    = ssGetdX(S);
    real_T   *x     = ssGetContStates(S);

    InputRealPtrsType u0 = ssGetInputPortRealSignalPtrs(S,0);
    InputRealPtrsType u1 = ssGetInputPortRealSignalPtrs(S,1);
    InputRealPtrsType u2 = ssGetInputPortRealSignalPtrs(S,2);
    InputRealPtrsType u3 = ssGetInputPortRealSignalPtrs(S,3);
    InputRealPtrsType u4 = ssGetInputPortRealSignalPtrs(S,4);
    InputRealPtrsType u5 = ssGetInputPortRealSignalPtrs(S,5);

    double Qdot_flow;
    double cp, rho;
    double thermalmass;
    int    n;
    
    char message[500];
	int_T messageset = MESSAGEPRINTNONE;
    
    /* Calculate the specific heat capacity and the density of the fluid.
     * For the fluid properties the carlib functions
     *  heat_capacity and density are uses.
     * Both require the inputs fluid type, fluid mix, temperature, pressure.
     * Here, the input conditions are used to calculate the
     * properties. */
    
    /* use the carlib function rangecheck() to check, if the fluid properties are in the correlated range.
     * If not, set a warning */
    if( rangecheck(DENSITY, FLUID_ID, PERCENTAGE, TIN, PRESS)!=RANGEISCORRECT )
    {
		sprintf(message,"The density is out of range! ID=%f, mix=%f, T=%f °C, p=%f Pa\n", FLUID_ID, PERCENTAGE, TIN, PRESS);
		messageset = printmessage(message, DWORK_ORIGIN, ssGetT(S), MESSAGELEVELWARNING, MESSAGELEVELBLOCK, DWORK_PRINTEDTOTALMESSAGES, MAXTOTALMESSAGES, DWORK_PRINTEDCONSECUTIVEMESSAGES, MAXCONSECUTIVEMESSAGES, WRITETOFILE, DWORK_FILENAME);
	}
    
    if( rangecheck(HEAT_CAPACITY, FLUID_ID, PERCENTAGE, TIN, PRESS)!=RANGEISCORRECT )
    {
		sprintf(message,"The specific heat capacity is out of range! ID=%f, mix=%f, T=%f °C, p=%f Pa\n", FLUID_ID, PERCENTAGE, TIN, PRESS);
		messageset = printmessage(message, DWORK_ORIGIN, ssGetT(S), MESSAGELEVELWARNING, MESSAGELEVELBLOCK, DWORK_PRINTEDTOTALMESSAGES, MAXTOTALMESSAGES, DWORK_PRINTEDCONSECUTIVEMESSAGES, MAXCONSECUTIVEMESSAGES, WRITETOFILE, DWORK_FILENAME);
	}
    
    cp  = heat_capacity(FLUID_ID, PERCENTAGE, TIN, PRESS);
    rho = density(FLUID_ID, PERCENTAGE, TIN, PRESS);
    thermalmass = VOLUME*rho*cp/(double)NODES;
    
    for (n = 0; n < NODES; n++)
    {
        /* energy flow due to fluid flow */
        if (n==0)
        { /* for the first node, the previous node is the inlet */
            Qdot_flow = MDOT*cp*(TIN-x[n]);
        }
        else
        {
            Qdot_flow = MDOT*cp*(x[n-1]-x[n]);
        }
        
        /* derivative
         * POWER is the DWork vector */
        dx[n] = (POWER[n] + Qdot_flow)/thermalmass;
    }
    
    /* if there is no message, set the number of consecutive printed messages to zero */
    if (messageset==MESSAGEPRINTNONE)
    {
        uint32_T *D = DWORK_PRINTEDCONSECUTIVEMESSAGES;
        D[0] = (uint32_T)0;
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

