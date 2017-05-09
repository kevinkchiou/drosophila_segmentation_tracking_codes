function [ cellList ] = trackSingleCellKalman( L, cellNum, cellStruct )
%TRACKSINGLECELLKALMAN Takes in a 3-d array of segmentations (2d+t) representing the time slices to track
%through, an integer specification cellNum for the cell to track, and a struct
%cellStruct to get the centroid info. Returns a list cellList that
%specifies the cell number in each frame corresponding to the tracked cell.
%Code copied/modified from provided example in MATLAB for Kalman filter

%Size constants
sz = size(L);
nFrames = sz(3);

%Initialize the output
cellList = -ones(1,sz(3));
cellList(1) = cellNum;

%Start the Kalman Filter
param = getParameters;
kalmanFilter = configureKalmanFilter(param.motionModel, ...
param.initialLocation, param.initialEstimateError, ...
param.motionNoise, param.measurementNoise);

%Initialize variables
trackedLocation = correct(kalmanFilter, param.initialLocation);
detectedLocation = [0,0];

%Track through frames
for i=2:nFrames
    trackedLocation = predict(kalmanFilter);
    if leftBoundary(trackedLocation)
        display('Left boundary during tracking.');
        break
    end
    %nextCell = overlapDetect(L(:,:,i), trackedLocation, cellStruct{i-1}(cellList(i-1)));
    nextCell = centroidMin(trackedLocation,cellStruct{i});
    detectedLocation = cellStruct{i}(nextCell).centroid;
    cellList(i) = nextCell;
    correct(kalmanFilter, detectedLocation);
    if nextCell == 1
        display('Joined boundary during tracking.');
        break
    end
end

function num = centroidMin(trackedLocation, prevCellInfo)
    centList = cat(1,prevCellInfo.centroid);
    sub = centList - repmat(trackedLocation,length(centList),1);
    dist = sqrt(sub(:,1).^2 + sub(:,2).^2);
    [~,num] = min(dist);
end

%Detects if tracked location leaves the frame
function isGone = leftBoundary(trackedLocation)
    x = trackedLocation(1);
    y = trackedLocation(2);
    if (x<0.5 || x>(sz(2)+0.5) || y<0.5 || y>(sz(1)+0.5))
        isGone = 1;
    else
        isGone = 0;
    end
end

%Associate prev cell to next cell
function num = overlapDetect(M, trackedLocation, prevCellInfo)
    tVec = trackedLocation - prevCellInfo.centroid;
    pixels = translateCell(tVec, prevCellInfo.pixels);
    overlapList = M(pixels);
    overlapList = overlapList(overlapList>0);
    num = mode(overlapList);
end

%Given a list of pixels and an x-y coordinate to translate them by, returns
%the list of translated pixels
function pixels = translateCell(tVec, inputP)
    numPix = length(inputP);
    pixels = -ones(1,numPix);
    for j = 1:numPix
        currPix = inputP(j);
        [r,c] = ind2sub(sz(1:2),currPix);
        x = c + tVec(1);
        y = r + tVec(2);
        if ~leftBoundary([x,y])
            pixels(j) = sub2ind(sz(1:2),round(y),round(x));
        end
    end
end
    
%Define some parameters for Kalman filter
function param = getParameters
  param.motionModel           = 'ConstantVelocity';
  param.initialEstimateError  = 1E5 * ones(1, 2);
  param.initialLocation = cellStruct{1}(cellNum).centroid;
  param.motionNoise           = [50, 50];
  param.measurementNoise      = 25;
end

end

