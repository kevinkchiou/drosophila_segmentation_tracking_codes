function [cellref,iFrame] = areaOverlapTracking(L,iFrame,iCells)
%UNTITLED10 Summary of this function goes here
%   Detailed explanation goes here

%iFrame and iCells are initial frame and initial cells selected within the
%frame. If these are empty, then start from beginning and track as many as
%given initial configuration
sz=size(L);
nFrames=sz(3);

if nargin==1
    cellref=-ones(max(max(L(:,:,1))),nFrames);
    cellref(:,1)=(1:numel(cellref(:,1)))';
    for i=1:nFrames-1
        L1=L(:,:,i);L2=L(:,:,i+1);
        prevPerm=cellref(:,i);currref=bestOverlap(L1,L2);
        cellref(:,i+1)=invReferenceVec(prevPerm,currref);
    end
elseif nargin==3
    cellref=-ones(max(max(L(:,:,iFrame))),nFrames);temp=(1:(max(max(L(:,:,iFrame)))))';
    cellref(iCells,iFrame)=temp(iCells);
    for i=iFrame:nFrames-1
        L1=L(:,:,i);L2=L(:,:,i+1);
        prevPerm=cellref(:,i);currref=bestOverlap(L1,L2);
        cellref(:,i+1)=invReferenceVec(prevPerm,currref);
    end
    %same as above, but backwards in time
    for i=iFrame:-1:2
        L1=L(:,:,i);L2=L(:,:,i-1);
        prevPerm=cellref(:,i);currref=bestOverlap(L1,L2);
        cellref(:,i-1)=invReferenceVec(prevPerm,currref);
    end
else
    error('fuck this nonsense, you used this function incorrectly!');
end
end

function refout=invReferenceVec(prevPerm,ref)
refout=-ones(size(prevPerm));
%this works out due to the way the overlap works
refout(prevPerm>0)=ref(prevPerm(prevPerm>0));
end

function out=bestOverlap(L1,L2)
thresh=0.55; % 55% threshold of pixel overlap
out=-ones(max(max(L1)));
for i=1:max(max(L1))
    idxp=find(L1==i);
    bestCell=areaOverlap(idxp,L2,thresh);
    if ~isempty(bestCell)
        out(i)=bestCell;
    end
end
end