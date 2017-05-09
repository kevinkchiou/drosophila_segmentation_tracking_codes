function [ imgout ] = bgSubLW( imgin, strelt )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

sz=size(imgin);
if numel(sz)==3
    n=sz(3);
else
    n=1;
end
imgtemp=zeros(sz);

imgraw=imgin;


imgtemp=mat2gray(imgraw);
imgin=imgtemp;

for i=1:n
    bg=imopen(imgin(:,:,i),strelt);
    %large wavelength bg subtraction %%and median filtering
    imgtemp(:,:,i)=imgin(:,:,i)-bg;
end
imgout=imgtemp;

end

