function [ARRAY, Power_TotalDelivered_W, Power_TotalLoss_pc]...
            = arrayloss(Project_ArraySize,...
                        Devices_PowerGenerated_W,...
                        Transmission_GenerationVoltage_V,... 
                        Transmission_OnboardTransformerNoLoadLosses_W,...
                        Transmission_OnboardTransformerEfficiency_pc,...
                        Transmission_OnboardSwitchgearEfficiency_pc,...
                        Transmission_ExportCableVoltage_V,...
                        Transmission_ExportCableResistance_ohmpm,...
                        Sites_ExportDistance_m,...
                        Transmission_ShoreSwitchgearEfficiency_pc,...
                        Transmission_ShoreTransformerNoLoadLosses_W,...
                        Transmission_ShoreTransformerEfficiency_pc,...
                        Transmission_GridVoltage_V,...
                        Transmission_PowerFactor_pc,...
                        Transmission_Phase)  
%% Function Description - arrayloss - JAM 30/11/20
% This function calculates the transmission losses for an array of devices
% with a simple and set electrical architecture.

%% Inputs Description
% Project_ArraySize
% Devices_PowerGenerated_W
% Transmission_GenerationVoltage_V
% Transmission_OnboardTransformerNoLoadLosses_W
% Transmission_OnboardTransformerEfficiency_pc
% Transmission_OnboardSwitchgearEfficency_pc
% Transmission_ExportCableVoltage_V
% Transmission_ExportCableResistance_ohmpm
% Sites_ExportDistance_m
% Transmission_ShoreSwitchgearEfficiency_pc
% Transmission_ShoreTransformerNoLoadLosses_W
% Transmission_ShoreTransformerEfficiency_pc
% Transmission_GridVoltage_V
% Transmission_PowerFactor
% Transmission_Phase

%% Outputs Description
% ARRAY
% Power_TotalDelivered_W
% Power_TotalLoss_pc

%% Inputs Checks
validateattributes(Project_ArraySize,               {'numeric'},{'scalar','positive','integer'});
validateattributes(Devices_PowerGenerated_W,        {'numeric'},{'column','nonnegative'});
validateattributes(Transmission_GenerationVoltage_V,{'numeric'},{'scalar','positive'});
validateattributes(Transmission_GridVoltage_V,      {'numeric'},{'scalar','positive'});
validateattributes(Transmission_OnboardTransformerNoLoadLosses_W,{'numeric'},{'scalar','nonnegative','nonnan'});
validateattributes(Transmission_OnboardTransformerEfficiency_pc, {'numeric'},{'scalar','nonnegative','nonnan'});
validateattributes(Transmission_OnboardSwitchgearEfficiency_pc,  {'numeric'},{'scalar','nonnegative','nonnan'});
validateattributes(Transmission_ExportCableVoltage_V,            {'numeric'},{'scalar','nonnegative'});
validateattributes(Transmission_ExportCableResistance_ohmpm,     {'numeric'},{'scalar','nonnegative'});
validateattributes(Sites_ExportDistance_m,                       {'numeric'},{'scalar','nonnegative'});
validateattributes(Transmission_ShoreSwitchgearEfficiency_pc,    {'numeric'},{'scalar','nonnegative','nonnan'});
validateattributes(Transmission_ShoreTransformerNoLoadLosses_W,  {'numeric'},{'scalar','nonnegative','nonnan'});
validateattributes(Transmission_ShoreTransformerEfficiency_pc,   {'numeric'},{'scalar','nonnegative','nonnan'});
validateattributes(Transmission_PowerFactor_pc,{'numeric'},{'scalar','nonnan'});
validateattributes(Transmission_Phase,         {'numeric'},{'scalar','nonnan','nonnegative'});

%% Power Factor Absolute
Transmission_PowerFactorAbs = (1 - abs(1 - (Transmission_PowerFactor_pc/100)));

%% Onboard Losses
% Power In
ARRAY.Onboard.PowerIn_W = Devices_PowerGenerated_W;

% Voltages
ARRAY.Onboard.VoltageIn_V  = Transmission_GenerationVoltage_V;
ARRAY.Onboard.VoltageOut_V = Transmission_ExportCableVoltage_V;

% Power Out
ARRAY.Onboard.PowerOut_W...
    = (ARRAY.Onboard.PowerIn_W - Transmission_OnboardTransformerNoLoadLosses_W)...
    .* (Transmission_OnboardTransformerEfficiency_pc / 100)...
    .* (Transmission_OnboardSwitchgearEfficiency_pc  / 100);
ARRAY.Onboard.PowerOut_W(ARRAY.Onboard.PowerOut_W < 0) = 0;

% Power Loss
[ARRAY.Onboard.PowerLoss_W,...
 ARRAY.Onboard.PowerLoss_pc]...
    = powerlossperc(ARRAY.Onboard.PowerIn_W,...
                    ARRAY.Onboard.PowerOut_W);

%% Export Cable
% Power In
ARRAY.ExportCable.PowerIn_W = ARRAY.Onboard.PowerOut_W;

% Voltages
ARRAY.ExportCable.VoltageIn_V  = Transmission_ExportCableVoltage_V;
ARRAY.ExportCable.VoltageOut_V = Transmission_ExportCableVoltage_V;

% Resistance
ARRAY.ExportCable.Resistance_ohmpm...
    = Transmission_ExportCableResistance_ohmpm;

% Current
ARRAY.ExportCable.LineCurrent_A...
    = linecurrent(ARRAY.ExportCable.PowerIn_W,...
                  Transmission_ExportCableVoltage_V,...
                  100,...
                  Transmission_Phase);
              
% Power Out, Loss & Loss Percentage           
[ARRAY.ExportCable.PowerOut_W,...
 ARRAY.ExportCable.PowerLoss_W,...
 ARRAY.ExportCable.PowerLoss_pc]...
    = lineloss(ARRAY.ExportCable.PowerIn_W,...
               Transmission_ExportCableVoltage_V,...
               Transmission_ExportCableResistance_ohmpm,...
               Sites_ExportDistance_m,...
               100,...
               Transmission_Phase);
                                                  
%% Shore Substation
% Power In
ARRAY.Shore.PowerIn_W = ARRAY.ExportCable.PowerOut_W .* Project_ArraySize;

% Voltages
ARRAY.Shore.VoltageIn_V  = Transmission_ExportCableVoltage_V;
ARRAY.Shore.VoltageOut_V = Transmission_GridVoltage_V;

% Power Out
ARRAY.Shore.PowerOut_W...
    = ((ARRAY.Shore.PowerIn_W .* (Transmission_ShoreSwitchgearEfficiency_pc / 100))...
        - Transmission_ShoreTransformerNoLoadLosses_W)...
    .* (Transmission_ShoreTransformerEfficiency_pc / 100);

ARRAY.Shore.PowerOut_W(ARRAY.Shore.PowerOut_W < 0) = 0;

% Power Loss
[ARRAY.Shore.PowerLoss_W,...
 ARRAY.Shore.PowerLoss_pc]...
    = powerlossperc(ARRAY.Shore.PowerIn_W,...
                    ARRAY.Shore.PowerOut_W);
                                                  
%% Total
% Power In
ARRAY.Total.PowerIn_W = Devices_PowerGenerated_W .* Project_ArraySize;

% Power Out
ARRAY.Total.PowerOut_W...
    = ARRAY.Shore.PowerOut_W;

% Power Loss
[ARRAY.Total.PowerLoss_W,...
 ARRAY.Total.PowerLoss_pc]...
    = powerlossperc(ARRAY.Total.PowerIn_W,...
                    ARRAY.Total.PowerOut_W);
                
% Accounting for Power Factor (reactive lost power)
ARRAY.Total.PowerOutFactored_W...
    = ARRAY.Total.PowerOut_W .* Transmission_PowerFactorAbs;  

[ARRAY.Total.PowerLossFactored_W,...
 ARRAY.Total.PowerLossFactored_pc]...
    = powerlossperc(ARRAY.Total.PowerIn_W,...
                    ARRAY.Total.PowerOutFactored_W);                

%% Output Checks
% ARRAY.Checks.Array_Devices_TotalPowerOut_W...
%     = Devices_PowerGenerated_W .* Project_ArraySize;
% 
% ARRAY.Checks.Array_OnBoard_TotalPowerOut_W...
%     = ARRAY.Onboard.PowerOut_W .* Project_ArraySize;
% 
% ARRAY.Checks.Array_ExportCable_TotalPowerOut_W...
%     = ARRAY.ExportCable.PowerOut_W .* Project_ArraySize;
% 
% ARRAY.Checks.Array_Shore_TotalPowerOut_W = ARRAY.Shore.PowerOut_W;
% 
% ARRAY.Checks.Array_SumIndividualStageLosses_TotalLosses_pc...
%     = ARRAY.Onboard.PowerLoss_pc...
%     + ARRAY.ExportCable.PowerLoss_pc...
%     + ARRAY.Shore.PowerLoss_pc;
% 
% ARRAY.Checks.Array_Delievered_TotalLosses_pc...
%     = ARRAY.Total.PowerLoss_pc;

%% Output Variables
Power_TotalDelivered_W = ARRAY.Total.PowerOutFactored_W;
Power_TotalLoss_pc     = ARRAY.Total.PowerLossFactored_pc;

end