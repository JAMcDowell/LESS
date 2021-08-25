%% dd2dms - Decimal Degrees to Degrees, Minutes, Seconds 
% Coordinate conversion from decimal lat,long to other formats.

% v1.0 NWC 15/06/2017

function [Decimal_Mins,DMS] = dd2dms(Coord)
if Coord > 0
    Decimal_Mins = sprintf('%dd %5.6f''',floor(Coord),(Coord-floor(Coord))*60);
    DMS = sprintf('%dd %d'' %5.4f"',floor(Coord),floor((Coord-floor(Coord))*60),((Coord-floor(Coord))*60 - floor((Coord-floor(Coord))*60))*60);
else
    Decimal_Mins = sprintf('%dd %5.6f''',ceil(Coord),-(Coord-ceil(Coord))*60);
    DMS = sprintf('%dd %d'' %5.4f"',ceil(Coord),-ceil((Coord-ceil(Coord))*60),-(((Coord-ceil(Coord))*60 - ceil((Coord-ceil(Coord))*60))*60));
end

end