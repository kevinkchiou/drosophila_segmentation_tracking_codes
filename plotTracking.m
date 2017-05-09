function [ outImage ] = plotTracking( L, trackCell, cellNums )
%PLOTTRACKING Takes in a segmentation array (L), set of tracking structs (trackCell),
%and a specification for a set of cells to track (cellNums), and outputs a movie array
%(outImage) with the selected cell highlighted.

%Initialize size parameters
sz = size(L);
nFrames = sz(3);
nC = length(cellNums);

%Initialize out variables
outImage = zeros(sz);

%Initialize tracking array
trackArray = -ones(nC,nFrames);

for i=1:nFrames
    idArray = cat(1,trackCell{i}.id);
    cellArray = cat(1,trackCell{i}.cellID);
    for j=1:nC
        findArray = (idArray==cellNums(j));
        arrayID = find(findArray);
        if isempty(arrayID)
        else
            trackArray(j,i) = cellArray(arrayID);
        end
    end
end

for i=1:nFrames
    %Color the cells
    for j=1:nC
        outImage(:,:,i) = (j+1)*(L(:,:,i) == trackArray(j,i)) + outImage(:,:,i);
    end
    %Fill in the borders
    outImage(:,:,i) = outImage(:,:,i) + (L(:,:,i)==0);
end

end