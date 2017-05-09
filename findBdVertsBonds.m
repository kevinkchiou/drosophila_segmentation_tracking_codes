function [blist,vlist] = findBdVertsBonds(vStruct,bStruct,bdcelllist)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
b=bStruct;v=vStruct;list=bdcelllist;
blist=[];vlist=[];
ct=0;
for i=1:numel(b)
    ncells=b(i).ncells;
    if ~isempty(intersect(ncells,list)) %if a bond has neighboring boundary cell it's a boundary bond
        ct=ct+1;
        blist(ct)=i;
    end
end
ct=0;
for i=1:numel(v)
    ncells=v(i).ncells;
    if ~isempty(intersect(ncells,list)) %if one of the neighboring cells is a boundary cell it's a boundary vert
        ct=ct+1;vlist(ct)=i;
    end
end
end

