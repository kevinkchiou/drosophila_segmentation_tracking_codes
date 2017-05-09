function [BWout,imgshift] = markerCorrection(BW,imgadapt)
%MARKERCORRECTION markerCorrection takes in a marker label seq generated
%through edge detection (BW) as well as a noise-proceesed version of the
%original image (imgadapt) in order to fix incorrect markers within BW. The
%resulting output (imgshift and BWout) are used respectively as the
%intensity profile and markers for watershed segmentation.
%   For partially corrected image sequences, consider using
%   multipleTimePtMarkerSegment() or singleTimePtMarkerSegment() functions

sz=size(BW);
if numel(sz)<3
    sz3=1;
else 
    sz3=sz(3);
end
if ~isequal(size(BW),size(imgadapt))
    error('Error: unequal sizes between inputs!\n');
end
imgshift=zeros(size(BW));
skip=skipMarkerCheckQuery;

for i=1:sz3
    if skip~=1
        BWL=BW(:,:,i);
        [BW(:,:,i),imgshift(:,:,i)]=modifyMarkers(BWL,1,imgadapt(:,:,i));
    elseif skip==1
        imgshift(:,:,i)=imageShift(imgadapt(:,:,i));
    end
end
BWout=BW;
end

function out=skipMarkerCheckQuery
s=input('Skip marker checking? (Y/N):','s');
if s=='Y' || s=='y'
    out=1;
elseif s=='N' || s=='n'
    out=0;
else
    fprintf('Sorry, I did not understand your answer.\n');
    out=skipMarkerCheckQuery;
end
end