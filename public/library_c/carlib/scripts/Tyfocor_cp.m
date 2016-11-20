function [fitresult, gof] = Tyfocor_cp(cp_TLS_T, cp_TLS_D)
%heat_capacity

%  Messdaten Laden
load('TyfocorLS_Data.mat');

%% Fit: 'untitled fit 1'.
[xData, yData] = prepareCurveData( cp_TLS_T, cp_TLS_D );

% Set up fittype and options.
ft = fittype( 'poly1' );
opts = fitoptions( ft );
opts.Lower = [-Inf -Inf];
opts.Upper = [Inf Inf];

% Fit model to data.
[fitresult, gof] = fit( xData, yData, ft, opts );
disp('Goodness:');
disp(gof);

%%CARLIB
%/* für -30°C < T < 120°C */
T_TLS=[-30:150];
t=T_TLS;
cp_TLS = 3.977553.*t+3.520392e3;
cp_TLS = cp_TLS/1000; %Umrechnung der Einheiten

%DIFF
difx = [-20:150];
CDif = (3.977553.*difx+3.520392e3)/1000;
FDif =   0.003975*difx + 3.5205833333;
DIFF = abs(CDif - FDif);

% Plot fit with data.
figure( 'Name', 'TyfocorLS Regress heatcapacity' );
%Plot with Data
subplot( 2, 1, 1 );
h = plot( fitresult, xData, yData, 'predobs', 0.95 );
hold on
plot (T_TLS,cp_TLS)
legend('Measured values', 'Regress-Function', 'Lower bounds 95%', 'Upper bounds 95%', 'Carlib-Function');
% Label axes
xlabel( 'Temperature t [°C]' );
ylabel( 'heatcapacity cp [kJ/kg.K]' );
grid on

% Plot residuals.
subplot( 2, 1, 2 );
plot( fitresult, xData, yData, 'residuals' );
hold on
plot(difx,DIFF);
legend('residuals', 'Zero Line', 'Location', 'NorthEast','Functiondif absolut' );
% Label axes
xlabel( 'Temperature t [°C]' );
ylabel( 'heatcapacity cp [kJ/kg.K]' );
grid on

%% Formel mit Nachkommastellen ausgeben
%coeffnames(fitresult)
coeff = coeffvalues(fitresult);
disp ('Coefficients with 10 decimal places:')
fprintf('p# %0.10f \n',coeff)


