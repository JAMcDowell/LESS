function [DepthBins_FrmBed,...
          BinnedVel_Profile_FrmBed]...
            = depav2velprofile(Flow_Vel_Abs_DepAv_ms,...
                               MaxDepth_Rounded2Bin_m,...
                               Shear_Coefficient,...
                               BinSize_m)
%% Function Description
%

%% Input Description
% Flow_Vel_Abs_DepAv_ms: Scalar value for the depth-averaged velocity (m/s).

% MaxDepth_Rounded2Bin_m: Scalar value for the maximum depth at chosen 
% location (m). This value will be rounded to the nearest bin size.

% Shear_Coefficient: Scalar value for the Power-Law exponent for velocity 
% shear profile. Typically 1/7 is representative of most flow regimes.

% BinSize_m: Scalar value designating the size of depth bin (m) for  
% velocity profile to be discretised into. Utilising 1m depth bins is most 
% appropriate for easy combatibility with other associated scripts.

%% Output Description
% DepthBins_FrmBed: Structure containing fields relating to depth maximum, bins
% and profile.

% BinnedVel_Profile_FrmBed: Structure containing fields relating to velocity maximum at the
% surface and binned velocity profile.

%% Input Checks
% Highly iterative script. Validating attributes will slow it down.
% validateattributes(Flow_Vel_Abs_DepAv_ms,...
%     {'numeric'},{'scalar','nonnegative'}); 
% 
% validateattributes(MaxDepth_Rounded2Bin_m,...
%     {'numeric'},{'scalar','positive','integer'}); 
% 
% validateattributes(Shear_Coefficient,...
%     {'numeric'},{'scalar','positive', '<=', 1}); 
% 
% validateattributes(BinSize_m,...
%     {'numeric'},{'scalar','positive'}); 
           
%% Depth Bins
DepthBins_FrmBed = 0:BinSize_m:MaxDepth_Rounded2Bin_m;                      % Split depth into designated bin size, with 0m being the first bin.             

%% Depth-Averaged Velocity Bins
BinnedVel_DepAv = ones(size(DepthBins_FrmBed)).* Flow_Vel_Abs_DepAv_ms;     % Binned but depth-averaged velocity (consistent velocity with depth).

%% Area
AreaVel_DepthAv = sum(DepthBins_FrmBed .* BinnedVel_DepAv);                 % Sum total Area of depth multiplied by depth-averaged velocity.

%% Set Initial Values
SurfaceVel               = Flow_Vel_Abs_DepAv_ms;                           % Set initial surface velocity to be the depth-averaged input value. This value will be incrementally increased during the While loop.

BinnedVel_Profile_FrmBed = zeros(size(DepthBins_FrmBed));                   % Generate an array of zeros to be iteratively filled with depth-varying velocity values during the While loop.

AreaVel_Profile          = sum(BinnedVel_Profile_FrmBed.* DepthBins_FrmBed);% Set initial sum total Area of depth multiplied by depth varying velocity to be 0. This value will be incrementally increased during the While loop.                        

%% While Loop for Binned Velocity Calculation
DepthBinFlip = fliplr(DepthBins_FrmBed);                                    % Flip bins for conceptual ease.

while AreaVel_Profile <= AreaVel_DepthAv                                    % While the sum total of depth-varying Area is less than the sum total of depth-averaged Area, continue the While loop.  
    SurfaceVel = SurfaceVel + 0.01;                                         % Increase the surface velocity by a small increment with each iteration of the While loop.
     
    BinnedVel_Profile_FrmBed(2:end)...                                      % For every value except the bed value of 0 calculate this iteration of the depth-varying velocity as per a Power Law profile.
        = SurfaceVel.*(1 - (DepthBinFlip(2:end)./max(DepthBins_FrmBed)))... % Ubar = Umax*((1 - (r / R))^(1/n))
            .^ Shear_Coefficient;                                           % https://www.nuclear-power.net/nuclear-engineering/fluid-dynamics/turbulent-flow/power-law-velocity-profile-turbulent-flow

    AreaVel_Profile = sum(BinnedVel_Profile_FrmBed .* DepthBins_FrmBed);    % Calculate this iteration of the sum total of depth-varying Area. The While loop will repeat until the sum total of depth-Varying Area is equal to or greater than the sum total of depth-averaged Area.   

end

end
