function [] = less_plots(LCOE,PATHFIND,METOCEAN)
%% Plot Formatting
% Colors
PLOTS.Colors.Red     = rgb({'Red'});
PLOTS.Colors.Green   = rgb({'Green'});
PLOTS.Colors.Blue    = rgb({'Blue'});
PLOTS.Colors.Orange  = rgb({'Orange'});
PLOTS.Colors.Purple  = rgb({'Purple'});
PLOTS.Colors.HotPink = rgb({'hot pink'});

% Color Maps
disp('Plotting Results...');
TCM = load('ColorMap_JetGreyZero_CharcoalMax.mat'); PLOTS.CustomColormaps.JetGreyZero_CharcoalMax = TCM.JetGreyZero_CharcoalMax; clearvars TCM;
TCM = load('ColorMap_JetGreyZero.mat');             PLOTS.CustomColormaps.JetGreyZero             = TCM.JetGreyZero;             clearvars TCM;
TCM = load('ColorMap_BinarySuitability.mat');       PLOTS.CustomColormaps.BinarySuitability       = TCM.BinarySuitability;       clearvars TCM;

% Font Sizes
PLOTS.FontSize_Axes   = 24;
PLOTS.FontSize_Title  = 24;
PLOTS.FontSize_Legend = 20;

% Axes/Ticks
PLOTS.Axes_TickSize_UTM_m = 10000;
PLOTS.Axes_MarkerPlotPosition_UTM_EN_m = [340000,4970000];

% Metocean Limits
PLOTS.MetoceanLimits_FlowVel = 5;
PLOTS.MetoceanLimits_Hs      = 5;

% Site Labels
PLOTS.SiteLabels_Short  = {'F'};
PLOTS.SiteLabels_Colors = {PLOTS.Colors.HotPink};

% Device Line Types
PLOTS.Device_LineTypes = {'g-','g--',...   
                          'b-','b--',...
                          'r-','r--',...
                          'm-','m--'};  
% Device MATLAB Colors
PLOTS.Device_MATColors = {[0, 0.4470, 0.7410],...
                          [0.8500, 0.3250, 0.0980],...
                          [0, 0.4470, 0.7410],...
                          [0.8500, 0.3250, 0.0980],...
                          [0, 0.4470, 0.7410],...
                          [0.8500, 0.3250, 0.0980]};
% Port Labels
PLOTS.PortLabels_Short         = {'AR','CH','DH','DG','PC','PB','SJ','SB','SM'};
PLOTS.PortLabels_HorzAlignment = {'left','left','left','left','left','left','left','left','left'};
PLOTS.PortLabels_VertAlignment = {'top','top','top','top','top','bottom','bottom','top','bottom'};
PLOTS.PortLabels_Colors        = {PLOTS.Colors.Green,PLOTS.Colors.Green,PLOTS.Colors.Green,PLOTS.Colors.Orange,PLOTS.Colors.Green,PLOTS.Colors.Green,PLOTS.Colors.Red,PLOTS.Colors.Green,PLOTS.Colors.Green};

% Vessel Labels
PLOTS.VesselLabels_PathMarkers = {'x','o','.'};
PLOTS.VesselLabels_Colors      = {PLOTS.Colors.Green,PLOTS.Colors.Orange,PLOTS.Colors.Red};
PLOTS.VesselLabels_MarkerSize  = {8,8,16};

% LCoE CutOff
PLOTS.LCoECut = 501;

% Currency
PLOTS.Currency = 'GBP';

%% Power Law Profiles
PLOTS.Profiles.Exponent = 5.4;
PLOTS.Profiles.BinSize_m = 0.1;
PLOTS.Profiles.Flow1 = 4;
PLOTS.Profiles.Flow2 = 3.7;

PLOTS.Profiles.Depth1_m = 0:PLOTS.Profiles.BinSize_m:43;
PLOTS.Profiles.Depth2_m = 0:PLOTS.Profiles.BinSize_m:50;

[~,PLOTS.Profiles.Profile1] = depav2velprofile(PLOTS.Profiles.Flow1,...
                                               round2(max(PLOTS.Profiles.Depth1_m),...
                                               PLOTS.Profiles.BinSize_m),...
                                               1/PLOTS.Profiles.Exponent,PLOTS.Profiles.BinSize_m);
[~,PLOTS.Profiles.Profile2] = depav2velprofile(PLOTS.Profiles.Flow2,...
                                               round2(max(PLOTS.Profiles.Depth2_m),...
                                               PLOTS.Profiles.BinSize_m),...
                                               1/PLOTS.Profiles.Exponent,PLOTS.Profiles.BinSize_m);
% Plot Profiles
figure;
yyaxis left;
plot(PLOTS.Profiles.Profile1,PLOTS.Profiles.Depth1_m,'LineWidth',2);
ylabel('Depth (Discrete) [m]');
ylim([min(PLOTS.Profiles.Depth1_m) max(PLOTS.Profiles.Depth1_m)]);

yyaxis right;
plot(PLOTS.Profiles.Profile2,PLOTS.Profiles.Depth2_m,'--','LineWidth',2);
plot(PLOTS.Profiles.Profile2,PLOTS.Profiles.Depth2_m,'LineWidth',2);
ylim([min(PLOTS.Profiles.Depth2_m) max(PLOTS.Profiles.Depth2_m)]);

% Labels
xlabel('Absolute Flow Velocity [m/s]');
ylabel('Depth (Spatial) [m]');
title('Impact of Depth-Averaged Flow Velocity Variation on Power Law Profile');
set(gca,'FontSize',PLOTS.FontSize_Axes);    

legend({'4.0 m/s (Discrete)','3.7 m/s (Spatial)'},...
    'location','northwest');
fig2fullscreen;

%% Experience Curves
% Inputs
PLOTS.Exp.LearningRate_pc    = [5,15];
PLOTS.Exp.Capacity_Init_MW   = (4*70/1000);
PLOTS.Exp.LCoE_Init_GBPMWh   = 500;
PLOTS.Exp.Duration_y         = 20;
PLOTS.Exp.LCoE_Offset_GBPMWh = 50;

PLOTS.Exp.CurrentInstalledCapacity = (2*70/1000) + (4*70/1000) + (6*70/1000) + (6*70/1000);
PLOTS.Exp.ProjectCapacity = (6*70/1000) * 21;

% Preallocate
PLOTS.Exp.PredLCoE    = zeros(size(PLOTS.Exp.LearningRate_pc,2),PLOTS.Exp.Duration_y);
PLOTS.Exp.Capacity_MW = zeros(size(PLOTS.Exp.LearningRate_pc,2),PLOTS.Exp.Duration_y);
PLOTS.Exp.LegendLabel = cell(1,size(PLOTS.Exp.LearningRate_pc,2)+5);

% Loop
for lr = 1:size(PLOTS.Exp.LearningRate_pc,2)
    [PLOTS.Exp.PredLCoE(lr,:),...
     PLOTS.Exp.Capacity_MW(lr,:)] = experiencecurve(PLOTS.Exp.Capacity_Init_MW,...
                                                  PLOTS.Exp.LCoE_Init_GBPMWh,...
                                                  PLOTS.Exp.LearningRate_pc(lr),...
                                                  PLOTS.Exp.Duration_y);
end

figure;
% Impact of Learning Rate
for lr = 1:size(PLOTS.Exp.LearningRate_pc,2)
    plot(PLOTS.Exp.Capacity_MW(lr,:),...
         PLOTS.Exp.PredLCoE(lr,:),'linewidth',2); hold on;
     PLOTS.Exp.LegendLabel{lr} = ['LR: ',num2str(round2(PLOTS.Exp.LearningRate_pc(lr),0.1)),'%'];
end; grid on;

% LESS Estimates
PLOTS.Exp.ConstantLESS = (PLOTS.Exp.LCoE_Init_GBPMWh).*ones(1,PLOTS.Exp.Duration_y);
plot(PLOTS.Exp.Capacity_MW(end,:),...
     PLOTS.Exp.ConstantLESS,...
     'k','linewidth',2);
PLOTS.Exp.LegendLabel{end-4} = 'LESS Tool (LR: 0%, No Prior Learning)';

PLOTS.Exp.ConstantLESS = (450).*ones(1,PLOTS.Exp.Duration_y);
plot(PLOTS.Exp.Capacity_MW(end,:),...
     PLOTS.Exp.ConstantLESS,...
     '-.','linewidth',2,'color',[0, 0.4470, 0.7410]);
PLOTS.Exp.LegendLabel{end-3} = 'LESS Tool (LR: 0%, 5% Prior Learning, Current Installed Capacity)';

PLOTS.Exp.ConstantLESS = (385).*ones(1,PLOTS.Exp.Duration_y);
plot(PLOTS.Exp.Capacity_MW(end,:),...
     PLOTS.Exp.ConstantLESS,...
     '--','linewidth',2,'color',[0, 0.4470, 0.7410]);
PLOTS.Exp.LegendLabel{end-2} = 'LESS Tool (LR: 0%, 5% Prior Learning, Case Project Capacity)';

PLOTS.Exp.ConstantLESS = (360).*ones(1,PLOTS.Exp.Duration_y);
plot(PLOTS.Exp.Capacity_MW(end,:),...
     PLOTS.Exp.ConstantLESS,...
     '-.','linewidth',2,'color',[0.8500, 0.3250, 0.0980]);
PLOTS.Exp.LegendLabel{end-1} = 'LESS Tool (LR: 0%, 15% Prior Learning, Current Installed Capacity)';

PLOTS.Exp.ConstantLESS = (220).*ones(1,PLOTS.Exp.Duration_y);
plot(PLOTS.Exp.Capacity_MW(end,:),...
     PLOTS.Exp.ConstantLESS,...
     '--','linewidth',2,'color',[0.8500, 0.3250, 0.0980]);
PLOTS.Exp.LegendLabel{end} = 'LESS Tool (LR: 0%, 15% Prior Learning, Case Project Capacity)';

xlabel('Installed Capacity [MW]');
ylabel('Estimates of OpEx / LCoE');
xlim([0 10]);
ylim([0 PLOTS.Exp.LCoE_Init_GBPMWh + PLOTS.Exp.LCoE_Offset_GBPMWh]);
%set(gca,'XTick',[]);
set(gca,'YTick',[]);

legend(PLOTS.Exp.LegendLabel,'interpreter','none','location','southwest');
title('Impact of Learning Rates on Estimates of OpEx / LCoE over Case Study Project Duration');
set(gca,'FontSize',PLOTS.FontSize_Axes);    

fig2fullscreen;
clearvars lr;

%% Power Curves
% Figure
figure;
for d = [1,2]
    plot(DEVICES(d).PowerPerformance.Flow_Vel_Abs_PWA_ms,...
         DEVICES(d).PowerPerformance.Power_W ./ 1000,...
         'linewidth',2); hold on; 
end; grid on; hold off;

% Ticks & Colormaps
xlim([0 PLOTS.MetoceanLimits_FlowVel]);
set(gca,'FontSize',PLOTS.FontSize_Axes);    

% Labels                                                                      
xlabel('In-Flow Velocity [m/s]','FontSize',PLOTS.FontSize_Axes);
ylabel('Instantaneous Electrical Power Generated [kW]','FontSize',PLOTS.FontSize_Axes);
title('Power Performance Curves for SCHOTTEL In-stream Turbines','FontSize',PLOTS.FontSize_Title);
legend('SIT40','SIT63','FontSize',PLOTS.FontSize_Legend,'location','northwest');

% Sizing
fig2fullscreen; clearvars d;

%% Daylight Hours
% Figure (left)
figure;
yyaxis left
plot(OPERATIONS.DISCRETE.SITES.DaylightHours.Time,...
     OPERATIONS.DISCRETE.SITES.DaylightHours.Daylight_h,...
     '-.','linewidth',5);

% Labels (left)
xlabel('Date','FontSize',PLOTS.FontSize_Axes);  
ylabel('Daylight Hours','FontSize',PLOTS.FontSize_Axes);

% Ticks & Colormaps (left)
ylim([0 24]); yticks([0 4 8 12 16 20 24]);
set(gca,'FontSize',PLOTS.FontSize_Axes); 

% Figure (right)
yyaxis right
plot(OPERATIONS.DISCRETE.SITES.DaylightHours.Time,...
     OPERATIONS.DISCRETE.SITES.DaylightHours.DaylightRatio,...
     '--','linewidth',5);

% Ticks & Colormaps (right)
ylim([0 1]);
set(gca,'FontSize',PLOTS.FontSize_Axes); 

% Labels (right)
ylabel('Daylight Ratio','FontSize',PLOTS.FontSize_Axes); 
title('Seasonal Variation in Daylight Hours & Ratio at FORCE Site','FontSize',PLOTS.FontSize_Title);

% Sizing
fig2fullscreen;

%% Surface & PWA Absolute Flow Velocity
% Figure (Surface Flow)
figure;
plot(METOCEAN.DISCRETE.FORCE.DateTime_UTC,...
     YIELD.DISCRETE.IDEAL.GENERATED.SITES.Flow_Vel_Abs_Surf_ms.Flow_Vel_Abs_Surf_ms,...
     'k-','linewidth',2); hold on;
LegendLabel = {'Surface'};

% Figure (PWA Flow)             
for d = 1:size(DEVICES,2)
    plot(METOCEAN.DISCRETE.FORCE.DateTime_UTC,...
        YIELD.DISCRETE.IDEAL.GENERATED.SITES.DEVICES(d).Flow_Vel_Abs_PWA_ms.Flow_Vel_Abs_PWA_ms,...
        PLOTS.Device_LineTypes{d},'linewidth',2); hold on;
    LegendLabel{d+1} = ['PWA: ',DEVICES(d).Name];
end

% Ticks & Colormaps 
ylim([0 PLOTS.MetoceanLimits_FlowVel]);
set(gca, 'FontSize',PLOTS.FontSize_Axes); 

% Labels
xlabel('Date','FontSize',PLOTS.FontSize_Axes);
ylabel('Flow Velocity [m/s]','FontSize',PLOTS.FontSize_Axes);  
legend(LegendLabel,'FontSize',PLOTS.FontSize_Legend,'location','northwest','Interpreter','none');	
title('Surface & Power-Weighted Average Absolute Flow Velocities at FORCE Site','FontSize',PLOTS.FontSize_Title);

% Sizing
fig2fullscreen; clearvars LegendLabel d;

%% Instantaneous Power Generated
% Figure
figure;
LegendLabel = {''};    
for d = 1:size(DEVICES,2)
    plot(METOCEAN.DISCRETE.FORCE.DateTime_UTC,...
         TRANSM.DISCRETE.SITES(1).DEVICES(d).Power_Ideal_GenDelLossPerDevice_kW  .Power_Ideal_GenPerDevice_kW,...
         PLOTS.Device_LineTypes{d},'linewidth',2); hold on;
    LegendLabel{d} = DEVICES(d).Name;
end

% Ticks & Colormaps
ylim([0 300]);
set(gca,'FontSize',PLOTS.FontSize_Axes); 

% Labels
xlabel('Date','FontSize',PLOTS.FontSize_Axes);
ylabel('Instantaneous Power Generated [kW]','FontSize',PLOTS.FontSize_Axes);  
legend(LegendLabel,'FontSize',PLOTS.FontSize_Legend,'location','northwest','Interpreter', 'none');	
title('Instantaneous Power Generated at FORCE Site','FontSize',PLOTS.FontSize_Axes);

% Sizing
fig2fullscreen; clearvars LegendLabel d;   
 
%% Depth-Averaged Flow Velocity
% Data
[PLOTS.DepthAvFlowVel.Max,...
 PLOTS.DepthAvFlowVel.Max_LinIdx] = max(METOCEAN.SPATIAL.Flow_Vel_Abs_DepAv_ms(:));
[PLOTS.DepthAvFlowVel.t,...
 PLOTS.DepthAvFlowVel.m,...
 PLOTS.DepthAvFlowVel.n]...
    = ind2sub(size(METOCEAN.SPATIAL.Flow_Vel_Abs_DepAv_ms),...
                   PLOTS.DepthAvFlowVel.Max_LinIdx);
% Figure               
figure;
pcolor(METOCEAN.SPATIAL.UTM_E_m,...
       METOCEAN.SPATIAL.UTM_N_m,...
       squeeze(METOCEAN.SPATIAL.Flow_Vel_Abs_DepAv_ms(PLOTS.DepthAvFlowVel.t,:,:)));
shading interp; hold on;

% Ticks & Colormaps
less_plots_utmticks(METOCEAN,PLOTS);
c = colorbar; colormap(parula);
caxis([0, PLOTS.MetoceanLimits_FlowVel]); c.FontSize = PLOTS.FontSize_Axes;

% Labels
xlabel('UTM Easting [km]','FontSize',PLOTS.FontSize_Axes);
ylabel('UTM Northing [km]','FontSize',PLOTS.FontSize_Axes);
c.Label.String = 'Depth-averaged Flow Velocity [m/s]'; c.Label.FontSize = PLOTS.FontSize_Axes;
title(['Spatial Variation in Depth-Averaged Flow Velocity (',datestr(METOCEAN.SPATIAL.DateTime_UTC(PLOTS.DepthAvFlowVel.t)),')'],'FontSize',PLOTS.FontSize_Title);

% Sizing
axis equal; fig2fullscreen; clearvars c;

%% Surface Flow Velocity
% Data
[PLOTS.SurfFlowVel.Max,...
 PLOTS.SurfFlowVel.Max_LinIdx] = max(METOCEAN.SPATIAL.Flow_Vel_Abs_DepAv_ms(:));
[PLOTS.SurfFlowVel.t,...
 PLOTS.SurfFlowVel.m,...
 PLOTS.SurfFlowVel.n]...
    = ind2sub(size(METOCEAN.SPATIAL.Flow_Vel_Abs_DepAv_ms),...
              PLOTS.SurfFlowVel.Max_LinIdx);
% Figure          
figure;
pcolor(METOCEAN.SPATIAL.UTM_E_m,...
       METOCEAN.SPATIAL.UTM_N_m,...
       squeeze(YIELD.SPATIAL.IDEAL.GENERATED.Flow_Vel_Abs_Surf_ms(PLOTS.SurfFlowVel.t,:,:)));
shading interp; hold on;

% Ticks & Colormaps
less_plots_utmticks(METOCEAN,PLOTS);                                                
c = colorbar; colormap(jet); 
caxis([0, PLOTS.MetoceanLimits_FlowVel]); c.FontSize = PLOTS.FontSize_Axes;

% Labels
xlabel('UTM Easting [km]','FontSize',PLOTS.FontSize_Axes);
ylabel('UTM Northing [km]','FontSize',PLOTS.FontSize_Axes);
c.Label.String = 'Surface Absolute Flow Velocity [m/s]'; c.Label.FontSize = PLOTS.FontSize_Axes;
title(['Spatial Variation in Surface Absolute Flow Velocity (',datestr(METOCEAN.SPATIAL.DateTime_UTC(PLOTS.SurfFlowVel.t)),')'],'FontSize',PLOTS.FontSize_Title);

% Sizing
axis equal; fig2fullscreen; clearvars c;

%% Significant Wave Height (at max Wave height)
% Data
[PLOTS.WaveHs.Max,...
 PLOTS.WaveHs.Max_LinIdx] = max(METOCEAN.SPATIAL.Wave_Hs_m(:));
 PLOTS.WaveHs.PicPerfOffset = -14;
[PLOTS.WaveHs.t,...
 PLOTS.WaveHs.m,...
 PLOTS.WaveHs.n] = ind2sub(size(METOCEAN.SPATIAL.Wave_Hs_m),...
                           PLOTS.WaveHs.Max_LinIdx);
% Figure                       
figure;
pcolor(METOCEAN.SPATIAL.UTM_E_m,...
       METOCEAN.SPATIAL.UTM_N_m,...
       squeeze(METOCEAN.SPATIAL.Wave_Hs_m(PLOTS.WaveHs.t+PLOTS.WaveHs.PicPerfOffset,:,:)));
shading interp; hold on;

% Ticks & Colormaps
less_plots_utmticks(METOCEAN,PLOTS);
c = colorbar; colormap(parula); 
caxis([0, PLOTS.MetoceanLimits_Hs]); c.FontSize = PLOTS.FontSize_Axes;

% Labels
xlabel('UTM Easting [km]','FontSize',PLOTS.FontSize_Axes);
ylabel('UTM Northing [km]','FontSize',PLOTS.FontSize_Axes);
c.Label.String = 'Significant Wave Height [m]'; c.Label.FontSize = PLOTS.FontSize_Axes;
title(['Spatial Variation in Significant Wave Height (',datestr(METOCEAN.SPATIAL.DateTime_UTC(PLOTS.WaveHs.t+PLOTS.WaveHs.PicPerfOffset)),')'],'FontSize',PLOTS.FontSize_Title);

% Sizing
axis equal; fig2fullscreen; clearvars c;

%% Deployment Suitability (Valid Deployment Locations)  
for d = [2,4,6]
    % Figure
    figure;
    pcolor(METOCEAN.SPATIAL.UTM_E_m,...
           METOCEAN.SPATIAL.UTM_N_m,...
           single(YIELD.SPATIAL.IDEAL.GENERATED.DEVICES(d).ValidDeviceDeployment_Binary));
    shading interp; hold on;

    % Ticks & Colormaps
    less_plots_utmticks(METOCEAN,PLOTS); 
    colormap(PLOTS.CustomColormaps.BinarySuitability);

    % Labels
    xlabel('UTM Easting [km]','FontSize',PLOTS.FontSize_Axes);
    ylabel('UTM Northing [km]','FontSize',PLOTS.FontSize_Axes);
    title(['Binary Deployment Suitability for ',DEVICES(d).Name(1:end-4),' Devices'],'FontSize',PLOTS.FontSize_Title,'Interpreter','none');
%    title(['Binary Deployment Suitability for PLAT-O & HBMT Devices'],'FontSize',PLOTS.FontSize_Title,'Interpreter','none');    

    % Sizing
    axis equal; fig2fullscreen;
end; clearvars d;

%% PWA Flow Velocity
for d = 1:size(DEVICES,2)
    % Data
    [PLOTS.PWAFlowVel(d).Max,...
     PLOTS.PWAFlowVel(d).Max_LinIdx] = max(YIELD.SPATIAL.IDEAL.GENERATED.DEVICES(d).Flow_Vel_Abs_PWA_ms(:));
    [PLOTS.PWAFlowVel(d).t,...
     PLOTS.PWAFlowVel(d).m,...
     PLOTS.PWAFlowVel(d).n]...
        = ind2sub(size(YIELD.SPATIAL.IDEAL.GENERATED.DEVICES(d).Flow_Vel_Abs_PWA_ms),...
                  PLOTS.PWAFlowVel(d).Max_LinIdx);
    % Figure          
    figure;
    pcolor(METOCEAN.SPATIAL.UTM_E_m,...
           METOCEAN.SPATIAL.UTM_N_m,...
           squeeze(YIELD.SPATIAL.IDEAL.GENERATED.DEVICES(d).Flow_Vel_Abs_PWA_ms(PLOTS.PWAFlowVel(d).t,:,:)));
    shading interp; hold on;

    % Ticks & Colormaps
    less_plots_utmticks(METOCEAN,PLOTS);
    c = colorbar; colormap(PLOTS.CustomColormaps.JetGreyZero);
    caxis([0, PLOTS.MetoceanLimits_FlowVel]); c.FontSize = PLOTS.FontSize_Axes;

    % Labels
    xlabel('UTM Easting [km]','FontSize',PLOTS.FontSize_Axes);
    ylabel('UTM Northing [km]','FontSize',PLOTS.FontSize_Axes);
    c.Label.String = 'PWA Absolute Flow Velocity [m/s]'; c.Label.FontSize = PLOTS.FontSize_Axes;
    title(['Spatial Variation in PWA Absolute Flow Velocity for ',DEVICES(d).Name,' Devices (',datestr(METOCEAN.SPATIAL.DateTime_UTC(PLOTS.PWAFlowVel(d).t)),')'],'FontSize',PLOTS.FontSize_Title,'Interpreter','none');

    % Sizing
    axis equal; fig2fullscreen; clearvars c d;
end

%% PLOT Site & Port Locations
% Figure
figure;
P = pcolor(METOCEAN.SPATIAL.UTM_E_m,...
           METOCEAN.SPATIAL.UTM_N_m,...
           METOCEAN.SPATIAL.ChartDatum_Z_m);
shading interp; hold on; P.HandleVisibility = 'off';

% Ticks & Colormaps
less_plots_utmticks(METOCEAN,PLOTS);                                        
c = colorbar; colormap(bone); c.FontSize = PLOTS.FontSize_Axes;
caxis([0, round2(max(METOCEAN.SPATIAL.ChartDatum_Z_m,[],'all'),10)]);

% Labels
xlabel('UTM Easting [km]','FontSize',PLOTS.FontSize_Axes);
ylabel('UTM Northing [km]','FontSize',PLOTS.FontSize_Axes);
c.Label.String = 'Depth [m]'; c.Label.FontSize = PLOTS.FontSize_Axes;
%title('Site & Port Locations plotted over Region Bathymetry','FontSize',PLOTS.FontSize_Title);
title('Bay of Fundy Region Bathymetry','FontSize',PLOTS.FontSize_Title);

% Markers
less_plots_sitelabels(PATHFIND,PLOTS,'Full');
%less_plots_portlabels(PATHFIND,PLOTS,'Full','On');
PLOTS.OpenBoundary = [272500,4947500;272500,5008500];
plot(PLOTS.OpenBoundary(:,1),PLOTS.OpenBoundary(:,2),...
    'Color',PLOTS.Colors.Blue,'linewidth',3);
legend('Open Boundary','location','southeast');

% Sizing
axis equal; fig2fullscreen; clearvars c P;

%% PLOT A* Paths from Site to Port for each Vessel
figure;
P = pcolor(METOCEAN.SPATIAL.UTM_E_m,...
           METOCEAN.SPATIAL.UTM_N_m,...
           METOCEAN.SPATIAL.ChartDatum_Z_m);
shading interp; hold on; P.HandleVisibility = 'off';

less_plots_utmticks(METOCEAN,PLOTS);                                     
c = colorbar; colormap(bone); c.FontSize = PLOTS.FontSize_Axes;  
caxis([0, round2(max(METOCEAN.SPATIAL.ChartDatum_Z_m,[],'all'),10)]); 

xlabel('UTM Easting [km]', 'FontSize',PLOTS.FontSize_Axes);
ylabel('UTM Northing [km]','FontSize',PLOTS.FontSize_Axes);
c.Label.String = 'Depth [m]'; c.Label.FontSize = PLOTS.FontSize_Axes;
title({'A* Shortest Vessel Paths from FORCE Site to Port',...
       'Plotted over Region Bathymetry'},...
       'FontSize',PLOTS.FontSize_Title);

less_plots_sitelabels(PATHFIND,PLOTS,'Full');
less_plots_portlabels(PATHFIND,PLOTS,'None','Off');
less_plots_vessellabels(PATHFIND,PLOTS);
axis equal; fig2fullscreen; clearvars c P;

%% PLOT A* Paths from Site to Landfall for Transmission
% Figure
figure;
P = pcolor(METOCEAN.SPATIAL.UTM_E_m,...
           METOCEAN.SPATIAL.UTM_N_m,...
           METOCEAN.SPATIAL.ChartDatum_Z_m);
shading interp; hold on; P.HandleVisibility = 'off';

% Ticks & Colormaps
less_plots_utmticks(METOCEAN,PLOTS);
c = colorbar; colormap(bone); c.FontSize = PLOTS.FontSize_Axes;
caxis([0, round2(max(METOCEAN.SPATIAL.ChartDatum_Z_m,[],'all'),10)]); 

% Labels
xlabel('UTM Easting [km]','FontSize',PLOTS.FontSize_Axes);
ylabel('UTM Northing [km]','FontSize',PLOTS.FontSize_Axes);
c.Label.String = 'Depth [m]'; c.Label.FontSize = PLOTS.FontSize_Axes;
title('A* Shortest Transmission Path from FORCE Site to Landfall','FontSize',PLOTS.FontSize_Title);

% Markers
less_plots_sitelabels(PATHFIND,PLOTS,'Full');
for s = 1:size(PATHFIND.DISCRETE.SITES,2)
    plot(PATHFIND.DISCRETE.SITES(s).TRANSMISSION.Path2LandFall_UTM_EN_m(:,1),...
         PATHFIND.DISCRETE.SITES(s).TRANSMISSION.Path2LandFall_UTM_EN_m(:,2),...
         'color',rgb('turquoise'),'Marker','.','LineWidth',6); hold on;
end
leg = legend; leg.String = 'Transmission Path'; 
leg.Location = 'southeast'; leg.FontSize = PLOTS.FontSize_Legend;

% Sizing
axis equal; fig2fullscreen; clearvars c leg P s;

%% Transit Distance (for each Vessel)
% Data
PLOTS.MaxVesselTransitDistances = zeros(1,size(PATHFIND.DISCRETE.SITES(1).VESSELS,2));
for v = 1:size(PATHFIND.DISCRETE.SITES(1).VESSELS,2)
    PLOTS.MaxVesselTransitDistances(v)...
        = max(PATHFIND.SPATIAL.VESSELS(v).Path2SuitableValidPort_AStarDistance_m,[],'all');
end

for v = 1:size(PATHFIND.DISCRETE.SITES(1).VESSELS,2)
    % Figure
    figure;
    P = pcolor(METOCEAN.SPATIAL.UTM_E_m,...
               METOCEAN.SPATIAL.UTM_N_m,...
               PATHFIND.SPATIAL.VESSELS(v).Path2SuitableValidPort_AStarDistance_m./1000);
               shading interp; hold on; P.HandleVisibility = 'off';

    % Ticks & Colormaps           
    less_plots_utmticks(METOCEAN,PLOTS);
    c = colorbar; colormap(jet); c.FontSize = PLOTS.FontSize_Axes;
    caxis([0, round2(max(PLOTS.MaxVesselTransitDistances)/1000,10)]);

    % Labels
    xlabel('UTM Easting [km]','FontSize',PLOTS.FontSize_Axes);
    ylabel('UTM Northing [km]','FontSize',PLOTS.FontSize_Axes);
    c.Label.String = 'Transit Distance [km]'; c.Label.FontSize = PLOTS.FontSize_Axes;
    title(['A* Shortest Vessel Paths from Site to Port for ',PATHFIND.SPATIAL.VESSELS(v).Vessels_Name,' Vessel'],'FontSize',PLOTS.FontSize_Title);

    % Markers
    less_plots_portlabels(PATHFIND,PLOTS,'None','On');

    % Sizing
    axis equal; fig2fullscreen; clearvars c P;
end; clearvars v; 

%% CapEx (for each turbine, otherwise identical)
for d = 3:4
    % Figure
    figure;
    P = pcolor(METOCEAN.SPATIAL.UTM_E_m,...
               METOCEAN.SPATIAL.UTM_N_m,...
               LCOE.SPATIAL.DEVICES(d).CAPEX.TotalCapEx_CCC);
               shading interp; hold on; P.HandleVisibility = 'off';
               
    % Ticks & Colormaps
    less_plots_utmticks(METOCEAN,PLOTS);
    c = colorbar; colormap(PLOTS.CustomColormaps.JetGreyZero); c.FontSize = PLOTS.FontSize_Axes;
    caxis([0, round2(max(LCOE.SPATIAL.DEVICES(d).CAPEX.TotalCapEx_CCC,[],'all'),10000)]); 

    % Labels
    xlabel('UTM Easting [km]','FontSize',PLOTS.FontSize_Axes);
    ylabel('UTM Northing [km]','FontSize',PLOTS.FontSize_Axes);
    c.Label.String = ['CapEx [',PLOTS.Currency,']']; c.Label.FontSize = PLOTS.FontSize_Axes;
    title(['Total Capital Expenditure for Devices Equipped with SIT',DEVICES(d).Name(end-1:end),' Turbines'],'FontSize',PLOTS.FontSize_Title);
      
    % Sizing
    axis equal; fig2fullscreen; pause(1);
    for C = 1:size(c.Ticks,2)
        c.TickLabels{C} = num2bank(c.Ticks(C));
    end
end; clearvars c C d P;

%% DecEx (for each turbine, otherwise identical) 
for d = 3:4
    % Figure
    figure;
    P = pcolor(METOCEAN.SPATIAL.UTM_E_m,...
               METOCEAN.SPATIAL.UTM_N_m,...
               LCOE.SPATIAL.DEVICES(d).DECEX.TotalDecEx_CCC);
               shading interp; hold on; P.HandleVisibility = 'off';
    % Ticks & Colormaps
    less_plots_utmticks(METOCEAN,PLOTS);
    c = colorbar; colormap(PLOTS.CustomColormaps.JetGreyZero); c.FontSize = PLOTS.FontSize_Axes;
    caxis([0, round2(max(LCOE.SPATIAL.DEVICES(d).DECEX.TotalDecEx_CCC,[],'all'),10000)]); 

    % Labels
    xlabel('UTM Easting [km]','FontSize',PLOTS.FontSize_Axes);
    ylabel('UTM Northing [km]','FontSize',PLOTS.FontSize_Axes);
    c.Label.String = ['DecEx [',PLOTS.Currency,']']; c.Label.FontSize = PLOTS.FontSize_Axes;
    title(['Total Decommissioning Expenditure for Devices Equipped with SIT',DEVICES(d).Name(end-1:end),' Turbines'],'FontSize',PLOTS.FontSize_Title);
    
    % Sizing
    axis equal; fig2fullscreen; pause(1);
    for C = 1:size(c.Ticks,2)
        c.TickLabels{C} = num2bank(c.Ticks(C));
    end
end; clearvars c C d P;

%% Transmission Distance
% Figure
figure;
P = pcolor(METOCEAN.SPATIAL.UTM_E_m,...
           METOCEAN.SPATIAL.UTM_N_m,...
           PATHFIND.SPATIAL.TRANSMISSION.Path2LandFall_AStarDistance_m./1000);
           shading interp; hold on; P.HandleVisibility = 'off';
           
% Ticks & Colormaps
less_plots_utmticks(METOCEAN,PLOTS);
c = colorbar; colormap(jet); c.FontSize = PLOTS.FontSize_Axes;
caxis([0, round2(max(PATHFIND.SPATIAL.TRANSMISSION.Path2LandFall_AStarDistance_m,[],'all')./1000,10)]); 

% Labels
xlabel('UTM Easting [km]','FontSize',PLOTS.FontSize_Axes);
ylabel('UTM Northing [km]','FontSize',PLOTS.FontSize_Axes);
c.Label.String = 'Transmission Distance [km]'; c.Label.FontSize = PLOTS.FontSize_Axes;
title('A* Shortest Transmission Distance to Landfall','FontSize',PLOTS.FontSize_Title);

% Sizing
axis equal; fig2fullscreen; clearvars c P;

%% Total Standby - Probability of Non-Persistence for Major Maintenance using OSV
for d = [2,4,6]
    % Figure;
    figure;
    P = pcolor(METOCEAN.SPATIAL.UTM_E_m,...
               METOCEAN.SPATIAL.UTM_N_m,...
               LCOE.SPATIAL.DEVICES(d).AED.OPERATIONS(5).VESSELS(3).MeanProbMetoceanDownTime.*100);
               shading interp; hold on; P.HandleVisibility = 'off';

    % Ticks & Colormaps           
    less_plots_utmticks(METOCEAN,PLOTS);
    c = colorbar; colormap(PLOTS.CustomColormaps.JetGreyZero); c.FontSize = PLOTS.FontSize_Axes;
    caxis([0, 100]); 

    % Labels
    xlabel('UTM Easting [km]','FontSize',PLOTS.FontSize_Axes);
    ylabel('UTM Northing [km]','FontSize',PLOTS.FontSize_Axes);
    c.Label.String = 'Probability of Non-Persistence [%]'; c.Label.FontSize = PLOTS.FontSize_Axes;
    title({'Mean Probability of Non-Persistence of Metocean Conditions:',...
          ['Major Maintenance Operation using OSV for ',DEVICES(d).Name(1:end-4),' Devices']},...
          'FontSize',PLOTS.FontSize_Title);
      
    % Markers
    less_plots_portlabels(PATHFIND,PLOTS,'None','On');
      
    % Sizing
    axis equal; fig2fullscreen; clearvars c P;    
end; clearvars d;

%% Total Annual OpEx (Mean)
% Data
PLOTS.MaxAnnualOpExLESSMeanEstimate = zeros(1,size(DEVICES,2));
for d = 1:size(DEVICES,2)
    PLOTS.MaxAnnualOpExLESSMeanEstimate(d)...
        = max(LCOE.SPATIAL.DEVICES(d).OPEX.Total_AnnualOpEx_Mean_CCCpy,[],'all');
end; clearvars d;

for d = [2,4,6]
    % Figure
    figure;
    P = pcolor(METOCEAN.SPATIAL.UTM_E_m,...
               METOCEAN.SPATIAL.UTM_N_m,...
               LCOE.SPATIAL.DEVICES(d).OPEX.Total_AnnualOpEx_Mean_CCCpy);
               shading interp; hold on; P.HandleVisibility = 'off';

    % Ticks & Colormaps           
    less_plots_utmticks(METOCEAN,PLOTS);
    c = colorbar; colormap(PLOTS.CustomColormaps.JetGreyZero); c.FontSize = PLOTS.FontSize_Axes;
    %caxis([0, max(PLOTS.MaxAnnualOpExLESSMeanEstimate)]);
    caxis([0, ceil(max(LCOE.SPATIAL.DEVICES(d).OPEX.Total_AnnualOpEx_Mean_CCCpy/5000000,[],'all'))*5000000]);
    
    % Labels
    xlabel('UTM Easting [km]','FontSize',PLOTS.FontSize_Axes);
    ylabel('UTM Northing [km]','FontSize',PLOTS.FontSize_Axes);
    c.Label.String = ['Total Annual OpEx [',PLOTS.Currency,']']; c.Label.FontSize = PLOTS.FontSize_Axes;
    title(['Mean Total Annual Operational Expenditure for ',DEVICES(d).Name(1:end-4),' Devices'],'FontSize',PLOTS.FontSize_Title,'Interpreter','none');

    % Markers
    less_plots_portlabels(PATHFIND,PLOTS,'None','On');
    
    % Sizing
    axis equal; fig2fullscreen; pause(1);
    for C = 1:size(c.Ticks,2)
        c.TickLabels{C} = num2bank(c.Ticks(C));
    end; clearvars c C P;
end; clearvars d;

%% Instantaneous Power Generated - Each Set of Devices
% d = [1,2] for PLATO, [3,4] for PLATI, [5,6] for HBMT

% Figure (Power, left)
fig = figure; set(fig,'defaultAxesColorOrder',[rgb('black');rgb('black')]);
yyaxis left;
for d = [5,6]
    area(YIELD.DISCRETE.IDEAL.GENERATED.SITES.DEVICES(d).Power_Ideal_GenPerDevice_kW.Time,...
         YIELD.DISCRETE.IDEAL.GENERATED.SITES.DEVICES(d).Power_Ideal_GenPerDevice_kW.Power_Generated_kW,...
         'linestyle','none','FaceColor',PLOTS.Device_MATColors{d},'FaceAlpha',0.5); hold on;
end; grid on;

% Ticks & Colormaps (Power, left)
set(gca,'FontSize',PLOTS.FontSize_Axes); 
ylim([0 300]);

% Labels (Power, left)
xlabel('Date','FontSize',PLOTS.FontSize_Axes);
ylabel('Instantaneous Power Generated [kW]','FontSize',PLOTS.FontSize_Axes);

% Figure (Flow, right)
yyaxis right;
plot(YIELD.DISCRETE.IDEAL.GENERATED.SITES.Flow_Vel_Abs_Surf_ms.Time,...
     YIELD.DISCRETE.IDEAL.GENERATED.SITES.Flow_Vel_Abs_Surf_ms.Flow_Vel_Abs_Surf_ms,...
     '-','linewidth',1);
 
% Ticks & Colormaps (Flow, right) 
ylim([0 PLOTS.MetoceanLimits_FlowVel]);

% Labels (Flow, right) 
ylabel('Surface Absolute Flow Velocity [m/s]','FontSize',PLOTS.FontSize_Axes);
legend('SIT40','SIT63','Surf. Abs. Flow Vel.','Interpreter','none','FontSize',PLOTS.FontSize_Legend,'location','northwest');
title(['Instantaneous Power Generated for a ',DEVICES(d).Name(1:end-4),' Device at FORCE Site'],'FontSize',PLOTS.FontSize_Title,'Interpreter','none');

% Sizing
fig2fullscreen; clearvars d;

%% Cumulative Instantaneous Power - Array of each Device
% Figure (Cumulative)
figure;
for d = 1:6
plot(YIELD.DISCRETE.IDEAL.GENERATED.SITES.DEVICES(d).Power_Ideal_GenPerDevice_kW.Time,...
     cumsum(YIELD.DISCRETE.IDEAL.GENERATED.SITES.DEVICES(d).Power_Ideal_GenPerDevice_kW.Power_Generated_kW).*SCENARIO.Project.Project_ArraySize.Project_ArraySize(1)./1000,...
     PLOTS.Device_LineTypes{d},'linewidth',2); hold on;
end; hold off; grid on; clearvars d;

% Ticks & Colormaps
set(gca, 'FontSize',PLOTS.FontSize_Axes); 
ax = ancestor(gca,'axes');
ax.YAxis.Exponent = 0;
ax.YAxis.TickLabelFormat = '%,.0f';

% Labels
xlabel('Date','FontSize',PLOTS.FontSize_Axes);
ylabel('Instantaneous Power Generated [MW]','FontSize',PLOTS.FontSize_Axes);
legend({DEVICES.Name},'Interpreter','none','FontSize',PLOTS.FontSize_Legend,'location','northwest');
title('Cumulative Instantaneous Power Generated for Array of Case Study Devices at FORCE Site','FontSize',PLOTS.FontSize_Title,'Interpreter','none');

% Sizing
fig2fullscreen; clearvars ax;

%% Ideal Annual Energy Delivered
% Data
PLOTS.MaxIdealAED = zeros(1,size(DEVICES,2));
for d = 1:size(DEVICES,2)
    PLOTS.MaxIdealAED(d)...
        = max(LCOE.SPATIAL.DEVICES(d).AED.Ideal_MWh,[],'all');
end; clearvars d;
    
for d = 1:size(DEVICES,2)
    % Data (Spatial Plot)
    PLOTS.AED(d).Standard.Estimate = LCOE.SPATIAL.DEVICES(d).AED.Ideal_MWh;
    
    % Data (Markers)
    PLOTS.AED(d).Standard.HighestInRegion...
        = max(LCOE.SPATIAL.DEVICES(d).AED.Ideal_MWh(LCOE.SPATIAL.DEVICES(d).AED.Ideal_MWh > 0),[],'all');
    PLOTS.AED(d).Standard.LinearIndex...
        = find(LCOE.SPATIAL.DEVICES(d).AED.Ideal_MWh == PLOTS.AED(d).Standard.HighestInRegion);
   [PLOTS.AED(d).Standard.SubscriptIndexes(1),...
    PLOTS.AED(d).Standard.SubscriptIndexes(2)]...
        = ind2sub(size(LCOE.SPATIAL.DEVICES(d).AED.Ideal_MWh),...
                  PLOTS.AED(d).Standard.LinearIndex);
    PLOTS.AED(d).Standard.UTM_EN_m...
        = [METOCEAN.SPATIAL.UTM_E_m(PLOTS.AED(d).Standard.SubscriptIndexes(1),PLOTS.AED(d).Standard.SubscriptIndexes(2)),...
           METOCEAN.SPATIAL.UTM_N_m(PLOTS.AED(d).Standard.SubscriptIndexes(1),PLOTS.AED(d).Standard.SubscriptIndexes(2))];      

    % Figure
    figure;
    P = pcolor(METOCEAN.SPATIAL.UTM_E_m,...
               METOCEAN.SPATIAL.UTM_N_m,...
               LCOE.SPATIAL.DEVICES(d).AED.Ideal_MWh);
               shading interp; hold on; P.HandleVisibility = 'off';

    % Ticks & Colormaps          
    less_plots_utmticks(METOCEAN,PLOTS);
    c = colorbar; colormap(PLOTS.CustomColormaps.JetGreyZero);
    c.FontSize = PLOTS.FontSize_Axes;
    caxis([0, round2(max(PLOTS.MaxIdealAED),1000)]);
      
    % Markers
    less_plots_portlabels(PATHFIND,PLOTS,'None','On');  
    less_plots_aedlabels(PLOTS,'Full','Standard',d);    
    
    % Labels
    xlabel('UTM Easting [km]','FontSize',PLOTS.FontSize_Axes);
    ylabel('UTM Northing [km]','FontSize',PLOTS.FontSize_Axes);
    c.Label.String = 'Ideal AED [MWh]'; c.Label.FontSize = PLOTS.FontSize_Axes;
    title(['Ideal Annual Energy Delivered for ',DEVICES(d).Name,' Device'],'FontSize',PLOTS.FontSize_Title,'Interpreter','none');
      
    % Sizing
    axis equal; fig2fullscreen; pause(1);
    for C = 1:size(c.Ticks,2)
        c.TickLabels{C} = num2bank(c.Ticks(C));
    end; clearvars c C P;
end; clearvars d;
	
%% Actual Annual Energy Delivered (Mean)
for d = 1:size(DEVICES,2)
    % Data (Spatial Plot)
    PLOTS.AED(d).LESSMean.Estimate = LCOE.SPATIAL.DEVICES(d).AED.Actual_Mean_MWh;
    
    % Data (Markers)
    PLOTS.AED(d).LESSMean.HighestInRegion...
        = max(LCOE.SPATIAL.DEVICES(d).AED.Actual_Mean_MWh(LCOE.SPATIAL.DEVICES(d).AED.Actual_Mean_MWh > 0),[],'all');
    PLOTS.AED(d).LESSMean.LinearIndex...
        = find(LCOE.SPATIAL.DEVICES(d).AED.Actual_Mean_MWh == PLOTS.AED(d).LESSMean.HighestInRegion);
   [PLOTS.AED(d).LESSMean.SubscriptIndexes(1),...
    PLOTS.AED(d).LESSMean.SubscriptIndexes(2)]...
        = ind2sub(size(LCOE.SPATIAL.DEVICES(d).AED.Actual_Mean_MWh),...
                  PLOTS.AED(d).LESSMean.LinearIndex);
    PLOTS.AED(d).LESSMean.UTM_EN_m...
        = [METOCEAN.SPATIAL.UTM_E_m(PLOTS.AED(d).LESSMean.SubscriptIndexes(1),PLOTS.AED(d).LESSMean.SubscriptIndexes(2)),...
           METOCEAN.SPATIAL.UTM_N_m(PLOTS.AED(d).LESSMean.SubscriptIndexes(1),PLOTS.AED(d).LESSMean.SubscriptIndexes(2))];      
    
    % Figure
    figure;
    P = pcolor(METOCEAN.SPATIAL.UTM_E_m,...
               METOCEAN.SPATIAL.UTM_N_m,...
               LCOE.SPATIAL.DEVICES(d).AED.Actual_Mean_MWh);
               shading interp; hold on; P.HandleVisibility = 'off';

    % Ticks & Colormaps          
    less_plots_utmticks(METOCEAN,PLOTS);
    c = colorbar; colormap(PLOTS.CustomColormaps.JetGreyZero);
    c.FontSize = PLOTS.FontSize_Axes;
    caxis([0, round2(max(PLOTS.MaxIdealAED),1000)]);

    % Labels
    xlabel('UTM Easting [km]','FontSize',PLOTS.FontSize_Axes);
    ylabel('UTM Northing [km]','FontSize',PLOTS.FontSize_Axes);
    c.Label.String = 'Actual AED [MWh]'; c.Label.FontSize = PLOTS.FontSize_Axes;
    title(['Actual Annual Energy Delivered for ',DEVICES(d).Name,' Device'],'FontSize',PLOTS.FontSize_Title,'Interpreter','none');
    
    % Markers
    less_plots_portlabels(PATHFIND,PLOTS,'None','On');  
    less_plots_aedlabels(PLOTS,'Full','LESSMean',d);
    
    % Sizing
    axis equal; fig2fullscreen; fig2fullscreen; pause(1);
    for C = 1:size(c.Ticks,2)
        c.TickLabels{C} = num2bank(c.Ticks(C));
    end; clearvars c C P;
end; clearvars d;

%% LCoE (Standard)
for d = 1:size(DEVICES,2)
    % Data (Spatial Plot)
    PLOTS.LCoE(d).Standard.Estimate = LCOE.SPATIAL.DEVICES(d).LCOE.LCoE_Standard_CCCpMWh;
    PLOTS.LCoE(d).Standard.Estimate(PLOTS.LCoE(d).Standard.Estimate > PLOTS.LCoECut) = PLOTS.LCoECut;
    PLOTS.LCoE(d).Standard.Estimate(PLOTS.LCoE(d).Standard.Estimate == 0) = -Inf;
    
    % Data (Markers)
    PLOTS.LCoE(d).Standard.LowestInRegion...
        = min(LCOE.SPATIAL.DEVICES(d).LCOE.LCoE_Standard_CCCpMWh(LCOE.SPATIAL.DEVICES(d).LCOE.LCoE_Standard_CCCpMWh > 0),[],'all');
    PLOTS.LCoE(d).Standard.LinearIndex...
        = find(LCOE.SPATIAL.DEVICES(d).LCOE.LCoE_Standard_CCCpMWh == PLOTS.LCoE(d).Standard.LowestInRegion);
   [PLOTS.LCoE(d).Standard.SubscriptIndexes(1),...
    PLOTS.LCoE(d).Standard.SubscriptIndexes(2)]...
        = ind2sub(size(LCOE.SPATIAL.DEVICES(d).LCOE.LCoE_Standard_CCCpMWh),...
                  PLOTS.LCoE(d).Standard.LinearIndex);
    PLOTS.LCoE(d).Standard.UTM_EN_m...
        = [METOCEAN.SPATIAL.UTM_E_m(PLOTS.LCoE(d).Standard.SubscriptIndexes(1),PLOTS.LCoE(d).Standard.SubscriptIndexes(2)),...
           METOCEAN.SPATIAL.UTM_N_m(PLOTS.LCoE(d).Standard.SubscriptIndexes(1),PLOTS.LCoE(d).Standard.SubscriptIndexes(2))];      
    
    % Figure
    figure;
    P = pcolor(METOCEAN.SPATIAL.UTM_E_m,...
               METOCEAN.SPATIAL.UTM_N_m,...
               PLOTS.LCoE(d).Standard.Estimate);
               shading interp; hold on; P.HandleVisibility = 'off';
               
    % Ticks & Colormaps
    less_plots_utmticks(METOCEAN,PLOTS);
    c = colorbar; colormap(PLOTS.CustomColormaps.JetGreyZero_CharcoalMax);
    caxis([0, PLOTS.LCoECut]); c.FontSize = PLOTS.FontSize_Axes;

    % Labels
    xlabel('UTM Easting [km]','FontSize',PLOTS.FontSize_Axes);
    ylabel('UTM Northing [km]','FontSize',PLOTS.FontSize_Axes);
    c.Label.String = ['LCoE [',PLOTS.Currency,'/MWh]']; c.Label.FontSize = PLOTS.FontSize_Axes;
    title(['Standard Estimate of LCoE for ',DEVICES(d).Name,' Device'],'FontSize',PLOTS.FontSize_Title,'Interpreter','none');
    
    % Markers
    less_plots_portlabels(PATHFIND,PLOTS,'None','On')
    less_plots_lcoelabels(PLOTS,'Full','Standard',d)
    
    % Sizing
    axis equal; fig2fullscreen; clearvars c P;
end; clearvars d;

%% LCoE (Mean)
for d = 1:size(DEVICES,2)
    % Data (Spatial Plot)
    PLOTS.LCoE(d).LESSMean.Estimate = LCOE.SPATIAL.DEVICES(d).LCOE.ArrayLCoE_Mean_CCCpMWh;
    PLOTS.LCoE(d).LESSMean.Estimate(PLOTS.LCoE(d).LESSMean.Estimate > PLOTS.LCoECut) = PLOTS.LCoECut;
    PLOTS.LCoE(d).LESSMean.Estimate(PLOTS.LCoE(d).LESSMean.Estimate == 0) = -Inf;
    
    % Data (Markers)
    PLOTS.LCoE(d).LESSMean.LowestInRegion...
        = min(LCOE.SPATIAL.DEVICES(d).LCOE.ArrayLCoE_Mean_CCCpMWh(LCOE.SPATIAL.DEVICES(d).LCOE.ArrayLCoE_Mean_CCCpMWh > 0),[],'all');
    PLOTS.LCoE(d).LESSMean.LinearIndex...
        = find(LCOE.SPATIAL.DEVICES(d).LCOE.ArrayLCoE_Mean_CCCpMWh == PLOTS.LCoE(d).LESSMean.LowestInRegion);
   [PLOTS.LCoE(d).LESSMean.SubscriptIndexes(1),...
    PLOTS.LCoE(d).LESSMean.SubscriptIndexes(2)]...
        = ind2sub(size(LCOE.SPATIAL.DEVICES(d).LCOE.ArrayLCoE_Mean_CCCpMWh),...
                  PLOTS.LCoE(d).LESSMean.LinearIndex);
    PLOTS.LCoE(d).LESSMean.UTM_EN_m...
        = [METOCEAN.SPATIAL.UTM_E_m(PLOTS.LCoE(d).LESSMean.SubscriptIndexes(1),PLOTS.LCoE(d).LESSMean.SubscriptIndexes(2)),...
           METOCEAN.SPATIAL.UTM_N_m(PLOTS.LCoE(d).LESSMean.SubscriptIndexes(1),PLOTS.LCoE(d).LESSMean.SubscriptIndexes(2))];      
 
    % Figure
    figure;
    P = pcolor(METOCEAN.SPATIAL.UTM_E_m,...
               METOCEAN.SPATIAL.UTM_N_m,...
               PLOTS.LCoE(d).LESSMean.Estimate);
               shading interp; hold on; P.HandleVisibility = 'off'; hold on;
               
    % Ticks & Colormaps
    less_plots_utmticks(METOCEAN,PLOTS);
    c = colorbar; colormap(PLOTS.CustomColormaps.JetGreyZero_CharcoalMax);
    caxis([0, PLOTS.LCoECut]); c.FontSize = PLOTS.FontSize_Axes;
    
    % Labels
    xlabel('UTM Easting [km]','FontSize',PLOTS.FontSize_Axes);
    ylabel('UTM Northing [km]','FontSize',PLOTS.FontSize_Axes);
    c.Label.String = ['LCoE [',PLOTS.Currency,'/MWh]'];
    c.Label.FontSize = PLOTS.FontSize_Axes;
    title(['LESS Tool Mean Estimate of LCoE for ',DEVICES(d).Name,' Device'],'FontSize',PLOTS.FontSize_Title,'Interpreter','none');
    
    % Markers
    less_plots_portlabels(PATHFIND,PLOTS,'None','On')    
    less_plots_lcoelabels(PLOTS,'Full','LESSMean',d)
    
    % Sizing
    axis equal; fig2fullscreen; clearvars c P;
end; clearvars d;

%% Finalise
pause(10); disp(' % All plots produced successfully.');
   
end
