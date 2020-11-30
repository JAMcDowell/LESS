function [LineCurrent_A] = linecurrent(PowerIn_W,...
                                       VoltageIn_V,...
                                       PowerFactor_pc,...
                                       Phase)
%% Function Description
%

%% Inputs Description
% PowerIn_W

% VoltageIn_V

% PowerFactor_pc

% Phase

%% Outputs Description
% LineCurrent_A

%% Input Checks
validateattributes(PowerIn_W,     {'numeric'},{'column','nonnegative'});
validateattributes(VoltageIn_V,   {'numeric'},{'scalar','nonnegative'});
validateattributes(PowerFactor_pc,{'numeric'},{'scalar','nonnan'});
validateattributes(Phase,         {'numeric'},{'scalar','nonnan','nonnegative'});

%% Calculate Line Current
LineCurrent_A...
    = PowerIn_W ./ (VoltageIn_V .* (PowerFactor_pc / 100) .* sqrt(Phase));

end