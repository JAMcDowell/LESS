function [SCENARIO] = less_currency(SCENARIO, IN)
%% Function Description
%

%% Inputs Description
% SCENARIO

% IN

%% Outputs Description
% SCENARIO

%% Function Input Checks
disp('Applying user-defined currency...');

validateattributes(SCENARIO,{'struct'},{'nonempty'});  
validateattributes(IN,      {'struct'},{'nonempty'});

validateattributes(SCENARIO.Project.Project_Currency.Project_Currency{1},{'char'},{'nonempty'}); 
validateattributes(size(SCENARIO.Project.Project_Currency.Project_Currency{1},2),{'numeric'},{'scalar', 'integer', '>=',3, '<=',3}); 

%% Replace Currency Strings (CCC)
for f = 1:size(IN.FIELDS.ScenarioStructs,2)
    TableNames = fieldnames(SCENARIO.(IN.FIELDS.ScenarioStructs{f}))';
    for t = 1:size(TableNames,2)
        HeaderNames = SCENARIO.(IN.FIELDS.ScenarioStructs{f}).(TableNames{t}).Properties.VariableNames;
        TempHeader = cell(1,size(HeaderNames,2));
        for h = 1:size(HeaderNames,2)
            if contains(HeaderNames{h},'CCC')
                TempHeader{h} = strrep(SCENARIO.(IN.FIELDS.ScenarioStructs{f}).(TableNames{t}).Properties.VariableNames{h},...
                                       'CCC',...
                                       SCENARIO.Project.Project_Currency.Project_Currency{1});
            else
                TempHeader{h} = SCENARIO.(IN.FIELDS.ScenarioStructs{f}).(TableNames{t}).Properties.VariableNames{h};
            end
        end  
        SCENARIO.(IN.FIELDS.ScenarioStructs{f}).(TableNames{t}).Properties.VariableNames = TempHeader;  
    end
end

%% Finalise
disp([' % Utilising "',SCENARIO.Project.Project_Currency.Project_Currency{1},'" currency.']);

end