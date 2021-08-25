function [SCENARIO,IN] = less_checks_scenario(SCENARIO,IN)
%% Function Description - less_checks_scenario - JAM 30/11/20
% This function checks that the data loaded in by "less_load_scenario.m" 
% is valid for the LESS tool. This function will throw errors if checks  
% are not completed successfully.

%% Inputs Description
% SCENARIO - Structure of Scenario data.
% IN       - Structure of Input data.

%% Outputs Description
% IN - Structure of Input data. New essential fields are added by this 
% function (Discrete/Spatial run flags).

% SCENARIO - Structure of Scenario data. New essential fields are added 
% by this function (validated strings).

%% Function Input Checks
validateattributes(SCENARIO,{'struct'},{'nonempty'});  
validateattributes(IN,      {'struct'},{'nonempty'});  
disp('Performing checks on user-defined "Scenario" data...');

%% Region_SpatialRunFlag
if size(SCENARIO.Region.Region_SpatialRunFlag,1) ~= 1
    error('"Region_SpatialRunFlag" table only requires a single input - check "Region_SpatialRunFlag" sheet in "U0_Region.xlsx".');
end

% Region_SpatialRunFlag
validateattributes(SCENARIO.Region.('Region_SpatialRunFlag').Region_SpatialRunFlag(1),...
                    {'numeric'},...
                    {'scalar','binary','nonempty','nonnan'});

if SCENARIO.Region.('Region_SpatialRunFlag').Region_SpatialRunFlag(1)
    %% Run Flag
    IN.RUN.SPATIAL = 1;

    %% Region_UTM
    if size(SCENARIO.Region.Region_UTM,1) ~= 1
        error('Only 1 Region can be specified - check "Region_UTM" sheet in "U0_Region.xlsx".');
    end

    if ~all(ismember(unique(SCENARIO.Region.('Region_UTM').Region_Name),... % Consistent text check.
                    SCENARIO.Region.Region_UTM.Region_Name))
        error('Inconsistent Region names specified - check "Region_UTM" sheet in "U0_Region.xlsx".');
    end

    % Region_Name
    if ~isvarname(SCENARIO.Region.('Region_UTM').Region_Name{1})
        error(['"Region_Name" must be a valid variable name. Must begin with a letter and contain not more than '...
            num2str(namelengthmax),' characters. Valid variable names can include letters, digits, and underscores. MATLAB keywords are not valid variable names.']);
    end

    % Region_UTM_Zone
    validateattributes(SCENARIO.Region.('Region_UTM').Region_UTM_Zone(1),...
                        {'numeric'},...
                        {'scalar','positive','integer','nonempty','nonnan'});
    % Region_UTM_Hemi
    SCENARIO.Region.('Region_UTM').Region_UTM_Hemi{1}...
        = validatestring(SCENARIO.Region.('Region_UTM').Region_UTM_Hemi{1},...
                         {'N','S'});               

    %% Region_MatFiles
    if size(SCENARIO.Region.Region_MatFiles,1) ~= 1
        error('Only 1 Region can be specified. Check "Region_MatFiles" sheet in "U0_Region.xlsx".');
    end

    if ~all(ismember(unique(SCENARIO.Region.('Region_MatFiles').Region_Name),...      % Consistent text check.
                    SCENARIO.Region.Region_UTM.Region_Name))
        error('Inconsistent Region names specified - check "Region_MatFiles" sheet in "U0_Region.xlsx".');
    end

    % Region_Name
    if ~isvarname(SCENARIO.Region.('Region_MatFiles').Region_Name{1})
        error(['"Region_Name" must be a valid variable name. Must begin with a letter and contain not more than '...
            num2str(namelengthmax),' characters. Valid variable names can include letters, digits, and underscores. MATLAB keywords are not valid variable names.']);
    end
    
    % Region_DateTime_UTC_MatFile
    validateattributes(SCENARIO.Region.('Region_MatFiles').Region_DateTime_UTC_MatFile{1},...
                        {'char'},...
                        {'nonempty'});

    if ~strcmp(SCENARIO.Region.('Region_MatFiles').Region_DateTime_UTC_MatFile{1}(end-3:end),'.mat')
        error('"Region_DateTime_UTC_MatFile" must be a MATLAB file (.mat). Check "Region_MatFiles" sheet in "U0_Region.xlsx".');     
    end

    % Region_BathyXYZ_UTM_m_MatFile
    validateattributes(SCENARIO.Region.('Region_MatFiles').Region_BathyXYZ_UTM_m_MatFile{1},...
                        {'char'},...
                        {'nonempty'});

    if ~strcmp(SCENARIO.Region.('Region_MatFiles').Region_BathyXYZ_UTM_m_MatFile{1}(end-3:end),'.mat')
        error('"Region_BathyXYZ_UTM_m_MatFile" must be a MATLAB file (.mat). Check "Region_MatFiles" sheet in "U0_Region.xlsx".');     
    end    

    % Region_Depth_m_MatFile
    validateattributes(SCENARIO.Region.('Region_MatFiles').Region_Depth_m_MatFile{1},...
                        {'char'},...
                        {'nonempty'});

    if ~strcmp(SCENARIO.Region.('Region_MatFiles').Region_Depth_m_MatFile{1}(end-3:end),'.mat')
        error('"Region_Depth_m_MatFile" must be a MATLAB file (.mat). Check "Region_MatFiles" sheet in "U0_Region.xlsx".');     
    end        

    % Region_Flow_Vel_Abs_DepAv_ms_MatFile
    validateattributes(SCENARIO.Region.('Region_MatFiles').Region_Flow_Vel_Abs_DepAv_ms_MatFile{1},...
                        {'char'},...
                        {'nonempty'});

    if ~strcmp(SCENARIO.Region.('Region_MatFiles').Region_Flow_Vel_Abs_DepAv_ms_MatFile{1}(end-3:end),'.mat')
        error('"Region_Flow_Vel_Abs_DepAv_ms_MatFile" must be a MATLAB file (.mat). Check "Region_MatFiles" sheet in "U0_Region.xlsx".');     
    end        

    % Region_Wind_Vel_Abs_U10_ms_MatFile
%     validateattributes(SCENARIO.Region.('Region_MatFiles').Region_Wind_Vel_Abs_U10_ms_MatFile{1},...
%                         {'char'},...
%                         {'nonempty'});
% 
%     if ~strcmp(SCENARIO.Region.('Region_MatFiles').Region_Wind_Vel_Abs_U10_ms_MatFile{1}(end-3:end),'.mat')
%         error('"Region_Wind_Vel_Abs_U10_ms_MatFile" must be a MATLAB file (.mat). Check "Region_MatFiles" sheet in "U0_Region.xlsx".');     
%     end       

    % Region_Wave_Hs_m_MatFile
    validateattributes(SCENARIO.Region.('Region_MatFiles').Region_Wave_Hs_m_MatFile{1},...
                        {'char'},...
                        {'nonempty'});

    if ~strcmp(SCENARIO.Region.('Region_MatFiles').Region_Wave_Hs_m_MatFile{1}(end-3:end),'.mat')
        error('"Region_Wave_Hs_m_MatFile" must be a MATLAB file (.mat). Check "Region_MatFiles" sheet in "U0_Region.xlsx".');     

    end   

    %% Region_FlowProfile
    if size(SCENARIO.Region.Region_FlowProfile,1) ~= 1
        error('Only 1 Region can be specified. Check "Region_FlowProfile" sheet in "U0_Region.xlsx".');
    end
    
    if ~all(ismember(unique(SCENARIO.Region.('Region_FlowProfile').Region_Name),...      % Consistent text check.
                    SCENARIO.Region.Region_UTM.Region_Name))
        error('Inconsistent Region names specified - check "Region_FlowProfile" sheet in "U0_Region.xlsx".');
    end

    % Region_Name
    if ~isvarname(SCENARIO.Region.('Region_FlowProfile').Region_Name{1})
        error(['"Region_Name" must be a valid variable name. Must begin with a letter and contain not more than '...
            num2str(namelengthmax),' characters. Valid variable names can include letters, digits, and underscores. MATLAB keywords are not valid variable names.']);
    end
    
    % Flow_PowerLawExponent	
    validateattributes(SCENARIO.Region.('Region_FlowProfile').Flow_PowerLawExponent(1),...
                       {'numeric'},...
                       {'scalar','nonempty','nonnan','>=',1});  
    % Flow_BinSize_m
    validateattributes(SCENARIO.Region.('Region_FlowProfile').Flow_BinSize_m(1),...
                       {'numeric'},...
                       {'scalar','nonempty','nonnan','positive'}); 

    %% Region_Pathfinding
    if size(SCENARIO.Region.Region_Pathfinding,1) ~= 1
        error('Only 1 Region can be specified. Check "Region_Pathfinding" sheet in "U0_Region.xlsx".');
    end
    
    if ~all(ismember(unique(SCENARIO.Region.('Region_Pathfinding').Region_Name),...      % Consistent text check.
                    SCENARIO.Region.Region_UTM.Region_Name))
        error('Inconsistent Region names specified - check "Region_Pathfinding" sheet in "U0_Region.xlsx".');
    end

    % Region_Name
    if ~isvarname(SCENARIO.Region.('Region_Pathfinding').Region_Name{1})
        error(['"Region_Name" must be a valid variable name. Must begin with a letter and contain not more than '...
            num2str(namelengthmax),' characters. Valid variable names can include letters, digits, and underscores. MATLAB keywords are not valid variable names.']);
    end

    % Pathfinding_HeuristicWeighting	
    validateattributes(SCENARIO.Region.('Region_Pathfinding').Pathfinding_HeuristicWeighting(1),...
                       {'numeric'},...
                       {'scalar','nonempty','nonnan','>=',1});      

    % Pathfinding_ConnectingDistance	
    validateattributes(SCENARIO.Region.('Region_Pathfinding').Pathfinding_ConnectingDistance(1),...
                       {'numeric'},...
                       {'scalar','nonempty','nonnan','even','>=',2});    

    % Pathfinding_DepthMobilityWeighting	
    validateattributes(SCENARIO.Region.('Region_Pathfinding').Pathfinding_DepthMobilityWeighting(1),...
                       {'numeric'},...
                       {'scalar','nonempty','nonnan','>=',1});    
                   
     %% Region_Costs
    if size(SCENARIO.Region.('Region_Costs').Region_Name,1)...                  % Number of inputs check.
    ~= size(SCENARIO.Region.Region_UTM.Region_Name,1)
        error('Inconsistent number of Region specified - check "Region_Costs" sheet in "U0_Region.xlsx".');
    end

    if ~all(ismember(unique(SCENARIO.Region.('Region_Costs').Region_Name),...      % Consistent text check.
                    SCENARIO.Region.Region_UTM.Region_Name))
        error('Inconsistent Region names specified - check "Region_Costs" sheet in "U0_Region.xlsx".');
    end

    % Region_Name
    if ~isvarname(SCENARIO.Region.('Region_Costs').Region_Name{1})
        error(['"Region_Name" must be a valid variable name. Must begin with a letter and contain not more than '...
            num2str(namelengthmax),' characters. Valid variable names can include letters, digits, and underscores. MATLAB keywords are not valid variable names.']);
    end

    % Region_AssessmentCosts_CCC
    validateattributes(SCENARIO.Region.('Region_Costs').Region_AssessmentCosts_CCC(1),...
                       {'numeric'},...
                       {'scalar','nonempty','nonnan','finite','nonnegative'});  

    % Region_LeasingCosts_CCCpy           
    validateattributes(SCENARIO.Region.('Region_Costs').Region_LeasingCosts_CCCpy(1),...
                       {'numeric'},...
                       {'scalar','nonempty','nonnan','finite','nonnegative'});                   
                   
else
    %% Run Flag
    IN.RUN.SPATIAL = 0;
end

disp(' - "Region" input checks passed.');               
               
%% Sites_DiscreteRunFlag
if size(SCENARIO.Sites.Sites_DiscreteRunFlag,1) ~= 1
    error('"Sites_DiscreteRunFlag" table only requires a single input - check "Sites_DiscreteRunFlag" sheet in "U1_Sites.xlsx".');
end

% Sites_DiscreteRunFlag
validateattributes(SCENARIO.Sites.('Sites_DiscreteRunFlag').Sites_DiscreteRunFlag(1),...
                    {'numeric'},...
                    {'scalar','binary','nonempty','nonnan'});

if SCENARIO.Sites.('Sites_DiscreteRunFlag').Sites_DiscreteRunFlag(1)
    %% Run Flag
    IN.RUN.DISCRETE = 1;

    %% Sites_Location
    if size(SCENARIO.Sites.('Sites_Location').Sites_Name,1)...              % Number of inputs check.
    ~= size(SCENARIO.Sites.Sites_Location.Sites_Name,1)
        error('Inconsistent number of Sites specified - check "Sites_Location" sheet in "U1_Sites.xlsx".');
    end

    if ~all(ismember(unique(SCENARIO.Sites.('Sites_Location').Sites_Name),...  % Consistent text check.
                     SCENARIO.Sites.Sites_Location.Sites_Name))
        error('Inconsistent Sites names specified - check "Sites_Location" sheet in "U1_Sites.xlsx".');
    end

    for r = 1:size(SCENARIO.Sites.('Sites_Location').Sites_Name,1)
        % Sites_Name
        if ~isvarname(SCENARIO.Sites.('Sites_MatFiles').Sites_Name{r})
            error(['"Sites_Name" must be a valid variable name. Must begin with a letter and contain not more than '...
                num2str(namelengthmax),' characters. Valid variable names can include letters, digits, and underscores. MATLAB keywords are not valid variable names.']);
        end

        % Sites_Lat_dd
        validateattributes(SCENARIO.Sites.('Sites_Location').Sites_Lat_dd(r),...
                           {'numeric'},...
                           {'scalar','nonempty','nonnan'});
        % Sites_Lon_dd              
        validateattributes(SCENARIO.Sites.('Sites_Location').Sites_Lon_dd(r),...
                           {'numeric'},...
                           {'scalar','nonempty','nonnan'});   
    end

    %% Sites_MatFiles
    if size(SCENARIO.Sites.('Sites_MatFiles').Sites_Name,1)...                       % Number of inputs check.
    ~= size(SCENARIO.Sites.Sites_Location.Sites_Name,1)
        error('Inconsistent number of Sites specified - check "Sites_MatFiles" sheet in "U1_Sites.xlsx".');
    end

    if ~all(ismember(unique(SCENARIO.Sites.('Sites_MatFiles').Sites_Name),...        % Consistent text check.
                     SCENARIO.Sites.Sites_Location.Sites_Name))
        error('Inconsistent Sites names specified - check "Sites_MatFiles" sheet in "U1_Sites.xlsx".');
    end

    for r = 1:size(SCENARIO.Sites.('Sites_MatFiles').Sites_Name,1)
        % Sites_Name
        if ~isvarname(SCENARIO.Sites.('Sites_MatFiles').Sites_Name{r})
            error(['"Sites_Name" must be a valid variable name. Must begin with a letter and contain not more than '...
                num2str(namelengthmax),' characters. Valid variable names can include letters, digits, and underscores. MATLAB keywords are not valid variable names.']);
        end

        % Sites_DateTime_UTC_MatFile
        validateattributes(SCENARIO.Sites.('Sites_MatFiles').Sites_DateTime_UTC_MatFile{r},...
                            {'char'},...
                            {'nonempty'});

        if ~strcmp(SCENARIO.Sites.('Sites_MatFiles').Sites_DateTime_UTC_MatFile{r}(end-3:end),'.mat')
            error('"Sites_DateTime_UTC_MatFile" must be a MATLAB file (.mat). Check "Sites_MatFiles" sheet in "U1_Sites.xlsx".');     
        end

        % Sites_Depth_m_MatFile
        validateattributes(SCENARIO.Sites.('Sites_MatFiles').Sites_Depth_m_MatFile{r},...
                            {'char'},...
                            {'nonempty'});

        if ~strcmp(SCENARIO.Sites.('Sites_MatFiles').Sites_Depth_m_MatFile{r}(end-3:end),'.mat')
            error('"Sites_Depth_m_MatFile" must be a MATLAB file (.mat). Check "Sites_MatFiles" sheet in "U1_Sites.xlsx".');     
        end        

        % Sites_Flow_Vel_Abs_DepAv_ms_MatFile
        validateattributes(SCENARIO.Sites.('Sites_MatFiles').Sites_Flow_Vel_Abs_DepAv_ms_MatFile{r},...
                            {'char'},...
                            {'nonempty'});

        if ~strcmp(SCENARIO.Sites.('Sites_MatFiles').Sites_Flow_Vel_Abs_DepAv_ms_MatFile{r}(end-3:end),'.mat')
            error('"Sites_Flow_Vel_Abs_DepAv_ms_MatFile" must be a MATLAB file (.mat). Check "Sites_MatFiles" sheet in "U1_Sites.xlsx".');     
        end        

        % Sites_Wind_Vel_Abs_U10_ms_MatFile
%         validateattributes(SCENARIO.Sites.('Sites_MatFiles').Sites_Wind_Vel_Abs_U10_ms_MatFile{r},...
%                             {'char'},...
%                             {'nonempty'});
% 
%         if ~strcmp(SCENARIO.Sites.('Sites_MatFiles').Sites_Wind_Vel_Abs_U10_ms_MatFile{r}(end-3:end),'.mat')
%             error('"Sites_Wind_Vel_Abs_U10_ms_MatFile" must be a MATLAB file (.mat). Check "Sites_MatFiles" sheet in "U1_Sites.xlsx".');     
%         end       

        % Sites_Wave_Hs_m_MatFile
        validateattributes(SCENARIO.Sites.('Sites_MatFiles').Sites_Wave_Hs_m_MatFile{r},...
                            {'char'},...
                            {'nonempty'});

        if ~strcmp(SCENARIO.Sites.('Sites_MatFiles').Sites_Wave_Hs_m_MatFile{r}(end-3:end),'.mat')
            error('"Sites_Wave_Hs_m_MatFile" must be a MATLAB file (.mat). Check "Sites_MatFiles" sheet in "U1_Sites.xlsx".');     
        end  
    end

    %% Sites_FlowProfile
    if size(SCENARIO.Sites.('Sites_FlowProfile').Sites_Name,1)...                       % Number of inputs check.
    ~= size(SCENARIO.Sites.Sites_Location.Sites_Name,1)
        error('Inconsistent number of Sites specified - check "Sites_FlowProfile" sheet in "U1_Sites.xlsx".');
    end

    if ~all(ismember(unique(SCENARIO.Sites.('Sites_FlowProfile').Sites_Name),...        % Consistent text check.
                     SCENARIO.Sites.Sites_Location.Sites_Name))
        error('Inconsistent Sites names specified - check "Sites_FlowProfile" sheet in "U1_Sites.xlsx".');
    end

    for r = 1:size(SCENARIO.Sites.('Sites_FlowProfile').Sites_Name,1)
        % Sites_Name
        if ~isvarname(SCENARIO.Sites.('Sites_FlowProfile').Sites_Name{r})
            error(['"Sites_Name" must be a valid variable name. Must begin with a letter and contain not more than '...
                num2str(namelengthmax),' characters. Valid variable names can include letters, digits, and underscores. MATLAB keywords are not valid variable names.']);
        end

        % Flow_PowerLawExponent	
        validateattributes(SCENARIO.Sites.('Sites_FlowProfile').Flow_PowerLawExponent(1),...
                           {'numeric'},...
                           {'scalar','nonempty','nonnan','>=',1});  
        % Flow_BinSize_m
        validateattributes(SCENARIO.Sites.('Sites_FlowProfile').Flow_BinSize_m(1),...
                           {'numeric'},...
                           {'scalar','nonempty','nonnan','positive'}); 
    end

    %% Sites_Costs
    if size(SCENARIO.Sites.('Sites_Costs').Sites_Name,1)...                     % Number of inputs check.
    ~= size(SCENARIO.Sites.Sites_Location.Sites_Name,1)
        error('Inconsistent number of Sites specified - check "Sites_Costs" sheet in "U1_Sites.xlsx".');
    end

    if ~all(ismember(unique(SCENARIO.Sites.('Sites_Costs').Sites_Name),...       % Consistent text check.
                    SCENARIO.Sites.Sites_Location.Sites_Name))
        error('Inconsistent Sites names specified - check "Sites_Costs" sheet in "U1_Sites.xlsx".');
    end

    for r = 1:size(SCENARIO.Sites.('Sites_Costs').Sites_Name,1)
        % Sites_Name
        if ~isvarname(SCENARIO.Sites.('Sites_Costs').Sites_Name{r})
            error(['"Sites_Name" must be a valid variable name. Must begin with a letter and contain not more than '...
                num2str(namelengthmax),' characters. Valid variable names can include letters, digits, and underscores. MATLAB keywords are not valid variable names.']);
        end

        % Sites_AssessmentCosts_CCC
        validateattributes(SCENARIO.Sites.('Sites_Costs').Sites_AssessmentCosts_CCC(r),...
                           {'numeric'},...
                           {'scalar','nonempty','nonnan','finite','nonnegative'});  
        % Sites_LeasingCosts_CCCpy           
        validateattributes(SCENARIO.Sites.('Sites_Costs').Sites_LeasingCosts_CCCpy(r),...
                           {'numeric'},...
                           {'scalar','nonempty','nonnan','finite','nonnegative'});    
    end
else
    %% Run Flag
    IN.RUN.DISCRETE = 0;
end   
 
disp(' - "Sites" input checks passed.');
if SCENARIO.Region.Region_SpatialRunFlag.Region_SpatialRunFlag(1)...
|| SCENARIO.Sites.Sites_DiscreteRunFlag.Sites_DiscreteRunFlag(1)
    %% Operations_Considered
    if size(SCENARIO.Operations.('Operations_Considered').Operations_Name,1)... % Number of inputs check.
    ~= size(SCENARIO.Operations.Operations_Considered.Operations_Name,1)
        error('Inconsistent number of Operations specified - check "Operations_Considered" sheet in "U2_Operations.xlsx".');
    end

    if ~all(ismember(unique(SCENARIO.Operations.('Operations_Considered').Operations_Name),...   % Consistent text check.
                     SCENARIO.Operations.Operations_Considered.Operations_Name))
        error('Inconsistent Operations names specified - check "Operations_Considered" sheet in "U2_Operations.xlsx".');
    end


    for r = 1:size(SCENARIO.Operations.('Operations_Considered').Operations_Name,1)
        % Operations_Name
        if ~isvarname(SCENARIO.Operations.('Operations_Considered').Operations_Name{r})
            error(['"Operations_Name" must be a valid variable name. Must begin with a letter and contain not more than '...
                num2str(namelengthmax),' characters. Valid variable names can include letters, digits, and underscores. MATLAB keywords are not valid variable names.']);
        end
    end
    disp(' - "Operations" input checks passed.');

    %% Turbines_Diameter 
    if size(SCENARIO.Turbines.('Turbines_Diameter').Turbines_Name,1)...         % Number of inputs check.
    ~= size(SCENARIO.Turbines.Turbines_Diameter.Turbines_Name,1)
        error('Inconsistent number of Turbines specified - check "Turbines_Diameter" sheet in "U3_Turbines.xlsx".');
    end

    if ~all(ismember(unique(SCENARIO.Turbines.('Turbines_Diameter').Turbines_Name),...   % Consistent text check.
                    SCENARIO.Turbines.Turbines_Diameter.Turbines_Name))
        error('Inconsistent Turbines names specified - check "Turbines_Diameter" sheet in "U3_Turbines.xlsx".');
    end

    for r = 1:size(SCENARIO.Turbines.('Turbines_Diameter').Turbines_Name,1)
        % Turbines_Name
        if isvarname(SCENARIO.Turbines.('Turbines_Diameter').Turbines_Name{r}) ~= 1
            error('Invalid variable name/table header. Expected entries must be composed of upper/lower case alphanumeric characters, and may contain the underscore symbol (_). Other symbol and special characters are not permitted.');  
        end

        % Turbines_Diameter_m
        validateattributes(SCENARIO.Turbines.('Turbines_Diameter').Turbines_Diameter_m(r),...
                           {'numeric'},...
                           {'scalar','nonempty','nonnan','finite','positive'});               
    end

    %% Turbines_PowerPerformance
    if size(SCENARIO.Turbines.('Turbines_PowerPerformance').Turbines_Name,1)...         % Number of inputs check.
    ~= size(SCENARIO.Turbines.Turbines_Diameter.Turbines_Name,1)
        error('Inconsistent number of Turbines specified - check "Turbines_PowerPerformance" sheet in "U3_Turbines.xlsx".');
    end

    if ~all(ismember(unique(SCENARIO.Turbines.('Turbines_PowerPerformance').Turbines_Name),...   % Consistent text check.
                    SCENARIO.Turbines.Turbines_Diameter.Turbines_Name))
        error('Inconsistent Turbines names specified - check "Turbines_PowerPerformance" sheet in "U3_Turbines.xlsx".');
    end

    for r = 1:size(SCENARIO.Turbines.('Turbines_PowerPerformance').Turbines_Name,1)
        % Turbines_Name
        if isvarname(SCENARIO.Turbines.('Turbines_PowerPerformance').Turbines_Name{r}) ~= 1
            error('Invalid variable name/table header. Expected entries must be composed of upper/lower case alphanumeric characters, and may contain the underscore symbol (_). Other symbol and special characters are not permitted.');  
        end

        % Power_W_PWAVel(c)
        for c = 2:size(SCENARIO.Turbines.('Turbines_PowerPerformance'),2) 
             validateattributes(SCENARIO.Turbines.('Turbines_PowerPerformance'){r,c},...
                                {'numeric'},...
                                {'scalar','nonempty','nonnan','finite','nonnegative'});   
        end                   
    end 

    %% Turbines_Cost
    if size(SCENARIO.Turbines.('Turbines_Cost').Turbines_Name,1)...             % Number of inputs check.
    ~= size(SCENARIO.Turbines.Turbines_Diameter.Turbines_Name,1)
        error('Inconsistent number of Turbines specified - check "Turbines_Cost" sheet in "U3_Turbines.xlsx".');
    end

    if ~all(ismember(unique(SCENARIO.Turbines.('Turbines_Cost').Turbines_Name),...% Consistent text check.
                    SCENARIO.Turbines.Turbines_Diameter.Turbines_Name))
        error('Inconsistent Turbines names specified - check "Turbines_Cost" sheet in "U3_Turbines.xlsx".');
    end

    for r = 1:size(SCENARIO.Turbines.('Turbines_Cost').Turbines_Name,1)
        % Turbines_Name
        if isvarname(SCENARIO.Turbines.('Turbines_Cost').Turbines_Name{r}) ~= 1
            error('Invalid variable name/table header. Expected entries must be composed of upper/lower case alphanumeric characters, and may contain the underscore symbol (_). Other symbol and special characters are not permitted.');  
        end

        % Turbines_Cost_CCC
        validateattributes(SCENARIO.Turbines.('Turbines_Cost').Turbines_Cost_CCC(r),...
                           {'numeric'},...
                           {'scalar','nonempty','nonnan','finite','nonnegative'});  
    end 
    disp(' - "Turbines" input checks passed.');

    %% Devices_TurbineArrangement
    if size(SCENARIO.Devices.('Devices_TurbineArrangement').Devices_Name,1)...  % Number of inputs check.
    ~= size(SCENARIO.Devices.Devices_TurbineArrangement.Devices_Name,1)
        error('Inconsistent number of Devices specified - check "Devices_TurbineArrangement" sheet in "U4_Devices.xlsx".');
    end

    if ~all(ismember(unique(SCENARIO.Devices.('Devices_TurbineArrangement').Devices_Name),...   % Consistent text check.
                    SCENARIO.Devices.Devices_TurbineArrangement.Devices_Name))
        error('Inconsistent Devices names specified - check "Devices_TurbineArrangement" sheet in "U4_Devices.xlsx".');
    end

    if ~all(ismember(unique(SCENARIO.Devices.('Devices_TurbineArrangement').Turbines_Name),...   % Consistent text check.
                    SCENARIO.Turbines.Turbines_Diameter.Turbines_Name))
        error('Inconsistent Turbines names specified - check "Devices_TurbineArrangement" sheet in "U4_Devices.xlsx".');
    end

    for r = 1:size(SCENARIO.Devices.('Devices_TurbineArrangement').Devices_Name,1)
        % Devices_Name
        if isvarname(SCENARIO.Devices.('Devices_TurbineArrangement').Devices_Name{r}) ~= 1
            error('Invalid variable name/table header. Expected entries must be composed of upper/lower case alphanumeric characters, and may contain the underscore symbol (_). Other symbol and special characters are not permitted.');  
        end

        % Turbines_Name         
        if isvarname(SCENARIO.Devices.('Devices_TurbineArrangement').Turbines_Name{r}) ~= 1
            error('Invalid variable name/table header. Expected entries must be composed of upper/lower case alphanumeric characters, and may contain the underscore symbol (_). Other symbol and special characters are not permitted.');  
        end

        % Devices_NumberTurbines
        validateattributes(SCENARIO.Devices.('Devices_TurbineArrangement').Devices_NumberTurbines(r),...
                           {'numeric'},...
                           {'scalar','nonempty','nonnan','finite','positive'});  

        % Devices_BoundaryType
        if isvarname(SCENARIO.Devices.('Devices_TurbineArrangement').Devices_BoundaryType{r}) ~= 1
            error('Invalid variable name/table header. Expected entries must be composed of upper/lower case alphanumeric characters, and may contain the underscore symbol (_). Other symbol and special characters are not permitted.');  
        end

        if max(strcmp(SCENARIO.Devices.('Devices_TurbineArrangement').Devices_BoundaryType{r},{'Surface','Bed'})) == 0
            error('"Devices_BoundaryType" must be designated as "Surface" or "Bed" - check "U4_Devices.xlsx".');
        end

        % Devices_Hub2BoundaryDistance_m           
        validateattributes(SCENARIO.Devices.('Devices_TurbineArrangement').Devices_Hub2BoundaryDistance_m(r),...
                           {'numeric'},...
                           {'scalar','nonempty','nonnan','finite','nonnegative'});   
                       
    end

    %% Devices_DeploymentRequirements
    if size(SCENARIO.Devices.('Devices_DeploymentRequirements').Devices_Name,1)...  % Number of inputs check.
    ~= size(SCENARIO.Devices.Devices_TurbineArrangement.Devices_Name,1)
        error('Inconsistent number of Devices specified - check "Devices_DeploymentRequirements" sheet in "U4_Devices.xlsx".');
    end

    if ~all(ismember(unique(SCENARIO.Devices.('Devices_DeploymentRequirements').Devices_Name),...   % Consistent text check.
                    SCENARIO.Devices.Devices_TurbineArrangement.Devices_Name))
        error('Inconsistent Devices names specified - check "Devices_DeploymentRequirements" sheet in "U4_Devices.xlsx".');
    end

    for r = 1:size(SCENARIO.Devices.('Devices_DeploymentRequirements').Devices_Name,1)
        % Devices_Name
        if isvarname(SCENARIO.Devices.('Devices_DeploymentRequirements').Devices_Name{r}) ~= 1
            error('Invalid variable name/table header. Expected entries must be composed of upper/lower case alphanumeric characters, and may contain the underscore symbol (_). Other symbol and special characters are not permitted.');  
        end

        % Devices_NumberAnchorPoints
        validateattributes(SCENARIO.Devices.('Devices_DeploymentRequirements').Devices_NumberAnchorPoints(r),...
                           {'numeric'},...
                           {'scalar','nonempty','nonnan','finite','nonnegative'});  

        % Devices_MinWaterDepth_m           
        validateattributes(SCENARIO.Devices.('Devices_DeploymentRequirements').Devices_MinWaterDepth_m(r),...
                           {'numeric'},...
                           {'scalar','nonempty','nonnan','finite','nonnegative'}); 

        % Devices_MaxWaterDepth_m           
        validateattributes(SCENARIO.Devices.('Devices_DeploymentRequirements').Devices_MaxWaterDepth_m(r),...
                           {'numeric'},...
                           {'scalar','nonempty','nonnan','finite','nonnegative'}); 
    end

    %% Devices_GenerationLimits
    if size(SCENARIO.Devices.('Devices_GenerationLimits').Devices_Name,1)...  % Number of inputs check.
    ~= size(SCENARIO.Devices.Devices_TurbineArrangement.Devices_Name,1)
        error('Inconsistent number of Devices specified - check "Devices_GenerationLimits" sheet in "U4_Devices.xlsx".');
    end

    if ~all(ismember(unique(SCENARIO.Devices.('Devices_GenerationLimits').Devices_Name),...   % Consistent text check.
                    SCENARIO.Devices.Devices_TurbineArrangement.Devices_Name))
        error('Inconsistent Devices names specified - check "Devices_GenerationLimits" sheet in "U4_Devices.xlsx".');
    end

    for r = 1:size(SCENARIO.Devices.('Devices_GenerationLimits').Devices_Name,1)
        % Devices_Name
        if isvarname(SCENARIO.Devices.('Devices_GenerationLimits').Devices_Name{r}) ~= 1
            error('Invalid variable name/table header. Expected entries must be composed of upper/lower case alphanumeric characters, and may contain the underscore symbol (_). Other symbol and special characters are not permitted.');  
        end

        % Flow_Vel_Abs_PWA_ms
        validateattributes(SCENARIO.Devices.('Devices_GenerationLimits').Flow_Vel_Abs_PWA_ms(r),...
                           {'numeric'},...
                           {'scalar','nonempty','nonnan','finite','positive'});  

        % Wind_Vel_Abs_U10_ms           
%         validateattributes(SCENARIO.Devices.('Devices_GenerationLimits').Wind_Vel_Abs_U10_ms(r),...
%                            {'numeric'},...
%                            {'scalar','nonempty','nonnan','finite','positive'});

        % Wave_Hs_m
        validateattributes(SCENARIO.Devices.('Devices_GenerationLimits').Wave_Hs_m(r),...
                           {'numeric'},...
                           {'scalar','nonempty','nonnan','finite','positive'});
    end

    %% Devices_OperationsLimits
    if size(SCENARIO.Devices.('Devices_OperationsLimits').Devices_Name,1)...% Number of inputs check.
    ~= (size(SCENARIO.Devices.Devices_TurbineArrangement.Devices_Name,1)...
      * size(SCENARIO.Operations.Operations_Considered.Operations_Name,1))
        error('Inconsistent number of Devices or Operations specified - check "Devices_OperationsLimits" sheet in "U4_Devices.xlsx".');
    end

    if ~all(ismember(unique(SCENARIO.Devices.('Devices_OperationsLimits').Devices_Name),...   % Consistent text check (Devices names).
                    SCENARIO.Devices.Devices_TurbineArrangement.Devices_Name))
        error('Inconsistent Devices names specified - check "Devices_OperationsLimits" sheet in "U4_Devices.xlsx".');
    end

    if ~all(ismember(unique(SCENARIO.Devices.('Devices_OperationsLimits').Operations_Name),...   % Consistent text check (Operations names).
                    SCENARIO.Operations.Operations_Considered.Operations_Name))
        error('Inconsistent Devices names specified - check "Devices_OperationsLimits" sheet in "U4_Devices.xlsx".');
    end

    for r = 1:size(SCENARIO.Devices.('Devices_OperationsLimits').Devices_Name,1)
        % Devices_Name
        if isvarname(SCENARIO.Devices.('Devices_OperationsLimits').Devices_Name{r}) ~= 1
            error('Invalid variable name/table header. Expected entries must be composed of upper/lower case alphanumeric characters, and may contain the underscore symbol (_). Other symbol and special characters are not permitted.');  
        end

        % Operations_Name
        if isvarname(SCENARIO.Devices.('Devices_OperationsLimits').Operations_Name{r}) ~= 1
            error('Invalid variable name/table header. Expected entries must be composed of upper/lower case alphanumeric characters, and may contain the underscore symbol (_). Other symbol and special characters are not permitted.');  
        end

        % Flow_Vel_Abs_Surf_ms
        validateattributes(SCENARIO.Devices.('Devices_OperationsLimits').Flow_Vel_Abs_Surf_ms(r),...
                           {'numeric'},...
                           {'scalar','nonempty','nonnan','finite','positive'});                   
        % Wind_Vel_Abs_U10_ms           
%         validateattributes(SCENARIO.Devices.('Devices_OperationsLimits').Wind_Vel_Abs_U10_ms(r),...
%                            {'numeric'},...
%                            {'scalar','nonempty','nonnan','finite','positive'});
        % Wave_Hs_m
        validateattributes(SCENARIO.Devices.('Devices_OperationsLimits').Wave_Hs_m(r),...
                           {'numeric'},...
                           {'scalar','nonempty','nonnan','finite','positive'});
    end

    %% Devices_OperationsDurationsFreq
    if size(SCENARIO.Devices.('Devices_OperationsDurationsFreq').Devices_Name,1)...% Number of inputs check.
    ~= (size(SCENARIO.Devices.Devices_TurbineArrangement.Devices_Name,1)...
      * size(SCENARIO.Operations.Operations_Considered.Operations_Name,1))
        error('Inconsistent number of Devices or Operations specified - check "Devices_OperationsDurationsFreq" sheet in "U4_Devices.xlsx".');
    end

    if ~all(ismember(unique(SCENARIO.Devices.('Devices_OperationsDurationsFreq').Devices_Name),...   % Consistent text check (Devices names).
                    SCENARIO.Devices.Devices_TurbineArrangement.Devices_Name))
        error('Inconsistent Devices names specified - check "Devices_OperationsDurationsFreq" sheet in "U4_Devices.xlsx".');
    end

    if ~all(ismember(unique(SCENARIO.Devices.('Devices_OperationsDurationsFreq').Operations_Name),...   % Consistent text check (Operations names).
                    SCENARIO.Operations.Operations_Considered.Operations_Name))
        error('Inconsistent Devices names specified - check "Devices_OperationsDurationsFreq" sheet in "U4_Devices.xlsx".');
    end

    for r = 1:size(SCENARIO.Devices.('Devices_OperationsDurationsFreq').Devices_Name,1)
        % Devices_Name
        if isvarname(SCENARIO.Devices.('Devices_OperationsDurationsFreq').Devices_Name{r}) ~= 1
            error('Invalid variable name/table header. Expected entries must be composed of upper/lower case alphanumeric characters, and may contain the underscore symbol (_). Other symbol and special characters are not permitted.');  
        end

        % Operations_Name
        if isvarname(SCENARIO.Devices.('Devices_OperationsDurationsFreq').Operations_Name{r}) ~= 1
            error('Invalid variable name/table header. Expected entries must be composed of upper/lower case alphanumeric characters, and may contain the underscore symbol (_). Other symbol and special characters are not permitted.');  
        end

        % Operations_OnSiteDuration_h
        validateattributes(SCENARIO.Devices.('Devices_OperationsDurationsFreq').Operations_OnSiteDuration_h(r),...
                           {'numeric'},...
                           {'scalar','nonempty','nonnan','finite','nonnegative'});                   

        % Operations_FrequencyOccurence_py           
        validateattributes(SCENARIO.Devices.('Devices_OperationsDurationsFreq').Operations_FrequencyOccurence_py(r),...
                           {'numeric'},...
                           {'scalar','nonempty','nonnan','finite','nonnegative'});
    end

    %% Devices_Costs
    if size(SCENARIO.Devices.('Devices_Costs').Devices_Name,1)...               % Number of inputs check.
    ~= size(SCENARIO.Devices.Devices_TurbineArrangement.Devices_Name,1)
        error('Inconsistent number of Devices specified - check "Devices_Costs" sheet in "U4_Devices.xlsx".');
    end

    if ~all(ismember(unique(SCENARIO.Devices.('Devices_Costs').Devices_Name),...% Consistent text check.
                    SCENARIO.Devices.Devices_TurbineArrangement.Devices_Name)) 
        error('Inconsistent Devices names specified - check "Devices_Costs" sheet in "U4_Devices.xlsx".');
    end

    for r = 1:size(SCENARIO.Devices.('Devices_Costs').Devices_Name,1)
        % Devices_Name
        if isvarname(SCENARIO.Devices.('Devices_Costs').Devices_Name{r}) ~= 1
            error('Invalid variable name/table header. Expected entries must be composed of upper/lower case alphanumeric characters, and may contain the underscore symbol (_). Other symbol and special characters are not permitted.');  
        end

        % Devices_StructureCost_CCC
        validateattributes(SCENARIO.Devices.('Devices_Costs').Devices_StructureCost_CCC(r),...
                           {'numeric'},...
                           {'scalar','nonempty','nonnan','finite','nonnegative'});  

        % Devices_AnchorCost_CCCpAnch           
        validateattributes(SCENARIO.Devices.('Devices_Costs').Devices_AnchorCost_CCCpAnch(r),...
                           {'numeric'},...
                           {'scalar','nonempty','nonnan','finite','nonnegative'});

        % Devices_MooringLineCost_CCCpAnch
        validateattributes(SCENARIO.Devices.('Devices_Costs').Devices_MooringLineCost_CCCpAnch(r),...
                           {'numeric'},...
                           {'scalar','nonempty','nonnan','finite','nonnegative'});

        % Devices_DevelopmentCost_CCC
        validateattributes(SCENARIO.Devices.('Devices_Costs').Devices_DevelopmentCost_CCC(r),...
                           {'numeric'},...
                           {'scalar','nonempty','nonnan','finite','nonnegative'});               
    end
    disp(' - "Devices" input checks passed.');

    %% Ports_Locations 
    if size(SCENARIO.Ports.('Ports_Locations').Ports_Name,1)...  % Number of inputs check.
    ~= size(SCENARIO.Ports.Ports_Locations.Ports_Name,1)
        error('Inconsistent number of Ports specified - check "Ports_Locations" sheet in "U5_Ports.xlsx".');
    end

    if ~all(ismember(unique(SCENARIO.Ports.('Ports_Locations').Ports_Name),...   % Consistent text check.
                    SCENARIO.Ports.Ports_Locations.Ports_Name))
        error('Inconsistent Ports names specified - check "Ports_Locations" sheet in "U5_Ports.xlsx".');
    end

    for r = 1:size(SCENARIO.Ports.('Ports_Locations').Ports_Name,1)
        % Ports_Name
        if isvarname(SCENARIO.Ports.('Ports_Locations').Ports_Name{r}) ~= 1
            error('Invalid variable name/table header. Expected entries must be composed of upper/lower case alphanumeric characters, and may contain the underscore symbol (_). Other symbol and special characters are not permitted.');  
        end

        % Ports_Lat_dd
        validateattributes(SCENARIO.Ports.('Ports_Locations').Ports_Lat_dd(r),...
                           {'numeric'},...
                           {'scalar','nonempty','nonnan','finite'});
        % Ports_Lon_dd              
        validateattributes(SCENARIO.Ports.('Ports_Locations').Ports_Lon_dd(r),...
                           {'numeric'},...
                           {'scalar','nonempty','nonnan','finite'});  
    end 

    %% Ports_SizeClassification
    if size(SCENARIO.Ports.('Ports_SizeClassification').Ports_Name,1)...    % Number of inputs check.
    ~= size(SCENARIO.Ports.Ports_Locations.Ports_Name,1)
        error('Inconsistent number of Ports specified - check "Ports_SizeClassification" sheet in "U5_Ports.xlsx".');
    end

    if ~all(ismember(unique(SCENARIO.Ports.('Ports_SizeClassification').Ports_Name),...       % Consistent text check.
                    SCENARIO.Ports.Ports_Locations.Ports_Name))
        error('Inconsistent Ports names specified - check "Ports_SizeClassification" sheet in "U5_Ports.xlsx".');
    end

    for r = 1:size(SCENARIO.Ports.('Ports_SizeClassification').Ports_Name,1)
        % Ports_Name
        if isvarname(SCENARIO.Ports.('Ports_SizeClassification').Ports_Name{r}) ~= 1
            error('Invalid variable name/table header. Expected entries must be composed of upper/lower case alphanumeric characters, and may contain the underscore symbol (_). Other symbol and special characters are not permitted.');  
        end

        % Ports_SizeClassification
        if isvarname(SCENARIO.Ports.('Ports_SizeClassification').Ports_SizeClassification{r}) ~= 1
            error('Invalid variable name/table header. Expected entries must be composed of upper/lower case alphanumeric characters, and may contain the underscore symbol (_). Other symbol and special characters are not permitted.');  
        end

        if max(strcmp(SCENARIO.Ports.('Ports_SizeClassification').Ports_SizeClassification{r},{'Small','Medium','Large'})) == 0
            error('"Ports_SizeClassification" must be designated as "Small", "Medium" or "Large" - check "U5_Ports.xlsx".');
        end
    end

    %% Ports_Costs
    if size(SCENARIO.Ports.('Ports_Costs').Ports_Name,1)...                 % Number of inputs check.
    ~= size(SCENARIO.Ports.Ports_Locations.Ports_Name,1)
        error('Inconsistent number of Ports specified - check "Ports_Costs" sheet in "U5_Ports.xlsx".');
    end

    if ~all(ismember(unique(SCENARIO.Ports.('Ports_Costs').Ports_Name),...  % Consistent text check.
                    SCENARIO.Ports.Ports_Locations.Ports_Name))
        error('Inconsistent Ports names specified - check "Ports_Costs" sheet in "U5_Ports.xlsx".');
    end

    for r = 1:size(SCENARIO.Ports.('Ports_Costs').Ports_Name,1)
        % Ports_Name
        if isvarname(SCENARIO.Ports.('Ports_Costs').Ports_Name{r}) ~= 1
            error('Invalid variable name/table header. Expected entries must be composed of upper/lower case alphanumeric characters, and may contain the underscore symbol (_). Other symbol and special characters are not permitted.');  
        end
        
        % Ports_HireCosts_CCCpd
        validateattributes(SCENARIO.Ports.('Ports_Costs').Ports_HireCosts_CCCpd(r),...
                           {'numeric'},...
                           {'scalar','nonempty','nonnan','finite','nonnegative'});  
    end
    disp(' - "Ports" input checks passed.');

    %% Vessels_WorkingLimits 
    if size(SCENARIO.Vessels.('Vessels_WorkingLimits').Vessels_Name,1)...   % Number of inputs check.
    ~= size(SCENARIO.Vessels.Vessels_WorkingLimits.Vessels_Name,1)
        error('Inconsistent number of Vessels specified - check "Vessels_WorkingLimits" sheet in "U6_Vessels.xlsx".');
    end

    if ~all(ismember(unique(SCENARIO.Vessels.('Vessels_WorkingLimits').Vessels_Name),...   % Consistent text check.
                    SCENARIO.Vessels.Vessels_WorkingLimits.Vessels_Name))
        error('Inconsistent Vessels names specified - check "Vessels_WorkingLimits" sheet in "U6_Vessels.xlsx".');
    end

    for r = 1:size(SCENARIO.Vessels.('Vessels_WorkingLimits').Vessels_Name,1)
        % Vessels_Name
        if isvarname(SCENARIO.Vessels.('Vessels_WorkingLimits').Vessels_Name{r}) ~= 1
            error('Invalid variable name/table header. Expected entries must be composed of upper/lower case alphanumeric characters, and may contain the underscore symbol (_). Other symbol and special characters are not permitted.');  
        end

        % Vessels_TransitSpeed_ms
        validateattributes(SCENARIO.Vessels.('Vessels_WorkingLimits').Vessels_TransitSpeed_ms(r),...
                           {'numeric'},...
                           {'scalar','nonempty','nonnan','finite','positive'});                
        % Flow_Vel_Abs_Surf_ms              
        validateattributes(SCENARIO.Vessels.('Vessels_WorkingLimits').Flow_Vel_Abs_Surf_ms(r),...
                           {'numeric'},...
                           {'scalar','nonempty','nonnan','finite','positive'});
        % Wind_Vel_Abs_U10_ms              
%         validateattributes(SCENARIO.Vessels.('Vessels_WorkingLimits').Wind_Vel_Abs_U10_ms(r),...
%                            {'numeric'},...
%                            {'scalar','nonempty','nonnan','finite','positive'});                 
        % Wave_Hs_m              
        validateattributes(SCENARIO.Vessels.('Vessels_WorkingLimits').Wave_Hs_m(r),...
                           {'numeric'},...
                           {'scalar','nonempty','nonnan','finite','positive'});  
    end 

    %% Vessels_OperationsSuitability
    if size(SCENARIO.Vessels.('Vessels_OperationsSuitability').Vessels_Name,1)...% Number of inputs check.
    ~= (size(SCENARIO.Vessels.Vessels_WorkingLimits.Vessels_Name,1)...
      * size(SCENARIO.Devices.Devices_TurbineArrangement.Devices_Name,1)...
      * size(SCENARIO.Operations.Operations_Considered.Operations_Name,1))
        error('Inconsistent number of Vessels, Devices or Operations specified - check "Vessels_OperationsSuitability" sheet in "U6_Vessels.xlsx".');
    end

    if ~all(ismember(unique(SCENARIO.Vessels.('Vessels_OperationsSuitability').Vessels_Name),...   % Consistent text check (Devices names).
                    SCENARIO.Vessels.Vessels_WorkingLimits.Vessels_Name))
        error('Inconsistent Devices names specified - check "Vessels_OperationsSuitability" sheet in "U6_Vessels.xlsx".');
    end

    if ~all(ismember(unique(SCENARIO.Vessels.('Vessels_OperationsSuitability').Devices_Name),...   % Consistent text check (Devices names).
                    SCENARIO.Devices.Devices_TurbineArrangement.Devices_Name))
        error('Inconsistent Devices names specified - check "Vessels_OperationsSuitability" sheet in "U6_Vessels.xlsx".');
    end

    if ~all(ismember(unique(SCENARIO.Vessels.('Vessels_OperationsSuitability').Operations_Name),...   % Consistent text check (Operations names).
                     SCENARIO.Operations.Operations_Considered.Operations_Name))
        error('Inconsistent Devices names specified - check "Devices_OperationsDurationsFreq" sheet in "U4_Devices.xlsx".');
    end

    for r = 1:size(SCENARIO.Vessels.('Vessels_OperationsSuitability').Vessels_Name,1)
        % Vessels Name
        if isvarname(SCENARIO.Vessels.('Vessels_OperationsSuitability').Vessels_Name{r}) ~= 1
            error('Invalid variable name/table header. Expected entries must be composed of upper/lower case alphanumeric characters, and may contain the underscore symbol (_). Other symbol and special characters are not permitted.');  
        end

        % Devices_Name
        if isvarname(SCENARIO.Vessels.('Vessels_OperationsSuitability').Devices_Name{r}) ~= 1
            error('Invalid variable name/table header. Expected entries must be composed of upper/lower case alphanumeric characters, and may contain the underscore symbol (_). Other symbol and special characters are not permitted.');  
        end

        % Operations_Name
        if isvarname(SCENARIO.Vessels.('Vessels_OperationsSuitability').Operations_Name{r}) ~= 1
            error('Invalid variable name/table header. Expected entries must be composed of upper/lower case alphanumeric characters, and may contain the underscore symbol (_). Other symbol and special characters are not permitted.');  
        end

        % Vessels_Suitability              
        if isvarname(SCENARIO.Vessels.('Vessels_OperationsSuitability').Vessels_Suitability{r}) ~= 1
            error('Invalid variable name/table header. Expected entries must be composed of upper/lower case alphanumeric characters, and may contain the underscore symbol (_). Other symbol and special characters are not permitted.');  
        end     

        if max(strcmp(SCENARIO.Vessels.('Vessels_OperationsSuitability').Vessels_Suitability{r},{'Yes','No'})) == 0
            error('"Vessel_Suitability" must be designated as "Yes" or "No" - check "U6_Vessels.xlsx".');
        end    
    end 

    %% Vessels_SizeClassification
    if size(SCENARIO.Vessels.('Vessels_SizeClassification').Vessels_Name,1)...  % Number of inputs check.
    ~= size(SCENARIO.Vessels.Vessels_WorkingLimits.Vessels_Name,1)
        error('Inconsistent number of Vessels specified - check "Vessels_SizeClassification" sheet in "U6_Vessels.xlsx".');
    end

    if ~all(ismember(unique(SCENARIO.Vessels.('Vessels_SizeClassification').Vessels_Name),...   % Consistent text check.
                    SCENARIO.Vessels.Vessels_WorkingLimits.Vessels_Name))
        error('Inconsistent Vessels names specified - check "Vessels_SizeClassification" sheet in "U6_Vessels.xlsx".');
    end

    for r = 1:size(SCENARIO.Vessels.('Vessels_SizeClassification').Vessels_Name,1)
        % Vessels_Name
        if isvarname(SCENARIO.Vessels.('Vessels_SizeClassification').Vessels_Name{r}) ~= 1
            error('Invalid variable name/table header. Expected entries must be composed of upper/lower case alphanumeric characters, and may contain the underscore symbol (_). Other symbol and special characters are not permitted.');  
        end

        % Vessels_SizeClassification
        if isvarname(SCENARIO.Vessels.('Vessels_SizeClassification').Vessels_SizeClassification{r}) ~= 1
            error('Invalid variable name/table header. Expected entries must be composed of upper/lower case alphanumeric characters, and may contain the underscore symbol (_). Other symbol and special characters are not permitted.');  
        end

        if max(strcmp(SCENARIO.Vessels.('Vessels_SizeClassification').Vessels_SizeClassification{r},{'Small','Medium','Large'})) == 0
            error('"Ports_Size" must be designated as "Small", "Medium" or "Large" - check "U5_Ports.xlsx".');
        end  
    end 

    %% Vessels_Costs
    if size(SCENARIO.Vessels.('Vessels_Costs').Vessels_Name,1)...           % Number of inputs check.
    ~= size(SCENARIO.Vessels.Vessels_WorkingLimits.Vessels_Name,1)
        error('Inconsistent number of Vessels specified - check "Vessels_Costs" sheet in "U6_Vessels.xlsx".');
    end

    if ~all(ismember(unique(SCENARIO.Vessels.('Vessels_Costs').Vessels_Name),...   % Consistent text check.
                    SCENARIO.Vessels.Vessels_WorkingLimits.Vessels_Name))
        error('Inconsistent Vessels names specified - check "Vessels_Costs" sheet in "U6_Vessels.xlsx".');
    end

    for r = 1:size(SCENARIO.Vessels.('Vessels_Costs').Vessels_Name,1)
        % Vessels_Name
        if isvarname(SCENARIO.Vessels.('Vessels_Costs').Vessels_Name{r}) ~= 1
            error('Invalid variable name/table header. Expected entries must be composed of upper/lower case alphanumeric characters, and may contain the underscore symbol (_). Other symbol and special characters are not permitted.');  
        end

        % Vessels_HireCost_CCCpd              
        validateattributes(SCENARIO.Vessels.('Vessels_Costs').Vessels_HireCost_CCCpd(r),...
                           {'numeric'},...
                           {'scalar','nonempty','nonnan','finite','nonnegative'});

        % Vessels_RunningCost_CCCph              
        validateattributes(SCENARIO.Vessels.('Vessels_Costs').Vessels_RunningCost_CCCph(r),...
                           {'numeric'},...
                           {'scalar','nonempty','nonnan','finite','nonnegative'}); 

        % Vessels_StandbyCost_CCCpd              
        validateattributes(SCENARIO.Vessels.('Vessels_Costs').Vessels_StandbyCost_CCCpd(r),...
                           {'numeric'},...
                           {'scalar','nonempty','nonnan','finite','nonnegative'});  
    end
    disp(' - "Vessels" input checks passed.');

    %% Transmission_Parameters 
    if size(SCENARIO.Transmission.('Transmission_Parameters').Devices_Name,1)...% Number of inputs check.
    ~= size(SCENARIO.Devices.Devices_TurbineArrangement.Devices_Name,1)
        error('Inconsistent number of Devices specified - check "Transmission_Parameters" sheet in "U7_Transmission.xlsx".');
    end

    if ~all(ismember(unique(SCENARIO.Transmission.('Transmission_Parameters').Devices_Name),...   % Consistent text check.
                    SCENARIO.Devices.Devices_TurbineArrangement.Devices_Name))
        error('Inconsistent Devices names specified - check "Transmission_Parameters" sheet in "U7_Transmission.xlsx".');
    end

    for r = 1:size(SCENARIO.Transmission.('Transmission_Parameters').Devices_Name,1)
        % Devices_Name
        if isvarname(SCENARIO.Transmission.('Transmission_Parameters').Devices_Name{r}) ~= 1
            error('Invalid variable name/table header. Expected entries must be composed of upper/lower case alphanumeric characters, and may contain the underscore symbol (_). Other symbol and special characters are not permitted.');  
        end

        % Transmission_GenerationVoltage_V
        validateattributes(SCENARIO.Transmission.('Transmission_Parameters').Transmission_GenerationVoltage_V(r),...
                           {'numeric'},...
                           {'scalar','nonempty','nonnan','finite','positive'}); 

        % Transmission_ExportCableVoltage_V
        validateattributes(SCENARIO.Transmission.('Transmission_Parameters').Transmission_ExportCableVoltage_V(r),...
                           {'numeric'},...
                           {'scalar','nonempty','nonnan','finite','positive'}); 

        % Transmission_GridVoltage_V
        validateattributes(SCENARIO.Transmission.('Transmission_Parameters').Transmission_GridVoltage_V(r),...
                           {'numeric'},...
                           {'scalar','nonempty','nonnan','finite','positive'});  

        % Transmission_ExportCableResistance_ohmpm
        validateattributes(SCENARIO.Transmission.('Transmission_Parameters').Transmission_ExportCableResistance_ohmpm(r),...
                           {'numeric'},...
                           {'scalar','nonempty','nonnan','finite','positive'});                     

        % Transmission_OnboardTransformerNoLoadLosses_W
        validateattributes(SCENARIO.Transmission.('Transmission_Parameters').Transmission_OnboardTransformerNoLoadLosses_W(r),...
                           {'numeric'},...
                           {'scalar','nonempty','nonnan','finite','nonnegative'});                    

        % Transmission_OnboardTransformerEfficiency_pc
        validateattributes(SCENARIO.Transmission.('Transmission_Parameters').Transmission_OnboardTransformerEfficiency_pc(r),...
                           {'numeric'},...
                           {'scalar','nonempty','nonnan','finite','positive','<=', 100});  

        % Transmission_ShoreTransformerNoLoadLosses_W
        validateattributes(SCENARIO.Transmission.('Transmission_Parameters').Transmission_ShoreTransformerNoLoadLosses_W(r),...
                           {'numeric'},...
                           {'scalar','nonempty','nonnan','finite','nonnegative'});                    

        % Transmission_ShoreTransformerEfficiency_pc
        validateattributes(SCENARIO.Transmission.('Transmission_Parameters').Transmission_ShoreTransformerEfficiency_pc(r),...
                           {'numeric'},...
                           {'scalar','nonempty','nonnan','finite','positive','<=', 100});                 

        % Transmission_OnboardSwitchgearEfficiency_pc
        validateattributes(SCENARIO.Transmission.('Transmission_Parameters').Transmission_OnboardSwitchgearEfficiency_pc(r),...
                           {'numeric'},...
                           {'scalar','nonempty','nonnan','finite','positive','<=', 100});      

        % Transmission_ShoreSwitchgearEfficiency_pc  
        validateattributes(SCENARIO.Transmission.('Transmission_Parameters').Transmission_ShoreSwitchgearEfficiency_pc(r),...
                           {'numeric'},...
                           {'scalar','nonempty','nonnan','finite','positive','<=', 100});  

        % Transmission_PowerFactor_pc
        validateattributes(SCENARIO.Transmission.('Transmission_Parameters').Transmission_PowerFactor_pc(r),...
                           {'numeric'},...
                           {'scalar','nonempty','nonnan','finite','positive','<=', 200});    
    end 

    %% Transmission_Costs
    if size(SCENARIO.Transmission.('Transmission_Costs').Devices_Name,1)... % Number of inputs check.
    ~= size(SCENARIO.Devices.Devices_TurbineArrangement.Devices_Name,1)
        error('Inconsistent number of Devices specified - check "Transmission_Costs" sheet in "U7_Transmission.xlsx".');
    end

    if ~all(ismember(unique(SCENARIO.Transmission.('Transmission_Costs').Devices_Name),...   % Consistent text check.
                    SCENARIO.Devices.Devices_TurbineArrangement.Devices_Name))
        error('Inconsistent Devices names specified - check "Transmission_Costs" sheet in "U7_Transmission.xlsx".');
    end

    for r = 1:size(SCENARIO.Transmission.('Transmission_Costs').Devices_Name,1)
        % Devices_Name
        if isvarname(SCENARIO.Transmission.('Transmission_Costs').Devices_Name{r}) ~= 1
            error('Invalid variable name/table header. Expected entries must be composed of upper/lower case alphanumeric characters, and may contain the underscore symbol (_). Other symbol and special characters are not permitted.');  
        end

        % Tranmission_ExportCableCost_CCCpm
        validateattributes(SCENARIO.Transmission.('Transmission_Costs').Tranmission_ExportCableCost_CCCpm(r),...
                           {'numeric'},...
                           {'scalar','nonempty','nonnan','finite','nonnegative'});    
        % Transmission_OnboardTransformerCost_CCC
        validateattributes(SCENARIO.Transmission.('Transmission_Costs').Transmission_OnboardTransformerCost_CCC(r),...
                           {'numeric'},...
                           {'scalar','nonempty','nonnan','finite','nonnegative'});   

        % Transmission_ShoreTransformerCost_CCC
        validateattributes(SCENARIO.Transmission.('Transmission_Costs').Transmission_ShoreTransformerCost_CCC(r),...
                           {'numeric'},...
                           {'scalar','nonempty','nonnan','finite','nonnegative'});                  

        % Transmission_OnboardSwitchgearCost_CCC
        validateattributes(SCENARIO.Transmission.('Transmission_Costs').Transmission_OnboardSwitchgearCost_CCC(r),...
                           {'numeric'},...
                           {'scalar','nonempty','nonnan','finite','nonnegative'});                      

        % Transmission_ShoreSwitchgearCost_CCC
        validateattributes(SCENARIO.Transmission.('Transmission_Costs').Transmission_ShoreSwitchgearCost_CCC(r),...
                           {'numeric'},...
                           {'scalar','nonempty','nonnan','finite','nonnegative'});      

        % Transmission_ShoreSubStationInfrastructureCost_CCC
        validateattributes(SCENARIO.Transmission.('Transmission_Costs').Transmission_ShoreSubStationInfrastructureCost_CCC(r),...
                           {'numeric'},...
                           {'scalar','nonempty','nonnan','finite','nonnegative'});     
    end
    disp(' - "Transmission" input checks passed.');

    %% Project_Currency
    % Project Currency
    if size(SCENARIO.Project.('Project_Currency').Project_Currency,1) ~= 1 ...
    || isvarname(SCENARIO.Project.('Project_Currency').Project_Currency{1}) ~= 1 
        error('Invalid variable name/table header. Expected only 1 entry composed of upper/lower case alphanumeric characters, and may contain the underscore symbol (_). Other symbol and special characters are not permitted.');  
    end

    %% Project_Length
    for r = 1:size(SCENARIO.Project.('Project_Length').Project_Length_y,1)
        % Project_Length_y
        validateattributes(SCENARIO.Project.('Project_Length').Project_Length_y(r),...
                           {'numeric'},...
                           {'scalar','nonempty','nonnan','finite','integer','>=',1});  
    end

    %% Project_DiscountRate
    for r = 1:size(SCENARIO.Project.('Project_DiscountRate').Project_DiscountRate_pc,1)
        % Project_DiscountRate_pc
        validateattributes(SCENARIO.Project.('Project_DiscountRate').Project_DiscountRate_pc(r),...
                           {'numeric'},...
                           {'scalar','nonempty','nonnan','finite','nonnegative'});  
    end

    %% Project_ArraySize
    for r = 1:size(SCENARIO.Project.('Project_ArraySize').Project_ArraySize,1)
        % Project_ArraySize
        validateattributes(SCENARIO.Project.('Project_ArraySize').Project_ArraySize(r),...
                           {'numeric'},...
                           {'scalar','nonempty','nonnan','finite','integer','>=',1});  
    end
    disp(' - "Project" input checks passed.');
else
    error('"Region_SpatialRunFlag" or "Sites_DiscreteRunFlag" must be specified as 1, or no calculations will be run - check "Region_SpatialRunFlag" sheet in "U0_Region.xlsx" and "Sites_DiscreteRunFlag" sheet in "U1_Sites.xlsx".');
end

%% Finalise
disp(' % All user-defined "Scenario" input checks passed.');

end