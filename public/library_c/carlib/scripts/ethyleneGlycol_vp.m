function [fitresult, gof] = ethyleneGlycol_vp(t_EG_D, vp_EG_D)

%  Messdaten Laden
vp_EG_D = [1 10 100 1000 10000 100000]; %in Pa
t_EG_D = [2 24 51.1 86.1 132.5 196.9]; %in °C
t_EG_D = t_EG_D';


%% Fit: 'untitled fit 1'.
[xData, yData] = prepareCurveData( t_EG_D, vp_EG_D );

% Set up fittype and options.
ft = fittype( 'exp1' );
opts = fitoptions( ft );
opts.Display = 'Off';
opts.Lower = [-Inf -Inf];
opts.StartPoint = [21.568176231108 0.0454479941267043];
opts.Upper = [Inf Inf];

% Fit model to data.
[fitresult, gof] = fit( xData, yData, ft, opts );
disp('Goodness:');
disp(gof);

%carlib
t= [20:200];
xi=0;
carlib_vp_00 = (exp (-0.81264.*log(t).*log(t)*xi*xi + 0.65201.*log(t).*log(t)*xi + 0.81015.*log(t).*log(t)  + 6.5902.*log(t)*xi*xi - 6.2249.*log(t)*xi - 3.8104.*log(t) - 15.826*xi*xi + 11.552*xi + 0.42034))*1e5;
xi=0.6;
carlib_vp_60 = (exp (-0.81264.*log(t).*log(t)*xi*xi + 0.65201.*log(t).*log(t)*xi + 0.81015.*log(t).*log(t)  + 6.5902.*log(t)*xi*xi - 6.2249.*log(t)*xi - 3.8104.*log(t) - 15.826*xi*xi + 11.552*xi + 0.42034))*1e5;
xi=1;
carlib_vp_1 = (exp (-0.81264.*log(t).*log(t)*xi*xi + 0.65201.*log(t).*log(t)*xi + 0.81015.*log(t).*log(t)  + 6.5902.*log(t)*xi*xi - 6.2249.*log(t)*xi - 3.8104.*log(t) - 15.826*xi*xi + 11.552*xi + 0.42034))*1e5;


% Plot fit with data.
figure( 'Name', 'Ethyleneglycole Regress vapourpressure' );
% Plot fit with data.
subplot( 2, 1, 1 );
plot( fitresult, xData, yData, 'predobs', 0.95 );
hold on
plot(t,carlib_vp_00,'k');
plot(t,carlib_vp_60,'g');
plot(t,carlib_vp_1,'--k');
legend( 'Measured values', 'Regress-Function', 'Lower bounds 95%', 'Upper bounds 95%','carlib Xi=0%','carlib Xi=60%','carlib Xi=100%');
% Label axes
xlabel( 'Temperature t [°C]' );
ylabel( 'pressure p [Pa]' );
grid on
hold off

% Plot residuals.
subplot( 2, 1, 2 );
h = plot( fitresult, xData, yData, 'residuals' );
legend( h, 'residuals', 'Zero Line', 'Location', 'NorthEast' );
% Label axes
xlabel( 'Temperature t [°C]' );
ylabel( 'pressure p [Pa]' );
grid on


%% Formel mit Nachkommastellen ausgeben
%coeffnames(fitresult)
coeff = coeffvalues(fitresult);
disp ('Coefficients with 10 decimal places:')
fprintf('p# %0.10f \n',coeff)

