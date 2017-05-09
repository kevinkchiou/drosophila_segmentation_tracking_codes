function [cell_list] = selectCellsAndTrack(L,img,fig,frame)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

if nargin<2
    img=[];
end
if nargin<3
    fig=[];
end
if nargin<4
    frame=[];
end

if isempty(frame)
    frame=plotTrackedCells(L,25,[],fig);
end
if ~isempty(img)
    im=img(:,:,frame);
else
    im=[];
end

f=1;
icells=userCellSelection(L(:,:,frame),f,im,[]);close(f);pause(5);
[cell_list frame]=areaOverlapTracking(L,frame,icells);%pause(5);

if ~isempty(fig)
    plotTrackedCells(L,frame,cell_list,fig);
end
end

