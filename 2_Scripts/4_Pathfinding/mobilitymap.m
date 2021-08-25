function [MobilityMap] = mobilitymap(VariableMap, MaxorMin)
%% Function Description - mobilitymap - JAM 02/05/20
% This function produces a mobility map of where within the domain a path
% can explore.

%% Inputs Description
% Map: Matrix of size [mxn] with NaNs representing blockages. For the
% example of depth, land should be input as NaNs. The water can be any
% numeric value.

%% Outputs Description
% MobilityMap: Matrix of size [mxn] with NaNs representing blockages. For the
% example of depth, all landlocked bodies of water will now be filled in
% with NaNs, as they cannot be reached from the main body of water.

%% Inputs Checks
validateattributes(VariableMap,{'numeric'},{'2d','nonempty'});
MaxorMin = validatestring(MaxorMin,{'minimal','maximal'});

%% Normalise to act as initial Mobility (between 0 - 1)
MobilityMap = zeros(size(VariableMap));                                     % Preallocate memory.
switch MaxorMin
    case 'minimal'                                                          % Normalise the mobility to be highest in shallow water (stick to the shallows).
        for x = 1:size(VariableMap, 1)                                      % For each grid cell in x direction (E/W)...
        for y = 1:size(VariableMap, 2)                                      % For each grid cell in y direction (N/S)...
            if isnan(VariableMap(x,y)) == 0                                 % If value is not a NaN...
                if VariableMap(x,y) > 0                                     % If mean water depth is greater than zero (valid water)...
                    MobilityMap(x,y)...
                        = (VariableMap(x,y)./ max(max(VariableMap))); 
                end
            end                                                            
        end
        end
        
    case 'maximal'                                                          % Normalise the mobility to be highest in deep water (stay away from the shallows).
        for x = 1:size(VariableMap, 1)                                      % For each grid cell in x direction (E/W)...
        for y = 1:size(VariableMap, 2)                                      % For each grid cell in y direction (N/S)...
            if isnan(VariableMap(x,y)) == 0                                 % If value is not a NaN...
                if VariableMap(x,y) > 0                                     % If mean water depth is greater than zero (valid water)...
                    MobilityMap(x,y)...
                        = 1 - (VariableMap(x,y)./ max(max(VariableMap)));
                end                
            end
        end
        end
end

%% Finalise
MobilityMap(MobilityMap == 0) = 1;

end