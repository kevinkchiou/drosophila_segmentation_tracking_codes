%Tracking Visualization script.

nFrames = length(trackCell);
forwardTrack = cell(nFrames,1);

%Reverse the trackCell, since the tracking algorith runs in -t
for i=1:nFrames
    forwardTrack{i} = trackCell{nFrames + 1 - i};
end

%Select cells
cell_list = userCellSelection(L(:,:,1),1,[],c{1});

%Find the indices needed to identify the selected cells in the tracking
%struct
track_list = zeros(length(cell_list),1);
idArray = cat(1,forwardTrack{1}.id);
cellArray = cat(1,forwardTrack{1}.cellID);
for i=1:length(cell_list)
    findArray = (cellArray==cell_list(i));
    arrayID = find(findArray);
    track_list(i) = idArray(arrayID);
end

%Create a movie of the selected cells.
movie = plotTracking(L,forwardTrack,track_list);

%Create a movie of the velocity fields
[x,y,u,v] = makeVelocityFields(stateVec);