function [Costs_OpEx_CCCpy] = less_opex(Costs_SiteLeasing_CCCpy,...
                                        Costs_Ports_Hire_CCCpy,...
                                        Costs_Vessels_Hire_CCCpy,...
                                        Costs_Vessels_Running_CCCpy,...
                                        Costs_Vessels_Standby_CCCpy)
%% Function Description
%

%% Inputs Description
% Costs_SiteLeasing_CCCpy

% Costs_Ports_Hire_CCCpy

% Costs_Vessels_Hire_CCCpy

% Costs_Vessels_Running_CCCpy

% Costs_Vessels_Standby_CCCpy

%% Outputs Description
% Costs_OpEx_CCCpy

%% Calculate Annual Operational Expenditure
Costs_OpEx_CCCpy...
    = Costs_SiteLeasing_CCCpy...
    + Costs_Ports_Hire_CCCpy...
    + Costs_Vessels_Hire_CCCpy...
    + Costs_Vessels_Running_CCCpy...
    + Costs_Vessels_Standby_CCCpy;

end
