function [CapEx_CCC] = less_capex(Costs_DeviceDevelopment_CCC,...
                                  Costs_SiteSelection_CCC,...
                                  Costs_Manufacturing_CCC)
%% Function Description
%

%% Inputs Description
% Costs_DeviceDevelopment_CCC

% Costs_SiteSelection_CCC

% Costs_Manufacturing_CCC

%% Outputs Description
% CapEx_CCC

%% Inputs Checks
validateattributes(Costs_DeviceDevelopment_CCC,{'numeric'},{'nonnegative','nonempty','nonnan','finite'});
validateattributes(Costs_SiteSelection_CCC,    {'numeric'},{'nonnegative','nonempty','nonnan','finite'});
validateattributes(Costs_Manufacturing_CCC,    {'numeric'},{'nonnegative','nonempty','nonnan','finite'});

%% Initial Costs Calculation
CapEx_CCC = Costs_DeviceDevelopment_CCC...
          + Costs_SiteSelection_CCC...
          + Costs_Manufacturing_CCC;

end