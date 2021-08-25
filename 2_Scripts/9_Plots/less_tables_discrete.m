%% Annual Operational Expenditure Breakdown
for d = [2,4,6]
    Fields = fieldnames(LCOE.DISCRETE.SITES(1).DEVICES(d).OPEX);
    Use    = Fields(3:end);
    AnnualOpEx(d).Data = zeros(size(Use,1),1);
    
    for f = 1:size(Use,1)
        AnnualOpEx(d).Data(f) = LCOE.DISCRETE.SITES(1).DEVICES(d).OPEX.(Use{f});
    end
    
    AnnualOpEx(d).Table = array2table(AnnualOpEx(d).Data','VariableNames',Use);
end

TABLES.AnnualOpExBreakdown = vertcat(AnnualOpEx.Table);
TABLES.AnnualOpExBreakdown.Properties.RowNames = {'PLATO','PLATI','HBMT'};
clearvars Fields Use AnnualOpEx d f;

%% Ideal Energy Generated, Delivered & Transmission Losses
VarNames = {'Ideal_Generated_MWh','Ideal_Loss_MWh','Ideal_Delivered_MWh','Ideal_Loss_pc'};
TABLES.IdealTransmissionLosses...
    = array2table([[YIELD.DISCRETE.IDEAL.DELIVERED.SITES.DEVICES.Energy_Ideal_GenPerDevice_kWh]'.*SCENARIO.Project.Project_ArraySize.Project_ArraySize(1)./1000,...
                   [YIELD.DISCRETE.IDEAL.DELIVERED.SITES.DEVICES.Energy_Ideal_LossPerDevice_kWh]'.*SCENARIO.Project.Project_ArraySize.Project_ArraySize(1)./1000,...
                   [YIELD.DISCRETE.IDEAL.DELIVERED.SITES.DEVICES.Energy_Ideal_DelPerDevice_kWh]'.*SCENARIO.Project.Project_ArraySize.Project_ArraySize(1)./1000,...
                   [YIELD.DISCRETE.IDEAL.DELIVERED.SITES.DEVICES.Energy_Ideal_LossPerDevice_pc]'],...
'VariableNames',VarNames);

TABLES.IdealTransmissionLosses.Properties.RowNames = {DEVICES(1:6).Name};
clearvars VarNames;

%% Ideal vs Actual AED
for d = 1:6
    Fields = fieldnames(LCOE.DISCRETE.SITES.DEVICES(d).AED);    
    Use    = Fields([3,4,5,1]);
    AED(d).Data = zeros(size(Use,1),1);
    
    for f = 1:size(Use,1)
        AED(d).Data(f) = LCOE.DISCRETE.SITES.DEVICES(d).AED.(Use{f});
    end
    
    AED(d).Table = array2table(AED(d).Data','VariableNames',Use);
end

TABLES.IdealVsActualAED = vertcat(AED.Table); 
TABLES.IdealVsActualAED.Properties.RowNames = {DEVICES(1:6).Name};
clearvars Fields Use AED d f;

%% LCoE
for d = 1:6
    Fields = fieldnames(LCOE.DISCRETE.SITES.DEVICES(d).LCOE);
    Use    = Fields([2,3,4,1]);
    lcoe(d).Data = zeros(size(Use,1),1);
    
    for f = 1:size(Use,1)
        lcoe(d).Data(f) = LCOE.DISCRETE.SITES.DEVICES(d).LCOE.(Use{f});
    end
    
    lcoe(d).Table = array2table(lcoe(d).Data','VariableNames',Use);
end

TABLES.LCoE = vertcat(lcoe.Table); 
TABLES.LCoE.Properties.RowNames = {DEVICES(1:6).Name};
clearvars Fields Use lcoe d f;

%% Comparison of Discrete Site Estimate and Regional Estimate at Site Location
VarNames = {'TotalCapEx_CCC','Total_AnnualOpEx_Mean_CCCpy','TotalDecEx_CCC','AED_Ideal_MWh','AED_Actual_Mean_MWh','ArrayLCoE_Mean_CCCpMWh'};
RowNames = {'SiteEstimate','RegionEstimate','Delta','Delta_Percentage'};

for d = 1:6
    % Site with Detailed Data
    SiteVsRegion(d).DeviceName = DEVICES(d).Name;
    SiteVsRegion(d).Data(1,:)...
        = [LCOE.DISCRETE.SITES.DEVICES(d).CAPEX.TotalCapEx_CCC
           LCOE.DISCRETE.SITES.DEVICES(d).OPEX.Total_AnnualOpEx_Mean_CCCpy
           LCOE.DISCRETE.SITES.DEVICES(d).DECEX.TotalDecEx_CCC
           LCOE.DISCRETE.SITES.DEVICES(d).AED.Ideal_MWh
           LCOE.DISCRETE.SITES.DEVICES(d).AED.Actual_Mean_MWh
           LCOE.DISCRETE.SITES.DEVICES(d).LCOE.ArrayLCoE_Mean_CCCpMWh]';
    
    % Site as Modelled by Region
    SiteVsRegion(d).Data(2,:)...
        = [LCOE.SPATIAL.DEVICES(d).CAPEX.TotalCapEx_CCC(PATHFIND.SPATIAL.SITES.ValidGridPosition_SubscriptIndex_mn(1),PATHFIND.SPATIAL.SITES.ValidGridPosition_SubscriptIndex_mn(2))
           LCOE.SPATIAL.DEVICES(d).OPEX.Total_AnnualOpEx_Mean_CCCpy(PATHFIND.SPATIAL.SITES.ValidGridPosition_SubscriptIndex_mn(1),PATHFIND.SPATIAL.SITES.ValidGridPosition_SubscriptIndex_mn(2))
           LCOE.SPATIAL.DEVICES(d).DECEX.TotalDecEx_CCC(PATHFIND.SPATIAL.SITES.ValidGridPosition_SubscriptIndex_mn(1),PATHFIND.SPATIAL.SITES.ValidGridPosition_SubscriptIndex_mn(2))
           LCOE.SPATIAL.DEVICES(d).AED.Ideal_MWh(PATHFIND.SPATIAL.SITES.ValidGridPosition_SubscriptIndex_mn(1),PATHFIND.SPATIAL.SITES.ValidGridPosition_SubscriptIndex_mn(2))
           LCOE.SPATIAL.DEVICES(d).AED.Actual_Mean_MWh(PATHFIND.SPATIAL.SITES.ValidGridPosition_SubscriptIndex_mn(1),PATHFIND.SPATIAL.SITES.ValidGridPosition_SubscriptIndex_mn(2))
           LCOE.SPATIAL.DEVICES(d).LCOE.ArrayLCoE_Mean_CCCpMWh(PATHFIND.SPATIAL.SITES.ValidGridPosition_SubscriptIndex_mn(1),PATHFIND.SPATIAL.SITES.ValidGridPosition_SubscriptIndex_mn(2))]';

    % Percentage Difference
    SiteVsRegion(d).Data(3,:)...
        = (SiteVsRegion(d).Data(2,:) - SiteVsRegion(d).Data(1,:));
    
    SiteVsRegion(d).Data(4,:)...
        = (SiteVsRegion(d).Data(3,:)./ SiteVsRegion(d).Data(1,:)) .* 100;   

    % Assign to Table
    TABLES.SiteVsRegionCostBreakdown(d).DeviceName = DEVICES(d).Name;
    TABLES.SiteVsRegionCostBreakdown(d).Table = array2table(SiteVsRegion(d).Data,...
                            'VariableNames',VarNames,'RowNames',RowNames);
end
clearvars SiteVsRegion VarNames RowNames d;