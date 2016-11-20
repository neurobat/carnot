function [fitresult, gof] = Cottonseedoil_heat_capacity()

%  Messdaten Laden

load('CottonseedoilData.mat');


%Wärmekapazität
Tcp_cot1 = [-50:-30];
t1 = Tcp_cot1;
Tcp_cot2 = [22:50];
t2 = Tcp_cot2;

%Quelle: Handbuch Verfahrenstechnik und Anlagenbau von Hans G. Hirschberg
cp_cot_F1 = 2060 + 11.5*t1; %Bereich: -50 + -30 °C
cp_cot_F2 = 1930 + 1.25*t2; %Bereich: 22 + 50 °C

%Regressionskurve --> keine Sinnvoll Regression möglich
% t3 = [-50:-30,22:50];
% j=1;
%     for i=-50:-30
%         cp_cot(1,j) = 2060 + 11.5*i;
%         j=j+1;
%     end 
%     for i=22:50
%         cp_cot(1,j) = 1930 + 1.25*i;
%         j=j+1;
%     end    


%%CARLIB
Tcp_cot = [-50:50];
t=Tcp_cot;
CARLIB_rho_cot = 4.2144*t + 1649.0;

%DIFF
difx = [0:150];
CDif = 4.2144*difx + 1649.0;
FDif = 1930 + 1.25*difx;
DIFF = abs(CDif-FDif);

% Create a figure for the plots.
figure( 'Name', 'Cottonoil Function heat capacity' );

% Plot fit with data.
subplot( 2, 1, 1 );
plot( t1,cp_cot_F1,'.r' );
hold on
plot( t2,cp_cot_F2,'.r' );
plot (Tcp_cot,CARLIB_rho_cot)
legend( 'Quellfunktion 1','Quellfunktion 2','Carlib-Function');
% Label axes
xlabel( 'Temperature t [°C]' );
ylabel( 'heat capacity [J/kg*K]' );
grid on

% Plot residuals.
subplot( 2, 1, 2 );
plot(difx,DIFF);
legend('Functiondif absolut');
% Label axes
xlabel( 'Temperature t [°C]' );
ylabel( 'heat capacity [J/kg*K]' );
grid on

