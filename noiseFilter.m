function [filtered_img] = noiseFilter(imgin,msize,sig)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

h=fspecial('gaussian',msize,sig);

sz=size(imgin);
if numel(sz)>2
    n=sz(3);
else
    n=1;
end

%low frequency background subtraction
imgbgsub=bgSub(imgin,strel('disk',10));

%figure(40);imshow(imgbgsub(:,:,1));figure(41);imshow(img(:,:,1));
img=imgbgsub; %large wavelength bg subtraction
figure(1);imshow(img(:,:,1));figure(11);imshow(gaborProcess(img(:,:,1),5,8));figure(21);imshow(edge(img(:,:,1),'canny',[0.005 0.09]));
figure(2);imghisteq=adapthisteq(img(:,:,1));imshow(imghisteq);figure(12);imshow(gaborProcess(imghisteq,5,8));figure(22);imshow(edge(imghisteq,'canny',[0.005 0.09]));

%apply median filter and show
imgtempmed=medfilt2(img(:,:,1),[sig sig]);
figure(3);imshow(imgtempmed);figure(13);imshow(gaborProcess(imgtempmed,5,8));figure(23);imshow(edge(imgtempmed,'canny',[0.005 0.09]));
%figure(31);imshow(imfilter(imghisteq,h));

%apply gaussian filter and show
imgtempgauss=imfilter(img(:,:,1),h);
figure(4);imshow(imgtempgauss);figure(14);imshow(gaborProcess(imgtempgauss,5,8));figure(24);imshow(edge(imgtempgauss,'canny',[0.005 0.09]));

%figure(5);BWcanny=edge(imgtempmed,'Canny',[0.005,0.09]);imshow(BWcanny);
%figure(5);BWcannyclose=imclose(BWcanny,strel('square',4));imshow(BWcannyclose);
%figure(6);BWcannyclosedilate=imdilate(BWcannyclose,strel('square',3));imshow(BWcannyclosedilate);
%figure(7);imshow(bwareaopen(BWcannyclosedilate,100));

%featureMat=gaborProcess(imgtempmed,5,8); %five wavelengths, eight orientations
%figure(5);imshow(featureMat);
end
