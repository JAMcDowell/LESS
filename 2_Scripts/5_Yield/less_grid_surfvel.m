function [Flow_Vel_Abs_Surf_ms] = less_grid_surfvel(Depth_Rounded2Bin_TimeHist_m,...
                                                    BinSize_m,...
                                                    Flow_Vel_Abs_DepAv_TimeHist_ms,...
                                                    PowerLaw_Coefficient)
%% Function Description
%

%% Inputs Description
%

%% Outputs Description
%

%% Inputs Checks
% Highly iterative script. Validating attributes will slow it down.
% validateattributes(Depth_Rounded2Bin_TimeHist_m,...
%     {'numeric'},{'column','positive','nonnan','nonempty'});
% 
% validateattributes(BinSize_m,...
%     {'numeric'},{'scalar','positive','nonnan','nonempty'});
% 
% validateattributes(Flow_Vel_Abs_DepAv_TimeHist_ms,...
%     {'numeric'},{'column','nonnegative','nonnan','nonempty'});
% 
% validateattributes(PowerLaw_Coefficient,...
%     {'numeric'},{'scalar','positive','nonnan','nonempty','<=',1});

%% Preallocate Arrays of NaNs
DepthBins_FrmSurf = NaN(size(Depth_Rounded2Bin_TimeHist_m,1),...
                        size(0:BinSize_m:max(Depth_Rounded2Bin_TimeHist_m),2)); 
                    
BinnedVel_Profile_FrmSurf = DepthBins_FrmSurf;

%% Calculate Depth Bins & Velocity Profiles (from Surface)

for t = 1:size(Depth_Rounded2Bin_TimeHist_m,1)
    Bin_Idx = size(0:BinSize_m:Depth_Rounded2Bin_TimeHist_m(t,1),2);
    
    %% Profile from Surface
    [DepthBins_FrmSurf(t,end-Bin_Idx+1:end),...
     BinnedVel_Profile_FrmSurf(t,end-Bin_Idx+1:end)]...
        = depav2velprofile(Flow_Vel_Abs_DepAv_TimeHist_ms(t,1),...
                           Depth_Rounded2Bin_TimeHist_m(t,1),...
                           PowerLaw_Coefficient,...
                           BinSize_m);
                       
end

%% Extract Surface Velocity
Flow_Vel_Abs_Surf_ms = BinnedVel_Profile_FrmSurf(:,end);
                                    
end
