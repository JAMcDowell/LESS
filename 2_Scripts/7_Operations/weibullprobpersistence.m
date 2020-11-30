function [WPM,...
          WbProbPersistence,...
          NumberHoursWaitingForAccess]...
            = weibullprobpersistence(Wave_Hs_m,...
                                     Wave_Hs_ProbExceedance,...
                                     AccessLimit_Wave_Hs_m,...
                                     RequiredAccessDuration_h)
%% Inputs Description
% Wave_Hs_m [tx1] - Hourly intervals.

% Wave_Hs_ProbExceedance [tx1] - Hourly intervals.
 
% AccessLimit_Wave_Hs_m [1x1]

% RequiredAccessDuration_h [1x1]

%% Outputs Description
% WPM

% WbProbPersistence

% NumberHoursWaitingForAccess

%% Input Checks
% Attribute Checks
validateattributes(Wave_Hs_m,...
                   {'numeric'},...
                   {'column','nonempty','nonnegative'});
validateattributes(Wave_Hs_ProbExceedance,...
                   {'numeric'},...
                   {'column','nonempty','nonnegative'});
                
validateattributes(AccessLimit_Wave_Hs_m,...
                   {'numeric'},...
                   {'scalar','nonempty','positive'});

validateattributes(RequiredAccessDuration_h,...
                   {'numeric'},...
                   {'scalar','nonempty','positive'});                  
 
% Size Checks
if ~isequal(size(Wave_Hs_m,1),...
            size(Wave_Hs_ProbExceedance,1))
    error('"Wave_Hs_m" and "Wave_Hs_ProbExceedance" must have the same number of rows.');
    
end   

%% Total Duration
WPM.D_TotalDuration_h = size(Wave_Hs_m,1);                                  % Total data duration is size of dataset, assuming hourly inputs.

WPM.RequiredAccessDuration_h = RequiredAccessDuration_h;                    % Store required Access Duration.

%% Access Limit Adjust
AccessLimit_Wave_Hs_m(AccessLimit_Wave_Hs_m < min(Wave_Hs_m))...            % In order to prevent creation of complex doubles, any limit smaller than the smallest wave in the data set, is set to be the same as the smallest data set, such that H - XO is not less than zero.
    = min(Wave_Hs_m);                   

WPM.AccessLimit_Wave_Hs_m = AccessLimit_Wave_Hs_m;                          % Store Hs Access Limit.

%% Sort Data & Probability Exceedance
Sorted_Wave_Hs_m           = double(sort(Wave_Hs_m,'descend'));             % Sort and convert to double, in case data is not already in this format.
Sorted_Wave_ProbExceedance = double(sort(Wave_Hs_ProbExceedance,'ascend'));

%% Weibull Two-Parameter Fit
Wb2PF.parmhat = wblfit(Sorted_Wave_Hs_m);                                   % Two-parameter Weibull Fit, to give first pass estimation of...

Wb2PF.b_Scale  = (Wb2PF.parmhat(1));                                        % Scale (b) and...
Wb2PF.k_Shape  = (Wb2PF.parmhat(2));                                        % Shape (k) Parameters.
Wb2PF.X0_Shift = 0;                                                         % Intial Shift (X0) Parameter is set to zero for a two-parameter Weibull Fit.

%% Weibull Three-Parameter Fit
% Wb3PF.Weibull3ProbDistFunction...                                           % Three-parameter Weibull Fit allows for shifting of distribution along x-axis for better fit with data.   
%     = @(x,a,b,c) (x>c).*(b/a).*(((x-c)/a).^(b-1)).*exp(-((x-c)/a).^b); 
% 
% Wb3PF.opt = statset('MaxIter',1e5,'MaxFunEvals',1e5,'FunValCheck','off');   
% 
% Wb3PF.parmhat...                                
%     = mle(Sorted_Wave_Hs_m,...                                          
%           'pdf',       Wb3PF.Weibull3ProbDistFunction,...           
%           'Options',   Wb3PF.opt,...                                             
%           'start',     [Wb2PF.b_Scale, Wb2PF.k_Shape, Wb2PF.X0_Shift],...   % Utilise the Two-parameter Weibull Fit Parameters for an initial estimate of the Three-Parameters (reduces processing time).             
%           'LowerBound',[0, 0, 0],...                                        % Including reasonable lower and upper bounds for parameters also decreases iterations for the maximum likelihood estimates (mle) solver.
%           'UpperBound',[5, 5, min(Wave_Hs_m)]);                             % The Weibull probability density function is positive only for x > c. This constraint means that the location parameter (c) must be smaller than the minimum of the sample data.
% 
% 
% Wb3PF.b_Scale  = Wb3PF.parmhat(1);                                          % Three-parameter Scale (b) Parameter.
% Wb3PF.k_Shape  = Wb3PF.parmhat(2);                                          % Three-parameter Shape (k) Parameter.
% Wb3PF.X0_Shift = Wb3PF.parmhat(3);                                          % Three-parameter Shift (XO) Parameter.

%% Weibull Probability of Exceedance
WPM.Prob_Exceedance = Sorted_Wave_ProbExceedance;                           % Store standard Probability of Exceedance (for comparison against Weibull probability of exceedance).
WPM.WbProb_Exceedance...                                                    % Weibull Probability of Hs data values being exceeded.
    = exp(-((Sorted_Wave_Hs_m - Wb2PF.X0_Shift) ./ Wb2PF.b_Scale) .^ Wb2PF.k_Shape);         

WPM.WbProb_HsAccessLimitExceeded...                                         % Weibull Probability of "AccessLimit_Wave_Hs_m" being exceeded.
    = exp(-((AccessLimit_Wave_Hs_m - Wb2PF.X0_Shift) ./ Wb2PF.b_Scale) .^ Wb2PF.k_Shape);   

%% Calculate Mean Hs
WPM.HsMean_m = mean(Wave_Hs_m);                                             % Visual check that the numerical mean is approximately equal to the

WPM.HsBar_m...                                                              % Distribution derived mean.    
    = Wb2PF.b_Scale .* gamma(1 + (1 ./ Wb2PF.k_Shape)) + Wb2PF.X0_Shift;   

%% Adjusted Weibull Shape Parameters
Wb2PF.Gamma_Shape...                                                        % Cumulative distribution function shape parameters. Relating the emperically derived Weibull distribution shape to the cumulative distribution function of the raw data.
    = Wb2PF.k_Shape + ((1.8 .* Wb2PF.X0_Shift) ./ (WPM.HsBar_m - Wb2PF.X0_Shift));         

Wb2PF.AlphaAcc_Shape_HsAccessLimitNotExceeded...
    = 0.267 .* Wb2PF.Gamma_Shape .* (AccessLimit_Wave_Hs_m ./ WPM.HsBar_m) .^ -0.4;

Wb2PF.CAcc_Shape_HsAccessLimitNotExceeded...
    = (gamma(1 + (1 ./ Wb2PF.AlphaAcc_Shape_HsAccessLimitNotExceeded)))...
    .^ Wb2PF.AlphaAcc_Shape_HsAccessLimitNotExceeded;

%% Empirically Derived Constants
Wb2PF.A_Graham    = 20;                                                     % Statistically derived constants to relate wave data to Weibull distribution shape. 
Wb2PF.Beta_Graham = 0.7692;                                                 % Originally proposed by Graham (1982)for North Sea wave data, useful to check against distribution derived constants below.

Wb2PF.A_Emp    = 35.* (Wb2PF.Gamma_Shape .^ -0.5);                          % Kuwashima & Hogben (1986) allowed variations in the parameters A and Beta by deriving empirical relations (based on exceedance data) between 
Wb2PF.Beta_Emp = 0.6.*(Wb2PF.Gamma_Shape .^ 0.287);                         % the parameters and a Weibull Shape parameter (k) for the input distribution defined in terms of a 2-parameter Weibull distribution.         

%% Average Duration of Exceedance of Waves (Hs) for a Threshold Height
WPM.TauG_AverageDurationHsAccessLimitExceeded_h...                          % Average Duration that Waves Exceed the access limit.
    = Wb2PF.A_Emp ./ ((-log(WPM.WbProb_HsAccessLimitExceeded)) .^ Wb2PF.Beta_Emp);              

%% Average Duration of Non-Exceedance Waves for a Threshold Height
WPM.TauAcc_AverageDurationHsAccessLimitNotExceeded_h...                     % 1-"Probability of operational wave limit being exceeded" gives the probability and average duration of wave limit NOT being exceeded.
    = ((1 - WPM.WbProb_HsAccessLimitExceeded) ./ WPM.WbProb_HsAccessLimitExceeded)...
    .* WPM.TauG_AverageDurationHsAccessLimitExceeded_h; 

%% Normalised Duration
WPM.Xi_NormalisedDurationHsAccessLimitNotExceeded_h...                      % Required access duration is normalised against the average duration of the wave limit NOT being exceeded.    
    = RequiredAccessDuration_h...
    ./ WPM.TauAcc_AverageDurationHsAccessLimitNotExceeded_h;       

%% Cumulative Distribution of Duration
WPM.WbProb_NormalisedDurationNotExceeded...                                 % Probability of Required Duration not being exceeded.
    = exp(-Wb2PF.CAcc_Shape_HsAccessLimitNotExceeded...
          .* (WPM.Xi_NormalisedDurationHsAccessLimitNotExceeded_h...
          .^ Wb2PF.AlphaAcc_Shape_HsAccessLimitNotExceeded)); 
      
%% Probability of Persistence
WPM.WbProb_Persist_AccessDurationExceeded_HsAccessLimitNotExceeded...       % Probability of required wave access period persisting for the required duration.
    = WPM.WbProb_NormalisedDurationNotExceeded...
    .* (1 - WPM.WbProb_HsAccessLimitExceeded);                      

%% Number of Access Hours
WPM.Nac_NumberAccessHours...                                                % Multiply probability of persistence by total duration to get available access hours within the month.
    = WPM.WbProb_Persist_AccessDurationExceeded_HsAccessLimitNotExceeded...
    .* WPM.D_TotalDuration_h;                   

%% Number Waiting Hours
WPM.Nwa_NumberHoursWaitingForAccess...                                      % Use Weibull Fatigue statistics to transform frequency into the time domain for likely waiting times for the required access hours within the month.
    = (WPM.D_TotalDuration_h - (WPM.Nac_NumberAccessHours .* WPM.TauAcc_AverageDurationHsAccessLimitNotExceeded_h))...
    ./ WPM.Nac_NumberAccessHours; 

WPM.Nwa_NumberHoursWaitingForAccess...                                      % If the total waiting hours exceeds the hours available in the data set... (waiting hours longer than 1 month within a month data set implies operation failure)
    (WPM.Nwa_NumberHoursWaitingForAccess > WPM.D_TotalDuration_h)...        
        = WPM.D_TotalDuration_h - 0.01234;                                  % Set the total waiting hours to be for the entire month (minus a small amount for visually flagging this occurence).

WPM.Nwa_NumberHoursWaitingForAccess...                                      % If the total number of waiting hours is less than zero (impossible, but means no waiting is predicted)...
    (WPM.Nwa_NumberHoursWaitingForAccess < 0) = 0.01234;                    % Set the total number of waiting hours to be zero (plus a small amount for visually flagging this occurence).

%% Output Variables
WbProbPersistence...
    = WPM.WbProb_Persist_AccessDurationExceeded_HsAccessLimitNotExceeded;

NumberHoursWaitingForAccess = WPM.Nwa_NumberHoursWaitingForAccess;

end