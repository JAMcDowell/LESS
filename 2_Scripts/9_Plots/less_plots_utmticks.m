function [] = less_plots_utmticks(METOCEAN,PLOTS)
%% Function Description
% This function converts x and y axis into appropriately spaced UTM ticks
% for plotting a large region.

%% Designate UTM Ticks
set(gca,'XTick',...                                                     % Set x tick limits and intervals.
    (round2(min(METOCEAN.SPATIAL.UTM_E_m,[],'all'),PLOTS.Axes_TickSize_UTM_m) - PLOTS.Axes_TickSize_UTM_m:...
     PLOTS.Axes_TickSize_UTM_m:...
     round2(max(METOCEAN.SPATIAL.UTM_E_m,[],'all'),PLOTS.Axes_TickSize_UTM_m) + PLOTS.Axes_TickSize_UTM_m))
set(gca,'YTick',...                                                     % Set y tick limits and intervals.    
    (round2(min(METOCEAN.SPATIAL.UTM_N_m,[],'all'),PLOTS.Axes_TickSize_UTM_m) - PLOTS.Axes_TickSize_UTM_m:...
     PLOTS.Axes_TickSize_UTM_m:...
     round2(max(METOCEAN.SPATIAL.UTM_N_m,[],'all'),PLOTS.Axes_TickSize_UTM_m) + PLOTS.Axes_TickSize_UTM_m))   
set(gca, 'XTickLabel',num2str((get(gca,'XTick')./1000)'),...            % Set x tick label and fontsize.
    'XTickLabelRotation',90,...
    'FontSize',PLOTS.FontSize_Axes);                                                                
set(gca,'YTickLabel',num2str((get(gca,'YTick')./1000)'),...             % Set y tick label and fontsize.
    'FontSize',PLOTS.FontSize_Axes);         

end
