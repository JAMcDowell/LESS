%% Annual Operational Expenditure
for d = [2, 4, 6]
    Fields = fieldnames(LCOE.DISCRETE.SITES(1).DEVICES(d).OPEX);
    
    
    Use = Fields(3:end);
    AnnualOpEx(d).Data = zeros(size(Use,1),1);
    for f = 1:size(Use,1)
        AnnualOpEx(d).Data(f) = LCOE.DISCRETE.SITES(1).DEVICES(d).OPEX.(Use{f});
        
        
    end
    
    AnnualOpEx(d).Table = array2table(AnnualOpEx(d).Data',...
                          'VariableNames',Use);
                      
end

%% Ideal AED
for d = 1:6
    Fields = fieldnames(LCOE.DISCRETE.SITES.DEVICES(d).AED);
    
    
    Use = Fields([3,4,5,1]);
    ActualAED(d).Data = zeros(size(Use,1),1);
    for f = 1:size(Use,1)
        ActualAED(d).Data(f) = LCOE.DISCRETE.SITES.DEVICES(d).AED.(Use{f});
        
        
    end
    
    ActualAED(d).Table = array2table(ActualAED(d).Data',...
                          'VariableNames',Use);
    
end



%% Actual AED
for d = 1:6
    Fields = fieldnames(LCOE.DISCRETE.SITES.DEVICES(d).AED);
    
    
    Use = Fields([3,4,5,1]);
    ActualAED(d).Data = zeros(size(Use,1),1);
    for f = 1:size(Use,1)
        ActualAED(d).Data(f) = LCOE.DISCRETE.SITES.DEVICES(d).AED.(Use{f});
        
        
    end
    
    ActualAED(d).Table = array2table(ActualAED(d).Data',...
                          'VariableNames',Use);
    
end

%% LCoE
for d = 1:6
    Fields = fieldnames(LCOE.DISCRETE.SITES.DEVICES(d).LCOE);

    
    Use = Fields([2,3,4,1]);
    lcoe(d).Data = zeros(size(Use,1),1);
    for f = 1:size(Use,1)
        lcoe(d).Data(f) = LCOE.DISCRETE.SITES.DEVICES(d).LCOE.(Use{f});
        
        
    end
    
    lcoe(d).Table = array2table(lcoe(d).Data',...
                          'VariableNames',Use);
    
end

%% Comparison of Discrete and Spatial at Discrete Site
for d = 1:6
    
    % Site with Detailed Data
    Comparison(d).Data(1,:)...
        = [LCOE.DISCRETE.SITES.DEVICES(d).CAPEX.TotalCapEx_CCC
    LCOE.DISCRETE.SITES.DEVICES(d).OPEX.Total_AnnualOpEx_Mean_CCCpy
    LCOE.DISCRETE.SITES.DEVICES(d).DECEX.TotalDecEx_CCC
    LCOE.DISCRETE.SITES.DEVICES(d).AED.Ideal_MWh
    LCOE.DISCRETE.SITES.DEVICES(d).AED.Actual_Mean_MWh
    LCOE.DISCRETE.SITES.DEVICES(d).LCOE.ArrayLCoE_Mean_CCCpMWh]';
    
    % Site as Modelled by Region
    Comparison(d).Data(2,:)...
        = [LCOE.SPATIAL.DEVICES(d).CAPEX.TotalCapEx_CCC(PATHFIND.SPATIAL.SITES.ValidGridPosition_SubscriptIndex_mn(1),PATHFIND.SPATIAL.SITES.ValidGridPosition_SubscriptIndex_mn(2))
    LCOE.SPATIAL.DEVICES(d).OPEX.Total_AnnualOpEx_Mean_CCCpy(PATHFIND.SPATIAL.SITES.ValidGridPosition_SubscriptIndex_mn(1),PATHFIND.SPATIAL.SITES.ValidGridPosition_SubscriptIndex_mn(2))
    LCOE.SPATIAL.DEVICES(d).DECEX.TotalDecEx_CCC(PATHFIND.SPATIAL.SITES.ValidGridPosition_SubscriptIndex_mn(1),PATHFIND.SPATIAL.SITES.ValidGridPosition_SubscriptIndex_mn(2))
    LCOE.SPATIAL.DEVICES(d).AED.Ideal_MWh(PATHFIND.SPATIAL.SITES.ValidGridPosition_SubscriptIndex_mn(1),PATHFIND.SPATIAL.SITES.ValidGridPosition_SubscriptIndex_mn(2))
    LCOE.SPATIAL.DEVICES(d).AED.Actual_Mean_MWh(PATHFIND.SPATIAL.SITES.ValidGridPosition_SubscriptIndex_mn(1),PATHFIND.SPATIAL.SITES.ValidGridPosition_SubscriptIndex_mn(2))
    LCOE.SPATIAL.DEVICES(d).LCOE.ArrayLCoE_Mean_CCCpMWh(PATHFIND.SPATIAL.SITES.ValidGridPosition_SubscriptIndex_mn(1),PATHFIND.SPATIAL.SITES.ValidGridPosition_SubscriptIndex_mn(2))]';

    % Percentage Difference
    Comparison(d).Data(3,:)...
        = ((Comparison(d).Data(2,:) - Comparison(d).Data(1,:))...
        ./ Comparison(d).Data(1,:))...
        .* 100;

end
