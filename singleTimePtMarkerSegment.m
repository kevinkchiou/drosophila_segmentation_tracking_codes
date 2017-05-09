function Lwatershed = singleTimePtMarkerSegment(imgadapt,fig,timept,L)
%singleTimePtMarkerSegment Summary of this function goes here
%   Put in a single adapted histogram image, perform marker correction from
%   simple threshold segmentation, and then performs watershed transform
%   segmentation. If called without a fourth argument (L), this will
%   automatically create a label from the first argument. Otherwise it will
%   utilize the fourth argument as a default label

if nargin<2
    fig=figure;
end
if nargin<3
    timept=[];
end
if nargin<4
    imgedges=im2bw(gaborProcess(imgadapt,5,8)); %find edges
    BW=bwlabel(bwareaopen(imerode(1-imgedges,strel('disk',1)),10)); %erode and label marker objects
else
    BW=bwlabel(imerode(im2bw(L),strel('disk',1)));
end
BWL=BW;
[BW,imgshift]=modifyMarkers(BWL,fig,imgadapt,timept); %manually modify marker objects for fidelity as necessary
Lwatershed=segmentFromMarker(imgshift,BW);
end

