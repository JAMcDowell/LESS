function [] = less_plots_vessellabels(PATHFIND,PLOTS)
%% Function Description
% This function plots the vessel labels on LESS region plots.

%% Plot Port Labels
VesselLegend = cell(1,size(PATHFIND.DISCRETE.SITES(1).VESSELS,2));
for s = 1:size(PATHFIND.DISCRETE.SITES,2)
    for v = 1:size(PATHFIND.DISCRETE.SITES(s).VESSELS,2)
        plot(PATHFIND.DISCRETE.SITES(s).VESSELS(v).Path2SuitableValidPort_UTM_EN_m(2:end-1,1),...
             PATHFIND.DISCRETE.SITES(s).VESSELS(v).Path2SuitableValidPort_UTM_EN_m(2:end-1,2),...
             'LineStyle','none','Color',PLOTS.VesselLabels_Colors{v},...
             'Marker',PLOTS.VesselLabels_PathMarkers{v},...
             'MarkerSize',PLOTS.VesselLabels_MarkerSize{v},'LineWidth',2); hold on;
        VesselLegend{v} = PATHFIND.DISCRETE.SITES(s).VESSELS(v).Vessels_Name;
    end
end

leg = legend; leg.String = VesselLegend; 
leg.Location = 'southeast'; leg.FontSize = PLOTS.FontSize_Legend;

end
