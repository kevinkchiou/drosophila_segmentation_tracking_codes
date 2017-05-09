function [ t1Struct, possibleNonLocalCount ] = detectT1Frame( cellStruct, topStruct )
%UNTITLED5 Note: This function assumes convexity of the interesting cell
%array. If problematic, we can implement a more complete characterization.
%   Detailed explanation goes here

%Initialize size variables
nCells = length(cellStruct);
nTop = length(topStruct);

%Initialize Out Variables
t1Struct = struct('Cells',[],'OldConnection',[],'NewConnection',[]);
t1Count = 1;
possibleNonLocalCount = 0;

%Initialize adjacency matrices
currentAdjMatrix = eye(nCells); %This sets all trivial zeroes to 1, so that checking algorith is easier
nextAdjMatrix = eye(nCells);

%Create adjacency matrices. Only fill in entries flagged for topological
%changes.
display('Creating Adjacency Matrices')
for i = 1:nTop
    id = topStruct(i).cellID;
    current = topStruct(i).CurrentNeighbors;
    next = topStruct(i).NextNeighbors;
    currentAdjMatrix(id,current) = 1;
    nextAdjMatrix(id,next) = 1;
end

%Create vector of cell identities flagged for topological change
changedCells = cat(1,topStruct.cellID)';

%Create matrix of combinations of cells flagged for topological change
possibleT1 = nchoosek(changedCells,4);
nComb = size(possibleT1,1);

%Check for topological indicators of T1-- just for number of connections
%being consistent
display('Finding T1s')
for i = 1:nComb;
    combination = possibleT1(i,:);
    redCurrent = currentAdjMatrix(combination,combination);
    indicator = sum(sum(redCurrent));
    if indicator == 12 %Possible 4-vertex, indicating non-local T1
        possibleNonLocalCount = possibleNonLocalCount + 1;
    elseif indicator == 14 %Possible T1 start
        redNext = nextAdjMatrix(combination,combination);
        indicator2 = sum(sum(redNext));
        if indicator2 == 12 %Possible 4-vertex
            possibleNonLocalCount = possibleNonLocalCount + 1;
        elseif indicator2 == 14 %Possible T1 end
            checkT1(combination,redCurrent,redNext);
        end
    end
end

function checkT1(combination,redCurrent,redNext)
    checkMatrix = redCurrent.*redNext;
    checkVec = sum(checkMatrix);
    checkVec = (checkVec == 3);
    if sum(checkVec) == 4
        cells = combination;
        old = [];
        new = [];
        t1Struct(t1Count) = struct('Cells', cells,'OldConnection', old,'NewConnection', new);
        t1Count = t1Count + 1;
    end
end

end

