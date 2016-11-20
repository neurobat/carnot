function [fitresult, gof] = Tyfocor_vp(vp_TLS_T, vp_TLS_D)
%vapopressure - Dampfdruck

%  Messdaten Laden
load('TyfocorLS_Data.mat');


[xData, yData] = prepareCurveData( vp_TLS_T, vp_TLS_D );

% Set up fittype and options.
ft = fittype( 'poly4' );
opts = fitoptions( ft );
opts.Lower = [-Inf -Inf -Inf -Inf -Inf];
opts.Upper = [Inf Inf Inf Inf Inf];

% Fit model to data.
[fitresult, gof] = fit( xData, yData, ft, opts );
disp('Goodness:');
disp(gof);

%%CARLIB
% for 40°C < T < 200°C  max f = 2,2
% T_TLS=[40:200];
% t=T_TLS;
% vp_TLS_D = exp(4.538434 * pow(t,0.25) - 2.893717); ??? pow()???


% Plot fit with data.
figure( 'Name', 'TyfocorLS Regress vapourpressure' );
%Plot with Data
subplot( 2, 1, 1 );
plot( fitresult, xData, yData, 'predobs', 0.95 );
% hold on
% plot (T_TLS,vp_TLS_D)
legend('Measured values', 'Regress-Function', 'Lower bounds 95%', 'Upper bounds 95%');
% Label axes
xlabel( 'Temperature t [°C]' );
ylabel( 'vaporpressure vp [bar]' );
grid on

% Plot residuals.
subplot( 2, 1, 2 );
h = plot( fitresult, xData, yData, 'residuals' );
legend( h, 'residuals', 'Zero Line', 'Location', 'NorthEast' );
% Label axes
xlabel( 'Temperature t [°C]' );
ylabel( 'vaporpressure vp [bar]' );
grid on

%% Formel mit Nachkommastellen ausgeben
%coeffnames(fitresult)
coeff = coeffvalues(fitresult);
disp ('Coefficients with 10 decimal places:')
fprintf('p# %0.10f \n',coeff)