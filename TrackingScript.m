%Example Tracking Script
%
%This assumes just that you have done all of the marker corrections.
%
%It makes the topological structure, and then calls the tracking structure
%on that topological structure.

%L is a segmentation, b is the bond structure of the lattice, v is the
%vertex structure of the lattice, and c is the cell structure of the
%lattice.
%[L,b,v,c] = watershedAndTopology(imgadapt, BWedges);

%Now, we reverse the L segmentation and cell structure in time, for easier
%initial conditions on the tracking algorithm.

sz = size(L);
revL = zeros(sz);
revc = cell(sz(3),1);

for i = 1:sz(3)
    revL(:,:,i) = L(:,:,sz(3)+ 1-i);
    revc{i} = c{sz(3)+ 1-i};
end

[trackCell, stateVec] = trackAllKalman(revL,revc); %trackCell holds the results of the tracking algorithm
nframes = length(trackCell);

%plot an example of a tracked cell (example is cells 100 and 101)
% outMovie = plotTracking(revL,trackCell,[100,101]);
% 
% for i=1:nframes
%     imshow(outMovie(:,:,i));
%     pause(0.5);
% end

%identify all topological changes
% changeCell = cell(nframes-1,1); %make the cell to hold all the changes
% 
% for i=1:nframes-1
%     changeCell{i} = detectTopologyChangesFrame(c,trackCell,i);
% end
% 
% %identify all t1 transition
% t1Cell = cell(nframes-1,1); %make the cell to hold all the changes
% possibleNonLocalCount = zeros(nframes-1,1); %counts the number of possible extended t1 transitions (i.e. stable 4-vertexes)
% 
% for i=1:nframes-1
%     [t1Cell{i},possibleNonLocalCount(i)] = detectT1Frame(c{i},changeCell{i});
% end
