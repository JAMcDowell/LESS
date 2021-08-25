function [LCoE_CCCpkWh] = lcoe(CapEx_CCC,...
                               AnnualOpex_CCCpy,...
                               DecEx_CCC,...
                               AnnualEnergyDelivered_kWh,...
                               ProjectLength_y,...
                               DiscountRate_pc)
%% Discount Rate
r = DiscountRate_pc ./ 100;

%% 'Annual' CapEx
Annual_Capex    = zeros(1,ProjectLength_y);
Annual_Capex(1) = CapEx_CCC;

%% Annual OpEx
Annual_OpEx        = zeros(1,ProjectLength_y);
Annual_OpEx(1:end) = AnnualOpex_CCCpy;

%% 'Annual' DecEx
Annual_DecEx      = zeros(1,ProjectLength_y);
Annual_DecEx(end) = DecEx_CCC;

%% LCOE Calculation
Annual_TotalCosts = zeros(1,ProjectLength_y);

for y = 1:ProjectLength_y
    Annual_TotalCosts(y)...
        = (Annual_Capex(y)./ ((1+r) .^ 0))...
        + (Annual_OpEx(y) ./ ((1+r) .^ y))...
        + (Annual_DecEx(y)./ ((1+r) .^ ProjectLength_y));
end

LCoE_CCCpkWh...
    = sum(Annual_TotalCosts) ./ (AnnualEnergyDelivered_kWh .* ProjectLength_y);

end
