function [fitresult, gof] = Tyfocor_ts(vp_TLS_D, vp_TLS_T)
%vapopressure - Dampfdruck

%  Messdaten Laden
load('TyfocorLS_Data.mat');


%% Fit: 'untitled fit 1'.
[xData, yData] = prepareCurveData( vp_TLS_D, vp_TLS_T );

% Set up fittype and options.
ft = fittype( 'a*x^b+c', 'independent', 'x', 'dependent', 'y' );
opts = fitoptions( ft );
opts.Display = 'Off';
opts.Lower = [-Inf -Inf -Inf];
opts.StartPoint = [0.751267059305653 0.255095115459269 0.505957051665142];
opts.Upper = [Inf Inf Inf];

% Fit model to data.
[fitresult, gof] = fit( xData, yData, ft, opts );
disp('Goodness:');
disp(gof);

%%CARLIB
% p_c = [0:15]; %[bar]
% ts_c = 263.9257158*(1-exp(-pow(p_c/1e5/6.2299009,0.4022453))); ???pow ???


% Plot fit with data.
figure( 'Name', 'TyfocorLS Regress saturationtemperature' );
title ('TyfocorLS Regress saturationtemperature');
%Plot with Data
subplot( 2, 1, 1 );
plot( fitresult, xData, yData, 'predobs', 0.95 );
legend('Measured values', 'Regress-Function', 'Lower bounds 95%', 'Upper bounds 95%');
% Label axes
xlabel( 'vaporpressure vp [bar]' );
ylabel( 'Temperature t [°C]' );
grid on

% Plot residuals.
subplot( 2, 1, 2 );
h = plot( fitresult, xData, yData, 'residuals' );
legend( h, 'residuals', 'Zero Line', 'Location', 'NorthEast' );
% Label axes
xlabel( 'vaporpressure vp [bar]' );
ylabel( 'Temperature t [°C]' );
grid on

%% Formel mit Nachkommastellen ausgeben
%coeffnames(fitresult)
coeff = coeffvalues(fitresult);
disp ('Coefficients with 10 decimal places:')
fprintf('p# %0.10f \n',coeff)
