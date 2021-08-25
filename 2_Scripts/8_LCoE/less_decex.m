function [Costs_Decommissioning_CCC]...
            = less_decex(Costs_Manufacturing_CCC,...
                         DecommissioningConstant)
%% Function Description
%

%% Inputs Description
% Costs_Manufacturing_CCC

% DecommissioningConstant

%% Outputs Description
% Costs_Decommissioning_CCC

%% Inputs Checks
validateattributes(Costs_Manufacturing_CCC,...
    {'numeric'},{'nonnegative','nonempty','nonnan','finite'});

validateattributes(DecommissioningConstant,...
    {'numeric'},{'nonempty','nonnan','finite'});

%% Decommissioning Costs Calculation
Costs_Decommissioning_CCC...
    = Costs_Manufacturing_CCC .* DecommissioningConstant;

end