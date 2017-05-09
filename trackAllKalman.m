function [ trackCell, stateVec ] = trackAllKalman( L, cellStruct )
%TRACKALLKALMAN Takes in a set of segmentation arrays L and the topological
%cell info contained in cellStruct and returns the history of all track structs as defined below.
%Uses a Kalman filter to generate predicted locations for
%cost assignment. Much of this code is copied and modified from MATLAB's
%multiObjectTracking.m example.

%Initialize size variables
sz = size(L);
nFrames = sz(3);

%Initialize out variables
trackCell = cell(nFrames,1);
stateVec = cell(nFrames,1);

%Initialize starting variables
tracks = initializeTracks(); % Create an empty array of tracks.
nextId = 1; % ID of the next track

% Detect moving objects, and track them across video frames.
for k=1:nFrames
    [centroids, pixels] = detectObjects(k);
    predictNewLocationsOfTracks();
    [assignments, unassignedTracks, unassignedDetections] = ...
        detectionToTrackAssignment();
    updateAssignedTracks();
    updateUnassignedTracks();
    deleteLostTracks();
    createNewTracks();
    updateOutData(k);
end

%% Detect Objects
%Process data from cellStruct object into more useable form.
    function [centroids, pixels] = detectObjects(j)
        centroids = cat(1,cellStruct{j}.centroid);
        pixels = cell(size(cellStruct{j},1),1);
        for i=1:length(pixels)
            pixels{i} = cellStruct{j}(i).pixels;
        end
    end

%% Predict New Locations of Existing Tracks
% Use the Kalman filter to predict the centroid of each track in the
% current frame, and update its pixel list.

    function predictNewLocationsOfTracks()
        for i = 1:length(tracks)
            % Predict the current location of the track.
            predictedCentroid = predict(tracks(i).kalmanFilter);
            tVec = predictedCentroid - tracks(i).centroid;
            tracks(i).pixels = translateCell(tVec,tracks(i).pixels);
            tracks(i).centroid = predictedCentroid;
        end
    end

%% Assign Detections to Tracks
% Assigning object detections in the current frame to existing tracks is
% done by minimizing cost. The cost is defined as the negative
% log-likelihood of a detection corresponding to a track.  
%
% The algorithm involves two steps: 
%
% Step 1: Assign costs using overlap and euclidean distance between
% centroids.
% Step 2: Solve the assignment problem represented by the cost matrix using
% the |assignDetectionsToTracks| function. The function takes the cost 
% matrix and the cost of not assigning any detections to a track.  
%
% The value for the cost of not assigning a detection to a track depends on
% the range of values given by the cost function. This value must be tuned experimentally. Setting 
% it too low increases the likelihood of creating a new track, and may
% result in track fragmentation. Setting it too high may result in a single 
% track corresponding to a series of separate moving objects.   
%
% The |assignDetectionsToTracks| function uses the Munkres' version of the
% Hungarian algorithm to compute an assignment which minimizes the total
% cost. It returns an M x 2 matrix containing the corresponding indices of
% assigned tracks and detections in its two columns. It also returns the
% indices of tracks and detections that remained unassigned. 

    function [assignments, unassignedTracks, unassignedDetections] = ...
            detectionToTrackAssignment()
        
        nTracks = length(tracks);
        nDetections = size(centroids, 1);
        
        % Compute the cost of assigning each detection to each track.
        cost = zeros(nTracks, nDetections);
        for i = 1:nTracks
            for j= 1:nDetections
                cost(i, j) = overlapFunction(tracks(i).pixels, pixels{j})...
                    + distanceFunction(tracks(i).centroid,centroids(j,:));
            end
        end
        
        % Solve the assignment problem.
        costOfNonAssignment = 20;
        % Force boundary assignment
        if nTracks>0
            cost(1,1) = -10000;
        end
        [assignments, unassignedTracks, unassignedDetections] = ...
            assignDetectionsToTracks(cost, costOfNonAssignment);
    end

%% Update Assigned Tracks
% The |updateAssignedTracks| function updates each assigned track with the
% corresponding detection. It calls the |correct| method of
% |vision.KalmanFilter| to correct the location estimate. Next, it stores
% the new bounding box, and increases the age of the track and the total
% visible count by 1. Finally, the function sets the invisible count to 0. 

    function updateAssignedTracks()
        numAssignedTracks = size(assignments, 1);
        for i = 1:numAssignedTracks
            trackIdx = assignments(i, 1);
            detectionIdx = assignments(i, 2);
            centroid = centroids(detectionIdx, :);
            pixelList = pixels{detectionIdx};
            
            
            if trackIdx>length(tracks)
                display('error found')
                display(trackIdx)
            end
            % Correct the estimate of the object's location
            % using the new detection.
            correct(tracks(trackIdx).kalmanFilter, centroid);
            
            % Update track's age.
            tracks(trackIdx).age = tracks(trackIdx).age + 1;
            
            % Update visibility.
            tracks(trackIdx).totalVisibleCount = ...
                tracks(trackIdx).totalVisibleCount + 1;
            tracks(trackIdx).consecutiveInvisibleCount = 0;
            
            % Update centroid
            tracks(trackIdx).centroid = centroid;
            
            % Update pixel list
            tracks(trackIdx).pixels = pixelList;
            
            % Update cellID)
            tracks(trackIdx).cellID = detectionIdx;
        end
    end

%% Update Unassigned Tracks
% Mark each unassigned track as invisible, and increase its age by 1.

    function updateUnassignedTracks()
        for i = 1:length(unassignedTracks)
            ind = unassignedTracks(i);
            tracks(ind).age = tracks(ind).age + 1;
            tracks(ind).consecutiveInvisibleCount = ...
                tracks(ind).consecutiveInvisibleCount + 1;
            tracks(ind).cellID = uint32(0);
        end
    end

%% Delete Lost Tracks
% The |deleteLostTracks| function deletes tracks that have been invisible
% for too many consecutive frames. It also deletes recently created tracks
% that have been invisible for too many frames overall. 

    function deleteLostTracks()
        if isempty(tracks)
            return;
        end
        
        invisibleForTooLong = 3;
        ageThreshold = 8;
        
        % Compute the fraction of the track's age for which it was visible.
        ages = [tracks(:).age];
        totalVisibleCounts = [tracks(:).totalVisibleCount];
        visibility = totalVisibleCounts ./ ages;
        
        % Find the indices of 'lost' tracks.
        lostInds = (ages < ageThreshold & visibility < 0.6) | ...
            [tracks(:).consecutiveInvisibleCount] >= invisibleForTooLong;
        
        % Delete lost tracks.
        tracks = tracks(~lostInds);
    end

%% Create New Tracks
% Create new tracks from unassigned detections. Assume that any unassigned
% detection is a start of a new track. In practice, you can use other cues
% to eliminate noisy detections, such as size, location, or appearance.

    function createNewTracks()
        centroids = centroids(unassignedDetections, :);
        
        for i = 1:size(centroids, 1)
            
            centroid = centroids(i,:);
            pixelList = pixels{i};
            cellID = unassignedDetections(i);
            
            % Create a Kalman filter object.
            %kalmanFilter = configureKalmanFilter('ConstantVelocity', ...
            %    centroid, [200, 50], [200, 200], 25);
            
            kalmanFilter = configureKalmanFilter('ConstantVelocity', ...
                centroid, [10, 10], [10, 10], 0.1);
            
            % Create a new track.
            newTrack = struct(...
                'id', nextId, ...
                'cellID', cellID, ...
                'pixels', pixelList, ...
                'centroid', centroid, ...
                'kalmanFilter', kalmanFilter, ...
                'age', 1, ...
                'totalVisibleCount', 1, ...
                'consecutiveInvisibleCount', 0);
            
            % Add it to the array of tracks.
            tracks(end + 1) = newTrack;
            
            % Increment the next id.
            nextId = nextId + 1;
        end
    end

%% Initialize Tracks
% The |initializeTracks| function creates an array of tracks, where each
% track is a structure representing a moving object in the video. The
% purpose of the structure is to maintain the state of a tracked object.
% The state consists of information used for detection to track assignment,
% track termination, and display. 
%
% The structure contains the following fields:
%
% * |id| :                  the integer ID of the track
% * |cellID|:               the integer ID of the cell for the current
%                           frame
% * |pixels| :              the list of pixels of the object tracked
% * |centroid| :            the centroid of the object
% * |kalmanFilter| :        a Kalman filter object used for motion-based
%                           tracking
% * |age| :                 the number of frames since the track was first
%                           detected
% * |totalVisibleCount| :   the total number of frames in which the track
%                           was detected (visible)
% * |consecutiveInvisibleCount| : the number of consecutive frames for 
%                                  which the track was not detected (invisible).
%
% Noisy detections tend to result in short-lived tracks. For this reason,
% the example only displays an object after it was tracked for some number
% of frames. This happens when |totalVisibleCount| exceeds a specified 
% threshold.    
%
% When no detections are associated with a track for several consecutive
% frames, the example assumes that the object has left the field of view 
% and deletes the track. This happens when |consecutiveInvisibleCount|
% exceeds a specified threshold. A track may also get deleted as noise if 
% it was tracked for a short time, and marked invisible for most of the of 
% the frames.        

    function tracks = initializeTracks()
        % create an empty array of tracks
        tracks = struct(...
            'id', {}, ...
            'cellID', {},...
            'pixels', {}, ...
            'centroid', {}, ...
            'kalmanFilter', {}, ...
            'age', {}, ...
            'totalVisibleCount', {}, ...
            'consecutiveInvisibleCount', {});
    end
%% Update Data

    function updateOutData(j)
        trackCell{j} = tracks;
        nTracks = length(tracks);
        state = zeros(4,nTracks);
        for i = 1:nTracks
            state(:,i) = tracks(i).kalmanFilter.State;
        end
        stateVec{j} = state;
    end

%% Translate Cell
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
        pixels = pixels(pixels>-1);
    end
%% Check Boundary

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
%% Overlap Cost Function
    function cost = overlapFunction(pixels1, pixels2)
        overlap = numel(intersect(pixels1,pixels2));
        cost = 10*exp(-0.005*overlap);
    end
%% Distance Cost Function
    function cost = distanceFunction(centroid1, centroid2)
        sub = centroid1-centroid2;
        distance = sqrt(sub(1)^2 + sub(2)^2);
        cost = 0.8*distance;
    end
end

