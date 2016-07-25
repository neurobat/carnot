#ifndef CUTIL_DEFINED
#define CUTIL_DEFINED

#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <math.h>
#include <string.h>


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

  This file contains following functions:

     void lies_zeile(FILE *infile,char *zeile, long *filepos)

     int string2double (char *s, double *zahl)

     void double2string(double d, char *s)



  Version  Author              Changes                             Date
  0.1.0    Thomas Wenzel       created                             31jan2000
 
  Copyright (c) 2000 Solar-Institut Juelich, Germany
  All Rights Reserved


*******************************************************************************/



/*******************************************************************************

  lies_zeile
  
  Eine Zeile wird zeichenweise bis zum Zeilenendzeichen eingelesen.
  
  
  Eingabe:  FILE *infile     Eingabedatei
            
  Ausgabe:  char *zeile      eingelesen Zeile mit \0  statt \n am Ende
            long *filepos    aktuelle Dateiposition nach dem Einlesen
                             = -1, wenn am Dateiende angelangt
  
*******************************************************************************/

void lies_zeile(FILE *infile,char *zeile, long *filepos)
{
   int i=-1;
   //int c;
   
   int zeile_fertig=0;

                                                  /* Zeile einlesen */
     do
     {
        zeile[++i] = fgetc(infile);
        if (zeile[i]==9)                 /* Tabs in Leerzeichen umwandeln */
           zeile[i]=' ';
     }
     while(zeile[i]!=10 && !feof(infile));

   
   zeile[i] = '\0';                      /* statt Zeilenumbruch Stringende! */
   
   if (feof(infile))
     *filepos = 0;
   else
   *filepos = ftell(infile);
}


/**********************************************************************

   string2double 

   wandelt einen gegeben Character-String in
   eine double-Variable um.
   Returnwert:
      0, wenn Umwandlung in Ordnung
      1, wenn ungueltige Zeichen im String vorkommen
         dann wird zahl auf 0 gesetzt

   Aufruf:

     int fehler;
     double d;
     char s[50];

     fehler = string2double(s,&d);


   Thomas Wenzel, 04.12.1998

**********************************************************************/

int string2double (char *s, double *zahl)
{
   double d=0,exponent=0;
   int i = 0,
       vorzeichen=1,
       expvorzeichen=1,
       basis=1,
       ziffer;
   double nachkomma=-1;
   

   while (s[i] != '\0')         /* lesen bis Stringende */
   {
      if (s[i] == '-')          /* evtl. Vorzeichen setzen */
      {
         if (basis) 
           vorzeichen = -1;
         else
           expvorzeichen = -1;
      }
      else if (s[i] == '+')
      {
         if (basis) 
           vorzeichen = +1;
         else
           expvorzeichen = +1;
      }
      else if (isdigit(s[i]))   /* wenn Ziffer */
      {
         ziffer = s[i]-'0';                /* Buchstabe -> Ziffer */
         if (basis)             
           if (nachkomma<0)                /* Basis, vor dem Komma */
             d = 10*d+(double) ziffer;
           else                            /* Basis, nach dem Komma */
           {
             d = d+((double) ziffer)/nachkomma;
             nachkomma *=10;
           } 
         else                              /* Exponent */
           exponent = exponent*10 + (double) ziffer;
      }
      else if (s[i] == '.' || s[i] == ',') /* Punkt oder Komma */
         nachkomma = 10;
      else if (toupper(s[i])=='D' ||toupper(s[i])=='E') /* Exp.Zeichen */
         basis=0;
      else                                 /* ungueltiges Zeichen */
      {                                    /* dann Abbruch */
        *zahl = 0;
        printf("ungültig: !%d!%d!%c!\n",i,s[i],s[i]);
        return 1;
      }
      i++;
   }

   exponent *= expvorzeichen;              /* beide Vorzeichen beachten */
   *zahl = d*vorzeichen*pow(10,exponent);
   return 0;
}



/**********************************************************************

   double2string 
   wandelt eine double-Zahl in einen Character-String um

   ACHTUNG : F³r den String muss genuegend Speicher vorhanden sein
             (mind. 24 Stellen)

   Format : d > 1e8:   3.14159e15
            d < 1e-3:  3.14159e-8
            sonst      3141.59 


   Aufruf:

     double d;
     char s[50];

     double2string(d,s)


   Thomas Wenzel, 04.12.1998   

**********************************************************************/

void double2string(double d, char *s)
{
   double zahl;
   int    i=0,ziffer,kommastellen=0; //exponent=0;
   unsigned long izahl, iz=1, exponent=0;
   
   zahl = (d < 0 ? -d : d);       /* vorzeichenlos machen */

  if (zahl==0)
     strcpy(s,"0");
  else
  {
     if (zahl<0.001)              /* falls zu klein, dann mit Exp. */
     {
       while (zahl<1)
       {
          zahl*= 10.;
          exponent--;
       }
     }
     else if (zahl > 1e8)         /* falls zu gross, dann mit Exp. */
     {
       while (zahl>9)
       {
          zahl/= 10.;
          exponent++;
       }
     }
  
     izahl = (int_T)zahl;                /* Zahl vor Komma, nach Integer wandeln */
  
     while (iz*10<izahl)          /* 10-er Exponenten ermitteln */
       iz *= 10;
     if (d<0)                     /* evtl. Vorzeichen schreiben */
       s[i++] = '-';
     while (iz>=1)                /* Stellen vor dem Komma      */
     {
        ziffer = izahl / iz;      /* jeweils 1. Ziffer ausgeben */
        s[i++] = ziffer+'0'; 
        izahl %= iz;              /* und dann diese streichen   */
        iz /= 10;
     }
     s[i++] = '.';
     izahl = (int_T)zahl;
     zahl -= izahl;               /* zahl = nur noch Rest       */
     while (zahl>1e-8 && kommastellen<10)   /* Nachkommastellen */
     {
        zahl *= 10;               /* jeweils 1. Nachkommastelle */
        ziffer = (int_T)zahl;            /* vor das Komma holen und als*/
        s[i++] = ziffer+'0';      /* Ziffer ausgeben            */
        zahl -= ziffer;
        kommastellen++;           /* Stellen mit zaehlen        */
     }  
   
    
     if (exponent)                /* Exponent */
     {
       s[i++] = 'e';
       if (exponent<0)            /*  wenn Exp. negativ, Minuszeichen */
       {
         s[i++] = '-';
         exponent *= -1;
       }
       iz=1;
       while (iz*10<=exponent)     /* 10er-Exp. der Exp.-Zahl best. */
         iz *= 10;
  
       while (iz>=1)              /* Ziffer des Exponenten */
       {
          ziffer = exponent / iz;
          s[i++] = ziffer+'0';
          exponent %= iz;
          iz /= 10;
       }
        
     }
     s[i] = '\0';                 /* String-Ende */
   }
}




#endif