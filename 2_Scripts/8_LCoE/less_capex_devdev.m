function [Costs_LCoE_DeviceDevelopment_CCC]...
            = less_capex_devdev(Time_Development_y,...
                                NumberStaff,...    
                                Costs_AnnualOverheads_CCC,...
                                Costs_StaffAnnualAverageSalary_CCC,...
                                Costs_ScaleTesting_CCC)
%% Function Description
%

%% Inputs Description
% Time_Development_y

% NumberStaff

% Costs_AnnualOverheads_CCC

% Costs_Staff_AnnualAverageSalary_CCC

% Costs_ScaleTesting_CCC

%% Outputs Description
% Costs_LCoE_DeviceDevelopment_CCC

%% Inputs Checks
validateattributes(Time_Development_y,                {'numeric'},{'nonnegative','nonempty','nonnan','finite'});
validateattributes(NumberStaff,                       {'numeric'},{'nonnegative','nonempty','nonnan','finite'});
validateattributes(Costs_AnnualOverheads_CCC,         {'numeric'},{'nonnegative','nonempty','nonnan','finite'});
validateattributes(Costs_StaffAnnualAverageSalary_CCC,{'numeric'},{'nonnegative','nonempty','nonnan','finite'});
validateattributes(Costs_ScaleTesting_CCC,            {'numeric'},{'nonnegative','nonempty','nonnan','finite'});

%% Device Development Costs Calculation
Costs_LCoE_DeviceDevelopment_CCC...
    = Time_Development_y .* (Costs_AnnualOverheads_CCC + (NumberStaff .* Costs_StaffAnnualAverageSalary_CCC))...
    + Costs_ScaleTesting_CCC;

end
