function bdcellnums = eliminateBdCells(L,cStruct)
%UNTITLED9 Summary of this function goes here
%   Detailed explanation goes here


sz=size(L);

%find all the cell numbers that lie on the boundary
bdcellnums=sort(unique([L(:,1);L(1,:)';L(:,end);L(end,:)']));

rp=regionprops(L);
%find outside boundary cells
b=find([rp(:).Area]>0.05*sz(1)*sz(2));
sz1=size(sort(b));
bdintersect=sort(intersect(b,bdcellnums));
sz2=size(bdintersect);
if sz1(1)~=1
    b=b';
end
if sz2(1)~=1
    bdintersect=bdintersect';
end

if ~isequal(bdintersect,sort(b))
    error('Boundary cells are not included in initial detection!');
end

if nargin>1
    %if there is an extra cell structure, also add cells next to big
    %boundary cells
    addlist=[];
    for i=1:numel(b)
        addlist=unique([addlist,cStruct(b(i)).ncells]);
    end
end

bdcellnums=[bdcellnums,addlist];

end

