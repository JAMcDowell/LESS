function [Power_Delivered_W,...
          Power_LineLoss_W,...
          Power_LineLoss_pc]...
            = lineloss(Export_Power_W,...
                       LineVoltage_V,...
                       Cable_Res_Ohmpm,...
                       Distance_m,...
                       PowerFactor_pc,...
                       Phase)
%% Function Description - lineloss - JAM 30/11/20
% This function calculates active line losses, assuming Delta configuration.

%% Inputs Description
% Export_Power_W
% LineVoltage_V
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
validateattributes(LineVoltage_V,  {'numeric'},{'scalar','nonnegative'});
validateattributes(Cable_Res_Ohmpm,{'numeric'},{'scalar','nonnegative'});
validateattributes(Distance_m,     {'numeric'},{'scalar','nonnegative'});
validateattributes(PowerFactor_pc, {'numeric'},{'scalar','nonnan'});
validateattributes(Phase,          {'numeric'},{'scalar','nonnan','nonnegative'});

%% Resistance (Ohms)
Resistance_Ohm = Cable_Res_Ohmpm .* Distance_m;

%% Power & Current through Export Cable
LineCurrent_A = linecurrent(Export_Power_W, LineVoltage_V,...
                            PowerFactor_pc, Phase);
                          
%% Losses through Export Cable
Power_LineLoss_W...                                                         % Assuming Delta configuration and active losses only:
    = (LineCurrent_A.^2) .* Resistance_Ohm .* Phase;                        % P = sqrt(3) * VLine * ILine * 1
                                                                            %   = sqrt(3) * (sqrt(3) * ILine * R) * ILine * 1
                                                                            %   = 3 * ILine^2 * R
        
%% Power Delivered
Power_Delivered_W = Export_Power_W - Power_LineLoss_W;
Power_Delivered_W(Power_Delivered_W < 0) = 0;

%% Percentage Loss
[~,Power_LineLoss_pc] = powerlossperc(Export_Power_W, Power_Delivered_W);

%% Output Checks
validateattributes(Power_Delivered_W,{'numeric'},{'column','nonnegative'});
validateattributes(Power_LineLoss_W, {'numeric'},{'column','nonnegative'});
validateattributes(Power_LineLoss_pc,{'numeric'},{'column','nonnegative'});

end
