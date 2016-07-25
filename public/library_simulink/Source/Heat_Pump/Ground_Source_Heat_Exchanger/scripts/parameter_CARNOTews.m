%
% Fabian Ochs, 2012, Innsbruck
% 
% based on Diss. Bianchi

% This file is part of the CARNOT Blockset.
% 
% Copyright (c) 1998-2015, Solar-Institute Juelich of the FH Aachen.
% Additional Copyright for this file see list auf authors.
% All rights reserved.
% 
% Redistribution and use in source and binary forms, with or without 
% modification, are permitted provided that the following conditions are 
% met:
% 
% 1. Redistributions of source code must retain the above copyright notice, 
%    this list of conditions and the following disclaimer.
% 
% 2. Redistributions in binary form must reproduce the above copyright 
%    notice, this list of conditions and the following disclaimer in the 
%    documentation and/or other materials provided with the distribution.
% 
% 3. Neither the name of the copyright holder nor the names of its 
%    contributors may be used to endorse or promote products derived from 
%    this software without specific prior written permission.
% 
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE 
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF 
% THE POSSIBILITY OF SUCH DAMAGE.

close all;
clear all;

scrsz = get(0,'ScreenSize');
f1=figure('Position',[scrsz(3)*0/4+10 scrsz(4)*2/3-10 scrsz(3)*1/4-10 scrsz(4)*1/4-10]);clf;
f2=figure('Position',[scrsz(3)*1/4+10 scrsz(4)*2/3-10 scrsz(3)*1/4-10 scrsz(4)*1/4-10]);clf;

sondenfall = 1;
startfall = 2; % 2: g-function

t0 = 0;                                 % start time
t1 = 3600 * 8760; % end time
sample_time = 3600;

np = 1; % number of parallel vghx
mdot = 0.5;
teta_in = 1;
Massenstrom = mdot/np;

teta_e_m = 10;

Qdot0 = 5000;
t_start = 50*8560*3600;

%% Geometry

DimRad=6;                                   % typischer wert 10
DimAxi=4;                                  % typischer wert 10
Gitterfaktor=2.5;

Bohrdurchmesser=0.180;           %rb           % m
Sondelaenge=100; % 100|75|50 
B = 10; % 10

Sondendurchmesser=0.032;                    % m
Dicke_Sondenrohr = 0.003;
lambda_Sondenrohr = 0.48;
Bu = .1293;

%% Ground Properties
    
lambdaErde=2.0; %2.0                          % W/m*K                        
cpErde=800;    %1000                         % J/Kg*K 
rhoErde=2500;   %2600                         % Kg/m3
aErde = lambdaErde/(rhoErde*cpErde);

lambdaFill=1.0; %0.7                        % W/m*K
cpFill=1000;     %1200                       % J/kg*K
rhoFill=2000;    %1600                       % Kg/m3

% Fluid
teta_m = 2; 
p0 = 1E5;
fluid = 5;
mix = 0.25;

Jahresmitteltemp=teta_e_m + 273.15;                       % 13 | 9°C
TGrad=0.025;                                 % K/m typ 0.025 bis 0.04
Bodenerwaermung=1;                          % 0°C
Bodentemp=Jahresmitteltemp+Bodenerwaermung; % K


%% 
%% Calculation
%% 

lambdaSole=thermal_conductivity(teta_m,p0,fluid,mix);%W/(m K)
cpSole=heat_capacity(teta_m,p0,fluid,mix);                                % J/Kg*K
rhoSole=density(teta_m,p0,fluid,mix);%kg/m^3
vSole=kinematic_viscosity(teta_m,p0,fluid,mix);                             % m2/s

Pr=vSole*rhoSole*cpSole/lambdaSole;

disp(['Pr = ' num2str(Pr) ])

rb = Bohrdurchmesser/2;
rm = B/2;
Rechenradius = rm;
Dl=Sondelaenge/DimAxi*2;    

rs=Sondendurchmesser/2;
r0 = rs-Dicke_Sondenrohr; % Innenradius
r1=Bohrdurchmesser/2;
r2=r1+(Rechenradius-r1)*(1-Gitterfaktor)/(1-Gitterfaktor^(DimRad-1))*Gitterfaktor^0;

rz1=((r1^2+r0^2)/2)^0.5;
rz2=((r2^2+r1^2)/2)^0.5;

mcpSole=2*cpSole*rhoSole*pi*Dl*(Sondendurchmesser/2)^2;
Di = Sondendurchmesser - 2 * Dicke_Sondenrohr;
Geschw_Sole= Massenstrom/rhoSole/(Di/2)^2/pi/2; % 2: double U

Vdot = Massenstrom/rhoSole;
A_p = (Di/2)^2/pi/2;

disp(['mdot = ' num2str(Massenstrom) ' kg/s ' ' Vdot = ' num2str(Vdot*3600/1000) ' l/h ' ' Sondelaenge = ' num2str(Sondelaenge) ' m '  ' A_p = ' num2str(A_p) ' m^2 ' ' w = ' num2str(Geschw_Sole) ' m/s ' ])

    Re=Geschw_Sole*Di/vSole;
    Druckverlust= 1/(1.82*log10(Re)-1.64)^2;
    K1=1+27.2*Druckverlust/8;
    K1_o=1.106886;
    K2=11.7+1.8*Pr^(-1.3);
    Druckverlust_o=0.031437;
    St_o= Druckverlust_o/8/(K1_o+K2*(Druckverlust_o/8)^0.5*(Pr^(2/3)-1));
    Nu_o=St_o*10000*Pr;
    St= Druckverlust/8/(K1+K2*(Druckverlust/8)^0.5*(Pr^(2/3)-1));

    % acc. Hellström    
    b = Bu/(2*r1);
    b_max = 1-rs/r1;
    b_min = rs/r1;
    disp(['b = ' num2str(b) ' b_max = ' num2str(b_max) ' b_min = ' num2str(b_min)])
    sigma = (lambdaFill-lambdaErde)/(lambdaErde+lambdaFill);
    A = pi*r0^2;
    vs = Massenstrom/2/rhoSole/A;
    zeta = 1/((1.82*log10(Re)-1.64)^2);
    K1 = 1+27.2*zeta/8;
    K2 = 11.7+1.8*Pr^(-1/3); 
    R_s = 1/(2*pi*lambda_Sondenrohr)*log(rs/r0);
    
    Nu_turbulent=St*Re*Pr;        
    Nu_laminar=4.36;

    if Re>=10000,
%         Nu=Nu_turbulent; 
        Nu =(zeta/8)*Re*Pr/(K1+K2*(zeta/8)^.5*(Pr^(2/3)-1));
    elseif Re<10000 && Re>2300
        Nu=Nu_laminar*exp(log(Nu_o/Nu_laminar)*log(Re/2300)/log(10000/2300));
    elseif Re<=2300,
        Nu=Nu_laminar;        
    end
    
    disp(['Nu = ' num2str(Nu) ])

    alpha = Nu*lambdaSole/(2*r0);
    alpha_eff = (1/alpha+r0/lambda_Sondenrohr*log(rs/r0))^-1;
    alpha0 = lambdaSole/(Di/2*(1-0.5^0.5));
    alpha0_eff = (1/alpha0+r0/lambda_Sondenrohr*log(rs/r0))^-1;
    disp(['mdot = ' num2str(Massenstrom) ' kg/s' ' Di = ' num2str(Di) ' m' ' v = ' num2str(Geschw_Sole) ' m/s' ', Re = ' num2str(Re) ', alpha = ' num2str(alpha) ' W/(m^2 K), alpha_eff = ' num2str(alpha_eff) ' W/(m^2 K)'])

    R_a = 1/(8*pi*alpha*r0);
    beta = lambdaFill*(1/(r0*alpha)+1/lambda_Sondenrohr*log(rs/r0));

    R1_EWS=0.25*(1/(2*pi*alpha_eff*r0*Dl)+1/(2*pi*lambdaFill*Dl)*log((r1-rz1)/r0));
    R2_EWS=1/(2*pi*Dl)*(1/lambdaFill*log(r1/rz1)+1/lambdaErde*log(rz2/r1));        
    
    R10_EWS=0.25*(1/(2*pi*alpha0_eff*r0*Dl)+1/(2*pi*lambdaFill*Dl)*log((r1-rz1)/r0));
    R20_EWS=1/(2*pi*Dl)*(1/lambdaFill*log(r1/rz1)+1/lambdaErde*log(rz2/r1));        
    
    disp(['R1_EWS = ' num2str(R1_EWS) ' R2_EWS = ' num2str(R2_EWS) ])
        
    Ra = 1/(pi*lambdaFill)*(log((2^.5*b*r1)/r0)-1/2*log((2*b*r1)/r0)-1/2*sigma*log((1-b^4)/(1+b^4)))+(1/(2*pi*r0*alpha))+R_s;
    Rb = (1/(8*pi*lambdaFill))*(beta+log(r1/r0)+log(r1/Bu)+sigma*log(r1^4/(r1^4-Bu^4/16))-(r0^2/Bu^2*(1-sigma*(Bu^474)/(r1^4-Bu^4/16)^2))/((1+beta)/(1-beta)+r0^2/Bu^2*(1+sigma*Bu^4*r1^4/(r1^4-Bu^4/16)^2)));
    
    Ra0 = 1/(pi*lambdaFill)*(log((2^.5*b*r1)/r0)-1/2*log((2*b*r1)/r0)-1/2*sigma*log((1-b^4)/(1+b^4)))+(1/(2*pi*r0*alpha0))+R_s;
    Rb0 = (1/(8*pi*lambdaFill))*(beta+log(r1/r0)+log(r1/Bu)+sigma*log(r1^4/(r1^4-Bu^4/16))-(r0^2/Bu^2*(1-sigma*(Bu^474)/(r1^4-Bu^4/16)^2))/((1+beta)/(1-beta)+r0^2/Bu^2*(1+sigma*Bu^4*r1^4/(r1^4-Bu^4/16)^2)));

    disp(['Ra = ' num2str(Ra) ' Rb = ' num2str(Rb) ])    
    if Ra < 4 * Rb
        R1 = Ra/(4*Dl);
        R2 = (Rb-Ra/4)/Dl+(2*pi*Dl*lambdaErde)^-1*log(rz2/r1);
        disp(['R1 = ' num2str(R1) ' R2 = ' num2str(R2) ]) 
        R10 = Ra0/(4*Dl);
        R20 = (Rb0-Ra0/4)/Dl+(2*pi*Dl*lambdaErde)^-1*log(rz2/r1);        
    else
        R1 = R1_EWS;
        R2 = R2_EWS;
        
        R10 = R10_EWS;
        R20 = R20_EWS;
    end
    
disp('Rb: Borehole therm. res. fluid/ground')

    
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% temperaturverlauf axialer richtung %%%%%%%%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

L0=cpSole*Massenstrom;      % konstant
L00 = 0.0;

L1=1/R1;
L2=1/R2;
L10=1/R10;
L20=1/R20;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%% matrizen Ad,Bd,Cd,Dd für Tdown %%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


Ad=zeros(DimAxi/2,DimAxi/2);
Ad0=zeros(DimAxi/2,DimAxi/2);
for h=1:DimAxi/2,
    Ad(h,h)=-(L0/(mcpSole)+L1/(2*mcpSole));
    Ad0(h,h)=-(L00/(mcpSole)+L10/(2*mcpSole));
end
  
for h=1:DimAxi/2-1,
    Ad(h+1,h)=L0/(mcpSole);
    Ad0(h+1,h)=L00/(mcpSole);
end

Bd=zeros(DimAxi/2,DimAxi/2+1);
Bd0=zeros(DimAxi/2,DimAxi/2+1);
Bd(1,1)=L0/(mcpSole);
Bd0(1,1)=L00/(mcpSole);

for h=1:DimAxi/2,
    Bd(h,h+1)=L1/(2*mcpSole);
    Bd0(h,h+1)=L10/(2*mcpSole);
end

Cd=eye(DimAxi/2);
Dd=zeros(DimAxi/2,DimAxi/2+1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%% matrizen Au,Bu,Cu,Du für Tup %%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Au=zeros(DimAxi/2,DimAxi/2);
Au0=zeros(DimAxi/2,DimAxi/2);
for h=1:DimAxi/2,
    Au(h,h)=-(L0/(mcpSole)+L1/(2*mcpSole));
    Au0(h,h)=-(L00/(mcpSole)+L10/(2*mcpSole));
end
  
for h=1:DimAxi/2-1,
    Au(h+1,h)=L0/(mcpSole);
    Au0(h+1,h)=L00/(mcpSole);
end

Bu=zeros(DimAxi/2,DimAxi/2+1);
Bu0=zeros(DimAxi/2,DimAxi/2+1);
Bu(1,1)=L0/(mcpSole);
Bu0(1,1)=L00/(mcpSole);
for h=1:DimAxi/2,
    Bu(h,h+1)=L1/(2*mcpSole);
    Bu0(h,h+1)=L10/(2*mcpSole);
end

Cu=Cd;
Du=zeros(DimAxi/2,DimAxi/2+1);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%% berechnung von Tradial %%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%% von Luzi Valär %%%%%%%%%%%%

Dim1=(DimRad-2)*DimAxi/2;

r(1)=Bohrdurchmesser/2;
r(2)=r2;

for h =3:DimRad,
    r(h)=r(h-1)+(Rechenradius-r1)*(1-Gitterfaktor)/(1-Gitterfaktor^(DimRad-1))*Gitterfaktor^(h-2);
end
    
rz(1)=((r(1)^2+r0^2)/2)^0.5;

for h = 2:DimRad,
    rz(h)=((r(h)^2+r(h-1)^2)/2)^0.5;
end

L(1)=L1; 
L(2)=L2;

for h = 3:DimRad-1,
L(h)=1/(1/(2*pi*Dl)*(1/lambdaErde*log(rz(h)/rz(h-1))));
end
L(DimRad)=1/(1/(2*pi*Dl)*(1/lambdaErde*log(r(DimRad)/rz(DimRad-1))));


C(1)=cpFill*rhoFill*pi*(r(1)^2-4*r0^2)*Dl;

for h = 2:DimRad,
    C(h)=cpErde*rhoErde*pi*(r(h)^2-r(h-1)^2)*Dl;
end


a=zeros(DimRad-2,DimRad-2);
for h = 1:DimRad-2,
    a(h,h)=(-L(h)-L(h+1))/C(h);
end
for h = 1:DimRad-3,
    a(h,h+1)=L(h+1)/C(h);
    a(h+1,h)=L(h+1)/C(h+1);
end

b=zeros(DimRad-2,2);
    b(1,1)=L(1)/C(1);
    b(DimRad-2,2)=L(DimRad-1)/C(DimRad-2);
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    
Ar=a;
Ar(DimRad-1:2*(DimRad-2),DimRad-1:2*(DimRad-2))=a;
    
for h=2:DimAxi/2-1,
    Ar(h*(DimRad-2)+1:(h+1)*(DimRad-2),h*(DimRad-2)+1:(h+1)*(DimRad-2))=a;

end  

Br=b;

for h=1:DimAxi/2-1,
    Br(h*(DimRad-2)+1:(h+1)*(DimRad-2),2*h+1:2*h+2)=b;   
end
    

Cr=eye((DimRad-2)*DimAxi/2);
Dr=zeros((DimRad-2)*DimAxi/2,DimAxi);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% andere matrizen %%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Cdl=zeros(DimAxi/2,1);
Cdl(DimAxi/2,1)=1;
Cdl=Cdl';

c1=zeros(DimAxi/2,Dim1);

for h=1:DimAxi/2,
   
    c1(1,1)=1;
    c1(h,(h-1)*(DimRad-2)+1)=1;
        
end


c31=zeros(1,DimAxi/2);
c3(1,1)=1;
for h=1:DimAxi/2-1,
    c3(1+2*h,1+h)=1;
    
end

c33=zeros(DimAxi,DimAxi/2);
c33(1:DimAxi-1,1:DimAxi/2)=c3;

c41=zeros(1,DimAxi/2);

c4=c41;
c4(2:DimAxi,1:DimAxi/2)=c3;


%%%%%% randbedingungen für Tearth,DimRad %%%%%
%%%%%% anfangsbedingungen für Tradial %%%%%%%%

mu=linspace(0,Sondelaenge,DimAxi/2);
T=(mu*TGrad+Bodentemp);
Tearth_anf=T'*ones(1,DimRad-2);

T_null=Tearth_anf(:,1);

teta_fluid_ini = mean(T_null)-273.15;

%%%%%% anfangsbedingungen für Tdown,Tup  %%%%%%%%%%


Tdown_0=Tearth_anf(:,1);
Tup_0=flipud(Tdown_0);
Tearth_anf=Tearth_anf';
c5=ones(DimAxi/2,1);           

c6=zeros(DimRad-2,3*(DimRad-2));

for i=2:DimRad-2;
    c6(1,DimRad-1)=1;
    c6(i,DimRad+i-2)=1;
end


%% RB
Ts_Trichter=7*24*3600; % 7 (1 week according to Huber)
Dr_Trichter=1;
t_Trichter = linspace(Ts_Trichter,Ts_Trichter*5000,5000);
r_Trichter = linspace(Dr_Trichter,Dr_Trichter*20,20);

% g-function
xS = [-4 -2 0 2 3];
if sondenfall == 1          % 1 Sonde
    yS = [4.82 5.69 6.29 6.57 6.6];
elseif sondenfall == 2      % 2 Sonden B/H = 0.1
    yS = [4.99 6.37 7.62 8.06 8.08];
elseif sondenfall == 3      % 2 Sonden B/H = 0.05
    yS = [5.30 6.92 8.20 8.67 8.71];
elseif sondenfall == 4      % 3x6 Sonden B/H = 0.1
    yS = [5.00 9.15 16.40 19.75 20.05];
elseif sondenfall == 5      % 5x10 Sonden B/H = 0.1
    yS = [5.00 10.2 22.75 29.5 30.05];
end

npol = 4;
p = polyfit(xS,yS,npol);
ts = Sondelaenge^2/(9*aErde);
gfunction = zeros(length(t_Trichter),length(r_Trichter));
Es = t_Trichter*9*aErde/Sondelaenge^2;

g = polyval(p,log(Es));

for ii = 1:length(r_Trichter)
    gfunction(:,ii) = max(0,g - log(r_Trichter(ii)/Sondelaenge/0.0005)); % correction 21-09-2012
end



%% Startwerte

qdot0 = Qdot0/Sondelaenge; 

if startfall == 2
    Es_start = t_start*9*aErde/Sondelaenge^2;
    TEarth0 = zeros(size(Tearth_anf));
    for ii = 1:DimAxi/2
        for iii = 1:DimRad-1
            g_start = polyval(p,log(Es_start));
            TEarth0(iii,ii) = Bodentemp + mu(ii)*TGrad - qdot0/(DimAxi/2)*((g_start-log(rz(iii+1)/Sondelaenge/0.0005))/(2*pi*lambdaErde));
        end
    end    

    T_null = TEarth0(end,:)';
    Tearth_anf = TEarth0(1:end-1,:);
    
    figure(f1); clf; hold on;
    title([' qdot0 = ' num2str(qdot0) ' W/m'])
    contourf(rz(2:end),-mu,[Tearth_anf;T_null']'-273.15); colorbar; set(gca,'Clim',[5 15])
    ylabel(' h / [m]','FontWeight','bold')
    xlabel(' r / [m]','FontWeight','bold')
end

figure(f2); clf; hold on;
plot(log(Es),g)
plot([log(Es_start),log(Es_start)],[0,15],'k--')
grid on;
    ylabel(' g / [-]','FontWeight','bold')
    xlabel(' ln(Es) / [-]','FontWeight','bold')


myfile = ['.\sol\ews_simout_'  num2str(Sondelaenge) 'm_' num2str(Bohrdurchmesser) 'm_' num2str(Rechenradius) 'm_V1.mat'];
myfile1 = ['.\sol\ews_sol_'  num2str(Sondelaenge) 'm_' num2str(Bohrdurchmesser) 'm_' num2str(Rechenradius) 'm_V1.mat'];
