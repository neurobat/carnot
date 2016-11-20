function [fitresult, gof] = TYFOCOR_LS_Dichte(T, rho)

%  Messdaten Laden

load ('Tyfocor_Data');

%Ausgabe der Formel
Formel= polyfit(T,rho,3);
fprintf('p# %0.30f \n',Formel)


%% Fit: 'untitled fit 1'.
[xData, yData] = prepareCurveData( T, rho );

% Set up fittype and options.
ft = fittype( 'poly3' );
opts = fitoptions( ft );
opts.Lower = [-Inf -Inf -Inf -Inf -Inf];
opts.Upper = [Inf Inf Inf Inf Inf];

% Fit model to data.
[fitresult, gof] = fit( xData, yData, ft, opts );
disp('Goodness:');
disp(gof);

%Extrapolation
Tex = [-20:200];
Extra =   0.0000031620272422728123*Tex.^3 -0.0022915795388355298*Tex.^2 -0.47852212509689063*Tex + 1044.5812080549749;

% Create a figure for the plots.
figure( 'Name', 'TyfocorLS rho' );

% Plot fit with data.
subplot( 2, 1, 1 );
plot( fitresult, xData, yData, 'predobs', 0.99 );
hold on
plot(Tex,Extra);
legend('rho vs. T', 'Dichteregression Tyfocor', 'Lower bounds', 'Upper bounds', 'Location', 'NorthEast','Extrapolation' );
% Label axes
xlabel( 'T [°C]' );
ylabel( 'rho [kg/m³]' );
grid on

% Plot residuals.
subplot( 2, 1, 2 );
h = plot( fitresult, xData, yData, 'residuals' );
hold on
legend( h, 'residuals', 'Zero Line', 'Location', 'NorthEast' );
% Label axes
xlabel( 'T [°C]' );
ylabel( 'rho [kg/m³]' );
grid on
