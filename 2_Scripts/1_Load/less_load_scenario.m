function [SCENARIO, IN] = less_load_scenario(IN)
%% Function Description
% This function loads in the Scenario data defined by the user in several
% Excel files. Validity checks of this user defined data are performed 
% later by the "less_checks_scenario.m" function.

%% Inputs Description
% IN - Stucture of Input data. In this function, the input file paths are 
% used to find the Scenario data.

%% Outputs Description
% SCENARIO - Structure of Scenario data.

% IN - Stucture of Input data. New essential fields are added by this 
% function.

%% Function Input Checks
validateattributes(IN,{'struct'},{'nonempty'});  
disp('Loading user-defined "Scenario" data...');

%% SCENARIO - Excel File Names
IN.SCENARIO.Region.File       = 'U0_Region.xlsx';
IN.SCENARIO.Sites.File        = 'U1_Sites.xlsx';
IN.SCENARIO.Operations.File   = 'U2_Operations.xlsx';
IN.SCENARIO.Turbines.File     = 'U3_Turbines.xlsx';
IN.SCENARIO.Devices.File      = 'U4_Devices.xlsx';
IN.SCENARIO.Ports.File        = 'U5_Ports.xlsx';
IN.SCENARIO.Vessels.File      = 'U6_Vessels.xlsx';
IN.SCENARIO.Transmission.File = 'U7_Transmission.xlsx';
IN.SCENARIO.Project.File      = 'U8_Project.xlsx';

%% SCENARIO - Excel Sheet Names
IN.SCENARIO.Region.Sheets       = {'Region_SpatialRunFlag',...
                                   'Region_UTM',...
                                   'Region_MatFiles',...
                                   'Region_FlowProfile',...
                                   'Region_Pathfinding',...
                                   'Region_Costs'};
                            
IN.SCENARIO.Sites.Sheets        = {'Sites_DiscreteRunFlag',...
                                   'Sites_Location',...
                                   'Sites_MatFiles',...
                                   'Sites_FlowProfile',...
                                   'Sites_Costs'};
                               
IN.SCENARIO.Operations.Sheets   = {'Operations_Considered'};

IN.SCENARIO.Turbines.Sheets     = {'Turbines_Diameter',...
                                   'Turbines_PowerPerformance',...
                                   'Turbines_Cost'};                               

IN.SCENARIO.Devices.Sheets      = {'Devices_TurbineArrangement',...
                                   'Devices_DeploymentRequirements',...
                                   'Devices_GenerationLimits',...
                                   'Devices_OperationsLimits',...
                                   'Devices_OperationsDurationsFreq',...
                                   'Devices_Costs'};   
                               
IN.SCENARIO.Ports.Sheets        = {'Ports_Locations',...
                                   'Ports_SizeClassification',...
                                   'Ports_Costs'};  
                               
IN.SCENARIO.Vessels.Sheets      = {'Vessels_WorkingLimits',...
                                   'Vessels_OperationsSuitability',...
                                   'Vessels_SizeClassification',...
                                   'Vessels_Costs'};   
                               
IN.SCENARIO.Transmission.Sheets = {'Transmission_Parameters',...
                                   'Transmission_Costs'};   
                               
IN.SCENARIO.Project.Sheets      = {'Project_Currency',...
                                   'Project_Length',...
                                   'Project_DiscountRate',...
                                   'Project_ArraySize'};
                               
%% Load User Inputs
ScenarioFields = fieldnames(IN.SCENARIO)';    

for ui = 1:size(ScenarioFields,2)    
    for sh = 1:size(IN.SCENARIO.(ScenarioFields{ui}).Sheets,2)
        SCENARIO.(ScenarioFields{ui}).(IN.SCENARIO.(ScenarioFields{ui}).Sheets{sh})...
            = readtable(IN.SCENARIO.(ScenarioFields{ui}).File,...
                        'Sheet',IN.SCENARIO.(ScenarioFields{ui}).Sheets{sh});
    end
    disp([' - "',ScenarioFields{ui},'" data loaded successfully.']);
end

%% Finalise
disp(' % All "Scenario" data loaded successfully.');

end