function [Vel_Dir_d2,...
          Vel_Abs_ms] = comp2dir(Vel_East_ms,...
                                 Vel_North_ms) 
%% comp2dir - JAM 24/10/20                        
% Calculate direction and absolute flow velocity in nautical convention 
% (0° to 360°, 0° = North) from velocity components (Easting & Northing).

%% Input Descriptions
% Vel_East_ms: Scalar or vector matrix for Easting component of flow (+/- m/s).

% Vel_North_ms: Scalar or vector matrix for Northing component of flow (+/- m/s).

%% Output Descriptions
% VelDir: Scalar or vector matrix for flow direction (°).

%% Input Checks
validateattributes(Vel_East_ms,{'numeric'}, {'2d','nonempty','numel',numel(Vel_North_ms)});
validateattributes(Vel_North_ms,{'numeric'},{'2d','nonempty','numel',numel(Vel_East_ms)});

%% Calculate Absolute Velocity
Vel_Abs_ms = (Vel_East_ms.^2 + Vel_North_ms.^2).^0.5;
 
%% Calculate Direction
Vel_Dir_d2 = atan2d((Vel_East_ms  ./ Vel_Abs_ms),...                        % Split into quadrants. % tan(theta) = opposite/adjacent.
                    (Vel_North_ms ./ Vel_Abs_ms));                          % Angles given in degrees (going to).

Vel_Dir_d2 = signed2nautical(Vel_Dir_d2);
                
%% Output Checks
validateattributes(Vel_Dir_d2(~isnan(Vel_Dir_d2)),{'numeric'},{'nonnegative','<=',360});
validateattributes(Vel_Dir_d2,{'numeric'},{'2d','numel',numel(Vel_East_ms),'nonempty'}); 

validateattributes(Vel_Abs_ms(~isnan(Vel_Abs_ms)),{'numeric'},{'nonnegative'});
validateattributes(Vel_Abs_ms,{'numeric'},{'2d','numel',numel(Vel_East_ms),'nonempty'}); 

end
% 
% %% Error Handles
% if ((size(Vel_East_ms) == size(Vel_North_ms)) & (size(Vel_East_ms) == size(VelAbs))) == 1
% else
%     error('Array dimensions do not match! Check sizes and orientations.')
% end

% %% Pre-Allocate Memory
% Opp    = zeros(size(VelAbs));
% Adj    = zeros(size(VelAbs));
% Vel_Dir_d2 = zeros(size(VelAbs));

% %% Calculate Flow Direction
% for i = 1:size(VelAbs,1)
% for j = 1:size(VelAbs,2)
%     Opp(i,j)    = Vel_East_ms(i,j); 
%     Adj(i,j)    = Vel_North_ms(i,j);                                                     % tan(theta) = opposite/adjacent                               
%     Vel_Dir_d2(i,j) = atan2d(Opp(i,j)./VelAbs(i,j), Adj(i,j)./VelAbs(i,j)); % Split into quadrants. Angles given in degrees.
%     
%     %% Shift Degrees to be between 0 and 360
%     if Polar == 0
%         if Vel_Dir_d2(i,j)  < 0
%             Vel_Dir_d2(i,j)  = Vel_Dir_d2(i,j) + 360;
%         end
%     end   
%     
% end
% end; clearvars i j;
