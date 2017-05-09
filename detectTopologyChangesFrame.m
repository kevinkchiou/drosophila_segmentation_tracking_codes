function [ changeStruct ] = detectTopologyChangesFrame( cell, trackCell, frame )
%DETECTTOPLOGYCHANGESFRAME Summary of this function goes here
%   Detailed explanation goes here

%Initialize tracking variables
currentTopology = cell{frame};
currentTracking = trackCell{frame};
currentCellIdLookUp = cat(1,currentTracking.cellID);
currentIdLookUp = cat(1,currentTracking.id);
nextTopology = cell{frame+1};
nextTracking = trackCell{frame+1};
nextCellIdLookUp = cat(1,nextTracking.cellID);
nextIdLookUp = cat(1,nextTracking.id);
nCells = length(currentTopology);

%Initialize out variables
changeIdx = 1;
changeStruct = struct('cellID',0,'CurrentNeighbors',[],...
                'NextNeighbors',[]);

%display(nextCellIdLookUp)

%Check whether associated cells have correct neighbor structure
for i = 2:nCells %Exclude boundary
    currentNeighbors = currentTopology(i).ncells;
    trackIdx = currentIdLookUp(currentCellIdLookUp == i);
    nextIdx = nextCellIdLookUp(nextIdLookUp == trackIdx);
    %display(nextIdx)
    if (~isempty(nextIdx) && nextIdx~=0)
        %display(nextIdx)
        nextNeighbors = nextTopology(nextIdx).ncells;
        correctedNextNeighbors = correctNeighbors(nextNeighbors);
        changes = setxor(currentNeighbors,correctedNextNeighbors);
        if i==100
            display(currentNeighbors)
            display(correctedNextNeighbors)
        end
        if numel(changes) ~= 0
            changeStruct(changeIdx) = struct('cellID',i,'CurrentNeighbors',currentNeighbors,...
                'NextNeighbors',correctedNextNeighbors);
            changeIdx = changeIdx + 1;
        end
    else
        display('Cell Not Found')
    end
    clearvars currentNeighbors nextNeighbors
end

%% Correct Neighbors
% Takes in a list of neighbors from a cell in the next frame, and returns
% the corresponding list of neighbors in the original frame, when they can
% be found.

    function [ corr ] = correctNeighbors( in )
        nNeighb = length(in);
        corr = -ones(1,nNeighb);
        for j=1:nNeighb
            idx = nextIdLookUp(nextCellIdLookUp==in(j));
            cellIdx = currentCellIdLookUp(currentIdLookUp==idx);
            if (~isempty(cellIdx) && cellIdx~=0)
                corr(j) = cellIdx;
            end
        end
        corr = corr(corr>-1);
    end

end

