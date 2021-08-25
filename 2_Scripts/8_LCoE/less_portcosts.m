function [Ports_Hire_CCC] = less_portcosts(Ports_TotalReqDuration_D,...
                                           Ports_HireCosts_CCCpd)                                
%% Function Description
%

%% Input Checks
validateattributes(Ports_TotalReqDuration_D,{'numeric'},...
    {'nonnegative','nonempty'});                                                   
validateattributes(Ports_HireCosts_CCCpd,{'numeric'},...
    {'nonnegative','nonempty'}); 

%% Port Hire Costs
Ports_Hire_CCC = ceil(Ports_TotalReqDuration_D)...                          % Round to nearest whole day.
               .* Ports_HireCosts_CCCpd;  
           
%% Output Checks           
validateattributes(Ports_Hire_CCC,{'numeric'},...
    {'nonnegative','nonempty'}); 

end
