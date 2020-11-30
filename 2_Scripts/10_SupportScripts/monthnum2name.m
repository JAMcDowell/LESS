function [MonthName] = monthnum2name(MonthNumber,MonthFormat)
%% monthnum2name
% J.McDowell - 10/07/20
% Simple function to convert month number to month name (eg [7] to 'July'). 
% Multiple numeric inputs are accepted (eg [5,8] outputs {'May','August'}).

%% Inputs
% MonthNumber: Numeric array of integers within the range 1 to 12. 
% Multiple numeric inputs accepted in the form [m1,m2,mn...].
% MonthFormat: Character array that must equal either 'First','Short' or 
% 'Long'. Input is not case sensitive and abbreviations are accepted.
% 'First' will output the first letter of the month (eg 'S' for September). 
% 'Short' will output the first 3 letters of the month (eg 'Jun' for June).
% 'Long'  will output the full month name (eg 'January' for the 1st month).

%% Outputs
% MonthName - character or cell array (if multiple numeric inputs given) of
% month names in the user specified Format.

%% Input Checks
validateattributes(MonthNumber,{'numeric'},{'positive','integer','<=',12,'finite','nonnan'})
MonthFormat = validatestring(MonthFormat, {'First','Short','Long'});

%% Calculate MonthNames for Specified Format
switch MonthFormat
    case {'Short','Long'}
        MonthNames = month(datetime(1, 1:12, 1), MonthFormat);
    case {'First'}
        MonthNames = month(datetime(1, 1:12, 1), 's');
        for m = 1:12
            MonthNames{1,m} = MonthNames{1,m}(1,1);                         % Extract only the first letter of each month.
        end
end
 
%% Output MonthName
if isscalar(MonthNumber)                                                    % If one number is input...
    MonthName = MonthNames{MonthNumber};                                    % Create character array output.
else                                                                        % Otherwise if more than one number is input [1,2,5,...]
    MonthName = MonthNames(MonthNumber);                                    % Store character array in cell array output.
end

end