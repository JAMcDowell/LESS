function [LCoE,...
          Capacity_MW] = experiencecurve(Capacity_Init_MW,...
                                         LCoE_Init_GBPMWh,...
                                         LearningRate_pc,...
                                         Duration_y)
%% Function Description
%

%% Input Checks
%   

%% Anonymous Function
b = @(LR) log(1 - LR)./log(2);

%% Preallocate
Capacity_MW = zeros(1,Duration_y);
LCoE        = zeros(1,Duration_y);

%% Initialise
Capacity_MW(1) = Capacity_Init_MW;
LCoE(1)        = LCoE_Init_GBPMWh;

%% Duration
for y = 2:size(Capacity_MW,2)
    Capacity_MW(y) = Capacity_MW(y-1)*2;
    LCoE(y) = LCoE(y-1)*((Capacity_MW(y-1)/Capacity_MW(y)))^-b(LearningRate_pc/100);
end

%% Output Checks
%

end
