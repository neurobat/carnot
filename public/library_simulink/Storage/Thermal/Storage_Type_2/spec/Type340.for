C***********************************************************************
C    MULTIPORT Store Model                                             *
C                                                                      *
C    This subroutine models a hot water store with three internal or   *
C    mantle heat exchangers, five doubleports and a auxiliary heater   *
C                                                                      *
C    Author:  Harald Dr…k                                             *
C                                                                      *
C             1.99EHD 24.01.2002  --->  auxon=0 if Paux=0.0            *
C             1.99DHD 22.01.2002  --->  problem of hx4 solved          *
C             1.99CHD 15.03.2001  --->  Sub NC_EX_HX again mod (p p)   *
C             1.99BHD 30.07.2000  --->  Sub NC_EX_HX mod (peak prob.)  * 
C             1.99AHD 13.04.2000  --->  Qlh4 included in calc of Qerr  * 
C             1.99 HD 30.03.2000  --->  err hx4 in solver74 corrected  * 
C             1.98EHD 09.02.1999  --->  calc of sub nc_ex_hx modified  * 
C             1.98DHD 03.02.1999  --->  calc of outlet temp changed    * 
C             1.98CHD 05.01.1999  --->  algorithm for mcon optimised   * 
C             1.98BHD 17.12.1998  --->  new mode for mcon              * 
C             1.98AHD 16.12.1998  --->  basis for 4 heat exchangers    * 
C                     in case of problems search for:  check hx4       *
C             1.97GHD 08.12.1998  --->  nc hx tdxi instead of tdxo     *
C             1.97FHD 08.12.1998  --->  boundary problem partly solved * 
C             1.97EHD 03.12.1998  --->  calc of mcon modified          * 
C             1.97EHD 01.12.1998  --->  new calc of mcon for charging  * 
C             1.97DHD 26.11.1998  --->  new calculation of mcon        * 
C             1.97 HD 25.11.1998  --->  integration of hx time factor  * 
C             1.97 HD 24.11.1998  --->  charing mode schx=2 for hx     * 
C             1.96 HD 11.11.1998  --->  extention to 10 double ports   * 
C             1.95 HD 11.11.1998  --->  Stratified discharge enabled   *
C             1.94 HD 01.02.1998  --->  Calculation of exergy          *
C             1.94 HD 24.01.1998  --->  Emulation of former versions   *    
C             1.93 HD 04.11.1997  --->  Tank in Tank option            *    
C             1.92 HD 25.09.1997  --->  Changes not included (UAHX)    *    
C             1.91 HD 08.08.1997  --->  Changes not incl.(Node funct.) *
C             1.90 HD 12.03.1997  --->  Solution of boundary problem   *    
C             1.90 HD 07.02.1997  --->  No write statements to screen  *    
C             1.89 HD 21.01.1997  --->  Calculation of Qlh2 modified   *    
C             1.88 HD 05.11.1996  --->  TRNSYS 14.2 --> TRNSYS 14.1    *    
C             1.88 HD 05.11.1996  --->  Tavr calculated before mixing  *    
C             1.87 HD 30.10.1996  --->  Adapted to TRNSYS 14.2         *    
C             1.86 HD 27.10.1996  --->  Output execution time modified *    
C             1.85 HD 17.10.1996  --->  Tavr calculated after mixing   *    
C             1.84 HD 24.06.1996  --->  more than one time useable     *    
C             1.83 HD 23.06.1996  --->  Features for load side HX      *    
C             1.82 HD 09.04.1996  --->  YCHECK and OCHECK MF2-->MF1    *    
C             1.81 HD 22.02.1996  --->  implementation of Fit-mode     *    
C             1.8  HD 27.07.1995  --->  bigger displ.value for Qerrsum *  
C             1.7  HD 21.03.1995  --->  LUNITS and SIM adapted         *  
C             1.6  HD 14.11.1994  --->  set epsall=1.e-2, (old 1.e-3)  *  
C             1.5  HD 02.11.1994  --->  Adapted for TRNSYS 14.1 (HD)   *
C             1.4  HD 27.08.1994  --->  Tavr used for ice/steam check  *
C             1.3  HD 18.08.1994  --->  Temp. for sensors after mixing *
C             1.2  HD 16.08.1994  --->  Last update (HD)               *
C    Version: 1.1  HD 20.07.1994  --->  Node-Function modified  (HD)   *
C    Version: 1.0  HD 11.07.1994                                       *
C                                                                      *
C***********************************************************************
C
      SUBROUTINE TYPE340(TIME,XIN,OUT,T,DTDT,PAR,INFO,ICNTRL,*)

! Export this subroutine for its use in external DLLs
!dec$attributes dllexport :: type340

      use TrnsysFunctions

C
C-----used variables--------------------------------------------------C
C
C     time           Trnsys-time
C     NI             Number of inputs
C     NP             Number of parameters
C     NO             Number of outputs
C     Smax           Number of elements in the S-arry
C     first          Flag if first call of Type 340 (1..yes)
C     unit           Number of the TRNSYS unit
C     YCHECK         input types
C     OCHECK         output types
C     SYSINFO        Matrix with nodepositions of heat exchangers,
C                    doubleports and zones with (UA)s,a = const.
C     FLOWINFO       matrix with nodes of massflow
C     nout           Number of a output node
C     nh1            Number of nodes occupied by the hx. 1
C     nh2            Number of nodes occupied by the hx. 2
C     nh3            Number of nodes occupied by the hx. 3
C     ndz1,ndz2,     Number of nodes with a zone
C     ndz3,ndz4         with (UA)s,a = const.
C     UAarea         (UA)sa referenced on a area
C     UAwhole        (UA)sa of the whole storage'
C     epsall         allowed exactness border (general)
C     epsis          real exactness border
C     epstmp         exactness for calculating the temperatures
C     epsua          exactness for temperature-dependence of UAhx,s
C     epsmix         allowed error caused by mixing the storage
C     TDTSC          Flag if temperature-dependence timestep
C                       controll is used(1..yes)
C     scharge        Flag if stratified charging (1..yes)
C     dia            diameter of the storage
C     bot            surface of the botten or top of the storage
C     mantle         surface of the mantle-area of the storage
C     area           genaral area
C     tdcon          thermal diffusifity caused by lacon
C     i,j,k          else
C     rhelp          Real help-variable
C     ficc           Flag if its the first call of the calculator
C                       in a Trnsys-timestep (1..yes)
C     Tnew           New temperature matrix
C     Told           Old temperature matrix
C     Tinp           temperature matrix that contains the input tem-
C                        peratures of the doubleports and heatexch.
C     Tavr           average temp.-matrix during the Trnsys - timestep
C     Tafter         Tnew in the storage after mixing
C     DO,DU,DL,      Difference - koefficients - matrix
C     DR,DB,DF       Difference - koefficients - matrix
C     DDSTAR         Matrix of DO+DU+DR+DL+DB+DF
C     CAP            Capacity-Matrix
C     SOURCE         Source-Matrix (for Paux (electric))
C     update         Flag if a difference - koefficients - matrix
C                       has been updated (1..yes)
C     dtemp          temperature-difference
C     dtmix          temperature-difference for mixing
C     DTmin          delta time thats stabel in the explicit case
C     DTint          internal delta time
C     DTmod          modified DTmin
C     DTisum         sum of the internal timesteps
C     NITS           number of relative internal timesteps
C     CPFD1          capacity-flow through doubleport 1
C     CPFD2          capacity-flow through doubleport 2
C     CPFD3          capacity-flow through doubleport 3
C     CPFD4          capacity-flow through doubleport 4
C     CPFD5          capacity-flow through doubleport 5
C     CPFD6          capacity-flow through doubleport 6
C     CPFD7          capacity-flow through doubleport 7
C     CPFD8          capacity-flow through doubleport 8
C     CPFD9          capacity-flow through doubleport 9
C     CPFD10         capacity-flow through doubleport 10
C     CPFH1          capacity-flow through the first heatexchanger
C     CPFH2          capacity-flow through the second heatexchanger
C     CPFH3          capacity-flow through the thrid heatexchanger
C     CPFH4          capacity-flow through the fourth heatexchanger
C     nzd/hi         nodal input positions of storage and hx
C     CPWS           Heat capacity of the whole storage
C     CPWH1          Heat capacity of the whole first heatexch.
C     CPWH2          Heat capacity of the whole second heatexch.
C     CPWH3          Heat capacity of the whole third heatexch.
C     CPWH4          Heat capacity of the whole fourth heatexch.
C     Th1onw         new outlet temperature hx 1
C     Th1ood         old outlet temperature hx 1
C     Th2onw         new outlet temperature hx 2
C     Th2ood         old outlet temperature hx 2
C     Th3onw         new outlet temperature hx 3
C     Th3ood         old outlet temperature hx 3
C     Th4onw         new outlet temperature hx 4
C     Th4ood         old outlet temperature hx 4
C     taita1         Flag if first hx is tank in tank hx (1...yes)
C     taita2         Flag if second hx is tank in tank hx (1...yes)
C     taita3         Flag if third hx is tank in tank hx (1...yes)
C     taita4         Flag if fourth hx is tank in tank hx (1...yes)
C     UAhxsm         Vector with values of UA between a
C                    heatexchanger and the storage
C     Qd1a...Qd10    actual power transfered by dp1...dp10
C     Qerr           error power in power balance
C     dQint          difference of internal power between two times
C                       on Trnsys-timestep
C     Qerrsum        sum of Qerr over the whole simulation
C     Qall           ABS of all changed power
C     dmix           value of the difference-koefficient for mixing
C     Tsmold1        Tsm from the actual timestep - 1
C     Tsmold2        Tsm from the actual timestep - 2
C     mh1old         mh1 from the actual timestep - 2 that was > 0
C     mh2old         mh2 from the actual timestep - 2 that was > 0
C     mh3old         mh3 from the actual timestep - 2 that was > 0
C     mh4old         mh4 from the actual timestep - 2 that was > 0
C     direct         kind of direct-solution method
C                       0...non         2...hx2/hx3
C                       1...hx1         3...hx1&hx2/hx3
C                       4...store only
C     sodir          direction of solving the equation
C                       system  (1..upwards / -1..downards)
C     DTminmod       Flag if DTmin has been modified  (1..yes)
C     modus          kind of solution 1....with CALL MIXER
C                                     2....with lambda - mix
C     hx1na          Flag if hx1 is not active (1..yes / 0..no)
C     hx2na          Flag if hx2 is not active (1..yes / 0..no)
C     hx3na          Flag if hx3 is not active (1..yes / 0..no)
C     hx4na          Flag if hx4 is not active (1..yes / 0..no)
C     hxactive       Flag if a heatexchanger is active (1..yes)
C     hxuavar        Flag if variable UAhx,s is used (1..yes)
C     ncvhx          Flag if a hx is operated in natural convection
C                    mode (1..yes)
C     dpactive       Flag if a doubleport is active (1..yes)
C     Ichange        Flag if Inputs have changed between
C                       two timesteps (1..yes)
C     auxon          Flag if auxiliary heater is active (1..yes)
C                    (if HMOD=2) (used in Subroutine HEATER)
C     auxold             auxon form the timestep before
C     called         Flag if Subroutine HEATER has allready
C                    been called (used in Subroutine HEATER)
C     fit            multiplication factor if Type 340 is used 
C                    for dynamic-fitting  (if PAR(82) = -7.0)
C     ver            flag for version to be emulated
C     UAHiV          factor for time constant of load side hx i (Shi)
C     UAhiT          time dependend factor for UA of  load side hx i
C     UAhxi          UA-value of heat exch. if treated as external
C     os             offset in the S-Array (os = INFO(10))
C                    For the calculation of the execution time
C     esth,estm,     execution start time: houers,minutes,
C     ests,esths                           seconds,hundredth second
C     eeth,eetm,     execution end time: houers,minutes,
C     eets,eeths,                        seconds,hundredth second
C     eth,etm,       execution time: houers,minutes,
C     ets,eths                       seconds,hundredth second
C
C     NODE           Function that calculates the node of
C                        a relative storage position
C
C-----allocation of the S-ARRAY---------------------------------------C
C
C     os             offset in the S-Array (os = INFO(10))
C     i = 1..Nmax    node
C
C     S(os+1)        Qerrsum
C     S(os+2)        Tsmold1
C     S(os+3)        Tsmold2
C     S(os+4)        auxon  (see Subroutie)
C     S(os+5)        auxold (see Subroutine HEATER)
C     S(os+6)        called (see Subroutine HEATER)
C     S(os+7)        UAh1T
C     S(os+8)        UAh2T
C     S(os+9)        UAh3T
C     S(os+10)       UAh4T
C     S(os+11)       mh1old
C     S(os+12)       mh2old
C     S(os+13)       mh3old
C     S(os+14)       mh4old
C     S(os+15)       eth
C     S(os+16)       etm  
C     S(os+17)       ets
C     S(os+18)       eths
C     S(os+19...+20) not used
C     S(os+21...+50) inputs form the timestep before
C     S(os+50+i...+50+Nmax)                 SYSINFO(1,1)...(Nmax,1)
C     S(os+50+(1*Nmax)+i...+50+(2*Nmax))    SYSINFO(1,2)...(Nmax,2)
C     S(os+50+(2*Nmax)+i...+50+(3*Nmax))    SYSINFO(1,3)...(Nmax,3)
C          .                    .               .             .
C          .                    .               .             .
C     S(os+50+(10*Nmax)+i...+50+(11*Nmax))  SYSINFO(1,11)...(Nmax,11)
C     S(os+50+(11*Nmax)+i...+50+(12*Nmax))  SYSINFO(1,12)...(Nmax,12)
C     S(os+50+(12*Nmax)+i...+50+(13*Nmax))  SYSINFO(1,13)...(Nmax,13)
C     S(os+50+(13*Nmax)+i...+50+(14*Nmax))  SYSINFO(1,14)...(Nmax,14)
C     S(os+50+(14*Nmax)+i...+50+(15*Nmax))  SYSINFO(1,15)...(Nmax,15)
C     S(os+50+(15*Nmax)+i...+50+(16*Nmax))  SYSINFO(1,16)...(Nmax,16)
C     S(os+50+(16*Nmax)+i...+50+(17*Nmax))  SYSINFO(1,17)...(Nmax,17)
C     S(os+50+(17*Nmax)+i...+50+(18*Nmax))  SYSINFO(1,18)...(Nmax,18)
C     S(os+50+(18*Nmax)+i...+50+(19*Nmax))     temperature - matrix
C     S(os+50+(19*Nmax)+i...+50+(20*Nmax))     at the beginn of the
C     S(os+50+(20*Nmax)+i...+50+(21*Nmax))      TRNSYS - Timestep
C     S(os+50+(21*Nmax)+i...+50+(22*Nmax))     temperature - matrix
C     S(os+50+(22*Nmax)+i...+50+(23*Nmax))      at the end of the
C     S(os+50+(23*Nmax)+i...+50+(24*Nmax))      TRNSYS - Timestep
C
C-----used subroutines-------------------------------------------------C
C
C     NAME           Type                Library
C     CONV74         Subroutine          Type 340
C     AL_SYSIN       Subroutine          Type 340
C     AL_FLOW        Subroutine          Type 340
C     TINP_IN        Subroutine          Type 340
C     DF_INIT        Subroutine          Type 340
C     HEATER         Subroutine          Type 340
C     SOLVER74       Subroutine          Type 340
C     UAHXT          Subroutine          Type 340
C     UAHXS          Subroutine          Type 340
C     NC_EX_HX       Subroutine          Type 340
C     IN_VI_DP       Subroutine          Type 340
C 14.2    GETTIM         Subroutine          TRNSYS (clock.for)
C     DU_DO_IN       Subroutine          Type 340
C     DL_DR_IN       Subroutine          Type 340
C     DD_DTMIN       Subroutine          Type 340
C     SOLUTION       Subroutine          Type 340
C     MIXER          Subroutine          Type 340
C     DP_POWER       Subroutine          Type 340
C     CALCU_EX       Subroutine          Type 340
C     CALCU_HX       Subroutine          Type 340
C     S_STORE        Subroutine          Type 340
C     S_DIRECT       Subroutine          Type 340
C     NODE           Integer-Function    Type 340
C
C----------------------------------------------------------------------C

      IMPLICIT NONE
	DOUBLE PRECISION XIN,OUT,TIME,PAR,T,DTDT,TIME0,TFINAL,DELT,STORED				
      INTEGER*4 INFO(15),NP,NI,NOUT,ND,IUNIT,ITYPE,ICNTRL,NSTORED,
	1   NIN,NPAR,NDER,NITEMS
	CHARACTER*3 YCHECK,OCHECK
C-----------------------------------------------------------------------------------------------------------------------

C-----------------------------------------------------------------------------------------------------------------------
C    USER DECLARATIONS
      PARAMETER (NP=126,NI=30,NOUT=285,ND=0,NSTORED=5250)
C-----------------------------------------------------------------------------------------------------------------------

C-----------------------------------------------------------------------------------------------------------------------
C    REQUIRED TRNSYS DIMENSIONS
      DIMENSION XIN(NI),OUT(NOUT),PAR(NP),YCHECK(NI),OCHECK(NOUT),
	1   STORED(NSTORED),T(ND),DTDT(ND)

C---->Note: the minimum value of maxN is Nmax+1 !!!
	DOUBLE PRECISION PI
	INTEGER maxN
      PARAMETER (maxN=200, PI=3.1417)

	DOUBLE PRECISION UAh1s,UAhx1,bh11,bh12,bh13,mh1,smh1
	DOUBLE PRECISION UAh2s,UAhx2,bh21,bh22,bh23,mh2,smh2
      DOUBLE PRECISION UAh3s,UAhx3,bh31,bh32,bh33,mh3,smh3
      DOUBLE PRECISION UAh4s,UAhx4,bh41,bh42,bh43,mh4,smh4

      DOUBLE PRECISION Tnew(maxN,3),Told(maxN,3),Tinp(maxN,3),
     &Tavr(maxN,3),DO(maxN,3),DU(maxN,3),DL(maxN,3),DR(maxN,3),
     &DB(maxN,3),DF(maxN,3),DDSTAR(maxN,3),Cap(maxN,3),Source(maxN,3),
     &Tafter(maxN),UAhxsm(maxN),dtemp,NITS,dtmix,rhelp,UAarea,UAwhole,
     &epsall,epsis,epstmp,epsua,epsmix,dia,bot,mantle,area,tdcon,DTmin,
     &DTisum,DTint,DTmod,CPFD1,CPFD2,CPFD3,CPFD4,CPFD5,CPFD6,CPFD7,
     &CPFD8,CPFD9,CPFD10,CPFH1,CPFH2,CPFH3,CPFH4,CPWS,CPWH1,CPWH2,CPWH3,
     &CPWH4,Qd1a,Qd2a,Qd3a,Qd4a,Qd5a,Qd6a,Qd7a,Qd8a,Qd9a,Qd10a,Qerr,
     &dQint,Qerrsum,Qall,dmix,fit,ver,Tsmold1,Tsmold2,UAH1V,UAH2V,UAH3V,
     &UAH4V,UAh1T,UAh2T,UAh3T,UAh4T,mh1old,
     &mh2old,mh3old,mh4old,Th1avr,Th2avr,Th3avr,Th4avr,Th1onw,Th1ood,
     &Th2onw,Th2ood,Th3onw,Th3ood,Th4onw,Th4ood,rhilf

      INTEGER SYSINFO(maxN,18),FLOWINFO(maxN,18),Smax,first,unit,ficc,
     &update,NO,nh1,nh2,nh3,ndz1,ndz2,ndz3,ndz4,taita1,taita2,taita3,
     &taita4,TDTSC,scharge,direct,sodir,Ichange,hxuavar,ncvhx,auxon,
     &auxold,called,i,j,k,os,nzd1i,nzd2i,nzd3i,nzd4i,nzd5i,nzd6i,nzd7i,
     &nzd8i,nzd9i,nzd10i,nzh1i,nzh2i,nzh3i,nzh4i,DTminmod,modus,hx1na,
     &hx2na,hx3na,hx4na,hxactive,dpactive,NODE,nh4,n

      INTEGER*2 esth,estm,ests,esths,eeth,eetm,eets,eeths,
     1          eth,etm,ets,eths

C     INPUTS
      DOUBLE PRECISION Td1i,Td2i,Td3i,Td4i,Td5i,Td6i,Td7i,Td8i,Td9i,
     &Td10i,Th1i,Th2i,Th3i,Th4i,Tamb,md1,md2,md3,md4,md5,md6,md7,md8,
     &md9,md10,Paux

C     PARAMETERS
      INTEGER scd1,scd2,scd3,scd4,scd5,scd6,scd7,scd8,scd9,scd10,HMOD,
     &HTOP,sch1,sch2,sch3,sch4,Nmax
      

	DOUBLE PRECISION Hs,Vs,dz1,dz2,dz3,zd1i,zd1o,zd2i,zd2o,zd3i,zd3o,
     &zd4i,zd4o,zd5i,zd5o,zd6i,zd6o,zd7i,zd7o,zd8i,zd8o,zd9i,zd9o,zd10i,
     &zd10o,zs1,zs2,zs3,zs4,zs5,laux,zaux,ztaux,zh1i,zh1o,Vh1,
     &zh2i,zh2o,Vh2,zh3i,zh3o,Vh3,
     &zh4i,zh4o,Vh4,dd1,dd2,dd3,dd4,dd5,dd6,dd7,dd8,dd9,
     &dd10,cps,rhos,cph1,rhoh1,cph2,rhoh2,cph3,rhoh3,cph4,rhoh4,UAsbot,
     &UAstop,UAsa1,UAsa2,UAsa3,UAsa4,UAh1a,UAh2a,
     &UAh3a,UAh4a,Tset,dTdb,Tini,lacon,lamix,
     &sigma

C     OUTPUTS
      DOUBLE PRECISION Td1o,Td2o,Td3o,Td4o,Td5o,Td6o,Td7o,Td8o,Td9o,
     &Td10o,Th1o,Th2o,Th3o,Th4o,Qls,Qd1,Qd2,Qd3,Qd4,Qd5,Qd6,Qd7,Qd8,
     &Qd9,Qd10,Tsm,Ts1,Ts2,Ts3,Ts4,Ts5,Taux,Qaux,Qlh1,Qh1,Qh1s,Th1m,
     &Qlh2,Qh2,Qh2s,Th2m,Qlh3,Qh3,Qh3s,Th3m,Qlh4,Qh4,Qh4s,Th4m,Qlbot,
     &Qltop,Qls1,Qls2,Qls3,Qls4,dUh1,dUh2,dUh3,dUh4,dUs,dUws,Exh1,Exh2,
     &Exh3,Exh4,Exs,Exws

	CHARACTER*256 iStr,Msg,jStr,TStr

	COMMON/DP_OUT/zd1o,zd2o,zd3o,zd4o,zd5o,zd6o,zd7o,zd8o,zd9o,zd10o
      COMMON/DP_CPF/CPFD1,CPFD2,CPFD3,CPFD4,CPFD5,
     1              CPFD6,CPFD7,CPFD8,CPFD9,CPFD10
      COMMON/DP_INP_T/Td1i,Td2i,Td3i,Td4i,Td5i,Td6i,Td7i,Td8i,Td9i,Td10i
      COMMON/DP_OUT_T/Td1o,Td2o,Td3o,Td4o,Td5o,Td6o,Td7o,Td8o,Td9o,Td10o
      COMMON/DP_R_INP/zd1i,zd2i,zd3i,zd4i,zd5i,zd6i,zd7i,zd8i,zd9i,zd10i
      COMMON/DP_N_INP/nzd1i,nzd2i,nzd3i,nzd4i,nzd5i,
     1                nzd6i,nzd7i,nzd8i,nzd9i,nzd10i
      COMMON/DP_MASSF/md1,md2,md3,md4,md5,md6,md7,md8,md9,md10

      COMMON/HX_OUT/zh1o,zh2o,zh3o,zh4o
      COMMON/HX_CPF/CPFH1,CPFH2,CPFH3,CPFH4
      COMMON/HX_INP_T/Th1i,Th2i,Th3i,Th4i
      COMMON/HX_OUT_T/Th1o,Th2o,Th3o,Th4o
      COMMON/HX_T_OUT/Th1onw,Th1ood,Th2onw,Th2ood,Th3onw,Th3ood, 
     1                Th4onw,Th4ood 
      COMMON/HX_R_INP/zh1i,zh2i,zh3i,zh4i
      COMMON/HX_N_INP/nzh1i,nzh2i,nzh3i,nzh4i

      COMMON/CP_FLUID/cps,cph1,cph2,cph3,cph4

      COMMON/S_CHARGE/scd1,scd2,scd3,scd4,scd5,scd6,scd7,scd8,
     1                scd9,scd10,sch1,sch2,sch3,sch4

      COMMON/UAHX/UAh1s,UAhx1,bh11,bh12,bh13,mh1,smh1,
     1            UAh2s,UAhx2,bh21,bh22,bh23,mh2,smh2,
     2            UAh3s,UAhx3,bh31,bh32,bh33,mh3,smh3,
     3            UAh4s,UAhx4,bh41,bh42,bh43,mh4,smh4,nh1,nh2,nh3,nh4

      COMMON/DU_DO/DU,DO,tdcon,dmix,modus

      COMMON/HXNOTACT/hx1na,hx2na,hx3na,hx4na

      COMMON/A_HEATER/laux,zaux,ztaux,HMOD,HTOP,Hs,Paux,Tset,dTdb

      COMMON/SOL_MET/direct,sodir

      COMMON/SAV_HEAT/auxon,auxold,called
      
      COMMON/LSH/UAh1T,UAh2T,UAh3T,UAh4T  

      COMMON/MP_INF/unit

      TIME0=getSimulationStartTime()
      TFINAL=getSimulationStopTime()
      DELT=getSimulationTimeStep()

      if (info(7) .eq. -2) then
        info(12) = 16   ! This component is a TRNSYS 15 Type
        return 1
      endif

      if (info(8)  .eq. -1) return 1

      if (info(13) .gt.  0) return 1

C---->set temperature - difference and Flag for mixing
c     dtmix = 0.5
      dtmix = 0.d0

C---->set allowed exactness border
      epsall = 1.d-2

C---->check which version of Multiport is used 
C     Note: Version 1.96 is the fist version were
C           Parameters, Input and Outputs were changed
C           Emulation of version 1.96 is not supported,
C           Emulation of version 1.97 is not supported,
C---->Check if it's used for fitting and set multiplication factor
C     Note: 1.81 was the first version with the fitting option       

      fit = 1.0
      If (PAR(125).gt.0.0.and.PAR(125).lt.(maxN - 1)) then
C------->it could be a deck for version 1.98 (or higher)
         if (PAR(126).eq.0.0.or.PAR(126).eq.1.98) then
C---------->it's a deck of version 1.98 in the standard mode
            ver = 1.98
         else if (PAR(126).eq.-7) then
C---------->it's a deck of version 1.98 (or higher) in the fitting mode
            ver = 1.98
            fit = 1000.0
         else if (PAR(126).eq.1.95) then
C---------->it's a deck of version 1.98 (or higher) emulating
C           version 1.95 (or lower)
            ver = 1.95
         else if (PAR(126).eq.-1.95) then
C---------->it's a deck of version 1.98 (or higher) emulating
C           version 1.95 (or lower) in the fitting mode
            ver = 1.95
            fit = 1000.0
         else
C---------->it's most probably an old deck (for version 1.95 or lower)
            ver = 1.95
         end if
      end if

C---->it's a deck for version 1.95 (or lower)
      if (PAR(82).lt.-1.8) then
C------->it's a deck for version 1.95 (or lower) in the fitting mode
         fit = 1000.0
      end if

C    DO ALL THE VERY FIRST CALL OF THE SIMULATION MANIPULATIONS HERE
      IF (INFO(7).EQ.-1) THEN

C       RETRIEVE THE UNIT NUMBER AND TYPE NUMBER FOR THIS COMPONENT FROM THE INFO ARRAY
         IUNIT=INFO(1)
	   ITYPE=INFO(2)

C       SET SOME INFO ARRAY VARIABLES TO TELL THE TRNSYS ENGINE HOW THIS TYPE IS TO WORK
         INFO(3)=NI
         INFO(4)=NP

C       SET THE REQUIRED NUMBER OF INPUTS, PARAMETERS AND DERIVATIVES
         NIN= 30
	   NPAR= 126
	   NDER= 0
C        Vertical number of nodes
         IF (ver.lt.1.98) then
            IF (fit.eq.1000.0) then
               Nmax = JFIX(PAR(81) * fit*10.0)
            else
               Nmax = JFIX(PAR(81) * fit)  
            end if
         else
            IF (fit.eq.1000.0) then
               Nmax = JFIX(PAR(125) * fit*10.0)
            else
               Nmax = JFIX(PAR(125) * fit)  
            end if
         end if
         IF (Nmax.gt.maxN-2) then
		 CALL MESSAGES(-1,'Maximum number of nodes exceeded','FATAL'
     &                   ,IUNIT,ITYPE)
	     if (ErrorFound()) RETURN 1
         end if

C        Number of Outputs
         NO = Nmax + 87
         INFO(6)=NO
	       
C       CALL THE TYPE CHECK SUBROUTINE TO COMPARE WHAT THIS COMPONENT REQUIRES TO WHAT IS SUPPLIED
	   CALL TYPECK(1,INFO,NIN,NPAR,NDER)

C       SET THE YCHECK AND OCHECK ARRAYS TO CONTAIN THE CORRECT VARIABLE TYPES FOR THE INPUTS AND OUTPUTS
         DATA YCHECK/'TE1','MF1','TE1','MF1','TE1','MF1','TE1','MF1',
     1               'TE1','MF1','TE1','MF1','TE1','MF1','TE1','MF1',
     2               'TE1','MF1','TE1','MF1','TE1','MF1','TE1','MF1',
     3               'TE1','MF1','TE1','MF1','TE1','PW1'/

         IF (ver.lt.1.98) then
C---------> modify OCHECK - array            
            YCHECK(18)  = 'PW1'
         end if
         DATA OCHECK/'TE1','MF1','TE1','MF1','TE1','MF1','TE1','MF1',
     +               'TE1','MF1','TE1','MF1','TE1','MF1','TE1','MF1',
     +               'TE1','MF1','TE1','MF1','TE1','MF1','TE1','MF1',
     +               'TE1','MF1','TE1','MF1','PW1',
     +               'PW1','PW1','PW1','PW1','PW1','PW1','PW1','PW1',
     +               'PW1','PW1','PW1','PW1','PW1','PW1','PW1','PW1',
     +               'TE1','TE1','TE1','TE1','TE1','TE1','PW1',
     +               'PW1','PW1','EN1','EN1','PW1','TE1','DM1',
     +               'PW1','PW1','EN1','EN1','PW1','TE1','DM1',
     +               'PW1','PW1','EN1','EN1','PW1','TE1','DM1',
     +               'PW1','PW1','EN1','EN1','PW1','TE1','DM1',
     +               'EN1','EN1','TE1',
     +               'EN1','EN1',200*'TE1'/

         IF (ver.lt.1.98) then
C---------> modify OCHECK - array
            OCHECK(17)  =  'PW1'
            OCHECK(18)  =  'PW1'
            OCHECK(19)  =  'PW1'
            OCHECK(20)  =  'PW1'
            OCHECK(21)  =  'PW1'
            OCHECK(22)  =  'PW1'
            OCHECK(23)  =  'PW1'
            OCHECK(24)  =  'PW1'
            OCHECK(25)  =  'PW1'
            OCHECK(26)  =  'PW1'
            OCHECK(27)  =  'PW1'
            OCHECK(28)  =  'PW1'
            OCHECK(29)  =  'TE1'
            OCHECK(30)  =  'TE1'
            OCHECK(31)  =  'TE1'
            OCHECK(32)  =  'TE1'
            OCHECK(33)  =  'TE1'
            OCHECK(34)  =  'TE1'
            OCHECK(35)  =  'PW1'
            OCHECK(36)  =  'PW1'
            OCHECK(37)  =  'PW1'
            OCHECK(38)  =  'EN1'
            OCHECK(39)  =  'PW1'
            OCHECK(40)  =  'TE1'
            OCHECK(41)  =  'PW1'
            OCHECK(42)  =  'PW1'
            OCHECK(43)  =  'EN1'
            OCHECK(44)  =  'PW1'
            OCHECK(45)  =  'TE1'
            OCHECK(46)  =  'PW1'
            OCHECK(47)  =  'PW1'
            OCHECK(48)  =  'EN1'
            OCHECK(49)  =  'PW1'
            OCHECK(50)  =  'TE1'
            OCHECK(51)  =  'EN1'
            OCHECK(52)  =  'TE1'
            OCHECK(53)  =  'EN1'
            OCHECK(54)  =  'TE1'
            OCHECK(55)  =  'TE1'
            OCHECK(56)  =  'TE1'
            OCHECK(57)  =  'TE1'
            OCHECK(58)  =  'TE1'
            OCHECK(59)  =  'TE1'
            OCHECK(60)  =  'TE1'
            OCHECK(61)  =  'TE1'
            OCHECK(62)  =  'TE1'
            OCHECK(63)  =  'TE1'
            OCHECK(64)  =  'TE1'
            OCHECK(65)  =  'TE1'
            OCHECK(66)  =  'TE1'
            OCHECK(67)  =  'TE1'
            OCHECK(68)  =  'TE1'
            OCHECK(69)  =  'TE1'
            OCHECK(70)  =  'TE1'
            OCHECK(71)  =  'TE1'
            OCHECK(72)  =  'TE1'
            OCHECK(73)  =  'TE1'
         end if

C       CALL THE RCHECK SUBROUTINE TO SET THE CORRECT INPUT AND OUTPUT TYPES FOR THIS COMPONENT
         CALL RCHECK(INFO,YCHECK,OCHECK)

C       SET THE NUMBER OF STORAGE SPOTS NEEDED FOR THIS COMPONENT
         NITEMS=50 + (26 * Nmax)
	   CALL SetStorageSize(NITEMS,INFO)

C       RETURN TO THE CALLING PROGRAM
         RETURN 1

      ENDIF

C    DO ALL OF THE INITIAL TIMESTEP MANIPULATIONS HERE - THERE ARE NO ITERATIONS AT THE INTIAL TIME
      IF (TIME.LT.(TIME0+DELT/2.D0)) THEN
C------> initial old mean storage-temperatures
         Tsmold1 = 1.d0
         Tsmold2 = 2.d0

C------> initial old hx massflows
         mh1old = 0.d0
         mh2old = 0.d0
         mh3old = 0.d0
         mh4old = 0.d0

C************************************************************************
C*    Initialisation at the first call of Type 340                      *
C************************************************************************
C------> reset execution time
         eth  = 0
         etm  = 0
         ets  = 0
         eths = 0

C------> reset sum of Qerr
         Qerrsum = 0.d0

C********** Initial necessary values
         IF (ver.lt.1.98) then
            Hs      =  PAR(1)
            Tini    =  PAR(7)
            UAsbot  =  PAR(8)
            UAstop  =  PAR(9)
            dz1     =  PAR(10)
            UAsa1   =  PAR(11)
            dz2     =  PAR(12)
            UAsa2   =  PAR(13)
            dz3     =  PAR(14)
            UAsa3   =  PAR(15)
            UAsa4   =  PAR(16)
            zd1i    =  PAR(17)
            zd1o    =  PAR(18)
            zd2i    =  PAR(20)
            zd2o    =  PAR(21)
            zd3i    =  PAR(23)
            zd3o    =  PAR(24)
            zd4i    =  PAR(26)
            zd4o    =  PAR(27)
            zd5i    =  PAR(29)
            zd5o    =  PAR(30)
            zh1i    =  PAR(44)
            zh1o    =  PAR(45)
            zh2i    =  PAR(55)
            zh2o    =  PAR(56)
            zh3i    =  PAR(66)
            zh3o    =  PAR(67)
            IF (fit.eq.1000.0) then
               Nmax = JFIX(PAR(81) * fit*10.d0)
            else
               Nmax = JFIX(PAR(81) * fit)  
            end if
C********** deactivate additional doubleports and heat exchangers
            zd6i    =  -1.d0
            zd6o    =  -1.d0
            zd7i    =  -1.d0
            zd7o    =  -1.d0
            zd8i    =  -1.d0
            zd8o    =  -1.d0
            zd9i    =  -1.d0
            zd9o    =  -1.d0
            zd10i   =  -1.d0
            zd10o   =  -1.d0
            zh4i    =  -1.d0
            zh4o    =  -1.d0
         else
            Hs      =  PAR(1)
            Tini    =  PAR(7)
            UAsbot  =  PAR(8)
            UAstop  =  PAR(9)
            dz1     =  PAR(10)
            UAsa1   =  PAR(11)
            dz2     =  PAR(12)
            UAsa2   =  PAR(13)
            dz3     =  PAR(14)
            UAsa3   =  PAR(15)
            UAsa4   =  PAR(16)
            zd1i    =  PAR(17)
            zd1o    =  PAR(18)
            zd2i    =  PAR(21)
            zd2o    =  PAR(22)
            zd3i    =  PAR(25)
            zd3o    =  PAR(26)
            zd4i    =  PAR(29)
            zd4o    =  PAR(30)
            zd5i    =  PAR(33)
            zd5o    =  PAR(34)
            zd6i    =  PAR(37)
            zd6o    =  PAR(38)
            zd7i    =  PAR(41)
            zd7o    =  PAR(42)
            zd8i    =  PAR(45)
            zd8o    =  PAR(46)
            zd9i    =  PAR(49)
            zd9o    =  PAR(50)
            zd10i   =  PAR(53)
            zd10o   =  PAR(54)
            zh1i    =  PAR(69)
            zh1o    =  PAR(70)
            sch1    =  NINT(PAR(79))
            smh1    =  PAR(80)
            zh2i    =  PAR(82)
            zh2o    =  PAR(83)
            sch2    =  NINT(PAR(92))
            smh2    =  PAR(93)
            zh3i    =  PAR(95)
            zh3o    =  PAR(96)
            sch3    =  NINT(PAR(105))
            smh3    =  PAR(106)
            zh4i    =  PAR(108)
            zh4o    =  PAR(109)
            sch4    =  NINT(PAR(118))
            smh4    =  PAR(119)

            IF (fit.eq.1000.0) then
               Nmax = NINT(PAR(125) * fit*10.d0)
            else
               Nmax = NINT(PAR(125) * fit)  
            end if
         end if

C************************************************************************
C*    Check if heat exchangers are operated in natural convection       *
C*    charging mode (schx = 2) the correspoding dp is already occupied  *
C************************************************************************
C------> first heatexchanger
         if (ABS(sch1).eq.2) then
            if ((zd7i.ne.-1.0).or.(zd7o.ne.-1.0)) then
C------------> check if double port 7 is used
               CALL MESSAGES(-1,'Heat exchanger 1 is operated in natural
     & convection mode (sch1=2 or -2). Hence in that case it is not llow
     &ed to use double port 7.','FATAL',IUNIT,ITYPE)
	         if (ErrorFound()) RETURN 1
            else
C------------> virtual use of douple port 7
               zd7i = zh1i  
               zd7o = zh1o  
            end if
         else
         end if
         
C------> second heatexchanger
         if (ABS(sch2).eq.2) then
            if ((zd8i.ne.-1.0).or.(zd8o.ne.-1.0)) then
C------------> check if double port 8 is used
               CALL MESSAGES(-1,'Heat exchanger 2 is operated in natural
     & convection mode (sch2=2 or -2). Hence in that case it is not allo
     &wed to use double port 8.','FATAL',IUNIT,ITYPE)
	         if (ErrorFound()) RETURN 1
            else
C------------> virtual use of douple port 8
               zd8i = zh2i  
               zd8o = zh2o  
            end if
         else
         end if

C------> third heatexchanger
         if (ABS(sch3).eq.2) then
            if ((zd9i.ne.-1.0).or.(zd9o.ne.-1.0)) then
C------------> check if double port 9 is used
               CALL MESSAGES(-1,'Heat exchanger 3 is operated in natural
     & convection mode (sch3=2 or -2). Hence in that case it is not allo
     &wed to use double port 9.','FATAL',IUNIT,ITYPE)
	         if (ErrorFound()) RETURN 1
            else
C------------> virtual use of douple port 9
               zd9i = zh3i  
               zd9o = zh3o  
            end if
         else
         end if

C------> fourth heatexchanger
         if (ABS(sch4).eq.2) then
            if ((zd10i.ne.-1.0).or.(zd10o.ne.-1.0)) then
C------------> check if double port 10 is used
               CALL MESSAGES(-1,'Heat exchanger 3 is operated in natural
     & convection mode (sch4=2 or -2). Hence in that case it is not allo
     &wed to use double port 10.','FATAL',IUNIT,ITYPE)
	         if (ErrorFound()) RETURN 1
            else
C------------> virtual use of douple port 10
               zd10i = zh4i  
               zd10o = zh4o  
            end if
         else
         end if

C************************************************************************
C*    Allocate the SYSINFO-array for heatexchangers and dp              *
C************************************************************************
C------> Set SYSINFO equal zero
         DO 1 j=1,18
            DO 2 i=1,Nmax
               SYSINFO(i,j) = 0
2           Continue
1        Continue

C------> first heatexchanger
         If (ABS(sch1).ne.2) Then
            CALL AL_SYSIN(maxN,Nmax,1,zh1i,zh1o,unit,SYSINFO)
	      If (ErrorFound()) RETURN 1
	   end if
C------> second heatexchanger
         If (ABS(sch2).ne.2) Then
            CALL AL_SYSIN(maxN,Nmax,2,zh2i,zh2o,unit,SYSINFO)
	      If (ErrorFound()) RETURN 1
	   End If
C------> third heatexchanger
         If (ABS(sch3).ne.2) Then
	      CALL AL_SYSIN(maxN,Nmax,3,zh3i,zh3o,unit,SYSINFO)
		  If (ErrorFound()) RETURN 1
	   End If
C------> fourth heatexchanger
         If (ABS(sch4).ne.2) Then
	      CALL AL_SYSIN(maxN,Nmax,4,zh4i,zh4o,unit,SYSINFO)
		  If (ErrorFound()) RETURN 1
	   End If
C------> first doubleport
         CALL AL_SYSIN(maxN,Nmax,5,zd1i,zd1o,unit,SYSINFO)
	   If (ErrorFound()) RETURN 1
C------> second doubleport
         CALL AL_SYSIN(maxN,Nmax,6,zd2i,zd2o,unit,SYSINFO)
	   If (ErrorFound()) RETURN 1
C------> third doubleport
         CALL AL_SYSIN(maxN,Nmax,7,zd3i,zd3o,unit,SYSINFO)
	   If (ErrorFound()) RETURN 1
C------> fourth doubleport
         CALL AL_SYSIN(maxN,Nmax,8,zd4i,zd4o,unit,SYSINFO)
	   If (ErrorFound()) RETURN 1
C------> fifth doubleport
         CALL AL_SYSIN(maxN,Nmax,9,zd5i,zd5o,unit,SYSINFO)
	   If (ErrorFound()) RETURN 1
C------> sixth doubleport
         CALL AL_SYSIN(maxN,Nmax,10,zd6i,zd6o,unit,SYSINFO)
	   If (ErrorFound()) RETURN 1
C------> seventh doubleport
         CALL AL_SYSIN(maxN,Nmax,11,zd7i,zd7o,unit,SYSINFO)
	   If (ErrorFound()) RETURN 1
C------> eight doubleport
         CALL AL_SYSIN(maxN,Nmax,12,zd8i,zd8o,unit,SYSINFO)
	   If (ErrorFound()) RETURN 1
C------> nine doubleport
         CALL AL_SYSIN(maxN,Nmax,13,zd9i,zd9o,unit,SYSINFO)
	   If (ErrorFound()) RETURN 1
C------> ten doubleport
         CALL AL_SYSIN(maxN,Nmax,14,zd10i,zd10o,unit,SYSINFO)
	   If (ErrorFound()) RETURN 1

C************************************************************************
C*    Check if heatexchanger 2 and hx. 3 are in the same node (zone)    *
C************************************************************************
         k = 0
         DO 35 i = 1,Nmax
           If (ABS(SYSINFO(i,2)).eq.1.and.ABS(SYSINFO(i,3)).eq.1) then
               k=1
               WRITE(iStr,*) i
	         Msg = 'Node '//TRIM(ADJUSTL(iStr))//' is occupied from he
     &at exchanger two and three'
               CALL MESSAGES(-1,Msg,'WARNING',IUNIT,ITYPE)
            end if
35       Continue

         IF (k.eq.1) THEN
           CALL MESSAGES(-1,'Node occupied by more than one heat exchang
     &er','FATAL',IUNIT,ITYPE)
	     If (ErrorFound()) RETURN 1
         ENDIF


C************************************************************************
C*    Check if heatexchanger 1 and hx. 4 are in the same node (zone)    *
C************************************************************************
         k = 0
         DO 37 i = 1,Nmax
           If (ABS(SYSINFO(i,1)).eq.1.and.ABS(SYSINFO(i,4)).eq.1) then
               k=1
               WRITE(iStr,*) i
	         Msg = 'Node '//TRIM(ADJUSTL(iStr))//' is occupied from he
     &at exchanger one and four'
               CALL MESSAGES(-1,Msg,'WARNING',IUNIT,ITYPE)
            end if
37       Continue

         IF (k.eq.1) THEN
           CALL MESSAGES(-1,'Node occupied by more than one heat exchang
     &er','FATAL',IUNIT,ITYPE)
	      If (ErrorFound()) RETURN 1
         ENDIF

         If (dz1.lt.0.) then
C************************************************************************
C*    Check if the heat loss capacity rate of the storage is specified  *
C*    in the correct way if it's used for the whole storage             *
C************************************************************************
            If (UAsbot.ne.0.or.UAstop.ne.0.or.dz2.ne.0.or.
     1         UAsa2.ne.0.or.dz3.ne.0.or.
     2         UAsa3.ne.0.or.UAsa4.ne.0) then
                  CALL MESSAGES(-1,'The heat loss capacity rate of the s
     &torage is specified wrong.','FATAL',IUNIT,ITYPE)
	            If (ErrorFound()) RETURN 1
               end if
C------------->Allocate only column 15 of the sysinfo array
               DO 3 i=1,Nmax
                  SYSINFO(i,15) = 1
3              Continue

         else
C************************************************************************
C*    Allocate the SYSINFO-array for the heat loss of the storage       *
C************************************************************************
C---------> Calculate nodes for constant zones of (UA)sa
            ndz1 = JFIX(DABS(dz1) * Nmax)
            ndz2 = JFIX(dz2 * Nmax)
            ndz3 = JFIX(dz3 * Nmax)
            ndz4 = Nmax-ndz1-ndz2-ndz3

            if (ndz4.lt.0) then
               CALL MESSAGES(-1,'dz5 is negative','FATAL',IUNIT,ITYPE)
	         If (ErrorFound()) RETURN 1
            end if

C---------> Allocate SYSINFO-array for zone 1
            if (ndz1.ge.1) then
               DO 4 i=1,ndz1
                  SYSINFO(i,15) = 1
4              Continue
            end if

C---------> Allocate SYSINFO-array for zone 2
            if (ndz2.ge.1) then
               DO 5 i=(ndz1+1),(ndz1+ndz2)
                  SYSINFO(i,16) = 1
5              Continue
            end if

C---------> Allocate SYSINFO-array for zone 3
            if (ndz3.ge.1) then
               DO 6 i=(ndz1+ndz2+1),(ndz1+ndz2+ndz3)
                  SYSINFO(i,17) = 1
6              Continue
            end if

C---------> Allocate SYSINFO-array for zone 4
            if (ndz4.ge.1) then
               DO 7 i=(ndz1+ndz2+ndz3+1),Nmax
                  SYSINFO(i,18) = 1
7              Continue
            end if

         end if


C************************************************************************
C*    Initial temperatures (storage and heatexchangers)                 *
C************************************************************************
         DO 10 i=1,Nmax
            Tnew(i,1) = ABS(SYSINFO(i,1)) * Tini
            Tnew(i,2) = Tini
            Tnew(i,3) = ABS(SYSINFO(i,2)) * Tini
            Tnew(i,3) = Tnew(i,3) + ABS(SYSINFO(i,3)) * Tini
            Tnew(i,1) = Tnew(i,1) + ABS(SYSINFO(i,4)) * Tini
10       Continue


C         IUNIT=INFO(1)

C************************************************************************
C*    Save the SYSINFO-ARRAY in the S-ARRAY                             *
C************************************************************************
         DO 20 j=1,18
            DO 21 i=1,Nmax
               STORED(50+((j-1)*Nmax)+i) = SYSINFO(i,j)
21          Continue
20       Continue

C************************************************************************
C*    Save the temperatures                                             *
C************************************************************************
        DO 8 j=1,3
            DO 9 i=1,Nmax
               STORED(50+((17+j)*Nmax)+i) = Tnew(i,j)
               STORED(50+((20+j)*Nmax)+i) = Tnew(i,j)
9           Continue
8        Continue
         CALL SetStorageVars(STORED,NITEMS,INFO)

         RETURN 1
      end if


C************************************************************************
C*                                                                      *
C*    This part is done by every TRNSYS-timestep                        *
C*                                                                      *
C************************************************************************
C****** Inputs
        IF (ver.lt.1.98) then
           Td1i    =  XIN(1)
           md1     =  XIN(2)
           Td2i    =  XIN(3)
           md2     =  XIN(4)
           Td3i    =  XIN(5)
           md3     =  XIN(6)
           Td4i    =  XIN(7)
           md4     =  XIN(8)
           Td5i    =  XIN(9)
           md5     =  XIN(10)
           Th1i    =  XIN(11)
           mh1     =  XIN(12)
           Th2i    =  XIN(13)
           mh2     =  XIN(14)
           Th3i    =  XIN(15)
           mh3     =  XIN(16)
           Tamb    =  XIN(17)
           Paux    =  XIN(18)
C********* reset not used inputs
           Td6i    =  0.d0
           md6     =  0.d0
           Td7i    =  0.d0
           md7     =  0.d0
           Td8i    =  0.d0
           md8     =  0.d0
           Td9i    =  0.d0
           md9     =  0.d0
           Td10i   =  0.d0
           md10    =  0.d0
           Th4i    =  0.d0
           mh4     =  0.d0
        else
           Td1i    =  XIN(1)
           md1     =  XIN(2)
           Td2i    =  XIN(3)
           md2     =  XIN(4)
           Td3i    =  XIN(5)
           md3     =  XIN(6)
           Td4i    =  XIN(7)
           md4     =  XIN(8)
           Td5i    =  XIN(9)
           md5     =  XIN(10)
           Td6i    =  XIN(11)
           md6     =  XIN(12)
           Td7i    =  XIN(13)
           md7     =  XIN(14)
           Td8i    =  XIN(15)
           md8     =  XIN(16)
           Td9i    =  XIN(17)
           md9     =  XIN(18)
           Td10i   =  XIN(19)
           md10    =  XIN(20)
           Th1i    =  XIN(21)
           mh1     =  XIN(22)
           Th2i    =  XIN(23)
           mh2     =  XIN(24)
           Th3i    =  XIN(25)
           mh3     =  XIN(26)
           Th4i    =  XIN(27)
           mh4     =  XIN(28)
           Tamb    =  XIN(29)
           Paux    =  XIN(30)
        end if

C****** Parameters
        IF (ver.lt.1.98) then
           Hs      =  PAR(1)
           Vs      =  PAR(2)
           cps     =  PAR(3)
           rhos    =  PAR(4)
           lacon   =  PAR(5)
C          lamix   =  PAR(6)
           lamix   =  0.d0
           Tini    =  PAR(7)
           UAsbot  =  PAR(8)
           UAstop  =  PAR(9)
           dz1     =  PAR(10)
           UAsa1   =  PAR(11)
           dz2     =  PAR(12)
           UAsa2   =  PAR(13)
           dz3     =  PAR(14)
           UAsa3   =  PAR(15)
           UAsa4   =  PAR(16)
           zd1i    =  PAR(17)
           zd1o    =  PAR(18)
           scd1    =  JFIX(PAR(19))
           zd2i    =  PAR(20)
           zd2o    =  PAR(21)
           scd2    =  JFIX(PAR(22))
           zd3i    =  PAR(23)
           zd3o    =  PAR(24)
           scd3    =  NINT(PAR(25))
           zd4i    =  PAR(26)
           zd4o    =  PAR(27)
           scd4    =  JFIX(PAR(28))
           zd5i    =  PAR(29)
           zd5o    =  PAR(30)
           scd5    =  JFIX(PAR(31))
           zs1     =  PAR(32)
           zs2     =  PAR(33)
           zs3     =  PAR(34)
           zs4     =  PAR(35)
           zs5     =  PAR(36)
           HMOD    =  JFIX(PAR(37))
           HTOP    =  JFIX(PAR(38))
           laux    =  PAR(39)
           zaux    =  PAR(40)
           ztaux   =  PAR(41)
           Tset    =  PAR(42)
           dTdb    =  PAR(43)
           zh1i    =  PAR(44)
           zh1o    =  PAR(45)
           Vh1     =  PAR(46)
           cph1    =  PAR(47)
           rhoh1   =  PAR(48)
           UAh1s   =  PAR(49) * fit
           bh11    =  PAR(50)
           bh12    =  PAR(51)
           bh13    =  PAR(52)
           UAh1a   =  PAR(53)
           sch1    =  JFIX(PAR(54))
           zh2i    =  PAR(55)
           zh2o    =  PAR(56)
           Vh2     =  PAR(57)
           cph2    =  PAR(58)
           rhoh2   =  PAR(59)
           UAh2s   =  PAR(60) * fit
           bh21    =  PAR(61)
           bh22    =  PAR(62)
           bh23    =  PAR(63)
           UAh2a   =  PAR(64)
           sch2    =  JFIX(PAR(65))
           zh3i    =  PAR(66)
           zh3o    =  PAR(67)
           Vh3     =  PAR(68)
           cph3    =  PAR(69)
           rhoh3   =  PAR(70)
           UAh3s   =  PAR(71) * fit
           bh31    =  PAR(72)
           bh32    =  PAR(73)
           bh33    =  PAR(74)
           UAh3a   =  PAR(75)
           sch3    =  JFIX(PAR(76))
           epstmp  =  PAR(77)
           epsua   =  PAR(78) / 100.0
           epsmix  =  PAR(79) / 100.0
           TDTSC   =  JFIX(PAR(80))
           IF (fit.eq.1000.0) then
              Nmax = JFIX(PAR(81) * fit*10.0)
           else
              Nmax = JFIX(PAR(81) * fit)  
           end if
c           sigma   =  PAR(82)
           sigma   =  0.50
C********* deactivate additional doubleports and heat exchangers
           zd6i    =  -1.d0
           zd6o    =  -1.d0
           zd7i    =  -1.d0
           zd7o    =  -1.d0
           zd8i    =  -1.d0
           zd8o    =  -1.d0
           zd9i    =  -1.d0
           zd9o    =  -1.d0
           zd10i   =  -1.d0
           zd10o   =  -1.d0           
           zh4i    =  -1.d0
           zh4o    =  -1.d0
           Vh4     =   0.d0          
           UAh4s   =   0.d0
           UAh4a   =   0.d0
           sch4    =   0.d0
           UAh4T   =   1.d0
           UAh4V   =  -1.0
        else
           Hs      =  PAR(1)
           Vs      =  PAR(2)
           cps     =  PAR(3)
           rhos    =  PAR(4)
           lacon   =  PAR(5)
C          lamix   =  PAR(6)
           lamix   =  0.d0
           Tini    =  PAR(7)
           UAsbot  =  PAR(8)
           UAstop  =  PAR(9)
           dz1     =  PAR(10)
           UAsa1   =  PAR(11)
           dz2     =  PAR(12)
           UAsa2   =  PAR(13)
           dz3     =  PAR(14)
           UAsa3   =  PAR(15)
           UAsa4   =  PAR(16)
           zd1i    =  PAR(17)
           zd1o    =  PAR(18)
           dd1     =  PAR(19)
           scd1    =  JFIX(PAR(20))
           zd2i    =  PAR(21)
           zd2o    =  PAR(22)
           dd2     =  PAR(23)
           scd2    =  JFIX(PAR(24))
           zd3i    =  PAR(25)
           zd3o    =  PAR(26)
           dd3     =  PAR(27)
           scd3    =  JFIX(PAR(28))
           zd4i    =  PAR(29)
           zd4o    =  PAR(30)
           dd4     =  PAR(31)
           scd4    =  JFIX(PAR(32))
           zd5i    =  PAR(33)
           zd5o    =  PAR(34)
           dd5     =  PAR(35)
           scd5    =  JFIX(PAR(36))
           zd6i    =  PAR(37)
           zd6o    =  PAR(38)
           dd6     =  PAR(39)
           scd6    =  JFIX(PAR(40))
           zd7i    =  PAR(41)
           zd7o    =  PAR(42)
           dd7     =  PAR(43)
           scd7    =  JFIX(PAR(44))
           zd8i    =  PAR(45)
           zd8o    =  PAR(46)
           dd8     =  PAR(47)
           scd8    =  JFIX(PAR(48))
           zd9i    =  PAR(49)
           zd9o    =  PAR(50)
           dd9     =  PAR(51)
           scd9    =  JFIX(PAR(52))
           zd10i   =  PAR(53)
           zd10o   =  PAR(54)
           dd10    =  PAR(55)
           scd10   =  JFIX(PAR(56))
           zs1     =  PAR(57)
           zs2     =  PAR(58)
           zs3     =  PAR(59)
           zs4     =  PAR(60)
           zs5     =  PAR(61)
           HMOD    =  JFIX(PAR(62))
           HTOP    =  JFIX(PAR(63))
           laux    =  PAR(64)
           zaux    =  PAR(65)
           ztaux   =  PAR(66)
           Tset    =  PAR(67)
           dTdb    =  PAR(68)
           zh1i    =  PAR(69)
           zh1o    =  PAR(70)
           Vh1     =  PAR(71)
           cph1    =  PAR(72)
           rhoh1   =  PAR(73)
           UAh1s   =  PAR(74) * fit
           bh11    =  PAR(75)
           bh12    =  PAR(76)
           bh13    =  PAR(77)
           UAh1a   =  PAR(78)
           sch1    =  JFIX(PAR(79))
           smh1    =  PAR(80)
           UAh1V   =  PAR(81)
           zh2i    =  PAR(82)
           zh2o    =  PAR(83)
           Vh2     =  PAR(84)
           cph2    =  PAR(85)
           rhoh2   =  PAR(86)
           UAh2s   =  PAR(87) * fit
           bh21    =  PAR(88)
           bh22    =  PAR(89)
           bh23    =  PAR(90)
           UAh2a   =  PAR(91)
           sch2    =  JFIX(PAR(92))
           smh2    =  PAR(93)
           UAh2V   =  PAR(94)
           zh3i    =  PAR(95)
           zh3o    =  PAR(96)
           Vh3     =  PAR(97)
           cph3    =  PAR(98)
           rhoh3   =  PAR(99)
           UAh3s   =  PAR(100) * fit
           bh31    =  PAR(101)
           bh32    =  PAR(102)
           bh33    =  PAR(103)
           UAh3a   =  PAR(104)
           sch3    =  JFIX(PAR(105))
           smh3    =  PAR(106)
           UAh3V   =  PAR(107)
           zh4i    =  PAR(108)
           zh4o    =  PAR(109)
           Vh4     =  PAR(110)
           cph4    =  PAR(111)
           rhoh4   =  PAR(112)
           UAh4s   =  PAR(113) * fit
           bh41    =  PAR(114)
           bh42    =  PAR(115)
           bh43    =  PAR(116)
           UAh4a   =  PAR(117)
           sch4    =  JFIX(PAR(118))
           smh4    =  PAR(119)
           UAh4V   =  PAR(120)
           epstmp  =  PAR(121)
           epsua   =  PAR(122) / 100.d0
           epsmix  =  PAR(123) / 100.d0
           TDTSC   =  JFIX(PAR(124))
           IF (fit.eq.1000.0) then
              Nmax = JFIX(PAR(125) * fit*10.d0)
           else
              Nmax = JFIX(PAR(125) * fit)  
           end if
c           sigma   =  PAR(126)
           sigma   =  0.5
        end if

C---> Reset not used values in order to avoid warning
      IF (dd1.ne.0) dd1   = 0.d0
      IF (dd2.ne.0) dd2   = 0.d0
      IF (dd3.ne.0) dd3   = 0.d0
      IF (dd4.ne.0) dd4   = 0.d0
      IF (dd5.ne.0) dd5   = 0.d0
      IF (dd6.ne.0) dd6   = 0.d0
      IF (dd7.ne.0) dd7   = 0.d0
      IF (dd8.ne.0) dd8   = 0.d0
      IF (dd9.ne.0) dd9   = 0.d0
      IF (dd10.ne.0) dd10 = 0.d0

C************************************************************************
C     Restore data form the old TRNSYS-timestep out of the S-ARRAY      *
C************************************************************************
	CALL GetStorageVars(STORED,NITEMS,INFO)
      Qerrsum = STORED(1)
      Tsmold1 = STORED(2)
      Tsmold2 = STORED(3)
      auxon   = JFIX(STORED(4))
      auxold  = JFIX(STORED(5))
      called  = JFIX(STORED(6))
      UAh1T   = STORED(7)
      UAh2T   = STORED(8)
      UAh3T   = STORED(9)
      UAh4T   = STORED(10)
      mh1old  = STORED(11)
      mh2old  = STORED(12)
      mh3old  = STORED(13)
      mh4old  = STORED(14)
      eth     = JFIX(STORED(15))   
      etm     = JFIX(STORED(16))   
      ets     = JFIX(STORED(17))   
      eths    = JFIX(STORED(18))   

C---> Restore the SYSINFO-ARRAY out of the S-ARRAY
      DO 30 j=1,18
         DO 31 i=1,Nmax
            SYSINFO(i,j) = JFIX(STORED(50+((j-1)*Nmax)+i))
31       Continue
30    Continue

                            
C************************************************************************
C     Change parameters if load side heat exchangers (LSH) are used     *
C************************************************************************
      IF (ver.lt.1.98) then
         IF (UAh1a.gt.0.0.and.UAh1a.lt.1.0) then
            UAh1V = UAh1a * 1000.d0
            UAh1a = 0.d0
         else
            UAh1T = 1.d0
            UAh1V = -1.d0
         end if
      
         IF (UAh2a.gt.0.0.and.UAh2a.lt.1.0) then
            UAh2V = UAh2a * 1000.d0
            UAh2a = 0.d0
         else
            UAh2T = 1.d0
            UAh2V = -1.d0
         end if
      
         IF (UAh3a.gt.0.0.and.UAh3a.lt.1.0) then
            UAh3V = UAh3a * 1000.d0
            UAh3a = 0.d0
         else
            UAh3T = 1.d0
            UAh3V = -1.d0
         end if
      else
         IF (UAh1V.le.0.0) then
            UAh1T = 1.d0
            UAh1V = -1.d0
         else
            UAh1V = UAh1V * 1000.d0
         end if
         IF (UAh2V.le.0.0) then
            UAh2T = 1.d0
            UAh2V = -1.d0
         else
            UAh2V = UAh2V * 1000.d0
         end if
         IF (UAh3V.le.0.0) then
            UAh3T = 1.d0
            UAh3V = -1.d0
         else
            UAh3V = UAh3V * 1000.d0
         end if
         IF (UAh4V.le.0.0) then
            UAh4T = 1.d0
            UAh4V = -1.d0
         else
            UAh4V = UAh4V * 1000.d0
         end if
      end if

C************************************************************************
C*    check if a hx is operated in natural convection mode              *
C************************************************************************
      if (ABS(sch1).eq.2.0.or.ABS(sch2).eq.2.0.or.ABS(sch3).eq.2.0
     1    .or.ABS(sch4).eq.2.0) then
         ncvhx = 1
      else
         ncvhx = 0
      end if

C************************************************************************
C*    Check if tank in tank option is used                              *
C************************************************************************
C------->reset Flag for Tank in Tank option 
         taita1 = 0
         taita2 = 0
         taita3 = 0
         taita4 = 0

C------->check for first heat exchanger     
         If (zh1i.ge.0.0.and.zh1o.ge.0.0) then
            If (Vh1.lt.0.0) then 
               taita1 = 1
               Vh1 = ABS(Vh1)
            else
            end if
         else
         end if

C------->check for second heat exchanger     
         If (zh2i.ge.0.0.and.zh2o.ge.0.0) then
            If (Vh2.lt.0.0) then 
               taita2 = 1
               Vh2 = ABS(Vh2)
            else
            end if
         else
         end if

C------->check for third heat exchanger     
         If (zh3i.ge.0.0.and.zh3o.ge.0.0) then
            If (Vh3.lt.0.0) then 
               taita3 = 1
               Vh3 = ABS(Vh3)
            else
            end if
         else
         end if

C------->check for fourth heat exchanger     
         If (zh4i.ge.0.0.and.zh4o.ge.0.0) then
            If (Vh4.lt.0.0) then 
               taita4 = 1
               Vh4 = ABS(Vh4)
            else
            end if
         else
         end if

C************************************************************************
C*    Check if all massflows are positive                               *
C************************************************************************
      If (md1.lt.0.or.md2.lt.0.or.md3.lt.0.or.md4.lt.0.or.md5.lt.0.or.
     1   md6.lt.0.or.md7.lt.0.or.md8.lt.0.or.md9.lt.0.or.
     2   md10.lt.0.or.mh1.lt.0.or.mh2.lt.0.or.mh3.lt.0.or.
     3   mh4.lt.0) then
         CALL MESSAGES(-1,'The input of negative massflows is not allowe
     &d!','FATAL',IUNIT,ITYPE)
	   If (ErrorFound()) RETURN 1
      else
      end if


C************************************************************************
C*  Store former massflow (if higher) (used for time dependen UA of hx) *
C************************************************************************
      If (mh1.ne.0) then    
         If (mh1.ge.STORED(20+22)) mh1old = STORED(20+22) 
      else
      end if
      If (mh2.ne.0) then
         If (mh2.ge.STORED(20+24)) mh2old = STORED(20+24) 
      else
      end if
      If (mh3.ne.0) then
         If (mh3.ge.STORED(20+26)) mh3old = STORED(20+26) 
      else
      end if

      If (mh4.ne.0) then
         If (mh4.ge.STORED(20+28)) mh4old = STORED(20+28) 
      else
      end if

C************************************************************************
C*    Check if inputs have changed since the last call of this type     *
C************************************************************************
      Ichange = 0

      DO 14 i=1,30
         IF(XIN(i).ne.STORED(20+i)) IChange = 1
C------->save to compare with the inputs of the next TRNSYS-timestep
         STORED(20+i) = XIN(i)
14    Continue

C************************************************************************
C*    Use of virtual dp's if hx is operated in natural convection mode  *
C*    and store heat transfer capacity rate in an other value           *
C************************************************************************
C------> first heatexchanger and double port 7
         if (ABS(sch1).eq.2) then
            zd7i = zh1i  
            zh1i = -1.0
            zd7o = zh1o
            zh1o = -1.0
            UAhx1 = UAh1s
            if (sch1.eq.2) then
               scd7 = 1.0
            else
               scd7 = -1.0
            end if
            sch1 = ABS(sch1)
         else
         end if

C------> second heatexchanger and double port 8
         if (ABS(sch2).eq.2) then
            zd8i = zh2i  
            zh2i = -1.0
            zd8o = zh2o
            zh2o = -1.0
            UAhx2 = UAh2s
            if (sch2.eq.2) then
               scd8 = 1.0
            else
               scd8 = -1.0
            end if
            sch2 = ABS(sch2)
         else
         end if

C------> third heatexchanger and double port 9
         if (ABS(sch3).eq.2) then
            zd9i = zh3i  
            zh3i = -1.0
            zd9o = zh3o
            zh3o = -1.0
            UAhx3 = UAh3s
            if (sch3.eq.2) then
               scd9 = 1.0
            else
               scd9 = -1.0
            end if
            sch3 = ABS(sch3)
         else
         end if

C------> fourth heatexchanger and double port 10
         if (ABS(sch4).eq.2) then
            zd10i = zh4i  
            zh4i = -1.0
            zd10o = zh4o
            zh4o = -1.0
            UAhx4 = UAh4s
            if (sch4.eq.2) then
               scd10 = 1.0
            else
               scd10 = -1.0
            end if
            sch4 = ABS(sch4)
         else
         end if

C************************************************************************
C*    Check if stratified charging is active                            *
C************************************************************************
      If (scd1.eq.1.or.scd2.eq.1.or.scd3.eq.1.or.scd4.eq.1.or.
     1    scd5.eq.1.or.scd6.eq.1.or.scd7.eq.1.or.scd8.eq.1.or.
     2    scd9.eq.1.or.scd10.eq.1.or.sch1.eq.1.or.sch2.eq.1.or.
     3    sch3.eq.1.or.sch4.eq.1.or.ncvhx.eq.1) then
         scharge = 1
      else
         scharge = 0
      end if


C************************************************************************
C*    Set DO,DU,DL,DR,DB,TINP,CAP,SOURCE equal zero and initial Told    *
C************************************************************************
      DO 12 j=1,3
         DO 13 i=1,Nmax
            DL(i,j) = 0.d0
            DR(i,j) = 0.d0
            DB(i,j) = 0.d0
            DF(i,j) = 0.d0
            CAP(i,j) = 1.d-30
            SOURCE(i,j) = 0.d0
            If (INFO(7).gt.0) then
              Told(i,j) = STORED(50+((17+j)*Nmax)+i)
              Tnew(i,j) = STORED(50+((17+j)*Nmax)+i)
            else
               Told(i,j) = STORED(50+((20+j)*Nmax)+i)
               Tnew(i,j) = STORED(50+((20+j)*Nmax)+i)
               STORED(50+((17+j)*Nmax)+i) = STORED(50+((20+j)*Nmax)+i)
            end if
13       Continue
12    Continue


C************************************************************************
C*    If case of natural convection charging mode, use inlet            *
C*    temperatures for the heat exchangers as inlet temperatures        *
C*    for the  virtual double ports for estimation of inlet positions   *
C*    in case of stratified charging                                    *
C************************************************************************
      If (sch1.eq.2) Td7i  = Th1i
      If (sch2.eq.2) Td8i  = Th2i
      If (sch3.eq.2) Td9i  = Th3i
      If (sch4.eq.2) Td10i = Th4i


C***********************************************************************
C*    Convert the relative input positions into input nodes             *
C************************************************************************
      CALL CONV74(maxN,Nmax,SYSINFO,Tnew,Told,scharge,FLOWINFO)
	If (ErrorFound()) RETURN 1

C************************************************************************
C*    Calculate how many nodes are occupied by each heatexchanger       *
C*    (also if virtual double ports are used (schx=2)                   *
C************************************************************************
      nh1 = 0
      nh2 = 0
      nh3 = 0
      nh4 = 0

      DO 11 i=1, Nmax
         IF (sch1.ne.2) then
            nh1 = nh1 + ABS(SYSINFO(i,1))
         else
            nh1 = nh1 + ABS(SYSINFO(i,11))
         end if
         IF (sch2.ne.2) then
            nh2 = nh2 + ABS(SYSINFO(i,2))
         else
            nh2 = nh2 + ABS(SYSINFO(i,12))
         end if
         IF (sch3.ne.2) then
            nh3 = nh3 + ABS(SYSINFO(i,3))
         else
            nh3 = nh3 + ABS(SYSINFO(i,13))
         end if
         IF (sch4.ne.2) then
            nh4 = nh4 + ABS(SYSINFO(i,4))
         else
            nh4 = nh4 + ABS(SYSINFO(i,14))
         end if

11    Continue



C************************************************************************
C*    calculate capacity flows through the dps and hxs                  *
C************************************************************************
      CPFD1  = md1 * cps
      CPFD2  = md2 * cps
      CPFD3  = md3 * cps
      CPFD4  = md4 * cps
      CPFD5  = md5 * cps
      CPFD6  = md6 * cps
      CPFD7  = md7 * cps
      CPFD8  = md8 * cps
      CPFD9  = md9 * cps
      CPFD10 = md10 * cps
      IF (sch1.ne.2) then
         CPFH1  = mh1 * cph1
      else
         CPFH1  = 0.d0
      end if
      IF (sch2.ne.2) then
         CPFH2  = mh2 * cph2
      else
         CPFH2  = 0.d0
      end if
      IF (sch3.ne.2) then
         CPFH3  = mh3 * cph3
      else
         CPFH3  = 0.d0
      end if
      IF (sch4.ne.2) then
         CPFH4  = mh4 * cph4
      else
         CPFH4  = 0.d0
      end if


C************************************************************************
C*    If case of natural convection charging mode, calculate            *
C*    outlet temperatures (used as inlet temperature into store)        *
C*    using the inlet positions for stratified charging (FLOWINFO)      *
C************************************************************************
      If (ncvhx.eq.1) then         
         CALL IN_VI_DP(maxN,Nmax,FLOWINFO,Told,rhelp,
     1                 rhelp,rhelp,rhelp)
	   If (ErrorFound()) RETURN 1
         Th1ood = Th1onw
         Th2ood = Th2onw
         Th3ood = Th3onw
         Th4ood = Th4onw        
      else
      end if
     

C************************************************************************
C*    Use this transformation only if TDTSC =0                          *
C*    Check which internal heatexchanger is not active                  *
C*    Note: Only existing heatexchangers can be not active              *
C*    Note: It's not allowed to use this method at the first time-      *
C*          steps because at that time the whole system has Tini        *
C*    Note: If hx is operated in natural convection charging            *
C*          mode (schx=2) it is considered as not active                *
C************************************************************************
      If (INFO(8).gt.7.and.TDTSC.eq.0) then
C------->first heatexchanger
         hx1na = 0
         If (nh1.gt.0.and.ABS(mh1).lt.epsall.and.UAh1a.eq.0.0) then
C----------->find the maximum temperature differece between
C            hx1 and storage
             rhilf = 0.0
             DO 32 i=1,Nmax
                If (ABS(SYSINFO(i,1)).eq.1) then
                   dtemp = ABS(Tnew(i,1)-Tnew(i,2))
                   If (dtemp.gt.rhilf) rhilf=dtemp
                else
                end if
32           Continue
             If (rhilf.lt.(epstmp*10.0)) hx1na = 1
         else
         end if

C------->second heatexchanger
         hx2na = 0
         If (nh2.gt.0.and.ABS(mh2).lt.epsall.and.UAh2a.eq.0.0) then
C----------->find the maximum temperature differece between
C            hx2 and storage
             rhilf = 0.0
             DO 33 i=1,Nmax
                If (ABS(SYSINFO(i,2)).eq.1) then
                   dtemp = ABS(Tnew(i,3)-Tnew(i,2))
                   If (dtemp.gt.rhilf) rhilf=dtemp
                else
                end if
33           Continue
             If (rhilf.lt.(epstmp*10.0)) hx2na = 1
         else
         end if

C------->third heatexchanger
         hx3na = 0
         If (nh3.gt.0.and.ABS(mh3).lt.epsall.and.UAh3a.eq.0.0) then
C----------->find the maximum temperature differece between
C            hx3 and storage
             rhilf = 0.0
             DO 36 i=1,Nmax
                If (ABS(SYSINFO(i,3)).eq.1) then
                   dtemp = ABS(Tnew(i,3)-Tnew(i,2))
                   If (dtemp.gt.rhilf) rhilf=dtemp
                else
                end if
36           Continue
             If (rhilf.lt.(epstmp*10.0)) hx3na = 1
         else
         end if
C------->fourth heatexchanger
         hx4na = 0
         If (nh4.gt.0.and.ABS(mh4).lt.epsall.and.UAh4a.eq.0.0) then
C----------->find the maximum temperature differece between
C            hx4 and storage
             rhilf = 0.0
             DO 34 i=1,Nmax
                If (ABS(SYSINFO(i,4)).eq.1) then
                   dtemp = ABS(Tnew(i,1)-Tnew(i,2))
                   If (dtemp.gt.rhilf) rhilf=dtemp
                else
                end if
34           Continue
             If (rhilf.lt.(epstmp*10.0)) hx4na = 1
         else
         end if
      else
         hx1na = 0
         hx2na = 0
         hx3na = 0
         hx4na = 0
      end if

C---->If hx is operated in natural convection charging
C     mode (schx=2) it is considered as not active 
      IF (sch1.eq.2) hx1na = 1
      IF (sch2.eq.2) hx2na = 1
      IF (sch3.eq.2) hx3na = 1
      IF (sch4.eq.2) hx4na = 1

C---->If the heatexchanger is not active UAhis can be set equal zero
      If (hx1na.eq.1) UAh1s = 1.d-30
      If (hx2na.eq.1) UAh2s = 1.d-30
      If (hx3na.eq.1) UAh3s = 1.d-30
      If (hx4na.eq.1) UAh4s = 1.d-30



C************************************************************************
C*    check if only the equations for the store have to be solved       *
C************************************************************************
      direct = 4
      if (nh1.gt.0.and.hx1na.eq.0) direct = 0
      if (nh2.gt.0.and.hx2na.eq.0) direct = 0
      if (nh3.gt.0.and.hx3na.eq.0) direct = 0
      if (nh4.gt.0.and.hx4na.eq.0) direct = 0


C************************************************************************
C*    check in which direction the equation system has to be solved     *
C************************************************************************
      If (direct.ne.4) then
C------->set default value upwards
         sodir = 1
C------->check for the heatexchangers
         If (zh1i.ge.0.0.and.zh1o.ge.0.0) then
            If (zh1i.ge.zh1o.and.mh1.gt.epsall) sodir = -1
         end if
         If (zh2i.ge.0.0.and.zh2o.ge.0.0) then
            If (zh2i.ge.zh2o.and.mh2.gt.epsall) sodir = -1
         end if
         If (zh3i.ge.0.0.and.zh3o.ge.0.0) then
            If (zh3i.ge.zh3o.and.mh3.gt.epsall) sodir = -1
         end if
         If (zh4i.ge.0.0.and.zh4o.ge.0.0) then
            If (zh4i.ge.zh4o.and.mh4.gt.epsall) sodir = -1
         end if

         If (sodir.eq.1) then
C---------->the doubleports with the maximum capacity flow is used
            rhelp = 0.0
            n = 1
            if (CPFD1.gt.rhelp) then
               rhelp = CPFD1
               n = 1
            else
            end if
            if (CPFD2.gt.rhelp) then
               rhelp = CPFD2
               n = 2
            else
            end if
            if (CPFD3.gt.rhelp) then
               rhelp = CPFD3
               n = 3
            else
            end if
            if (CPFD4.gt.rhelp) then
               rhelp = CPFD4
               n = 4
            else
            end if
            if (CPFD5.gt.rhelp) then
               rhelp = CPFD5
               n = 5
            else
            end if
            if (CPFD6.gt.rhelp) then
               rhelp = CPFD6
               n = 6
            else
            end if
            if (CPFD7.gt.rhelp) then
               rhelp = CPFD7
               n = 7
            else
            end if
            if (CPFD8.gt.rhelp) then
               rhelp = CPFD8
               n = 8
            else
            end if
            if (CPFD9.gt.rhelp) then
               rhelp = CPFD9
               n = 9
            else
            end if
            if (CPFD10.gt.rhelp) then
               rhelp = CPFD10
               n = 10
            else
            end if
            DO 16 i=1,Nmax
               IF (SYSINFO(i,n).eq.-1) sodir = -1
16          Continue
         else
         end if

      else
      end if


C************************************************************************
C*    check if a direct solution mode can be used                       *
C************************************************************************
      if (direct.ne.4) then
         if (CPFD1.gt.0.0.or.CPFD2.gt.0.0.or.CPFD3.gt.0.0.or.
     1       CPFD4.gt.0.0.or.CPFD5.gt.0.0.or.CPFD6.gt.0.0.or.
     2       CPFD7.gt.0.0.or.CPFD8.gt.0.0.or.CPFD9.gt.0.0.or.
     3       CPFD10.gt.0.0) then
            direct = 0
         else
            direct = 2
         end if
      else
      end if

C    check hx4

      if (direct.ne.4.and.direct.ne.0) then
         if (nh1.gt.0) then
            if (nh2.eq.0.and.nh3.eq.0.and.nh4.eq.0) then
               direct = 1
               if (zh1i.gt.zh1o) then
                  sodir = - 1
               else
                  sodir = 1
               end if
            else
               direct = 3
               If ((nh2.gt.0.and.zh2i.gt.zh2o).and.
     1             (nh3.gt.0.and.zh3i.gt.zh3o).and.
     2             (nh4.gt.0.and.zh4i.gt.zh4o).and.   
     3             (zh1i.gt.zh1o)) then
                  sodir = -1
               else if ((nh2.eq.0.and.nh4.eq.0.and.zh3i.gt.zh3o).and.
     1                  (zh1i.gt.zh1o)) then
                  sodir = -1
               else if ((nh3.eq.0.and.nh4.eq.0.and.zh2i.gt.zh2o).and.
     1                  (zh1i.gt.zh1o)) then
                  sodir = -1
               else if ((nh2.gt.0.and.zh2i.le.zh2o).and.
     1                  (nh3.gt.0.and.zh3i.le.zh3o).and.
     2                  (nh4.gt.0.and.zh4i.le.zh4o).and.
     3                  (zh1i.le.zh1o)) then
                  sodir = 1
               else if ((nh2.eq.0.and.nh4.eq.0.and.zh3i.le.zh3o).and.
     1                  (zh1i.le.zh1o)) then
                  sodir = 1
               else if ((nh3.eq.0.and.nh4.eq.0.and.zh2i.le.zh2o).and.
     1                  (zh1i.le.zh1o)) then
                  sodir = 1
               else
                  direct = 0
               end if
            end if
         else
            direct = 2
            If ((nh2.gt.0.and.zh2i.gt.zh2o).and.
     1          (nh3.gt.0.and.zh3i.gt.zh3o)) then
               sodir = -1
            else if (nh2.eq.0.and.zh3i.gt.zh3o) then
               sodir = -1
            else if (nh3.eq.0.and.zh2i.gt.zh2o) then
               sodir = -1
            else if ((nh2.gt.0.and.zh2i.le.zh2o).and.
     1          (nh3.gt.0.and.zh3i.le.zh3o)) then
               sodir = 1
            else if (nh2.eq.0.and.zh3i.le.zh3o) then
               sodir = 1
            else if (nh3.eq.0.and.zh2i.le.zh2o) then
               sodir = 1
            else
               direct = 0
            end if
         end if
         if (lamix.gt.0.0) direct = 0
         if (lacon.gt.0.0) direct = 0
      else
      end if


C************************************************************************
C*    Initial TINP(ut) matrix with the input temperatures               *
C************************************************************************
      CALL TINP_IN(maxN,Nmax,TINP)
	If (ErrorFound()) RETURN 1

      DO 711 j=1,3
         DO 712 i=1,Nmax
            if (tinp(i,j).ne.0) then
c            write(*,'(A,I3,A,I3,A,F7.3)')' Input-temperature of node ',
c     1               i,' / ',j, ' =  ', tinp(i,j)
            else
            end if
712      Continue
711   Continue
c      read(*,*)



C************************************************************************
C*    Initial CAP(acity) matrix for storage and heatexchangers          *
C************************************************************************
      CPWS  = Vs * cps * rhos
      CPWH1 = Vh1 * cph1 * rhoh1
      CPWH2 = Vh2 * cph2 * rhoh2
      CPWH3 = Vh3 * cph3 * rhoh3
      CPWH4 = Vh4 * cph4 * rhoh4

      DO 18 i=1,Nmax
         CAP(i,2) = CPWS/DBLE(Nmax)
         IF (SYSINFO(i,1).ne.0) then
            IF (hx1na.eq.0) then
               CAP(i,1)=ABS(SYSINFO(i,1))*CPWH1/DBLE(nh1)
            else
C------------->The capacity of the not active heatexchanger 1
C              has to be added to the storage
               CAP(i,2) = CAP(i,2)+ABS(SYSINFO(i,1))*CPWH1/DBLE(nh1)
            end if
C---------->Take into account tank in tank stores with hx 1
            IF (taita1.eq.1) then
               CAP(i,2) = CAP(i,2)-ABS(SYSINFO(i,1))*CPWH1/DBLE(nh1)
            else
            end if
         else                                     
C---------->Chech if instead dp 7 is used as virtual double port
            If (sch1.eq.2) then
               CAP(i,2) = CAP(i,2)+ABS(SYSINFO(i,11))*CPWH1/DBLE(nh1)
            else
            end if
         end if
         IF (SYSINFO(i,2).ne.0) then
            IF (hx2na.eq.0) then
               CAP(i,3)=ABS(SYSINFO(i,2))*CPWH2/DBLE(nh2)
            else
C------------->The capacity of the not active heatexchanger 2
C              has to be added to the storage
               CAP(i,2) = CAP(i,2)+ABS(SYSINFO(i,2))*CPWH2/DBLE(nh2)
            end if
C---------->Take into account tank in tank stores with hx 2
            IF (taita2.eq.1) then
               CAP(i,2) = CAP(i,2)-ABS(SYSINFO(i,2))*CPWH2/DBLE(nh2)
            else
            end if
         else
C---------->Chech if instead dp 8 is used as virtual double port
            If (sch2.eq.2) then
               CAP(i,2) = CAP(i,2)+ABS(SYSINFO(i,12))*CPWH2/DBLE(nh2)
            else
            end if
         end if

         IF (SYSINFO(i,3).ne.0) then
              IF (hx3na.eq.0) then
                 CAP(i,3)=ABS(SYSINFO(i,3))*CPWH3/DBLE(nh3)
            else
C------------->The capacity of the not active heatexchanger 3
C              has to be added to the storage
               CAP(i,2) = CAP(i,2)+ABS(SYSINFO(i,3))*CPWH3/DBLE(nh3)
            end if
C---------->Take into account tank in tank stores with hx 3
            IF (taita3.eq.1) then
               CAP(i,2) = CAP(i,2)-ABS(SYSINFO(i,3))*CPWH3/DBLE(nh3)
            else
            end if
         else
C---------->Chech if instead dp 9 is used as virtual double port
            If (sch3.eq.2) then
               CAP(i,2) = CAP(i,2)+ABS(SYSINFO(i,13))*CPWH3/DBLE(nh3)
            else
            end if
         end if

         IF (SYSINFO(i,4).ne.0) then
              IF (hx4na.eq.0) then
                 CAP(i,1)=ABS(SYSINFO(i,4))*CPWH4/DBLE(nh4)
            else
C------------->The capacity of the not active heatexchanger 4
C              has to be added to the storage
               CAP(i,2) = CAP(i,2)+ABS(SYSINFO(i,4))*CPWH4/DBLE(nh4)
            end if
C---------->Take into account tank in tank stores with hx 4
            IF (taita4.eq.1) then
               CAP(i,2) = CAP(i,2)-ABS(SYSINFO(i,4))*CPWH4/DBLE(nh4)
            else
            end if
         else
C---------->Chech if instead dp 10 is used as virtual double port
            If (sch4.eq.2) then
               CAP(i,2) = CAP(i,2)+ABS(SYSINFO(i,14))*CPWH4/DBLE(nh4)
            else
            end if
         end if
               
C----->  Check if CAP(acity) matrix for storage is negative     
         IF (CAP(i,2).lt.0.0) then
               WRITE(iStr,*) i
	         Msg = 'The Capacity of Store node No.: '//TRIM(ADJUSTL(iS
     &tr))//' is negative. Check if (negative) volume of heat exchanger 
     &is larger than the one of the store.'
               CALL MESSAGES(-1,Msg,'FATAL',IUNIT,ITYPE)
	         If (ErrorFound()) RETURN 1
         else
         end if

c       write(*,*)i,'  CAP-storage: ',cap(i,2),
c    1             '        CAP-hx3: ',cap(i,3)
18    Continue

c     read(*,*)

C************************************************************************
C*    Set the solution modus                                            *
C************************************************************************
      modus = 1
      IF (lamix.gt.1.0) modus = 2


C************************************************************************
C*    check if a heatexchager is active (charging the storage)          *
C************************************************************************
      hxactive = 0
C---->first heatexchanger
      If (mh1.gt.epsall) hxactive = 1
C---->second heatexchanger
      If (mh2.gt.epsall) hxactive = 1
C---->third heatexchanger
      If (mh3.gt.epsall) hxactive = 1
C---->fourth heatexchanger
      If (mh4.gt.epsall) hxactive = 1


C************************************************************************
C*    check if the use of variable UAhx,s is necessary                  *
C************************************************************************
      if (bh11.eq.0.and.bh12.eq.0.and.bh13.eq.0.and.UAh1V.lt.0.0.and.
     1    bh21.eq.0.and.bh22.eq.0.and.bh23.eq.0.and.UAh2V.lt.0.0.and. 
     2    bh31.eq.0.and.bh32.eq.0.and.bh33.eq.0.and.UAh3V.lt.0.0.and.
     3    bh41.eq.0.and.bh42.eq.0.and.bh43.eq.0.and.UAh4V.lt.0.0) then
         hxuavar = 0
      else
         hxuavar = 1
      end if


C************************************************************************
C check if a doubleport is active (charging or discharging the storage) *
C************************************************************************
      dpactive = 0
      IF (md1.gt.epsall.or.md2.gt.epsall.or.md3.gt.epsall
     1    .or.md4.gt.epsall.or.md5.gt.epsall.or.md6.gt.epsall
     2    .or.md7.gt.epsall.or.md8.gt.epsall.or.md9.gt.epsall
     3    .or.md10.gt.epsall) dpactive = 1


C************************************************************************
C*    Set dtmix                                                         *
C************************************************************************
c      If (nh1.gt.0) then
c         nin = NODE(Nmax,zh1i)
c         If (mh1.lt.epsall.or.Th1i.lt.Tnew(nin,2)) dtmix=0.0
c      else
c      end if
c      If (nh2.gt.0) then
c         nin = NODE(Nmax,zh2i)
c         If (mh2.lt.epsall.or.Th2i.lt.Tnew(nin,2)) dtmix=0.0
c      else
c      end if
c      If (nh3.gt.0) then
c         nin = NODE(Nmax,zh3i)
c         If (mh3.lt.epsall.or.Th3i.lt.Tnew(nin,2)) dtmix=0.0
c      else
c      end if


C************************************************************************
C*                                                                      *
C*    Initial differnce-koefficient-matrix DB                           *
C*                                                                      *
C************************************************************************
C************************************************************************
C*    If dz1 lower then zero UAsa1 is used for the whole storage        *
C************************************************************************
C---> Calculate the diameter of the storage
      dia = DSQRT (4.d0 * Vs/(PI*Hs))

      IF (dz1.lt.0.) then
C------> Calculate the surface of the bottom (same as top)
         bot = (PI * dia * dia)/4.d0
C------> Calculate mantle area of the storage
         mantle = (PI * dia * Hs)
C------> Calculate surface area of the storage
         area = mantle + bot + bot

C------> Calculate usual (UA)-spezification
C------> for the top of the storage
         UAstop = ((bot/area) * UAsa1)
C------> for the bottom of the storage it's the same as for the top
         UAsbot = UAstop
C------> for the mantle of the storage
         UAsa1 = UAsa1 - UAsbot - UAstop
C------> length for the first zone
         ndz1 = Nmax

      else
C************************************************************************
C*    Calculate nodes for constant zones of (UA)sa                      *
C************************************************************************
         ndz1 = JFIX(ABS(dz1) * Nmax)
         ndz2 = JFIX(dz2 * Nmax)
         ndz3 = JFIX(dz3 * Nmax)
         ndz4 = Nmax-ndz1-ndz2-ndz3

         if (ndz4.lt.0) then
            CALL MESSAGES(-1,'dz5 is negative.','FATAL',IUNIT,ITYPE)
	      If (ErrorFound()) RETURN 1
         else
         end if

      end if

C************************************************************************
C*    Initialisation of DB(i,2) (between storage and environment)       *
C************************************************************************
      DO 22 i=1,Nmax
C-------> zone 1
         if (ndz1.ge.1) then
            DB(i,2) = (SYSINFO(i,15)*(UAsa1/ndz1))
         else
         end if
C-------> zone 2
         if (ndz2.ge.1) then
            DB(i,2) = DB(i,2) + (SYSINFO(i,16)*(UAsa2/ndz2))
         else
         end if
C-------> zone 3
         if (ndz3.ge.1) then
            DB(i,2) = DB(i,2) + (SYSINFO(i,17)*(UAsa3/ndz3))
         else
         end if
C-------> zone 4
         if (ndz4.ge.1) then
            DB(i,2) = DB(i,2) + (SYSINFO(i,18)*(UAsa4/ndz4))
         else
         end if
22       Continue


C------> Initial DB for the bottom of the storage
         DB(1,2) = DB(1,2) + UAsbot
C------> Initial DB for the top of the storage
         DB(Nmax,2) = DB(Nmax,2) + UAstop


C************************************************************************
C*    Check if DB(i,2) is correct   (allowed:  epsall%)                 *
C************************************************************************
      UAwhole = ABS(UAsbot)+UAstop+UAsa1+UAsa2+UAsa3+UAsa4
      UAarea = 0
      
      DO 26 i=1,Nmax
         UAarea = UAarea + DB(i,2)
C         write (*,*)'Node: ',i,'     DB-storage: ',DB(i,2)
26    Continue

      if (UAwhole.ne.0.0) then
         epsis = ABS((UAarea-UAwhole)/UAwhole)
      else
        epsis = 0.0
      end if
      if (epsis.gt.epsall) then
          WRITE(iStr,*) epsis*100.0
	    Msg = 'The difference in UAsa is '//TRIM(ADJUSTL(iStr))//' %'
          CALL MESSAGES(-1,Msg,'WARNING',IUNIT,ITYPE)
      else
      end if



C************************************************************************
C*    Initialisation of DB(i,1) and DB(i,3) (between heatexchangers     *
C************************************************************************
      DO 27 i=1,Nmax
         IF (nh1.ne.0) DB(i,1) = ABS(SYSINFO(i,1)) * UAh1a/nh1
         If (nh2.ne.0) DB(i,3) = ABS(SYSINFO(i,2)) * UAh2a/nh2
         If (nh3.ne.0) then 
            DB(i,3) = DB(i,3) + (ABS(SYSINFO(i,3)) * UAh3a/nh3)
         else
         end if
         If (nh4.ne.0) then 
            DB(i,1) = DB(i,1) + (ABS(SYSINFO(i,4)) * UAh4a/nh4)
         else
         end if
27    Continue



C************************************************************************
C*                                                                      *
C*    Initial differnce-koefficient-matrix DU and DO with the           *
C*    capacity-flows caused by the massflows in the storage             *
C*    and in the heat exchangers                                        *
C*                                                                      *
C************************************************************************
C---->calculate tdcon to simulate thermal diffusivity in the storage
      tdcon = lacon * (dia*dia*PI/4.0)/(Hs/DBLE(Nmax))

      If (modus.eq.2) then
C------->calculate dmix for the difference-koefficients for mixing
         dmix = lamix * (dia*dia*PI/4.0)/(Hs/DBLE(Nmax))
      else
      end if

C---->initialisation by calling subroutine CALL DU_DO_IN
      if (scharge.eq.0) then
         CALL DU_DO_IN(maxN,Nmax,dtmix,Tnew,SYSINFO)
 	   If (ErrorFound()) RETURN 1
      else
         CALL DU_DO_IN(maxN,Nmax,dtmix,Tnew,FLOWINFO)
	   If (ErrorFound()) RETURN 1
      end if


C************************************************************************
C*                                                                      *
C*    Initial differnce-koefficient-matrix DF                           *
C*                                                                      *
C************************************************************************
      CALL DF_INIT(maxN,Nmax,DF)
	If (ErrorFound()) RETURN 1

C************************************************************************
C*                                                                      *
C*    Initial differnce-koefficient-matrix DL and DR                    *
C*                                                                      *
C************************************************************************


C************************************************************************
C*    First check if time constant for (UA)-value of heat exchangers    *
C*    is used and calculate it resp. update it if necessary             *
C************************************************************************
      If (UAh1V.ne.-1.0) then
C------> calculate time constant for first heat exchanger (1)             
         If (mh1.gt.0.0) then
            rhelp = mh1
         else
            rhelp = (-1.0) * mh1old     
         end if
         CALL UAHXT(rhelp,delt,NITS,UAh1V,UAh1T)
	   If (ErrorFound()) RETURN 1
      else 
      end if
      
      If (UAh2V.ne.-1.0) then
C------> calculate time constant for second heat exchanger (2)             
         If (mh2.gt.0.0) then
            rhelp = mh2
         else
            rhelp = (-1.0) * mh2old     
         end if
         CALL UAHXT(rhelp,delt,NITS,UAh2V,UAh2T)
	   If (ErrorFound()) RETURN 1
      else 
      end if

      If (UAh3V.ne.-1.0) then
C------> calculate time constant for third heat exchanger (3)             
         If (mh3.gt.0.0) then
            rhelp = mh3
         else
            rhelp = (-1.0) * mh3old     
         end if
         CALL UAHXT(rhelp,delt,NITS,UAh3V,UAh3T)
	   If (ErrorFound()) RETURN 1
      else 
      end if

      If (UAh4V.ne.-1.0) then
C------> calculate time constant for fourth heat exchanger (4)             
         If (mh4.gt.0.0) then
            rhelp = mh4
         else
            rhelp = (-1.0) * mh4old     
         end if
         CALL UAHXT(rhelp,delt,NITS,UAh4V,UAh4T)
	   If (ErrorFound()) RETURN 1
      else 
      end if

C---->Initial differnce-koefficient-matrix DL and DR                    
      
      CALL DL_DR_IN(maxN,Nmax,UAhxsm,epsua,SYSINFO,DL,DR,Tnew,update)
	If (ErrorFound()) RETURN 1

C************************************************************************
C*    Calculate DDSTAR = DO + DU + DR + DL + DB + DF and the biggest    *
C*    internal timestep that it is stable in explicit case (DTmin)      *
C************************************************************************
      CALL DD_DTMIN(maxN,Nmax,CAP,DU,DO,DR,DL,DB,DF,DDSTAR,DTmin)
	If (ErrorFound()) RETURN 1

C************************************************************************
C*************** Return if second call from TRNSYS **********************
C************************************************************************
      IF(INFO(8).EQ.3) RETURN 1


C************************************************************************
C*                                                                      *
C*                   START OF SIMULATION                                *
C*                                                                      *
C************************************************************************


C************************************************************************
C*    Calculate DTmod that the difference in Tsm between two timesteps  *
C*    is bigger than epstmp (in the SOLVER74)                           *
C************************************************************************
      IF (Ichange.eq.0.and.sigma.lt.0.51.and.
     1   (ABS(Tsmold1-Tsmold2)*Dtmin)/DELT.lt.epstmp) then
         DTminmod = 1
         IF (ABS(Tsmold1-Tsmold2).ne.0) then
            DTmod = DELT * epstmp*10.0 / ABS(Tsmold1-Tsmold2)
            If (DTmod.gt.200.0*DTmin) DTmin=200.0*DTmin
         else
            DTmin = 200.0 * DTmin
         end if
      else
         DTminmod = 0
      end if


C************************************************************************
C*                                                                      *
C*    Calculate new temperatures                                        *
C*                                                                      *
C************************************************************************
C---> Reset the sums
      DO 49 i=1,Nmax
         Tavr(i,1) = 0.d0
         Tavr(i,2) = 0.d0
         Tavr(i,3) = 0.d0
49    Continue

      Th1avr = 0.d0
      Th2avr = 0.d0
      Th3avr = 0.d0
      Th4avr = 0.d0
      dQint = 0.d0
      Qaux  = 0.d0
      Qls   = 0.d0
      Qlbot = 0.d0
      Qltop = 0.d0
      Qls1  = 0.d0
      Qls2  = 0.d0
      Qls3  = 0.d0
      Qls4  = 0.d0
      Qd1   = 0.d0
      Qd2   = 0.d0
      Qd3   = 0.d0
      Qd4   = 0.d0
      Qd5   = 0.d0
      Qd6   = 0.d0
      Qd7   = 0.d0
      Qd8   = 0.d0
      Qd9   = 0.d0
      Qd10  = 0.d0
      Qlh1  = 0.d0
      Qh1   = 0.d0
      Qh1s  = 0.d0
      Qlh2  = 0.d0
      Qh2   = 0.d0
      Qh2s  = 0.d0
      Qlh3  = 0.d0
      Qh3   = 0.d0
      Qh3s  = 0.d0
      Qlh4  = 0.d0
      Qh4   = 0.d0
      Qh4s  = 0.d0
      Ts1   = 0.d0
      Ts2   = 0.d0
      Ts3   = 0.d0
      Ts4   = 0.d0
      Ts5   = 0.d0
      Taux  = 0.d0
      Exs   = 0.d0
      Exws  = 0.d0
      Exh1  = 0.d0
      Exh2  = 0.d0
      Exh3  = 0.d0
      Exh4  = 0.d0


C************************************************************************
C*    Start of the loop with internal timesteps                         *
C************************************************************************

         ficc = 1

777   Continue

C************************************************************************
C*    Check if time constant for (UA)-value of heat exchangers          *
C*    is used and calculate it resp. update it if necessary             *
C*    Note: Already done for the first internal time step               *
C************************************************************************
      If (UAh1V.ne.-1.0.and.ficc.gt.1) then
C------> calculate time constant for first heat exchanger (1)             
         If (mh1.gt.0.0) then
            rhelp = mh1
         else
            rhelp = (-1.0) * mh1old     
         end if
         CALL UAHXT(rhelp,delt,NITS,UAh1V,UAh1T)
	   If (ErrorFound()) RETURN 1
      else 
      end if
      
      If (UAh2V.ne.-1.0.and.ficc.gt.1) then
C------> calculate time constant for second heat exchanger (2)             
         If (mh2.gt.0.0) then
            rhelp = mh2
         else
            rhelp = (-1.0) * mh2old     
         end if
         CALL UAHXT(rhelp,delt,NITS,UAh2V,UAh2T)
	   If (ErrorFound()) RETURN 1
      else 
      end if

      If (UAh3V.ne.-1.0.and.ficc.gt.1) then
C------> calculate time constant for third heat exchanger (3)             
         If (mh3.gt.0.0) then
            rhelp = mh3
         else
            rhelp = (-1.0) * mh3old     
         end if
         CALL UAHXT(rhelp,delt,NITS,UAh3V,UAh3T)
	   If (ErrorFound()) RETURN 1
      else 
      end if

      If (UAh4V.ne.-1.0.and.ficc.gt.1) then
C------> calculate time constant for fourth heat exchanger (4)             
         If (mh4.gt.0.0) then
            rhelp = mh4
         else
            rhelp = (-1.0) * mh4old     
         end if
         CALL UAHXT(rhelp,delt,NITS,UAh4V,UAh4T)
	   If (ErrorFound()) RETURN 1
      else 
      end if


C************************************************************************
C*    Check if there is inversion in the storage                        *
C************************************************************************
c      DO 71 i=1,Nmax-1
c         If (Tnew(i+1,2).lt.Tnew(i,2)) then
c            write(*,'(A,I2,A,F6.3,A,I2,A,F6.3,A)')
c     1      '!!! ERROR : Inversion in the storage at ',i,' (',
c     2      Tnew(i,2),') and ',i+1,' (',Tnew(i+1,2),') <ENTER>'
c            read(*,*)
c         else
c         end if
c71    Continue



            CALL CALCU_HX(maxN,Nmax,ficc,sigma,epstmp,epsua,epsmix,
     1                    SYSINFO,FLOWINFO,CAP,DDSTAR,SOURCE,DO,DU,
     2                    DL,DR,DB,DF,nh1,nh2,nh3,nh4,Told,Tinp,Tamb,
     3                    UAhxsm,modus,dtmix,time,DTmin,Dtminmod,
     4                    hxactive,dpactive,hxuavar,ncvhx,TDTSC,
     5                    Tnew,Tafter,DTint,DTisum)
	      If (ErrorFound()) RETURN 1
         ficc = 0


C************************************************************************
C*    Calculate the relative number of internal timesteps               *
C************************************************************************
      NITS = DTint/delt
c      write(*,*)'DTint: ',dtint,'  delt: ',delt,'  NITS: ',nits

C************************************************************************
C*       Sum up the power after every internal timestep                 *
C************************************************************************
         DO 80 i=1,Nmax
C---------> power lost by the storage
            Qls = Qls + (DB(i,2)*(Tamb - (sigma*Told(i,2))
     1                 + (sigma-1.)*Tnew(i,2)))*NITS
C---------> power lost through the first zone of the storage
            IF (SYSINFO(i,15).eq.1)
     1         Qls1 = Qls1 + (DB(i,2)*(Tamb - (sigma*Told(i,2))
     2                     + (sigma-1.)*Tnew(i,2)))*NITS
C---------> power lost through the second zone of the storage
            IF (SYSINFO(i,16).eq.1)
     1         Qls2 = Qls2 + (DB(i,2)*(Tamb - (sigma*Told(i,2))
     2                     + (sigma-1.)*Tnew(i,2)))*NITS
C---------> power lost through the third zone of the storage
            IF (SYSINFO(i,17).eq.1)
     1         Qls3 = Qls3 + (DB(i,2)*(Tamb - (sigma*Told(i,2))
     2                     + (sigma-1.)*Tnew(i,2)))*NITS
C---------> power lost through the fourth zone of the storage
            IF (SYSINFO(i,18).eq.1)
     1         Qls4 = Qls4 + (DB(i,2)*(Tamb - (sigma*Told(i,2))
     2                     + (sigma-1.)*Tnew(i,2)))*NITS

C---------> power lost by the first heatexchanger
            if (SYSINFO(i,1).ne.0)
     1      Qlh1 = Qlh1 + (DB(i,1)*(sigma*(Tamb-Told(i,1))
     2                 - (sigma-1.)*(Tamb-Tnew(i,1))))*NITS

C---------> power lost by the second heatexchanger
            if (SYSINFO(i,2).ne.0)
     1      Qlh2 = Qlh2 + (DB(i,3)*(sigma*(Tamb-Told(i,3))
     2                  - (sigma-1.)*(Tamb-Tnew(i,3))))*NITS
C---------> power lost by the third heatexchanger
            if (SYSINFO(i,3).ne.0)
     1      Qlh3 = Qlh3 + (DB(i,3)*(sigma*(Tamb-Told(i,3))
     2                  - (sigma-1.)*(Tamb-Tnew(i,3))))*NITS

C---------> power lost by the fourth heatexchanger
            if (SYSINFO(i,4).ne.0)
     1      Qlh4 = Qlh4 + (DB(i,1)*(sigma*(Tamb-Told(i,1))
     2                  - (sigma-1.)*(Tamb-Tnew(i,1))))*NITS

C---------> power transfered between the first hx and the storage
            if (SYSINFO(i,1).ne.0)
     1      Qh1s = Qh1s + (DL(i,2)*(sigma*(Told(i,1)-Told(i,2))
     2                  - (sigma-1.)*(Tnew(i,1)-Tnew(i,2))))*NITS

C---------> power transfered between the second hx and the storage
            if (SYSINFO(i,2).ne.0)
     1      Qh2s = Qh2s + (DR(i,2)*(sigma*(Told(i,3)-Told(i,2))
     2                  - (sigma-1.)*(Tnew(i,3)-Tnew(i,2))))*NITS

C---------> power transfered between the third hx and the storage
            if (SYSINFO(i,3).ne.0)
     1      Qh3s = Qh3s + (DR(i,2)*(sigma*(Told(i,3)-Told(i,2))
     2                  - (sigma-1.)*(Tnew(i,3)-Tnew(i,2))))*NITS

C---------> power transfered between the fourth hx and the storage
            if (SYSINFO(i,4).ne.0)
     1      Qh4s = Qh4s + (DL(i,2)*(sigma*(Told(i,1)-Told(i,2))
     2                  - (sigma-1.)*(Tnew(i,1)-Tnew(i,2))))*NITS

C---------> power from the auxiliary heater
            Qaux = Qaux + SOURCE(i,2)*NITS
C---------> power caused by changing the internal power
            DO 81 j=1,3
            dQint = dQint + (Cap(i,j)/dtint)*(Tnew(i,j)
     1                      - Told(i,j))*NITS
81          Continue
80       Continue


C------> calculate power lost through the bottom of storage
         Qlbot = Qlbot + (UAsbot*(Tamb - (sigma*Told(1,2))
     1                 + (sigma-1.)*(Tnew(1,2))))*NITS

C------> calculate power lost through the top of storage
         Qltop = Qltop + (UAstop*(Tamb - (sigma*Told(Nmax,2))
     1                 + (sigma-1.)*(Tnew(Nmax,2))))*NITS

C------> calculate actual power changed by the double ports (1...10)
         CALL DP_POWER(maxN,Nmax,Told,Tnew,sigma,Qd1a,Qd2a,
     1                 Qd3a,Qd4a,Qd5a,Qd6a,Qd7a,Qd8a,
     2                 Qd9a,Qd10a)
	   If (ErrorFound()) RETURN 1
         Qd1  = Qd1 + (Qd1a * NITS)
         Qd2  = Qd2 + (Qd2a * NITS)
         Qd3  = Qd3 + (Qd3a * NITS)
         Qd4  = Qd4 + (Qd4a * NITS)
         Qd5  = Qd5 + (Qd5a * NITS)
         Qd6  = Qd6 + (Qd6a * NITS)
         Qd7  = Qd7 + (Qd7a * NITS)
         Qd8  = Qd8 + (Qd8a * NITS)
         Qd9  = Qd9 + (Qd9a * NITS)
         Qd10 = Qd10 + (Qd10a * NITS)

C------> power through the first heatexchanger         
         no = NODE(Nmax,zh1o)         
         Qh1 = Qh1 + CPFH1*(Th1i - (sigma*Told(no,1))
     1             + (sigma-1.)*(Tnew(no,1)))*NITS
C------> power through the second heatexchanger 
         no = NODE(Nmax,zh2o)
         Qh2 = Qh2 + CPFH2*(Th2i - (sigma*Told(no,3))
     1             + (sigma-1.)*(Tnew(no,3)))*NITS
C------> power through the third heatexchanger
         no = NODE(Nmax,zh3o)
         Qh3 = Qh3 + CPFH3*(Th3i - (sigma*Told(no,3))
     1             + (sigma-1.)*(Tnew(no,3)))*NITS
C------> power through the fourth heatexchanger
         no = NODE(Nmax,zh4o)
         Qh4 = Qh4 + CPFH4*(Th4i - (sigma*Told(no,1))
     1             + (sigma-1.)*(Tnew(no,1)))*NITS


C************************************************************************
C*    Controll Output                                                   *
C************************************************************************
c      if (time.lt.-0.7) then
c         do 727 i = 1,Nmax
c            n = Nmax+1-i
c            write(*,'(I3,a,F10.3,a,F10.3,a,F10.3)')n,'     ',
c     1         Tnew(n,1),'       ',Tnew(n,2),'      Tafter: ',
c     2         Tafter(n)

c727       Continue
c
c         write(*,*)'TIME: ',time,'    DTmin: ',DTmin,
c     1             '    Qerrsum: ',Qerrsum
c         read(*,*)
c      else
c      end if


C************************************************************************
C*    Calculate sums of temperature Matrix during a Trnsys - timestep   *
C************************************************************************
         DO 54 i=1,Nmax
            Tavr(i,1) = Tavr(i,1)+((Told(i,1)+Tnew(i,1))*sigma)*NITS
            Tavr(i,2) = Tavr(i,2)+((Told(i,2)+Tnew(i,2))*sigma)*NITS
            Tavr(i,3) = Tavr(i,3)+((Told(i,3)+Tnew(i,3))*sigma)*NITS
54       Continue

         If (ncvhx.eq.1) then
            Th1avr = Th1avr +((sigma * Th1ood)
     1                      + ((1.0 - sigma) * Th1onw)) *NITS
            Th2avr = Th2avr +((sigma * Th2ood)
     1                      + ((1.0 - sigma) * Th2onw)) *NITS
            Th3avr = Th3avr +((sigma * Th3ood)
     1                      + ((1.0 - sigma) * Th3onw)) *NITS
            Th4avr = Th4avr +((sigma * Th4ood)
     1                      + ((1.0 - sigma) * Th4onw)) *NITS
          else
          end if

C************************************************************************
C*    Inversion in the storage is not allowed ---> use Tafter           *
C************************************************************************
C       The temperatures of the not active heatexchangers are           *
C           the same as the temperatures in the storage                 *
C************************************************************************
         DO 51 i=1,Nmax
            Tnew(i,2) = Tafter(i)
c old       If (hx1na.eq.1) Tnew(i,1) = ABS(SYSINFO(i,1))*Tnew(i,2)
            If (hx1na.eq.1.and.SYSINFO(i,1).ne.0) Tnew(i,1)=Tnew(i,2)
            If (hx2na.eq.1.and.SYSINFO(i,2).ne.0) Tnew(i,3)=Tnew(i,2)
            If (hx3na.eq.1.and.SYSINFO(i,3).ne.0) Tnew(i,3)=Tnew(i,2)
            If (hx4na.eq.1.and.SYSINFO(i,4).ne.0) Tnew(i,1)=Tnew(i,2)
51       Continue


C************************************************************************
C*    Cal. average sensor temp. after mixing during a Trnsys-timestep   *
C************************************************************************
C---> temperature sensor 1
      no = NODE(Nmax,zs1)
      Ts1 = Ts1 + ((Told(no,2)+Tnew(no,2))*sigma)*NITS
C---> temperature sensor 2
      no = NODE(Nmax,zs2)
      Ts2 = Ts2 + ((Told(no,2)+Tnew(no,2))*sigma)*NITS
C---> temperature sensor 3
      no = NODE(Nmax,zs3)
      Ts3 = Ts3 + ((Told(no,2)+Tnew(no,2))*sigma)*NITS
C---> temperature sensor 4
      no = NODE(Nmax,zs4)
      Ts4 = Ts4 + ((Told(no,2)+Tnew(no,2))*sigma)*NITS
C---> temperature sensor 5
      no = NODE(Nmax,zs5)
      Ts5 = Ts5 + ((Told(no,2)+Tnew(no,2))*sigma)*NITS

C---> temperature at the controller for the aux. heater
      no = NODE(Nmax,ztaux)
      Taux = Taux + ((Told(no,2)+Tnew(no,2))*sigma)*NITS


C************************************************************************
C*    Change:  Told <---> Tnew                                          *
C************************************************************************
         DO 52 j=1,3
            DO 53 i=1,Nmax
               Told(i,j) = Tnew(i,j)
53          Continue
52       Continue

C------->also hx outlet temperatures (only relevant for mode schx=2)
         Th1ood  = Th1onw
         Th2ood  = Th2onw
         Th3ood  = Th3onw
         Th4ood  = Th4onw

C************************************************************************
C*    If the end of the Trnsys-timestep is not reached                  *
C*    goto back to increase DTisum                                      *
C************************************************************************
c      write(*,*)'Time: ',time,'   Dtisum: ',dtisum,'   DTint: ',dtint
c      read(*,*)
      If (DTisum.lt.delt) goto 777
      If (DTisum-delt.gt.epsall) then
          CALL MESSAGES(-1,'Time is greater than in TRNSYS','WARNING',
     &IUNIT,ITYPE)
      else
      end if


C************************************************************************
C*    Controll Output                                                   *
C************************************************************************
c        write(*,*)'*********************************** Control ',
c     1            ' output ************************'

c      write(*,*)'node   hx1-temp           sto-temp   ',
c     1             '     hex2-temp           Tinp         '

c         do 727 i = 1,Nmax
c            n = Nmax+1-i
c            write(*,'(I3,a,F10.3,a,F10.3,a,F10.3,a,F10.3)')n,'     ',
c     1         Tnew(n,1),'      ',Tnew(n,2),' Tafter: ',
c     2         Tafter(n),'   DO2: ',DO(n,2)

c727       Continue

c         write(*,*)'TIME: ',time,'    DTmin: ',DTmin,
C     1             '    Qerrsum: ',Qerrsum
c         read(*,*)


C************************************************************************
C*    Calculate power via heat exchangers if they are used in the       *
C*    natural convection mode (schx=2) (with virtual double ports       *
C************************************************************************
      If (sch1.eq.2) then
         Qh1  = Qd7
         Qh1s = Qd7
         Qd7  = 0.d0
      else
      end if

      If (sch2.eq.2) then
         Qh2  = Qd8
         Qh2s = Qd8
         Qd8  = 0.d0
      else
      end if

      If (sch3.eq.2) then
         Qh3  = Qd9
         Qh3s = Qd9
         Qd9  = 0.d0
      else
      end if

      If (sch4.eq.2) then
         Qh4  = Qd10
         Qh4s = Qd10
         Qd10  = 0.d0
      else
      end if


C************************************************************************
C*    Calculate output data                                             *
C************************************************************************
C---> lost energy of the storage
C     Note: heat loss of bottom and top has to be subtracted
      IF (SYSINFO(1,15).eq.1)    Qls1 = Qls1 - Qlbot
      IF (SYSINFO(Nmax,15).eq.1) Qls1 = Qls1 - Qltop
      IF (SYSINFO(1,16).eq.1)    Qls2 = Qls2 - Qlbot
      IF (SYSINFO(Nmax,16).eq.1) Qls2 = Qls2 - Qltop
      IF (SYSINFO(1,17).eq.1)    Qls3 = Qls3 - Qlbot
      IF (SYSINFO(Nmax,17).eq.1) Qls3 = Qls3 - Qltop
      IF (SYSINFO(1,18).eq.1)    Qls4 = Qls4 - Qlbot
      IF (SYSINFO(Nmax,18).eq.1) Qls4 = Qls4 - Qltop

C---> temperatures
C---> first doubleport
      no = NODE(Nmax,zd1o)
      Td1o = Tavr(no,2)
C---> second doubleport
      no = NODE(Nmax,zd2o)
      Td2o = Tavr(no,2)
C---> third doubleport
      no = NODE(Nmax,zd3o)
      Td3o = Tavr(no,2)
C---> fourth doubleport
      no = NODE(Nmax,zd4o)
      Td4o = Tavr(no,2)
C---> fifth doubleport
      no = NODE(Nmax,zd5o)
      Td5o = Tavr(no,2)
C---> sixth doubleport
      no = NODE(Nmax,zd6o)
      Td6o = Tavr(no,2)
C---> seventh doubleport
      if (ABS(sch1).ne.2) then
         no = NODE(Nmax,zd7o)
         Td7o = Tavr(no,2)
      else
         Td7o = Td7i
      end if
C---> eight doubleport
      if (ABS(sch2).ne.2) then
         no = NODE(Nmax,zd8o)
         Td8o = Tavr(no,2)
      else
         Td8o = Td8i
      end if
C---> nine doubleport
      if (ABS(sch3).ne.2) then
         no = NODE(Nmax,zd9o)
         Td9o = Tavr(no,2)
      else
         Td9o = Td9i
      end if
C---> ten doubleport
      if (ABS(sch4).ne.2) then
         no = NODE(Nmax,zd10o)
         Td10o = Tavr(no,2)
      else
         Td10o = Td10i
      end if
C---> first heatexchanger
      if (sch1.eq.2) then
         if (mh1.gt.0.0) then
            Th1o = Th1i - Qh1/(mh1 * cph1)
         else
C---------> use outlet temperature of seventh double port
            no = NODE(Nmax,zd7o)
            Th1o = Tavr(no,2)
         end if
      else
         no = NODE(Nmax,zh1o)
         Th1o = Tavr(no,1)
      end if

C---> second heatexchanger
      if (sch2.eq.2) then
         if (mh2.gt.0.0) then
            Th2o = Th2i - Qh2/(mh2 * cph2)
         else
C---------> use outlet temperature of eight double port
            no = NODE(Nmax,zd8o)
            Th2o = Tavr(no,2)
         end if
      else
         no = NODE(Nmax,zh2o)
         Th2o = Tavr(no,3)
      end if
C---> third heatexchanger
      if (sch3.eq.2) then
         if (mh3.gt.0.0) then
            Th3o = Th3i - Qh3/(mh3 * cph3)
         else
C---------> use outlet temperature of nine double port
            no = NODE(Nmax,zd9o)
            Th3o = Tavr(no,2)
         end if
      else
         no = NODE(Nmax,zh3o)
         Th3o = Tavr(no,3)
      end if
C---> fourth heatexchanger
      if (sch4.eq.2) then
         if (mh4.gt.0.0) then
            Th4o = Th4i - Qh4/(mh4 * cph4)
         else
C---------> use outlet temperature of ten double port
            no = NODE(Nmax,zd10o)
            Th4o = Tavr(no,2)
         end if
      else
         no = NODE(Nmax,zh4o)
         Th4o = Tavr(no,1)
      end if


C---> mean temperature of the first heatexchanger
      rhelp = 0.0
      If (nh1.gt.0) then
         DO 64 i=1, Nmax
            rhelp = rhelp + Tavr(i,1)*ABS(SYSINFO(i,1))
64       Continue
         Th1m = rhelp/nh1
         if (sch1.eq.2) Th1m = Th1o 
      else
         Th1m = 0.0
      end if

C---> mean temperature of the second heatexchanger
      rhelp = 0.0
      If (nh2.gt.0) then
         DO 65 i=1, Nmax
            rhelp = rhelp + Tavr(i,3)*ABS(SYSINFO(i,2))
65       Continue
         Th2m = rhelp/nh2
         if (sch2.eq.2) Th2m = Th2o 
      else
         Th2m = 0.0
      end if

C---> mean temperature of the third heatexchanger
      rhelp = 0.0
      If (nh3.gt.0) then
         DO 66 i=1, Nmax
            rhelp = rhelp + Tavr(i,3)*ABS(SYSINFO(i,3))
66       Continue
         Th3m = rhelp/nh3
         if (sch3.eq.2) Th3m = Th3o 
      else
         Th3m = 0.0
      end if

C---> mean temperature of the fourth heatexchanger
      rhelp = 0.0
      If (nh4.gt.0) then
         DO 67 i=1, Nmax
            rhelp = rhelp + Tavr(i,1)*ABS(SYSINFO(i,4))
67       Continue
         Th4m = rhelp/nh4
         if (sch4.eq.2) Th4m = Th4o 
      else
         Th4m = 0.0
      end if

C---> mean temperature of the storage
      rhelp = 0.0
      DO 68 i=1, Nmax
            rhelp = rhelp + Tavr(i,2)
68    Continue
      Tsm = rhelp/Nmax



C************************************************************************
C*    Calculate the change of internal energy (reference is Tini)       *
C************************************************************************
C---> first heatexchanger
      dUh1 = (Th1m - Tini) * CPWH1
C---> second heatexchanger
      dUh2 = (Th2m - Tini) * CPWH2
C---> third heatexchanger
      dUh3 = (Th3m - Tini) * CPWH3
C---> fourth heatexchanger
      dUh4 = (Th4m - Tini) * CPWH4
C---> storage - tank
      dUs = (Tsm - Tini) * CPWS
C---> whole system (stoage - tank and heatexchangers)
      dUws = dUs + dUh1 + dUh2 + dUh3 + dUh4

      
C************************************************************************
C*    Calculate the exergy in the tank and in the heat exchangers       *
C*    related to the ambient temperature                                *
C************************************************************************

C------> first heatexchanger
         IF (nh1.gt.0) Then
	      CALL CALCU_EX(maxN,Nmax,1,Tnew,Tamb,CAP,SYSINFO,Exh1)
	      If (ErrorFound()) RETURN 1
	   End If
C------> second heatexchanger
         IF (nh2.gt.0) Then
	      CALL CALCU_EX(maxN,Nmax,2,Tnew,Tamb,CAP,SYSINFO,Exh2)
	      If (ErrorFound()) RETURN 1
	   End If
C------> third heatexchanger
         IF (nh3.gt.0) Then
	      CALL CALCU_EX(maxN,Nmax,3,Tnew,Tamb,CAP,SYSINFO,Exh3)
	      If (ErrorFound()) RETURN 1
	   End If
C------> fourth heatexchanger
         IF (nh4.gt.0) Then
	      CALL CALCU_EX(maxN,Nmax,4,Tnew,Tamb,CAP,SYSINFO,Exh4)
	      If (ErrorFound()) RETURN 1
	   End If
C------> tank
         CALL CALCU_EX(maxN,Nmax,0,Tnew,Tamb,CAP,SYSINFO,Exs)
	   If (ErrorFound()) RETURN 1
C------> whole system (store and heat exchangers)
         Exws = Exh1 + Exh2 + Exh3 + Exh4 + Exs


C************************************************************************
C*    Check power balance after one trnsys timestep                    *
C************************************************************************
      Qerr = (Qh1 + Qh2 + Qh3 + Qh4 + Qlh1 + Qlh2 + Qlh3 + Qlh4 + Qls
     1       + Qd1 + Qd2 + Qd3 + Qd4 + Qd5
     2       + Qd6 + Qd7 + Qd8 + Qd9 + Qd10
     3       + Qaux) - dQint


      Qerrsum = Qerrsum + Qerr*Delt

      Qall = (CPWH1+CPWH2+CPWH3+CPWH4+CPWS)/delt

      If (Qall.ne.0) then
         epsis = Qerr / Qall
      else
         epsis = 0
      end if

c      if (ABS(epsis).gt.epsall) then
      if (ABS(epsis).gt.0.05.and.ABS(Qerr).gt.1.0) then
          WRITE(iStr,*) epsis*100
	    Msg = 'Difference in Power balance is '//TRIM(ADJUSTL(iStr))//
     &' %'
          CALL MESSAGES(-1,Msg,'WARNING',IUNIT,ITYPE)
      else
      end if


C************************************************************************
C*    Check temperature limits in the storage                           *
C************************************************************************
      j = 2
      DO 83 i=1,Nmax
         if (Tavr(i,j).gt.100.0) then
            WRITE(iStr,*) i
            WRITE(jStr,*) j
            WRITE(tStr,*) Tavr(i,j)
	      Msg = 'Water in the store is steam at I: '//TRIM(ADJUSTL(iSt
     &r))//' J:'//TRIM(ADJUSTL(jStr))//' T:'//TRIM(ADJUSTL(tStr))//' '
C************************
C Modif Mickael ALBARIC *
C************************
C            CALL MESSAGES(-1,Msg,'WARNING',IUNIT,ITYPE)
C*****************************
C  Fin Modif Mickael ALBARIC *
C*****************************
         else if (Tavr(i,j).lt.0.0) then
            WRITE(iStr,*) i
            WRITE(jStr,*) j
            WRITE(tStr,*) Tavr(i,j)
	      Msg = 'Water in the store is ice at I: '//TRIM(ADJUSTL(iStr)
     &)//' J:'//TRIM(ADJUSTL(jStr))//' T:'//TRIM(ADJUSTL(tStr))//' '
            CALL MESSAGES(-1,Msg,'WARNING',IUNIT,ITYPE)
         end if
83    Continue


C************************************************************************
C*    Save the new temperatures                                         *
C************************************************************************
      DO 62 j=1,3
         DO 63 i=1,Nmax
            STORED(50+((20+j)*Nmax)+i) = Tnew(i,j)
63       Continue
62    Continue


C************************************************************************
C*    Allocate local variables to output array                          *
C************************************************************************
      IF (ver.lt.1.98) then
         OUT(1)  =  Td1o
         OUT(2)  =  md1
         OUT(3)  =  Td2o
         OUT(4)  =  md2
         OUT(5)  =  Td3o
         OUT(6)  =  md3
         OUT(7)  =  Td4o
         OUT(8)  =  md4
         OUT(9)  =  Td5o
         OUT(10) =  md5
         OUT(11) =  Th1o
         OUT(12) =  mh1
         OUT(13) =  Th2o
         OUT(14) =  mh2
         OUT(15) =  Th3o
         OUT(16) =  mh3
         OUT(17) =  Qls
         OUT(18) =  Qlbot
         OUT(19) =  Qltop
         OUT(20) =  Qls1
         OUT(21) =  Qls2
         OUT(22) =  Qls3
         OUT(23) =  Qls4
         OUT(24) =  Qd1
         OUT(25) =  Qd2
         OUT(26) =  Qd3
         OUT(27) =  Qd4
         OUT(28) =  Qd5
         OUT(29) =  Ts1
         OUT(30) =  Ts2
         OUT(31) =  Ts3
         OUT(32) =  Ts4
         OUT(33) =  Ts5
         OUT(34) =  Taux
         OUT(35) =  Qaux
         OUT(36) =  Qh1
         OUT(37) =  Qh1s
         OUT(38) =  dUh1
         OUT(39) =  Qlh1
         OUT(40) =  Th1m
         OUT(41) =  Qh2
         OUT(42) =  Qh2s
         OUT(43) =  dUh2
         OUT(44) =  Qlh2
         OUT(45) =  Th2m
         OUT(46) =  Qh3
         OUT(47) =  Qh3s
         OUT(48) =  dUh3
         OUT(49) =  Qlh3
         OUT(50) =  Th3m
         OUT(51) =  dUs
         OUT(52) =  Tsm
         OUT(53) =  dUws
         DO 90 i=1,Nmax
            OUT(53+i) = Tavr(i,2)
90       Continue      
      else
         OUT(1)  =  Td1o
         OUT(2)  =  md1
         OUT(3)  =  Td2o
         OUT(4)  =  md2
         OUT(5)  =  Td3o
         OUT(6)  =  md3
         OUT(7)  =  Td4o
         OUT(8)  =  md4
         OUT(9)  =  Td5o
         OUT(10) =  md5
         OUT(11) =  Td6o
         OUT(12) =  md6
         OUT(13) =  Td7o
         OUT(14) =  md7
         OUT(15) =  Td8o
         OUT(16) =  md8
         OUT(17) =  Td9o
         OUT(18) =  md9
         OUT(19) =  Td10o
         OUT(20) =  md10
         OUT(21) =  Th1o
         OUT(22) =  mh1
         OUT(23) =  Th2o
         OUT(24) =  mh2
         OUT(25) =  Th3o
         OUT(26) =  mh3
         OUT(27) =  Th4o
         OUT(28) =  mh4
         OUT(29) =  Qls
         OUT(30) =  Qlbot
         OUT(31) =  Qltop
         OUT(32) =  Qls1
         OUT(33) =  Qls2
         OUT(34) =  Qls3
         OUT(35) =  Qls4
         OUT(36) =  Qd1
         OUT(37) =  Qd2
         OUT(38) =  Qd3
         OUT(39) =  Qd4
         OUT(40) =  Qd5
         OUT(41) =  Qd6
         OUT(42) =  Qd7
         OUT(43) =  Qd8
         OUT(44) =  Qd9
         OUT(45) =  Qd10
         OUT(46) =  Ts1
         OUT(47) =  Ts2
         OUT(48) =  Ts3
         OUT(49) =  Ts4
         OUT(50) =  Ts5
         OUT(51) =  Taux
         OUT(52) =  Qaux
         OUT(53) =  Qh1
         OUT(54) =  Qh1s
         OUT(55) =  dUh1
         OUT(56) =  Exh1
         OUT(57) =  Qlh1
         OUT(58) =  Th1m
         OUT(59) =  0.0
         OUT(60) =  Qh2
         OUT(61) =  Qh2s
         OUT(62) =  dUh2
         OUT(63) =  Exh2
         OUT(64) =  Qlh2
         OUT(65) =  Th2m
         OUT(66) =  0.0
         OUT(67) =  Qh3
         OUT(68) =  Qh3s
         OUT(69) =  dUh3
         OUT(70) =  Exh3
         OUT(71) =  Qlh3
         OUT(72) =  Th3m
         OUT(73) =  0.0
         OUT(74) =  Qh4
         OUT(75) =  Qh4s
         OUT(76) =  dUh4
         OUT(77) =  Exh4
         OUT(78) =  Qlh4
         OUT(79) =  Th4m
         OUT(80) =  0.0
         OUT(81) =  dUs
         OUT(82) =  Exs
         OUT(83) =  Tsm
         OUT(84) =  dUws
         OUT(85) =  Exws
         DO 91 i=1,Nmax
            OUT(85+i) = Tavr(i,2)
91       Continue      
      end if  

C      OUT(40+Nmax) =  Qerrsum


C************************************************************************
C*    Direct data output in a File                                      *
C************************************************************************
         If (time.lt.-0.95) then

c            write(50,'(F10.7,A,F10.7,A,F10.7)')
c     1      time,'       ',Td1o,'       ',Th1o


c            write(50,'(F10.4)')(Tnew(i,2),i=1,Nmax)
            IF (time.gt.tfinal-delt) CLOSE(50)
         else
         end if


C************************************************************************
C     Save Tsmold1 and Tsmold2                                          *
C************************************************************************
      If (DTminmod.eq.1) then
         Tsmold2 = Tsm
      else
         Tsmold2 = Tsmold1
      end if
      Tsmold1 = Tsm

      
C************************************************************************
C     Get end time for the execution of Type 340                        *
C************************************************************************
c      call GETTIM(eeth,eetm,eets,eeths)
c      WRITE(*,'(8X,A,T40,I2,A,I2,A,I2,A,I2,A)')'End-Time:',
c     1            eeth,':',eetm,':',eets,'.',eeths,' CLOCK'


C************************************************************************
C     Sum up execution time of Type 340                                 *
C************************************************************************
c      eths = eths + eeths - esths
c      if (eths.lt.0) then
c         eths = eths + 100
c         ests = ests + 1
c      else if (eths.ge.100) then
c         eths = eths - 100
c         ests = ests - 1
c      end if

c      ets = ets + eets - ests
c      if (ets.lt.0) then
c         ets = ets + 60
c         estm = estm + 1
c      else if (ets.ge.60) then
c         ets = ets - 60
c         estm = estm - 1
c      end if

c      etm = etm + eetm - estm
c      if (etm.lt.0) then
c         etm = etm + 60
c         esth = esth + 1
c      else if (etm.ge.60) then
c         etm = etm - 60
c         esth = esth - 1
c      end if

c      eth = eth + eeth - esth
c      if (eth.lt.0) then
c         eth = eth + 24.
c       else
c       end if


C************************************************************************
C     Save data for the next TRNSYS-timestep in the S-ARRAY             *
C************************************************************************
      STORED(1) = Qerrsum
      STORED(2) = Tsmold1
      STORED(3) = Tsmold2
      STORED(4) = auxon
      STORED(5) = auxold
      STORED(6) = called
      STORED(7) = UAh1T
      STORED(8) = UAh2T
      STORED(9) = UAh3T
      STORED(10) = UAh4T
      STORED(11) = mh1old
      STORED(12) = mh2old
      STORED(13) = mh3old
      STORED(14) = mh4old
      STORED(15) = eth
      STORED(16) = etm  
      STORED(17) = ets
      STORED(18) = eths
	CALL SetStorageVars(STORED,NITEMS,INFO)

C************************************************************************
C     Check if end of simulation --> Print final info to output file    *
C************************************************************************
      IF (time.gt.tfinal-delt) then
         
         IF (ver.lt.1.98) then 
            WRITE(iStr,*) ver
	      Msg = 'V1.99 was used for emulation of version '//TRIM(ADJUS
     &TL(iStr))//' (or lower)'
            CALL MESSAGES(-1,Msg,'NOTICE',IUNIT,ITYPE)
         else   
         end if
         
         WRITE(iStr,*) Qerrsum
	   Msg = 'Qerrsum of V1.99E: '//TRIM(ADJUSTL(iStr))//' [kJ]'
         CALL MESSAGES(-1,Msg,'NOTICE',IUNIT,ITYPE)
         

         IF (fit.eq.1000.0) then
            CALL MESSAGES(-1,'Used in the fitting-mode. Following parame
     &ters have to be converted: UAhis = UAhis * 1000.0 Nmax  = Nmax * 1
     &0000.0','NOTICE',IUNIT,ITYPE)
         else
         end if
      
      else
      end if


      RETURN 1
      END
C************************************************************************
C*    Here it the end of the main part from Type 340                    *
C************************************************************************


C-----------------------------------------------------------------------

      SUBROUTINE CONV74(maxN,Nmax,SYSINFO,Tnew,Told,
     1                  scharge,FLOWINFO)
      use TrnsysFunctions
C-----Programmdescription---------------------------------------------C
C
C     converts the relative input positions into node positions
C     and if stratified charging is used, the real physical positions
C     are transformed to the correct position and the FLOWINFO-matrix
C     is initialised by the subroutine AF_FLOW
C
C---------------------------------------------------------------------C
C
C     Name:     H.Dr…k
C
C     Version:  17.12.1998                    Date: 07.02.1994
C
C               17.12.1998  Extention to 4 heat exchangers
C               07.11.1998  Extention to 10 double ports
C
C-----used variables--------------------------------------------------C
C
C      TO:      maxN              max. number of nodes in the storage
C                                 (only for dimension)
C               Nmax              number of nodes in the storage
C               SYSINFO           matrix with nodepositions of hx & dp
C               Tnew              new temperature matrix
C               scharge           Flag if stratified charging
C               FLOWINFO          matrix with nodes with massflow
C
C      BACK:    DP_N_INP          COMMON-Block
C               HX_N_INP          COMMON-Block
C
C----------------------------------------------------------------------C

      COMMON/DP_R_INP/zd1i,zd2i,zd3i,zd4i,zd5i,zd6i,zd7i,zd8i,zd9i,zd10i
      COMMON/HX_R_INP/zh1i,zh2i,zh3i,zh4i

      COMMON/DP_N_INP/nzd1i,nzd2i,nzd3i,nzd4i,nzd5i,
     1                nzd6i,nzd7i,nzd8i,nzd9i,nzd10i
      COMMON/HX_N_INP/nzh1i,nzh2i,nzh3i,nzh4i

      COMMON/DP_OUT/zd1o,zd2o,zd3o,zd4o,zd5o,zd6o,zd7o,zd8o,zd9o,zd10o
      COMMON/HX_OUT/zh1o,zh2o,zh3o,zh4o
      COMMON/S_CHARGE/scd1,scd2,scd3,scd4,scd5,scd6,scd7,scd8,
     1                scd9,scd10,sch1,sch2,sch3,sch4

      COMMON/DP_INP_T/Td1i,Td2i,Td3i,Td4i,Td5i,Td6i,Td7i,Td8i,Td9i,Td10i    
      COMMON/HX_INP_T/Th1i,Th2i,Th3i,Th4i

      INTEGER scd1,scd2,scd3,scd4,scd5,scd6,scd7,scd8,scd9,scd10
      INTEGER sch1,sch2,sch3,sch4
      INTEGER nzd1i,nzd2i,nzd3i,nzd4i,nzd5i,nzd6i,nzd7i,nzd8i
      INTEGER nzd9i,nzd10i,nzh1i,nzh2i,nzh3i,nzh4i
      INTEGER maxN,Nmax,scharge,i,NODE
      INTEGER SYSINFO(maxN,18), FLOWINFO(maxN,18)

      DOUBLE PRECISION zd1i,zd2i,zd3i,zd4i,zd5i,zd6i,zd7i,zd8i,zd9i
      DOUBLE PRECISION zd1o,zd2o,zd3o,zd4o,zd5o,zd6o,zd7o,zd8o,zd9o
      DOUBLE PRECISION zh1i,zh2i,zh3i,zh4i,zh1o,zh2o,zh3o,zh4o    
      DOUBLE PRECISION Td1i,Td2i,Td3i,Td4i,Td5i,Td6i,Td7i,Td8i,Td9i
      DOUBLE PRECISION Th1i,Th2i,Th3i,Th4i,zd10i,zd10o,Td10i
      DOUBLE PRECISION Tnew(maxN,3), Told(maxN,3)

C---->double ports
      nzd1i  = NODE(Nmax,zd1i)
      nzd2i  = NODE(Nmax,zd2i)
      nzd3i  = NODE(Nmax,zd3i)
      nzd4i  = NODE(Nmax,zd4i)
      nzd5i  = NODE(Nmax,zd5i)
      nzd6i  = NODE(Nmax,zd6i)
      nzd7i  = NODE(Nmax,zd7i)
      nzd8i  = NODE(Nmax,zd8i)
      nzd9i  = NODE(Nmax,zd9i)
      nzd10i = NODE(Nmax,zd10i)

C---->heat exchangers
      nzh1i = NODE(Nmax,zh1i)
      nzh2i = NODE(Nmax,zh2i)
      nzh3i = NODE(Nmax,zh3i)
      nzh4i = NODE(Nmax,zh4i)

   
C************************************************************************
C*    Allocate the FLOWINFO-array with nodes off massflow               *
C************************************************************************
      IF (scharge.eq.1) then

C------> Set FLOWINFO equal zero
         DO 1 j=1,18
            DO 2 i=1,Nmax
               FLOWINFO(i,j) = 0
2           Continue
1        Continue


C------> first heatexchanger
         CALL AL_FLOW(maxN,Nmax,SYSINFO,Tnew,Told,Th1i,sch1,1,nzh1i,
     1                zh1o,FLOWINFO)
	   If (ErrorFound()) RETURN
C------> second heatexchanger
         CALL AL_FLOW(maxN,Nmax,SYSINFO,Tnew,Told,Th2i,sch2,2,nzh2i,
     1                zh2o,FLOWINFO)
	   If (ErrorFound()) RETURN
C------> third heatexchanger
         CALL AL_FLOW(maxN,Nmax,SYSINFO,Tnew,Told,Th3i,sch3,3,nzh3i,
     1                zh3o,FLOWINFO)
	   If (ErrorFound()) RETURN
C------> fourth heatexchanger
         CALL AL_FLOW(maxN,Nmax,SYSINFO,Tnew,Told,Th4i,sch4,4,nzh4i,
     1                zh4o,FLOWINFO)
	   If (ErrorFound()) RETURN
C------> first doubleport
         CALL AL_FLOW(maxN,Nmax,SYSINFO,Tnew,Told,Td1i,scd1,5,nzd1i,
     1                zd1o,FLOWINFO)
	   If (ErrorFound()) RETURN
C------> second doubleport
         CALL AL_FLOW(maxN,Nmax,SYSINFO,Tnew,Told,Td2i,scd2,6,nzd2i,
     1                zd2o,FLOWINFO)
	   If (ErrorFound()) RETURN
C------> third doubleport
         CALL AL_FLOW(maxN,Nmax,SYSINFO,Tnew,Told,Td3i,scd3,7,nzd3i,
     1                zd3o,FLOWINFO)
	   If (ErrorFound()) RETURN
C------> fourth doubleport
         CALL AL_FLOW(maxN,Nmax,SYSINFO,Tnew,Told,Td4i,scd4,8,nzd4i,
     1                zd4o,FLOWINFO)
	   If (ErrorFound()) RETURN
C------> fifth doubleport
         CALL AL_FLOW(maxN,Nmax,SYSINFO,Tnew,Told,Td5i,scd5,9,nzd5i,
     1                zd5o,FLOWINFO)
	   If (ErrorFound()) RETURN
C------> sixth doubleport
         CALL AL_FLOW(maxN,Nmax,SYSINFO,Tnew,Told,Td6i,scd6,10,nzd6i,
     1                zd6o,FLOWINFO)
	   If (ErrorFound()) RETURN
C------> seventh doubleport
         CALL AL_FLOW(maxN,Nmax,SYSINFO,Tnew,Told,Td7i,scd7,11,nzd7i,
     1                zd7o,FLOWINFO)
	   If (ErrorFound()) RETURN
C------> eigth doubleport
         CALL AL_FLOW(maxN,Nmax,SYSINFO,Tnew,Told,Td8i,scd8,12,nzd8i,
     1                zd8o,FLOWINFO)
	   If (ErrorFound()) RETURN
C------> nine doubleport
         CALL AL_FLOW(maxN,Nmax,SYSINFO,Tnew,Told,Td9i,scd9,13,nzd9i,
     1                zd9o,FLOWINFO)
	   If (ErrorFound()) RETURN
C------> ten doubleport
         CALL AL_FLOW(maxN,Nmax,SYSINFO,Tnew,Told,Td10i,scd10,14,nzd10i,
     1                zd10o,FLOWINFO)
	   If (ErrorFound()) RETURN
      else
      end if


      RETURN
      END



C-----------------------------------------------------------------------

      SUBROUTINE AL_SYSIN(maxN,Nmax,col,zi,zo,unit,SYSINFO)

C-----Programmdescription---------------------------------------------C
C
C     This subroutine allocates the SYSINFO-matrix with
C     the positions of the doubleports and heatexchangers
C
C---------------------------------------------------------------------C
C
C     Name:     H.Dr…k
C
C     Version:  17.12.1998                    Date: 12.01.1994
C
C               17.12.1998  Extention to 4 heat exchangers
C               07.11.1998  Extention to 10 double ports
C
C-----used variables--------------------------------------------------C
C
C      TO:      maxN              max. number of nodes in the storage
C                                 (only for dimension)
C               Nmax              number of nodes in the storage
C               col               column of the SYSINFO-matrix
C               zi                inlet-position
C               zo                outlet-position
C               unit              Number of the TRNSYS unit
C
C      BACK:    SYSINFO           matrix with nodepositions of hx. & dp
C
C      ELSE:    nin               number of a input node
C               nout              number of a output node
C               dir               Flag for flow-direction
C                                 (1..upwards,-1...downwards)
C               i                 help-variable
C
C----------------------------------------------------------------------C
       
       INTEGER maxN,Nmax,col,nin,nout,dir,i,unit
       INTEGER SYSINFO(maxN,18)
	 CHARACTER*256 iStr, Msg

       DOUBLE PRECISION zi,zo


       if (zi.ge.0.and.zo.ge.0) then
           nin  = NODE(Nmax,zi)
           nout = NODE(Nmax,zo)
           if (nin.eq.nout) then
              if (col.lt.5) then
                 WRITE(iStr,*) col
	           Msg = 'For Heat Exchanger '//TRIM(ADJUSTL(iStr))//': Th
     &e inlet and outlet positions are in the same node.'
                 CALL MESSAGES(-1,Msg,'WARNING',IUNIT,ITYPE)
              else
                 WRITE(iStr,*) col-4
	           Msg = 'For Double Port '//TRIM(ADJUSTL(iStr))//': The i
     &nlet and outlet positions are in the same node.'
                 CALL MESSAGES(-1,Msg,'WARNING',IUNIT,ITYPE)
              end if
           else
           end if

           if (nin.lt.nout) then
               dir = 1
            else
               dir = -1
               ihelp = nin
               nin = nout
               nout = ihelp
            end if

            DO 3 i=nin,nout
               SYSINFO(i,col) = dir
3           Continue
         else
         end if

        RETURN
        END



C-----------------------------------------------------------------------

      SUBROUTINE AL_FLOW(maxN,Nmax,SYSINFO,Tnew,Told,Tin,
     1                   sc,col,nin,zo,FLOWINFO)
      use TrnsysFunctions
C-----Programmdescription---------------------------------------------C
C
C     If stratified charging is used this subroutine transforms
C     the physical input position to the corresponding position
C     and initialises the FLOWINFO-matrix
C
C     Note: It's olny necessary if stratified charging,
C           else it's similar to the SYSINFO matrix
C
C---------------------------------------------------------------------C
C
C     Name:     H.Dr…k
C
C     Version:  17.12.1998                    Date: 07.02.1994
C
C               17.12.1998  Extention to 4 heat exchangers
C               11.11.1998  stratified discharge implemented
C               07.11.1998  Extention to 10 double ports
C
C-----used variables--------------------------------------------------C
C
C      TO:      maxN              max. number of nodes in the storage
C                                 (only for dimension)
C               Nmax              number of nodes in the storage
C               SYSINFO           matrix with nodepositions of dp & hx
C               Tnew              new temperature matrix
C               Told              old temperature matrix
C               Tin               input temperature
C               sc                Flag if stratified charging (1..yes)
C               col               column of the FLOWINFO-matrix
C               nin               number of a inlet node
C               zo                outlet-position
C
C      BACK:    FLOWINFO          matrix with nodes of massflow
C               nout              number of a output node
C               dir               Flag for flow-direction
C                                 (1..upwards,-1...downwards)
C               nstart            start node
C               nend              end node
C               nstin             input node for stratified charging
C               charge            Flag if charging (1..yes)
C               i                 help-variable
C
C      COMMON:  unit              Number of the TRNSYS unit
C
C----------------------------------------------------------------------C

      COMMON/MP_INF/unit

      INTEGER maxN,Nmax,col,nin,nout,dir,nstart,nend,i,nstin,sc
      INTEGER unit
      INTEGER SYSINFO(maxN,18), FLOWINFO(maxN,18)
      CHARACTER*256 iStr,Msg

      DOUBLE PRECISION Tin,zo
      DOUBLE PRECISION Tnew(maxN,3),Told(maxN,3)


      nout = NODE(Nmax,zo)

C************************************************************************
C*    if stratified charging /discharging search the correct input node *
C************************************************************************
      if (sc.eq.1) then
C------->check if input is above the output then stratified discharging
         if (nin.lt.nout) then
            nstin = nin
            DO 8 i=nin,nout
               rhelp = (Tnew(i,2) + Told(i,2))/2.0
               if (rhelp.le.Tin) nstin = i
c              write(*,*)i,'  Tnew: ',Tnew(i,1),'   Tin: ',Tin
8           Continue
            nin = nstin
c           write(*,*)'Ready ----> nin: ',nstin
c           read(*,*)
         else
C------->stratified charging:  search the correct input node (upwards)
            nstin = nout
            DO 10 i=nout,nin
               rhelp = (Tnew(i,2) + Told(i,2))/2.0
               if (rhelp.le.Tin) nstin = i
c              write(*,*)i,'  Tnew: ',Tnew(i,1),'   Tin: ',Tin
10          Continue
            nin = nstin
c           write(*,*)'Ready ----> nin: ',nstin
c           read(*,*)        
         end if
      else
      end if





C************************************************************************
C*    Allocate the FLOWINFO-array with nodes off massflow               *
C************************************************************************
      if (nin.le.Nmax.and.nout.le.Nmax.and.nin.ne.nout) then
         if (nin.lt.nout) then
             dir = 1
             nstart = nin
             nend   = nout
          else
             dir = -1
             nstart = nout
             nend   = nin
          end if

          DO 30 i=nstart,nend
             If (ABS(SYSINFO(i,col)).ne.1) then
                 WRITE(iStr,*) i
	           Msg = 'Massflow without a double port or a heat exchang
     &er - col: '//TRIM(ADJUSTL(iStr))//'.'
                 CALL MESSAGES(-1,Msg,'FATAL',IUNIT,ITYPE)
	           If (ErrorFound()) RETURN
             else 
             end if
             
             FLOWINFO(i,col) = dir

30        Continue
       else
       end if



       RETURN
       END





C-----------------------------------------------------------------------
      Integer FUNCTION NODE(Nmax,z)
C     Function calculates the node of a relative storage position
C     Note: Node zero and negative do not exit!

      DOUBLE PRECISION z
      INTEGER Nmax

      NODE = (JFIX(Nmax*z)) + 1
      If (NODE.eq.0) NODE = 1
      IF (NODE.gt.Nmax) NODE = Nmax


      END


C-----------------------------------------------------------------------

      SUBROUTINE TINP_IN(maxN,Nmax,TINP)

C-----Programmdescription---------------------------------------------C
C
C     initialisation of the TINP-matrix
C     (matrix with the input temperatures)
C
C---------------------------------------------------------------------C
C
C     Name:     H.Dr…k
C
C     Version:  17.12.1998                    Date: 07.02.1994
C
C               17.12.1998  Extention to 4 heat exchangers
C               07.11.1998  Extention to 10 double ports
C
C-----used variables--------------------------------------------------C
C
C      TO:      maxN              max. number of nodes in the storage
C                                 (only for dimension)
C               Nmax              number of nodes in the storage
C
C      BACK:    TINP              matrix with nodepositions of hx & dp
C
C
C      ELSE:    mavr              average massfolw
C
C----------------------------------------------------------------------C


      COMMON/DP_N_INP/nzd1i,nzd2i,nzd3i,nzd4i,nzd5i,
     1                nzd6i,nzd7i,nzd8i,nzd9i,nzd10i
      COMMON/HX_N_INP/nzh1i,nzh2i,nzh3i,nzh4i

      COMMON/DP_MASSF/md1,md2,md3,md4,md5,md6,md7,md8,md9,md10     
      COMMON/DP_INP_T/Td1i,Td2i,Td3i,Td4i,Td5i,Td6i,Td7i,Td8i,Td9i,Td10i
      COMMON/HX_INP_T/Th1i,Th2i,Th3i,Th4i

      INTEGER nzd1i,nzd2i,nzd3i,nzd4i,nzd5i,nzd6i,nzd7i,nzd8i
      INTEGER nzd9i,nzd10i,nzh1i,nzh2i,nzh3i,nzh4i
      INTEGER maxN,Nmax,i,j

      DOUBLE PRECISION TINP(maxN,3)
      DOUBLE PRECISION md1,md2,md3,md4,md5,md6,md7,md8,md9,md10,mavr
      DOUBLE PRECISION Td1i,Td2i,Td3i,Td4i,Td5i,Td6i,Td7i,Td8i,Td9i
      DOUBLE PRECISION Th1i,Th2i,Th3i,Th4i,Td10i




C************************************************************************
C*    Reset TINP(ut) matrix                                             *
C************************************************************************
      DO 10 i=1,Nmax
         DO 20 j=1,3
            TINP(i,j) = 0.d0
20       Continue
10    Continue


C************************************************************************
C*    Initial TINP(ut) matrix with the input temperatures               *
C************************************************************************
C---> form the doubleports for the whole tank
C     Note: If there is more than one input in a node, the average
C           of the inputs has to be used
C           It's only necessary to initial the temperatures if there
C           is a massflow
      DO 30 i=1,Nmax
         mavr  = 0.d0
         rhelp = 0.d0
         If (md1.gt.0.and.nzd1i.eq.i) then
            mavr  = md1
            rhelp = Td1i * md1
         else
         end if
         If (md2.gt.0.and.nzd2i.eq.i) then
            mavr  = mavr + md2
            rhelp = rhelp + (Td2i*md2)
         else
         end if
         If (md3.gt.0.and.nzd3i.eq.i) then
            mavr  = mavr + md3
            rhelp = rhelp + (Td3i*md3)
         else
         end if
         If (md4.gt.0.and.nzd4i.eq.i) then
            mavr  = mavr + md4
            rhelp = rhelp + (Td4i*md4)
         else
         end if
         If (md5.gt.0.and.nzd5i.eq.i) then
             mavr  = mavr + md5
             rhelp = rhelp + (Td5i*md5)
         else
         end if
         If (md6.gt.0.and.nzd6i.eq.i) then
             mavr  = mavr + md6
             rhelp = rhelp + (Td6i*md6)
         else
         end if
         If (md7.gt.0.and.nzd7i.eq.i) then
             mavr  = mavr + md7
             rhelp = rhelp + (Td7i*md7)
         else
         end if
         If (md8.gt.0.and.nzd8i.eq.i) then
             mavr  = mavr + md8
             rhelp = rhelp + (Td8i*md8)
         else
         end if
         If (md9.gt.0.and.nzd9i.eq.i) then
             mavr  = mavr + md9
             rhelp = rhelp + (Td9i*md9)
         else
         end if
         If (md10.gt.0.and.nzd10i.eq.i) then
             mavr  = mavr + md10
             rhelp = rhelp + (Td10i*md10)
         else
         end if
         IF (mavr.gt.0) TINP(i,2) = rhelp/mavr
30    Continue


C---> first heatexchanger
      TINP(nzh1i,1) = Th1i
C---> second heatexchanger
      TINP(nzh2i,3) = Th2i
C---> third heatexchanger
      TINP(nzh3i,3) = Th3i
C---> fourth heatexchanger
      TINP(nzh4i,1) = Th4i


      RETURN
      END

C-----------------------------------------------------------------------

      SUBROUTINE DF_INIT(maxN,Nmax,DF)

C-----Programmdescription---------------------------------------------C
C
C     initialisation of the DF-matrix
C     (matrix with the capacity-flows into the system)
C
C---------------------------------------------------------------------C
C
C     Name:     H.Dr…k
C
C     Version:  17.12.1998                    Date: 07.02.1994
C
C               17.12.1998  Extention to 4 heat exchangers
C               07.11.1998  Extention to 10 double ports
C
C-----used variables--------------------------------------------------C
C
C      TO:      maxN              max. number of nodes in the storage
C                                 (only for dimension)
C               Nmax              number of nodes in the storage
C
C      BACK:    DF                matrix with difference koefficients
C
C
C----------------------------------------------------------------------C


      COMMON/DP_N_INP/nzd1i,nzd2i,nzd3i,nzd4i,nzd5i,
     1                nzd6i,nzd7i,nzd8i,nzd9i,nzd10i
      COMMON/DP_CPF/CPFD1,CPFD2,CPFD3,CPFD4,CPFD5,
     1              CPFD6,CPFD7,CPFD8,CPFD9,CPFD10

      COMMON/HX_N_INP/nzh1i,nzh2i,nzh3i,nzh4i
      COMMON/HX_CPF/CPFH1,CPFH2,CPFH3,CPFH4


      INTEGER maxN,Nmax,i
      INTEGER nzd1i,nzd2i,nzd3i,nzd4i,nzd5i,nzd6i,nzd7i,nzd8i
      INTEGER nzd9i,nzd10i,nzh1i,nzh2i,nzh3i,nzh4i

      DOUBLE PRECISION DF(maxN,3)
      DOUBLE PRECISION CPFD1,CPFD2,CPFD3,CPFD4,CPFD5,
     1     CPFD6,CPFD7,CPFD8,CPFD9,CPFD10,
     2     CPFH1,CPFH2,CPFH3,CPFH4


C************************************************************************
C*    Reset DF-matrix                                                   *
C************************************************************************
      DO 10 i=1,Nmax
         DO 20 j=1,3
            DF(i,j) = 0.d0
20       Continue
10    Continue


C************************************************************************
C*    Initial differnce-koefficient-matrix DF                           *
C************************************************************************
C---> storage
      DF(nzd1i,2)  = CPFD1
      DF(nzd2i,2)  =  DF(nzd2i,2) + CPFD2
      DF(nzd3i,2)  =  DF(nzd3i,2) + CPFD3
      DF(nzd4i,2)  =  DF(nzd4i,2) + CPFD4
      DF(nzd5i,2)  =  DF(nzd5i,2) + CPFD5
      DF(nzd6i,2)  =  DF(nzd6i,2) + CPFD6
      DF(nzd7i,2)  =  DF(nzd7i,2) + CPFD7
      DF(nzd8i,2)  =  DF(nzd8i,2) + CPFD8
      DF(nzd9i,2)  =  DF(nzd9i,2) + CPFD9
      DF(nzd10i,2) =  DF(nzd10i,2) + CPFD10

C---> first heatexchanger
      DF(nzh1i,1) = CPFH1
C---> second heatexchanger
      DF(nzh2i,3) = CPFH2
C---> third heatexchanger
      DF(nzh3i,3) = CPFH3
C---> fourth heatexchanger
      DF(nzh4i,1) = CPFH4


      RETURN
      END


C-----------------------------------------------------------------------

      SUBROUTINE HEATER(maxN,Nmax,Told,Tafter,epstmp,DTint,DTmin,
     1                  time,first,SOURCE,DTmax,update)

C-----Programmdescription---------------------------------------------C
C
C     This subroutine manages the auxiliary heater
C     (Initialisation or modification of the SOURCE-matrix,
C      and swiching it on and off)
C
C---------------------------------------------------------------------C
C
C     Name:     H.Dr…k
C
C     Version:  24.01.2002                    Date: 12.01.1994
C
C               24.01.2002  HD  auxon=0 if Paux=0.0           
C               08.12.1998  HD  boundary problem removed
C
C-----used variables--------------------------------------------------C
C
C      TO:      maxN              max. number of nodes in the storage
C                                 (only for dimension)
C               Nmax              number of nodes in the storage
C               Told              old temperature matrix
C               Tafter            new in the storage after mixing
C               epstmp            exactness for calculating the temp.
C               DTint             internal delta time
C               DTmin             delta_t thats stable in explicit case
C               time              Trnsys-time
C               first             Flag if first call in this internal
C                                 timestep (1..yes)
C
C      BACK:    SOURCE            SOURCE-matrix
C               DTmax             maximum delta time thats allowed
C               update            Flag if SOURCE-matrix has
C                                 changed (1..yes)
C
C      COMMON:  laux              length of the auxiliary heater
C    /A_HEATER/ zaux              relative position of aux. heater
C               ztaux             relative position of the controller
C                                 of the auxiliary heater
C               HMOD              auxiliary heater mode
C               HTOP              HTOP=1 if installed from the top
C               Hs                storage height
C               Paux              power of the auxiliary heater
C               Tset              set temp. of the controller
C               dTdb              dead band temp. difference
C                                 of the controller
C
C      ELSE:    auxon             Flag if aux. heater is active
C                                 (1..yes) (if HMOD=2)
C               auxold            auxon form the timestep before
C               naux              nodes in which the auxiliary heater
C                                 is installed (only if HTOP=1)
C               nzaux             nodes in which the auxiliary heater
C                                 is installed
C               nztaux            nodes in which the controler for the
C                                 auxiliary heater is installed
C               eps               real temp. difference
C               epsold            eps form the timestep before
C               called            Flag if this part has allready
C                                 been called (1..yes)
C               ntry              number of trys to find the
C                                 switching point
C               i                 help-variable
C               SOU_OLD           old SOURCE-matrix
C               Tauxold           old controller Temperature
C
C----------------------------------------------------------------------C

      COMMON/A_HEATER/laux,zaux,ztaux,HMOD,HTOP,Hs,Paux,Tset,dTdb
      COMMON/SAV_HEAT/auxon,auxold,called

      INTEGER maxN,Nmax,i,naux,nzaux,nztaux,HMOD,HTOP
      INTEGER auxon,auxold,update,called,ntry,first

      DOUBLE PRECISION laux,zaux,ztaux,Hs,Paux,Tset,dTdb,DTmax,epstmp
      DOUBLE PRECISION eps,DTint,DTmin,time,epsold,Tauxold
      DOUBLE PRECISION SOURCE(maxN,3),Tafter(maxN),Told(maxN,3)
      DOUBLE PRECISION SOU_OLD(200)
	CHARACTER*256 iStr,Msg

      SAVE ntry,Tauxold


C---->if it is the first call in this internal timestep reset nrty
      if (first.eq.1) ntry = 0

C---->find the node of the controller
      nztaux = NODE(Nmax,ztaux)

      IF (HMOD.eq.0) then
C------->if no auxiliary heater exists, it's switched off
         auxon = 0
      else
C------->else the old SOURCE-Matrix is saved
         DO 1 i=1,Nmax
            SOU_OLD(i) = SOURCE(i,2)
1        Continue
C------->at the first call use Told for Tauxold
         if (first.eq.1) Tauxold = Told(nztaux,2)
      end if


      DTmax = 200.0 * DTmin

      If (HMOD.eq.2) then
C------> check if it has allready been called
         if (called.ne.1) then
            auxold=0
            goto 1111
         else
         end if
C------> check if the heater has been swiched
         If (auxold.ne.auxon) then
c            write(*,*)'I will use the new one!'
            auxold = auxon
            goto 7777
         else
         end if


1111     Continue

C------> CB: check if no power is available, then set auxon = 0 and skip
         If (Paux.eq.0.0) then
            auxon = 0
            goto 7777
         else
         end if

C************************************************************************
C*       the auxiliary heater is automaticly switched on                *
C************************************************************************
         eps = Tafter(nztaux) - Tset
         If (Tafter(nztaux).lt.(Tset+dTdb).and.auxold.eq.1) then
c            write(*,*)'The heater will stay on because',
c     1                '  eps = ',eps
            goto 7777
         else
         end if


         If (ABS(eps).lt.(10.0*epstmp).and.auxold.eq.0) then
c            write(*,*)'The heater will be swiched on, but it is ',
c     1                ' OK with eps = ',eps
            auxon=1
            goto 9999
         else
         end if


         If (Tafter(nztaux).lt.Tset.and.auxon.eq.0) then
C---------->try to find the switch-point to switch the heater on
c            write(*,*)'Something has changed, but I have to ',
c     1                'try again because eps = ',eps
            update = 1
            If (ntry.eq.0) then
c               write(*,*)'First try! eps = ',eps
               If (called.ne.1) then
                  auxon = 1
                  goto 7777
               else
               end if
            else
c               write(*,*)'This is try number ',ntry
               if (epsold.lt.ABS(eps).or.ntry.gt.5) then
                  WRITE(iStr,*) eps
	            Msg = 'Heater contr. temp. out of limit: '//TRIM(ADJUS
     &TL(iStr))//'.'
                  CALL MESSAGES(-1,Msg,'WARNING',IUNIT,ITYPE)
                  ntry = 0
                  auxon = 1
                  goto 7777
               else
               end if
            end if
            epsold = ABS(eps)
            If ((Tafter(nztaux)-Tauxold).ne.0) then
               DTmax = ABS((Tset-Tauxold)/(Tafter(nztaux)
     1                 - Tauxold)) * DTint
            else
               DTmax = 200.0 * DTmin
            end if

c            write(*,*)'I will try with DTmax = ',DTmax,
c     1                   '   DTint = ',DTint

            goto 7777
         else
         end if

C************************************************************************
C*       the auxiliary heater is automaticly switched off               *
C************************************************************************
         eps = Tafter(nztaux) - (Tset+dTdb)

         If (Tafter(nztaux).gt.Tset.and.auxold.eq.0) then
c            write(*,*)'The heater will stay off because',
c     1                '  eps = ',eps
            goto 9999
         else
         end if


         If (ABS(eps).lt.(10.0*epstmp).and.auxold.eq.1) then
c            write(*,*)'The heater will be swiched off, but it is ',
c     1                ' OK with eps = ',eps
            auxon=0
            goto 9999
         else
         end if


         If (Tafter(nztaux).gt.(Tset+dTdb).and.auxon.eq.1) then
C---------->try to find the switch-point to switch the heater off
c            write(*,*)'Something has changed, but I have to ',
c     1                'try again because eps = ',eps
            update=1
            If (ntry.eq.0) then
c               write(*,*)'First try! eps = ',eps
            else
c               write(*,*)'This is try number ',ntry
               if (epsold.lt.ABS(eps).or.ntry.gt.5) then
                  WRITE(iStr,*) eps
	            Msg = 'Heater contr. temp. out of limit: '//TRIM(ADJUS
     &TL(iStr))//'.'
                  CALL MESSAGES(-1,Msg,'WARNING',IUNIT,ITYPE)
                  auxon = 0
                  goto 9999
               else
               end if
            end if
            epsold = ABS(eps)
            If ((Tafter(nztaux)-Tauxold).ne.0) then
               DTmax = ABS((Tset+dTdb-Tauxold)/(Tafter(nztaux)
     1              - Tauxold)) * DTint
            else
               DTmax = 200.0 * DTmin
            end if

c            write(*,*)'I will try with DTmax = ',DTmax,
c     1                   '   DTint = ',DTint

            goto 9999
         else
         end if
c         write(*,*)'No posibility: '
c         read(*,*)
      else
      end if



7777  Continue
C************************************************************************
C*    Initialisation of the SOURCE-matrix                               *
C************************************************************************
      IF (auxon.eq.1.or.HMOD.eq.1) then
C------> Paux as varialbe input if HMOD=1

         If (HTOP.eq.1) then
C---------> the auxiliary heater is installed form the top
            NAUX = JFIX((laux/Hs)*Nmax)
c            write(*,*)'The auxiliary heater ist installed ',
c     1                'in the upper ',naux,' nodes'
c            read(*,*)
         else
            NAUX = 0
            nzaux = NODE(Nmax,zaux)
         end if

         if (HTOP.eq.1) then
            DO 15 i=(Nmax-Naux+1),Nmax
               SOURCE(i,2) = PAUX/DBLE(Naux)
15          Continue
         else
            SOURCE(nzaux,2) = Paux
         end if
      else if (auxon.eq.0) then
C------>auxiliary heater is now not active
c            DO 17 i=(Nmax-Naux+1),Nmax
            DO 17 i=1,Nmax
               SOURCE(i,2) = 0.0
17          Continue
      else
C------->auxiliary heater is not installed
      end if

      auxold = auxon

9999  Continue

      If (HMOD.gt.0) then
C------> check if SOURCE-Matrix has changed
         DO 21 i=1,Nmax
            IF (SOURCE(i,2).ne.SOU_OLD(i)) update=1
21       Continue
      else
      end if

      called = 1

      if (update.eq.1.and.first.ne.1) ntry = ntry + 1

      Tauxold = Tafter(nztaux)



      RETURN
      END


C-----------------------------------------------------------------------

      SUBROUTINE SOLVER74(maxN,Nmax,dt,sigma,epstmp,SYSINFO,CAP,
     1                    DDSTAR,SOURCE,DO,DU,DL,DR,DB,DF,TOLD,
     2                    Tinp,Tamb,Tnew)

C-----Programmdescription---------------------------------------------C
C
C      Iterative solution of linear equation systems
C
C      A 6-point difference-                  DO      - DB
C      star ist used                           I   -
C                                              I -
C                                      DL---- DD ----DR
C                                           -  I
C                                         -    I
C                                   DF -      DU
C
C
C       3 methods of solution are supported
C                        sigma = 0             : fully implicit
C                        sigma between 0 and 1 : Cranck-Nicolson
C                        sigma = 1             : fully explicit
C
c
C       Literature: CARNAHAN,LUTHER,WILKES
C                   APPLIED NUMERICAL METHODS, S.303
C                   JOHN WILEY & SONS, NEW YORK,1969
C                   (ITW-LIB A90)
C
C---------------------------------------------------------------------C
C
C     Name:     H.Dr…k
C
C     Version:  22.01.2002                    Date: 23.09.1993
C
C               22.01.2002 HD   problem of hx4 solved         
C               08.12.1998 HD   boundary problem solved
C
C-----used variables--------------------------------------------------C
C
C      TO:      maxN              max. number of nodes in the storage
C                                 (only for dimension)
C               Nmax              number of nodes in the storage
C               DT                timestep
C               sigma             parameter for solving method
C               epstmp            allowed difference between temperatures
C               SYSINFO           matrix with nodepositions of hx. & dp
C               CAP               capacity - Term (Rho * Cp * V)
C               DDSTAR            matrix of DO+DU+DR+DL
C               SOURCE            source-matrix
C               DO,DU,DR,DL,DB,DF difference-koefficients
C               Told              old temperature-matrix
C               Tinp              temperature matrix with input temp.
C               Tamb              ambient temperature
C
C      BACK:    Tnew              new temperature-matrix
C
C      COMMON:  hx1na             Flag if hx1 is not active (1..yes)
C               hx2na             Flag if hx2 is not active (1..yes)
C               hx3na             Flag if hx3 is not active (1..yes)
C
C               direct            kind of direct-solution method
C                                    0...non         2...hx2/hx3
C                                    1...hx1         3...hx1&hx2/hx3
C                                    4...store only
C               sodir             direction of solving the equation
C                                 system  (1..upwards / -1..downards)
C
C      ELSE:    kmax              maximum number of iterations
C               iter              number of iterations
C               BO                matrix with boundary values
C               errmax            error maximum
C               error             error
C               xstern            old Temperature of a node
C               RL                help variables
C               i,j                 dto
C               omega             parameter for relaxasation
C
C----------------------------------------------------------------------C
        
        COMMON/SOL_MET/direct,sodir

        COMMON/HXNOTACT/hx1na,hx2na,hx3na,hx4na

        COMMON/MP_INF/unit

        INTEGER maxN,Nmax,kmax,iter,i,j,flag
        INTEGER SYSINFO(maxN,18)
        INTEGER hx1na,hx2na,hx3na
        INTEGER direct,sodir,unit

        DOUBLE PRECISION dt,sigma,epstmp,Tamb,errmax,error,omega
        DOUBLE PRECISION CAP(maxN,3)
        DOUBLE PRECISION DDSTAR(maxN,3)
        DOUBLE PRECISION SOURCE(maxN,3)
        DOUBLE PRECISION DO(maxN,3),DU(maxN,3),DL(maxN,3)
        DOUBLE PRECISION DR(maxN,3),DB(maxN,3),DF(maxN,3)
        DOUBLE PRECISION Tinp(maxN,3)
        DOUBLE PRECISION Told(maxN,3),Tnew(maxN,3)
        DOUBLE PRECISION BO(200,3)
        DOUBLE PRECISION xstern,RL

C-----> Set maximum number of iterations in one timestep
        kmax = 700

C-----> Set omega
        omega = 1.d0


C**********************************************************************
C       change temperature-fields   Told ---> Tnew                   *
C**********************************************************************
        Do 1 j=1,3
            Do 2 i=1,Nmax
                 Tnew(i,j)=Told(i,j)
2           Continue
1       Continue


C**********************************************************************
C     If hx1 is working, then call GAUSS                              *
C**********************************************************************
      If (direct.eq.4) then
         CALL S_STORE(maxN,Nmax,dt,sigma,CAP,DDSTAR,SOURCE,DO,
     1                DU,DL,DR,DB,DF,TOLD,Tinp,Tamb,Tnew)
         RETURN
      else
      end if


C**********************************************************************
C      Calculate boundary vector                                      *
C**********************************************************************
       DO 10 i = 1,Nmax
          DO 11 j = 1,3
C------ --> It's not necessary to calculate nodes that are
C           not occupied by heatexchangers
            If (j.eq.1.and.(ABS(SYSINFO(i,1))
     1          + ABS(SYSINFO(i,4))).eq.0) GOTO 11
            IF (j.eq.3.and.(ABS(SYSINFO(i,2))
     1          + ABS(SYSINFO(i,3))).eq.0) GOTO 11
            if (i.eq.1.and.j.eq.1) then
               BO(i,j)=sigma*(
     1                  DR(i,j)*Told(i,j+1) + DO(i,j)*Told(i+1,j))
     2                + DB(i,j)*Tamb + DF(i,j)*Tinp(i,j)+SOURCE(i,j)
     3                + (CAP(i,j)/DT-sigma*DDSTAR(i,j))*Told(i,j)
            else if (j.eq.1) then
               BO(i,j)=sigma*(DU(i,j)*Told(i-1,j)
     1                + DR(i,j)*Told(i,j+1) + DO(i,j)*Told(i+1,j))
     2                + DB(i,j)*Tamb + DF(i,j)*Tinp(i,j)+SOURCE(i,j)
     3                + (CAP(i,j)/DT-sigma*DDSTAR(i,j))*Told(i,j)
            else if (i.eq.1.and.j.eq.3) then
               BO(i,j)=sigma*(
     1                   DL(i,j)*Told(i,j-1) + DO(i,j)*Told(i+1,j))
     2                 + DB(i,j)*Tamb + DF(i,j)*Tinp(i,j) + SOURCE(i,j)
     3                 + (CAP(i,j)/DT-sigma * DDSTAR(i,j))*Told(i,j)
            else if (j.eq.3) then
               BO(i,j)=sigma*(DU(i,j)*Told(i-1,j)
     1                 + DL(i,j)*Told(i,j-1) + DO(i,j)*Told(i+1,j))
     2                 + DB(i,j)*Tamb + DF(i,j)*Tinp(i,j) + SOURCE(i,j)
     3                 + (CAP(i,j)/DT-sigma * DDSTAR(i,j))*Told(i,j)
            else
               BO(i,j)=sigma*(DO(i,j)*Told(i+1,j)+DU(i,j)*Told(i-1,j)
     1                 + DL(i,j)*Told(i,j-1) + DR(i,j)*Told(i,j+1))
     2                 + (CAP(i,j)/DT-sigma*DDSTAR(i,j))*Told(i,j)
     3                 + SOURCE(i,j)+DB(i,j)*Tamb+DF(i,j)*Tinp(i,j)
            end if
11       Continue
10    Continue


C**********************************************************************
C     If possible, use a direct solution mehtod                       *
C**********************************************************************
      If (direct.gt.0.) then
         CALL S_DIRECT(maxN,Nmax,dt,sigma,sodir,SYSINFO,CAP,
     1                 DDSTAR,DO,DU,DL,DR,BO,Tnew)
         RETURN
      else
      end if


C**********************************************************************
C       ITERATIONS                                                    *
C**********************************************************************
        DO 7 ITER=1,KMAX

C-----> Initialisation           FLAG=1...konvergence
C                                FLAG=0...no konvergence
           FLAG=1
           errmax=0.
C--------> vertical loop
           DO 20 n=1,Nmax
              IF (sodir.eq.-1) then
                 i = Nmax+1-n
              else
                 i = n
              end if
C-----------> horizontal loop
              DO 21 j=1,3
C--------------> Its not necessary to calculate nodes that are
C                not occupied by heatexchangers
                 If (j.eq.1.and.(ABS(SYSINFO(i,1))
     1              + ABS(SYSINFO(i,4))).eq.0) GOTO 21
                 IF (j.eq.3.and.(ABS(SYSINFO(i,2))
     1              + ABS(SYSINFO(i,3))).eq.0) GOTO 21
ch                 IF ((j.eq.1.and.SYSINFO(i,1).eq.0).or.(j.eq.3.and.
ch     1           ABS(SYSINFO(i,2))+ABS(SYSINFO(i,3)).eq.0)) GOTO 21
C--------------> Its not necessary to calculate the nodes of
C                heatexchangers which are not active
c                 IF (j.eq.1.and.hx1na.eq.1) GOTO 21
c                 If (j.eq.3.and.hx2na.eq.1.and.
c     1               ABS(SYSINFO(i,2)).eq.0) GOTO 21
c                 If (j.eq.3.and.hx3na.eq.1.and.
c     1               ABS(SYSINFO(i,3)).eq.0) GOTO 21
C--------------> save old temperature for konvergenceproof
                 XSTERN=Tnew(I,J)
c                  write(*,*)i,j
                 if (j.eq.1) then
                    RL=(sigma-1.)*(DU(i,j)*Tnew(i-1,j)
     1                 + DR(i,j)*Tnew(i,j+1) + DO(i,j)*Tnew(i+1,j))

                 else if (j.eq.3) then
                    RL=(sigma-1.)*(DU(i,j)*Tnew(i-1,j)
     1                 + DL(i,j)*Tnew(i,j-1) + DO(i,j)*Tnew(i+1,j))

                 else
                    RL=(sigma-1.)*(DU(i,j)*Tnew(i-1,j)
     1                 + DL(i,j)*Tnew(i,j-1) + DR(i,j)*Tnew(i,j+1)
     2                 + DO(i,j)*Tnew(i+1,j))

                 end if


                 Tnew(I,J)=omega*(BO(i,j)-RL)/(((CAP(i,j)/DT)
     1            - (sigma-1.) * DDSTAR(i,j))) - (omega-1.0)*xstern
c                 write(*,*)'After calculation of Tnew: ',Tnew(i,j)


C**********************************************************************
C          Test if konvergence??                                      *
C          If konvergence (max. error < epstmp) then FLAG = 1         *
C**********************************************************************
                 error=ABS(XSTERN-Tnew(i,j))
                 IF (error.GT.errmax) then
                    errmax=error
c                    ai = i
c                    aj = j
                 else
                 end if
                 IF (errmax.GT.epstmp) THEN
                    FLAG=0
                 ELSE
                 END IF
C--------------->In the explicit case are no iterations necessary
                 if (sigma.eq.1.0) FLAG = 1
C--------------->two lines to speed up execution
c                 if (iter.ge.2.and.errmax.lt.0.05) FLAG=1
c                 if (errmax.lt.0.01) FLAG=1
21            CONTINUE
20         CONTINUE



C**********************************************************************
C          Output of the actual working situation                     *
C**********************************************************************
c             write (*,'(1h+,1x,A,I4,e12.4,1x,f4.2,5X,A,E12.6)')
c     1             'SOLVER74 (Itr/Err/sigm) : ',iter,Errmax,sigma,
c     2             'DT: ',DT
c             write(*,*)
c
C**********************************************************************
C          One more iteration, if FLAG = 0                            *
C**********************************************************************
           IF (FLAG.EQ.1) THEN
              goto 30
           ELSE
c           write(*,'(A,I3,A,I3,A,I3,A,E10.4)')'Iter: ',iter,
c     1        'i: ',ai,'   j: ',aj, '      errmax: ',errmax
           end if
7       CONTINUE

C**********************************************************************
C       No konvergence then  Warning!!                                *
C**********************************************************************

        CALL MESSAGES(-1,'No convergence in the internal solver',
     &'WARNING',IUNIT,ITYPE)

30      CONTINUE



        RETURN
        END

C-----------------------------------------------------------------------
      
      SUBROUTINE UAHXT(mhx,delt,NITS,UAhiV,UAhiT) 
         
C-----Programmdescription---------------------------------------------C
C
C     This subroutine calculates UAhxT 
C     UAhxT is used as a time dependent factor time for the 
C     (UA) value of the heat exchangers 
C     (usually used for load side heat exchangers (LSH))
C
C---------------------------------------------------------------------C
C
C     Name:     H.Dr…k
C
C     Version:  03.11.1995                    Date: 03.11.1995
C
C-----used variables--------------------------------------------------C
C
C      TO:      maxN              max. number of nodes in the storage
C                                 (only for dimension)
C               Nmax              number of nodes in the storage
C               nhx               number of the actual heatexchanger
C               nh                number of nodes occupied by the hx.
C               mhx               fluid flow rate through the hx.
C               delt              TRNSYS-timestep
C               NITS              relative number of int. timesteps
C               UAhiV             factor for time constant of LSH i
C
C      BACK:    UAhiT             time dependend factor for UA of LSH i
C
C      ELSE:    rhelp
C
C----------------------------------------------------------------------C

      DOUBLE PRECISION mhx
      DOUBLE PRECISION delt,NITS
      DOUBLE PRECISION UAhiV,UAhiT
      DOUBLE PRECISION rhelp

C**********************************************************************
C     Calculation of UAhiT                                            *
C**********************************************************************
      IF (NITS.eq.0.0) then
          rhelp = (UAhiV*UAhiT) + (mhx * delt * (1.d0 - UAhiT))
      else
         rhelp = (UAhiV*UAhiT) + (mhx * NITS * delt * (1.d0 - UAhiT))
      end if

C---->maximum value of rhelp is UAhiV, minimum value is zero  
      If (rhelp.gt.UAhiV) rhelp = UAhiV
      If (rhelp.lt.0.0) rhelp = 0.d0
      
      UAhiT = rhelp/UAhiV


      RETURN
      END

C-----------------------------------------------------------------------

      SUBROUTINE UAHXS(maxN,Nmax,nhx,nh,epsua,UAhis,bhi1,bhi2,bhi3,
     1                 UAhiT,SYSINFO,Thi,mhx,Tnew,DL,UAhxsm,UAmod)


C-----Programmdescription---------------------------------------------C
C
C     This subroutine calculates UAhxs (UA between the heat-
C     changer and the storage) individual for each node as
C     a function of the temperaturedifference between the
C     two nodes and the parameters bhii in connection with
C     mdot.
C
C---------------------------------------------------------------------C
C
C     Name:     H.Dr…k
C
C     Version:  17.12.1998                    Date: 09.01.1994
C
C               17.12.1998  Extention to 4 heat exchangers
C               03.11.1995  HD  time dependend factor for load side hx
C
C-----used variables--------------------------------------------------C
C
C      TO:      maxN              max. number of nodes in the storage
C                                 (only for dimension)
C               Nmax              number of nodes in the storage
C               nhx               number of the actual heatexchanger
C               nh                number of nodes occupied by the hx.
C               epsua             allowed exactness border
C               UAhis             UA form heatexchanger to storage
C               bhi1,bhi2,bhi3    parameters for calculation of UAhxsm
C               UAhiT             time dependend factor for UA of LSH i
C               SYSINFO           matrix with nodepositions of hx. & dp
C               Thi               inlet temperature of the heatexch.
C               mhx               fluid flow rate through the hx.
C               Tnew              actual temperature-matrix
C               DL                difference-coefficinet-matrix
C
C      BACK:    UAhxsm            values of UA between a heatexchanger
C                                 and the storage
C               UAmod             Flag if the values of UAhxsm have
C                                 to be modified  (1..yes)
C
C      ELSE:    error             relative error
C               td                temperature-difference
C               co                column of a matrix
C               Tm                mean temp. between st. and hx.
C               i
C
C----------------------------------------------------------------------C

        INTEGER maxN,Nmax,nhx,nh,UAmod,i,co
        INTEGER SYSINFO(maxN,18)

        DOUBLE PRECISION error,epsua,UAhis,bhi1,bhi2,bhi3
        DOUBLE PRECISION Thi,mhx,td,Tm
        DOUBLE PRECISION UAhxsm(maxN)
        DOUBLE PRECISION Tnew(maxN,3)
        DOUBLE PRECISION DL(maxN,3)
        DOUBLE PRECISION UAhiT

C**********************************************************************
C     general initialisation                                          *
C**********************************************************************
      UAmod = 0
      IF (nhx.eq.1.or.nhx.eq.4) then
         co = 1
      else if (nhx.eq.2.or.nhx.eq.3) then
         co = 3
      end if
C---->reset UAhxsm(i)
      DO 7 i=1,Nmax
         UAhxsm(i) = 0.d0
7     Continue


C**********************************************************************
C     Calculate UA as a function of temp.difference and flow rate     *
C**********************************************************************

      if (bhi1.ne.0.or.bhi2.ne.0.or.bhi3.ne.0) then
         DO 10 i=1,Nmax
            if (ABS(SYSINFO(i,nhx)).eq.1) then
               td = ABS(Thi-Tnew(i,2))
               Tm = ABS((Thi+Tnew(i,2))/2.d0)
C------------> this is the ITW equation
               if (td.eq.0.and.mhx.eq.0) then
                  UAhxsm(i) = UAhiT * ((UAhis/Float(nh)) * (Tm**bhi3))
               else if (td.eq.0.and.mhx.gt.0.) then
                  UAhxsm(i) = UAhiT * ((UAhis/Float(nh)) 
     1                       * ((mhx/3600.)**bhi1)
     2                       * (Tm**bhi3))
               else if (td.gt.0.and.mhx.eq.0.) then
                  UAhxsm(i) = UAhiT * ((UAhis/Float(nh)) 
     1                       * (td**bhi2) * (Tm**bhi3))
               else
                  UAhxsm(i) = UAhiT * ((UAhis/Float(nh)) 
     1                       * ((mhx/3600.)**bhi1)
     2                       * (td**bhi2) * (Tm**bhi3))
               end if
C------------> Attention, UAhiT only implemented in the equation above!!
C------------> this is the modified ITW - equation
c              UAhxsm(i) = (UAhis/Float(nh)) * ((mhx/3600.)**bhi1)
c       1                     * (Tm**bhi3)

C------------> this is the modified-Danish equation
c               UAhxsm(i) = (UAhis+(bhi1*Tm))/Float(nh)

            else
            end if
10       Continue
      else
         DO 11 i=1,Nmax
            if (ABS(SYSINFO(i,nhx)).eq.1) then
               UAhxsm(i) = UAhis/Float(nh)
            else 
            end if
11       Continue
      end if


c      read(*,*)

C**********************************************************************
C     Check if the difference-koefficient-matrix has to be modified   *
C**********************************************************************
      IF (nhx.eq.1.or.nhx.eq.4) then
         co = 2
      else if (nhx.eq.2.or.nhx.eq.3) then
         co = 3
      end if

      DO 20 i=1,Nmax
         if (ABS(SYSINFO(i,nhx)).eq.1) then
            if (UAhxsm(i).gt.0.0) then
               error = ABS((DL(i,co)-UAhxsm(i))/UAhxsm(i))
            else
               error = 0.5 * epsua
               UAhxsm(i) = 0.d0
            end if

            if (error.gt.epsua) UAmod=1
         else
         end if
20    Continue
c      read(*,*)


      RETURN
      END



C-----------------------------------------------------------------------
      
      SUBROUTINE CALCU_EX(maxN,Nmax,nhx,Tnew,Tamb,CAP,SYSINFO,Excalc)

C-----Programmdescription---------------------------------------------C
C
C     This subroutine calculates the exergy stored in the   
C     tank and in the heat exchangers (in relation to the 
C     ambient temperature)
C
C---------------------------------------------------------------------C
C
C     Name:     H.Dr…k
C
C     Version:  17.12.1998                    Date: 25.01.1998
C
C               17.12.1998  Extention to 4 heat exchangers
C
C-----used variables--------------------------------------------------C
C
C      TO:      maxN              max. number of nodes in the storage
C                                 (only for dimension)
C               Nmax              number of nodes in the storage
C               nhx               number of the actual heatexchanger
C                                 Note: nhx = 0 is the tank
C               Tnew              actual temperature-matrix
C               Tamb              ambient temperature
C               CAP               capacity matrix
C               SYSINFO           matrix with nodepositions of hx. & dp
C
C      BACK:    Excalc            calcualted exergy                   
C
C      ELSE:    co                column of a matrix (co=2 --> tank)
C               energy            energy (product of capacity and temp.)       
C               exergy            exergy (related to Tamb)
C               i
C
C----------------------------------------------------------------------C
        
        INTEGER maxN,Nmax,nhx,i,co
        INTEGER SYSINFO(maxN,18)
      
        DOUBLE PRECISION Tnew(maxN,3)
        DOUBLE PRECISION CAP(maxN,3)
        DOUBLE PRECISION Tamb,Excalc,energy,exergy

C**********************************************************************
C     general initialisation                                          *
C**********************************************************************
      IF (nhx.eq.0) then
         co = 2
      else if (nhx.eq.1.or.nhx.eq.4) then
         co = 1
      else if (nhx.eq.2.or.nhx.eq.3) then
         co = 3
      end if

C**********************************************************************
C     calculate exergy for the appropriate device (hx or store)       *
C**********************************************************************
      Excalc = 0.0
      DO 82 i=1,Nmax
         If (nhx.eq.0) then
            energy = CAP(i,co) * (Tnew(i,co) - Tamb)
            exergy = (1.0 - ((Tamb+273.15)/(Tnew(i,co)+273.15)))
     1               * energy 
            Excalc = Excalc + exergy
         else if (ABS(SYSINFO(i,nhx)).eq.1) then
            energy = CAP(i,co) * (Tnew(i,co) - Tamb)
            exergy = (1.0 - ((Tamb+273.15)/(Tnew(i,co)+273.15)))
     1               * energy 
            Excalc = Excalc + exergy
         end if
82    Continue

      RETURN
      END



C-----------------------------------------------------------------------

cak GETTIM-Routine for LAHEY now in include file compilr4.inc or lahey4.inc
cak for MS Powerstation the intrinsic function GETTIM will be called 
cak for this reason the file mspower4.inc is empty

C-----------------------------------------------------------------------
                  
      SUBROUTINE DU_DO_IN(maxN,Nmax,dtmix,Tnew,FLOWINFO)

C-----Programmdescription---------------------------------------------C
C
C     Initialisation, and when using stratified charging also
C     update, of DU and DO for the massflows in the storage and
C     in the heat exchangers
C
C     Note: If no stratified charging the marix of SYSINFO is
C           similar to the matrix of FLOWINFO
C
C---------------------------------------------------------------------C
C
C     Name:     H.Dr…k
C
C     Version:  17.12.1998                    Date: 07.03.1994
C
C               17.12.1998  Extention to 4 heat exchangers
C               07.11.1998  Extention to 10 double ports
C
C-----used variables--------------------------------------------------C
C
C      TO:      maxN              max. number of nodes in the storage
C                                 (only for dimension)
C               Nmax              number of nodes in the storage
C               dtmix             temperature-difference for mixing
C               Tnew              actual temperature-matrix
C               FLOWINFO          matrix with nodes of massflow
C
C      Changed: DU,DO             matrix of difference-koefficients
C                                 which are changed in this subroutine
C
C      ELSE:    nin               number of a input node
C               i,n               help variables
C
C----------------------------------------------------------------------C

      COMMON/DP_OUT/zd1o,zd2o,zd3o,zd4o,zd5o,zd6o,zd7o,zd8o,zd9o,zd10o
      COMMON/DP_CPF/CPFD1,CPFD2,CPFD3,CPFD4,CPFD5,
     1              CPFD6,CPFD7,CPFD8,CPFD9,CPFD10
      COMMON/DP_R_INP/zd1i,zd2i,zd3i,zd4i,zd5i,zd6i,zd7i,zd8i,zd9i,zd10i
      COMMON/DP_N_INP/nzd1i,nzd2i,nzd3i,nzd4i,nzd5i,
     1                nzd6i,nzd7i,nzd8i,nzd9i,nzd10i

      COMMON/HX_OUT/zh1o,zh2o,zh3o,zh4o
      COMMON/HX_CPF/CPFH1,CPFH2,CPFH3,CPFH4

      COMMON/HX_R_INP/zh1i,zh2i,zh3i,zh4i
      COMMON/HX_N_INP/nzh1i,nzh2i,nzh3i,nzh4i

      COMMON/DU_DO/DU,DO,tdcon,dmix,modus


      INTEGER maxN,Nmax,nin,i,n,modus
      INTEGER nzd1i,nzd2i,nzd3i,nzd4i,nzd5i,nzd6i,nzd7i,nzd8i
      INTEGER nzd9i,nzd10i,nzh1i,nzh2i,nzh3i,nzh4i

      INTEGER FLOWINFO(maxN,18)

      DOUBLE PRECISION DO(200,3),DU(200,3),Tnew(maxN,3)

      DOUBLE PRECISION CPFD1,CPFD2,CPFD3,CPFD4,CPFD5,CPFD6,CPFD7,CPFD8
      DOUBLE PRECISION CPFH1,CPFH2,CPFH3,CPFH4,CPFD9,CPFD10
      DOUBLE PRECISION zd1i,zd2i,zd3i,zd4i,zd5i,zd6i,zd7i,zd8i,zd9i
      DOUBLE PRECISION zd1o,zd2o,zd3o,zd4o,zd5o,zd6o,zd7o,zd8o,zd9o
      DOUBLE PRECISION zh1i,zh2i,zh3i,zh4i,zh1o,zh2o,zh3o,zh4o,zd10i            
      DOUBLE PRECISION tdcon,dmix,dtmix,zd10o

C************************************************************************
C*    Reset DU and DO                                                   *
C************************************************************************
      DO 10 i=1,Nmax
         DO 20 j=1,3
            DU(i,j) = 0.0
            DO(i,j) = 0.0
20       Continue
10    Continue


C************************************************************************
C*    Initial differnce-koefficient-matrix DU because of massflows      *
C************************************************************************
      DO 40 i=1,Nmax
C---> first heatexchanger
         IF (FLOWINFO(i,1).eq.1) DU(i,1) = CPFH1
C---> second heatexchanger
         IF (FLOWINFO(i,2).eq.1) DU(i,3) = CPFH2
C---> third heatexchanger
         IF (FLOWINFO(i,3).eq.1) DU(i,3) = CPFH3
C---> fourth heatexchanger
         IF (FLOWINFO(i,4).eq.1) DU(i,1) = CPFH4

C---> storage
         IF (FLOWINFO(i,5).eq.1)  DU(i,2) = CPFD1
         IF (FLOWINFO(i,6).eq.1)  DU(i,2) = DU(i,2) + CPFD2
         IF (FLOWINFO(i,7).eq.1)  DU(i,2) = DU(i,2) + CPFD3
         IF (FLOWINFO(i,8).eq.1)  DU(i,2) = DU(i,2) + CPFD4
         IF (FLOWINFO(i,9).eq.1)  DU(i,2) = DU(i,2) + CPFD5
         IF (FLOWINFO(i,10).eq.1)  DU(i,2) = DU(i,2) + CPFD6
         IF (FLOWINFO(i,11).eq.1) DU(i,2) = DU(i,2) + CPFD7
         IF (FLOWINFO(i,12).eq.1) DU(i,2) = DU(i,2) + CPFD8
         IF (FLOWINFO(i,13).eq.1) DU(i,2) = DU(i,2) + CPFD9
         IF (FLOWINFO(i,14).eq.1) DU(i,2) = DU(i,2) + CPFD10
40    Continue
                          

C*--> Note: DU of the node entered by a external capacity flow is
C*          not influenced by this capacity flow!
C---> first heatexchanger
      IF (zh1i.ge.0.and.zh1o.ge.0) then
         nin = nzh1i
         IF (FLOWINFO(nin,1).eq.1) DU(nin,1) = DU(nin,1) - CPFH1
      else
      end if
C---> second heatexchanger
      IF (zh2i.ge.0.and.zh2o.ge.0) then
         nin = nzh2i
         IF (FLOWINFO(nin,2).eq.1) DU(nin,3) = DU(nin,3) - CPFH2
      else
      end if
C---> third heatexchanger
      IF (zh3i.ge.0.and.zh3o.ge.0) then
         nin = nzh3i
         IF (FLOWINFO(nin,3).eq.1) DU(nin,3) = DU(nin,3) - CPFH3
      else
      end if

C---> fourth heatexchanger
      IF (zh4i.ge.0.and.zh4o.ge.0) then
         nin = nzh4i
         IF (FLOWINFO(nin,4).eq.1) DU(nin,1) = DU(nin,1) - CPFH4
      else
      end if

C---> first doubleport
      IF (zd1i.ge.0.and.zd1o.ge.0) then
         nin = nzd1i
         IF (FLOWINFO(nin,5).eq.1) DU(nin,2) = DU(nin,2) - CPFD1
      else
      end if
C---> second doubleport
      IF (zd2i.ge.0.and.zd2o.ge.0) then
         nin = nzd2i
         IF (FLOWINFO(nin,6).eq.1) DU(nin,2) = DU(nin,2) - CPFD2
      else
      end if
C---> third doubleport
      IF (zd3i.ge.0.and.zd3o.ge.0) then
         nin = nzd3i
         IF (FLOWINFO(nin,7).eq.1) DU(nin,2) = DU(nin,2) - CPFD3
      else
      end if
C---> fourth doubleport
      IF (zd4i.ge.0.and.zd4o.ge.0) then
         nin = nzd4i
         IF (FLOWINFO(nin,8).eq.1) DU(nin,2) = DU(nin,2) - CPFD4
      else
      end if
C---> fifth doubleport
      IF (zd5i.ge.0.and.zd5o.ge.0) then
         nin = nzd5i
         IF (FLOWINFO(nin,9).eq.1) DU(nin,2) = DU(nin,2) - CPFD5
      else
      end if
C---> sixth doubleport
      IF (zd6i.ge.0.and.zd6o.ge.0) then
         nin = nzd6i
         IF (FLOWINFO(nin,10).eq.1) DU(nin,2) = DU(nin,2) - CPFD6
      else
      end if
C---> seventh doubleport
      IF (zd7i.ge.0.and.zd7o.ge.0) then
         nin = nzd7i
         IF (FLOWINFO(nin,11).eq.1) DU(nin,2) = DU(nin,2) - CPFD7
      else
      end if
C---> eight doubleport
      IF (zd8i.ge.0.and.zd8o.ge.0) then
         nin = nzd8i
         IF (FLOWINFO(nin,12).eq.1) DU(nin,2) = DU(nin,2) - CPFD8
      else
      end if
C---> nine doubleport
      IF (zd9i.ge.0.and.zd9o.ge.0) then
         nin = nzd9i
         IF (FLOWINFO(nin,13).eq.1) DU(nin,2) = DU(nin,2) - CPFD9
      else
      end if
C---> ten doubleport
      IF (zd10i.ge.0.and.zd10o.ge.0) then
         nin = nzd10i
         IF (FLOWINFO(nin,14).eq.1) DU(nin,2) = DU(nin,2) - CPFD10
      else
      end if


C************************************************************************
C*    Initial differnce-koefficient-matrix DO because of massflows      *
C************************************************************************
        DO 41 i=1,Nmax
C---> first heatexchanger
         IF (FLOWINFO(i,1).eq.-1) DO(i,1) = CPFH1
C---> second heatexchanger
         IF (FLOWINFO(i,2).eq.-1) DO(i,3) = CPFH2
C---> third heatexchanger
         IF (FLOWINFO(i,3).eq.-1) DO(i,3) = CPFH3
C---> fourth heatexchanger
         IF (FLOWINFO(i,4).eq.-1) DO(i,1) = CPFH4

C---> storage
         IF (FLOWINFO(i,5).eq.-1)  DO(i,2) = CPFD1
         IF (FLOWINFO(i,6).eq.-1)  DO(i,2) = DO(i,2) + CPFD2
         IF (FLOWINFO(i,7).eq.-1)  DO(i,2) = DO(i,2) + CPFD3
         IF (FLOWINFO(i,8).eq.-1)  DO(i,2) = DO(i,2) + CPFD4
         IF (FLOWINFO(i,9).eq.-1)  DO(i,2) = DO(i,2) + CPFD5
         IF (FLOWINFO(i,10).eq.-1)  DO(i,2) = DO(i,2) + CPFD6
         IF (FLOWINFO(i,11).eq.-1) DO(i,2) = DO(i,2) + CPFD7
         IF (FLOWINFO(i,12).eq.-1) DO(i,2) = DO(i,2) + CPFD8
         IF (FLOWINFO(i,13).eq.-1) DO(i,2) = DO(i,2) + CPFD9
         IF (FLOWINFO(i,14).eq.-1) DO(i,2) = DO(i,2) + CPFD10
41    Continue


C*--> Note: DO of the node entered by a external capacity flow is
C*          not influenced by this capacity flow!
C---> first heatexchanger
      IF (zh1i.ge.0.and.zh1o.ge.0) then
         nin = nzh1i
         IF (FLOWINFO(nin,1).eq.-1) DO(nin,1) = DO(nin,1) - CPFH1
      else
      end if
C---> second heatexchanger
      IF (zh2i.ge.0.and.zh2o.ge.0) then
         nin = nzh2i
         IF (FLOWINFO(nin,2).eq.-1) DO(nin,3) = DO(nin,3) - CPFH2
      else
      end if
C---> third heatexchanger
      IF (zh3i.ge.0.and.zh3o.ge.0) then
         nin = nzh3i
         IF (FLOWINFO(nin,3).eq.-1) DO(nin,3) = DO(nin,3) - CPFH3
      else
      end if
C---> fourth heatexchanger
      IF (zh4i.ge.0.and.zh4o.ge.0) then
         nin = nzh4i
         IF (FLOWINFO(nin,4).eq.-1) DO(nin,1) = DO(nin,1) - CPFH4
      else
      end if

C---> first doubleport
      IF (zd1i.ge.0.and.zd1o.ge.0) then
         nin = nzd1i
         IF (FLOWINFO(nin,5).eq.-1) DO(nin,2) = DO(nin,2) - CPFD1
      else
      end if
C---> second doubleport   
      IF (zd2i.ge.0.and.zd2o.ge.0) then
         nin = nzd2i
         IF (FLOWINFO(nin,6).eq.-1) DO(nin,2) = DO(nin,2) - CPFD2
      else
      end if
C---> third doubleport
      IF (zd3i.ge.0.and.zd3o.ge.0) then
         nin = nzd3i
         IF (FLOWINFO(nin,7).eq.-1) DO(nin,2) = DO(nin,2) - CPFD3
      else
      end if
C---> fourth doubleport
      IF (zd4i.ge.0.and.zd4o.ge.0) then
         nin = nzd4i
         IF (FLOWINFO(nin,8).eq.-1) DO(nin,2) = DO(nin,2) - CPFD4
      else
      end if
C---> fifth doubleport
      IF (zd5i.ge.0.and.zd5o.ge.0) then
         nin = nzd5i
         IF (FLOWINFO(nin,9).eq.-1) DO(nin,2) = DO(nin,2) - CPFD5
      else
      end if
C---> sixth doubleport
      IF (zd6i.ge.0.and.zd6o.ge.0) then
         nin = nzd6i
         IF (FLOWINFO(nin,10).eq.-1) DO(nin,2) = DO(nin,2) - CPFD6
      else
      end if
C---> seventh doubleport
      IF (zd7i.ge.0.and.zd7o.ge.0) then
         nin = nzd7i
         IF (FLOWINFO(nin,11).eq.-1) DO(nin,2) = DO(nin,2) - CPFD7
      else
      end if
C---> eight doubleport
      IF (zd8i.ge.0.and.zd8o.ge.0) then
         nin = nzd8i
         IF (FLOWINFO(nin,12).eq.-1) DO(nin,2) = DO(nin,2) - CPFD8
      else
      end if
C---> nine doubleport
      IF (zd9i.ge.0.and.zd9o.ge.0) then
         nin = nzd9i
         IF (FLOWINFO(nin,13).eq.-1) DO(nin,2) = DO(nin,2) - CPFD9
      else
      end if
C---> ten doubleport
      IF (zd10i.ge.0.and.zd10o.ge.0) then
         nin = nzd10i
         IF (FLOWINFO(nin,14).eq.-1) DO(nin,2) = DO(nin,2) - CPFD10
      else
      end if


C************************************************************************
C*    Initial differnce-koefficient-matrix DU and DO in the storage     *
C*    with lacon to simulate thermal diffusivity in the storage         *
C************************************************************************
      DO 500 i=1,Nmax-1
         n = i+1
         DU(n,2) = DU(n,2) + tdcon
         DO(i,2) = DO(i,2) + tdcon
500    Continue


C************************************************************************
C*    Initial differnce-koefficient-matrix DU and DO in the storage     *
C*    with dmix (only if the massflow rate through the dp = 0)          *
C*    to avoid inversion in the storage                                 *
C************************************************************************
      If (modus.eq.2) then
C------->calculate the value for the difference-koefficient
         DO 60 i=1,Nmax-1
            If (Tnew(i,2).ge.Tnew(i+1,2)-dtmix) then
               n = i+1
               DU(n,2) = DU(n,2) + dmix
               DO(i,2) = DO(i,2) + dmix
            else
            end if
60       Continue
      else
      end if


      RETURN
      END


C-----------------------------------------------------------------------


      SUBROUTINE DL_DR_IN(maxN,Nmax,UAhxsm,epsua,SYSINFO,DL,DR,
     1                    Tnew,update)
      use TrnsysFunctions
C-----Programmdescription---------------------------------------------C
C
C     Initialisation, and when using temperature and massflow
C     dependend UAhxs also update, of DL and DR
C
C---------------------------------------------------------------------C
C
C     Name:     H.Dr…k
C
C     Version:  17.12.1998                    Date: 20.11.1993
C
C               17.12.1998    Extention to 4 heat exchangers
C               03.11.1995    implementation of time constant for
C                             (UA) of load side heat exchangers
C
C-----used variables--------------------------------------------------C
C
C      TO:      maxN              max. number of nodes in the storage
C                                 (only for dimension)
C               Nmax              number of nodes in the storage
C               DL,DR             difference-koefficients
C               UAhxsm            Vector with values of UA between a
C                                 heatexchanger and the storage
C               epsua             exactness for temperature-dependence
C                                 of UAhx,s
C               SYSINFO           matrix with nodepositions of the hx.
C               Tnew              actual temperature-matrix
C
C      BACK:    update            Flag if values of DL and DR have been
C                                 updated (1..yes)
C
C      ELSE:    nhx               number of the heatexchanger
C               UAmod1            Flag if the values of UAhxsm form
C                                 hx1 have to be modified  (1..yes)
C               UAmod2            Flag if the values of UAhxsm form
C                                 hx2 have to be modified  (1..yes)
C               UAmod3            Flag if the values of UAhxsm form
C                                 hx2 have to be modified  (1..yes)
C               i,j               help variables
C
C----------------------------------------------------------------------C

      INTEGER maxN,Nmax,UAmod1,UAmod2,UAmod3,UAmod4,nhx,i,update
      INTEGER SYSINFO(maxN,18)
      INTEGER nh1,nh2,nh3,nh4
      
      DOUBLE PRECISION DL(maxN,3),DR(maxN,3)
      DOUBLE PRECISION Tnew(maxN,3)
      DOUBLE PRECISION UAhxsm(maxN)
      DOUBLE PRECISION UAh1s,UAhx1,bh11,bh12,bh13,mh1,smh1,Th1i
      DOUBLE PRECISION UAh2s,UAhx2,bh21,bh22,bh23,mh2,smh2,Th2i
      DOUBLE PRECISION UAh3s,UAhx3,bh31,bh32,bh33,mh3,smh3,Th3i
      DOUBLE PRECISION UAh4s,UAhx4,bh41,bh42,bh43,mh4,smh4,Th4i
      DOUBLE PRECISION epsua
      DOUBLE PRECISION UAh1T,UAh2T,UAh3T,UAh4T 

      COMMON/UAHX/UAh1s,UAhx1,bh11,bh12,bh13,mh1,smh1,
     1            UAh2s,UAhx2,bh21,bh22,bh23,mh2,smh2,
     2            UAh3s,UAhx3,bh31,bh32,bh33,mh3,smh3,
     3            UAh4s,UAhx4,bh41,bh42,bh43,mh4,smh4,nh1,nh2,nh3,nh4

      COMMON/HX_INP_T/Th1i,Th2i,Th3i,Th4i

      COMMON/LSH/UAh1T,UAh2T,UAh3T,UAh4T
      
C************************************************************************
C*                                                                      *
C*    Update differnce-koefficient-matrix DL                            *
C*                                                                      *
C************************************************************************
      IF (UAh1s.gt.1.e-27) then
C------> first calculate UA between the first heatexch. and the storage
         nhx=1
         UAmod1=0
         Call UAHXS(maxN,Nmax,nhx,nh1,epsua,UAh1s,bh11,bh12,bh13,
     1              UAh1T,SYSINFO,Th1i,mh1,Tnew,DL,UAhxsm,UAmod1)
	   If (ErrorFound()) RETURN
C------> then update if necessary
         If (UAmod1.eq.1) then
            update = 1
            DO 71 i=1,Nmax
               DL(i,2) = UAhxsm(i) * ABS(SYSINFO(i,1))
71          Continue
         else
         end if
      else
      end if

      IF (UAh2s.gt.1.e-27) then
C---> first calculate UA between the second heatexch. and the storage
         nhx=2
         UAmod2=0
         Call UAHXS(maxN,Nmax,nhx,nh2,epsua,UAh2s,bh21,bh22,bh23,
     1              UAh2T,SYSINFO,Th2i,mh2,Tnew,DL,UAhxsm,UAmod2)
	   If (ErrorFound()) RETURN
C------> then update if necessary
         If (UAmod2.eq.1) then
            update = 1
            DO 72 i=1,Nmax
               IF (SYSINFO(i,2).ne.0) DL(i,3) = UAhxsm(i)
72          Continue
         else
         end if
      else
      end if

      IF (UAh3s.gt.1.e-27) then
C---> first calculate UA between the third heatexch. and the storage
         nhx=3
         UAmod3=0
         Call UAHXS(maxN,Nmax,nhx,nh3,epsua,UAh3s,bh31,bh32,bh33,
     1              UAh3T,SYSINFO,Th3i,mh3,Tnew,DL,UAhxsm,UAmod3)
	   If (ErrorFound()) RETURN
C------> then update if necessary
         IF (UAmod3.eq.1) then
            update = 1
            DO 73 i=1,Nmax
               IF (SYSINFO(i,3).ne.0) DL(i,3) = UAhxsm(i)
73          Continue
         else
         end if
      else
      end if

      IF (UAh4s.gt.1.e-27) then
C---> first calculate UA between the fourth heatexch. and the storage
         nhx=4
         UAmod4=0
         Call UAHXS(maxN,Nmax,nhx,nh4,epsua,UAh4s,bh41,bh42,bh43,
     1              UAh4T,SYSINFO,Th4i,mh4,Tnew,DL,UAhxsm,UAmod4)
	   If (ErrorFound()) RETURN
C------> then update if necessary
         IF (UAmod4.eq.1) then
            update = 1
            DO 74 i=1,Nmax
               IF (SYSINFO(i,4).ne.0) DL(i,2) = UAhxsm(i)
74          Continue
         else
         end if
      else
      end if


C---->If DL has been updated, DR has to be modified
      IF (update.eq.1) then
C************************************************************************
C*    Update differnce-koefficient-matrix DR                            *
C************************************************************************
         DO 75 i=1,Nmax
            DR(i,1) = DL(i,2)
            DR(i,2) = DL(i,3)
75       Continue

      else
      end if

      RETURN
      END


C-----------------------------------------------------------------------

      SUBROUTINE DD_DTMIN(maxN,Nmax,CAP,DU,DO,DR,DL,DB,DF,
     1                    DDSTAR,DTmin)

C-----Programmdescription---------------------------------------------C
C
C     Initialisation, and when using temperature and massflow
C     dependend UAhxs also update, of
C     DDSTAR = DO + DU + DR + DL + DB + DF and calculation of the
C     biggest timestep that is stable in the explicit case (DTmin)
C
C---------------------------------------------------------------------C
C
C     Name:     H.Dr…k
C
C     Version:  15.05.1994                    Date: 15.04.1994
C
C-----used variables--------------------------------------------------C
C
C      TO:      maxN              max. number of nodes in the storage
C                                 (only for dimension)
C               Nmax              number of nodes in the storage
C               CAP               capacity-matrix
C               DL,DR,DO,DU,DB,DF difference-koefficients
C
C      BACK:    DDSTAR            matrix of DO+DU+DR+DL+DB+DF
C               DTmin             timestep that is stable in the
C                                 explicit case
C
C      ELSE:    i,j               help variables
C
C----------------------------------------------------------------------C


      INTEGER maxN,Nmax,i,j

      DOUBLE PRECISION DO(maxN,3),DU(maxN,3)
      DOUBLE PRECISION DB(maxN,3),DF(maxN,3)
      DOUBLE PRECISION DL(maxN,3),DR(maxN,3),DDSTAR(maxN,3)
      DOUBLE PRECISION CAP(maxN,3)
      DOUBLE PRECISION DTmin,rhelp


C************************************************************************
C*    Calculate DDSTAR = DO + DU + DR + DL + DB + DF                    *
C************************************************************************
      DO 10 j=1,3
         DO 20 i=1,Nmax
            DDSTAR(i,j) = DO(i,j) + DU(i,j) + DR(i,j) +
     1                    DL(i,j) + DB(i,j) + DF(i,j)
20       Continue
10    Continue


C************************************************************************
C*    Calculate internal timestep that it is stable in explicit case    *
C************************************************************************
      DTmin = 1.e30
      DO 30 j=1,3
         DO 40 i=1,Nmax
            If (DDSTAR(i,j).gt.0) then
               rhelp = CAP(i,j)/DDSTAR(i,j)
               If (rhelp.lt.DTmin) then
                  DTmin=rhelp
               else
               end if
            else
            end if
40       Continue
30    Continue



      RETURN
      END


C-----------------------------------------------------------------------

      SUBROUTINE SOLUTION(maxN,Nmax,sigma,epstmp,epsua,SYSINFO,
     1                    FLOWINFO,CAP,DDSTAR,SOURCE,DO,DU,DL,DR,
     2                    DB,DF,Told,Tinp,Tamb,UAhxsm,time,DTint,
     3                    DTmin,modus,hxuavar,ncvhx,little,dtmix,
     4                    Tnew,Tafter)
      use TrnsysFunctions
C-----Programmdescription---------------------------------------------C
C
C     This subroutine manages the calculation of Tnew
C
C---------------------------------------------------------------------C
C
C     Name:     H.Dr…k
C
C     Version:  17.12.1998                    Date: 21.11.1993
C
C               17.12.1998  Extention to 4 heat exchangers
C               02.12.1998  modified for natural convection hx
C
C-----used variables--------------------------------------------------C
C
C      TO:      maxN              max. number of nodes in the storage
C                                 (only for dimension)
C               Nmax              number of nodes in the storage
C               sigma             parameter for solving method
C               epstmp            exactness for calculating the
C                                 temperatures
C               epsua             exactness for temperature-dependence
C                                 of UAhx,s
C               SYSINFO           matrix with nodepositions of hx. & dp
C               CAP               capacity - Term (Rho * Cp * V)
C               DDSTAR            matrix of DO+DU+DR+DL
C               SOURCE            source-matrix
C               DO,DU,DR,DL,DB,DF difference-koefficients
C               Told              old temperature-matrix
C               Tinp              temperature matrix with input temp.
C               Tamb              ambient temperature
C               UAhxsm            Vector with values of UA between a
C                                 hx. and the storage (only for dim.)
C               time              Trnsys-time
C               DTint             internal delta time
C               DTmin             delta_t thats stable in explicit case
C               modus             kind of solution 1....with CALL MIXER
C                                 2....with lambda - mix
C               hxuavar           Flag if UAhx,s is variable (1..yes)
C               ncvhx             Flag if natural conv. mode for a hx
C               little            Flag if SOLUTION is done with
C                                 little timesteps (1..yes)
C               dtmix             temperature-difference for mixing
C
C      BACK:    Tnew              new temperature-matrix
C               Tafter            TNEW in the storage after mixing
C
C      COMMON:  laux              length of the auxiliary heater
C    /A_HEATER/ zaux              relative position of aux. heater
C               ztaux             relative position of the controller
C                                 of the auxiliary heater
C               HMOD              auxiliary heater mode
C               HTOP              HTOP=1 if installed from the top
C               Hs                storage height
C               Paux              power of the auxiliary heater
C               Tset              set temp. of the controller
C               dTdb              dead band temp. difference
C                                 of the controller
C
C      ELSE:    update            Flag if values of DL,DR or SOURCE
C                                 have been updated (1..yes)
C               nchmod            Flag if power of natural convection
C                                 hx has changed (1..yes)
C  Qh1new,Qh2new,Qh3new,Qh4new    'new' power of natural conv. hx
C  Qh1old,Qh2old,Qh3old,Qh4old    power of nc hx from iteration before
C               nudate            number of updates
C               sdtint            DTint at the call of this subrotine
C               DTmax             maximal delta_t thats allowed
C               first             Flag if first call of HEATER in
C                                 this internal timestep (1..yes)
C
C----------------------------------------------------------------------C

      COMMON/A_HEATER/laux,zaux,ztaux,HMOD,HTOP,Hs,Paux,Tset,dTdb


      INTEGER maxN,Nmax,update,nudate,modus,hxuavar,ncvhx,little
      INTEGER SYSINFO(maxN,18),FLOWINFO(maxN,18)
      INTEGER HMOD,HTOP,first
      INTEGER nchmod

      DOUBLE PRECISION laux,zaux,ztaux,Hs,Paux,Tset,dTdb
      DOUBLE PRECISION time,sdtint,DTint,DTmin,DTmax,dtmix
      DOUBLE PRECISION sigma,epstmp,epsua,Tamb
      DOUBLE PRECISION CAP(maxN,3)
      DOUBLE PRECISION DDSTAR(maxN,3)
      DOUBLE PRECISION SOURCE(maxN,3)
      DOUBLE PRECISION DO(maxN,3),DU(maxN,3),DL(maxN,3)
      DOUBLE PRECISION DR(maxN,3),DB(maxN,3),DF(maxN,3)
      DOUBLE PRECISION Tinp(maxN,3)
      DOUBLE PRECISION Told(maxN,3),Tnew(maxN,3),Tafter(maxN)
      DOUBLE PRECISION UAhxsm(maxN,3),Qh4old
      DOUBLE PRECISION Qh1new,Qh2new,Qh3new,Qh4new,Qh1old,Qh2old,Qh3old


C---> save dtint at the call of this subroutine
      sdtint = DTint

C---> initialisation of DTmax
      DTmax = 200.d0 * DTmin


C---->initial SOURCE-matrix
      first = 1
      If (little.ne.1) Then
       CALL HEATER(maxN,Nmax,Told,Tafter,epstmp,DTint,DTmin,time,
     &             first,SOURCE,DTmax,update)
	 If (ErrorFound()) RETURN
	End If
      If (sdtint.gt.DTmax) DTint = DTmax


C************************************************************************
C*    Calculate new temperatures (start of the internal timestep)       *
C************************************************************************
      nudate = 0
      first = 0
7777  Continue
      nudate = nudate + 1
      update = 0


      Call SOLVER74(maxN,Nmax,dtint,sigma,epstmp,SYSINFO,CAP,DDSTAR,
     1              SOURCE,DO,DU,DL,DR,DB,DF,TOLD,Tinp,Tamb,Tnew)
	If (ErrorFound()) RETURN
      If (modus.eq.1) then
	   CALL MIXER(maxN,Nmax,CAP,Tnew,dtmix,Tafter)
         If (ErrorFound()) RETURN
	End If
      if (hxuavar.eq.1) then
         CALL DL_DR_IN(maxN,Nmax,UAhxsm,epsua,SYSINFO,DL,DR,
     1                 Tnew,update)
	   If (ErrorFound()) RETURN
      else
      end if

      if (ncvhx.eq.1) then
         CALL IN_VI_DP(maxN,Nmax,FLOWINFO,Told,Qh1new,
     1                 Qh2new,Qh3new,Qh4new)
         If (ErrorFound()) RETURN
         if (nudate.gt.1) then
C---------->check if output power has changed (for all four hx)
            nchmod = 0 
C---------> natural convection heat exchanger 1
            IF (Qh1new.ne.0.0) rhelp = (Qh1old - Qh1new)/Qh1new
            If (rhelp.ne.0.0) then
               IF (ABS(rhelp).gt.(epsua/10.0)) nchmod = 1
            else
            end if
C---------> natural convection heat exchanger 2
            IF (Qh2new.ne.0.0) rhelp = (Qh2old - Qh2new)/Qh2new
            If (rhelp.ne.0.0) then
               IF (ABS(rhelp).gt.(epsua/10.0)) nchmod = 1
            else
            end if
C---------> natural convection heat exchanger 3
            IF (Qh3new.ne.0.0) rhelp = (Qh3old - Qh3new)/Qh3new
            If (rhelp.ne.0.0) then
               IF (ABS(rhelp).gt.(epsua/10.0)) nchmod = 1
            else
            end if
C---------> natural convection heat exchanger 4
            IF (Qh4new.ne.0.0) rhelp = (Qh4old - Qh4new)/Qh4new
            If (rhelp.ne.0.0) then
               IF (ABS(rhelp).gt.(epsua/10.0)) nchmod = 1
            else
            end if
         else
            if (nudate.eq.1) nchmod = 1
         end if

         Qh1old = Qh1new
         Qh2old = Qh2new
         Qh3old = Qh3new
         Qh4old = Qh4new

         if (nchmod.eq.1) then
            update = 1
            CALL DU_DO_IN(maxN,Nmax,dtmix,Tnew,FLOWINFO)
c            CALL DU_DO_IN(maxN,Nmax,dtmix,Tnew,SYSINFO)
            If (ErrorFound()) RETURN
            CALL DF_INIT(maxN,Nmax,DF)
	      If (ErrorFound()) RETURN
            CALL TINP_IN(maxN,Nmax,TINP)
	      If (ErrorFound()) RETURN
         else
         end if
      else
      end if

C---->update DD-STAR if necessary
      if (hxuavar.eq.1.or.ncvhx.eq.1) then
         If (update.eq.1) then
            CALL DD_DTMIN(maxN,Nmax,CAP,DU,DO,DR,DL,DB,DF,DDSTAR,
     1                    DTmin)
	      If (ErrorFound()) RETURN
            DTmax = 200.0 * DTmin
         else
         end if
      else
      end if

C---->if necessary then modify SOURCE-matrix
      If (little.ne.1) then

C---->one more Iteration is necessary, but only 7 updates in one
C        internal timestep
         if (nudate.eq.7) then
c            write(*,*)'Attention : Not more than 7 updates ',
c     1                'in one internal timestep!!'
c            write(LUW,*)'Warning form Type 340:   TRNSYS-TIME: ',time
c            write(LUW,*)'Attention : Not more than 7 updates ',
c     1                  'in one internal timestep!!'
            goto 9999
         else
            CALL HEATER(maxN,Nmax,Told,Tafter,epstmp,DTint,DTmin,
     1                  time,first,SOURCE,DTmax,update)
	      If (ErrorFound()) RETURN
            if (update.eq.1) then
               If (sdtint.gt.DTmax) DTint = DTmax
               goto 7777
            else
            end if
         end if
      else
      end if

9999  Continue


      RETURN
      END


C-----------------------------------------------------------------------

      SUBROUTINE MIXER(maxN,Nmax,CAP,Tnew,dtmix,Tafter)

C-----Programmdescription---------------------------------------------C
C
C     This subroutine mixes the water in the storage
C     to avoid inversion
C
C---------------------------------------------------------------------C
C
C     Name:     H.Dr…k
C
C     Version:  04.04.1993                    Date: 10.12.1993
C
C-----used variables--------------------------------------------------C
C
C      TO:      maxN              max. number of nodes in the storage
C                                 (only for dimension)
C               Nmax              number of nodes in the storage
C               CAP               Capacity-Matrix
C               Tnew              temperature-matrix
C               dtmix             temperature-difference for mixing
C
C      BACK:    Tafter            storage temperature after mixing
C
C      ELSE:    tav               average temperature
C               capsum            sum of nodal capacity
C               energy            energy (product of capacity and temp.)
C               lnwi              lowest node with inversion
C               node              number of a node
C               por               point of return
C               rpapor            return point above por
C               grad1,grad2       gradient in the storage
C               useden            used energy
C               i,n
C
C----------------------------------------------------------------------C

        INTEGER maxN,Nmax,lnwi,node,i,n

        DOUBLE PRECISION dtmix,tav,capsum,energy
        DOUBLE PRECISION Tnew(maxN,3),Tafter(maxN)
        DOUBLE PRECISION CAP(maxN,3)


C------>change storage-temperature
        DO 15 i=1,Nmax
           Tafter(i) = Tnew(i,2)
15      Continue



19      Continue

C------>search from top to down the lowest node with inversion
        lnwi = 0
        DO 17 i=1,Nmax-1
           n = Nmax - i
           if (Tafter(n).gt.(Tafter(n+1)-dtmix).and.
     1        (Tafter(n).ne.Tafter(n+1))) lnwi = n

17      Continue

        if (lnwi.ne.0.) then
C--------->compute the average temperature
           node = lnwi-1
           capsum = 0.0
           energy = 0.0
           n = 0

27         node = node + 1
           n = n + 1
c           energy = energy + Tafter(node)
           energy = energy + ((CAP(node,2)/CAP(Nmax,2)) * Tafter(node))
           capsum = capsum + (CAP(node,2)/CAP(Nmax,2))
           tav = energy/capsum
c           tav = energy/Float(n)
           if (node.lt.Nmax.and.(tav.gt.Tafter(node+1)-dtmix))
     1         goto 27

C--------->set nodes with the average temperature
           DO 37 i=lnwi,lnwi-1+n
              Tafter(i) = tav
37         Continue

           goto 19
        else
        end if


        RETURN
        END



C-----------------------------------------------------------------------

      SUBROUTINE DP_POWER(maxN,Nmax,Told,Tnew,sigma,Qd1a,Qd2a,
     1                    Qd3a,Qd4a,Qd5a,Qd6a,Qd7a,Qd8a,
     2                    Qd9a,Qd10a)

C-----Programmdescription---------------------------------------------C
C                         
C     Calculates the actual power transfered by the double ports
C
C---------------------------------------------------------------------C
C
C     Name:     H.Dr…k
C
C     Version:  07.11.1998                    Date: 05.02.1994
C
C               07.11.1998  Extention to 10 double ports
C
C
C-----used variables--------------------------------------------------C
C
C      TO:      maxN              max. number of nodes in the storage
C                                 (only for dimension)
C               Nmax              number of nodes in the storage
C               Told              old temperature-matrix
C               Tnew              new temperature-matrix
C               sigma             parameter for solving method
C
C      BACK:    Qd1a...Qd10a      actual power transfered by
C                                 double port 1...10
C
C      ELES:    nout              number of a output node
C
C----------------------------------------------------------------------C

      COMMON/DP_OUT/zd1o,zd2o,zd3o,zd4o,zd5o,zd6o,zd7o,zd8o,zd9o,zd10o
      COMMON/DP_CPF/CPFD1,CPFD2,CPFD3,CPFD4,CPFD5,
     1              CPFD6,CPFD7,CPFD8,CPFD9,CPFD10
      COMMON/DP_INP_T/Td1i,Td2i,Td3i,Td4i,Td5i,Td6i,Td7i,Td8i,Td9i,Td10i

C---->variables from the common blocks
      DOUBLE PRECISION zd1o,zd2o,zd3o,zd4o,zd5o,zd6o,zd7o,zd8o,zd9o
      DOUBLE PRECISION CPFD1,CPFD2,CPFD3,CPFD4,CPFD5,CPFD6,CPFD7,CPFD8
      DOUBLE PRECISION Td1i,Td2i,Td3i,Td4i,Td5i,Td6i,Td7i,Td8i,Td9i
	DOUBLE PRECISION zd10o,CPFD9,CPFD10,Td10i

C---->other variables
      INTEGER maxN,Nmax,nout

      DOUBLE PRECISION sigma,Qd1a,Qd2a,Qd3a,Qd4a,Qd5a,Qd6a,Qd7a,Qd8a
      DOUBLE PRECISION Tnew(maxN,3), Told(maxN,3),Qd9a,Qd10a


C---> power through the first doubleport
      nout = NODE(Nmax,zd1o)
      Qd1a = CPFD1*(Td1i - (sigma*Told(nout,2))
     1           + (sigma-1.)*(Tnew(nout,2)))

C---> power through the second doubleport
      nout = NODE(Nmax,zd2o)
      Qd2a = CPFD2*(Td2i - (sigma*Told(nout,2))
     1           + (sigma-1.)*(Tnew(nout,2)))

C---> power through the third doubleport
      nout = NODE(Nmax,zd3o)
      Qd3a = CPFD3*(Td3i - (sigma*Told(nout,2))
     1           + (sigma-1.)*(Tnew(nout,2)))

C---> power through the fourth doubleport
      nout = NODE(Nmax,zd4o)
      Qd4a = CPFD4*(Td4i- (sigma*Told(nout,2))
     1          + (sigma-1.)*(Tnew(nout,2)))

C---> power through the fifth doubleport
      nout = NODE(Nmax,zd5o)
      Qd5a = CPFD5*(Td5i - (sigma*Told(nout,2))
     1          + (sigma-1.)*(Tnew(nout,2)))

C---> power through the sixth doubleport
      nout = NODE(Nmax,zd6o)
      Qd6a = CPFD6*(Td6i - (sigma*Told(nout,2))
     1          + (sigma-1.)*(Tnew(nout,2)))

C---> power through the seventh doubleport
      nout = NODE(Nmax,zd7o)
      Qd7a = CPFD7*(Td7i - (sigma*Told(nout,2))
     1          + (sigma-1.)*(Tnew(nout,2)))

C---> power through the eight doubleport
      nout = NODE(Nmax,zd8o)
      Qd8a = CPFD8*(Td8i - (sigma*Told(nout,2))
     1          + (sigma-1.)*(Tnew(nout,2)))

C---> power through the nine doubleport
      nout = NODE(Nmax,zd9o)
      Qd9a = CPFD9*(Td9i - (sigma*Told(nout,2))
     1          + (sigma-1.)*(Tnew(nout,2)))

C---> power through the ten doubleport
      nout = NODE(Nmax,zd10o)
      Qd10a = CPFD10*(Td10i - (sigma*Told(nout,2))
     1          + (sigma-1.)*(Tnew(nout,2)))


      RETURN
      END


C-----------------------------------------------------------------------

      SUBROUTINE CALCU_HX(maxN,Nmax,ficc,sigma,epstmp,epsua,epsmix,
     1                    SYSINFO,FLOWINFO,CAP,DDSTAR,SOURCE,DO,DU,
     2                    DL,DR,DB,DF,nh1,nh2,nh3,nh4,Told,Tinp,Tamb,
     3                    UAhxsm,modus,dtmix,time,DTmin,Dtminmod,
     4                    hxactive,dpactive,hxuavar,ncvhx,TDTSC,
     5                    Tnew,Tafter,DTint,DTisum)

C-----Programmdescription---------------------------------------------C
C
C     CALCULATOR for the temperatures at the end of a Trnsys-timestep
C     If modus=1 is used its taken care about the  errors caused
C     by mixing
C
C---------------------------------------------------------------------C
C
C     Name:     H.Dr…k
C                 
C     Version:  17.12.1998                    Date: 17.11.1993
C
C               17.12.1998  Extention to 4 heat exchangers
C               07.11.1998  extention to 10 double ports
C
C-----used variables--------------------------------------------------C
C
C      TO:      maxN              max. number of nodes in the storage
C                                 (only for dimension)
C               Nmax              number of nodes in the storage
C               ficc              Flag if its the first call of this
C                                 subroutine in trnsys ts (1..yes)
C               sigma             parameter for solving method
C               epstmp            exactness for calculating the
C                                 temperatures
C               epsua             exactness for temperature-dependence
C                                 of UAhx,s
C               epsmix            allowed error caused because of
C                                 mixing the storage
C               SYSINFO           matrix with nodepositions of hx. & dp
C               CAP               capacity - Term (Rho * Cp * V)
C               DDSTAR            matrix of DO+DU+DR+DL
C               SOURCE            source-matrix
C               DO,DU,DR,DL,DB,DF difference-koefficients
C               nh1               nodes occupied by the hx. 1
C               nh2               nodes occupied by the hx. 2
C               nh3               nodes occupied by the hx. 3
C               Told              old temperature-matrix
C               Tinp              temperature matrix with input temp.
C               Tamb              ambient temperature
C               UAhxsm            Vector with values of UA between a
C                                 hx. and the storage (only for dim.)
C               modus             kind of solution-modus
C               dtmix             temperature-difference for mixing
C               time              Trnsys-time
C               DTmin             delta_t thats stable in explicit case
C               DTminmod          Flag if DTmin has been modified (1..yes)
C               hxactive          Flag if a heatexchanger is active
C               dpactive          Flag if a doubleport is active
C               hxuavar           Flag if UAhx,s is variable (1..yes)
C               ncvhx             Flag if natural conv. mode for a hx
C               TDTSC             Flag if temperature-dependence timestep
C                                 controll is used(1..yes)
C
C      BACK:    Tnew              new temperature-matrix
C               Tafter            Tnew in the storage after mixing
C               DTint             internal delta time
C               Dtisum            sum of the internal timesteps
C
C      COMMON:  hx1na             Flag if hx1 is not active (1..yes)
C               hx2na             Flag if hx2 is not active (1..yes)
C               hx3na             Flag if hx3 is not active (1..yes)
C
C      ELSE:    kmax              maximum number of iterations
C               delt              Trnsys-timestep
C               iter              number of iterations
C               i                 help variables
C               first             Flag if first call in this
C                                 Trnsys-timestep (1..no)
C               dtsum             sum of the internal timesteps
C               sdtint            variable to save dtint
C               Qb1               power changed by hx1 before mixing
C               Qb2               power changed by hx2 before mixing
C               Qb3               power changed by hx3 before mixing
C               Qbdp              power ch. by dp (1..10)before mixing
C               Qa1               power changed by hx1 after mixing
C               Qa2               power changed by hx2 after mixing
C               Qa3               power changed by hx3 after mixing
C               Qadp              power ch. by dp (1..10) after mixing
C         Q1err,Q2err,Q3err       power error between little and dig dt
C               Qerrmax           maximum of  Q1err,Q2err,Q3err
C               Tlit              temperature after a little timestep
C               Thalf             temperature after 1 times DTint/2
C               emaxst            maximum error in the store
C               emaxhx            maximum error in the heatexchangers
C               errmax            maximum of emaxst and emaxhx
C               DTmixhx          DTint calculated because of hx
C               DTmixdp          DTint calculated because of dp
C               DTterr            DTint calculated because of the temp.
C               endot             flag if end of the trnsys-timestep
C               tmpchk            Flag if TNEW is checked against the
C                                 calculation with two steps of DTint/2
C               dtmaxst           max. temp.diff. between two timesteps
C                                 in the storage
C               dtmaxhx           max. temp.diff. between two timesteps
C                                 in the heatexchangers
C               little            Flag if SOLUTION is done with
C                                 little timesteps (1..yes)
C
C----------------------------------------------------------------------C
      use TrnsysFunctions
      COMMON/HXNOTACT/hx1na,hx2na,hx3na,hx4na

      INTEGER hx1na,hx2na,hx3na,hx4na,nh1,nh2,nh3,nh4
      INTEGER maxN,Nmax,ficc,i,TDTSC,first,little,ncvhx
      INTEGER modus,DTminmod,hxactive,dpactive,hxuavar,tmpchk,endot
      INTEGER SYSINFO(maxN,18),FLOWINFO(maxN,18)

      DOUBLE PRECISION delt,sigma,epstmp,epsua,epsmix,Tamb,dtmin,dtmix
      DOUBLE PRECISION dtmaxhx,time,dtisum,dtsum,DTint,sdtint,dtmaxst
      DOUBLE PRECISION CAP(maxN,3)
      DOUBLE PRECISION DDSTAR(maxN,3)
      DOUBLE PRECISION SOURCE(maxN,3)
      DOUBLE PRECISION DO(maxN,3),DU(maxN,3),DL(maxN,3)
      DOUBLE PRECISION DR(maxN,3),DB(maxN,3),DF(maxN,3)
      DOUBLE PRECISION Tinp(maxN,3)
      DOUBLE PRECISION Told(maxN,3),Tnew(maxN,3)
      DOUBLE PRECISION Tafter(200),Thelp(200,3)
      DOUBLE PRECISION Tlit(200,3),Thalf(200,3)
      DOUBLE PRECISION UAhxsm(maxN,3)
      DOUBLE PRECISION Qbdp(10),Qadp(10)
      DOUBLE PRECISION Qb1,Qb2,Qb3,Qb4,Qa1,Qa2,Qa3,Qa4,Q1err,Q2err,Q3err
      DOUBLE PRECISION Qerrmax,Q4err
      DOUBLE PRECISION emaxst,emaxhx,errmax,DTmixhx,DTmixdp,DTterr


      SAVE sdtint,dtsum
      DELT=getSimulationTimeStep()


C---->set flag for temperature-check
      tmpchk = TDTSC
      little = 0

C---->check if its the first call in this timestep
      if (ficc.eq.1) then
c         write(*,*)'First call of the CALCU_HX in this timestep!'
         first = 1
      else
         first = 0
      end if

      if (first.eq.1) then
         sdtint = DTmin
C------->reset dtsum
         dtsum = 0.d0
         dtisum = dtsum
C------->initial temperature after mixing
         DO 34 i=1,Nmax
            Tafter(i) = Tnew(i,2)
34       Continue
c         write(60,*)
c         write(60,*)'Time: ',time-delt,'     DTmin: ',DTmin
      else
      end if

      if (sigma.gt.0.51.or.DTminmod.eq.1) then
c      if (sigma.ge.0.0.or.DTmin.ge.DELT) then
C************************************************************************
C*    with explicit solution its not allowed to use                     *
C*    timesteps bigger than DTmin                                       *
C************************************************************************
         DTint = DTmin

         if (dtsum+dtint.gt.delt) dtint = delt - dtsum
         CALL SOLUTION(maxN,Nmax,sigma,epstmp,epsua,SYSINFO,
     1                 FLOWINFO,CAP,DDSTAR,SOURCE,DO,DU,DL,DR,
     2                 DB,DF,Told,Tinp,Tamb,UAhxsm,time,DTint,
     3                 DTmin,modus,hxuavar,ncvhx,little,dtmix,
     4                 Tnew,Tafter)
	   If (ErrorFound()) RETURN
      else

C************************************************************************
C*       modify delta_t (DTint) to speed up the execution of Type 340   *
C************************************************************************
         Dtint = sdtint

         if (dtsum+dtint.gt.delt) then
            dtint = delt - dtsum
            endot=1
c           write(*,*)'End of TRNSYS-timestep!'
         else
            endot = 0
         end if


777      Continue

c            write(*,*)'Trying to find DTint.gt.DTmin = ',DTmin,
c     1                ' using DTint = ',DTint
C************************************************************************
C*       modify delta_t to speed up the execution of Type 340           *
C************************************************************************
c         write(*,*)'Time: ',time-delt+dtsum,
c     1             '      DTnin: ',DTmin,
c     2             '      DTint: ',DTint

C************************************************************************
C*       Calculate new temperature using one big timestep               *
C************************************************************************
         CALL SOLUTION(maxN,Nmax,sigma,epstmp,epsua,SYSINFO,FLOWINFO,
     1                 CAP,DDSTAR,SOURCE,DO,DU,DL,DR,DB,DF,
     2                 Told,Tinp,Tamb,UAhxsm,time,DTint,DTmin,
     3                 modus,hxuavar,ncvhx,little,dtmix,Tnew,Tafter)
         If (ErrorFound()) RETURN

         If (tmpchk.eq.1) then
C---------->find the maximum temp. difference
            dtmaxst = 0.d0
            dtmaxhx = 0.d0
            DO 37 i=1, Nmax
               DO 38 j=1,3
                  rhelp = ABS(Tnew(i,j) - Told(i,j))
                  If (j.eq.2.) then
                     If (rhelp.gt.dtmaxst) dtmaxst=rhelp
                  else
                     If (rhelp.gt.dtmaxhx) dtmaxhx=rhelp
                  end if
38             Continue
37          Continue
C---------->check if it is necessary to calculate the new temperature
C           in two steps
            IF (dtmaxst.lt.epstmp*10.0.and.
     1             dtmaxhx.lt.epstmp*100.0) then
               DTterr = 1000.d0
               goto 771
            else
            end if
C************************************************************************
C*       Calculate new temperature in two steps                         *
C************************************************************************
775         Continue
            DTint = DTint/2.d0
            little = 1

            CALL SOLUTION(maxN,Nmax,sigma,epstmp,epsua,SYSINFO,
     1                    FLOWINFO,CAP,DDSTAR,SOURCE,DO,DU,DL,DR,
     2                    DB,DF,Told,Tinp,Tamb,UAhxsm,time,DTint,
     3                    DTmin,modus,hxuavar,ncvhx,little,dtmix,
     4                    Thalf,Tafter)
            If (ErrorFound()) RETURN
            CALL SOLUTION(maxN,Nmax,sigma,epstmp,epsua,SYSINFO,
     1                    FLOWINFO,CAP,DDSTAR,SOURCE,DO,DU,DL,DR,
     2                    DB,DF,Thalf,Tinp,Tamb,UAhxsm,time,DTint,
     3                    DTmin,modus,hxuavar,ncvhx,little,dtmix,
     4                    Tlit,Tafter)
            If (ErrorFound()) RETURN
            little =0
            DTint = DTint*2.d0
C************************************************************************
C*       Find the maximum error between Tlit (with little dt) and Tnew  *
C************************************************************************
            emaxst = 0.d0
            emaxhx = 0.d0
            DO 41 i=1,Nmax
               DO 42 j=1,3
                  error = ABS(Tnew(i,j) - Tlit(i,j))
                  If (j.eq.2.) then
                     If (error.gt.emaxst) emaxst=error
                  else
                     If (error.gt.emaxhx) emaxhx=error
                  end if
42             Continue
41          Continue

C************************************************************************
C*          check if the error ist too big                              *
C************************************************************************
            if (emaxst.gt.10.d0*epstmp) then
c              write(*,*)'store-error too big: ',emaxst,
c    1                   '   DTint: ',DTint
               If (DTint.lt.DTmin/100.d0) then
c                  write(*,*)' WARNING : Reduction of DTint because ',
c     1                      'of store-temperatures terminated! '
                  tmpchk = 0
                  goto 777
               else
                  Dtint = DTint / 2.d0
c                  write(*,*)'I will try with DTint: ',DTint
                  DO 51 i=1,Nmax
                     Tnew(i,1) = Thalf(i,1)
                     Tnew(i,2) = Thalf(i,2)
                     Tnew(i,3) = Thalf(i,3)
51                Continue
                  goto 775
               end if
            else if (emaxhx.gt.100*epstmp) then
c               write(*,*)'the hx-error is too big with DTint: ',DTint
               If (DTint.lt.DTmin/1000.d0) then
c                  write(*,*)' WARNING : Reduction of DTint because ',
c     1                      'of hx-temperatures terminated! '
                  tmpchk = 0
                  goto 777
               else
                  DTint = DTint / 2.d0
                  DO 52 i=1,Nmax
                     Tnew(i,1) = Thalf(i,1)
                     Tnew(i,2) = Thalf(i,2)
                     Tnew(i,3) = Thalf(i,3)
52                Continue
                  goto 775
               end if
            end if

            If (endot.eq.1) then
               DTterr = 1.1 * sdtint
            else
C------------->find relative maximum of emaxst and emaxhx
               errmax=0.d0
               If (emaxst.gt.emaxhx/10.d0) then
                  errmax = emaxst
               else
                  errmax = emaxhx
               end if

c               write(*,*)'emaxst: ',emaxst,'      emaxhx: ',emaxhx,
c     1                '    errmax: ',errmax


C------------->try calculate a bigger DTint because of the temperatures
               If (errmax/10.0.lt.0.8*epstmp) then
                  If (modus.eq.2) then
                     If (first.eq.1) then
                        DTterr = DTint * 2.d0
c                        write(*,*)'Next time I will use ',
c     1                            'DTterr: ',DTterr
                     else
                        DTterr = DTint
                     end if
                  else
                     DTterr = DTint * 2.d0
c                     write(*,*)'Next time I will use ',
c     1                         'DTterr: ',DTterr
                  end if
               else
                  DTterr = DTint
c                  write(*,*)'Next time I will use the same DTint!'
               end if
            end if
         else
            DTterr = 1000.d0
         end if

771      Continue



         IF (hxactive.eq.1.and.modus.eq.1) then
C************************************************************************
C*          check transferd power through hxs before and after mixing   *
C************************************************************************
C---------->calculate the power transfered before mixing
            Qb1=0.d0
            Qb2=0.d0
            Qb3=0.d0
            Qb4=0.d0

            DO 10 i=1,Nmax
               Qb1 = Qb1 + SYSINFO(i,1)*DL(i,2) * ABS(sigma*(Told(i,1)
     1              - Told(i,2)) - (sigma-1.)*(Tnew(i,1)-Tnew(i,2)))
c     2              + DF(i,2) * ABS(sigma*(Told(i,2)-Tinp(i,2))
c     3              - (sigma-1.)*(Tnew(i,2)-Tinp(i,2)))
               Qb2 = Qb2 + SYSINFO(i,2)*DR(i,2) * ABS(sigma*(Told(i,3)
     1              -Told(i,2)) - (sigma-1.)*(Tnew(i,3)-Tnew(i,2)))
               Qb3 = Qb3 + SYSINFO(i,3)*DR(i,2) * ABS(sigma*(Told(i,3)
     1              -Told(i,2)) - (sigma-1.)*(Tnew(i,3)-Tnew(i,2)))
               Qb4 = Qb4 + SYSINFO(i,4)*DL(i,2) * ABS(sigma*(Told(i,1)
     1              -Told(i,2)) - (sigma-1.)*(Tnew(i,1)-Tnew(i,2)))

10          Continue


C---------->calculate the power transfered after mixing
            Qa1=0.d0
            Qa2=0.d0
            Qa3=0.d0
            Qa4=0.d0

            DO 30 i=1,Nmax
               Qa1 = Qa1 + SYSINFO(i,1)*DL(i,2) * ABS(sigma*(Told(i,1)
     1              -Told(i,2)) - (sigma-1.)*(Tnew(i,1)-Tafter(i)))
c     2              + DF(i,2) * ABS(sigma*(Told(i,2)-Tinp(i,2))
c     3              - (sigma-1.)*(Tafter(i)-Tinp(i,2)))
               Qa2 = Qa2 + SYSINFO(i,2)*DR(i,2) * ABS(sigma*(Told(i,3)
     1              -Told(i,2)) - (sigma-1.)*(Tnew(i,3)-Tafter(i)))
               Qa3 = Qa3 + SYSINFO(i,3)*DR(i,2) * ABS(sigma*(Told(i,3)
     1              -Told(i,2)) - (sigma-1.)*(Tnew(i,3)-Tafter(i)))
               Qa4 = Qa4 + SYSINFO(i,4)*DL(i,2) * ABS(sigma*(Told(i,1)
     1              -Told(i,2)) - (sigma-1.)*(Tnew(i,1)-Tafter(i)))

30          Continue


C---------->calculate the relative error between Qbi and Qai
            Q1err = 0.d0
            Q2err = 0.d0
            Q3err = 0.d0
            Q4err = 0.d0   
            If (Qb1.ne.0.0) Q1err = ABS((Qb1-Qa1)/Qb1)
            If (Qb2.ne.0.0) Q2err = ABS((Qb2-Qa2)/Qb2)
            If (Qb3.ne.0.0) Q3err = ABS((Qb3-Qa3)/Qb3)
            If (Qb4.ne.0.0) Q4err = ABS((Qb4-Qa4)/Qb4)


C---------->find the maximum of Q1err,Q2err,Q3err and Q4err
            Qerrmax=0.d0
            if (Q1err.gt.Qerrmax) Qerrmax = Q1err
            if (Q2err.gt.Qerrmax) Qerrmax = Q2err
            if (Q3err.gt.Qerrmax) Qerrmax = Q3err
            if (Q4err.gt.Qerrmax) Qerrmax = Q4err

C---------->check if relative error between Qbi and Qai is too big
            if (Qerrmax.gt.epsmix) then
c               write(*,*)' Error too big with ',DTint,
c     1                '    Qerrmax: ',Qerrmax,
c     1                '     Delta_Q: ',Qa1-Qb1
               If (DTint.lt.DTmin/100.0) then
c                  write(*,*)' WARNING : Reduction of DTint because',
c     1                   ' of hx-energy terminated! '
               else
                  Dtint = DTint * (epsmix/Qerrmax) * 0.9
                  tmpchk = 0
                  goto 777
               end if
            else
c              write(60,*)' Error not too big with ',DTint,
c     1                   '    Qerrmax: ',Qerrmax,
c     1                   '     Delta_Q: ',Qa1-Qb1
c              write(60,*)
               if (Qerrmax.lt.(epsmix*0.8)) then
c                 write(60,*)'Next time I will use bigger DTint'
C---------------->try calculate a bigger DTint because of the transfered
C                 energy
                  if (Qerrmax.ne.0.0) then
                     DTmixhx = DTint * (epsmix/Qerrmax) * 0.9
                  else
                     DTmixhx = DTint * 2.0
                  end if
               else
                  DTmixhx = DTint
               end if
               If (endot.eq.1) DTmixhx = 1.1*sdtint
            end if
         else
           DTmixhx = 1000.d0
         end if


         IF (dpactive.eq.1.and.modus.eq.1) then
C************************************************************************
C*       check transferd power through dps before and after mixing      *
C************************************************************************
C---------->calculate the power transfered before mixing
            CALL DP_POWER(maxN,Nmax,Told,Tnew,sigma,Qbdp(1),
     1                    Qbdp(2),Qbdp(3),Qbdp(4),Qbdp(5),
     2                    Qbdp(6),Qbdp(7),Qbdp(8),Qbdp(9),
     3                    Qbdp(10))
            If (ErrorFound()) RETURN

C---------->calculate the power transfered after mixing
C           first put temperatures after mixing into a matrix
            DO 31 i=1,Nmax
               Thelp(i,2) = Tafter(i)
31          Continue
            CALL DP_POWER(maxN,Nmax,Told,Thelp,sigma,Qadp(1),
     1                    Qadp(2),Qadp(3),Qadp(4),Qadp(5),
     2                    Qadp(6),Qadp(7),Qadp(8),Qadp(9),
     3                    Qadp(10))
            If (ErrorFound()) RETURN

C---------->calculate the relative error between Qbdp and Qadp
C           and find the maxinum
c            write(*,*)'Next timestep!     DTint: ',DTint
            Qerrmax = 0.d0
            DO 33 i=1,10
               If (Qbdp(i).ne.0) then
                  rhelp = ABS((Qbdp(i)-Qadp(i))/Qbdp(i))
               else
                  rhelp = 0.d0
               end if
               If (rhelp.gt.Qerrmax) Qerrmax = rhelp
c               write(*,*)'Qbdp: ',Qbdp(i),'     Qadp: ',Qadp(i),
c     1                   '      rel. err: ',rhelp
33          Continue


C---------->if the maximum of transfered energy is very little, it's a bigger
C           it's a bigger value of Qerrmax allowed
C---------->find the maximum transferd enrgy
            rhelp = 0.d0
            DO 57 i=1,10
               If (ABS(Qadp(i)).gt.rhelp) rhelp = ABS(Qadp(i))
57          Continue

C---------->calculate new Qerrmax
            If (rhelp*Dtint.lt.CAP(Nmax,2)*1.e-4) then
                Qerrmax = (rhelp*DTint)/(CAP(Nmax,2)*1.e-4)
                Qerrmax = Qerrmax * epsmix
            else
            end if


C---------->check if relative error between Qbdp and Qadp is too big
            if (Qerrmax.gt.epsmix) then
               If (DTint.lt.DTmin/10000.0) then
c                  write(*,*)' WARNING : Reduction of DTint because',
c     1                   ' of dp-energy terminated! '
               else
                  Dtint = DTint * (epsmix/Qerrmax) * 0.9
                  tmpchk = 0
                  goto 777
               end if
            else
c               write(*,*)' Error not too big with ',DTint,
c     1                   '    Qerrmax: ',Qerrmax,
c              write(60,*)
               if (Qerrmax.lt.(epsmix*0.8)) then
c                  write(*,*)'Next time I will use bigger DTint'
C---------------->try calculate a bigger DTint because of the transfered
C                 energy
                  if (Qerrmax.ne.0.0) then
                     DTmixdp = DTint * (epsmix/Qerrmax) * 0.9
                  else
                     DTmixdp = DTint * 2.0
                  end if
               else
                  DTmixdp = DTint
               end if
               If (endot.eq.1) DTmixdp = 1.1*sdtint
            end if
         else
           DTmixdp = 1000.d0
         end if


C************************************************************************
C*     the lowest time is used                                          *
C************************************************************************
         IF (DTmixhx.gt.DTmixdp) then
            rhelp = DTmixdp
c            write(*,*)'DTmixdp is lower as DTmixhx!'
         else
            rhelp = DTmixhx
c            write(*,*)'DTmixhx is lower as DTmixdp!'
         end if
         IF (rhelp.gt.DTterr) then
            sdtint = DTterr
c            write(*,*)'I will use the temperature-time DTterr: ',
c     1                    DTterr
         else
            sdtint = rhelp
c            write(*,*)'I will use the energy-time  DTqerr: ',rhelp
         end if

C------->take care that the timesteps are not too big if the
C        heatexchanger is not active and not transformed
         If (TDTSC.eq.0.and.hxactive.eq.0) then
            If (hx1na.eq.0.and.nh1.gt.0) sdtint = 10 * DTmin
            If (hx2na.eq.0.and.nh2.gt.0) sdtint = 10 * DTmin
            If (hx3na.eq.0.and.nh3.gt.0) sdtint = 10 * DTmin
            If (hx4na.eq.0.and.nh4.gt.0) sdtint = 10 * DTmin
         else
         end if

C------->take care that the timesteps are not too big
C        if TSTSC is not used
         If (TDTSC.eq.0.and.sdtint.gt.(200.0*DTmin))
     1       sdtint = 200.d0 * DTmin

         If (sdtint.gt.DELT) sdtint = DELT
      end if


C---->save actual delta_time
      dtsum = dtsum + dtint
      dtisum = dtsum
c      IF (time.gt.tfinal-delt) CLOSE(60)


      RETURN
      END


C-----------------------------------------------------------------------

      SUBROUTINE S_STORE(maxN,Nmax,dt,sigma,CAP,DDSTAR,SOURCE,DO,
     1                   DU,DL,DR,DB,DF,TOLD,Tinp,Tamb,Tnew)

C-----Programmdescription---------------------------------------------C
C
C     Calculates the temperatures in the store by using a
C     linera equation system after GAUSS
C
C---------------------------------------------------------------------C
C
C     Name:     H.Dr…k
C
C     Version:  14.02.1994                    Date: 14.02.1994
C
C-----used variables--------------------------------------------------C
C
C      TO:      maxN              max. number of nodes in the storage
C                                 (only for dimension)
C               Nmax              number of nodes in the storage
C               DT                timestep
C               sigma             parameter for solving method
C               CAP               capacity - Term (Rho * Cp * V)
C               DDSTAR            matrix of DO+DU+DR+DL
C               SOURCE            source-matrix
C               DO,DU,DR,DL,DB,DF difference-koefficients
C               Told              old temperature-matrix
C               Tinp              temperature matrix with input temp.
C               Tamb              ambient temperature
C
C      BACK:    Tnew              new temperature-matrix
C
C      ELSE:    i,j               help variables
C               col               column of a matrix
C               A                 diagonal elements of the matrix
C               B                 upper diagonal elements of the matrix
C               C                 lower diagonal elements of the matrix
C               P                 boundary vector
C               H                 help vector
C               i,j                 dto
C
C----------------------------------------------------------------------C

        INTEGER maxN,Nmax,col,i,j

        DOUBLE PRECISION dt,sigma,Tamb
        DOUBLE PRECISION CAP(maxN,3)
        DOUBLE PRECISION DDSTAR(maxN,3)
        DOUBLE PRECISION SOURCE(maxN,3)
        DOUBLE PRECISION DO(maxN,3),DU(maxN,3),DL(maxN,3)
        DOUBLE PRECISION DR(maxN,3),DB(maxN,3),DF(maxN,3)
        DOUBLE PRECISION Tinp(maxN,3)
        DOUBLE PRECISION Told(maxN,3),Tnew(maxN,3)

        DOUBLE PRECISION A(200),B(200),C(200),D(200),H(200),P(200)


C**********************************************************************
C     change values for A,B,C,D to calculate the temp. of the store   *
C**********************************************************************
      col = 2
      Do 10 i=1,Nmax
         j = col
         C(i) = (sigma-1.) * DU(i,j)
         B(i) = (sigma-1.) * DO(i,j)
         A(i) = CAP(i,j)/DT - ((sigma-1.) * (DDSTAR(i,j)))
         IF (A(i).lt.0.00001) A(i) = 1.e27

         D(i) = sigma*(DU(i,j)*Told(i-1,j) + DO(i,j)*Told(i+1,j))
     1        + DL(i,j)*Told(i,j-1) + DR(i,j)*Told(i,j+1)
     2        + DB(i,j)*Tamb + DF(i,j)*Tinp(i,j) + SOURCE(i,j)
     3        + (CAP(i,j)/DT - sigma*DDSTAR(i,j))*Told(i,j)
10    Continue

C**********************************************************************
C     calculate new storage temperatures                              *
C**********************************************************************
      H(1) = -B(1)/A(1)
      P(1) = D(1)/A(1)

      DO 20 i = 2,Nmax
         H(i) = -B(i)/(A(i) + H(i-1)*C(i))
         P(i) = (D(i) - P(i-1)*C(i))/(A(i)+H(i-1)*C(i))
c        write(*,*)'i: ',i,'   H(i): ',H(i),'    P(i): ',P(i)
20    Continue

      Tnew(Nmax,col) = P(Nmax)
      DO 22 n=1,Nmax
         i = Nmax + 1 - n
         Tnew(i,col) = P(i) + H(i) * Tnew(i+1,col)
22    Continue


      RETURN
      END


C-----------------------------------------------------------------------

      SUBROUTINE S_DIRECT(maxN,Nmax,dt,sigma,sodir,SYSINFO,
     1                    CAP,DDSTAR,DO,DU,DL,DR,BO,Tnew)

C-----Programmdescription---------------------------------------------C
C
C     Direct solution of a linera equation system
C
C---------------------------------------------------------------------C
C
C     Name:     H.Dr…k
C
C     Version:  17.12.1998                    Date: 14.02.1994
C
C               17.12.1998  Extention to 4 heat exchangers
C
C-----used variables--------------------------------------------------C
C
C      TO:      maxN              max. number of nodes in the storage
C                                 (only for dimension)
C               Nmax              number of nodes in the storage
C               DT                timestep
C               sigma             parameter for solving method
C               sodir             direction of solving the equation
C                                 system  (1..upwards / -1..downards)
C               SYSINFO           matrix with nodepositions of hx. & dp
C               CAP               capacity - Term (Rho * Cp * V)
C               DDSTAR            matrix of DO+DU+DR+DL
C               DO,DU,DR,DL       difference-koefficients
C               BO                matrix with boundary values
C
C      BACK:    Tnew              new temperature-matrix
C
C      COMMON:  hx1na             Flag if hx1 is not active (1..yes)
C               hx2na             Flag if hx2 is not active (1..yes)
C               hx3na             Flag if hx3 is not active (1..yes)
C               hx4na             Flag if hx4 is not active (1..yes)
C
C
C      ELSE:    smod              kind of direct-solution method
C                                    1...hx1       2...hx2/hx3
C                                    3...hx1&hx2/hx3
C                                    4...store only
C               E1,E2,E3          help variables
C               H1,H2,H3,H4       help variables
C               i,kl,kr,n         help variables
C               s                 help variable
C
C----------------------------------------------------------------------C

      COMMON/HXNOTACT/hx1na,hx2na,hx3na,hx4na

      INTEGER maxN,Nmax,sodir,smod,i,kl,kr,n
      INTEGER hx1na,hx2na,hx3na,hx4na
      INTEGER SYSINFO(maxN,18)

      DOUBLE PRECISION dt,sigma,s
      DOUBLE PRECISION CAP(maxN,3)
      DOUBLE PRECISION DDSTAR(maxN,3)
      DOUBLE PRECISION DO(maxN,3),DU(maxN,3),DL(maxN,3)
      DOUBLE PRECISION DR(maxN,3),BO(maxN,3)
      DOUBLE PRECISION Tnew(maxN,3)
      DOUBLE PRECISION E1,E2,E3,H1,H2,H3,H4,rhelp


      S = (sigma - 1.)


C---->here starts the loop over all nodes
      DO 10 n=1,Nmax
         IF (sodir.eq.-1) then
            i = Nmax + 1 - n
         else
            i = n
         end if

C------->check which temperatures have to be calculated
         kl = 0
         if ((ABS(SYSINFO(i,1)).eq.1.and.hx1na.ne.1).or.
     1       (ABS(SYSINFO(i,4)).eq.1.and.hx4na.ne.1)) kl = 1
         kr = 0
         if ((ABS(SYSINFO(i,2)).eq.1.and.hx2na.ne.1).or.
     1       (ABS(SYSINFO(i,3)).eq.1.and.hx3na.ne.1)) kr = 1

         smod = 4
         If (kl.eq.1.and.kr.eq.0) smod = 1
         If (kl.eq.0.and.kr.eq.1) smod = 2
         If (kl.eq.1.and.kr.eq.1) smod = 3

c         write(*,*)'I: ',i,'    smod: ',smod

C------->general for all possible smod
         E2 = CAP(i,2)/DT - ((sigma-1.) * (DDSTAR(i,2)))

         If (smod.eq.1) then
C**********************************************************************
C        calculate temperatures of the store and hx1                  *
C**********************************************************************
            E1 = CAP(i,1)/DT - ((sigma-1.) * (DDSTAR(i,1)))
C---------->calculate temperature of the node form hx1 or hx4
            IF ((ABS(SYSINFO(i,1))+ABS(SYSINFO(i,4))).ne.0) then
               rhelp = E2*(-BO(i,1) + (S*DO(i,1)*Tnew(i+1,1))
     1                     + (S*DU(i,1)*Tnew(i-1,1)))
               Tnew(i,1) = (rhelp + (BO(i,2)*S*DL(i,2)))
     1                    / ((S*DL(i,2)*S*DL(i,2)) - (E1*E2))
            else
               Tnew(i,1) = 0.0
            end if
C---------->calculate temperature of the storage node
            Tnew(i,2) = (BO(i,2) - (S*DL(i,2)*Tnew(i,1)))/E2

         else if (smod.eq.2) then
C**********************************************************************
C        calculate temperatures of the store and hx2/hx3              *
C**********************************************************************
            E3 = CAP(i,3)/DT - ((sigma-1.) * (DDSTAR(i,3)))
C---------->calculate temperature of the node form hx2 or hx3
            IF ((ABS(SYSINFO(i,2))+ABS(SYSINFO(i,3))).ne.0) then
               rhelp = E2*(BO(i,3) - (S*DO(i,3)*Tnew(i+1,3))
     1                     - (S*DU(i,3)*Tnew(i-1,3)))
               Tnew(i,3) = (rhelp - (BO(i,2)*S*DR(i,2)))
     1                    / ((E3*E2) - (S*DR(i,2)*S*DR(i,2)))
            else
               Tnew(i,3) = 0.0
            end if
C---------->calculate temperature of the storage node
            Tnew(i,2) = (BO(i,2) - (S*DR(i,2)*Tnew(i,3)))/E2

         else if (smod.eq.3) then
C**********************************************************************
C        calculate temperatures of the store and hx1/hx4 and hx2/hx   *
C**********************************************************************
C---------->calculate help variables
            E1 = CAP(i,1)/DT - ((sigma-1.) * (DDSTAR(i,1)))
            E3 = CAP(i,3)/DT - ((sigma-1.) * (DDSTAR(i,3)))

            H1 = (S*DL(i,2)/E1) - (E2/(S*DL(i,2)))
            H2 = (BO(i,1)-(S*DO(i,1)*Tnew(i+1,1))-
     1            (S*DU(i,1)*Tnew(i-1,1)))/(E1*H1)
            H2 = H2 - BO(i,2)/(S*DL(i,2)*H1)
            H3 = (BO(i,3) - (S*DO(i,3)*Tnew(i+1,3))-
     1            (S*DU(i,3)*Tnew(i-1,3)))/(S*DR(i,2))
            H4 = (E3/(S*DR(i,2))) + (DR(i,2)/(DL(i,2)*H1))

            Tnew(i,3) = (H3-H2)/H4
            Tnew(i,2) = H2 + ((DR(i,2)*Tnew(i,3))/(DL(i,2)*H1))
            Tnew(i,1) = (BO(i,2) - (S*DR(i,2)*Tnew(i,3)) -
     1                   (E2*Tnew(i,2)))/(S*DL(i,2))

         else
C**********************************************************************
C        calculate temperatures of the store                          *
C**********************************************************************
            Tnew(i,2) = BO(i,2)/E2

         end if

10    Continue


      RETURN
      END



C-----------------------------------------------------------------------


      SUBROUTINE NC_EX_HX(maxN,Nmax,FLOWINFO,Told,nhx,UAhis,bhi1,
     1                    bhi2,bhi3,UAhiT,smhx,Tpin,mpri,cppri,
     2                    Tsin,cpsek,Tpout,Tsout,msek,Qhx)

      use TrnsysFunctions
C-----Programmdescription---------------------------------------------C
C
C     If heat exchangers are operated in the natural convection
C     charging/discharging mode, they are treated as external
C     heat exchangers and charging is performed via a double port.
C     This subroutine calcuates the secondary mass flow rate
C     via this external heat exchanger and its outlet temperatures  
C
C---------------------------------------------------------------------C
C
C     Name:     H.Dr…k
C
C     Version:  15.03.2001                    Date: 19.11.1998
C
C               15.03.2001  check of min calc. temp. (peak problem)
C               30.07.2000  check of calculated temp. (peak problem)
C               09.02.1999  Algo for calc of outlet temp. optimised
C               05.01.1999  Algo for calc of mcon (msek) optimised
C               17.12.1998  Extention to 4 heat exchangers
C
C-----used variables--------------------------------------------------C
C
C      TO:      maxN              max. number of nodes in the storage
C                                 (only for dimension)
C               Nmax              number of nodes in the storage
C               FLOWINFO          matrix with nodes with massflow
C               Told              old temperature-matrix
C               nhx               number of the actual heatexchanger
C               UAhis             UA of heatexchanger
C               bhi1,bhi2,bhi3    parameters for calculation of UAhxsm
C               UAhiT             time dependend factor for UA of LSH i
C               smhx              factor for secondary mass flow rate
C               Tpin              inlet temp. primary side (hx)
C               cppri             spez. heat cap. rate primary side (hx)
C               mpri              mass flow rate primary side (hx)
C               Tsin              inlet temp. secondary side (hx)
C               cpsek             spez. heat cap. rate sec. side (store)
C
C      BACK:    Tpout             outlet temp. primary side (hx)
C               Tsout             outlet temp. secondary side (hx)
C               msek              mass flow rate secondary side (hx)
C               Qhx               power transferred via the hx
C
C      ELSE:    error             error
C               CPFpri            capacity-flow rate primary side
C               CPFsek            capacity-flow rate secondary side
C               dir               Flag for flow-direction
C                                 (1..upwards,-1...downwards)
C               mue               sum based on capacity flow rates
C               CPFmin            minimal capacity-flow rate
C               ratio             ratio CPFpri / CPFsek
C               tetam             mean logarithmic temperature
C               UApri             UA for primary side
C               UAsek             UA for secondary side
C               UAhx              UA-value of whole hx
C               Qhx               power transferred via the hx
C               Qhxold            Qhx from iteration before
C               Tdp               temperature diff. primary side
C               Tds               temperature diff. secondary side
C               Temp              temperature of a store node
C               Tmax              maximum temperature occuring
C               Tmin              maximum temperature occuring
C               tmaxli            flag if Tmax was used for limitation
C               tminli            flag if Tmin was used for limitation
C               co                column of the FLOWINFO-matrix
C               mcon              convective mass flow
C               mseko             old value of msek  
C               mode              mode for calculation of natural
C                                 convection driving force (1 or 2)
C               rohin             density at inlet
C               rohout            density at outlet
C               rohm              mean density
C               roh               density
C               droh              density difference
C               iter              number of iterations
C               i,n               help variable
C
C----------------------------------------------------------------------C

        INTEGER maxN,Nmax,nhx,co,i,n
        INTEGER dir,iter,mode,tminli,tmaxli
        INTEGER FLOWINFO(maxN,18)

        DOUBLE PRECISION Told(maxN,3)

        DOUBLE PRECISION error,mue,mcon
        DOUBLE PRECISION UAhis,bhi1,bhi2,bhi3,smhx
        DOUBLE PRECISION Tpin,Tpout,Tsin,Tsout,Tmin,Tmax
        DOUBLE PRECISION mpri,msek,mseko,cppri,cpsek
        DOUBLE PRECISION CPFpri,CPFsek,CPFmin,ratio,tetam
        DOUBLE PRECISION UAhx,Qhx,Qhxold
        DOUBLE PRECISION UApri,UAsek
        DOUBLE PRECISION Temp,Tdp,Tds
        DOUBLE PRECISION UAhiT
        DOUBLE PRECISION roh,rohm,rohin,rohout,droh


C**********************************************************************
C     general initialisation                                          *
C**********************************************************************
      iter = 0
      
C---->set mode for calculation of natural convection driving force
      if (smhx.gt.0.0) then
         mode = 1
      else
         mode = 0
      end if


c      write(*,*)'mode: ',mode

      If (smhx.ne.0.0) smhx = ABS(smhx)


C----->for Test
c       UAhx = 587.52
c       Tpin = 100.0
c       mpri = 835.0
c       cppri = 1.012
c       Tsin = 20.0
c       msek = 100.0
c       cpsek = 4.182


C**********************************************************************
C        calculate mean density of water in the store (in the         *
C        range of the virtual double port used for charging)          *     
C**********************************************************************
         co = nhx + 10
         rohm = 0
         n = 0
         dir = 0
c         write(*,*)'co: ',co
      DO 40 i=1,Nmax
         if (ABS(FLOWINFO(i,co)).ne.0) then
            n = n + 1
            Temp = Told(i,2)            
            dir = FLOWINFO(i,co)
            roh = 1001.667 - (0.11012*Temp) - (0.00327*Temp**2)
            rohm = rohm + roh
c            write(*,*)'i: ',i,' Temp:',Temp,'roh:',roh,' rohm:',rohm
         else
         end if
40    Continue
         if (n.ne.0) rohm = rohm/n

C**********************************************************************
C     find maximum temperature                                        *
C**********************************************************************
      Tmax = 0.0
      DO 50 i=1,Nmax
         if (ABS(FLOWINFO(i,co)).ne.0) then            
            Temp = Told(i,2)
            If (Temp.gt.Tmax) Tmax = Temp
         else
         end if
50    Continue

      If (Tpin.gt.Tmax) Tmax = Tpin
      If (Tsin.gt.Tmax) Tmax = Tsin

C**********************************************************************
C     find minimum temperature                                        *
C**********************************************************************
      Tmin = 1000.0
      DO 60 i=1,Nmax
         if (ABS(FLOWINFO(i,co)).ne.0) then            
            Temp = Told(i,2)
            If (Temp.lt.Tmin) Tmin = Temp
         else
         end if
60    Continue

      If (Tpin.lt.Tmin) Tmin = Tpin
      If (Tsin.lt.Tmin) Tmin = Tsin


C**********************************************************************
C     here starts loop for iterative calculation procedure            *
C**********************************************************************
133   Continue

         tmaxli = 0
         tminli = 0

C------->guess new values to avoid endless iterations
         If (Tpout.eq.Tpin) Tpout = Tpin - 0.4 * (Tpin - Tsin)
         If (Tsout.eq.Tsin) Tsout = Tsin + 0.4 * (Tpin - Tsin)

         iter = iter + 1

C**********************************************************************
C     calculation of convective mass flow rate (msek)                 *
C**********************************************************************
C------->calculate density of water at inlet unsing two modes
C        specified by the sign of smhx
         if (mode.eq.1.and.rohm.ne.0.0) then
            rohin = rohm
         else
            rohin = 1001.667 - (0.11012*Tsin) - (0.00327*Tsin**2)
        end if

      

C------->calculate density of water at outlet
         rohout = 1001.667 - (0.11012*Tsout) - (0.00327*Tsout**2)

C------->calculate convective flow based ond density difference
C        factor 0.9999 for stability
         droh = ((rohout * 0.9999) - rohin) * dir

         mcon = droh * smhx * UAhiT
         mcon = MAX(0.0,mcon)

         if (iter.gt.1) then         
            if (iter.lt.100) then
               msek = (mcon * 0.7) + (mseko * 0.3)
            else if (iter.lt.400) then
               msek = (mcon * 0.5) + (mseko * 0.5)
            else
               msek = (mcon * 0.05) + (mseko * 0.95)
            end if
         else
            msek = mcon
         end if

C------->to avoid numerical problems
         if (msek.gt.0.0.and.msek.lt.1.0) msek = 1.0

         mseko = msek

C**********************************************************************
C     Calculate UA as a function of temp.difference and flow rate     *
C     Note: Calculation of UAhx for this case differs form the one    *
C           for common internal hx                                    *
C**********************************************************************
C        calculation of reference values 
C ------>temperature difference primary side
         Tdp = ABS(Tpin - Tpout)
C ------>temperature difference secondary side
         Tds = ABS(Tsin - Tsout)


         if (bhi1.ne.0.or.bhi2.ne.0.or.bhi3.ne.0) then
C---------> calculation for primary side
            if (Tdp.eq.0.and.mpri.eq.0) then
               UApri = (UAhis * (Tpin**bhi3))
            else if (Tdp.eq.0.and.mpri.gt.0.) then
               UApri = (UAhis * ((mpri/3600.)**bhi1)
     1                       * (Tpin**bhi3))
            else if (Tdp.gt.0.and.mpri.eq.0.) then
               UApri = (UAhis * (Tdp**bhi2) * (Tpin**bhi3)) 
            else
               UApri = (UAhis * ((mpri/3600.)**bhi1)
     1                       * (Tdp**bhi2) * (Tpin**bhi3))
            end if

C---------> calculation for secondary side
            if (Tds.eq.0.and.msek.eq.0) then
               UAsek = (UAhis * (Tsin**bhi3))
            else if (Tds.eq.0.and.msek.gt.0.) then
               UAsek = (UAhis * ((msek/3600.)**bhi1)
     1                       * (Tsin**bhi3))
            else if (Tds.gt.0.and.msek.eq.0.) then
               UAsek = (UAhis * (Tds**bhi2) * (Tsin**bhi3))
            else
               UAsek = (UAhis * ((msek/3600.)**bhi1)
     1                       * (Tds**bhi2) * (Tsin**bhi3))
            end if
C---------> calculation of UAhx (for the whole heat exchanger)


            IF (UApri.ne.0.0.and.UAsek.ne.0.0) then
               UAhx = 1.0 /((1.0/UApri) + (1.0/UAsek))
            else if (UApri.eq.0.0) then
               UAhx = UAsek
            else 
               UAhx = UApri
            end if
C---------- use default value in order start iteration
            IF (UAhx.eq.0.0) UAhx = 1000.0
         else
C---------> use constant UAhx
            UAhx = UAhiT * UAhis  
         end if

c         write(*,*)'UAhx:' ,UAhx

C**********************************************************************
C     calculation of secondary side temperatures                      *
C     (equations based on script "Berechnung von Wвme｜ertragern"    *
C**********************************************************************
C------->calculation of capacity flow rates
         CPFpri = mpri * cppri
         CPFsek = msek * cpsek


c         write(*,*)'CPFpri: ', CPFpri,'   CPFsek: ', CPFsek

         CPFmin = MIN(CPFpri,CPFsek)

         IF (CPFmin.gt.0.0) then
C---------->used to avoid numerical problems   
            ratio = CPFpri/CPFsek
            if (ratio.lt.0.002) then
               CPFpri = 0.0
               CPFmin = 0.0
            else if (ratio.gt.500) then
               CPFsek = 0.0
               CPFmin = 0.0
            else
            end if
         else
         end if

         IF (CPFmin.gt.0.0) then
            IF (ratio.gt.0.999.and.ratio.lt.1.001) then
C---------->use simplified calculation
               Tsout = ((UAhx/CPsek)*Tpin + Tsin)/(1 + (UAhx/CPsek))
               Tpout = Tpin - (CPFsek/CPFpri) * (Tsout - Tsin)
C------------->calculation of transfered power
               Qhx = CPFpri * (Tpin - Tpout)
            else 
               mue = ((1.0 / CPFpri) - (1.0 / CPFsek))

               If (ABS(mue*UAhx).gt.70.0) then
C------------->use simplified calc method to avoid numerical problems
                  Tpout = Tpin - (1.0 / ratio) * (Tpin - Tsin)
C---------------->plausibility check of max calculated temperature
                  IF (Tpout.gt.Tmax) Tpout = Tmax
C---------------->plausibility check of min calculated temperature
                  IF (Tpout.lt.Tmin) Tpout = Tmin
                  Tsout = Tsin - (CPFpri/CPFsek) * (Tpout - Tpin)

C---------------->calculation of transfered power
                  Qhx = CPFpri * (Tpin - Tpout)

               else
C---------------->calculation of new outlet temperatures
                  Tpout = Tpin - ((1.0 - EXP(-mue*UAhx)) /
     1                    (1.0 - ratio*EXP(-mue*UAhx))) * (Tpin - Tsin)

                  Tsout = Tpin - ((1.0 - ratio) /
     1                    (1.0 - ratio*EXP(-mue*UAhx))) * (Tpin - Tsin)
C---------------->plausibility check of max calculated temperatures
                  tmaxli = 0
                  IF (Tpout.gt.Tmax) then
                     tmaxli = 1
                     Tpout = Tmax
                  else
                  end if

                  IF (Tsout.gt.Tmax) then
                     tmaxli = 1
                     Tsout = Tmax
                  else
                  end if

C---------------->plausibility check of min calculated temperatures
                  tminli = 0
                  IF (Tpout.lt.Tmin) then
                     tminli = 1
                     Tpout = Tmin
                  else
                  end if

                  IF (Tsout.lt.Tmin) then
                     tminli = 1
                     Tsout = Tmin
                  else
                  end if

C---------------->calculation of mean logaritimic temp. and power

                  if ((Tpin.ne.Tsout).and.(Tpout.ne.Tsin)) then
                     tetam = ((Tpin - Tsout) - (Tpout - Tsin)) /
     1                       dlog((Tpin - Tsout) / (Tpout - Tsin))

                     Qhx = UAhx * tetam
C------------------->calculation of power if outlet temps are limited 
                     If (tmaxli.eq.1.or.tminli.eq.1) then
                        Qhx = CPFpri * (Tpin - Tpout)
                        IF (Tsin.ne.Tsout) then
                           CPFsek = Qhx /(Tsin - Tsout)
                           mesk  = CPFsek/cpsek
                           mseko = mesk
                        else
                           msek  = 0.0
                           mseko = 0.0
                        end if
                     else
                     end if

                  else
C---------------->used to handle numerical inaccuracies
C------------------->plausibility check of max calculated temperatures
                     IF (Tpout.gt.Tmax) Tpout = Tmax
C------------------->plausibility check of min calculated temperatures
                     IF (Tpout.lt.Tmin) Tpout = Tmin
                     Qhx = CPFpri * (Tpin - Tpout)
                     Tsout = Tsin + (CPFpri/CPFsek) * (Tpin - Tpout)

                  end if
               end if
            end if
         else if (CPFmin.eq.0.0) then
C---------->no flow through hx
            Tpout = Tpin
            Tsout = Tsin
            Qhx = 0.0
         else
C---------->flow through hx in the wrong direction
	      Call Messages(-1,'Negative flow rate through heat exchanger 
     &(operated in stratified charging mode 2)','FATAL',-1,340)
	      If (ErrorFound()) Return
         end if


C**********************************************************************
C     check if convergence (of power) is o.k.                         *
C**********************************************************************

c         write(*,*)'After iteration'
c         write(*,*)'Qhx: ',Qhx,'    Qhxold:',Qhxold
c         write(*,*)'CPFpri: ', CPFpri,'   CPFsek: ', CPFsek


         if (Qhx.ne.0.0) then
            error = (Qhx - Qhxold) / Qhx
            Qhxold = Qhx
            if (error.ne.0.0) error = ABS(error)
         else
            if (iter.lt.3) error = 1.0
         end if



c         write(*,*)'iter: ',iter,'   error:  ',error
c         write(*,*)'Tpin:',Tpin,'   Tpout:',Tpout,'   mpri:',mpri
c         write(*,*)'Tsin:',Tsin,'   Tsout:',Tsout,'   msek:',msek

         if (iter.gt.700) then
            IF (Qhx.ne.0.0) then
               write(*,*)' Warning from Type 340:'
               write(*,*)' No convergence in Subroutine NC_EX_HX !!'            
            else
            end if
         else if (error.gt.0.0001.or.iter.lt.7) then
            goto 133
         end if


      RETURN
      END


C-----------------------------------------------------------------------


      SUBROUTINE IN_VI_DP(maxN,Nmax,FLOWINFO,Told,
     1                    Qhx1,Qhx2,Qhx3,Qhx4)
      use TrnsysFunctions
C-----Programmdescription---------------------------------------------C
C
C     Initialises virtual double ports if heat exchangers are  
C     used in natural convection mode (schx=2) 
C
C---------------------------------------------------------------------C
C
C     Name:     H.Dr…k
C
C     Version:  17.12.1998                    Date: 23.11.1998
C
C               17.12.1998  Extention to 4 heat exchangers
C
C-----used variables--------------------------------------------------C
C
C      TO:      maxN              max. number of nodes in the storage
C                                 (only for dimension)
C               Nmax              number of nodes in the storage
C               FLOWINFO          matrix with nodes with massflow
C               Told              old temperature-matrix
C
C      BACK:    Qhx1              power transferred via hx1 (external)
C               Qhx2              power transferred via hx2 (external)
C               Qhx3              power transferred via hx3 (external)
C               Qhx4              power transferred via hx4 (external)
C              
C      ELSE:    ---
C
C----------------------------------------------------------------------C


      INTEGER maxN,Nmax
      INTEGER nh1,nh2,nh3,nh4
                           
      INTEGER scd1,scd2,scd3,scd4,scd5,scd6,scd7,scd8,scd9,scd10,
     1        sch1,sch2,sch3,sch4
   
      INTEGER FLOWINFO(maxN,18)

      DOUBLE PRECISION Told(maxN,3)

      DOUBLE PRECISION Qhx1,Qhx2,Qhx3,Qhx4

      DOUBLE PRECISION md1,md2,md3,md4,md5,md6,md7,md8,md9,md10
      DOUBLE PRECISION Td1i,Td2i,Td3i,Td4i,Td5i,Td6i,Td7i,Td8i,Td9i
      DOUBLE PRECISION Td1o,Td2o,Td3o,Td4o,Td5o,Td6o,Td7o,Td8o,Td9o
      DOUBLE PRECISION Th1i,Th2i,Th3i,Th4i,Td10i,Td10o
      DOUBLE PRECISION Th1o,Th2o,Th3o,Th4o
      DOUBLE PRECISION Th1onw,Th1ood,Th2onw,Th2ood,Th3onw,Th3ood,Th4onw 
      DOUBLE PRECISION UAh1T,UAh2T,UAh3T,UAh4T,Th4ood

      DOUBLE PRECISION UAh1s,UAhx1,bh11,bh12,bh13,smh1
      DOUBLE PRECISION UAh2s,UAhx2,bh21,bh22,bh23,smh2
      DOUBLE PRECISION UAh3s,UAhx3,bh31,bh32,bh33,smh3
      DOUBLE PRECISION UAh4s,UAhx4,bh41,bh42,bh43,smh4
      DOUBLE PRECISION mh1,mh2,mh3,mh4
      DOUBLE PRECISION cps,cph1,cph2,cph3,cph4,zd10o
      DOUBLE PRECISION CPFD1,CPFD2,CPFD3,CPFD4,CPFD5,
     1     CPFD6,CPFD7,CPFD8,CPFD9,CPFD10
      DOUBLE PRECISION zd1o,zd2o,zd3o,zd4o,zd5o,zd6o,zd7o,zd8o,zd9o

      

      COMMON/UAHX/UAh1s,UAhx1,bh11,bh12,bh13,mh1,smh1,
     1            UAh2s,UAhx2,bh21,bh22,bh23,mh2,smh2,
     2            UAh3s,UAhx3,bh31,bh32,bh33,mh3,smh3,
     3            UAh4s,UAhx4,bh41,bh42,bh43,mh4,smh4,nh1,nh2,nh3,nh4

      COMMON/LSH/UAh1T,UAh2T,UAh3T,UAh4T

      COMMON/DP_OUT/zd1o,zd2o,zd3o,zd4o,zd5o,zd6o,zd7o,zd8o,zd9o,zd10o
      COMMON/DP_MASSF/md1,md2,md3,md4,md5,md6,md7,md8,md9,md10     
      COMMON/DP_INP_T/Td1i,Td2i,Td3i,Td4i,Td5i,Td6i,Td7i,Td8i,Td9i,Td10i
      COMMON/DP_OUT_T/Td1o,Td2o,Td3o,Td4o,Td5o,Td6o,Td7o,Td8o,Td9o,Td10o
      COMMON/DP_CPF/CPFD1,CPFD2,CPFD3,CPFD4,CPFD5,
     1              CPFD6,CPFD7,CPFD8,CPFD9,CPFD10

      COMMON/HX_INP_T/Th1i,Th2i,Th3i,Th4i
      COMMON/HX_OUT_T/Th1o,Th2o,Th3o,Th4o
      COMMON/HX_T_OUT/Th1onw,Th1ood,Th2onw,Th2ood,Th3onw,Th3ood, 
     1                Th4onw,Th4ood 
      COMMON/CP_FLUID/cps,cph1,cph2,cph3,cph4
      COMMON/S_CHARGE/scd1,scd2,scd3,scd4,scd5,scd6,scd7,scd8,
     1                scd9,scd10,sch1,sch2,sch3,sch4

C**********************************************************************
C     start modification for virtual double ports                     *
C**********************************************************************

      If (sch1.eq.2.and.mh1.gt.0.0) then
C------->for heat exchanger 1 and double port 7 respectively
         nout = NODE(Nmax,zd7o)
         Td7o = Told(nout,2)   

         CALL NC_EX_HX(maxN,Nmax,FLOWINFO,Told,1,UAhx1,bh11,bh12,
     1                 bh13,UAh1T,smh1,Th1i,mh1,cph1,Td7o,cps,
     2                 Th1onw,Td7i,md7,Qhx1)    
         If (ErrorFound()) RETURN  
         CPFD7 = cps * md7
      else
      end if

      If (sch2.eq.2.and.mh2.gt.0.0) then
C------->for heat exchanger 2 and double port 8 respectively
         nout = NODE(Nmax,zd8o)
         Td8o = Told(nout,2)

         CALL NC_EX_HX(maxN,Nmax,FLOWINFO,Told,2,UAhx2,bh21,bh22,
     1                 bh23,UAh2T,smh2,Th2i,mh2,cph2,Td8o,cps,
     2                 Th2onw,Td8i,md8,Qhx2)
	   If (ErrorFound()) RETURN
         CPFD8 = cps * md8
      else
      end if

      If (sch3.eq.2.and.mh3.gt.0.0) then
C------->for heat exchanger 3 and double port 9 respectively
         nout = NODE(Nmax,zd9o)
         Td9o = Told(nout,2)

         CALL NC_EX_HX(maxN,Nmax,FLOWINFO,Told,3,UAhx3,bh31,bh32,
     1                 bh33,UAh3T,smh3,Th3i,mh3,cph3,Td9o,cps,
     2                 Th3onw,Td9i,md9,Qhx3)      
	   If (ErrorFound()) RETURN
         CPFD9 = cps * md9
      else
      end if

      If (sch4.eq.2.and.mh4.gt.0.0) then
C------->for heat exchanger 4 and double port 10 respectively
         nout = NODE(Nmax,zd10o)
         Td10o = Told(nout,2)

         CALL NC_EX_HX(maxN,Nmax,FLOWINFO,Told,4,UAhx4,bh41,bh42,
     1                 bh43,UAh4T,smh4,Th4i,mh4,cph4,Td10o,cps,
     2                 Th4onw,Td10i,md10,Qhx4)      
	   If (ErrorFound()) RETURN
         CPFD10 = cps * md10
      else
      end if



      RETURN
      END


C----------------ENDE---------------------------------------------------
