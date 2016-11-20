function [fitresult, gof] = Silicon_heat_capacity(cp_S_T, cp_S_D)

%  Messdaten Laden

load('SiliconData.mat');


%% Fit: 'untitled fit 1'.
[xData, yData] = prepareCurveData( cp_S_T, cp_S_D );

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
Tcp_Sil = [0:150];
t=Tcp_Sil;
CARLIB_cp_sil = (1.7 .*t + 1470.0)/1000; % /1000 für Umwandlung von J in kJ


% Create a figure for the plots.
figure( 'Name', 'Siliconoil (syltherm 800) Regress heat capacity' );

% Plot fit with data.
subplot( 2, 1, 1 );
h = plot( fitresult, xData, yData, 'predobs', 0.95 );
hold on
plot (Tcp_Sil,CARLIB_cp_sil)
legend( 'Measured values', 'Regress-Function', 'Lower bounds 95%', 'Upper bounds 95%', 'Carlib-Function');
% Label axes
xlabel( 'Temperature t [°C]' );
ylabel( 'heatcapacity cp [kJ/kg.K]' );
grid on
hold off

% Plot residuals.
subplot( 2, 1, 2 );
h = plot( fitresult, xData, yData, 'residuals' );
legend( h, 'residuals', 'Zero Line', 'Location', 'NorthEast' );
% Label axes
xlabel( 'Temperature t [°C]' );
ylabel( 'heatcapacity cp [kJ/kg.K]' );
grid on


%% Formel mit Nachkommastellen ausgeben
%coeffnames(fitresult)
coeff = coeffvalues(fitresult);
disp ('Coefficients with 10 decimal places:')
fprintf('p# %0.10f \n',coeff)

