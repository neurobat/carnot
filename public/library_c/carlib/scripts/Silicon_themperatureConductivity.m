function [fitresult, gof] = Silicon_themperatureConductivity(c_S_T, c_S_D)

%  Messdaten Laden

load('SiliconData.mat');


%% Fit: 'untitled fit 1'.
[xData, yData] = prepareCurveData( c_S_T, c_S_D );

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
Tc_Sil = [0:150];
t=Tc_Sil;
CARLIB_c_sil = 0.16 + t-t;

%Newfunction
difx = [-20:200];
Newfunction =  -0.0001880769*difx + 0.1387705128;
CARLIB_dif = 0.16 + difx-difx;
DIFF = abs(Newfunction-CARLIB_dif);


% Create a figure for the plots.
figure( 'Name', 'Siliconoil (syltherm 800) Regress thermal Conductivity' );

% Plot fit with data.
subplot( 2, 1, 1 );
h = plot( fitresult, xData, yData, 'predobs', 0.95 );
hold on
plot (Tc_Sil,CARLIB_c_sil)
legend( 'Measured values', 'Regress-Function', 'Lower bounds 95%', 'Upper bounds 95%', 'Carlib-Function');
% Label axes
xlabel( 'Temperature t [°C]' );
ylabel( 'thermal conductivity c [W/m.K]' );
grid on
hold off

% Plot residuals.
subplot( 2, 1, 2 );
plot( fitresult, xData, yData, 'residuals' );
hold on
plot (difx,DIFF);
legend('residuals', 'Zero Line', 'Location', 'NorthEast','Functiondif');
% Label axes
xlabel( 'Temperature t [°C]' );
ylabel( 'thermal conductivity c [W/m.K]' );
grid on


%% Formel mit Nachkommastellen ausgeben
%coeffnames(fitresult)
coeff = coeffvalues(fitresult);
disp ('Coefficients with 10 decimal places:')
fprintf('p# %0.10f \n',coeff)
