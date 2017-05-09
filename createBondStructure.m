function [bondStructOut vertStructOut cellStructOut] = createBondStructure(vertStruct,cellStruct,L)
%CREATEBONDSTRUCTURE() takes in vertex and cell structures from
%EXTRACTTOPOLOGYFROMSEGMENT() and creates a bond structure which identifies
%pixels associated with each bond between vertices
%   Use an iterative branching process to find the bond between two pixels
%   from a segmentation L. However, instead of using a complicated tree
%   structure to track the branching process, I am lazy and instead will
%   use the final data to simply track back to the original vertex.
%   Increased computation but decreases the necessity to store and develop
%   a tree data structure for a process that should not branch very much
vs=vertStruct;cs=cellStruct;
nv=numel(vs);nc=numel(cs);
vadjmat=zeros(nv,nv);
sz=size(L);
for i=1:nv
    nverts=sort(vs(i).nverts);
    vadjmat(i,nverts)=1;
end
if ~isequal(vadjmat,vadjmat')
    error('Not symmetric!\n');
end
nb=sum(sum(vadjmat))/2;
bs=repmat(struct('nverts',[-1 -1]','ncells',[-1 -1]','nbonds',[],'pixels',[]),nb,1);
countbond=0;
for i=1:nv
    tvec=vadjmat(i,i+1:end); %only consider lower triangular adjacency to avoid double counting
    idx=find(tvec==1)+i; %correct the indexing given shortened vector
    vs(i).nbonds=-ones(size(vs(i).nverts));
    i
    idx
    for j=1:numel(idx)
        j
        countbond=countbond+1;
        %creates bond structure which has end vertices, pixels, and
        %neighboring cells
        bs(countbond).nverts=[i idx(j)];
        bs(countbond).pixels=convertPixelNumtoXY(findBondPixels([vs(i).x,vs(i).y],[vs(idx(j)).x,vs(idx(j)).y],L),sz);
        bs(countbond).ncells=intersect(vs(i).ncells,vs(idx(j)).ncells); %two cells on either side of the bond
        %correctly associate the current bond with the vertex structure
        vs(i).nbonds(vs(i).nverts==idx(j))=countbond;
        vs(idx(j)).nbonds(vs(idx(j)).nverts==i)=countbond;
    end
end
for i=1:nc
    nneighb=length(cs(i).nverts);
    cs(i).nbonds=repmat(-1,nneighb,1);
    for j=1:nneighb
        vj=cs(i).nverts(j);vjp1=cs(i).nverts(mod(j,nneighb)+1);
        %identify the vertex with the greater index
        if vjp1>vj
            v1=vj;v2=vjp1;
        else
            v1=vjp1;v2=vj;
        end
        idenbondmatrix=triu(vadjmat,1); %use lower triangular vertex adjacency matrix
        %this allows us to sum along the rows in matlab given the vertex
        %numbers and binary adjacency matrix to find the bond number
        n=(v1-1)*nv+v2; %find the matrix number from the given v1 and v2.
        cs(i).nbonds(j)=sum(idenbondmatrix(1:n)); %since only adjacent vertices contain an entry, and 
        %adjacent vertices share a bond, this identifies the bond number.
    end
end

%copy by value into (hopefully) more efficient structures
vertStructOut=vs;
cellStructOut=cs;
bondStructOut=bs;

end