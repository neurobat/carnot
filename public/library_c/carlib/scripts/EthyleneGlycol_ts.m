function [fitresult, gof] = EthyleneGlycol_ts(vp_EG_D, t_EG_D)

%%Vaporpressure
% Quelle: TRCVP, Vapor Pressure Database, Version 2.2P, Thermodynamic Research Center, Texas A&M University, College Station, TX.
vp_EG_D = [1 10 100 1000 10000 100000]; %in Pa
t_EG_D = [2 24 51.1 86.1 132.5 196.9]; %in °C
t_EG_D = t_EG_D';



%% Fit: 'untitled fit 1'.
[xData, yData] = prepareCurveData( vp_EG_D, t_EG_D);

% Set up fittype and options.
ft = fittype( 'power2' );
opts = fitoptions( ft );
opts.Display = 'Off';
opts.Lower = [-Inf -Inf -Inf];
opts.StartPoint = [4.93233439029471 0.378906934968443 -42.198773261856];
opts.Upper = [Inf Inf Inf];

% Fit model to data.
[fitresult, gof] = fit( xData, yData, ft, opts );
disp('Goodness:');
disp(gof);


% Plot fit with data.
figure( 'Name', 'Ethyleneglycole Regress saturationtemperature' );
% Plot fit with data.
subplot( 2, 1, 1 );
h = plot( fitresult, xData, yData, 'predobs', 0.95 );
legend( 'Measured values', 'Regress-Function', 'Lower bounds 95%', 'Upper bounds 95%');
% Label axes
xlabel( 'pressure p [Pa]' );
ylabel( 'Temperature t [°C]' );
grid on
hold off

% Plot residuals.
subplot( 2, 1, 2 );
h = plot( fitresult, xData, yData, 'residuals' );
legend( h, 'residuals', 'Zero Line', 'Location', 'NorthEast' );
% Label axes
xlabel( 'pressure p [Pa]' );
ylabel( 'Temperature t [°C]' );
grid on


%% Formel mit Nachkommastellen ausgeben
%coeffnames(fitresult)
coeff = coeffvalues(fitresult);
disp ('Coefficients with 10 decimal places:')
fprintf('p# %0.10f \n',coeff)

