%% utm2wgs84dd - UTM Coordinates to WGS84 (decimal degrees) Converter.
% Bathymetry coordinate redefinition function from WGS84 to UTM.
% Main process function for coordinate array/vector transformation.

% Zone is the UTM zone number.
% Hemi is either 'N' (North) or 'S' (South).

% v1.0 - NWC 15/06/2017
% v2.0 - JAM 06/06/2019

function [LAT, LON] = utm2wgs(UTM_E, UTM_N, Zone, Hemi)
[~,A,alpha,beta,delta,E_0,N_0,k_0] = utm_constants;

[rows,cols] = size(UTM_E);
UTM_E = UTM_E / 1e3;
UTM_N = UTM_N / 1e3;

[~,lim] = size(alpha);
if strcmp(Hemi,'N') || strcmp(Hemi,'n') || strcmp(Hemi,'North') || strcmp(Hemi,'north')
    N_0 = 0;
elseif strcmp(Hemi,'S') || strcmp(Hemi,'s') || strcmp(Hemi,'South') || strcmp(Hemi,'south')
    N_0 = 10000;
else
    warning('Check Hemisphere entry.');
end

for i = 1:rows
    for j = 1:cols
        zet = (UTM_N(i,j) - N_0) / (k_0 * A);
        nu  = (UTM_E(i,j) - E_0) / (k_0 * A);
        zet_dash_Pt = zet;
        nu_dash_Pt  = nu;
        
        for q = 1:lim
            zet_dash_Pt = zet_dash_Pt - beta(q)*sin(2*q*zet)*cosh(2*q*nu);
            nu_dash_Pt  = nu_dash_Pt  - beta(q)*cos(2*q*zet)*sinh(2*q*nu);
        end
        
        x_calc = asin(sin(zet_dash_Pt)/cosh(nu_dash_Pt));
        LAT_dec_pt = x_calc;
        
        for q = 1:lim
            LAT_dec_pt = LAT_dec_pt + delta(q)*sin(2*q*x_calc);
        end
        
        LAT.Decimal(i,j) = LAT_dec_pt * (180/pi);
        [LAT.Decimal_Mins{i,j},LAT.DMS{i,j}] = dd2dms(LAT.Decimal(i,j));
        LON.Decimal(i,j) = Zone * 6 - 183 + ((atan(sinh(nu_dash_Pt)/cos(zet_dash_Pt))) * (180/pi));
        [LON.Decimal_Mins{i,j},LON.DMS{i,j}] = dd2dms(LON.Decimal(i,j));
    end
end

end