function [I Imean] = integrateIntensity(struct,index,xRefImg)
%UNTITLED7 Summary of this function goes here
%   Detailed explanation goes here

pixelList=convertXYtoPixelNum(struct(index).pixels);
I=sum(xRefImg(pixelList));
Imean=meanI/numel(pixelList);

end