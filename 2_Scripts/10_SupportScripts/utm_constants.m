%% UTM Constants
% Bathymetry coordinate redefinition function from WGS84 to UTM.
% https://en.wikipedia.org/wiki/Universal_Transverse_Mercator_coordinate_system

% v1.0 - NWC 26/04/2017
% v2.0 - NWC 22/10/2018

function [n,A,alpha,beta,delta,E_0,N_0,k_0] = utm_constants
  a   = 6378.137;
  f   = 1/298.257223563;
  N_0 = 0;
  k_0 = 0.9996;
  E_0 = 500;
  
  n = f/(2-f);
  A = (a/(1+n))*(1 + (n^2/4) + (n^4/64) + (n^6/256) + ((25*n^8)/16384));
  
  alpha(1) = (1/2)*n - (2/3)*n^2 + (5/16)*n^3 + (41/180)*n^4;
  alpha(2) = (13/48)*n^2 - (3/5)*n^3 + (557/1440)*n^4;
  alpha(3) = (61/240)*n^3 - (103/140)*n^4;
  alpha(4) = (49561/161280)*n^4;
  
  beta(1) = (1/2)*n - (2/3)*n^2 + (37/96)*n^3 - (1/360)*n^4;
  beta(2) = (1/48)*n^2 + (1/15)*n^3 - (437/1440)*n^4;
  beta(3) = (17/480)*n^3- (37/840)*n^4;
  beta(4) = (4397/161280)*n^4;
  
  delta(1) = 2*n - (2/3)*n^2 - 2*n^3;
  delta(2) = (7/3)*n^2 - (8/5)*n^3;
  delta(3) = (56/15)*n^3;
  delta(4) = 0;
end