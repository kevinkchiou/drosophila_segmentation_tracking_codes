function [trackCellOut,trackedCellsStruct] = correctTracking(L,forwardTrack,track_list,fig,cStruct)
%CORRECTTRACKING Corrects track deviations between frames
%   Utilize outputs from TrackingScript() (L and trackCell) as well as a
%   vector of cell numbers, and corrects any track errors in Kalman filter
%   cell tracking. Make sure that trackCell is the forward version
%   (called forwardTrack) structure from the trackingVisualization()
%   script. This function is self-contained. The final cStruct argument is
%   completely optional, but including it will output time-course data for
%   the tracked cells

trackCell=forwardTrack;cellnums=track_list;
trackImg=plottracking(L,trackCell,cellnums);
sz=size(L);minT=1;maxT=sz(3);

%initializations
tempTrackImg=trackImg;
userflag=1;frame=1;
trackCellmod=trackCell;
if nargin<4
    figure;
    fig=gcf;
else
    figure(fig);
end

while(userflag)
    imshow(label2rgb(tempTrackImg(:,:,frame)));title(sprintf('Frame = %d',frame));
    in=input('(N)ext/(P)revious/(S)elect/(C)orrect/(E)xit: ','s');
    if(advstrcmp(in,'n') || advstrcmp(in,'N'))
        if(frame<maxT)
            frame=frame+1;
        else
            fprintf(sprintf('Already at final frame (%d)!\n',frame));
        end
    elseif(advstrcmp(in,'p') || advstrcmp(in,'P'))
        if(frame>minT)
            frame=frame-1;
        else
            fprintf(sprintf('Already at first frame (%d)!\n',frame));
        end
    elseif(advstrcmp(in,'c') || advstrcmp(in,'C'))
        %make a correction (trackCellmod) and change the tempTrackImg
        trackCellmod=correctTrack(tempTrackImg,L,trackCellmod,frame,fig);
        tempTrackImg=plottracking(L,trackCellmod,cellnums);
    elseif(advstrcmp(in,'e') || advstrcmp(in,'E'))
        fprintf('Exiting!\n');
        userflag=0;
    elseif(advstrcmp(in,'s') || advstrcmp(in,'S'))
        temp=input(sprintf('Enter frame number between %d and %d: ',minT,maxT));
        if(temp<=maxT || temp>=minT)
            frame=temp;
        else
            fprintf('Out of bounds! Try again...\n');
        end
    else
        fprintf('Sorry, I did not understand. Try again!\n');
    end
end
trackCellOut=trackCellmod;

if nargin<5
    trackedCellsStruct=[];
    return;
end

c=cStruct;

trackedCellsStruct=cell(numel(c),1);
%initial track list
itracksall=cat(1,trackCellOut{1}.id);
itracks=itracksall(ismember(cat(1,trackCellOut{1}.cellID),cellnums));
for i=1:numel(c)
    temp=c{i};
    clistall=cat(1,trackCellOut{i}.cellID);
    clist=clistall(ismember(cat(1,trackCellOut{i}.id),itracks));
    trackedCellsStruct{i}=temp(clist);
end

end

function out=advstrcmp(in,comp)
%remove any spaces, character repeats, and only grab the last character
%from the in string using its ascii code
in(double(in)~=32);
out=strcmp(in(end),comp);
end

function outTrack=correctTrack(tempTrackImg,L,inTrack,frame,fig)
%initializations
fig1=fig+1;t0=frame;t1=frame+1;sz=size(L);tf=sz(3);
outTrack=inTrack;

fprintf('Right-click on the cell track that must be corrected in the next frame\n');
figure(fig);ax=gca;
[x,y]=getpts(ax);
cidx0=L(round(y(end)),round(x(end)),t0);
figure(fig1);ax=gca;imshow(label2rgb(tempTrackImg(:,:,t1)));
fprintf('Right-click on the correct cell in this frame\n');
[x,y]=getpts(ax);
cidx1=L(round(y(end)),round(x(end)),t1);
close(fig1);

%now we know the cellsIDs in t0 and t1. Find track ids from this

trackdata_t0=inTrack{t0};
trackdata_t1=inTrack{t1};
t0cids=cat(1,trackdata_t0.cellID);
t1cids=cat(1,trackdata_t1.cellID);
t0ids=cat(1,trackdata_t0.id);
t1ids=cat(1,trackdata_t1.id);

id0=t0ids(t0cids==cidx0);
id1=t1ids(t1cids==cidx1);

if numel(id0)>1 || numel(id1)>1
    error('Error: more than one track identified!');
end

%Now we have identified the appropriate tracks, id0 and id1. Now find all
%cells at later times associated with id1 and make them id0 instead. Note:
%since merging a track and causing a deletion is so drastic, I have chosen
%instead swap the track ids in order to preserve some of the structure of
%the data. But basically we use data from inTrack (id0 and id1) to modify
%the entries of outTrack. This prevents an "iterative" indexing error that
%can occur when the data structure being modified is also being read
for t=t1:tf
    %creates a list of track ids at time t using original inTrack
    idlist=[inTrack{t}.id]';
    %bitmask entries to the correct track id, id1
    bm1=(idlist==id1);
    if(sum(bm1)>1)
        error('Error: more than one track identified!');
    end
    %bitmask entries to the incorrect (original) track id, id0
    bm0=(idlist==id0);
    if(sum(bm0)>1)
        error('Error: more than one track identified!');
    elseif(sum(bm0)<1)
        %no corresponding track identified with this cell at this time
    end
    %corrects id1 by merging it into id0 for times t1 to tf in outTrack
    if(sum(bm1)==1) %make the change if track exists at this time point
        outTrack{t}(bm1).id=id0;
    end
    %swaps the tracks orifinally associated with id1 into id0 in outTrack
    if(sum(bm0)==1) %make the change if track exists at thie time point
        outTrack{t}(bm0).id=id1;
    end
end

end

%originally written by Tim Middlemas. Merged in here to prevent future
%modifications from breaking correctTracking() function. Merged a 14/2/2017
%version of the function
function [ outImage ] = plottracking( L, trackCell, cellNums )
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