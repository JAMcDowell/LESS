%% Levelised cost of Energy Site Selection (LESS) Tool - MASTER SCRIPT
% J.McDowell - 04/04/2020

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

% The LESS tool is sensitive to the name and number of column headers in 
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

% Further information on the format of the Excel input files for the LESS 
% tool can be found in the appendix of "A Levelised Cost of Energy Site 
% Selection Tool for Tidal Stream Devices" (McDowell, 2020).

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
% Statistics ()
% Image Processing (imfill, edge)
% Parallel Computing (parpool, parfor) (not essential, but will speed
% things up significantly).
% All included with academic license.
% license('inuse')

%% Initilise Script
close all; clear; clc; Start = tic;
disp('%%% LESS Tool 4.2 %%%'); 
disp('J.McDowell 04/04/2020'); 

%% PATH to Data & Functions
disp('Generating Paths to data and supporting functions...'); 
IN.FILE.PWD = pwd;                                                          % Print Working Directory.
IN.FILE.MasterFolder = IN.FILE.PWD;                                         % Generate a path to the master folder.
addpath(IN.FILE.MasterFolder);                                              % Add master folder to path.
disp(' - Paths to input data folders generated successfully.');       
addpath(genpath(IN.FILE.MasterFolder));                                     % Add all sub-folders to path.    
disp(' - Paths to functions folders generated successfully.');  
disp(' % All Paths generated successfully.');                                  

%% Load Scenario Data (Excel Files)
[SCENARIO, IN] = less_load_scenario(IN);                                    % Load scenario data.

%% Scenario Data Checks
[SCENARIO, IN] = less_checks_scenario(SCENARIO, IN);                        % Check scenario input data is valid.  

%% Load Metocean Data (.mat files)
METOCEAN = less_load_metocean(SCENARIO, IN);                                % Load metocean inputs.

%% Metocean Data Checks
METOCEAN = less_checks_metocean(METOCEAN, SCENARIO, IN);                    % Check metocean input data is valid.

%% Setup Sites Structure
SITES = less_setup_sites(SCENARIO, IN);                                     % Setup a structure to easily reference Sites characteristics.

%% Setup Devices Structure
DEVICES = less_setup_devices(SCENARIO);                                     % Setup a structure to easily reference Devices characteristics.

%% A* Algorithm Pathfinding
PATHFIND = less_pathfinding(METOCEAN, SCENARIO, SITES, IN);                 % Find the shortest paths from Sites to landfall for transmission, and Vessel specific paths from Sites to nearest suitable Ports.
   
%% Ideal Yield Calculation
YIELD = less_yield_ideal(PATHFIND, METOCEAN, SCENARIO, SITES, DEVICES, IN); % Calculate Device specific power-weighted average velocity, ideal power generated & energy generated.

%% Transmission
[TRANSM, YIELD]...                                                          % Calculate Device specific transmission losses, ideal power delivered & energy delivered.
    = less_transmission(YIELD, PATHFIND, METOCEAN, SCENARIO, SITES, DEVICES, IN);  

%% Operations
[OPERATIONS, YIELD]...                                                      % Calculate Device, Operation & Vessel specific standby time & actual energy delivered.
    = less_operations(YIELD, PATHFIND, DEVICES, SITES, METOCEAN, IN);

%% Levelised Cost of Energy
LCOE...                                                                     % Calculate Levelised Cost of Energy.
    = less_lcoe(OPERATIONS, TRANSM, YIELD, PATHFIND, METOCEAN, SCENARIO, SITES, DEVICES, IN); 

%% Finalise Script
disp('Saving outputs (this may take some time)...');
if exist('LESS_OUT.mat','file') == 2
    warning('"LESS_OUT.mat" file already exists in work space. Data must be saved manually.');
else
    save('LESS_OUT.mat',...
         'DEVICES','IN','METOCEAN','OPERATIONS','PATHFIND','SCENARIO','SITES','TRANSM','YIELD','LCOE',...
         '-v7.3');
end

disp(' % LESS Tool finished normally.'); Stop = toc(Start);
disp(['Total Time Elapsed: ', num2str(round2(Stop/60/60,0.01)),' hours.']); 
clearvars Start Stop; 
wssize;

%% Plot Outputs
%less_plots(METOCEAN, PATHFIND, IN)
