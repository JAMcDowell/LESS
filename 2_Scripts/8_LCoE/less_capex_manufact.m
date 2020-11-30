function [Costs_Manufacturing_CCC]...
            = less_capex_manufact(Costs_Transmission_Shoreside_CCC,...
                                  Costs_Transmission_Onboard_CCC,... 
                                  Costs_Transmission_ExportCable_CCC,...
                                  Costs_Devices_PerStructure_CCC,...
                                  Costs_Turbines_PerTurbine_CCC,...
                                  Costs_Devices_PerAnchor,...
                                  Costs_Devices_PerMooringLine,...
                                  Array_NumberDevices,...
                                  Devices_NumberTurbines,...
                                  Devices_NumberAnchors)
%% Function Description
%

%% Inputs Description
% Costs_Transmission_Shoreside_CCC

% Costs_Transmission_Onboard_CCC

% Costs_Transmission_ExportCable_CCC

% Costs_Devices_PerStructure_CCC

% Costs_Turbines_PerTurbine_CCC

% Costs_Devices_PerAnchor

% Costs_Devices_PerMooringLine

% Array_NumberDevices

% Devices_NumberTurbines

% Devices_NumberAnchors

% Devices_NumberMooringLines

%% Outputs Description
% Costs_Manufacturing_CCC

%% Inputs Checks
% Costs
validateattributes(Costs_Transmission_Shoreside_CCC,  {'numeric'},{'nonnegative','nonempty','nonnan','finite'});
validateattributes(Costs_Transmission_Onboard_CCC,    {'numeric'},{'nonnegative','nonempty','nonnan','finite'});
validateattributes(Costs_Transmission_ExportCable_CCC,{'numeric'},{'nonnegative','nonempty','nonnan','finite'});
validateattributes(Costs_Devices_PerStructure_CCC,    {'numeric'},{'nonnegative','nonempty','nonnan','finite'});
validateattributes(Costs_Turbines_PerTurbine_CCC,     {'numeric'},{'nonnegative','nonempty','nonnan','finite'});
validateattributes(Costs_Devices_PerAnchor,           {'numeric'},{'nonnegative','nonempty','nonnan','finite'});
validateattributes(Costs_Devices_PerMooringLine,      {'numeric'},{'nonnegative','nonempty','nonnan','finite'});

% Device Characteristics
validateattributes(Devices_NumberTurbines,    {'numeric'},{'nonnegative','nonempty','nonnan','finite'});
validateattributes(Devices_NumberAnchors,     {'numeric'},{'nonnegative','nonempty','nonnan','finite'});

% Number Devices
validateattributes(Array_NumberDevices,{'numeric'},{'nonnegative','nonempty','nonnan','finite'});

%% Manufacturing Costs Calculation
Costs_Manufacturing_CCC...
    = Costs_Transmission_Shoreside_CCC...
    + Array_NumberDevices * (Costs_Transmission_Onboard_CCC...
                           + Costs_Transmission_ExportCable_CCC...
                           + Costs_Devices_PerStructure_CCC...
                           + (Costs_Turbines_PerTurbine_CCC * Devices_NumberTurbines)...
                           + (Costs_Devices_PerAnchor       * Devices_NumberAnchors)...
                           + (Costs_Devices_PerMooringLine  * Devices_NumberAnchors));

end
