%% Levelised cost of Energy Site Selection (LESS) Tool - MASTER SCRIPT
% v4.5 - J.McDowell - 29/07/2021

% A tool to predict the Levelised Cost of Energy (LCoE) of tidal energy
% devices. Metocean site data is incorporated into the calculation through
% estimating the impact upon operations & maintenance and energy yield.
% This produces a more representative prediction of LCoE.

%% Inputs - Scenario Excel Files
% The initial method of data input to LESS tool is a series of Microsoft 
% Excel files (.xlsx). These files can be found in the "1_User Inputs" 
% folder, and should be amended according to the user's desired sites, 
% operations, devices, etc.:

% - "U0_Region.xlsx"
% - "U1_Sites.xlsx"
% - "U2_Operations.xlsx"
% - "U3_Turbines.xlsx"
% - "U4_Devices.xlsx"
% - "U5_Ports.xlsx"
% - "U6_Vessels.xlsx"
% - "U7_Transmission.xlsx"
% - "U8_Project.xlsx"

% The LESS tool responds to the name and number of column headers in 
% each Excel file, therefore the header rows in the provided example files 
% have been locked to prevent accidental alteration. Adding or removing 
% COLUMNS is discouraged as it will result in errors when running this 
% script. Similarly, entering data outside of designated columns, or not 
% entering the required data (leaving blanks) will result in script errors. 

% If a column header is not pertinent to the user's scenario, it is best to 
% populate the specific column with default or zero values. For example, if
% a user wished to incorporate the losses of only one transformer at the 
% shore (rather than onboard their device also), they could populate the 
% "Transmission_OnboardTransformerNoLoadLosses_kW" column with 0, and the 
% "Transmission_OnboardTransformerEfficiency_pc" with 100
% (found in the "Transmission_Parameters" sheet of the
% "U7_Transmission.xlsx" input file). This would effectively model the
% onboard transformer as having no losses (as if it were not present). 
% Similarly, the capital expenditure of an onboard transformer can be
% negated by setting the "Transmission_OnboardTransformerCost_CCC" column
% to 0 (found in the "Transmission_Costs" sheet of the 
% "U7_Transmission.xlsx" input file).

% The user is actively encouraged to add/remove ROWS in the input files 
% relating to their specific sites, operations, devices, etc. While this 
% script will catch the majority of input errors, the user is encouraged
% to ensure that a consistent number of objects is input throughout all the
% sheets/files, and that all required rows/columns are populated.

% For example, if in the "Operations_Name" column of the
% "Operations_Considered" sheet ("U2_Operations.xlsx"), the user wishes to
% add another type of maintenance operation specific to their scenario,
% then they must also update the "Devices_OperationsLimits", 
% "Devices_OperationsDurations" and "Devices_OperationsFrequency" sheets
% ("U4_Devices.xlsx") with their new operation name, as these sheets 
% dictate the device-specific characteristics of the operations for each of 
% the user-defined device(s). 

% While this method of data entry may at first glance seem tedious (when 
% modelling several devices/operations/vessels the tables become quite 
% large), consider that the only other way to capture these linked 
% attributes is a comprehensive object-orientated database, populated and 
% subsequently queried by the user. This would add significant complexity 
% to the LESS tool and its use; while potentially monotonous, the concept 
% of data entry is easily understandable and accessible to anyone with 
% moderate computer literacy.

% Further information on the LESS tool and its use can be found in:
% "A Levelised Cost of Energy Site Selection Tool for Tidal Stream Devices"
% (McDowell, 2021).

%% Inputs - Metocean Data MATLAB Files
% Metocean data is input into the LESS tool as a series of MATLAB (.mat)
% files. At least one year of hourly data is required to calculate LCoE.

% For DISCRETE calculations of LCoE at a designated site, the essential
% metocean data inputs are as follows:

%  - DateTime_UTC          ([t x 1], class 'datetime')
%  - Depth_m               ([t x 1], class 'single')
%  - Flow_Vel_Abs_DepAv_ms ([t x 1], class 'single')
%  - Wave_Hs_m             ([t x 1], class 'single')

% For SPATIAL calculations of LCoE over a wider region, the essential
% metocean data inputs are as follows:

%  - DateTime_UTC          ([t x 1],     class 'datetime')
%  - BathyXYZ_UTM_m        ([3 x m x n], class 'single')
%  - Depth_m               ([t x m x n], class 'single')
%  - Flow_Vel_Abs_DepAv_ms ([t x m x n], class 'single')
%  - Wave_Hs_m             ([t x m x n], class 'single')

%% Required MATLAB Toolboxes
% All required toolboxes are included with an academic MATLAB license. 
% Check your license with the command: license('inuse').
% - Statistics (harmonic analysis, general fitting).
% - Image Processing (imfill, edge).
% - Parallel Computing (parpool, parfor). Not essential, but will speed 
%   things up significantly.

%% Initilise Script
close all; clear; clc; Start = tic;
disp('%%% LESS Tool -v4.5 %%%'); 

%% PATH to Data & Functions
disp('Generating Paths to data and supporting functions...'); 
IN.FILE.PWD = pwd; IN.FILE.MasterFolder = IN.FILE.PWD;                      % Print Working Directory & generate a path to the master folder.                            
addpath(IN.FILE.MasterFolder); addpath(genpath(IN.FILE.MasterFolder));      % Add master folder and all sub-folders to path.
disp(' - Paths to input data folders generated successfully.'); 
IN.FILE.SaveDateIdentifier = char(datetime('now','Format','yyMMdd'));
disp(' - Paths to functions folders generated successfully.');  
disp(' % All Paths generated successfully.');                                  

%% Load Scenario Data (Excel Files)
[SCENARIO, IN] = less_load_scenario(IN);                                    % Load scenario data.

%% Scenario Data Checks
[SCENARIO, IN] = less_checks_scenario(SCENARIO,...                          % Check scenario input data is valid.  
                                      IN);                        

%% Load Metocean Data (.mat files)
METOCEAN = less_load_metocean(SCENARIO,...                                  % Load metocean inputs.
                              IN);                                

%% Metocean Data Checks
METOCEAN = less_checks_metocean(METOCEAN,...                                % Check metocean input data is valid.
                                SCENARIO,...
                                IN); 
                            
% Save Point
disp('Saving outputs (this may take some time)...');                        % Save checked metocean data.     
save('METOCEAN.mat','METOCEAN','-v7.3'); clearvars METOCEAN;                % Clear the data from memory for efficiency.                           

%% Setup Sites Structure
SITES = less_setup_sites(SCENARIO,...                                       % Setup a structure to easily reference Sites characteristics.
                         IN);                                     

%% Setup Devices Structure
DEVICES = less_setup_devices(SCENARIO);                                     % Setup a structure to easily reference Devices characteristics.

% Save Point
disp('Saving outputs (this may take some time)...');                        % Save specified outputs.       
save(['LESS_OUT_',IN.FILE.SaveDateIdentifier,'.mat'],'IN','SCENARIO','SITES','DEVICES','-v7.3');                   
      
%% A* Algorithm Pathfinding
% Memory Management
load('METOCEAN.mat');                                                       % Load metocean data back in.
if IN.RUN.SPATIAL
    METEMP.SPATIAL.UTM_E_m        = METOCEAN.SPATIAL.UTM_E_m;               % Specify metocean data required for Pathfinding.
    METEMP.SPATIAL.UTM_N_m        = METOCEAN.SPATIAL.UTM_N_m;
    METEMP.SPATIAL.ChartDatum_Z_m = METOCEAN.SPATIAL.ChartDatum_Z_m;
    METEMP.SPATIAL.BathyXYZ_UTM_m = METOCEAN.SPATIAL.BathyXYZ_UTM_m;
end
clearvars METOCEAN; METOCEAN = METEMP; clearvars METEMP;                    % Remove all other metocean data.

% Pathfinding
PATHFIND = less_pathfinding(METOCEAN,...                                    % Find the shortest paths from Sites to landfall for transmission, and Vessel specific paths from Sites to nearest suitable Ports.
                            SCENARIO,...
                            SITES,...
                            IN); 
                        
% Save Point                                                   
clearvars METOCEAN; disp('Saving outputs (this may take some time)...');    % Clear metocean data from memory for efficiency.          
save(['LESS_OUT_',IN.FILE.SaveDateIdentifier,'.mat'],'PATHFIND','-append'); % Save recent outputs.       

%% Ideal Yield Calculation
% Memory Management
load('METOCEAN.mat');                                                       % Load metocean data back in (almost all metocean data needed for Yield).

% Yield
YIELD = less_yield_ideal(PATHFIND,...                                       % Calculate Device specific power-weighted average velocity, ideal power generated & energy generated.
                         METOCEAN,...
                         SCENARIO,...
                         SITES,...
                         DEVICES,...
                         IN); 
                     
% Save Point                                                  
clearvars METOCEAN; disp('Saving outputs (this may take some time)...');    % Clear metocean data from memory for efficiency.        
save(['LESS_OUT_',IN.FILE.SaveDateIdentifier,'.mat'],'YIELD','-append');    % Save recent outputs.                      

%% Transmission
% Memory Management
load('METOCEAN.mat');                                                       % Load metocean data back in.
if IN.RUN.DISCRETE
    for s = 1:size(SITES,2)
        METEMP.DISCRETE.(SITES(s).Name).DateTime_UTC...
            = METOCEAN.DISCRETE.(SITES(s).Name).DateTime_UTC;
    end 
end
    
if IN.RUN.SPATIAL
    METEMP.SPATIAL.DateTime_UTC = METOCEAN.SPATIAL.DateTime_UTC;
end
    
clearvars s METOCEAN; METOCEAN = METEMP; clearvars METEMP;                  % Remove all other metocean data.

% Transmission
[TRANSM, YIELD] = less_transmission(YIELD,...                               % Calculate Device specific transmission losses, ideal power delivered & energy delivered.
                                    PATHFIND,...
                                    METOCEAN,...
                                    SCENARIO,...
                                    SITES,...
                                    DEVICES,...
                                    IN); 
                                
% Save Point 
clearvars METOCEAN; disp('Saving outputs (this may take some time)...');    % Clear metocean data from memory for efficiency.
save(['LESS_OUT_',IN.FILE.SaveDateIdentifier,'.mat'],'YIELD','TRANSM','-append');   % Save recent outputs.       
 
%% Operations
% Memory Management
load('METOCEAN.mat');                                                       % Load metocean data back in.
if IN.RUN.DISCRETE
    for s = 1:size(SITES,2)
        METEMP.DISCRETE.(SITES(s).Name).DateTime_UTC...
            = METOCEAN.DISCRETE.(SITES(s).Name).DateTime_UTC;
        METEMP.DISCRETE.(SITES(s).Name).Wave_Hs_m...
            = METOCEAN.DISCRETE.(SITES(s).Name).Wave_Hs_m;        
    end 
end
    
if IN.RUN.SPATIAL
    METEMP.SPATIAL.DateTime_UTC = METOCEAN.SPATIAL.DateTime_UTC;
    METEMP.SPATIAL.Wave_Hs_m    = METOCEAN.SPATIAL.Wave_Hs_m;
end
    
clearvars s METOCEAN; METOCEAN = METEMP; clearvars METEMP;

% Operations
[OPERATIONS, YIELD] = less_operations(YIELD,...                             % Calculate Device, Operation & Vessel specific standby time & actual energy delivered.
                                      PATHFIND,...
                                      METOCEAN,...
                                      SITES,...
                                      DEVICES,...
                                      IN);
                                  
% Save Point                                                   
clearvars METOCEAN; disp('Saving outputs (this may take some time)...');    % Clear metocean data from memory for efficiency.          
save(['LESS_OUT_',IN.FILE.SaveDateIdentifier,'.mat'],'YIELD','OPERATIONS','-append');   % Save recent outputs.         
 
%% Levelised Cost of Energy
% Memory Management
load('METOCEAN.mat');                                                       % Load metocean data back in.
if IN.RUN.DISCRETE
    for s = 1:size(SITES,2)
        METEMP.DISCRETE.(SITES(s).Name).DateTime_UTC...
            = METOCEAN.DISCRETE.(SITES(s).Name).DateTime_UTC;
    end 
end

if IN.RUN.SPATIAL
    METEMP.SPATIAL.DateTime_UTC = METOCEAN.SPATIAL.DateTime_UTC;
end

clearvars s METOCEAN; METOCEAN = METEMP; clearvars METEMP;

% Levelised Cost of Energy
LCOE = less_lcoe(OPERATIONS,...                                             % Calculate Levelised Cost of Energy.
                 TRANSM,...
                 YIELD,...
                 PATHFIND,...
                 METOCEAN,...
                 SCENARIO,...
                 SITES,...
                 DEVICES,...
                 IN);
             
% Save Point                                                              
clearvars METOCEAN; disp('Saving outputs (this may take some time)...');    % Clear metocean data from memory for efficiency.         
save(['LESS_OUT_',IN.FILE.SaveDateIdentifier,'.mat'],'LCOE','-append');     % Save recent outputs.   
     
%% Finalise Script
load('METOCEAN.mat');                                                       % Load metocean data back in.
disp(' % LESS Tool finished normally.'); Stop = toc(Start);                 % Stop the clock.
disp(['Total Time Elapsed: ', num2str(round2(Stop/60/60,0.01)),' hours.']); % Display run time.
clearvars Start Stop; wssize;                                               % Clear temporary variables and display workspace size.

%% Plot Outputs
less_plots(LCOE,...                                                         % Useful plots, formatting specific to example data.
           PATHFIND,...
           METOCEAN);                                         
