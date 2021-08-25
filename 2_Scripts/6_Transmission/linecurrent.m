function [LineCurrent_A] = linecurrent(PowerIn_W,...
                                       VoltageLine_V,...
                                       PowerFactor_pc,...
                                       Phase)
%% Function Description - linecurrent - JAM 30/11/20
% This function calculates the line current.

%% Inputs Description
% PowerIn_W
% VoltageIn_V
% PowerFactor_pc
% Phase

%% Outputs Description
% LineCurrent_A

%% Input Checks
validateattributes(PowerIn_W,     {'numeric'},{'column','nonnegative'});
validateattributes(VoltageLine_V, {'numeric'},{'scalar','nonnegative'});
validateattributes(PowerFactor_pc,{'numeric'},{'scalar','nonnan'});
validateattributes(Phase,         {'numeric'},{'scalar','nonnan','nonnegative'});

%% Power Factor Absolute
PowweFactorAbs = (1 - abs(1 - (PowerFactor_pc/100)));

%% Calculate Line Current
LineCurrent_A...                                                            % Generalised equation for total transmitted power in three-phase system: 
    = PowerIn_W ./ (VoltageLine_V .* PowweFactorAbs .* sqrt(Phase));        % P = sqrt(3) * VLine * ILine * PFactor = 3 * VPhase * IPhase * PFactor

%% Output Checks
validateattributes(LineCurrent_A,{'numeric'},{'column','nonnegative'});

end
