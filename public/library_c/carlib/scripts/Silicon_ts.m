function [fitresult, gof] = Silicon_ts(st_S_D, st_S_T)
%vapopressure - Dampfdruck

%  Messdaten Laden
load('SiliconData.mat');


%% Fit: 'untitled fit 1'.
[xData, yData] = prepareCurveData( st_S_D, st_S_T );

% Set up fittype and options.
ft = fittype( 'power2' );
opts = fitoptions( ft );
opts.Display = 'Off';
opts.Lower = [-Inf -Inf -Inf];
opts.StartPoint = [68.9558710411455 0.2402724705319 -1.07919130271252];
opts.Upper = [Inf Inf Inf];

% Fit model to data.
[fitresult, gof] = fit( xData, yData, ft, opts );
disp('Goodness:');
disp(gof);

% Plot fit with data.
figure( 'Name', 'Silicon Regress saturationtemperature' );
title ('Silicon Regress saturationtemperature');
%Plot with Data
subplot( 2, 1, 1 );
plot( fitresult, xData, yData, 'predobs', 0.95 );
legend('Measured values', 'Regress-Function', 'Lower bounds 95%', 'Upper bounds 95%');
% Label axes
xlabel( 'vaporpressure vp [kPa]' );
ylabel( 'Temperature t [°C]' );
grid on

% Plot residuals.
subplot( 2, 1, 2 );
h = plot( fitresult, xData, yData, 'residuals' );
legend( h, 'residuals', 'Zero Line', 'Location', 'NorthEast' );
% Label axes
xlabel( 'vaporpressure vp [kPa]' );
ylabel( 'Temperature t [°C]' );
grid on

%% Formel mit Nachkommastellen ausgeben
%coeffnames(fitresult)
coeff = coeffvalues(fitresult);
disp ('Coefficients with 10 decimal places:')
fprintf('p# %0.10f \n',coeff)