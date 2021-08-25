function [Vel_East_ms,...
          Vel_North_ms] = dir2comp(Vel_Abs_ms,...
                                   Vel_Dir_d2) 
%% dir2comp - JAM 24/10/20
% Calculate velocity components (Easting & Northing) from absolute 
% velocity and direction in nautical convention (0° to 360°, 0° = North).

% Signed heading convention (-360° to 360°, 0° = North) will not be 
% accepted, and must be converted to nautical convention prior to using 
% this function (see signed2nautical.m).

%% Input Descriptions
% Vel_Abs_ms: Scalar or vector matrix for absolute flow velocity (m/s).

% Vel_Dir_d2: Scalar or vector matrix for flow direction (° going to).

%% Output Descriptions
% Vel_East_ms: Scalar or vector matrix for Easting component of flow (+/- m/s).

% Vel_North_ms: Scalar or vector matrix for Northing component of flow (+/- m/s).

%% Input Checks
validateattributes(Vel_Abs_ms(~isnan(Vel_Abs_ms)),{'numeric'},{'nonnegative'});
validateattributes(Vel_Abs_ms,{'numeric'},{'2d','nonempty','numel',numel(Vel_Dir_d2)});

validateattributes(Vel_Dir_d2(~isnan(Vel_Dir_d2)),{'numeric'},{'nonnegative','<=',360});
validateattributes(Vel_Dir_d2,{'numeric'},{'2d','nonempty','numel',numel(Vel_Abs_ms)});

%% Calculate Flow Components
Vel_East_ms  = Vel_Abs_ms .* sind(Vel_Dir_d2); 
Vel_North_ms = Vel_Abs_ms .* cosd(Vel_Dir_d2);

%% Output Checks
validateattributes(Vel_East_ms, {'numeric'},{'2d','numel',numel(Vel_Abs_ms),'nonempty'}); 
validateattributes(Vel_North_ms,{'numeric'},{'2d','numel',numel(Vel_Abs_ms),'nonempty'}); 

end

%% Shift Degrees to be between 0 and 360
%disp('Converting flow direction into component velocity...')
% for d = 1:length(Vel_Dir_d)
%     if Vel_Dir_d(d) < 0 
% 		Vel_Dir_d(d) = Vel_Dir_d(d) + 360;
% 	end % Convert to 0-360°.  
% end