function [YIELD] = less_yield_ideal(PATHFIND, METOCEAN, SCENARIO, SITES, DEVICES, IN)
%% Function Description
% Calculate Ideal Yield (Energy Generated) for Discrete Sites and/or
% Spatial Region for each Device.

%% Inputs Description
% PATHFIND

% METOCEAN

% SCENARIO

% SITES

% DEVICES

% IN

%% Outputs Description
% YIELD

%% DISCRETE Sites
if IN.RUN.DISCRETE
    disp('Calculating Ideal Energy Generated for DISCRETE Sites...'); 
    
    for s = 1:size(SITES,2)  
        disp([' - Calculating Ideal Energy Generated for "',char(string(SITES(s).Name)),'" site...']);
        Start = tic;                                                        % Start Timer.
        
        % Site Name
        YIELD.DISCRETE.IDEAL.GENERATED.SITES(s).Sites_Name = SITES(s).Name;
    
        % Power Law Exponent
        YIELD.DISCRETE.IDEAL.GENERATED.SITES(s).Flow_PowerLawExponent...
            = SCENARIO.Sites.Sites_FlowProfile.Flow_PowerLawExponent(s);
        
        % Shear Coefficient
        YIELD.DISCRETE.IDEAL.GENERATED.SITES(s).Flow_ShearCoefficient...
            = 1 / YIELD.DISCRETE.IDEAL.GENERATED.SITES(s).Flow_PowerLawExponent;

        % Bin Size
        YIELD.DISCRETE.IDEAL.GENERATED.SITES(s).Flow_BinSize_m...
            = SCENARIO.Sites.Sites_FlowProfile.Flow_BinSize_m(s);
        
        % Surface Flow Velocity (Temporary Variable)
        Flow_Vel_Abs_Surf_ms...
            = less_grid_surfvel(round2(METOCEAN.DISCRETE.(SITES(s).Name).Depth_m,YIELD.DISCRETE.IDEAL.GENERATED.SITES(s).Flow_BinSize_m),...
                                YIELD.DISCRETE.IDEAL.GENERATED.SITES(s).Flow_BinSize_m,...
                                METOCEAN.DISCRETE.(SITES(s).Name).Flow_Vel_Abs_DepAv_ms,...
                                YIELD.DISCRETE.IDEAL.GENERATED.SITES(s).Flow_ShearCoefficient);
        
        % Surface Flow Velocity TimeTable
        YIELD.DISCRETE.IDEAL.GENERATED.SITES(s).Flow_Vel_Abs_Surf_ms...
            = timetable(METOCEAN.DISCRETE.(SITES(s).Name).DateTime_UTC,...
                        single(Flow_Vel_Abs_Surf_ms),...
                        'VariableNames',{'Flow_Vel_Abs_Surf_ms'});
                    
        clearvars Flow_Vel_Abs_Surf_ms;
                    
        %% Calculate Power-Weighted Average & Power Generated Per Device
        for d = 1:size(DEVICES,2)                                           % For each Device... 
            disp(['     - Calculating PWA Flow Velocity & Ideal Power Generated per "',DEVICES(d).Name,'" Device...']);
            
            % Device Name
            YIELD.DISCRETE.IDEAL.GENERATED.SITES(s).DEVICES(d).Devices_Name...
                = DEVICES(d).Name;

            % Turbine Diameter
            YIELD.DISCRETE.IDEAL.GENERATED.SITES(s).DEVICES(d).Turbines_Diameter_m...
                = DEVICES(d).Turbines_Diameter_m;  

            % Swept Area
            YIELD.DISCRETE.IDEAL.GENERATED.SITES(s).DEVICES(d).Turbines_SweptArea_m2...
                = pi * (DEVICES(d).Turbines_Radius_m ^ 2);  

            % Boundary Type
            YIELD.DISCRETE.IDEAL.GENERATED.SITES(s).DEVICES(d).BoundaryType...
                = DEVICES(d).BoundaryType;

            % Hub to Boundary Distance            
            YIELD.DISCRETE.IDEAL.GENERATED.SITES(s).DEVICES(d).Hub2BoundaryDistance_m...
                = DEVICES(d).Hub2BoundaryDistance_m;

            % PWA Velocity (Temporary Variable)
            Flow_Vel_Abs_PWA_ms...
                = less_grid_pwa(round2(METOCEAN.DISCRETE.(SITES(s).Name).Depth_m,YIELD.DISCRETE.IDEAL.GENERATED.SITES(s).Flow_BinSize_m),...
                                YIELD.DISCRETE.IDEAL.GENERATED.SITES(s).Flow_BinSize_m,...
                                METOCEAN.DISCRETE.(SITES(s).Name).Flow_Vel_Abs_DepAv_ms,...
                                YIELD.DISCRETE.IDEAL.GENERATED.SITES(s).Flow_ShearCoefficient,...
                                DEVICES(d).BoundaryType,...
                                DEVICES(d).Hub2BoundaryDistance_m,...
                                DEVICES(d).Turbines_Radius_m); 
                             
            % PWA Flow Velocity TimeTable
            YIELD.DISCRETE.IDEAL.GENERATED.SITES(s).DEVICES(d).Flow_Vel_Abs_PWA_ms...
                = timetable(METOCEAN.DISCRETE.(SITES(s).Name).DateTime_UTC,...
                            single(Flow_Vel_Abs_PWA_ms),...
                            'VariableNames',{'Flow_Vel_Abs_PWA_ms'});
                        
            % Power Generated Per Device (Temporary)
            Power_Ideal_GenPerDevice_kW...
                = powergen(table2array(DEVICES(d).PowerPerformance),...
                           YIELD.DISCRETE.IDEAL.GENERATED.SITES(s).DEVICES(d).Flow_Vel_Abs_PWA_ms.Flow_Vel_Abs_PWA_ms);
            
            % PWA Device Specific Generation Limit                
            Power_Ideal_GenPerDevice_kW(Flow_Vel_Abs_PWA_ms > DEVICES(d).GenLimit_Flow_Vel_Abs_PWA_ms)...
                = 0;
           
            % Power Generated Per Device            
            YIELD.DISCRETE.IDEAL.GENERATED.SITES(s).DEVICES(d).Power_Ideal_GenPerDevice_kW...
                = timetable(METOCEAN.DISCRETE.(SITES(s).Name).DateTime_UTC,...
                     single(Power_Ideal_GenPerDevice_kW...
                            .* DEVICES(d).NumberTurbines ./ 1000),...
                            'VariableNames',{'Power_Generated_kW'}); 
            
            % Ideal Energy Generated Per Device
            YIELD.DISCRETE.IDEAL.GENERATED.SITES(s).DEVICES(d).Energy_Ideal_GenPerDevice_kWh...
                = double(sum(YIELD.DISCRETE.IDEAL.GENERATED.SITES(s).DEVICES(d).Power_Ideal_GenPerDevice_kW.Power_Generated_kW));
           
            % Clear temporary variables
            clearvars Flow_Vel_Abs_PWA_ms Power_Ideal_GenPerDevice_kW;
            
            %% Monthly Breakdown
            for m = 1:12                                                    % For each month...                 
                % Month Name
                YIELD.DISCRETE.IDEAL.GENERATED.SITES(s).DEVICES(d).Monthly(m).Month...
                    = monthnum2name(m,'Short');
                
                % PWA Flow Velocity
                YIELD.DISCRETE.IDEAL.GENERATED.SITES(s).DEVICES(d).Monthly(m).Flow_Vel_Abs_PWA_ms...
                    = YIELD.DISCRETE.IDEAL.GENERATED.SITES(s).DEVICES(d).Flow_Vel_Abs_PWA_ms(month(METOCEAN.DISCRETE.(SITES(s).Name).DateTime_UTC) == m,:);                
                
                % Monthly Ideal Power Generated Per Device
                YIELD.DISCRETE.IDEAL.GENERATED.SITES(s).DEVICES(d).Monthly(m).Power_Ideal_GenPerDevice_kW...
                    = YIELD.DISCRETE.IDEAL.GENERATED.SITES(s).DEVICES(d).Power_Ideal_GenPerDevice_kW(month(METOCEAN.DISCRETE.(SITES(s).Name).DateTime_UTC) == m,:);
                
                % Monthly Ideal Energy Generated Per Device
                YIELD.DISCRETE.IDEAL.GENERATED.SITES(s).DEVICES(d).Monthly(m).Energy_Ideal_GenPerDevice_kWh...
                    = double(sum(YIELD.DISCRETE.IDEAL.GENERATED.SITES(s).DEVICES(d).Monthly(m).Power_Ideal_GenPerDevice_kW.Power_Generated_kW));
           
            end
            
        end  
        
        % Finalise Section 
        Stop = toc(Start); 
        disp([' - Time Elapsed: ',num2str(round2(Stop/60,0.01)),' minutes.']); 
        
    end
    
    % Finalise Section
    disp(' % Ideal Energy Generated for DISCRETE Sites calculated successfully.'); 

end

%% SPATIAL Region
if IN.RUN.SPATIAL
    disp('Calculating Ideal Energy Generated for SPATIAL Region...');
    delete(gcp('nocreate')); PP = parpool(feature('numcores'));             % Start the Parallel computing Pool. 
    disp(' - Preallocating memory for the population of large arrays...'); 

    % Power Law Exponent
    YIELD.SPATIAL.IDEAL.GENERATED.Flow_PowerLawExponent...
        = SCENARIO.Region.Region_FlowProfile.Flow_PowerLawExponent(1);
    
    % Shear Coefficient
    YIELD.SPATIAL.IDEAL.GENERATED.Flow_ShearCoefficient...
        = 1 / YIELD.SPATIAL.IDEAL.GENERATED.Flow_PowerLawExponent;
    
    % Shear Coefficient (Parallel Workers)
    Flow_ShearCoefficient...                                               
        = YIELD.SPATIAL.IDEAL.GENERATED.Flow_ShearCoefficient;      
    
    % Bin Size
    YIELD.SPATIAL.IDEAL.GENERATED.Flow_BinSize_m...
        = SCENARIO.Region.Region_FlowProfile.Flow_BinSize_m(1);  
    
    % Bin Size (Parallel Workers)
    Flow_BinSize_m = YIELD.SPATIAL.IDEAL.GENERATED.Flow_BinSize_m;
    
    % Water/Land Condition (Parallel Workers)
    ValidChartDatumDepth_Binary...
        = logical(~PATHFIND.MAPS.BinaryMobilityMap); 
    
    % Rounded Depth (Parallel Workers)
    Depth_Rounded2Bin_m...
        = round2(METOCEAN.SPATIAL.Depth_m,...
                 SCENARIO.Region.Region_FlowProfile.Flow_BinSize_m(1));
                   
    % Absolute Flow Velocity (Parallel Workers)
    Flow_Vel_Abs_DepAv_ms = METOCEAN.SPATIAL.Flow_Vel_Abs_DepAv_ms;         % Call temporary arrays to be called into the parfor loop.
    
    % Surface Flow Velocity Temp Array (Parallel Workers)
    Flow_Vel_Abs_Surf_ms = Flow_Vel_Abs_DepAv_ms;                           % Populate array with temporary values.
    Flow_Vel_Abs_Surf_ms(~isnan(Flow_Vel_Abs_Surf_ms)) = 0;                 % Replace non-NaNs with zeros.             
        
    %% Calculate Surface Velocity 
    disp(' - Calculating Surface Flow Velocity at every grid point (this may take some time)...'); 
    Start = tic; b = waitbar(0,'1','Name','Evaluating row number...');      % Start timer. 
    
    for x = 1:size(Flow_Vel_Abs_Surf_ms,2)                                  % For each row...
        waitbar(x/size(Flow_Vel_Abs_Surf_ms,2), b, sprintf('%5.0f',x));
        parfor y = 1:size(Flow_Vel_Abs_Surf_ms,3)                           % For each column...
            if ValidChartDatumDepth_Binary(x,y)                             % If the grid point is water...
                % Surface Flow Velocity (Temporary)
                Flow_Vel_Abs_Surf_ms(:,x,y)...
                    = less_grid_surfvel(Depth_Rounded2Bin_m(:,x,y),...
                                        Flow_BinSize_m,...
                                        Flow_Vel_Abs_DepAv_ms(:,x,y),...
                                        Flow_ShearCoefficient);
            end
        end
    end   
        
    Stop = toc(Start); close(b);
    disp([' - Time Elapsed: ',num2str(round2(Stop/60,0.01)),' minutes.']); 
    
    % Store Output Variable in Structure
    YIELD.SPATIAL.IDEAL.GENERATED.Flow_Vel_Abs_Surf_ms...
        = Flow_Vel_Abs_Surf_ms;
    
    clearvars Flow_Vel_Abs_Surf_ms;
    
    %% Calculate Power-Weighted Average & Power Generated Per Device
    for d = 1:size(DEVICES,2)                                               % For each Device...
        % Device Name
        YIELD.SPATIAL.IDEAL.GENERATED.DEVICES(d).Devices_Name...
            = DEVICES(d).Name;
        
        % Fails Minimum Depth Condition
        ValidDeviceMinDepth_Binary...                           
            = ~squeeze(any(Depth_Rounded2Bin_m < DEVICES(d).MinWaterDepth_m,1));
           
        % Fails Maximum Depth Condition
        ValidDeviceMaxDepth_Binary...                           
            = ~squeeze(any(Depth_Rounded2Bin_m > DEVICES(d).MaxWaterDepth_m,1));      
        
        % Valid Deployment Location
        YIELD.SPATIAL.IDEAL.GENERATED.DEVICES(d).ValidDeviceDeployment_Binary...       
            = ValidChartDatumDepth_Binary...                                % Valid grid point if: Always water.
            & ValidDeviceMaxDepth_Binary...                                 % Always above the device minimum depth requirement.
            & ValidDeviceMinDepth_Binary;                                   % Always below the device maximum depth threshold.
        
        clearvars ValidDeviceMinDepth_Binary ValidDeviceMaxDepth_Binary;
        
        % Device Name 
        YIELD.SPATIAL.IDEAL.GENERATED.DEVICES(d).Devices_Name = DEVICES(d).Name;  
        
        % Turbine Diameter
        YIELD.SPATIAL.IDEAL.GENERATED.DEVICES(d).Turbines_Diameter_m...
            = DEVICES(d).Turbines_Diameter_m;
        
        % Swept Area
        YIELD.SPATIAL.IDEAL.GENERATED.DEVICES(d).Turbines_SweptArea_m2...
            = pi * (DEVICES(d).Turbines_Radius_m ^ 2); 
        
        % Boundary Type
        YIELD.SPATIAL.IDEAL.GENERATED.DEVICES(d).BoundaryType...
            = DEVICES(d).BoundaryType;
        
        % Hub to Boundary Distance 
        YIELD.SPATIAL.IDEAL.GENERATED.DEVICES(d).Hub2BoundaryDistance_m...
            = DEVICES(d).Hub2BoundaryDistance_m;
        
        % PWA Flow Velocity (Parallel Workers)  
        Flow_Vel_Abs_PWA_ms = METOCEAN.SPATIAL.Flow_Vel_Abs_DepAv_ms;       % Populate array with temporary values.
        Flow_Vel_Abs_PWA_ms(~isnan(Flow_Vel_Abs_PWA_ms)) = 0;               % Replace non-NaNs with zeros.    
        
        % Power Generated per Device (Parallel Workers)
        Power_Ideal_GenPerDevice_kW...
            = single(zeros(size(METOCEAN.SPATIAL.Flow_Vel_Abs_DepAv_ms)));

        % Deployment (Parallel Workers)
        ValidDeviceDeployment_Binary...
            = YIELD.SPATIAL.IDEAL.GENERATED.DEVICES(d).ValidDeviceDeployment_Binary;
        
        % Boundary Type (Parallel Workers)
        BoundaryType = DEVICES(d).BoundaryType;
        
        % Boundary Distance (Parallel Workers)
        Hub2BoundaryDistance_m = DEVICES(d).Hub2BoundaryDistance_m;
        
        % Turbine Radius (Parallel Workers)
        Turbines_Radius_m = DEVICES(d).Turbines_Radius_m;
        
        % Power Performance (Parallel Workers) 
        PowerPerformance = DEVICES(d).PowerPerformance;
        
        % NumberTurbines (Parallel Workers)
        NumberTurbines = DEVICES(d).NumberTurbines;
        
        %% Calculate Power-Weighted Average & Power Generated Per Device
        disp([' - Calculating PWA Flow Velocity & Ideal Power Generated per "',DEVICES(d).Name,'" Device. at every grid point (this may take some time)...']); 
        Start = tic; b = waitbar(0,'1','Name','Evaluating row number...');  % Start timer. 

        for x = 1:size(Flow_Vel_Abs_PWA_ms,2)                               % For each row...
            waitbar(x/size(Flow_Vel_Abs_PWA_ms,2), b, sprintf('%5.0f',x));
            parfor y = 1:size(Flow_Vel_Abs_PWA_ms,3)                        % Start the Parallel computing pool. For each column...
                if ValidChartDatumDepth_Binary(x,y)...                      % If the grid point is water...
                && ValidDeviceDeployment_Binary(x,y)                        % If the grid point is Device specific acceptable deployment location...
                   % PWA Flow Velocity (Temporary)
                   Flow_Vel_Abs_PWA_ms(:,x,y)...
                       = less_grid_pwa(Depth_Rounded2Bin_m(:,x,y),...
                                       Flow_BinSize_m,...
                                       Flow_Vel_Abs_DepAv_ms(:,x,y),...
                                       Flow_ShearCoefficient,...
                                       BoundaryType,...
                                       Hub2BoundaryDistance_m,...
                                       Turbines_Radius_m);

                    % Power Generated Per Device (Temporary) 
                    Power_Ideal_GenPerDevice_kW(:,x,y)...
                        = (powergen(table2array(PowerPerformance),...
                                    Flow_Vel_Abs_PWA_ms(:,x,y)))...
                            .* NumberTurbines ./ 1000;  
                end
            end
        end   
        
        Stop = toc(Start); close(b);
        disp([' - Time Elapsed: ',num2str(round2(Stop/60,0.01)),' minutes.']); 
        
        %% Store Output Variables in Structure
        % PWA Flow Velocity
        YIELD.SPATIAL.IDEAL.GENERATED.DEVICES(d).Flow_Vel_Abs_PWA_ms...
            = Flow_Vel_Abs_PWA_ms;
       
        % Power Generated per Device
        YIELD.SPATIAL.IDEAL.GENERATED.DEVICES(d).Power_Ideal_GenPerDevice_kW...
            = single(Power_Ideal_GenPerDevice_kW);
        
        % PWA Device Specific Generation Limit
        YIELD.SPATIAL.IDEAL.GENERATED.DEVICES(d).Power_Ideal_GenPerDevice_kW...
            (Flow_Vel_Abs_PWA_ms > DEVICES(d).GenLimit_Flow_Vel_Abs_PWA_ms)...
                = 0;
        
        % Ideal Energy Generated per Device        
        YIELD.SPATIAL.IDEAL.GENERATED.DEVICES(d).Energy_Ideal_GenPerDevice_kWh...
            = single(squeeze(sum(YIELD.SPATIAL.IDEAL.GENERATED.DEVICES(d).Power_Ideal_GenPerDevice_kW,1))); 
        
        YIELD.SPATIAL.IDEAL.GENERATED.DEVICES(d).Energy_Ideal_GenPerDevice_kWh...
            (~ValidChartDatumDepth_Binary) = NaN;
        
        %% Monthly Breakdown
        for m = 1:12                                                        % For each month...                 
            % Month Name
            YIELD.SPATIAL.IDEAL.GENERATED.DEVICES(d).Monthly(m).Month...
                = monthnum2name(m,'Short');             

            % Monthly Ideal Power Generated Per Device
            YIELD.SPATIAL.IDEAL.GENERATED.DEVICES(d).Monthly(m).Power_Ideal_GenPerDevice_kW...
                = YIELD.SPATIAL.IDEAL.GENERATED.DEVICES(d).Power_Ideal_GenPerDevice_kW(month(METOCEAN.SPATIAL.DateTime_UTC) == m,:,:);

            % Monthly Ideal Energy Generated Per Device
            YIELD.SPATIAL.IDEAL.GENERATED.DEVICES(d).Monthly(m).Energy_Ideal_GenPerDevice_kWh...
                = single(squeeze(sum(YIELD.SPATIAL.IDEAL.GENERATED.DEVICES(d).Power_Ideal_GenPerDevice_kW,1)));
            
            YIELD.SPATIAL.IDEAL.GENERATED.DEVICES(d).Monthly(m).Energy_Ideal_GenPerDevice_kWh...
                (~ValidChartDatumDepth_Binary) = NaN;

        end  
        
    end
    
    % Finalise Section
    delete(PP);                                                             % Delete the Parallel Pool.
    disp(' % Ideal Energy Generated for SPATIAL region calculated successfully.'); 

end  

end
