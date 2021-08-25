function [EuclideanDistance_m]...
            = utmeuclideandist(UTM_E1_m, UTM_N1_m,...
                               UTM_Zone1, UTM_Hemi1,...
                               UTM_E2_m, UTM_N2_m,...
                               UTM_Zone2, UTM_Hemi2)
%% Function Description
%

%% Inputs Description
% UTM_E1_m

% UTM_N1_m

% UTM_Zone1

% UTM_Hemi1

% UTM_E2_m

% UTM_N2_m

% UTM_Zone2

% UTM_Hemi2

%% Outputs Description
% EuclideanDistance_m

%% Input Checks
validateattributes(UTM_E1_m, {'numeric'},{'scalar','nonempty','nonnan','finite'});
validateattributes(UTM_N1_m, {'numeric'},{'scalar','nonempty','nonnan','finite'});
validateattributes(UTM_Zone1,{'numeric'},{'scalar','nonempty','nonnan','finite'});
validateattributes(UTM_Hemi1,{'char'},{'nonempty'});

validateattributes(UTM_E2_m, {'numeric'},{'scalar','nonempty','nonnan','finite'});
validateattributes(UTM_N2_m, {'numeric'},{'scalar','nonempty','nonnan','finite'});
validateattributes(UTM_Zone2,{'numeric'},{'scalar','nonempty','nonnan','finite'});
validateattributes(UTM_Hemi2,{'char'},{'nonempty'});

if UTM_Zone1 ~= UTM_Zone2 ...
|| strcmp(UTM_Hemi1, UTM_Hemi2) ~=1
    error('UTM Zones / Hemispheres do not match! Ensure that the two points over which Euclidean distance is to be calculated lie in the same UTM Zone / Hemisphere. If this is not the case, but the points are reasonably nearby, consider imposing a UTM zone with the "wgs2utm.m" function.');
end

%% Calculate Euclidean Distance "over the Earth" between the two points
EuclideanDistance_m...                                                      % Approximated by the euclidean distance. No Scale factor included, assuming height above Earth's surface to be 0.
    = ((UTM_E1_m - UTM_E2_m).^2 + (UTM_N1_m - UTM_N2_m).^2) .^ 0.5; 

end