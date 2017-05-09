function [ img ] = plotSpatialData( sz, inStruct, dataString, plotString )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

if nargin<4
    plotString = 'off';
end

img = zeros(sz);
nElements = length(inStruct);
maxEl = max(cat(1,inStruct.(dataString)));
minEl = min(cat(1,inStruct.(dataString)));

intpl = @(x) ((0.98*(x-minEl))/(maxEl-minEl))+0.01;

for i=1:nElements
    img(inStruct(i).pixels) = intpl(inStruct(i).(dataString));
end

if strcmp(plotString,'on')
    figure(1)
    histogram(cat(1,inStruct.(dataString)));
    figure(2)
    imagesc(img); colormap(jet);
elseif strcmp(plotString,'off')
else
    warning('not passed valid arguments to plot function')
end

end

