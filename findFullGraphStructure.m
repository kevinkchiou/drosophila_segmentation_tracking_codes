function [ edgeStructure vertStructure faceStructure ] = findFullGraphStructure( L )
%FINDFULLGRAPHSTRUCTURE Simpler version of extractGraphFromSegment and
%createBondStructure. Creates a graph w/ planar embedding info out of the given 4-connected segmentation L.
%Encoding is in the three out structures, which will contain both
%connection information among the graph theoretic structures as well as
%geometric information such as face centroids, vertex average locations, etc.
%Algorithm based on http://stackoverflow.com/questions/12972527/graph-from-medial-axis-skeleton

%Define some global parameters
sz = size(L); nr=sz(1); nc=sz(2); 

%Construct initial face labeling and skeleton identification
bwFace = L>0;
faceComponents = bwconncomp(bwFace,8); faceLM = labelmatrix(faceComponents);
bwSkeleton = (L==0); skelLocs = find(bwSkeleton);
bwVert = zeros(sz(1)); numFaces = faceComponents.NumObjects;

%Find vertices by searching over skeleton and identifying skeleton pixels
%with >2 skeleton neighbors
for i=1:numel(skelLocs);
    j=skelLocs(i);[r,c]=ind2sub([nr,nc],j);
    if (r == 1 || r == nr || c == 1 || c == nc) %Exclude 1 pixel frame
    else
        testvec=[bwSkeleton(r-1,c),bwSkeleton(r+1,c),bwSkeleton(r,c-1),bwSkeleton(r,c+1)];
        if sum(testvec)>2
            bwVert(r,c) = 1;
        end
    end
end

%Construct vertex and edge labeling
vertComponents = bwconncomp(bwVert,4); bwEdge = bwSkeleton-bwVert;
edgeComponents = bwconncomp(bwEdge,4);
vertLM = labelmatrix(vertComponents);
edgeLM = labelmatrix(edgeComponents);
numVerts = vertComponents.NumObjects;
numEdges = edgeComponents.NumObjects;

%Initialize adjacency matrices
vertFace = zeros(numVerts,numFaces);
vertEdge = zeros(numVerts,numEdges);
edgeFace = zeros(numEdges,numFaces);
faceFace = zeros(numFaces);

%Fill in adjacency matrices by searching over skeleton and handling locally
for i=1:numel(skelLocs);
    j=skelLocs(i);[r,c]=ind2sub([nr,nc],j);
    if (r == 1 || r == nr || c == 1 || c == nc) %Exclude 1 pixel frame
    else
        if bwVert(r,c)==1 %handle as vertex
            vNumber = vertLM(r,c);
            faceVec = [faceLM(r+1,c-1:c+1), faceLM(r,c-1:c+1), faceLM(r-1,c-1:c+1)]; %Use 8-connection
            faceAdj = unique(faceVec(faceVec>0)); %Figure out adjacent faces
            vertFace(vNumber,faceAdj) = 1;
            edgeVec = [edgeLM(r+1,c),edgeLM(r-1,c),edgeLM(r,c+1),edgeLM(r,c-1)]; %Use 4-connection
            edgeAdj = unique(edgeVec(edgeVec>0)); %Figure out adjacent edges
            vertEdge(vNumber,edgeAdj) = 1;
        else %handle as edge
            eNumber = edgeLM(r,c);
            faceVec = [faceLM(r+1,c-1:c+1), faceLM(r,c-1:c+1), faceLM(r-1,c-1:c+1)]; %Use 8-connection
            faceAdj = unique(faceVec(faceVec>0)); %Figure out adjacent faces
            edgeFace(eNumber,faceAdj) = 1;
            faceFace(faceAdj,faceAdj) = 1;
        end
    end
end

%Remove self-adjacency for face-face
faceFace = faceFace-eye(numFaces);

%Create vertex-vertex adjacency matrix
vertVert = vertEdge*vertEdge';
vertVert = vertVert>0;
vertVert = vertVert-eye(numVerts);

%Create region properties
%For faces
s=regionprops(faceLM,'Centroid','Area','Perimeter','MajorAxisLength','MinorAxisLength');
cents=cat(1,s.Centroid); areas=cat(1,s.Area); perims=cat(1,s.Perimeter);
majA = cat(1,s.MajorAxisLength); minA = cat(1,s.MinorAxisLength);
%For edges
s=regionprops(edgeLM,'Area','Centroid');lengths=cat(1,s.Area);ePos=cat(1,s.Centroid);
%For vertices
s=regionprops(vertLM,'Centroid');vPos=cat(1,s.Centroid);

%Initialize data structures
faceStruct = repmat(struct('centroid',[0 0],'area',0,'perim',0,'aspectratio',[],'ncells',[],'nverts',[],'nedges',[],'pixels',[]),numFaces,1);
vertStruct = repmat(struct('x',0,'y',0,'ncells',[],'nverts',[],'nedges',[],'pixels',[]),numVerts,1);
edgeStruct = repmat(struct('centroid',[0 0],'length',0,'ncells',[],'nverts',[],'pixels',[]),numEdges,1);

%Fill in face data structure
for i=1:numFaces
    faceStruct(i).centroid = cents(i,:);
    faceStruct(i).area = areas(i);
    faceStruct(i).perim = perims(i);
    if i==1
        faceStruct(i).aspectratio = 0;
    else
        faceStruct(i).aspectratio = majA(i)./minA(i);
    end
    faceStruct(i).ncells = sortCCWByPosition(find(faceFace(i,:)),cents);
    faceStruct(i).nverts = sortCCWByPosition(find(vertFace(:,i))',vPos);
    faceStruct(i).nedges = sortCCWByPosition(find(edgeFace(:,i))',ePos);
    faceStruct(i).pixels = find(faceLM == i)';
end

%Fill in vertex data structure
for i=1:numVerts
    vertStruct(i).x = vPos(i,1);
    vertStruct(i).y = vPos(i,2);
    vertStruct(i).ncells = sortCCWByPosition(find(vertFace(i,:)),cents);
    vertStruct(i).nverts = sortCCWByPosition(find(vertVert(i,:)),vPos);
    vertStruct(i).nedges = sortCCWByPosition(find(vertEdge(i,:)),ePos);
    vertStruct(i).pixels = find(vertLM == i)';
end

%Fill in edge data structure
for i=1:numEdges
    edgeStruct(i).centroid = ePos(i,:);
    edgeStruct(i).length = lengths(i);
    edgeStruct(i).ncells = sortCCWByPosition(find(edgeFace(i,:)),cents);
    edgeStruct(i).nverts = sortCCWByPosition(find(vertEdge(:,i))',vPos);
    edgeStruct(i).pixels = find(edgeLM == i)';
end

%Assign out variables
edgeStructure = edgeStruct; vertStructure = vertStruct; faceStructure = faceStruct;

%Plotting

%plotImObjects(label2rgb(L),vertStruct,[],2);
%plotImObjects(label2rgb(L),[],faceStruct,1);

end

function [sortedList sortedIndex]=sortCCWByPosition(list,fullpositionlist)
%Sorts the given list of objects according to their angles around their
%mean position
%Assumes convexity or nearly so, likely if in interior
if length(list)<3 %no sorting necessary
    sortedList=list;
    return;
end
poslist=fullpositionlist(list,:);sz=size(poslist);
poslist=poslist-repmat(mean(poslist),length(poslist),1);
if length(poslist)~=sz(1)
    error('Error in CCW sorting.');
end
[~,sortedIndex]=sort(atan2(poslist(:,2),poslist(:,1)));
sortedList=list(sortedIndex);
end