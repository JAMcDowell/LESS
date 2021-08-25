function [OptimalPath,...
          HScore, GScore] = astar2(StartX, StartY,...
                                   BinaryMobilityMap,...
                                   PrimaryGoalRegisterMap,...
                                   SecondaryHeuristicMap,...                     
                                   HeuristicWeighting,...
                                   Connecting_Distance)                             
%% Function Description
% A* Path in an Occupancy Grid with Multiple Heuristics
% Based on the astar script by  Einar Ueland (02/05/16):
% https://uk.mathworks.com/matlabcentral/fileexchange/56877-astar-algorithm
 
% J.McDowell, 02/05/19: Heuristic Weighting, additional outputs
% J.McDowell, 12/05/20: Cost of Graph movement. Large efficiency increase
% through vectorisation. Multiple Heuristics introduced.

%% Inputs Description
%

%% Outputs Description
%

%% Input Checks
% This is a highly iterative script, and therefore no checks are included
% as they will decrease performance. Please ensure that the size and shape
% of the inputs are as described in the "Inputs Description" section above.

%% Preallocation of Matrices
[X,Y]   = size(BinaryMobilityMap);                                          % Height and width of matrix.
GScore  = single(zeros(X,Y));                                               % Matrix keeping track of G-scores.
HScore  = single(zeros(X,Y));                                               % Goal Proximity and Secondary Heuristic matrix.
FScore  = single(inf(X,Y));                                                 % Matrix keeping track of F-scores (only open list). 
OpMAT   = int8(zeros(X,Y));                                                 % Matrix keeping of open grid cells.     
ParentX = int16(zeros(X,Y));                                                % Matrix keeping track of X position of parent.
ParentY = int16(zeros(X,Y));                                                % Matrix keeping track of Y position of parent.
ClMAT   = int8(BinaryMobilityMap);                                          % Matrix keeping track of closed grid cells. Adding object-cells to closed matrix.               

%% Setting up matrices representing neighbours to be investigated
NBCheck = ones(2 * Connecting_Distance + 1);
Dummy   = (2 * Connecting_Distance + 2);
Mid     = Connecting_Distance + 1;

for i = 1:(Connecting_Distance - 1)
    NBCheck(i,i)             = 0;
    NBCheck(Dummy-i,i)       = 0;
    NBCheck(i,Dummy-i)       = 0;
    NBCheck(Dummy-i,Dummy-i) = 0;
    NBCheck(Mid,i)           = 0;
    NBCheck(Mid,Dummy-i)     = 0;
    NBCheck(i,Mid)           = 0;
    NBCheck(Dummy-i,Mid)     = 0;
end

NBCheck(Mid,Mid) = 0;
[row, col]       = find(NBCheck == 1);
Neighbours       = [row col]-(Connecting_Distance + 1);
N_Neighbours     = size(col,1);

%% Registered Goal Nodes
[col, row]      = find(PrimaryGoalRegisterMap);
RegisteredGoals = [row, col];

%% Creating Heuristic-matrix based on Proximity to nearest goal node (inefficient, but useful for demonstrating how multiple goals are defined)
%Nodesfound      = size(RegisteredGoals,1);
% tic;
% for x = 1:size(GoalRegisterMap,1)
% for y = 1:size(GoalRegisterMap,2)
%     if BinaryMobilityMap(x,y) == 0
%         HScore(x,y)...                                                    % Below is same as: norm(goal-[x,y]) 
%             = (min(sqrt(sum(abs((RegisteredGoals - (repmat([y, x],(Nodesfound),1)))).^2, 2))))... 
%             * HeuristicWeighting;                                         % Note: If HeuristicWeighting is set to zero the method will reduce to the Dijkstras method.
%     end
% end
% end
% toc;

%% Creating Heuristic-matrix based on Proximity to nearest goal node (vectorised for large efficiency increase)
[x,y] = ind2sub(size(BinaryMobilityMap),find(~BinaryMobilityMap));  
HScore(~BinaryMobilityMap)...
    = (min(sqrt((bsxfun(@minus, RegisteredGoals(:,1)', y)).^2 + (bsxfun(@minus, RegisteredGoals(:,2)', x)).^2),[],2)...
    + SecondaryHeuristicMap(~BinaryMobilityMap))...
    * HeuristicWeighting;

%% Initialising start node with FValue and opening first node.
FScore(StartY,StartX) = HScore(StartY,StartX);                               % Actually, FScore(StartY,StartX) = GScore(StartY,StartX) + HScore(StartY,StartX), but since GScore will always be zero, save on an operation.
OpMAT(StartY,StartX)  = 1;   

%% A* Algorithm
while 1 == 1                                                                % Loop will break when path found or when no path exist
    %% Find node from open set with smallest FScore
    MINopenFSCORE = min(min(FScore));
    if MINopenFSCORE == inf                                                 % Failure! No path exists.
        OptimalPath     = inf;
        RECONSTRUCTPATH = 0;
        break
    end
    [CurrentY, CurrentX] = find(FScore == MINopenFSCORE);
    CurrentY = CurrentY(1);                                                 % If there are two values returned, just take the first.
    CurrentX = CurrentX(1);

    if PrimaryGoalRegisterMap(CurrentY,CurrentX)                                   % Goal! A path is found.
        RECONSTRUCTPATH = 1; 
        break
    end
    
    %% Removing node from OpenList to ClosedList  
    OpMAT(CurrentY,CurrentX)  = 0;
    FScore(CurrentY,CurrentX) = inf;
    ClMAT(CurrentY,CurrentX)  = 1;
    for p = 1:N_Neighbours
        i = Neighbours(p,1);                                                % Y
        y = Neighbours(p,2);                                                % X
        if CurrentY+i < 1 || CurrentY+i > X ...
        || CurrentX+y < 1 || CurrentX+y > Y
            continue
        end
        
        Flag = 1;
        
        if ClMAT(CurrentY+i, CurrentX+y) == 0                               % If neighbour is open...
            if (abs(i) > 1 || abs(y) > 1)   
                %% Check that the path does not pass an object
                JumpCells = (2 * max(abs(i),abs(y))) - 1;
                for K = 1:JumpCells
                    YPOS = round(K*i / JumpCells);
                    XPOS = round(K*y / JumpCells);
                    if BinaryMobilityMap(CurrentY+YPOS, CurrentX+XPOS)
                        Flag = 0;
                    end
                end
            end
            
            %% Brute Force
            if Flag
                %% Movement Cost
                tentative_gScore = norm([i,y]) + GScore(CurrentY,CurrentX); % Norm = Vector and matrix norms (sqrt(i^2 + y^2))  
                if OpMAT(CurrentY+i, CurrentX+y) == 0
                    OpMAT(CurrentY+i, CurrentX+y) = 1;                    
                elseif tentative_gScore >= GScore(CurrentY+i, CurrentX+y)
                    continue
                end
                
                %% Parents
                ParentX(CurrentY+i,CurrentX+y) = CurrentX;
                ParentY(CurrentY+i,CurrentX+y) = CurrentY;
                
                %% GScore
                GScore(CurrentY+i,CurrentX+y) = tentative_gScore;

                %% F Score 
                FScore(CurrentY+i,CurrentX+y)...
                    = GScore(CurrentY+i,CurrentX+y)...        
                    + HScore(CurrentY+i,CurrentX+y);
                
            end
        end
    end
end

%% Make path
x = 2;
if RECONSTRUCTPATH
    OptimalPath(1,:) = [CurrentY, CurrentX];
    while RECONSTRUCTPATH
        CurrentXDummy    = ParentX(CurrentY, CurrentX);
        CurrentY         = ParentY(CurrentY, CurrentX);
        CurrentX         = CurrentXDummy;
        OptimalPath(x,:) = [CurrentY CurrentX];
        x = x + 1;  
        if (((CurrentX == StartX)) && (CurrentY == StartY))
            break
        end     
    end
end

end