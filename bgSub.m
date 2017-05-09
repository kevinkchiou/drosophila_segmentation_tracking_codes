function [imgout] = bgSub(imgin,strelt,mfilter)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

if nargin<2
    strelt=strel('disk',10);
end
if nargin<3
    mfilter=0;
end

sz=size(imgin);
if numel(sz)==3
    n=sz(3);
else
    n=1;
end
imgtemp=zeros(sz);

imgraw=imgin;
%eliminate highly spurious noise by looking through images that contain
%maximum intensities much greater than the rest of the images.
maxvec=[max(max(imgraw))];
temp=maxvec>(2.5*median(maxvec));
if sum(temp(:))>0
    idx=find(temp(:)>0);
    for i=1:numel(idx)
        im=imgraw(:,:,idx(i));
        maxval=max(max(im));
        locs=find(im>0.7*maxval);
        imtemp=im;
        for j=1:numel(locs)
            idx1=mod(locs(j)-1,sz(1))+1;idx2=(locs(j)-idx1)/sz(1)+1;
            %this performs a single 7x7 square median filter (order floor(1/3*49))
            dN=3;N=2*dN+1;
            vectemp=sort(reshape(im(idx1-dN:idx1+dN,idx2-dN:idx2+dN),N^2,1));
            %median filter
            imtemp(locs(j))=median(vectemp);
            %order filter (floor(1/3*N^2)
            %imtemp(locs(j))=vectemp(floor(1/3*(N^2)));
        end
        imgraw(:,:,idx(i))=imtemp;
    end
end
    
if mfilter~=0
    for i=1:n
        imgtemp(:,:,i)=medfilt2(imgraw(:,:,i));
    end
    imgraw=imgtemp;
end

imgtemp=mat2gray(imgraw);
imgin=imgtemp;

for i=1:n
    bg=imopen(imgin(:,:,i),strelt);
    %large wavelength bg subtraction
    imgtemp(:,:,i)=imgin(:,:,i)-bg;
end
imgout=imgtemp;
end