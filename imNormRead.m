function [imgarray] = imNormRead(NAME)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

info=imfinfo(NAME);
imgin=zeros(info(1).Height,info(1).Width,numel([info.Height]));
for i=1:numel([info.Height])
    imgin(:,:,i)=imread(NAME,i);
end

%baseline normalization
img=double(imgin);
for i=1:numel([info.Height])
    temp=img(:,:,i);
    %get background value, omitting really dark camera segments
    bg=min(temp(temp(:)>median(temp(:))/2));
    temp=double(imgin(:,:,i))-bg;
    temp(temp<0)=0; %restore minimum background
    img(:,:,i)=temp/max(max(temp));
end

imgarray=img;
end

