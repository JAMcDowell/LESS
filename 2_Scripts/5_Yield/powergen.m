function [PowerGen_W] = powergen(PowerPerf_Rotor_W,...
                                 Flow_Vel_Abs_PWA_ms)
%% Input Descriptions
% PowerPerf_Rotor_W: [mx2] matrix, where Column 1 is the incident flow 
% velocity (m/s) at 0.1m/s velocity bin resolution and Column 2 is the 
% power generated (W) at each velocity bin of the specified rotor.

% Flow_Vel_Abs_PWA_ms: Column vector of power-weighted average absolute 
% flow velocity, as calculated per the IEC standards (see pwa.m function).

%% Output Descriptions
% PowerGen: Scalar value relating to the power generated (kW) by the input
% velocity values. Optional output variable.

%% Inputs Checks
validateattributes(PowerPerf_Rotor_W,...
    {'numeric'},{'2d','ncols',2,'nonnegative','nonnan','nonempty','finite'});

validateattributes(Flow_Vel_Abs_PWA_ms,...
    {'numeric'},{'column','nonnegative','nonempty','finite'});

%% Index Match
[~,Idx] = ismembertol(single(round2(Flow_Vel_Abs_PWA_ms,0.1)),...           % Find whether power-weighted velocity value is held within the rounded power curves.
                      single(PowerPerf_Rotor_W(:,1)));                      % Tolerance is essential to ensure the values are rounded properly. ismembertol(A,B) uses a default tolerance of 1e-6 for single-precision inputs and 1e-12 for double-precision inputs.                                              

%% Calculate Power Generated
PowerGen_W = zeros(size(Flow_Vel_Abs_PWA_ms));                              % Preallocate memory.
PowerGen_W(Idx~=0) = PowerPerf_Rotor_W(Idx(Idx~=0),2);                      % Extract the corresponding power data for each velocity.

end