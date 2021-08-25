function [OPERATIONS, YIELD] = less_operations(YIELD,...
                                               PATHFIND,...
                                               METOCEAN,...
                                               SITES,...
                                               DEVICES,...
                                               IN)
%% Function Description - less_operations - JAM 30/11/20
% This function estimates operational durations and standby hours based on
% Scenario data and metocean conditions.

%% Inputs Description
% YIELD
% PATHFIND
% METOCEAN
% SCENARIO
% SITES
% DEVICES
% IN

%% Outputs Description
% OPERATIONS
% YIELD

%% DISCRETE Sites
if IN.RUN.DISCRETE   
    disp('Calculating Metocean Induced Standby/Downtime for DISCRETE Sites...');
    for s = 1:size(SITES,2)                                                 % For each Site...    
        %% Daylight Hours
        disp([' - Calculating Daylight Hours available for Operations at "',SITES(s).Name,'" Site...']);
        
        % Site Name
        OPERATIONS.DISCRETE.SITES(s).Sites_Name = SITES(s).Name;
        
        % Daylight Hours
        [RiseSet,~,~,~,~,~]...
            = suncycle(SITES(s).Lat_dd, SITES(s).Lon_dd,...
                       datenum(METOCEAN.DISCRETE.(SITES(s).Name).DateTime_UTC));
                       
        LightHours = RiseSet(:,2) - RiseSet(:,1);
        LightHours(LightHours < 0) = LightHours(LightHours < 0) + 24;
        LightRatio = LightHours ./ 24;

        OPERATIONS.DISCRETE.SITES(s).DaylightHours...
            = timetable(METOCEAN.DISCRETE.(SITES(s).Name).DateTime_UTC,...
                          LightHours,...
                          LightRatio,...
                          'VariableNames',{'Daylight_h','DaylightRatio'});
          
        % Clear temporary variables              
        clearvars RiseSet LightHours;            
        
        %% Waiting Time for Time On Site - Defined by Operations Limits              
        for d = 1:size(DEVICES,2)                                           % For each Device...
            disp([' - Calculating Metocean Induced Standby/Downtime for "',DEVICES(d).Name,'" Device...']);
            Start = tic;
            
            % Device Name
            OPERATIONS.DISCRETE.SITES(s).DEVICES(d).Devices_Name...
                = DEVICES(d).Name;

            for o = 1:size(DEVICES(d).OPERATIONS,2)                         % For each Operation...
                disp(['   - Evaluating "',DEVICES(d).OPERATIONS(o).Name,'" Operation Limits...']);

                % Operations Name
                OPERATIONS.DISCRETE.SITES(s).DEVICES(d).OPERATIONS(o).Operations_Name...
                    = DEVICES(d).OPERATIONS(o).Name;  

                % Operations On Site Duration
                OPERATIONS.DISCRETE.SITES(s).DEVICES(d).OPERATIONS(o).Operations_OnSiteDuration_h...
                    = DEVICES(d).OPERATIONS(o).OnSiteDuration_h;
                
                % Operations Metocean Limits
                OPERATIONS.DISCRETE.SITES(s).DEVICES(d).OPERATIONS(o).OperationsLimit_Flow_Vel_Abs_Surf_ms...
                    = DEVICES(d).OPERATIONS(o).OpsLimit_Flow_Vel_Abs_Surf_ms;
                
                OPERATIONS.DISCRETE.SITES(s).DEVICES(d).OPERATIONS(o).OperationsLimit_Wave_Hs_m...
                    = DEVICES(d).OPERATIONS(o).OpsLimit_Wave_Hs_m; 
            
                for m = 1:12                                                % For each month...
                    % Calculate Monthly Neap Access Periods for Time On Site according to Operations Limits (Flow)         
                    [OPERATIONS.DISCRETE.SITES(s).DEVICES(d).OPERATIONS(o).OperationLimitedTimeOnSite.NeapAccess(m),~,~]...
                        = neapaccess(METOCEAN.DISCRETE.(SITES(s).Name).DateTime_UTC(month(METOCEAN.DISCRETE.(SITES(s).Name).DateTime_UTC) == m),...
                                     YIELD.DISCRETE.IDEAL.GENERATED.SITES(s).Flow_Vel_Abs_Surf_ms.Flow_Vel_Abs_Surf_ms(month(METOCEAN.DISCRETE.(SITES(s).Name).DateTime_UTC) == m),...
                                     LightRatio(month(METOCEAN.DISCRETE.(SITES(s).Name).DateTime_UTC) == m),...
                                     14,...
                                     7,...
                                     DEVICES(d).OPERATIONS(o).OpsLimit_Flow_Vel_Abs_Surf_ms,...
                                     DEVICES(d).OPERATIONS(o).OnSiteDuration_h);  
                      
                    % Probability of Exceedance for Operations Limits (Wave)
                    [OPERATIONS.DISCRETE.SITES(s).DEVICES(d).OPERATIONS(o).OperationLimitedTimeOnSite.ProbExceedance(m),~,~]...
                        = eprob(METOCEAN.DISCRETE.(SITES(s).Name).Wave_Hs_m(month(METOCEAN.DISCRETE.(SITES(s).Name).DateTime_UTC) == m),...
                                DEVICES(d).OPERATIONS(o).OpsLimit_Wave_Hs_m);
                                          
                    % Calculate Monthly Weibull Probability of Persistence of Time On Site according to Operations Limits (Wave)  
                    [OPERATIONS.DISCRETE.SITES(s).DEVICES(d).OPERATIONS(o).OperationLimitedTimeOnSite.WeibullPersistence(m),~,~]...
                        = weibullprobpersistence(OPERATIONS.DISCRETE.SITES(s).DEVICES(d).OPERATIONS(o).OperationLimitedTimeOnSite.ProbExceedance(m).SortedData,...
                                                 OPERATIONS.DISCRETE.SITES(s).DEVICES(d).OPERATIONS(o).OperationLimitedTimeOnSite.ProbExceedance(m).ProbExc,...
                                                 DEVICES(d).OPERATIONS(o).OpsLimit_Wave_Hs_m,...
                                          (24 .* OPERATIONS.DISCRETE.SITES(s).DEVICES(d).OPERATIONS(o).OperationLimitedTimeOnSite.NeapAccess(m).NumberDaysRequiredOnSite));
                                      
                end
                
                % Assign Month Names & Reorder
                for m = 1:12
                    OPERATIONS.DISCRETE.SITES(s).DEVICES(d).OPERATIONS(o).OperationLimitedTimeOnSite.ProbExceedance(m).Month...
                        = monthnum2name(m,'Short');
                
                     OPERATIONS.DISCRETE.SITES(s).DEVICES(d).OPERATIONS(o).OperationLimitedTimeOnSite.WeibullPersistence(m).Month...
                        = monthnum2name(m,'Short');
                    
                end
                
                OPERATIONS.DISCRETE.SITES(s).DEVICES(d).OPERATIONS(o).OperationLimitedTimeOnSite.ProbExceedance...
                    = orderfields(OPERATIONS.DISCRETE.SITES(s).DEVICES(d).OPERATIONS(o).OperationLimitedTimeOnSite.ProbExceedance,...
                                  [size(fieldnames(OPERATIONS.DISCRETE.SITES(s).DEVICES(d).OPERATIONS(o).OperationLimitedTimeOnSite.ProbExceedance),1),...
                                   1:(size(fieldnames(OPERATIONS.DISCRETE.SITES(s).DEVICES(d).OPERATIONS(o).OperationLimitedTimeOnSite.ProbExceedance),1)-1)]);
                
                OPERATIONS.DISCRETE.SITES(s).DEVICES(d).OPERATIONS(o).OperationLimitedTimeOnSite.WeibullPersistence...
                    = orderfields(OPERATIONS.DISCRETE.SITES(s).DEVICES(d).OPERATIONS(o).OperationLimitedTimeOnSite.WeibullPersistence,...
                                  [size(fieldnames(OPERATIONS.DISCRETE.SITES(s).DEVICES(d).OPERATIONS(o).OperationLimitedTimeOnSite.WeibullPersistence),1),...
                                   1:(size(fieldnames(OPERATIONS.DISCRETE.SITES(s).DEVICES(d).OPERATIONS(o).OperationLimitedTimeOnSite.WeibullPersistence),1)-1)]);                

                %% Waiting Time for Transit - Defined by Vessels Limits                     
                for v = 1:size(DEVICES(d).OPERATIONS(o).VESSELS,2)          % For each Vessel...  
                    disp(['     - Applying "',DEVICES(d).OPERATIONS(o).VESSELS(v).Name,'" Vessel Limits...']);
                    % Vessel Name
                    OPERATIONS.DISCRETE.SITES(s).DEVICES(d).OPERATIONS(o).VESSELS(v).Vessels_Name...
                        = DEVICES(d).OPERATIONS(o).VESSELS(v).Name;

                    % Vessel Suitability for Operation
                    OPERATIONS.DISCRETE.SITES(s).DEVICES(d).OPERATIONS(o).VESSELS(v).Suitability4Operation...
                        = DEVICES(d).OPERATIONS(o).VESSELS(v).Suitability4Operation;  
                    
                    if strcmp(DEVICES(d).OPERATIONS(o).VESSELS(v).Suitability4Operation,'Yes')
                        % Vessel Working Limits
                        OPERATIONS.DISCRETE.SITES(s).DEVICES(d).OPERATIONS(o).VESSELS(v).VesselLimitedTransitTime.VesselLimits_Flow_Vel_Abs_Surf_ms...
                            = DEVICES(d).OPERATIONS(o).VESSELS(v).WorkingLimits_Flow_Vel_Abs_Surf_ms;                

                        OPERATIONS.DISCRETE.SITES(s).DEVICES(d).OPERATIONS(o).VESSELS(v).VesselLimitedTransitTime.VesselLimits_Wave_Hs_m...
                            = DEVICES(d).OPERATIONS(o).VESSELS(v).WorkingLimits_Wave_Hs_m;    
                        
                        % Vessel Transit Speed
                        OPERATIONS.DISCRETE.SITES(s).DEVICES(d).OPERATIONS(o).VESSELS(v).VesselLimitedTransitTime.TransitSpeed_ms...
                            = DEVICES(d).OPERATIONS(o).VESSELS(v).Transit_Speed_ms;
                        
                        if IN.RUN.SPATIAL
                            % Nearest Suitable Port
                            OPERATIONS.DISCRETE.SITES(s).DEVICES(d).OPERATIONS(o).VESSELS(v).VesselLimitedTransitTime.NearestSuitablePort...
                                = PATHFIND.DISCRETE.SITES(s).VESSELS(v).NearestSuitableValidPort_AStar;
                            
                            % Transit Distance
                            OPERATIONS.DISCRETE.SITES(s).DEVICES(d).OPERATIONS(o).VESSELS(v).VesselLimitedTransitTime.TransitDistance_m...
                                = PATHFIND.DISCRETE.SITES(s).VESSELS(v).Path2SuitableValidPort_AStarDistance_m;
                        
                        else
                            % Nearest Suitable Port
                            OPERATIONS.DISCRETE.SITES(s).DEVICES(d).OPERATIONS(o).VESSELS(v).VesselLimitedTransitTime.NearestSuitablePort...
                                = PATHFIND.DISCRETE.SITES(s).VESSELS(v).NearestSuitableValidPort_Euclid;
                            
                            % Transit Distance
                            OPERATIONS.DISCRETE.SITES(s).DEVICES(d).OPERATIONS(o).VESSELS(v).VesselLimitedTransitTime.TransitDistance_m...
                                = PATHFIND.DISCRETE.SITES(s).VESSELS(v).Path2SuitableValidPort_EuclidDistance_m;
                        
                        end
                        
                        % Transit Time (Out & Back)
                        OPERATIONS.DISCRETE.SITES(s).DEVICES(d).OPERATIONS(o).VESSELS(v).VesselLimitedTransitTime.TotalTransitTime_h...
                            = (OPERATIONS.DISCRETE.SITES(s).DEVICES(d).OPERATIONS(o).VESSELS(v).VesselLimitedTransitTime.TransitDistance_m...
                            ./ DEVICES(d).OPERATIONS(o).VESSELS(v).Transit_Speed_ms) .* 2 ...
                            ./ 60 ./ 60;
                        
                        %% For DISCRETE Calculation, it is assumed that the Site conditions are representative of the Transit path (since no data along the path to port is available)
                        for m = 1:12                                        % For each month...
                            % Probability of Exceedance for Vessels Limits (Wave)
                            [OPERATIONS.DISCRETE.SITES(s).DEVICES(d).OPERATIONS(o).VESSELS(v).VesselLimitedTransitTime.ProbExceedance(m),~,~]...
                                = eprob(METOCEAN.DISCRETE.(SITES(s).Name).Wave_Hs_m(month(METOCEAN.DISCRETE.(SITES(s).Name).DateTime_UTC) == m),...
                                        DEVICES(d).OPERATIONS(o).VESSELS(v).WorkingLimits_Wave_Hs_m);
                            
                            % Calculate Monthly Weibull Probability of Persistence of Transit Time + Operations Time according to Vessels Limits (Wave)  
                            OPERATIONS.DISCRETE.SITES(s).DEVICES(d).OPERATIONS(o).VESSELS(v).VesselLimitedTransitTime.WeibullPersistence(m)...
                                = weibullprobpersistence(OPERATIONS.DISCRETE.SITES(s).DEVICES(d).OPERATIONS(o).VESSELS(v).VesselLimitedTransitTime.ProbExceedance(m).SortedData,...
                                                         OPERATIONS.DISCRETE.SITES(s).DEVICES(d).OPERATIONS(o).VESSELS(v).VesselLimitedTransitTime.ProbExceedance(m).ProbExc,...
                                                         DEVICES(d).OPERATIONS(o).VESSELS(v).WorkingLimits_Wave_Hs_m,...
                                                        (DEVICES(d).OPERATIONS(o).OnSiteDuration_h + (OPERATIONS.DISCRETE.SITES(s).DEVICES(d).OPERATIONS(o).VESSELS(v).VesselLimitedTransitTime.TotalTransitTime_h)));

                        end
                        
                        % Assign Month Names and Reorder
                        for m = 1:12
                            OPERATIONS.DISCRETE.SITES(s).DEVICES(d).OPERATIONS(o).VESSELS(v).VesselLimitedTransitTime.ProbExceedance(m).Month...
                               = monthnum2name(m,'Short');

                            OPERATIONS.DISCRETE.SITES(s).DEVICES(d).OPERATIONS(o).VESSELS(v).VesselLimitedTransitTime.WeibullPersistence(m).Month...
                               = monthnum2name(m,'Short');

                        end

                        OPERATIONS.DISCRETE.SITES(s).DEVICES(d).OPERATIONS(o).VESSELS(v).VesselLimitedTransitTime.ProbExceedance...
                            = orderfields(OPERATIONS.DISCRETE.SITES(s).DEVICES(d).OPERATIONS(o).VESSELS(v).VesselLimitedTransitTime.ProbExceedance,...
                                          [size(fieldnames(OPERATIONS.DISCRETE.SITES(s).DEVICES(d).OPERATIONS(o).VESSELS(v).VesselLimitedTransitTime.ProbExceedance),1),...
                                           1:(size(fieldnames(OPERATIONS.DISCRETE.SITES(s).DEVICES(d).OPERATIONS(o).VESSELS(v).VesselLimitedTransitTime.ProbExceedance),1)-1)]);

                        OPERATIONS.DISCRETE.SITES(s).DEVICES(d).OPERATIONS(o).VESSELS(v).VesselLimitedTransitTime.WeibullPersistence...
                            = orderfields(OPERATIONS.DISCRETE.SITES(s).DEVICES(d).OPERATIONS(o).VESSELS(v).VesselLimitedTransitTime.WeibullPersistence,...
                                          [size(fieldnames(OPERATIONS.DISCRETE.SITES(s).DEVICES(d).OPERATIONS(o).VESSELS(v).VesselLimitedTransitTime.WeibullPersistence),1),...
                                           1:(size(fieldnames(OPERATIONS.DISCRETE.SITES(s).DEVICES(d).OPERATIONS(o).VESSELS(v).VesselLimitedTransitTime.WeibullPersistence),1)-1)]);   
                        
                    else
                        % Unsuitable Vessel Placeholders
                        OPERATIONS.DISCRETE.SITES(s).DEVICES(d).OPERATIONS(o).VESSELS(v).VesselLimitedTransitTime...
                            = 'VESSEL UNSUITABLE';
                        
                    end  
    
                    %% Total Standby Time
                    % Vessel Name
                    OPERATIONS.DISCRETE.SITES(s).DEVICES(d).OPERATIONS(o).VESSELS(v).Vessels_Name...
                        = DEVICES(d).OPERATIONS(o).VESSELS(v).Name; 
                    
                    % Vessel Suitability for Operation
                    OPERATIONS.DISCRETE.SITES(s).DEVICES(d).OPERATIONS(o).VESSELS(v).Suitability4Operation...
                        = DEVICES(d).OPERATIONS(o).VESSELS(v).Suitability4Operation;  
                    
                    if strcmp(DEVICES(d).OPERATIONS(o).VESSELS(v).Suitability4Operation,'Yes')
                        for m = 1:12
                            % Month
                            OPERATIONS.DISCRETE.SITES(s).DEVICES(d).OPERATIONS(o).VESSELS(v).TotalStandbyTime(m).Month...
                                = monthnum2name(m,'Short');

                            % Days Required On Site for Operation Completion (Not including Standby time)
                            OPERATIONS.DISCRETE.SITES(s).DEVICES(d).OPERATIONS(o).VESSELS(v).TotalStandbyTime(m).OperationDuration_D...
                                = OPERATIONS.DISCRETE.SITES(s).DEVICES(d).OPERATIONS(o).OperationLimitedTimeOnSite.NeapAccess(m).NumberDaysRequiredOnSite;

                            % Standby Days Between Neap Access Period (Defined by Operations Flow Limitations)
                            OPERATIONS.DISCRETE.SITES(s).DEVICES(d).OPERATIONS(o).VESSELS(v).TotalStandbyTime(m).StandbyBetweenNeapAccessPeriods_D...
                                = OPERATIONS.DISCRETE.SITES(s).DEVICES(d).OPERATIONS(o).OperationLimitedTimeOnSite.NeapAccess(m).NumberStandbyDaysBetweenAccessPeriods;

                            % Standby Time Waiting for Weather Windows to Occur During Neap Access Periods (Defined by Operations Wave Limitations)
                            OPERATIONS.DISCRETE.SITES(s).DEVICES(d).OPERATIONS(o).VESSELS(v).TotalStandbyTime(m).StandbyWaitingForOnSiteWeatherWindows_h...
                                = (OPERATIONS.DISCRETE.SITES(s).DEVICES(d).OPERATIONS(o).OperationLimitedTimeOnSite.WeibullPersistence(m).Nwa_NumberHoursWaitingForAccess);
                            
                            OPERATIONS.DISCRETE.SITES(s).DEVICES(d).OPERATIONS(o).VESSELS(v).TotalStandbyTime(m).StandbyWaitingForOnSiteWeatherWindows_D...
                                = round2(OPERATIONS.DISCRETE.SITES(s).DEVICES(d).OPERATIONS(o).VESSELS(v).TotalStandbyTime(m).StandbyWaitingForOnSiteWeatherWindows_h ./ 24,1);
                            
                            % Standby Time Waiting for Weather Windows to Occur for Transit (Defined By Vessel, multiplied by number of days required)  
                            OPERATIONS.DISCRETE.SITES(s).DEVICES(d).OPERATIONS(o).VESSELS(v).TotalStandbyTime(m).StandbyWaitingForTransitWeatherWindows_h...
                                = (OPERATIONS.DISCRETE.SITES(s).DEVICES(d).OPERATIONS(o).VESSELS(v).VesselLimitedTransitTime.WeibullPersistence(m).Nwa_NumberHoursWaitingForAccess...
                               .* OPERATIONS.DISCRETE.SITES(s).DEVICES(d).OPERATIONS(o).VESSELS(v).TotalStandbyTime(m).OperationDuration_D);
                                  
                            OPERATIONS.DISCRETE.SITES(s).DEVICES(d).OPERATIONS(o).VESSELS(v).TotalStandbyTime(m).StandbyWaitingForTransitWeatherWindows_D...
                                = round2(OPERATIONS.DISCRETE.SITES(s).DEVICES(d).OPERATIONS(o).VESSELS(v).TotalStandbyTime(m).StandbyWaitingForTransitWeatherWindows_h ./ 24,1);
                                     
                            % Total Standby Time 
                            OPERATIONS.DISCRETE.SITES(s).DEVICES(d).OPERATIONS(o).VESSELS(v).TotalStandbyTime(m).TotalStandbyTime_h...
                                = ((24 .* OPERATIONS.DISCRETE.SITES(s).DEVICES(d).OPERATIONS(o).VESSELS(v).TotalStandbyTime(m).StandbyBetweenNeapAccessPeriods_D)...
                                + OPERATIONS.DISCRETE.SITES(s).DEVICES(d).OPERATIONS(o).VESSELS(v).TotalStandbyTime(m).StandbyWaitingForOnSiteWeatherWindows_h...
                                + OPERATIONS.DISCRETE.SITES(s).DEVICES(d).OPERATIONS(o).VESSELS(v).TotalStandbyTime(m).StandbyWaitingForTransitWeatherWindows_h);
                            
                            OPERATIONS.DISCRETE.SITES(s).DEVICES(d).OPERATIONS(o).VESSELS(v).TotalStandbyTime(m).TotalStandbyTime_h...
                                (OPERATIONS.DISCRETE.SITES(s).DEVICES(d).OPERATIONS(o).VESSELS(v).TotalStandbyTime(m).TotalStandbyTime_h > OPERATIONS.DISCRETE.SITES(s).DEVICES(d).OPERATIONS(o).OperationLimitedTimeOnSite.WeibullPersistence(m).D_TotalDuration_h)...
                                = OPERATIONS.DISCRETE.SITES(s).DEVICES(d).OPERATIONS(o).OperationLimitedTimeOnSite.WeibullPersistence(m).D_TotalDuration_h;
                            
                            OPERATIONS.DISCRETE.SITES(s).DEVICES(d).OPERATIONS(o).VESSELS(v).TotalStandbyTime(m).TotalStandbyTime_D...
                                = round2(OPERATIONS.DISCRETE.SITES(s).DEVICES(d).OPERATIONS(o).VESSELS(v).TotalStandbyTime(m).TotalStandbyTime_h ./ 24, 1);
                           
                        end
 
                    else
                        
                        OPERATIONS.DISCRETE.SITES(s).DEVICES(d).OPERATIONS(o).VESSELS(v).TotalStandbyTime...
                            = 'VESSEL UNSUITABLE';

                    end   
                end
            end
                    
            %% Actual Energy Delivered (Downtime due to Metocean Generation Limit Exceedance)
            disp('   - Calculating Actual Energy Delivered...');       
            
            % Site Name
            YIELD.DISCRETE.ACTUAL.DELIVERED.SITES(s).Sites_Name...
                = SITES(s).Name;
            
            % Devices Name
            YIELD.DISCRETE.ACTUAL.DELIVERED.SITES(s).DEVICES(d).Devices_Name...
                = DEVICES(d).Name;      
            
            % Metocean Generation Limit
            YIELD.DISCRETE.ACTUAL.DELIVERED.SITES(s).DEVICES(d).GenerationLimit.GenLimit_Wave_Hs_m...
                = DEVICES(d).GenLimit_Wave_Hs_m;
            
            % Annual Probability of Exceedance (Metocean Generation Limit)
            [~,~,YIELD.DISCRETE.ACTUAL.DELIVERED.SITES(s).DEVICES(d).GenerationLimit.GenLimit_AnnualProbExceedance]...
                = eprob(METOCEAN.DISCRETE.(SITES(s).Name).Wave_Hs_m,...
                        DEVICES(d).GenLimit_Wave_Hs_m);
                    
            % Annual Ideal Energy Delivered      
            YIELD.DISCRETE.ACTUAL.DELIVERED.SITES(s).DEVICES(d).GenerationLimit.Energy_Ideal_DelPerDevice_kWh...
                = YIELD.DISCRETE.IDEAL.DELIVERED.SITES(s).DEVICES(d).Energy_Ideal_DelPerDevice_kWh;
            
            % Annual Actual Energy Delivered (Metocean Generation Limit)
            YIELD.DISCRETE.ACTUAL.DELIVERED.SITES(s).DEVICES(d).GenerationLimit.Energy_GenLimit_DelPerDevice_kWh...
                = YIELD.DISCRETE.IDEAL.DELIVERED.SITES(s).DEVICES(d).Energy_Ideal_DelPerDevice_kWh...
               .* (1 - YIELD.DISCRETE.ACTUAL.DELIVERED.SITES(s).DEVICES(d).GenerationLimit.GenLimit_AnnualProbExceedance);  
                
            % Monthly Breakdown
            for m = 1:12                                                    % For each month...
                % Month Name
                YIELD.DISCRETE.ACTUAL.DELIVERED.SITES(s).DEVICES(d).GenerationLimit.Monthly(m).Month...
                    = monthnum2name(m,'Short');
                
                % Monthly Probability of Exceedance (Metocean Generation Limit)
                [~,~,YIELD.DISCRETE.ACTUAL.DELIVERED.SITES(s).DEVICES(d).GenerationLimit.Monthly(m).GenLimit_ProbExceedance]...
                    = eprob(METOCEAN.DISCRETE.(SITES(s).Name).Wave_Hs_m(month(METOCEAN.DISCRETE.(SITES(s).Name).DateTime_UTC) == m),...
                            DEVICES(d).GenLimit_Wave_Hs_m);

                % Monthly Ideal Energy Delivered
                YIELD.DISCRETE.ACTUAL.DELIVERED.SITES(s).DEVICES(d).GenerationLimit.Monthly(m).Energy_Ideal_DelPerDevice_kWh...
                    = YIELD.DISCRETE.IDEAL.DELIVERED.SITES(s).DEVICES(d).Monthly(m).Energy_Ideal_DelPerDevice_kWh;
                           
                % Monthly Metocean Generation Limited Energy Generated Per Device             
                YIELD.DISCRETE.ACTUAL.DELIVERED.SITES(s).DEVICES(d).GenerationLimit.Monthly(m).Energy_GenLimit_DelPerDevice_kWh...          
                    = YIELD.DISCRETE.IDEAL.DELIVERED.SITES(s).DEVICES(d).Monthly(m).Energy_Ideal_DelPerDevice_kWh...
                    .* (1 - YIELD.DISCRETE.ACTUAL.DELIVERED.SITES(s).DEVICES(d).GenerationLimit.Monthly(m).GenLimit_ProbExceedance);
                
            end
           
            %% Actual Energy Delivered (Loss of Generation Hours due to Standby Time)
            for o = 1:size(DEVICES(d).OPERATIONS,2)
                % Operations Name
                YIELD.DISCRETE.ACTUAL.DELIVERED.SITES(s).DEVICES(d).MetoceanStandby.OPERATIONS(o).Operations_Name...
                    = DEVICES(d).OPERATIONS(o).Name;  
                
                for v = 1:size(DEVICES(d).OPERATIONS(o).VESSELS,2)  
                    % Vessels Name
                    YIELD.DISCRETE.ACTUAL.DELIVERED.SITES(s).DEVICES(d).MetoceanStandby.OPERATIONS(o).VESSELS(v).Vessels_Name...
                        = DEVICES(d).OPERATIONS(o).VESSELS(v).Name; 
                    
                    % Vessels Suitability
                    YIELD.DISCRETE.ACTUAL.DELIVERED.SITES(s).DEVICES(d).MetoceanStandby.OPERATIONS(o).VESSELS(v).Suitability4Operation...
                        = DEVICES(d).OPERATIONS(o).VESSELS(v).Suitability4Operation;  
                    
                    if strcmp(DEVICES(d).OPERATIONS(o).VESSELS(v).Suitability4Operation,'Yes')
                        % Monthly Breakdown
                        for m = 1:12
                            % Month Name
                            YIELD.DISCRETE.ACTUAL.DELIVERED.SITES(s).DEVICES(d).MetoceanStandby.OPERATIONS(o).VESSELS(v).Monthly(m).Month...
                                = monthnum2name(m,'Short');
                            
                            % Monthly Ideal Energy Delivered
                            YIELD.DISCRETE.ACTUAL.DELIVERED.SITES(s).DEVICES(d).MetoceanStandby.OPERATIONS(o).VESSELS(v).Monthly(m).Energy_Ideal_DelPerDevice_kWh...
                                = YIELD.DISCRETE.IDEAL.DELIVERED.SITES(s).DEVICES(d).Monthly(m).Energy_Ideal_DelPerDevice_kWh;
                            
                            % Monthly Generation Time Lost to Metocean Impact on Operation Duration
                            YIELD.DISCRETE.ACTUAL.DELIVERED.SITES(s).DEVICES(d).MetoceanStandby.OPERATIONS(o).VESSELS(v).Monthly(m).GenTimeLost2MetReqOperationDuration_h...
                                = 24 .* OPERATIONS.DISCRETE.SITES(s).DEVICES(d).OPERATIONS(o).VESSELS(v).TotalStandbyTime(m).OperationDuration_D;
                             
                            % Monthly Generation Time Lost to Standby
                            YIELD.DISCRETE.ACTUAL.DELIVERED.SITES(s).DEVICES(d).MetoceanStandby.OPERATIONS(o).VESSELS(v).Monthly(m).GenTimeLost2MetStandby_h...
                                = OPERATIONS.DISCRETE.SITES(s).DEVICES(d).OPERATIONS(o).VESSELS(v).TotalStandbyTime(m).TotalStandbyTime_h;
                            
                            % Monthly Total Generation Time Lost to Metocean Conditions
                            YIELD.DISCRETE.ACTUAL.DELIVERED.SITES(s).DEVICES(d).MetoceanStandby.OPERATIONS(o).VESSELS(v).Monthly(m).TotalGenTimeLost2MetStandby_h...
                                = YIELD.DISCRETE.ACTUAL.DELIVERED.SITES(s).DEVICES(d).MetoceanStandby.OPERATIONS(o).VESSELS(v).Monthly(m).GenTimeLost2MetReqOperationDuration_h...
                                + YIELD.DISCRETE.ACTUAL.DELIVERED.SITES(s).DEVICES(d).MetoceanStandby.OPERATIONS(o).VESSELS(v).Monthly(m).GenTimeLost2MetStandby_h;
                            
                            YIELD.DISCRETE.ACTUAL.DELIVERED.SITES(s).DEVICES(d).MetoceanStandby.OPERATIONS(o).VESSELS(v).Monthly(m).TotalGenTimeLost2MetStandby_h...
                                (YIELD.DISCRETE.ACTUAL.DELIVERED.SITES(s).DEVICES(d).MetoceanStandby.OPERATIONS(o).VESSELS(v).Monthly(m).TotalGenTimeLost2MetStandby_h > OPERATIONS.DISCRETE.SITES(s).DEVICES(d).OPERATIONS(o).OperationLimitedTimeOnSite.WeibullPersistence(m).D_TotalDuration_h)...
                                = OPERATIONS.DISCRETE.SITES(s).DEVICES(d).OPERATIONS(o).OperationLimitedTimeOnSite.WeibullPersistence(m).D_TotalDuration_h;
                            
                            % Monthly Probability of Energy Loss to Standby
                            YIELD.DISCRETE.ACTUAL.DELIVERED.SITES(s).DEVICES(d).MetoceanStandby.OPERATIONS(o).VESSELS(v).Monthly(m).MetStandby_ProbOccurrence...
                              = YIELD.DISCRETE.ACTUAL.DELIVERED.SITES(s).DEVICES(d).MetoceanStandby.OPERATIONS(o).VESSELS(v).Monthly(m).TotalGenTimeLost2MetStandby_h...
                                ./ OPERATIONS.DISCRETE.SITES(s).DEVICES(d).OPERATIONS(o).OperationLimitedTimeOnSite.WeibullPersistence(m).D_TotalDuration_h;
                            
                            % Monthly Energy Lost to Standby
                            YIELD.DISCRETE.ACTUAL.DELIVERED.SITES(s).DEVICES(d).MetoceanStandby.OPERATIONS(o).VESSELS(v).Monthly(m).Energy_MetStandby_GenPerDevice_kWh...
                                = YIELD.DISCRETE.ACTUAL.DELIVERED.SITES(s).DEVICES(d).MetoceanStandby.OPERATIONS(o).VESSELS(v).Monthly(m).Energy_Ideal_DelPerDevice_kWh...
                                .* (1 - YIELD.DISCRETE.ACTUAL.DELIVERED.SITES(s).DEVICES(d).MetoceanStandby.OPERATIONS(o).VESSELS(v).Monthly(m).MetStandby_ProbOccurrence);
                            
                        end
                        
                    else
                        
                        YIELD.DISCRETE.ACTUAL.DELIVERED.SITES(s).DEVICES(d).MetoceanStandby.OPERATIONS(o).VESSELS(v).Monthly...
                            = 'VESSEL UNSUITABLE';
                        
                    end
                    
                    %% Actual Energy Delivered
                    % Operations Name
                    YIELD.DISCRETE.ACTUAL.DELIVERED.SITES(s).DEVICES(d).ActualEnergyDelivered.OPERATIONS(o).Operations_Name...
                        = DEVICES(d).OPERATIONS(o).Name;  
                    
                    % Vessels Name
                    YIELD.DISCRETE.ACTUAL.DELIVERED.SITES(s).DEVICES(d).ActualEnergyDelivered.OPERATIONS(o).VESSELS(v).Vessels_Name...
                        = DEVICES(d).OPERATIONS(o).VESSELS(v).Name;             
                    
                    % Vessels Suitability
                    YIELD.DISCRETE.ACTUAL.DELIVERED.SITES(s).DEVICES(d).ActualEnergyDelivered.OPERATIONS(o).VESSELS(v).Suitability4Operation...
                        = DEVICES(d).OPERATIONS(o).VESSELS(v).Suitability4Operation;   
                    
                    if strcmp(DEVICES(d).OPERATIONS(o).VESSELS(v).Suitability4Operation,'Yes')
                        
                        % Monthly Breakdown
                        for m = 1:12
                            % Month Name
                            YIELD.DISCRETE.ACTUAL.DELIVERED.SITES(s).DEVICES(d).ActualEnergyDelivered.OPERATIONS(o).VESSELS(v).Monthly(m).Month...
                                = monthnum2name(m,'Short');
                            
                            % Monthly Probability of Exceedance (Metocean Generation Limit)
                            YIELD.DISCRETE.ACTUAL.DELIVERED.SITES(s).DEVICES(d).ActualEnergyDelivered.OPERATIONS(o).VESSELS(v).Monthly(m).GenLimit_ProbExceedance...
                                = YIELD.DISCRETE.ACTUAL.DELIVERED.SITES(s).DEVICES(d).GenerationLimit.Monthly(m).GenLimit_ProbExceedance;
                            
                            % Monthly Probability of Energy Loss to Standby
                            YIELD.DISCRETE.ACTUAL.DELIVERED.SITES(s).DEVICES(d).ActualEnergyDelivered.OPERATIONS(o).VESSELS(v).Monthly(m).MetStandby_ProbOccurrence...
                                = YIELD.DISCRETE.ACTUAL.DELIVERED.SITES(s).DEVICES(d).MetoceanStandby.OPERATIONS(o).VESSELS(v).Monthly(m).MetStandby_ProbOccurrence;
                            
                            % Total Probability of Metocean Induced Downtime
                            YIELD.DISCRETE.ACTUAL.DELIVERED.SITES(s).DEVICES(d).ActualEnergyDelivered.OPERATIONS(o).VESSELS(v).Monthly(m).MetInducedDowntime_ProbOccurence...
                                = YIELD.DISCRETE.ACTUAL.DELIVERED.SITES(s).DEVICES(d).ActualEnergyDelivered.OPERATIONS(o).VESSELS(v).Monthly(m).GenLimit_ProbExceedance...
                                + YIELD.DISCRETE.ACTUAL.DELIVERED.SITES(s).DEVICES(d).ActualEnergyDelivered.OPERATIONS(o).VESSELS(v).Monthly(m).MetStandby_ProbOccurrence;
                            
                            YIELD.DISCRETE.ACTUAL.DELIVERED.SITES(s).DEVICES(d).ActualEnergyDelivered.OPERATIONS(o).VESSELS(v).Monthly(m).MetInducedDowntime_ProbOccurence...
                                (YIELD.DISCRETE.ACTUAL.DELIVERED.SITES(s).DEVICES(d).ActualEnergyDelivered.OPERATIONS(o).VESSELS(v).Monthly(m).MetInducedDowntime_ProbOccurence > 1)...
                                = 1;
                            
                            % Monthly Ideal Energy Delivered
                            YIELD.DISCRETE.ACTUAL.DELIVERED.SITES(s).DEVICES(d).ActualEnergyDelivered.OPERATIONS(o).VESSELS(v).Monthly(m).Energy_Ideal_DelPerDevice_kWh...
                                = YIELD.DISCRETE.IDEAL.DELIVERED.SITES(s).DEVICES(d).Monthly(m).Energy_Ideal_DelPerDevice_kWh;
  
                            % Monthly Actual Energy Delivered
                            YIELD.DISCRETE.ACTUAL.DELIVERED.SITES(s).DEVICES(d).ActualEnergyDelivered.OPERATIONS(o).VESSELS(v).Monthly(m).Energy_Actual_DelPerDevice_kWh...
                                = YIELD.DISCRETE.IDEAL.DELIVERED.SITES(s).DEVICES(d).Monthly(m).Energy_Ideal_DelPerDevice_kWh...
                                .* (1 - YIELD.DISCRETE.ACTUAL.DELIVERED.SITES(s).DEVICES(d).ActualEnergyDelivered.OPERATIONS(o).VESSELS(v).Monthly(m).MetInducedDowntime_ProbOccurence);
                            
                        end
                        
                    else
                        
                        YIELD.DISCRETE.ACTUAL.DELIVERED.SITES(s).DEVICES(d).ActualEnergyDelivered.OPERATIONS(o).VESSELS(v).Monthly...
                            = 'VESSEL UNSUITABLE';
                        
                    end 
                end
            end 
            
        % Finalise Section
        Stop = toc(Start); 
        disp([' - Time Elapsed: ',num2str(round2(Stop/60,0.01)),' minutes.']);
            
        end
    end

    % Finalise Section
    disp(' % Metocean Induced Standby/Downtime for DISCRETE Sites calculated successfully.');
end                   

%% SPATIAL Region
if IN.RUN.SPATIAL 
    disp('Calculating Metocean Induced Standby/Downtime for SPATIAL Region...');
    delete(gcp('nocreate')); PP = parpool(feature('numcores'));             % Start the Parallel computing Pool. 
    disp(' - Calculating Daylight Hours available for Operations...');

    % Water/Land Condition (Parallel Workers)
    ValidChartDatumDepth_Binary...
        = logical(~PATHFIND.MAPS.BinaryMobilityMap);
    
    % Daylight Hours Ratio (Parallel Workers)
    [RiseSet,~,~,~,~,~] = suncycle(SITES(1).Lat_dd,...                      % Assume the lat/lon of the first site is representative of the region (over large regions, this may lead to errors).
                                   SITES(1).Lon_dd,...            
                                   datenum(METOCEAN.SPATIAL.DateTime_UTC));

    LightHours = RiseSet(:,2) - RiseSet(:,1);
    LightHours(LightHours < 0) = LightHours(LightHours < 0) + 24;
    LightRatio = LightHours ./ 24;
    
    OPERATIONS.SPATIAL.DaylightHours...
            = timetable(METOCEAN.SPATIAL.DateTime_UTC,...
                        LightHours,...
                        LightRatio,...
                        'VariableNames',{'Daylight_h','DaylightRatio'});
        
    clearvars RiseSet LightHours;   
    
    %% Waiting Time for Time On Site - Defined by Operations Limits
    for d = 1:size(DEVICES,2)                                               % For each Device...
        disp([' - Calculating Metocean Induced Standby/Downtime for  "',DEVICES(d).Name,'" Device at every grid point (this may take some time)...']);    
        Start = tic; 
        
        % Device Name
        OPERATIONS.SPATIAL.DEVICES(d).Devices_Name = DEVICES(d).Name;
        
        % Valid Deployment Location (Parallel Workers)
        ValidDeviceDeployment_Binary...
            = YIELD.SPATIAL.IDEAL.GENERATED.DEVICES(d).ValidDeviceDeployment_Binary; 
                            
        for o = 1:size(DEVICES(d).OPERATIONS,2)                             % For each Operation...
            disp(['   - Evaluating "',DEVICES(d).OPERATIONS(o).Name,'" Operation Limits...']);

            % Operations Name
            OPERATIONS.SPATIAL.DEVICES(d).OPERATIONS(o).Operations_Name...
                = DEVICES(d).OPERATIONS(o).Name;  

            % Operations On Site Duration
            OPERATIONS.SPATIAL.DEVICES(d).OPERATIONS(o).Operations_OnSiteDuration_h...
                = DEVICES(d).OPERATIONS(o).OnSiteDuration_h;

            % Operations Metocean Limits
            OPERATIONS.SPATIAL.DEVICES(d).OPERATIONS(o).OperationsLimit_Flow_Vel_Abs_Surf_ms...
                = DEVICES(d).OPERATIONS(o).OpsLimit_Flow_Vel_Abs_Surf_ms;

            OPERATIONS.SPATIAL.DEVICES(d).OPERATIONS(o).OperationsLimit_Wave_Hs_m...
                = DEVICES(d).OPERATIONS(o).OpsLimit_Wave_Hs_m; 

            % Operations Limits & Duration (Parallel Workers)
            OperationsLimit_Flow_Vel_Abs_Surf_ms...
                = DEVICES(d).OPERATIONS(o).OpsLimit_Flow_Vel_Abs_Surf_ms;
                
            OperationsLimit_Wave_Hs_m...
                = DEVICES(d).OPERATIONS(o).OpsLimit_Wave_Hs_m; 
            
            Operations_OnSiteDuration_h...
                    = DEVICES(d).OPERATIONS(o).OnSiteDuration_h;
            
            b = waitbar(0,'1','Name','Evaluating Month number...'); 
            for m = 1:12                                                    % For each month...
                %% Preallocation of Large Arrays
                waitbar(m/12, b, sprintf('%5.0f',m));
                
                % Monthly DateTime (Parallel Workers)
                Monthly_DateTime_UTC...
                    = METOCEAN.SPATIAL.DateTime_UTC(month(METOCEAN.SPATIAL.DateTime_UTC) == m);
                
                % Monthly Surface Flow Velocity (Parallel Workers)
                Monthly_Flow_Vel_Abs_Surf_ms...
                    = YIELD.SPATIAL.IDEAL.GENERATED.Flow_Vel_Abs_Surf_ms(month(METOCEAN.SPATIAL.DateTime_UTC) == m,:,:);
                
                % Monthly Hs (Parallel Workers)
                Monthly_Wave_Hs_m...
                    = METOCEAN.SPATIAL.Wave_Hs_m(month(METOCEAN.SPATIAL.DateTime_UTC) == m,:,:);                
                
                % Monthly Daylight Ratio (Parallel Workers)
                Monthly_LightRatio...
                    = LightRatio(month(METOCEAN.SPATIAL.DateTime_UTC) == m);
                
                % Monthly NumberDaysRequiredOnSite (Temporary)
                Monthly_NumberDaysRequiredOnSite...
                    = single(zeros(size(ValidChartDatumDepth_Binary)));

                % Monthly NumberStandbyDaysBetweenAccessPeriods (Temporary)
                Monthly_NumberStandbyDaysBetweenAccessPeriods...
                    = single(zeros(size(ValidChartDatumDepth_Binary)));                        

                % Monthly Weibull Probability of Persistence of Operations Limits & Duration (Temporary)
                Monthly_WeibullProbPersistence...
                    = single(zeros(size(ValidChartDatumDepth_Binary)));   
                
                % Monthly Weibull Waiting Hours for Weather Window (Temporary)
                Monthly_NumberStandbyHoursWaitingForWeatherWindows...
                    = single(zeros(size(ValidChartDatumDepth_Binary))); 
                
                %% Calculate SPATIAL Standby for Time On Site - Defined by Operations Limits    
                for x = 1:size(Monthly_Flow_Vel_Abs_Surf_ms,2)
                    parfor y = 1:size(Monthly_Flow_Vel_Abs_Surf_ms,3)
                        if ValidDeviceDeployment_Binary(x,y)
                            % Calculate Monthly Neap Access Periods for Required Time On Site according to Operations Limits
                            [~,Monthly_NumberDaysRequiredOnSite(x,y),...
                               Monthly_NumberStandbyDaysBetweenAccessPeriods(x,y)]...
                                    = neapaccess(Monthly_DateTime_UTC,...
                                                 Monthly_Flow_Vel_Abs_Surf_ms(:,x,y),...
                                                 Monthly_LightRatio,...
                                                 14,...
                                                 7,...
                                                 OperationsLimit_Flow_Vel_Abs_Surf_ms,...
                                                 Operations_OnSiteDuration_h);

                            % Calculate Probability of Exceedance
                            [~,Monthly_ProbExc,~]...
                                = eprob(Monthly_Wave_Hs_m(:,x,y),...
                                        OperationsLimit_Wave_Hs_m);    

                             % Calculate Monthly Weibull Probability of Persistence of Required Time On Site according to Operations Limits (Wave)     
                            [~,Monthly_WeibullProbPersistence(x,y),...
                               Monthly_NumberStandbyHoursWaitingForWeatherWindows(x,y)]...
                                = weibullprobpersistence(Monthly_Wave_Hs_m(:,x,y),...
                                                         Monthly_ProbExc,...
                                                         OperationsLimit_Wave_Hs_m,...
                                                  (24 .* Monthly_NumberDaysRequiredOnSite(x,y)));
                        end
                    end
                end 
                
                % Month
                OPERATIONS.SPATIAL.DEVICES(d).OPERATIONS(o).OperationLimitedTimeOnSite(m).Month...
                    = monthnum2name(m,'Short');
                
                % Operation Duration
                OPERATIONS.SPATIAL.DEVICES(d).OPERATIONS(o).OperationLimitedTimeOnSite(m).OperationDuration_D...
                    = Monthly_NumberDaysRequiredOnSite;
                
                OPERATIONS.SPATIAL.DEVICES(d).OPERATIONS(o).OperationLimitedTimeOnSite(m).OperationDuration_D...
                (~ValidChartDatumDepth_Binary) = NaN;
                
                % Standby Between Neaps
                OPERATIONS.SPATIAL.DEVICES(d).OPERATIONS(o).OperationLimitedTimeOnSite(m).StandbyBetweenNeapAccessPeriods_D...
                    = Monthly_NumberStandbyDaysBetweenAccessPeriods;
                
                OPERATIONS.SPATIAL.DEVICES(d).OPERATIONS(o).OperationLimitedTimeOnSite(m).StandbyBetweenNeapAccessPeriods_D...
                (~ValidChartDatumDepth_Binary) = NaN;
                
                % Standby Waiting for Weather Windows
                OPERATIONS.SPATIAL.DEVICES(d).OPERATIONS(o).OperationLimitedTimeOnSite(m).StandbyWaitingForOnSiteWeatherWindows_h...
                    = (Monthly_NumberStandbyHoursWaitingForWeatherWindows);
                
                OPERATIONS.SPATIAL.DEVICES(d).OPERATIONS(o).OperationLimitedTimeOnSite(m).StandbyWaitingForOnSiteWeatherWindows_h...
                (~ValidChartDatumDepth_Binary) = NaN;
                
                % Weibull Probability of Persistence
                OPERATIONS.SPATIAL.DEVICES(d).OPERATIONS(o).OperationLimitedTimeOnSite(m).WeibullProbPersistence...
                    = Monthly_WeibullProbPersistence;
                
                OPERATIONS.SPATIAL.DEVICES(d).OPERATIONS(o).OperationLimitedTimeOnSite(m).WeibullProbPersistence...
                (~ValidChartDatumDepth_Binary) = NaN;
                
            end
            
            close(b);
            
            %% Waiting Time for Transit - Defined by Vessels Limits  
            for v = 1:size(DEVICES(d).OPERATIONS(o).VESSELS,2)              % For each Vessel...
                disp(['     - Applying "',DEVICES(d).OPERATIONS(o).VESSELS(v).Name,'" Vessel Limits...']);
                % Vessel Name
                OPERATIONS.SPATIAL.DEVICES(d).OPERATIONS(o).VESSELS(v).Vessels_Name...
                    = DEVICES(d).OPERATIONS(o).VESSELS(v).Name;
                
                % Vessel Working Limits & Transit Speed
                OPERATIONS.SPATIAL.DEVICES(d).OPERATIONS(o).VESSELS(v).VesselLimits_Flow_Vel_Abs_Surf_ms...
                    = DEVICES(d).OPERATIONS(o).VESSELS(v).WorkingLimits_Flow_Vel_Abs_Surf_ms;                

                OPERATIONS.SPATIAL.DEVICES(d).OPERATIONS(o).VESSELS(v).VesselLimits_Wave_Hs_m...
                    = DEVICES(d).OPERATIONS(o).VESSELS(v).WorkingLimits_Wave_Hs_m;    

                OPERATIONS.SPATIAL.DEVICES(d).OPERATIONS(o).VESSELS(v).TransitSpeed_ms...
                    = DEVICES(d).OPERATIONS(o).VESSELS(v).Transit_Speed_ms;
                
                % Total Transit Time (Out & Back)
                OPERATIONS.SPATIAL.DEVICES(d).OPERATIONS(o).VESSELS(v).TotalTransitTime_h...
                    = (PATHFIND.SPATIAL.VESSELS(v).Path2SuitableValidPort_AStarDistance_m...
                    ./ DEVICES(d).OPERATIONS(o).VESSELS(v).Transit_Speed_ms) .* 2 ...
                    ./ 60 ./ 60;

                % Vessel Suitability for Operation
                OPERATIONS.SPATIAL.DEVICES(d).OPERATIONS(o).VESSELS(v).Suitability4Operation...
                    = DEVICES(d).OPERATIONS(o).VESSELS(v).Suitability4Operation;  
                
                if strcmp(DEVICES(d).OPERATIONS(o).VESSELS(v).Suitability4Operation,'Yes')
                    % Path to Port (Parrelel Workers)
                    AStar_Path2SuitableValidPort_mn...
                        = PATHFIND.SPATIAL.VESSELS(v).AStar_Path2SuitableValidPort_mn;
                    
                    % Vessel Working Limits & Transit Time (Parallel Workers)
                    VesselLimits_Wave_Hs_m...
                        = DEVICES(d).OPERATIONS(o).VESSELS(v).WorkingLimits_Wave_Hs_m;                  
                   
                    TotalTransitTime_h...
                        = OPERATIONS.SPATIAL.DEVICES(d).OPERATIONS(o).VESSELS(v).TotalTransitTime_h;
                    
                    %% For SPATIAL Calculation, the Standby Data must be calculated for each node of the Transit path (the worst is then taken)
                    b = waitbar(0,'1','Name','Evaluating Month number...'); 
                    
                    for m = 1:12                                            % For each month...
                        waitbar(m/12, b, sprintf('%5.0f',m));
                        % Month
                        OPERATIONS.SPATIAL.DEVICES(d).OPERATIONS(o).VESSELS(v).VesselLimitedTransitTime(m).Month...
                            = monthnum2name(m,'Short');

                        % Monthly DateTime (Parallel Workers)
                         Monthly_DateTime_UTC...
                            = METOCEAN.SPATIAL.DateTime_UTC(month(METOCEAN.SPATIAL.DateTime_UTC) == m);
                        
                        % Monthly Hs (Parallel Workers)
                        Monthly_Wave_Hs_m...
                            = METOCEAN.SPATIAL.Wave_Hs_m(month(METOCEAN.SPATIAL.DateTime_UTC) == m,:,:);                                       

                        % Monthly Weibull Probability of Persistence of Vessel Limits & Operation Duration (Temporary)
                        Monthly_WeibullProbPersistence...
                            = single(zeros(size(ValidChartDatumDepth_Binary)));   

                        % Monthly Weibull Waiting Hours for Weather Window (Temporary)
                        Monthly_NumberStandbyHoursWaitingForWeatherWindows...
                            = single(zeros(size(ValidChartDatumDepth_Binary))); 

                        % Longest Standby Time on Transit Path
                        Monthly_WorstStandbyWaitingForTransitWeatherWindows_h...
                            = single(zeros(size(ValidChartDatumDepth_Binary))); 

                        Monthly_WorstWeibullProbPersistence...
                            = single(zeros(size(ValidChartDatumDepth_Binary))); 
                        
                        % Calculate Probability of Exceedance for Vessel Limits (Wave)
                        for x = 1:size(Monthly_Wave_Hs_m,2)
                            for y = 1:size(Monthly_Wave_Hs_m,3)
                                if ValidDeviceDeployment_Binary(x,y)
                                    [~,Monthly_ProbExc,~]...
                                        = eprob(Monthly_Wave_Hs_m(:,x,y),...
                                                VesselLimits_Wave_Hs_m);    
                                            
                                    [~,Monthly_WeibullProbPersistence(x,y),...
                                       Monthly_NumberStandbyHoursWaitingForWeatherWindows(x,y)]...
                                        = weibullprobpersistence(Monthly_Wave_Hs_m(:,x,y),...
                                                                 Monthly_ProbExc,...
                                                                 VesselLimits_Wave_Hs_m,...
                                                                 TotalTransitTime_h(x,y) + Operations_OnSiteDuration_h);

                                    Monthly_WaitingHoursOnPath = zeros(size(AStar_Path2SuitableValidPort_mn{x, y},1),1);
                                    
                                    for n = 1:size(AStar_Path2SuitableValidPort_mn{x, y},1)
                                        Monthly_WaitingHoursOnPath(n)...
                                            = Monthly_NumberStandbyHoursWaitingForWeatherWindows...
                                                (AStar_Path2SuitableValidPort_mn{x, y}(n,2),...
                                                 AStar_Path2SuitableValidPort_mn{x, y}(n,1));
                                             
                                    end

                                    [~, MaxHoursIdx] = max(Monthly_WaitingHoursOnPath);

                                    Worstx = AStar_Path2SuitableValidPort_mn{x, y}(MaxHoursIdx,2);
                                    Worsty = AStar_Path2SuitableValidPort_mn{x, y}(MaxHoursIdx,1);

                                    Monthly_WorstStandbyWaitingForTransitWeatherWindows_h(x,y)...
                                        = Monthly_NumberStandbyHoursWaitingForWeatherWindows(Worstx, Worsty);
                                    
                                    Monthly_WorstWeibullProbPersistence(x,y)...
                                        = Monthly_WeibullProbPersistence(Worstx, Worsty);
                                    
                                end
                            end
                        end
                        
                        % Standby Waiting for Transit Weather Windows
                        OPERATIONS.SPATIAL.DEVICES(d).OPERATIONS(o).VESSELS(v).VesselLimitedTransitTime(m).StandbyWaitingForTransitWeatherWindows_h...
                            = (Monthly_WorstStandbyWaitingForTransitWeatherWindows_h...
                                .* OPERATIONS.SPATIAL.DEVICES(d).OPERATIONS(o).OperationLimitedTimeOnSite(m).OperationDuration_D);

                        OPERATIONS.SPATIAL.DEVICES(d).OPERATIONS(o).VESSELS(v).VesselLimitedTransitTime(m).StandbyWaitingForTransitWeatherWindows_h...
                        (~ValidChartDatumDepth_Binary) = NaN;   

                        % Weibull Probability of Persistence
                        OPERATIONS.SPATIAL.DEVICES(d).OPERATIONS(o).VESSELS(v).VesselLimitedTransitTime(m).WorstWeibullProbPersistence...
                           = Monthly_WorstWeibullProbPersistence;

                        OPERATIONS.SPATIAL.DEVICES(d).OPERATIONS(o).VESSELS(v).VesselLimitedTransitTime(m).WorstWeibullProbPersistence...
                        (~ValidChartDatumDepth_Binary) = NaN;  

                        %% Total Standby Time
                        % Month
                        OPERATIONS.SPATIAL.DEVICES(d).OPERATIONS(o).VESSELS(v).TotalStandbyTime(m).Month...
                            = monthnum2name(m,'Short');

                        % Days Required On Site for Operation Completion (Not including Standby time)
                        OPERATIONS.SPATIAL.DEVICES(d).OPERATIONS(o).VESSELS(v).TotalStandbyTime(m).OperationDuration_D...
                            = OPERATIONS.SPATIAL.DEVICES(d).OPERATIONS(o).OperationLimitedTimeOnSite(m).OperationDuration_D;

                        % Standby Days Between Neap Access Period (Defined by Operations Flow Limitations)
                        OPERATIONS.SPATIAL.DEVICES(d).OPERATIONS(o).VESSELS(v).TotalStandbyTime(m).StandbyBetweenNeapAccessPeriods_D...
                            = OPERATIONS.SPATIAL.DEVICES(d).OPERATIONS(o).OperationLimitedTimeOnSite(m).StandbyBetweenNeapAccessPeriods_D;

                        % Standby Time Waiting for Weather Windows to Occur During Neap Access Periods (Defined by Operations Wave Limitations)
                        OPERATIONS.SPATIAL.DEVICES(d).OPERATIONS(o).VESSELS(v).TotalStandbyTime(m).StandbyWaitingForOnSiteWeatherWindows_h...
                            = OPERATIONS.SPATIAL.DEVICES(d).OPERATIONS(o).OperationLimitedTimeOnSite(m).StandbyWaitingForOnSiteWeatherWindows_h;

                        OPERATIONS.SPATIAL.DEVICES(d).OPERATIONS(o).VESSELS(v).TotalStandbyTime(m).StandbyWaitingForOnSiteWeatherWindows_D...
                            = round2(OPERATIONS.SPATIAL.DEVICES(d).OPERATIONS(o).VESSELS(v).TotalStandbyTime(m).StandbyWaitingForOnSiteWeatherWindows_h ./ 24,1);

                        % Standby Time Waiting for Weather Windows to Occur for Transit (Defined By Vessel, multiplied by number of days required)  
                        OPERATIONS.SPATIAL.DEVICES(d).OPERATIONS(o).VESSELS(v).TotalStandbyTime(m).StandbyWaitingForTransitWeatherWindows_h...
                            = OPERATIONS.SPATIAL.DEVICES(d).OPERATIONS(o).VESSELS(v).VesselLimitedTransitTime(m).StandbyWaitingForTransitWeatherWindows_h;

                        OPERATIONS.SPATIAL.DEVICES(d).OPERATIONS(o).VESSELS(v).TotalStandbyTime(m).StandbyWaitingForTransitWeatherWindows_D...
                            = round2(OPERATIONS.SPATIAL.DEVICES(d).OPERATIONS(o).VESSELS(v).TotalStandbyTime(m).StandbyWaitingForTransitWeatherWindows_h ./ 24,1);

                        % Total Standby Time 
                        OPERATIONS.SPATIAL.DEVICES(d).OPERATIONS(o).VESSELS(v).TotalStandbyTime(m).TotalStandbyTime_h...
                            = ((24 .* OPERATIONS.SPATIAL.DEVICES(d).OPERATIONS(o).VESSELS(v).TotalStandbyTime(m).StandbyBetweenNeapAccessPeriods_D)...
                            + OPERATIONS.SPATIAL.DEVICES(d).OPERATIONS(o).VESSELS(v).TotalStandbyTime(m).StandbyWaitingForOnSiteWeatherWindows_h...
                            + OPERATIONS.SPATIAL.DEVICES(d).OPERATIONS(o).VESSELS(v).TotalStandbyTime(m).StandbyWaitingForTransitWeatherWindows_h);

                        OPERATIONS.SPATIAL.DEVICES(d).OPERATIONS(o).VESSELS(v).TotalStandbyTime(m).TotalStandbyTime_h...
                            (OPERATIONS.SPATIAL.DEVICES(d).OPERATIONS(o).VESSELS(v).TotalStandbyTime(m).TotalStandbyTime_h > size(Monthly_DateTime_UTC,1))...
                            = size(Monthly_DateTime_UTC,1);

                        OPERATIONS.SPATIAL.DEVICES(d).OPERATIONS(o).VESSELS(v).TotalStandbyTime(m).TotalStandbyTime_D...
                            = round2(OPERATIONS.SPATIAL.DEVICES(d).OPERATIONS(o).VESSELS(v).TotalStandbyTime(m).TotalStandbyTime_h ./ 24, 1);

                    end
                    
                    close(b);
                    
                else
                    % Unsuitable Vessel Placeholders
                    OPERATIONS.SPATIAL.DEVICES(d).OPERATIONS(o).VESSELS(v).VesselLimitedTransitTime...
                        = 'VESSEL UNSUITABLE';
                    
                    OPERATIONS.SPATIAL.DEVICES(d).OPERATIONS(o).VESSELS(v).TotalStandbyTime...
                        = 'VESSEL UNSUITABLE';

                end   
            end
        end
        
        %% Actual Energy Delivered (Downtime due to Metocean Generation Limit Exceedance)
        disp('   - Calculating Actual Energy Delivered...');
        
        % Devices Name
        YIELD.SPATIAL.ACTUAL.DELIVERED.DEVICES(d).Devices_Name...
            = DEVICES(d).Name;      

        % Metocean Generation Limit
        YIELD.SPATIAL.ACTUAL.DELIVERED.DEVICES(d).GenerationLimit.GenLimit_Wave_Hs_m...
            = DEVICES(d).GenLimit_Wave_Hs_m;
        
        % Metocean Generation Limit (Parallel Workers)
        GenLimit_Wave_Hs_m = DEVICES(d).GenLimit_Wave_Hs_m; 
        
        % Monthly Breakdown
        b = waitbar(0,'1','Name','Evaluating Month number...'); 

        for m = 1:12                                                    	% For each month...
            waitbar(m/12, b, sprintf('%5.0f',m));
            
            % Month Name
            YIELD.SPATIAL.ACTUAL.DELIVERED.DEVICES(d).GenerationLimit.Monthly(m).Month...
                = monthnum2name(m,'Short');

            % Monthly Hs (Parallel Workers)
            Monthly_Wave_Hs_m...
                = METOCEAN.SPATIAL.Wave_Hs_m(month(METOCEAN.SPATIAL.DateTime_UTC) == m,:,:);    

            % Monthly Ideal Energy Delivered
            YIELD.SPATIAL.ACTUAL.DELIVERED.DEVICES(d).GenerationLimit.Monthly(m).Energy_Ideal_DelPerDevice_kWh...
                = YIELD.SPATIAL.IDEAL.DELIVERED.DEVICES(d).Monthly(m).Energy_Ideal_DelPerDevice_kWh;

            % Monthly Weibull Probability of Persistence of Vessel Limits & Operation Duration (Temporary)
            GenLimit_ProbExceedance...
                = single(zeros(size(ValidChartDatumDepth_Binary)));   
            
            % Monthly Probability of Exceedance (Metocean Generation Limit)            
            for x = 1:size(Monthly_Wave_Hs_m,2)
                for y = 1:size(Monthly_Wave_Hs_m,3)
                    if ValidDeviceDeployment_Binary(x,y)
                        [~,~,GenLimit_ProbExceedance(x,y)]...
                            = eprob(Monthly_Wave_Hs_m(:,x,y),...
                                    GenLimit_Wave_Hs_m);
                    end
                end
            end
            
            % Probaility of Exceedance (Metocean Generation Limit)
            YIELD.SPATIAL.ACTUAL.DELIVERED.DEVICES(d).GenerationLimit.Monthly(m).GenLimit_ProbExceedance...
                = GenLimit_ProbExceedance;
             
            % Monthly Metocean Generation Limited Energy Generated Per Device             
            YIELD.SPATIAL.ACTUAL.DELIVERED.DEVICES(d).GenerationLimit.Monthly(m).Energy_GenLimit_DelPerDevice_kWh...          
                = YIELD.SPATIAL.IDEAL.DELIVERED.DEVICES(d).Monthly(m).Energy_Ideal_DelPerDevice_kWh...
                .* (1 - YIELD.SPATIAL.ACTUAL.DELIVERED.DEVICES(d).GenerationLimit.Monthly(m).GenLimit_ProbExceedance);

        end
        
        close(b);

        %% Actual Energy Delivered (Loss of Generation Hours due to Standby Time)
        for o = 1:size(DEVICES(d).OPERATIONS,2)
            % Operations Name
            YIELD.SPATIAL.ACTUAL.DELIVERED.DEVICES(d).MetoceanStandby.OPERATIONS(o).Operations_Name...
                = DEVICES(d).OPERATIONS(o).Name;  
            
            YIELD.SPATIAL.ACTUAL.DELIVERED.DEVICES(d).ActualEnergyDelivered.OPERATIONS(o).Operations_Name...
                = DEVICES(d).OPERATIONS(o).Name;  

            for v = 1:size(DEVICES(d).OPERATIONS(o).VESSELS,2)  
                % Vessels Name
                YIELD.SPATIAL.ACTUAL.DELIVERED.DEVICES(d).MetoceanStandby.OPERATIONS(o).VESSELS(v).Vessels_Name...
                    = DEVICES(d).OPERATIONS(o).VESSELS(v).Name; 
                
                YIELD.SPATIAL.ACTUAL.DELIVERED.DEVICES(d).ActualEnergyDelivered.OPERATIONS(o).VESSELS(v).Vessels_Name...
                    = DEVICES(d).OPERATIONS(o).VESSELS(v).Name;   

                % Vessels Suitability
                YIELD.SPATIAL.ACTUAL.DELIVERED.DEVICES(d).MetoceanStandby.OPERATIONS(o).VESSELS(v).Suitability4Operation...
                    = DEVICES(d).OPERATIONS(o).VESSELS(v).Suitability4Operation;  
                
                YIELD.SPATIAL.ACTUAL.DELIVERED.DEVICES(d).ActualEnergyDelivered.OPERATIONS(o).VESSELS(v).Suitability4Operation...
                    = DEVICES(d).OPERATIONS(o).VESSELS(v).Suitability4Operation;   

                if strcmp(DEVICES(d).OPERATIONS(o).VESSELS(v).Suitability4Operation,'Yes')
                    % Monthly Breakdown
                    for m = 1:12
                        % Month Name
                        YIELD.SPATIAL.ACTUAL.DELIVERED.DEVICES(d).MetoceanStandby.OPERATIONS(o).VESSELS(v).Monthly(m).Month...
                            = monthnum2name(m,'Short');

                        % Monthly DateTime (Parallel Workers)
                        Monthly_DateTime_UTC...
                            = METOCEAN.SPATIAL.DateTime_UTC(month(METOCEAN.SPATIAL.DateTime_UTC) == m);
                        
                        % Monthly Ideal Energy Delivered
                        YIELD.SPATIAL.ACTUAL.DELIVERED.DEVICES(d).MetoceanStandby.OPERATIONS(o).VESSELS(v).Monthly(m).Energy_Ideal_DelPerDevice_kWh...
                            = YIELD.SPATIAL.IDEAL.DELIVERED.DEVICES(d).Monthly(m).Energy_Ideal_DelPerDevice_kWh;

                        % Monthly Generation Time Lost to Metocean Impact on Operation Duration
                        YIELD.SPATIAL.ACTUAL.DELIVERED.DEVICES(d).MetoceanStandby.OPERATIONS(o).VESSELS(v).Monthly(m).GenTimeLost2MetReqOperationDuration_h...
                            = 24 .* OPERATIONS.SPATIAL.DEVICES(d).OPERATIONS(o).VESSELS(v).TotalStandbyTime(m).OperationDuration_D;

                        % Monthly Generation Time Lost to Standby
                        YIELD.SPATIAL.ACTUAL.DELIVERED.DEVICES(d).MetoceanStandby.OPERATIONS(o).VESSELS(v).Monthly(m).GenTimeLost2MetStandby_h...
                            = OPERATIONS.SPATIAL.DEVICES(d).OPERATIONS(o).VESSELS(v).TotalStandbyTime(m).TotalStandbyTime_h;

                        % Monthly Total Generation Time Lost to Metocean Conditions
                        YIELD.SPATIAL.ACTUAL.DELIVERED.DEVICES(d).MetoceanStandby.OPERATIONS(o).VESSELS(v).Monthly(m).TotalGenTimeLost2MetStandby_h...
                            = YIELD.SPATIAL.ACTUAL.DELIVERED.DEVICES(d).MetoceanStandby.OPERATIONS(o).VESSELS(v).Monthly(m).GenTimeLost2MetReqOperationDuration_h...
                            + YIELD.SPATIAL.ACTUAL.DELIVERED.DEVICES(d).MetoceanStandby.OPERATIONS(o).VESSELS(v).Monthly(m).GenTimeLost2MetStandby_h;

                        YIELD.SPATIAL.ACTUAL.DELIVERED.DEVICES(d).MetoceanStandby.OPERATIONS(o).VESSELS(v).Monthly(m).TotalGenTimeLost2MetStandby_h...
                            (YIELD.SPATIAL.ACTUAL.DELIVERED.DEVICES(d).MetoceanStandby.OPERATIONS(o).VESSELS(v).Monthly(m).TotalGenTimeLost2MetStandby_h > size(Monthly_DateTime_UTC,1))...
                            = size(Monthly_DateTime_UTC,1);

                        % Monthly Probability of Energy Loss to Standby
                        YIELD.SPATIAL.ACTUAL.DELIVERED.DEVICES(d).MetoceanStandby.OPERATIONS(o).VESSELS(v).Monthly(m).MetStandby_ProbOccurrence...
                          = YIELD.SPATIAL.ACTUAL.DELIVERED.DEVICES(d).MetoceanStandby.OPERATIONS(o).VESSELS(v).Monthly(m).TotalGenTimeLost2MetStandby_h...
                            ./ size(Monthly_DateTime_UTC,1);

                        % Monthly Energy Lost to Standby
                        YIELD.SPATIAL.ACTUAL.DELIVERED.DEVICES(d).MetoceanStandby.OPERATIONS(o).VESSELS(v).Monthly(m).Energy_MetStandby_GenPerDevice_kWh...
                            = YIELD.SPATIAL.ACTUAL.DELIVERED.DEVICES(d).MetoceanStandby.OPERATIONS(o).VESSELS(v).Monthly(m).Energy_Ideal_DelPerDevice_kWh...
                            .* (1 - YIELD.SPATIAL.ACTUAL.DELIVERED.DEVICES(d).MetoceanStandby.OPERATIONS(o).VESSELS(v).Monthly(m).MetStandby_ProbOccurrence);

                        %% Actual Energy Delivered
                        % Month Name
                        YIELD.SPATIAL.ACTUAL.DELIVERED.DEVICES(d).ActualEnergyDelivered.OPERATIONS(o).VESSELS(v).Monthly(m).Month...
                            = monthnum2name(m,'Short');

                        % Monthly Probability of Exceedance (Metocean Generation Limit)
                        YIELD.SPATIAL.ACTUAL.DELIVERED.DEVICES(d).ActualEnergyDelivered.OPERATIONS(o).VESSELS(v).Monthly(m).GenLimit_ProbExceedance...
                            = YIELD.SPATIAL.ACTUAL.DELIVERED.DEVICES(d).GenerationLimit.Monthly(m).GenLimit_ProbExceedance;

                        % Monthly Probability of Energy Loss to Standby
                        YIELD.SPATIAL.ACTUAL.DELIVERED.DEVICES(d).ActualEnergyDelivered.OPERATIONS(o).VESSELS(v).Monthly(m).MetStandby_ProbOccurrence...
                            = YIELD.SPATIAL.ACTUAL.DELIVERED.DEVICES(d).MetoceanStandby.OPERATIONS(o).VESSELS(v).Monthly(m).MetStandby_ProbOccurrence;

                        % Total Probability of Metocean Induced Downtime
                        YIELD.SPATIAL.ACTUAL.DELIVERED.DEVICES(d).ActualEnergyDelivered.OPERATIONS(o).VESSELS(v).Monthly(m).MetInducedDowntime_ProbOccurence...
                            = YIELD.SPATIAL.ACTUAL.DELIVERED.DEVICES(d).ActualEnergyDelivered.OPERATIONS(o).VESSELS(v).Monthly(m).GenLimit_ProbExceedance...
                            + YIELD.SPATIAL.ACTUAL.DELIVERED.DEVICES(d).ActualEnergyDelivered.OPERATIONS(o).VESSELS(v).Monthly(m).MetStandby_ProbOccurrence;

                        YIELD.SPATIAL.ACTUAL.DELIVERED.DEVICES(d).ActualEnergyDelivered.OPERATIONS(o).VESSELS(v).Monthly(m).MetInducedDowntime_ProbOccurence...
                            (YIELD.SPATIAL.ACTUAL.DELIVERED.DEVICES(d).ActualEnergyDelivered.OPERATIONS(o).VESSELS(v).Monthly(m).MetInducedDowntime_ProbOccurence > 1)...
                            = 1;

                        % Monthly Ideal Energy Delivered
                        YIELD.SPATIAL.ACTUAL.DELIVERED.DEVICES(d).ActualEnergyDelivered.OPERATIONS(o).VESSELS(v).Monthly(m).Energy_Ideal_DelPerDevice_kWh...
                            = YIELD.SPATIAL.IDEAL.DELIVERED.DEVICES(d).Monthly(m).Energy_Ideal_DelPerDevice_kWh;

                        % Monthly Actual Energy Delivered
                        YIELD.SPATIAL.ACTUAL.DELIVERED.DEVICES(d).ActualEnergyDelivered.OPERATIONS(o).VESSELS(v).Monthly(m).Energy_Actual_DelPerDevice_kWh...
                            = YIELD.SPATIAL.IDEAL.DELIVERED.DEVICES(d).Monthly(m).Energy_Ideal_DelPerDevice_kWh...
                            .* (1 - YIELD.SPATIAL.ACTUAL.DELIVERED.DEVICES(d).ActualEnergyDelivered.OPERATIONS(o).VESSELS(v).Monthly(m).MetInducedDowntime_ProbOccurence);

                    end

                else
                    % Unsuitable Vessel Placeholder
                    YIELD.SPATIAL.ACTUAL.DELIVERED.DEVICES(d).MetoceanStandby.OPERATIONS(o).VESSELS(v).Monthly...
                        = 'VESSEL UNSUITABLE';
                    
                    YIELD.SPATIAL.ACTUAL.DELIVERED.DEVICES(d).ActualEnergyDelivered.OPERATIONS(o).VESSELS(v).Monthly...
                        = 'VESSEL UNSUITABLE';

                end 
            end
        end
        
        Stop = toc(Start);
        disp([' - Time Elapsed: ',num2str(round2(Stop/60,0.01)),' minutes.']);
    
    end
    
    % Finalise Section
    delete(PP);
    disp(' % Metocean Induced Standby/Downtime for SPATIAL Region calculated successfully.');
    
end

end
