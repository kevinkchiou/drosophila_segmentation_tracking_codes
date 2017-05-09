function [ outStruct ] = associateSpatialData( D, inStruct, fieldString )
%ASSOCIATEMYOSIN Takes in an array D of spatial data to be associated
%with the graph structures represented by inStruct. Assumes that the array
%myo has the same dimensions as the segmentation label array that inStruct
%was extracted from. inStruct will typically be either a cell, bond, or
%vertex structure. Data association to an object will average the values of the array D for
%the pixels of the object + an eight neighborhood border around the object.
%Will return a data structure outStruct that is the same as inStruct,
%except with an extra field called by string fieldString.
%Physical Assumption: the spatial data was taken at a time close enough to
%picture the segmentation inStruct is based on to have essentially the same
%pixels associated with the objects represented in inStruct.

%Thanks to
%http://www.mathworks.com/matlabcentral/newsreader/view_thread/237702
%For help with struct syntax

outStruct = inStruct;
nElements = length(inStruct);
sz = size(D); nr = sz(1); nc = sz(2);

for i=1:nElements
    P = zeros(nr,nc);
    pixelList = inStruct(i).pixels;
    P(pixelList) = 1;
    P = imdilate(P,strel('square',3)); %Dilate the region a bit so that we get data 'near' it
    sumList = find(P);
    s = sum(D(sumList));
    l = length(sumList);
    outStruct(i).(fieldString) = cast(s,'double') ./ cast(l,'double'); %Record the average pixel value
end


end

