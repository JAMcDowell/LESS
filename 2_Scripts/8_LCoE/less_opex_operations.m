function [Costs_OpEx_CCCpy] = less_opex_operations(Costs_Ports_Hire_CCCpy,...
                                                   Costs_Vessels_Hire_CCCpy,...
                                                   Costs_Vessels_Running_CCCpy,...
                                                   Costs_Vessels_Standby_CCCpy)
%% Function Description - less_opex_operations - JAM 30/11/20
% This function sums all costs associated with Operations in order to
% calculate Operational Expenditure (OpEx).

%% Inputs Description
% Costs_Ports_Hire_CCCpy
% Costs_Vessels_Hire_CCCpy
% Costs_Vessels_Running_CCCpy
% Costs_Vessels_Standby_CCCpy

%% Outputs Description
% Costs_OpEx_CCCpy

%% Calculate Annual Operational Expenditure
Costs_OpEx_CCCpy...
    = Costs_Ports_Hire_CCCpy...
    + Costs_Vessels_Hire_CCCpy...
    + Costs_Vessels_Running_CCCpy...
    + Costs_Vessels_Standby_CCCpy;

end
