function [fitresult, gof] = Silicon_density(rho_S_T, rho_S_D)

%  Messdaten Laden

load('SiliconData.mat');


%% Fit: 'untitled fit 1'.
[xData, yData] = prepareCurveData( rho_S_T, rho_S_D );

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
Trho_Sil = [0:150];
t=Trho_Sil;
CARLIB_rho_sil = 983.1 - 0.9232 .* t;

%DIFF
difx = [-20:200];
CDif = 983.1 - 0.9232 .* difx;
FDif = -0.9841486014*difx + 960.0584149184;
DIFF = abs(CDif-FDif);

% Create a figure for the plots.
figure( 'Name', 'Siliconoil (syltherm 800) Regress density' );

% Plot fit with data.
subplot( 2, 1, 1 );
h = plot( fitresult, xData, yData, 'predobs', 0.95 );
hold on
plot (Trho_Sil,CARLIB_rho_sil)
legend( 'Measured values', 'Regress-Function', 'Lower bounds 95%', 'Upper bounds 95%', 'Carlib-Function');
% Label axes
xlabel( 'Temperature t [°C]' );
ylabel( 'density rho [kg/m³]' );
grid on


% Plot residuals.
subplot( 2, 1, 2 );
plot( fitresult, xData, yData, 'residuals' );
hold on
plot(difx,DIFF);
legend('residuals', 'Zero Line', 'Location', 'NorthEast','Functiondif absolut');
% Label axes
xlabel( 'Temperature t [°C]' );
ylabel( 'density rho [kg/m³]' );
grid on


%% Formel mit Nachkommastellen ausgeben
%coeffnames(fitresult)
coeff = coeffvalues(fitresult);
disp ('Coefficients with 10 decimal places:')
fprintf('p# %0.10f \n',coeff)
