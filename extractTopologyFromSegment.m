function [ vertStruct cellStruct] = extractTopologyFromSegment(L)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

%L should be two dimensional matrix with different regions labeled
sz=size(L);skelLocs=find(L==0);numcell=numel(unique(L(L(:)>0)));
s=regionprops(L,'Centroid');cents=cat(1,s.Centroid);
s=regionprops(L,'Area');areas=cat(1,s.Area);
celladjmat=zeros(numcell);
cellStruct=repmat(struct('centroid',[0 0],'area',0,'ncells',[],'nverts',[],'pixels',[]),numcell,1);
perimCell=measurePerimeterFromLabel(L);
AR=computeAspectRatio(L);
for i=1:numcell
    cellStruct(i).centroid=cents(i,:); %centroid at pixel points
    cellStruct(i).area=areas(i); %area in pixels
    perims=perimCell{1}; %only one cell element
    cellStruct(i).perim=perims(i); %perimeter in pixels
    cellStruct(i).aspectratio=AR(i,1); %aspect ratio computed from perimeter intersection with principle axes
    %cellStruct(i).aspectratio=AR(i,2); %aspect ratio computed from ellipse fitting
    if areas(i)>sz(1)*sz(2)*50/numcell
        %then it is likely a boundary cell, modify centroid location to
        %make it easier to deal with
        if cents(i,1)<sz(1)/2
            cents(i,1)=-sz(2); %send centroid off to large -x
            cellStruct(i).centroid=cents(i,:);
        elseif cents(i,1)>sz(1)/2
            cents(i,1)=2*sz(2); %send it off to large +x
            cellStruct(i).centroid=cents(i,:);
        end
    end
end

vcount=0;vvec=-ones(2*(numcell+2),6); %[x,y,ncell1,ncell2,ncell3,ncell4]
for i=1:numel(skelLocs);
    j=skelLocs(i);ny=sz(1);
    testvec5=[L(j-2*ny-2:j-2*ny+2)',L(j-ny-2:j-ny+2)',L(j-2:j+2)',L(j+ny-2:j+ny+2)',L(j+2*ny-2:j+2*ny+2)']; %5x5 test window
    Ltest=[L(j-ny-1:j-ny+1)',L(j-1:j+1)',L(j+ny-1:j+ny+1)']; %3x3 test window
    testvec=[L(j-1),L(j-ny),L(j+ny),L(j+1)]; %other test for 4-connected
    v=testVert(testvec,Ltest,j,sz);
    if ~isempty(v)
        vcount=vcount+1;
        vvec(vcount,1:numel(v))=v; %there will be lots of -1's remaining
    end
    nc=unique(Ltest(Ltest>0));
    if numel(nc)>2 %don't need to adjust neighbors every single time
        celladjmat(nc,nc)=1;
    end
end
celladjmat=celladjmat-eye(numcell); %eliminate self-adjacency
bdnum=0;bdcells=[];
for i=1:numcell
    cellStruct(i).pixels=convertPixelNumtoXY(find(L==i),size(L));
    tempncells=find(celladjmat(i,:)>0);
    cellStruct(i).ncells=sortCCWByPosition(tempncells,cents);
    if numel(tempncells)>15 %then count as a boundary cell and deal with it later, but ccw sorting will fail for it
        bdnum=bdnum+1;
        bdcells(bdnum)=i;
    end
end
%redo the boundary cell sorting, cause it's whack
% for i=1:bdnum
%     cellStruct(bdcells(i)).ncells=sortBdCellNeighbs(bdcells(i),cellStruct,cents,'ascend');
% end
%vvec is now a list of vertices with neighboring cells, some incomplete
mergevec=mergeVertices(vvec); %merge close vertices into 4-pt vertices
tempstruct=repmat(struct('x',0,'y',0,'nverts',[],'ncells',[]),length(mergevec),1);
%We first arrange the data into a structure. Then orient and arrange after
for i=1:numel(tempstruct)
    tempstruct(i).x=mergevec(i,1);tempstruct(i).y=mergevec(i,2);
    tempidx=find(mergevec(i,3:end)>-1)+2; %+2 to correct for doing a partial vector search
    tempstruct(i).ncells=mergevec(i,tempidx);
    tempstruct(i).ncells=sortCCWByPosition(tempstruct(i).ncells,cents);
end
tempcstruct=cellStruct;
%[tempvstruct tempcstruct]=shrinkDataStructures(tempstruct,tempcstruct);
%plotImObjects(label2rgb(L),tempstruct,[],2);
plotImObjects(label2rgb(L),[],tempcstruct,1);
[vertStruct cellStruct]=extractNeighbVerts(tempstruct,tempcstruct);
end

function vert=testVert(vec,Ltest3,j,sz,Ltest5)
vert=[];
s=sum(vec==0);
if s>2 %verts identified as boundary pixels with >2 neighboring boundary pixels in a 4-connected skeletonization
    r=convertPixelNumtoXY(j,sz);x=r(1);y=r(2);
    uvec=unique(Ltest3(Ltest3>0)); %vertex has at most 4 neighbors, will sometimes have 2 if it is delocalized 4-pt.
    %This is solved in a distinct subroutine; for now just find vertices
    vert=[x,y,uvec'];
    if sum(uvec(3:end)==0)>3
        error('fuck me again');
    end
end

%a test for 4-pt vertices. Most likely will be unused, as vast majority are
%3-pt vertices.
if nargin>4
    Lvec=Ltest3(Ltest3>0);
    if numel(unique(Lvec))==2 && numel(Lvec)<4
        %most likely a 4-pt vertex exists here
        r=convertPixelNumtoXY(j,sz);x=r(1);y=r(2);
        uvec=unique(Ltest5(Ltest5>0));
        vert=[x,y,uvec'];
    end
end
end

function mergedvec=mergeVertices(vec)
%merges close vertices. Tried some clever ways like sorting in coordinates
%but they aren't robust enough. Better off just doing stupid, simple thing
%and run a big loop.
bmask=zeros(length(vec));
for i=1:length(vec)
    pos=vec(i,1:2);
    dpos=vec(:,1:2)-repmat(pos,length(vec),1);
    bmask(:,i)=abs(dpos(:,1))<=1 & abs(dpos(:,2))<=1;
end
if ~isequal(bmask,bmask')
    error('problem! not symmetric!');
end
vmergestruct=struct('v',0,'vnums',[],'cnums',[]);vmergecount=0;
vcurr=1:length(vec); %for tracking which vertices will be merged
for i=1:length(vec)
    vtemp=bmask(i:end,i);%only need entries greater than i if bmask is symmetric
    if sum(vtemp)>1 %then there is at least one other vertex that is close.
        vtest=setxor(vcurr,find(vtemp>0)); %track vertices that are merging
        if numel(vtest)<numel(vcurr)-1 %if the setxor eliminates more than the current vertex
            vmergecount=vmergecount+1;
            vmergestruct(vmergecount).v=i;
            idx=find(vtemp==1)+i-1; %adjust for truncated vtemp(i:end)
            vmergestruct(vmergecount).vnums=sort(idx);
            cnums=unique(vec(idx,3:end));
            vmergestruct(vmergecount).cnums=sort(cnums(cnums>0));
        end
    end
end
%create final vector with merged vertices
outvec=zeros(1,6);j=1;k=1;
for i=1:length(vec)
    vtemp=bmask(1:i,i); %the complementary portion of bmask from above
    if sum(vtemp)==1 %if there is no lower index vertex this will merge into...
        if vmergestruct(j).v~=i %and if there are no vertices merging into this one
            outvec(k,:)=vec(i,:);
        else %merge the other vertices into this one
            outvec(k,1:2)=mean(vec([vmergestruct(j).v;vmergestruct(j).vnums],1:2));
            outvec(k,3:3+numel(vmergestruct(j).cnums)-1)=[vmergestruct(j).cnums]';
            if isempty(vmergestruct(j).cnums) %temporary fix for now
                outvec(k,3:end)=-1;
            end
            j=j+1;
        end
        k=k+1;
    elseif sum(vtemp)>1
        continue; %but do not increment k=k+1
    else
        error('FIRE IN THE DISCO');
    end
end
mergedvec=outvec;
end

function [sortedList sortedIndex]=sortCCWByPosition(list,fullpositionlist)
sz=size(list);
if sz(1)<3 %no sorting necessary
    sortedList=list;
    return;
end
poslist=fullpositionlist(list,:);sz=size(poslist);
poslist=poslist-repmat(mean(poslist),length(poslist),1);
if length(poslist)~=sz(1)
    error('FIRE IN THE TACO BELL');
end
[~,sortedIndex]=sort(atan2(poslist(:,2),poslist(:,1)));
sortedList=list(sortedIndex);
end

function [sortedList sortedIndex]=sortBdCellNeighbs(idx,cellstruct,cents,TYPE)
if strcmp(TYPE,'ascend')
    flag=0;
elseif strcmp(TYPE,'descend')
    flag=1;
else
    error('I do not understand: use TYPE = ''ascend'' or TYPE = ''descend'' ');
end

cs=cellstruct;
clist=cs(idx).ncells;
sortedList=repmat(-1,size(clist));
[~,fidx]=max(cents(clist,2));
fcell=cs(idx).ncells(fidx); %start with cell neighbor with maximum y-position

%find the cells that fcell and bdcell have in common
ocell=intersect(cs(fcell).ncells,cs(idx).ncells);

if numel(ocell)>1 %if there's more than one shared neighbor then pick the next max y-position
    [~,oidx]=max(cents(ocell,2));
    ocell=ocell(oidx);
end
%initialize neighbor finding process
pcell=fcell;ccell=ocell;sortedList(1)=pcell;sortedList(2)=ccell;
remainList=setdiff(clist,[pcell;ccell]);
for i=3:numel(clist)
    %find intersection of neighboring cells between bd cell and current
    %cell, but minus the previous neighboring cell found in the prior step
    pcell;
    ccell;
    temp=setdiff(intersect(clist,cs(ccell).ncells),pcell);
    %temporary solution.
    if numel(temp)==1
        ncell=temp;
    elseif numel(temp)==0
        
    else
        ncell=temp(1);
    end
    remainList=setdiff(remainList,ncell);
    if ~isempty(ncell)
        sortedList(i)=ncell;
        pcell=ccell;
        ccell=ncell;
    elseif(isempty(ncell) && numel(remainList)==1) 
        sortedList(i)=remainList(1);
    else
        %error('fuck me sideways');
        sortedList(i)=remainList(1); %solution for now
    end
end

if flag==1
    sortedList=flipud(sortedList);
end
end

function [vStructOut cStructOut]=extractNeighbVerts(vStructIn,cStructIn)
vs=vStructIn;cs=cStructIn;
nv=numel(vs);nc=numel(cs);
[assocMatrix vpos]=createVertexCellAssocMatrix(vs,cs);
for i=1:nc
    tempnverts=find(assocMatrix(:,i)>0);
    cs(i).nverts=sortCCWByPosition(tempnverts,vpos);
end
for i=1:nv
    temp=zeros(length(vs(i).ncells),2);
    nneighb=length(vs(i).ncells);
    for j=1:nneighb
        cidx=vs(i).ncells(j);
        idx=find(cs(cidx).nverts==i);
        nn=numel(cs(cidx).nverts);
        %the following assumes ccw organization of neighboring vertices.
        %this works great for convex cells, but fails spectacularly on the
        %boundary cells, which are non-convex!!!!!
        temp(j,1)=cs(cidx).nverts(mod(idx-2,nn)+1);
        temp(j,2)=cs(cidx).nverts(mod(idx,nn)+1);
    end
    exclutemp=temp(temp~=i); %discount the current vertex
    tempnverts=unique(exclutemp);
    vs(i).nverts=sortCCWByPosition(tempnverts,vpos);
end
vStructOut=vs;cStructOut=cs;
end

function [assocMatrix vertexPositions]=createVertexCellAssocMatrix(vstruct,cstruct)
v=vstruct;c=cstruct;nv=numel(v);nc=numel(c);
assocMatrix=zeros(nv,nc);vertexPositions=zeros(nv,2);
for i=1:nv
    if ~isempty(intersect(v(i).ncells,[0 -1]))
        v(i).ncells
    end
    if ~isempty(v(i).ncells) && isempty(intersect(v(i).ncells,[0 -1]))
        assocMatrix(i,v(i).ncells)=1;
        vertexPositions(i,:)=[v(i).x,v(i).y];
    end
end
end