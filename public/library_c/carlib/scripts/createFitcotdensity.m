function createFit(Trho_cot_D,rho_cot_D)
%CREATEFIT Create plot of data sets and fits
%   CREATEFIT(TRHO_COT_D,RHO_COT_D)
%   Creates a plot, similar to the plot in the main Curve Fitting Tool,
%   using the data that you provide as input.  You can
%   use this function with the same data you used with CFTOOL
%   or with different data.  You may want to edit the function to
%   customize the code and this help message.
%
%   Number of data sets:  1
%   Number of fits:  1

% Data from data set "rho_cot_D vs. Trho_cot_D":
%     X = Trho_cot_D:
%     Y = rho_cot_D:
%     Unweighted

% Auto-generated by MATLAB on 12-Sep-2015 17:29:10

load CottonseedoilData

% Set up figure to receive data sets and fits
f_ = clf;
figure(f_);
set(f_,'Units','Pixels','Position',[1 49 1366 571]);
% Line handles and text for the legend.
legh_ = [];
legt_ = {};
% Limits of the x-axis.
xlim_ = [Inf -Inf];
% Axes for the main plot.
ax_ = axes;
set(ax_,'Units','normalized','OuterPosition',[0 .5 1 .5]);
% Axes for the residuals plot.
ax2_ = axes;
set(ax2_,'Units','normalized','OuterPosition',[0 0 1 .5]);
set(ax2_,'Box','on');
% Line handles and text for the residuals plot legend.
legrh_ = [];
legrt_ = {};
set(ax_,'Box','on');
axes(ax_);
hold on;

% --- Plot data that was originally in data set "rho_cot_D vs. Trho_cot_D"
Trho_cot_D = Trho_cot_D(:);
rho_cot_D = rho_cot_D(:);
h_ = line(Trho_cot_D,rho_cot_D,'Parent',ax_,'Color',[0.333333 0 0.666667],...
    'LineStyle','none', 'LineWidth',1,...
    'Marker','.', 'MarkerSize',12);
xlim_(1) = min(xlim_(1),min(Trho_cot_D));
xlim_(2) = max(xlim_(2),max(Trho_cot_D));
legh_(end+1) = h_;
legt_{end+1} = 'rho_cot_D vs. Trho_cot_D';

% Nudge axis limits beyond data limits
if all(isfinite(xlim_))
    xlim_ = xlim_ + [-1 1] * 0.01 * diff(xlim_);
    set(ax_,'XLim',xlim_)
    set(ax2_,'XLim',xlim_)
else
    set(ax_, 'XLim',[-1.0109999999999999, 102.11099999999999]);
    set(ax2_,'XLim',[-1.0109999999999999, 102.11099999999999]);
end

% --- Create fit "fit 1"
ok_ = isfinite(Trho_cot_D) & isfinite(rho_cot_D);
if ~all( ok_ )
    warning( 'GenerateMFile:IgnoringNansAndInfs',...
        'Ignoring NaNs and Infs in data.' );
end
ft_ = fittype('poly1');

% Fit this model using new data
cf_ = fit(Trho_cot_D(ok_),rho_cot_D(ok_),ft_);
% Alternatively uncomment the following lines to use coefficients from the
% original fit. You can use this choice to plot the original fit against new
% data.
%    cv_ = { -0.67371866091515487, 931.88159275631062};
%    cf_ = cfit(ft_,cv_{:});

% Plot this fit
h_ = plot(cf_,'fit',0.95);
set(h_(1),'Color',[1 0 0],...
    'LineStyle','-', 'LineWidth',2,...
    'Marker','none', 'MarkerSize',6);
% Turn off legend created by plot method.
legend off;
% Store line handle and fit name for legend.
legh_(end+1) = h_(1);
legt_{end+1} = 'fit 1';

% Compute and plot residuals.
res_ = rho_cot_D - cf_(Trho_cot_D);
[x_,i_] = sort(Trho_cot_D);
axes(ax2_);
hold on;
h_ = line(x_,res_(i_),'Parent',ax2_,'Color',[1 0 0],...
    'LineStyle','-', 'LineWidth',1,...
    'Marker','.', 'MarkerSize',6);
axes(ax_);
hold on;
legrh_(end+1) = h_;
legrt_{end+1} = 'fit 1';

% --- Finished fitting and plotting data. Clean up.
hold off;
% Display legend
leginfo_ = {'Orientation', 'vertical', 'Location', 'NorthEast'};
h_ = legend(ax_,legh_,legt_,leginfo_{:});
set(h_,'Interpreter','none');
leginfo_ = {'Orientation', 'vertical', 'Location', 'NorthEast'};
h_ = legend(ax2_,legrh_,legrt_,leginfo_{:});
set(h_,'Interpreter','none');
% Remove labels from x- and y-axes.
xlabel(ax_,'');
ylabel(ax_,'');
xlabel(ax2_,'');
ylabel(ax2_,'');
% Add titles to the plots.
title(ax_,'Data and Fits');
title(ax2_,'Residuals');
