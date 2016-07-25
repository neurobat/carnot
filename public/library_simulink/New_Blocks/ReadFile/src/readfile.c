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
 * Syntax  readfile
 *
 * Version  Author       Changes                                 Date
 * 0.01.0   Th. Wenzel   created S-function                      10jan2000
 *
 * Copyright (c) 2000 Solar-Institut Juelich, Germany
 *
 * This function needs the file "cutils.c"
 *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *  D E S C R I P T I O N
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * FUNCTION:		
     This function reads a matrix or variables from a file.

   PARAMETER:
     NUMBER1       : number of matrix columns (including time column) when timedependent
                     or number of all variables when not timedependent
     TIMEDEPENDENT : 1, when timedependent
                     0, when not timedependent (double variable, so <0.1 means 0)
     FILENAME      : string

   INPUT VECTOR:
     dummy         : dummy input of width 1, only because 0 isn't possible
 
   OUTPUT VECTOR:
   - matrix row, when timedependent, without the first variable = time
   - all variables, when not timedependent
 

 When timedependent, a matrix is read with the given number of column, where the first 
 value is the time variable. This time is compared to the systemtime, so data, which 
 is not in the matrix, will be linear interpolated.
 Comment lines have to begin with % or //.
 When the simulation time exceeds the time in the file, the function reads the file from the beginning.

 When not timedependent, all variables (not a matrix) in the file are read in the first 
 function call. Then at every call the same variables will be put out.

 Thomas Wenzel, 10.01.2000
 */


#define S_FUNCTION_LEVEL 2
#define S_FUNCTION_NAME readfile


/*
 * Need to include simstruc.h for the definition of the SimStruct and
 * its associated macro definitions. math.h is for function sqrt
 */
#include "simstruc.h"
#include <math.h>
#include <ctype.h>
#include "cutils.h"
/* #include "carlib.h" not yet necessary */


/* defines for the iteration loop */
#define MAXCALL         100    /* maximum number of iteration calls */
#define ERROR           1.0e-5 /* error in massflow iteration       */


/*
 * some defines for access to the parameters
 */
#define NUMBER1 (*mxGetPr(ssGetSFcnParam(S,0))) 
#define TIMEDEPENDENT (*mxGetPr(ssGetSFcnParam(S,1))) 
#define FILENAME ((ssGetSFcnParam(S,2)))
#define N_PARA                              3
#define TIME     (ssGetT(S))



/*
 * some defines for access to the input vector
 */



/*
 * some defines for access to the output vector
 */



/*
 * some defines for access to the rwork vector
 */

#define M(i)     rwork[2*NUMBER+i+3]
#define LOOPTIME rwork[0]
#define LASTTIME rwork[1]
#define NOWTIME  rwork[NUMBER+2]
#define Y1(i)    rwork[2+i]
#define Y2(i)    rwork[NUMBER+3+i]
#define FILEPOS  iwork[0]


#undef DEBUG

/*====================*
 * S-function methods *
 *====================*/

/* Function: mdlInitializeSizes ===============================================
 * Abstract:
 *    The sizes information is used by Simulink to determine the S-function
 *    block's characteristics (number of inputs, outputs, states, etc.).
 */
static void mdlInitializeSizes(SimStruct *S)
{
    ssSetNumSFcnParams(S, N_PARA);  /* Number of expected parameters */
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
        /* Return if number of expected != number of actual parameters */
        return;
    }

    ssSetNumContStates(S, 0);
    ssSetNumDiscStates(S, 0);

    if (!ssSetNumInputPorts(S, 1)) return;  
    ssSetInputPortWidth(S, 0, 1);
    ssSetInputPortDirectFeedThrough(S, 0, 1);

    if (!ssSetNumOutputPorts(S, 1)) return;
    ssSetOutputPortWidth(S, 0, (int) (NUMBER1+0.5));

    ssSetNumSampleTimes(S, 1);
    ssSetNumRWork(S, 3*((int) (NUMBER1 +0.5))+2);
    ssSetNumIWork(S, 1);
    ssSetNumPWork(S, 0);
    ssSetNumModes(S, 0);
    ssSetNumNonsampledZCs(S, 0);

    /* Take care when specifying exception free code - see sfuntmpl.doc */
#ifdef  EXCEPTION_FREE_CODE
    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE);
#endif
}



/* Function: mdlInitializeSampleTimes =========================================
 * Abstract:
 *    This function is used to specify the sample time(s) for your
 *    S-function. You must register the same number of sample times as
 *    specified in ssSetNumSampleTimes.
 */
static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, CONTINUOUS_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, 0.0);

}



#define MDL_INITIALIZE_CONDITIONS   /* Change to #undef to remove function */
#if defined(MDL_INITIALIZE_CONDITIONS)
  /* Function: mdlInitializeConditions ========================================
   * Abstract:
   *    In this function, you should initialize the continuous and discrete
   *    states for your S-function block.  The initial states are placed
   *    in the state vector, ssGetContStates(S) or ssGetRealDiscStates(S).
   *    You can also perform any other initialization activities that your
   *    S-function may require. Note, this routine will be called at the
   *    start of simulation and if it is present in an enabled subsystem
   *    configured to reset states, it will be call when the enabled subsystem
   *    restarts execution to reset the states.
   */
  static void mdlInitializeConditions(SimStruct *S)
  {
    real_T   *rwork    = ssGetRWork(S);
    int_T    *iwork    = ssGetIWork(S);
    int ir;
    int_T   i,name_length, status, fehler, NUMBER;
    long pos;
    char zeile[1000], zahlstring[100], *name, *p;
    FILE *datei;
    real_T   d;

    
    NUMBER = (int_T)(NUMBER1+0.5);    					/* move to integer */
 
    for (i=0;i<3*NUMBER+2;i++)             			/* clear work space */
      rwork[i] = 0;
    iwork[0] = 0;

    if (TIMEDEPENDENT<0.1)    /* when not TIMEDEPENDENT, then read all variables */
    {
       name_length = (int_T)((mxGetM(FILENAME)*mxGetN(FILENAME))+1);   	/* find filename */
       name = mxCalloc(name_length,sizeof(char));
       status = mxGetString(FILENAME,name,name_length);

       if ((datei=fopen(name,"r"))!=NULL)                  
       {
          ir = 0;
          while (!feof(datei))
          {
            lies_zeile(datei,zeile,&pos);                 	/* read one line */
    
            while (strlen(zeile)>0)
            {             
/*              p = zeile;                                        
              while((p[0]==' ' || isalpha(p[0])) && p[0]!='\0')	/* search for a digit */
  /*              p++;
 */
              i = 0;
              while((zeile[i]==' ' || (int_T)(isalpha(zeile[i])) && i<(int_T)strlen(zeile))) /* search for a digit */
                i++;
/*              strcpy(zahlstring,p);
              p = zahlstring;*/
              strcpy(zahlstring,zeile+i);
              p = zahlstring;
              if (i>0 && isalpha(zeile[i-1]))                   /* e.g. 'var1' -> 'vara' is not a number*/
                  zahlstring[0]='a';

              while (p[0]!=' ' && p[0]!='\0') 			/* search end of numberstring */
                 p++;
              strcpy(zeile,p);
              p[0] = '\0';

              fehler = string2double(zahlstring,&d);		/* read number from numberstring */

              if (fehler==0 && ir<=NUMBER && strlen(zahlstring)>0) /* save number */
                  rwork[ir++] = d;

              if (fehler)					
                 printf("error: no number : %s\n",zahlstring);
              if (ir>NUMBER)
                 printf("error: number of values too large\n");
            } /* while (strlen(zeile)>0) */
          } /* while (!feof(datei)) */
        } /* if ((datei=fopen(name,"r"))!=NULL) */
        else
          printf("error: cannot open file %s\n",name);
              
            

    }
  }
#endif /* MDL_INITIALIZE_CONDITIONS */



#undef MDL_START  /* Change to #undef to remove function */
#if defined(MDL_START) 
  /* Function: mdlStart =======================================================
   * Abstract:
   *    This function is called once at start of model execution. If you
   *    have states that should be initialized once, this is the place
   *    to do it.
   */
  static void mdlStart(SimStruct *S)
  {
  }
#endif /*  MDL_START */



/* Function: mdlOutputs =======================================================
 * Abstract:
 *    In this function, you compute the outputs of your S-function
 *    block. Generally outputs are placed in the output vector, ssGetY(S).
 */
static void mdlOutputs(SimStruct *S, int_T tid)
{
    InputRealPtrsType u1Ptrs = ssGetInputPortRealSignalPtrs(S,0);

    real_T  *y1 = ssGetOutputPortRealSignal(S,0);
    real_T  *rwork = ssGetRWork(S);
    int_T   *iwork = ssGetIWork(S);
    real_T  d; //t;
    int_T   i, name_length, status, fehler, NUMBER;
    long pos;
    char zeile[1000], zahlstring[1000], *name, *p;
    FILE *datei;


    NUMBER = (int_T)(NUMBER1+0.1);


    name_length = (int_T)((mxGetM(FILENAME)*mxGetN(FILENAME))+1);         /* find filename */
    name = mxCalloc(name_length,sizeof(char));
    status = mxGetString(FILENAME,name,name_length);

    if (TIMEDEPENDENT)  /* if timedependent, then read one line or interpolated between to lines */
    {
      while (TIME-LOOPTIME>=NOWTIME)  /* if simulationtime > last read time, then read new line */
      {
        for (i=0;i<NUMBER;i++)                              /* remember last line */
           Y1(i) = Y2(i);
        LASTTIME = NOWTIME;
        NOWTIME = 0;

        if ((datei=fopen(name,"r"))!=NULL)                  
        {
          if (FILEPOS<=0)                                    /* if begin of file, then    */
          {                                                  /* save the time, with which */
             LOOPTIME = TIME;                                /* every time loop begins    */
             NOWTIME = 0;
          }


          fseek(datei,(long) FILEPOS,SEEK_SET);         	/* go to last file position */
         
          if (!feof(datei))
            do
            {
              lies_zeile(datei,zeile,&pos);          		/* read one line */
            }
            while (zeile[0]=='%' || (zeile[0]=='/' && zeile[1]=='/'));/* don't read comment-lines */
#ifdef DEBUG
             printf("zeile: %s\n",zeile);
#endif


          /*     decode line      */
          
          for (i=0;i<=NUMBER;i++)           			/* for each number */
          {
             p = zeile;                                        
             while(p[0]==' ' && p[0]!='\0')
               p++;             
             strcpy(zahlstring,p);
             p = zahlstring;
             while ((isdigit(p[0]) || p[0]=='e' || p[0]=='E' || p[0]=='.' || p[0]==',' || p[0]=='-' || p[0]=='+') && p[0]!='\0')
                p++;
             strcpy(zeile,p);
             p[0] = '\0';
             fehler = string2double(zahlstring,&d);
             Y2(i-1) = d;   /* -1, first number ist NOWTIME */
             /*printf("%f %s \n",d,zahlstring);*/
          } 

          /*                          print workspace for debugging */
#ifdef DEBUG
          printf("%f : ",LASTTIME);
          for (i=0;i<NUMBER;i++)
             printf("%d %f   %d\n",i,Y1(i),NUMBER);
          printf("\n");
          printf("%f : ",NOWTIME);
          for (i=0;i<NUMBER;i++)
             printf("%d %f ",i,Y2(i));
          printf("\n");             
#endif           
          FILEPOS = pos;                        		/* save actuell file position */
          fclose(datei);
        } /* if ((datei=fopen(name,"r"))!=NULL) */
        else
          printf("error: cannot open file %s!\n",name);

        for (i=0;i<NUMBER;i++)           			/* calculate linear coefficient */
          M(i) = (Y2(i)-Y1(i))/(NOWTIME-LASTTIME);
      } /* while (TIME-LOOPTIME>=NOWTIME) */


      for (i=0;i<NUMBER;i++)       				/* linear interpolation */
        y1[i] = M(i)*(TIME-LOOPTIME-NOWTIME) + Y2(i);

    }
    else               /********************************************************************/
    {                                                      /* if not time dependend, then  */
      for (i=0;i<NUMBER;i++)                               /* every time the same values   */
        y1[i] = rwork[i]; 
    }     

    /*                             print output*/
#ifdef DEBUG
     printf("           ");
    for (i=0;i<NUMBER;i++)           
      printf("%d %f  %d\n",i,y1[i],NUMBER);
    printf("\n");
#endif

} /* end mdloutputs */



#undef MDL_UPDATE  /* Change to #undef to remove function */
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
  }
#endif /* MDL_UPDATE */



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
 *    In this function, you should perform any actions that are necessary
 *    at the termination of a simulation.  For example, if memory was
 *    allocated in mdlInitializeConditions, this is the place to free it.
 */
static void mdlTerminate(SimStruct *S)
{
}


/*======================================================*
 * See sfuntmpl.doc for the optional S-function methods *
 *======================================================*/

/*=============================*
 * Required S-function trailer *
 *=============================*/

#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif
