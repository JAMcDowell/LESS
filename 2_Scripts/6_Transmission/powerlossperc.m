function [PowerLoss_W,...
          PowerLoss_pc] = powerlossperc(PowerGenerated_W,...
                                        PowerDelivered_W)
%% Function Description - powerlossperc - JAM 30/11/21
% This function calculates the power loss percentage, based on power
% generated and power delivered.

%% Inputs Description
% PowerGenerated_W
% PowerDelivered_W

%% Outputs Description
% PowerLoss_W
% PowerLoss_pc

%% Input Checks
% Iterative script, checks not performed.

%% Power Loss 
PowerLoss_W = PowerGenerated_W - PowerDelivered_W;                          % (a - b)

%% Loss Percentage
if PowerGenerated_W == 0
    PowerLoss_pc = 0;
else
    PowerLoss_pc = (PowerLoss_W ./ PowerGenerated_W) .* 100;                % ((a - b) ./ a) * 100
end

end
