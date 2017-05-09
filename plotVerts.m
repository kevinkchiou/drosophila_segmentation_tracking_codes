function [ h ] = plotVerts( im, vertStruct, cellStruct, fig, vertNum )
%PLOTVERTS This function plots the connections of a group of vertices
%specified by vertNum

v = vertStruct;c=cellStruct;h=figure(fig);
set(h,'Position',[0 0 1000 1000]);
if ~isempty(im)
    imshow(im,'InitialMagnification','fit');hold on;
end
verts = v(vertNum);
for i=1:numel(verts)
    pos = [v(vertNum(i)).x, v(vertNum(i)).y];
    text(pos(1),pos(2),sprintf('%d',vertNum(i)));
    cells = verts(i).ncells;
    for j=1:numel(cells)
        cpos = c(cells(j)).centroid;
        text(cpos(1),cpos(2),sprintf('%d',j));
    end
    vertn = verts(i).nverts;
    for k = 1:numel(vertn)
        vpos = [v(vertn(k)).x, v(vertn(k)).y];
        text(vpos(1), vpos(2), sprintf('%d',k));
    end
end
hold off;
h=figure(fig);
end

