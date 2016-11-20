function [fitresult, gof] = Cottonseedoil_enthalpy()

%  Messdaten Laden

load('CottonseedoilData.mat');

%% Fit: 'untitled fit 1'.
[xData, yData] = prepareCurveData( Th_cot_D,h_cot_D );
%Wenn Angaben in 
yData = yData; 
% Set up fittype and options.
ft = fittype( 'poly1' );
opts = fitoptions( ft );
opts.Lower = [-Inf -Inf -Inf -Inf -Inf];
opts.Upper = [Inf Inf Inf Inf Inf];

% Fit model to data.
[fitresult, gof] = fit( xData, yData, ft, opts );
disp('Goodness:');
disp(gof);

%%CARLIB
Th_cot = [-40:100];
t=Th_cot;
CARLIB_h_cot = (935.0 - 0.6806 .* t).*t/1000;

%%DIFF zwischen carlib und neue Funktion
Th_cot_diff = [-40:80];
T = Th_cot_diff;
newF_poly1 = 2.9296949153.*T;
newF_poly4 = 0.0000108650*T.^4 -0.0003634447*T.^3 -0.0274916161*T.^2 + 3.2641604980*T -0.7681629727;
CARLIB_diff = (935.0 - 0.6806 .* T).*T/1000;
DIFF = newF_poly4 - CARLIB_diff;

% Create a figure for the plots.
figure( 'Name', 'Cottonoil Regress enthalpie' );

% Plot fit with data.
subplot( 2, 1, 1 );
h = plot( fitresult, xData, yData, 'predobs', 0.95 );
hold on
plot (Th_cot,CARLIB_h_cot)
legend( 'Measured values', 'Regress-Function', 'Lower bounds 95%', 'Upper bounds 95%', 'Carlib-Function unter der Annahme dass Carlib in Einheit J/kg rechnet');
% Label axes
xlabel( 'Temperature t [°C]' );
ylabel( 'enthalpy h [kJ/kg]' );
grid on

% Plot residuals.
subplot( 2, 1, 2 );
plot( fitresult, xData, yData, 'residuals' );
% hold on
% plot (Th_cot_diff, DIFF);
legend('residuals', 'Zero Line', 'Location', 'NorthEast', 'FuncDiff');
% Label axes
xlabel( 'Temperature t [°C]' );
ylabel( 'enthalpy h [kJ/kg]' );
grid on
hold off

%Neues Diagramm
figure( 'Name', 'Cottonoil Regress enthalpie2' );
plot( fitresult, xData, yData, 'predobs', 0.95 );
hold on
plot (Th_cot_diff, newF_poly1,'b')
plot (Th_cot_diff, newF_poly4,'r');
plot (Th_cot_diff, CARLIB_diff,'k');
% plot (Th_cot_diff, newF_poly4,'g');
legend('newFunc-poly1','newFunc-poly4','Carlib');
% Label axes
xlabel( 'Temperature t [°C]' );
ylabel( 'enthalpy h [kJ/kg]' );
grid on
hold off

%% Formel mit Nachkommastellen ausgeben
%coeffnames(fitresult)
coeff = coeffvalues(fitresult);
disp ('Coefficients with 10 decimal places:')
fprintf('p# %0.30f \n',coeff)

