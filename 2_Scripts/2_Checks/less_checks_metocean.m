function [METOCEAN] = less_checks_metocean(METOCEAN,SCENARIO,IN)
%% Function Description - less_checks_metocean - JAM 30/11/20
% This function performs several checks on the loaded metocean data in 
% order to catch common errors.

%% Inputs Description
% METOCEAN - Structure of Metocean data.
% SCENARIO - Structure of Scenario data.
% IN       - Structure of Inputs data.

%% Ouputs Description
% METOCEAN - Structure of Metocean data. Updated with data which has been
%            checked/corrected by this function.

%% Validate Attributes
if IN.RUN.SPATIAL
    if ~isdatetime(METOCEAN.SPATIAL.DateTime_UTC)
        error('Check that the .mat file specified in "Region_DateTime_UTC_MatFile" of sheet "Region_MatFiles" in "U0_Region.xlsx" is of class "datetime".');
    end
    
    validateattributes(METOCEAN.SPATIAL.BathyXYZ_UTM_m,...
                       {'single'},...
                       {'3d','nonempty'});
    validateattributes(METOCEAN.SPATIAL.Depth_m,...
                       {'single'},...
                       {'3d','nonempty'}); 
    validateattributes(METOCEAN.SPATIAL.Flow_Vel_Abs_DepAv_ms,...
                       {'single'},...
                       {'3d','nonempty'});               
%     validateattributes(METOCEAN.SPATIAL.Wind_Vel_Abs_U10_ms,...
%                        {'single'},...
%                        {'3d','nonempty'});
    validateattributes(METOCEAN.SPATIAL.Wave_Hs_m,...
                       {'single'},...
                       {'3d','nonempty'});              
end

if IN.RUN.DISCRETE
    for s = 1:size(SCENARIO.Sites.Sites_Location,1)
        if ~isdatetime(METOCEAN.DISCRETE.(SCENARIO.Sites.Sites_Location.Sites_Name{s}).DateTime_UTC)
            error('Check that the .mat file specified in "Sites_DateTime_UTC_MatFile" of sheet "Sites_MatFiles" in "U1_Sites.xlsx" is of class "datetime".');
        end

        validateattributes(METOCEAN.DISCRETE.(SCENARIO.Sites.Sites_Location.Sites_Name{s}).Depth_m,...
                           {'single'},...
                           {'column','nonempty'});    
        validateattributes(METOCEAN.DISCRETE.(SCENARIO.Sites.Sites_Location.Sites_Name{s}).Flow_Vel_Abs_DepAv_ms,...
                           {'single'},...
                           {'column','nonempty'});   
%         validateattributes(METOCEAN.DISCRETE.(SCENARIO.Sites.Sites_Location.Sites_Name{s}).Wind_Vel_Abs_U10_ms,...
%                            {'single'},...
%                            {'column','nonempty'});   
        validateattributes(METOCEAN.DISCRETE.(SCENARIO.Sites.Sites_Location.Sites_Name{s}).Wave_Hs_m,...
                           {'single'},...
                           {'column','nonempty'});  
    end
end

%% Minimum Duration Checks (1 year of data required)
MinDuration_h = 365*24;

if IN.RUN.SPATIAL
    if size(METOCEAN.SPATIAL.DateTime_UTC,1)          < MinDuration_h ...
    || size(METOCEAN.SPATIAL.Depth_m,1)               < MinDuration_h ...
    || size(METOCEAN.SPATIAL.Flow_Vel_Abs_DepAv_ms,1) < MinDuration_h ...      
    || size(METOCEAN.SPATIAL.Wave_Hs_m,1)             < MinDuration_h      
        error('At least 1 year of hourly data (>= 8760) is required to calculate LCoE. Check the duration of the SPATIAL .mat files.');
    end
end

if IN.RUN.DISCRETE
    for s = 1:size(SCENARIO.Sites.Sites_Location,1)
        if size(METOCEAN.DISCRETE.(SCENARIO.Sites.Sites_Location.Sites_Name{s}).DateTime_UTC,1)          < MinDuration_h ...
        || size(METOCEAN.DISCRETE.(SCENARIO.Sites.Sites_Location.Sites_Name{s}).Depth_m,1)               < MinDuration_h ...
        || size(METOCEAN.DISCRETE.(SCENARIO.Sites.Sites_Location.Sites_Name{s}).Flow_Vel_Abs_DepAv_ms,1) < MinDuration_h ...      
        || size(METOCEAN.DISCRETE.(SCENARIO.Sites.Sites_Location.Sites_Name{s}).Wave_Hs_m,1)             < MinDuration_h      
            error('At least 1 year of hourly data (>= 8760) is required to calculate LCoE. Check the duration of the DISCRETE .mat files.');
        end
    end
end

%% Size Checks
if IN.RUN.SPATIAL
    % Bathymetry (X, Y, Z)
    if size(METOCEAN.SPATIAL.BathyXYZ_UTM_m,1) ~= 3
        error('"BathyXYZ_UTM_m" data must have dimensions [3 x m x n], where m and n correspond to the size of the UTM grid. Dimension 1/3 corresponds to UTM E, 2/3 to UTM N and 3/3 to chart datum bathymetry (initial bed level).')
    end
    
    % Grid t (Time)
    if ~isequal(size(METOCEAN.SPATIAL.Depth_m,1),...
                size(METOCEAN.SPATIAL.Flow_Vel_Abs_DepAv_ms,1),...
                size(METOCEAN.SPATIAL.Wave_Hs_m,1))
            error('The "t dimension" [t x m x n] of the SPATIAL data does not match. Check the dimensions of the SPATIAL .mat files.');
    end
    
    % Grid m
    if ~isequal(size(METOCEAN.SPATIAL.BathyXYZ_UTM_m,2),...
                size(METOCEAN.SPATIAL.Depth_m,2),...
                size(METOCEAN.SPATIAL.Flow_Vel_Abs_DepAv_ms,2),...
                size(METOCEAN.SPATIAL.Wave_Hs_m,2))
            error('The "m dimension" [t x m x n] of the SPATIAL data does not match. Check the dimensions of the SPATIAL .mat files.');
    end

    % Grid n  
    if ~isequal(size(METOCEAN.SPATIAL.BathyXYZ_UTM_m,3),...
                size(METOCEAN.SPATIAL.Depth_m,3),...
                size(METOCEAN.SPATIAL.Flow_Vel_Abs_DepAv_ms,3),...
                size(METOCEAN.SPATIAL.Wave_Hs_m,3))
            error('The "n dimension" [t x m x n] of the SPATIAL data does not match. Check the dimensions of the SPATIAL .mat files.');
    end
end
    
if IN.RUN.DISCRETE
    for s = 1:size(SCENARIO.Sites.Sites_Location,1)
        % Dimension t (Time)
        if ~isequal(size(METOCEAN.DISCRETE.(SCENARIO.Sites.Sites_Location.Sites_Name{s}).DateTime_UTC,1),...
                    size(METOCEAN.DISCRETE.(SCENARIO.Sites.Sites_Location.Sites_Name{s}).Depth_m,1),...
                    size(METOCEAN.DISCRETE.(SCENARIO.Sites.Sites_Location.Sites_Name{s}).Flow_Vel_Abs_DepAv_ms,1),...
                    size(METOCEAN.DISCRETE.(SCENARIO.Sites.Sites_Location.Sites_Name{s}).Wave_Hs_m,1))
                error('The "t dimension" [t x 1] of the DISCRETE data does not match. Check the number of rows in the DISCRETE .mat files.');
        end
    end
end
    
%% SPATIAL Corrections
if IN.RUN.SPATIAL 
    %% Adjust Chart Datum to always be above Bin Size
    METOCEAN.SPATIAL.ChartDatum_Z_m = squeeze(METOCEAN.SPATIAL.BathyXYZ_UTM_m(3,:,:));
    METOCEAN.SPATIAL.ChartDatum_Z_m(METOCEAN.SPATIAL.ChartDatum_Z_m > 0) = NaN;
    METOCEAN.SPATIAL.ChartDatum_Z_m = abs(METOCEAN.SPATIAL.ChartDatum_Z_m);
    METOCEAN.SPATIAL.ChartDatum_Z_m...
        (METOCEAN.SPATIAL.ChartDatum_Z_m < SCENARIO.Region.Region_FlowProfile.Flow_BinSize_m)...
            = NaN;
     
    %% Adjust Depth to always be above Bin Size
    METOCEAN.SPATIAL.Depth_m...                                             % If at each time step, the depth at a grid point is less than the bin size...
        (:,squeeze(any(METOCEAN.SPATIAL.Depth_m < SCENARIO.Region.Region_FlowProfile.Flow_BinSize_m,1)))...
            = SCENARIO.Region.Region_FlowProfile.Flow_BinSize_m;            % ...set it to be the bin size, so that at least one bin exists at every grid point for each time step.
        
    %% Generate Binary Map to Fill
    BinaryBathy = METOCEAN.SPATIAL.ChartDatum_Z_m;                          % Duplicate bathy.
    BinaryBathy(isnan(METOCEAN.SPATIAL.ChartDatum_Z_m))  = 1;               % Convert any NaNs (land) to 1.
    BinaryBathy(~isnan(METOCEAN.SPATIAL.ChartDatum_Z_m)) = 0;               % Convert any non-NaNs (water) to 0.
    BinaryBathy = logical(BinaryBathy);                                     % Convert to logical.
          
    %% Floodfill (remove any landlocked sections of water)
    % Image Reconstruct Fill  
    disp(' - Applying "image" fill...');
    FloodFilledHoles = imfill(BinaryBathy,'holes');                     	% Fill in the 0s bounded by 1s.

    % Generate Filled Map
    FilledMap = METOCEAN.SPATIAL.ChartDatum_Z_m;                        	% Duplicate bathy.
    FilledMap(FloodFilledHoles == 1) = NaN;                             	% Holes filled with 1 now count as land, and are designated as NaNs.
    
    % NaN Conditions (LandLocked)
    NaNConditions = isnan(FilledMap);                                       % Store indexes of all NaNs on the filled map.

    %% Apply the NaN Conditions to all METOCEAN grids for consistency
    METOCEAN.SPATIAL.BathyXYZ_UTM_m(:,NaNConditions) = NaN;                 % Make any invalid points on the Bathy map into NaNs.                 
    METOCEAN.SPATIAL.ChartDatum_Z_m(NaNConditions)   = NaN;

    METOCEAN.SPATIAL.Depth_m(:,NaNConditions)               = NaN;          % Make any invalid points on the metocean conditions map into NaNs.                 
    METOCEAN.SPATIAL.Flow_Vel_Abs_DepAv_ms(:,NaNConditions) = NaN;
%     METOCEAN.SPATIAL.Wind_Vel_Abs_U10_ms(:,NaNConditions)   = NaN;
    METOCEAN.SPATIAL.Wave_Hs_m(:,NaNConditions)             = NaN;
    
    %% Output UTM Coordinate Grid
    METOCEAN.SPATIAL.UTM_E_m = squeeze(METOCEAN.SPATIAL.BathyXYZ_UTM_m(1,:,:));
    METOCEAN.SPATIAL.UTM_N_m = squeeze(METOCEAN.SPATIAL.BathyXYZ_UTM_m(2,:,:));
end

end
