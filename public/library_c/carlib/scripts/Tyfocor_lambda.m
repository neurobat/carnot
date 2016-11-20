function [fitresult, gof] = Tyfocor_lambda(c_TLS_T, c_TLS_D)

%  Messdaten Laden

load ('TyfocorLS_Data');


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
t=[-30:120];
Carlib_c = 7.011693e-4*t+3.991658e-1;

%DIFF
difx = [-30:200];
newfunction = 0.0007021429*difx + 0.3990928571;
Carlib_diff = 7.011693e-4*difx+3.991658e-1;
DIFF = abs(newfunction-Carlib_diff);

% Create a figure for the plots.
figure( 'Name', 'TyfocorLS Regress thermal_conductivity' );            
% Plot fit with data.
subplot( 2, 1, 1 );
plot( fitresult, xData, yData, 'predobs', 0.99 );
hold on
plot(t,Carlib_c);
legend('lambda vs. T', 'Regression', 'Lower bounds', 'Upper bounds', 'Location', 'NorthEast','Carlibfunction' );
% Label axes
xlabel( 'T [°C]' );
ylabel( 'thermal_conductivity lambda [W/m.K]' );
grid on


% Plot residuals.
subplot( 2, 1, 2 );
plot( fitresult, xData, yData, 'residuals' );
hold on
plot(difx,DIFF);
legend('residuals', 'Zero Line', 'Location', 'NorthEast','Functiondif');
% Label axes
xlabel( 'T [°C]' );
ylabel( 'thermal_conductivity lambda [W/m.K]' );
grid on


%% Formel mit Nachkommastellen ausgeben
%coeffnames(fitresult)
coeff = coeffvalues(fitresult);
disp ('Coefficients with 10 decimal places:')
fprintf('p# %0.10f \n',coeff)
