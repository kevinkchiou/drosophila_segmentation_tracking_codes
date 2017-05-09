function [L,b,v,c] = watershedAndTopology(img,BW)
%WATERSHEDANDTOPOLOGY Takes in an intensity map (img) and label of
%marker-imposed minima (BW) in order to skeletonize and extract the
%topology of the graph
%   Detailed explanation goes here

lSize=size(img);
if ~isequal(size(img),size(BW))
    error('Error: sizing issue!\n');
end
A=zeros(lSize);
if numel(lSize)==3
    L=zeros(lSize(1)+2, lSize(2)+2, lSize(3));
elseif numel(lSize)==2
    L=zeros(lSize(1)+2, lSize(2)+2, 1);
else
    error('Error: input sizing\n');
end
%watershed segmentation
for i=1:lSize(3)
    A(:,:,i)=segmentFromMarker(img(:,:,i),BW(:,:,i)); %Create watershed matrix
    L(:,:,i) = erodeBorderCells(A(:,:,i)); %Keep only the interior
end

%process L into topological and geometric data
v=cell(lSize(3),1);c=cell(lSize(3),1);b=cell(lSize(3),1);
for i=1:lSize(3)
    [b{i} v{i} c{i}]=findFullGraphStructure(L(:,:,i));
end

end

