function [fitresult, gof] = Silicon_vapourpressure(vp_S_T, vp_S_D)

%  Messdaten Laden

load('SiliconData.mat');


%% Fit: 'untitled fit 1'.
[xData, yData] = prepareCurveData( vp_S_T, vp_S_D );

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
Tvp_Sil = [0:400];
t=Tvp_Sil;
CARLIB_vp_sil = -1 + t - t;


% Create a figure for the plots.
figure( 'Name', 'Siliconoil (syltherm 800) Regress vaporpressure' );

% Plot fit with data.
subplot( 2, 1, 1 );
h = plot( fitresult, xData, yData, 'predobs', 0.95 );
hold on
plot (Tvp_Sil,CARLIB_vp_sil)
legend( 'Measured values', 'Regress-Function', 'Lower bounds 95%', 'Upper bounds 95%', 'Carlib-Function');
% Label axes
xlabel( 'Temperature t [°C]' );
ylabel( 'vaporpressure vp [kPa]' );
grid on
hold off

% Plot residuals.
subplot( 2, 1, 2 );
h = plot( fitresult, xData, yData, 'residuals' );
legend( h, 'residuals', 'Zero Line', 'Location', 'NorthEast' );
% Label axes
xlabel( 'Temperature t [°C]' );
ylabel( 'vaporpressure vp [kPa]' );
grid on


%% Formel mit Nachkommastellen ausgeben
%coeffnames(fitresult)
coeff = coeffvalues(fitresult);
disp ('Coefficients with 10 decimal places:')
fprintf('p# %0.10f \n',coeff)


