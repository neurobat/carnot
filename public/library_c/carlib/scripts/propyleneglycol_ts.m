function [fitresult, gof] = PropyleneGlycol_ts(p_PG_D, vp_PG_D)

%  Messdaten Laden
load('PropyleneGlycolData.mat');



%% Fit: 'untitled fit 1'.
[xData, yData] = prepareCurveData( p_PG_D, vp_PG_D );

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
figure( 'Name', 'Propyleneglycole Regress saturationtemperature' );
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

