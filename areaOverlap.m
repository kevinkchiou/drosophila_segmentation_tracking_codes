function out = areaOverlap(pixelList,L,thresh)
%UNTITLED11 Summary of this function goes here
%   Detailed explanation goes here

if nargin<3
    thresh=0.75; %75% threshold
end

out=[];
overlap=L(pixelList);
md=mode(overlap);
if numel(overlap(overlap==md))>thresh*numel(pixelList)
    out=md; %success
end

end

