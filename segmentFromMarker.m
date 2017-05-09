function L = segmentFromMarker(imgshift,markerBW,fig)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

if nargin<3
    fig=0;
end
Linit=watershed(imimposemin(imgshift,markerBW)); %initial watershed transform
%Take care of small islands here, probably through adjacency.
L=cleanupLabel(Linit,markerBW,imgshift);
if fig>0
    figure(fig);
    maxItarget=0.8;maxI=max(max(imgshift));
    img=maxItarget/maxI*imgshift;
    img(L==0)=1;
    figure(fig);imshow(img);
end
end

function Lout=cleanupLabel(L,markerBW,img)
%cleans up undesireable components, such as small islands
%Lout=L;
nc=numel(unique(L(L>0)));sz=size(L);
skelLocs=find(L==0); %locations of boundaries
adjcell=zeros(nc,nc);
for i=1:numel(skelLocs)
    j=skelLocs(i);ny=sz(1);
    %should be sufficient for 4-connected label to use this cell neighbor test vector
    testvec=[L(j-1),L(j-ny),L(j+ny),L(j+1)];
    neighbcells=unique(testvec(testvec>0));
    if numel(neighbcells)==2
        %declare cells across a boundary to be neighbors
        adjcell(neighbcells,neighbcells)=1;
    end
end
%''just-in-case'' elimination of self-adjacency
adjcell(1:nc+1:nc*nc)=0;
elimvec=zeros(nc,1);
for i=1:nc
    if sum(adjcell(:,i))<3
        %cell has less than 3 neighbors, mark for elimination
        elimvec(i)=1;
    end
end
celim=find(elimvec==1);
for i=1:numel(celim)
    %eliminate the markers for that cell, and then resegment via watershed.
    markerBW(markerBW==celim(i))=0;
end
Lout=watershed(imimposemin(img,markerBW));
end