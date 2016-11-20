function [fitresult, gof] = propylenglycol_rho_3(t_KSU, xi_KSU, rho_PG_D2)
%  Messdaten Laden
load('PropyleneGlycolData.mat');


%% Fit: 'untitled fit 1'.
[xData, yData, zData] = prepareSurfaceData( t_KSU, xi_KSU, rho_PG_D2 );

% Set up fittype and options.
ft = fittype( 'poly24' );
opts = fitoptions( ft );
opts.Lower = [-Inf -Inf -Inf -Inf -Inf -Inf -Inf -Inf -Inf -Inf -Inf -Inf];
opts.Upper = [Inf Inf Inf Inf Inf Inf Inf Inf Inf Inf Inf Inf];

% Fit model to data.
[fitresult, gof] = fit( [xData, yData], zData, ft, opts );

% Create a figure for the plots.
figure( 'Name', 'untitled fit 1' );

% Plot fit with data.
subplot( 2, 1, 1 );
h = plot( fitresult, [xData, yData], zData );
legend( h, 'untitled fit 1', 'rho_PG_D2 vs. t_KSU, xi_KSU', 'Location', 'NorthEast' );
% Label axes
xlabel( 't_KSU' );
ylabel( 'xi_KSU' );
zlabel( 'rho_PG_D2' );
grid on
view( 65.5, 22 );

% Plot residuals.
subplot( 2, 1, 2 );
h = plot( fitresult, [xData, yData], zData, 'Style', 'Residual' );
legend( h, 'untitled fit 1 - residuals', 'Location', 'NorthEast' );
% Label axes
xlabel( 't_KSU' );
ylabel( 'xi_KSU' );
zlabel( 'rho_PG_D2' );
grid on
view( 65.5, 22 );


