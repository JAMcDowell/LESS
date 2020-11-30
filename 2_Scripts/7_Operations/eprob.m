function [EXC,...
          ProbExc,...
          ProbThresholdExc] = eprob(Data,...
                                    Threshold)
%% Written by Jeff Tuhtan, Adapted by JAM 09/05/19
% eprob: calculates the exceedance probability for n column vectors in the
%        array [m n] X, where m are the observations. The probability is 
%        output in percent. eX is output as a structure (see Output Arguments).
%
% Usage: eX = eprob(X);
%
% Input Arguments:
%
%   X - [m n] vector where m are the observations and n are the number of
%   datasets for which the exceedance probability is to be calculated. 
%   The size of m must be the same for all datasets.
%
% Output Arguments:
%
%   eX - structure array containing all output data
%   ex.data - input data X [m n]
%   ex.r - the number of rows, m
%   ex.c - the number of datasets (columns), n
%   ex.sort - X input data sorted in descending order
%   ex.rank - single column matrix of the sorted data rank
%   ex.eprob - calculated exceedance probability (rank/m+1)
%
% Example:
% X  = randn(1000,1) % create randomly distributed dataset with 1000 values
% eX = eprob(X);

% Scap = 10; % active operational energy storage capacity
% Scap = StorCapPercent % eX average annual generation

%% Inputs Checks

%% Ranking and Exceedance
if max(size(size(Data))) == 2
    EXC = struct;
else
    error('Array must be in 2-dimensional [m,n]')
end

if size(Data,1) > size(Data,2)
    EXC.SortedData = Data;
else
    EXC.SortedData = Data';
end

Rows = size(EXC.SortedData,1); % no. rows
%Cols = size(EXC.SortedData,2); % no. cols

EXC.SortedData  = sort(EXC.SortedData,'descend');                           % Sort data in descending order.
EXC.Rank        = (1:Rows)';
EXC.ProbExc     = zeros(Rows,1);
EXC.ProbExc     = EXC.Rank./(Rows+1);

%% Quick Plot
% title('plotting eeXceedance probability curve (in %)')
% plot(eX.eprob.*100,eX.sort,'r-','LineWidth',2);
% xlabel('Exceedance Probability (%)','FontWeight','Bold');
% ylabel('Value','FontWeight','Bold');

%% Return Period
EXC.RecurrencePeriod = 1./EXC.ProbExc;

%% Threshold Exceedance
if max(Data) < Threshold                                                    % If the maximum value is less than the threshold...
    EXC.ProbThreshExc = 1/Rows;
    
else                                                                        % Otherwise...
    [~, DataMinIndex] = (min(abs(EXC.SortedData - Threshold)));
    EXC.ProbThreshExc = EXC.ProbExc(DataMinIndex);
    
end

%% Output Variables
ProbExc = EXC.ProbExc;
ProbThresholdExc = EXC.ProbThreshExc;

end
