%% PLOT Flows Pcolor
figure; pcolor(DATA.X_UTM_m', DATA.Y_UTM_m', squeeze(DATA.DepAvFlowVel_ms(128,:,:))');
title('Delft3D-FM Output - Depth-Averaged Absolute Velocity')
xlabel('UTM X Position (m)');
ylabel('UTM Y Position (m)');
c = colorbar; c.Label.String = ('Depth-Av. Abs. Velocity (m/s)'); c.FontSize = 20; caxis([0,5]);
set(gca,'FontSize',20); shading interp; 

%% PLOT WaterLevel Pcolor
figure; pcolor(DATA.X_UTM_m', DATA.Y_UTM_m', squeeze(DATA.WaterLevel_m(4,:,:))');
title('Delft3D-FM Output - WaterLevel_m')
xlabel('UTM X Position (m)');
ylabel('UTM Y Position (m)');
c = colorbar; c.Label.String = ('WaterLevel (m)'); c.FontSize = 20;% caxis([0,5]);
set(gca,'FontSize',20); shading interp; 

%% PLOT WaterDepth_m Pcolor
figure; pcolor(DATA.X_UTM_m', DATA.Y_UTM_m', squeeze(DATA.WaterDepth_m(70,:,:))');
title('Delft3D-FM Output - WaterDepth')
xlabel('UTM X Position (m)');
ylabel('UTM Y Position (m)');
c = colorbar; c.Label.String = ('WaterDepth (m)'); c.FontSize = 20;% caxis([0,5]);
set(gca,'FontSize',20); shading interp; 

%% PLOT WaterDepth_m-Mean Pcolor
figure; pcolor(DATA.X_UTM_m', DATA.Y_UTM_m', squeeze(DATA.WaterDepth_m(79,:,:))'- DATA.MeanWaterDepth_m');
title('Delft3D-FM Output - WaterDepth-MeanWaterDepth')
xlabel('UTM X Position (m)');
ylabel('UTM Y Position (m)');
c = colorbar; c.Label.String = ('WaterDepth-MeanWaterDepth (m)'); c.FontSize = 20;% caxis([0,5]);
set(gca,'FontSize',20); shading interp; 


%% PLOT Waves pcolor
figure; pcolor(DATA.X_UTM_m', DATA.Y_UTM_m', squeeze(DATA.WaveHs_m(723,:,:))');
title('Delft3D-FM Output - Significant Wave Height')
xlabel('UTM X Position (m)');
ylabel('UTM Y Position (m)');
c = colorbar; c.Label.String = ('H_S (m)'); c.FontSize = 20; caxis([0,3.5]);
set(gca,'FontSize',20); shading interp; clear c;

%% PLOT Wind Time Series
figure; title('Delft3D-FM Input - Wind Velocity & Direction')
yyaxis left
plot(NumDateTime, WindVel_ms)
ylabel('Wind Velocity (m/s)');
ylim([0,14])

yyaxis right
plot(NumDateTime,WindDirFrm_deg)
xlabel('Date Time');
ylabel('Wind Direction (°¬>)');
ylim([0,360])
set(gca,'FontSize',26);
datetick('x','mmm-dd'); grid on;

%% PLOT Wind pcolor
figure; pcolor(DATA.X_UTM_m', DATA.Y_UTM_m', squeeze(WindVel2(55,:,:))');
title('Delft3D-FM Output - WindVel2')
xlabel('UTM X Position (m)');
ylabel('UTM Y Position (m)');
c = colorbar; c.Label.String = ('WindVel2 (m/s)'); c.FontSize = 20;% caxis([0,3.5]);
set(gca,'FontSize',20); shading interp; clear c;

%% PLOT Bathymetry/Depth
DepthPlot = DATA.MeanWaterDepth_m;
DepthPlot(DepthPlot == 0) = NaN;

figure; pcolor(DepthPlot'); shading interp; hold on; 
colormap gray; c = colorbar; c.Label.String = ('Depth (m)'); c.FontSize = 26; caxis([0,250]);

for p = 1:size(PORTS.GridPos,1)
    plot(PORTS.GridPos(p,1),PORTS.GridPos(p,2),'s','MarkerFaceColor','r'); hold on;
    Label = char(PORTS.PortNames(p));  
    text(PORTS.GridPos(p,1),PORTS.GridPos(p,2),...
         strcat("  ",string(p)," ",string(Label(:,1:end-3))," [",string(PORTS.GridPos(p,1)),",",string(PORTS.GridPos(p,2)),"]"),...
         'color','red','HorizontalAlignment','left','FontSize',12); clear Label;
end
title('Grid Bathymetry & Port Locations');
xlabel('Grid X Position (m)');
ylabel('Grid Y Position (m)');
set(gca,'FontSize',26);
clearvars DepthPlot;

%% PLOT AStar Algorithm Paths to Port
figure; pcolor(DATA.MeanWaterDepth_m'); shading interp;  hold on;
plot(PATH.GridPos_mn(x,y).OptimalPath(1,2),   PATH.GridPos_mn(x,y).OptimalPath(1,1),'o','color','m')
plot(PATH.GridPos_mn(x,y).OptimalPath(end,2), PATH.GridPos_mn(x,y).OptimalPath(end,1),'o','color','g')
plot(PATH.GridPos_mn(x,y).OptimalPath(:,2),   PATH.GridPos_mn(x,y).OptimalPath(:,1),'r')
title('A* Path to Port');
xlabel('Grid X Position');
ylabel('Grid Y Position');
colormap(((gray))); c = colorbar; c.Label.String = ('Depth (m)'); c.FontSize = 26; caxis([0,250]);
legend({'Bathymetry','Port Location','Deployment Location','A* Path'},'Location','northwest')
set(gca,'FontSize',26);

%% ACCESS - Transit
figure; pcolor(DATA.X_UTM_m', DATA.Y_UTM_m',PROB.Weibull.Wave_m.N_Acc_h.Transit'); shading interp;  hold on;
c = colorbar; c.Label.String = ('Access Time (h)'); c.FontSize = 20; caxis([0,744]);
title('Access Hours for Transit Phase of Operation');
xlabel('UTM X Position (m)');
ylabel('UTM Y Position (m)');
set(gca,'FontSize',20); clear c;

% ACCESS - OnSite
figure; pcolor(DATA.X_UTM_m', DATA.Y_UTM_m',PROB.Weibull.Wave_m.N_Acc_h.OnSite'); shading interp;  hold on;
c = colorbar; c.Label.String = ('Access Time (h)'); c.FontSize = 20; caxis([0,744]);
title('Access Hours for On-Site Phase of Operation');
xlabel('UTM X Position (m)');
ylabel('UTM Y Position (m)');
set(gca,'FontSize',20); clear c;

% ACCESS - Full Op
% figure; pcolor(DATA.X_UTM_m', DATA.Y_UTM_m',PROB.Weibull.Wave_m.N_Acc_h.FullOp'); shading interp;  hold on;
% c = colorbar; c.Label.String = ('Access Time (h)'); c.FontSize = 26; caxis([0,744]);
% title('Access Hours for Full Operation');
% xlabel('UTM X Position (m)');
% ylabel('UTM Y Position (m)');
% set(gca,'FontSize',26); clear c;

% WAITING - Transit
figure; pcolor(DATA.X_UTM_m', DATA.Y_UTM_m',PROB.Weibull.Wave_m.N_Wait_h.Transit'); shading interp;  hold on;
c = colorbar; c.Label.String = ('Waiting Time (h)'); c.FontSize = 20; caxis([0,100]);
title('Waiting Hours for Transit Phase of Operation');
xlabel('UTM X Position (m)');
ylabel('UTM Y Position (m)');
set(gca,'FontSize',20); clear c;

% WAITING - On Site
figure; pcolor(DATA.X_UTM_m', DATA.Y_UTM_m',PROB.Weibull.Wave_m.N_Wait_h.OnSite'); shading interp;  hold on;
c = colorbar; c.Label.String = ('Waiting Time (h)'); c.FontSize = 20; caxis([0,100]);
title('Waiting Hours for On-Site Phase of Operation');
xlabel('UTM X Position (m)');
ylabel('UTM Y Position (m)');
set(gca,'FontSize',20); clear c;

% WAITING - Full Operation
% figure; pcolor(DATA.X_UTM_m', DATA.Y_UTM_m',PROB.Weibull.Wave_m.N_Wait_h.FullOp'); shading interp;  hold on;
% c = colorbar; c.Label.String = ('Waiting Time (h)'); c.FontSize = 26; %caxis([0,24]);
% title('Waiting Hours for Full Operation');
% xlabel('UTM X Position (m)');
% ylabel('UTM Y Position (m)');
% set(gca,'FontSize',26); clear c;


%% Time to Port
figure; pcolor(DATA.X_UTM_m', DATA.Y_UTM_m',PATH.TransitDur_h'); shading interp;
c = colorbar; colormap jet; c.Label.String = ('Transit Time (h)'); c.FontSize = 20; caxis([0,12]);
title('Transit Time from Port to Site');
xlabel('UTM X Position (m)');
ylabel('UTM Y Position (m)');
set(gca,'FontSize',20); clear c;

%% Slack Length
figure; pcolor(DATA.X_UTM_m', DATA.Y_UTM_m',VEL.ViableSlack.Transit'); shading interp;
c = colorbar; colormap(flipud(jet)); c.Label.String = ('Viable Slack Duration (h)'); c.FontSize = 20; %caxis([0,24]);
title('Viable Slack Duration for Transit from Port to Site');
xlabel('UTM X Position (m)');
ylabel('UTM Y Position (m)');
set(gca,'FontSize',20); clear c;

figure; pcolor(DATA.X_UTM_m', DATA.Y_UTM_m',VEL.ViableSlack.OnSite'); shading interp;
c = colorbar; colormap(flipud(jet)); c.Label.String = ('Viable Slack Duration (h)'); c.FontSize = 20; %caxis([0,24]);
title('Viable Slack Duration for Time On Site');
xlabel('UTM X Position (m)');
ylabel('UTM Y Position (m)');
set(gca,'FontSize',20); clear c;

%% Idealised Energy Delivered
figure; pcolor(DATA.X_UTM_m', DATA.Y_UTM_m',POW.IdealEnergyDel_kWh'./1000.*12); shading interp;
c = colorbar; colormap((summer)); c.Label.String = ('Ideal. Energy Del. (MWh)'); c.FontSize = 20; caxis([0,1000]);
title('Idealized Energy Delivered');
xlabel('UTM X Position (m)');
ylabel('UTM Y Position (m)');
set(gca,'FontSize',20); clear c;

%% Annual Energy Delivered
figure; pcolor(DATA.X_UTM_m', DATA.Y_UTM_m',LCOE.AnnualEnergyDel_MWh'); shading interp;
c = colorbar; colormap((summer)); c.Label.String = ('Annual Energy Del. (MWh)'); c.FontSize = 20; %caxis([0,1000]);
title('Annual Energy Delivered');
xlabel('UTM X Position (m)');
ylabel('UTM Y Position (m)');
set(gca,'FontSize',20); clear c;

%% Annual OPEX
figure; pcolor(DATA.X_UTM_m', DATA.Y_UTM_m',LCOE.AnnualOPEX_USD'); shading interp;
c = colorbar; colormap((jet)); c.Label.String = ('Operational Costs (USD)'); c.FontSize = 20; %caxis([0,1000]);
title('Annual Operational Costs');
xlabel('UTM X Position (m)');
ylabel('UTM Y Position (m)');
set(gca,'FontSize',20); clear c;

%% Annual Revenue
figure; pcolor(DATA.X_UTM_m', DATA.Y_UTM_m',LCOE.AnnualRevenue_USD'); shading interp;
c = colorbar; colormap(flipud(jet)); c.Label.String = ('Annual Revenue (USD)'); c.FontSize = 20; %caxis([0,1000]);
title('Annual Revenue');
xlabel('UTM X Position (m)');
ylabel('UTM Y Position (m)');
set(gca,'FontSize',20); clear c;

%% LCOE
figure; pcolor(DATA.X_UTM_m', DATA.Y_UTM_m',LCOE.LCOE_USD_MWh'); shading interp; %LCOE.LCOE_USD_MWh
c = colorbar; colormap((jet)); c.Label.String = ('LCOE (USD/MWh)'); c.FontSize = 20; caxis([100,1000]);
title('LCOE (Accounting for MetOcean Induced Costs)');
xlabel('UTM X Position (m)');
ylabel('UTM Y Position (m)');
set(gca,'FontSize',20); clear c;

%% LCOE not accounting for Met Ocean conditions
figure; pcolor(DATA.X_UTM_m', DATA.Y_UTM_m',LCOE_NoOpEx.LCOE_USD_MWh'); shading interp; %LCOE.LCOE_USD_MWh
c = colorbar; colormap((jet)); c.Label.String = ('LCOE (USD/MWh)'); c.FontSize = 20; caxis([100,1000]);
title('LCOE (Not Accounting for MetOcean Induced Costs)');
xlabel('UTM X Position (m)');
ylabel('UTM Y Position (m)');
set(gca,'FontSize',20); clear c;

%%
save('POW_EN.mat','POW','-v7.3');
%
% save('VELSLACK.mat','VEL','-v7.3'); save('POW.mat','POW','-v7.3');
% PAT.GridPos_mn(1:526,:) = PATH1_526.GridPos_mn(1:526,:);
% PAT.GridPos_mn(527:564,:) = PATH527_564.GridPos_mn(527:564,:);
% PAT.GridPos_mn(565:665,:) = PATH565_665.GridPos_mn(565:665,:);
% PAT.GridPos_mn(666:866,:) = PATH666_866.GridPos_mn(666:866,:);
% PAT.GridPos_mn(867:1000,:) = PATH867_1000.GridPos_mn(867:1000,:);
% PAT.GridPos_mn(1001:1200,:) = PATH1001_1200.GridPos_mn(1001:1200,:);
% PAT.GridPos_mn(1201:1301,:) = PATH1201_1301.GridPos_mn(1201:1301,:);
%


% figure; pcolor(DATA.X_UTM_m', DATA.Y_UTM_m',PATH.TransitDur_h'); shading interp;
% c = colorbar; c.Label.String = ('Transit Time (h)'); c.FontSize = 26; %caxis([0,24]);
% title('Transit Time from Port to Site');
% xlabel('UTM X Position (m)');
% ylabel('UTM Y Position (m)');
% set(gca,'FontSize',26); clear c;