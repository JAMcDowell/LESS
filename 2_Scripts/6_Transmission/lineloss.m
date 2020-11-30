function [Power_Delivered_W,...
          Power_LineLoss_W,...
          Power_LineLoss_pc]...
            = lineloss(Export_Power_W,...
                       ExportVoltage_V,...
                       Cable_Res_Ohmpm,...
                       Distance_m,...
                       PowerFactor_pc,...
                       Phase)
%% Function Description
%

%% Inputs Description
% Export_Power_W

% ExportVoltage_V

% Cable_Res_Ohmpm

% Distance_m

% PowerFactor_pc

% Phase

%% Outputs Description
% Power_Delivered_W

% Power_LineLoss_W

% Power_LineLoss_pc

%% Input Checks
validateattributes(Export_Power_W, {'numeric'},{'column','nonnegative'});
validateattributes(ExportVoltage_V,{'numeric'},{'scalar','nonnegative'});
validateattributes(Cable_Res_Ohmpm,{'numeric'},{'scalar','nonnegative'});
validateattributes(Distance_m,     {'numeric'},{'scalar','nonnegative'});
validateattributes(PowerFactor_pc, {'numeric'},{'scalar','nonnan'});
validateattributes(Phase,          {'numeric'},{'scalar','nonnan','nonnegative'});

%% Resistance (Ohms)
Resistance_Ohm = Cable_Res_Ohmpm .* Distance_m;

%% Power & Current through Export Cable
[LineCurrent_A] = linecurrent(Export_Power_W, ExportVoltage_V,...
                              PowerFactor_pc, Phase);
                          
%% Losses through Export Cable
Power_LineLoss_W = sqrt(Phase) .* (LineCurrent_A.^2) .* Resistance_Ohm;
        
%% Power Delivered
Power_Delivered_W = Export_Power_W - Power_LineLoss_W;

%% Percentage Loss
Power_LineLoss_pc = 100 - (Power_Delivered_W ./ Export_Power_W .* 100);

end
