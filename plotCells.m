function [ h ] = plotCells( im, vertStruct, cellStruct, fig, cellNum )
%PLOTCELLS This function plots the connections of a group of cells
%specified by cellNum.

v = vertStruct;c=cellStruct;h=figure(fig);
set(h,'Position',[0 0 1000 1000]);
if ~isempty(im)
    imshow(im,'InitialMagnification','fit');hold on;
end
cells = c(cellNum);
for i=1:numel(cells)
    pos = c(cellNum(i)).centroid;
    text(pos(1),pos(2),sprintf('%d',cellNum(i)));
    verts = cells(i).nverts;
    for j=1:numel(verts)
        vpos = [v(verts(j)).x, v(verts(j)).y];
        text(vpos(1),vpos(2),sprintf('%d',j));
    end
    celln = cells(i).ncells;
    for k = 1:numel(celln)
        cpos = [c(celln(k)).centroid(1), c(celln(k)).centroid(2)];
        text(cpos(1), cpos(2), sprintf('%d',k));
    end
end
hold off;
h=figure(fig);
end

