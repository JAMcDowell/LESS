function [Flow_Vel_Abs_PWA_ms] = pwa(DepthBins_FrmBedorSurf_m,...
                                     BinnedVel_Profile_FrmBedorSurf_ms,...
                                     RotorRadius_m,...
                                     RotorHub_BinIdx,...
                                     RotorTipTop_BinIdx,...
                                     RotorTipBot_BinIdx)
%% Function Description
%

%% Inputs Description
%

%% Outputs Description
%

%% Inputs Checks
% Highly iterative script. Validating attributes will slow it down.
% validateattributes(DepthBins_FrmBedorSurf_m,...
%     {'numeric'},{'2d','nonempty'}); 
% 
% validateattributes(BinnedVel_Profile_FrmBedorSurf_ms,...
%     {'numeric'},{'2d','nonempty'}); 
% 
% validateattributes(RotorRadius_m,...
%     {'numeric'},{'scalar','positive','nonnan','nonempty'});
% 
% validateattributes(RotorHub_BinIdx,...
%     {'numeric'},{'scalar','positive','nonnan','nonempty','integer'}); 
% 
% validateattributes(RotorTipTop_BinIdx,...
%     {'numeric'},{'scalar','positive','nonnan','nonempty','integer'}); 
% 
% validateattributes(RotorTipBot_BinIdx,...
%     {'numeric'},{'scalar','positive','nonnan','nonempty','integer'}); 

%% Rotor Swept Area
RotorSweptArea_m2 = pi * RotorRadius_m^2;

%% Calculate Binnned Distance from Hub to Rotor Centre
BinDist2RotorCentre...
    = abs(DepthBins_FrmBedorSurf_m(1,RotorTipBot_BinIdx:RotorTipTop_BinIdx)...
        - DepthBins_FrmBedorSurf_m(1,RotorHub_BinIdx));

%% Distance Ratio
DistRatio = BinDist2RotorCentre / RotorRadius_m;                            % Ratio of the binned distance to the total rotor size.

DistRatio(DistRatio > 1) = 1;                                               % Adjust for if the depth bin happens to land exactly on the rotor tip bin.

%% Theta Angle
ThetaAngle = 2 * acosd(DistRatio);  

%% Semicircular Segment Area
SemiCircularSegmentArea...
    = ((RotorRadius_m^2) / 2)...
    * ((pi / 180 * ThetaAngle) - sind(ThetaAngle));

%% Thin Strips
ThinStrips = zeros(size(SemiCircularSegmentArea));                          % Preallocate memory.

% Thin Strips Top  
h = round2((RotorTipTop_BinIdx - RotorTipBot_BinIdx)/2,1);
while h < size(SemiCircularSegmentArea,2)
    ThinStrips(h)...
        = SemiCircularSegmentArea(h)...
        - SemiCircularSegmentArea(h+1);
    h = h + 1;
end  

ThinStrips(h) = SemiCircularSegmentArea(h);
clearvars h;

% Thin Strips Bottom
h = round2((RotorTipTop_BinIdx - RotorTipBot_BinIdx)/2,1);

while h > 1
    ThinStrips(h)...
        = SemiCircularSegmentArea(h)...
        - SemiCircularSegmentArea(h-1);
    h = h - 1;
end  

ThinStrips(h) = SemiCircularSegmentArea(h);            
clearvars h;

%% Power-Weighted Average Velocity
Flow_Vel_Abs_PWA_ms...
    = (sum((BinnedVel_Profile_FrmBedorSurf_ms(:,RotorTipBot_BinIdx:RotorTipTop_BinIdx).^3)...
            .* ThinStrips,2)...
       ./ RotorSweptArea_m2).^(1/3);
 
%% Check if Real
if any(~isreal(Flow_Vel_Abs_PWA_ms))
    warning('Power Weighted Average has been calculated as a complex double! The complex component will be removed. Should the results be erroneous, check the consistency of the "Turbines" inputs.');
    Flow_Vel_Abs_PWA_ms = abs(Flow_Vel_Abs_PWA_ms);
end

%% CHeck if NaN
if any(isnan(Flow_Vel_Abs_PWA_ms))
    error('Power Weighted Average has been calculated as a NaN! This is likely because the rotor swept bins lie outside of the depth bins. Check that the "RotorHub_BinIdx", "RotorTipTop_BinIdx" and "RotorTipBot_BinIdx" inputs do not produce impossible bins to average over (eg a 3m radius rotor with a hub depth of 2m from the surface).');
end

end