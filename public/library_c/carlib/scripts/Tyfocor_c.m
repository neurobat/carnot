function [fitresult, gof] = Tyfocor_c(c_TLS_T, c_TLS_D)
%thermal_conductivity - Wärmeleitfähigkeit [W/mK]

%  Messdaten Laden
load('TyfocorLS_Data.mat');

%% Fit: 'untitled fit 1'.
[xData, yData] = prepareCurveData( c_TLS_T, c_TLS_D );

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
%for -30°C < T < 120°C  max f = 0.194 %  */
T_TLS=[-30:120];
t=T_TLS;
c_TLS = 7.011693e-4*t+3.991658e-1;


% Plot fit with data.
figure( 'Name', 'TyfocorLS Regress thermal conductivity' );
%Plot with Data
subplot( 2, 1, 1 );
h = plot( fitresult, xData, yData, 'predobs', 0.95 );
hold on
plot (T_TLS,c_TLS)
legend('Measured values', 'Regress-Function', 'Lower bounds 95%', 'Upper bounds 95%', 'Carlib-Function');
% Label axes
xlabel( 'Temperature t [°C]' );
ylabel( 'thermal conductivity c [W/m.K]' );
grid on


% Plot residuals.
subplot( 2, 1, 2 );
h = plot( fitresult, xData, yData, 'residuals' );
legend( h, 'residuals', 'Zero Line', 'Location', 'NorthEast' );
% Label axes
xlabel( 'Temperature t [°C]' );
ylabel( 'thermal conductivity c [W/m.K]' );
grid on

%% Formel mit Nachkommastellen ausgeben
%coeffnames(fitresult)
coeff = coeffvalues(fitresult);
disp ('Coefficients with 10 decimal places:')
fprintf('p# %0.10f \n',coeff)
