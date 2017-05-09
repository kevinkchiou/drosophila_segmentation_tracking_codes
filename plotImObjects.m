function [ h ] = plotImObjects(im,vertStruct,cellStruct,fig,Lrgb)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

if nargin<2
    vertStruct=[];
end
if nargin<3
    cellStruct=[];
end
if nargin<4
    fig=1;
end
if nargin<5
    Lrgb=[]; %label2rgb picture
end
v=vertStruct;c=cellStruct;h=figure(fig);
set(h,'Position',[0 0 1000 1000]);
if ~isempty(im)
    imshow(im,'InitialMagnification','fit');hold on;
end
if ~isempty(Lrgb)
    hold on;himg=imagesc(Lrgb);set(himg,'AlphaData',0.25);
end
if ~isempty(v)
    for i=1:numel(v)
        text(v(i).x,v(i).y,sprintf('%d',i));
    end
end
if ~isempty(c)
    for i=1:numel(c)
        pos=c(i).centroid;
        text(pos(1),pos(2),sprintf('%d',i));
    end
end
hold off;
h=figure(fig);
end

