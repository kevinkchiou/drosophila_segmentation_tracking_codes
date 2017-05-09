
%read in appropriate files.
FNAME='./Ecadherin-GFP movies/160831 ecadGFPr5 e5 t10-70.tif';
imginfo=imfinfo(FNAME);
n=numel([imginfo.Height]);
imgraw=zeros(imginfo(1).Height,imginfo(1).Width,n);
imgrawsat=zeros(size(imgraw));
satfactor=1.0; %factor for saturation intensity. Larger factor -> 
for i=1:n
    imgraw(:,:,i)=imread(FNAME,i);
    %saturate high end due to punctate data observed in histogram
    imgrawsat(:,:,i)=satfactor*imgraw(:,:,i)/max(max(imgraw(:,:,i)));
    imgrawsat(:,:,i)=min(imgrawsat(:,:,i),1);
end

% Min/Max for displaying raw data
rawShow = [min(min(imgrawsat)) max(max(imgrawsat))];

%low frequency (background) subtraction through morphological methods
imgbgsub=bgSub(imgrawsat,strel('disk',20));

% Min/Max for displaying background subtracted data
bgShow = [min(min(imgbgsub)) max(max(imgbgsub))];

%use adaptive histogram equalization to equalize image contrast
imgadapt=zeros(size(imgbgsub));BW=zeros(size(imgbgsub));
for i=1:n
    imgadapt(:,:,i)=adapthisteq(imgbgsub(:,:,i));
    %additional filtering
    temp=imgadapt(:,:,i);
    temp(imgadapt(:,:,i)<1.3*median(reshape(imgadapt(:,:,i),numel(imgadapt(:,:,i)),1)))=0;
    imgadapt(:,:,i)=medfilt2(temp);
end
clear temp;

%Simple thresholding
imgthresh=zeros(size(imgadapt));
imgedges=zeros(size(imgadapt));BWedges=zeros(size(imgadapt));
for i=1:n
    gray = mat2gray(imgadapt(:,:,i));
    level = graythresh(gray)/2;
    imgthresh(:,:,i) = medfilt2(im2bw(gray,level));
    imgedges(:,:,i)=im2bw(gaborProcess(imgadapt(:,:,i),5,8),level); %find edges
    BW(:,:,i)=bwlabel(bwareaopen(imerode(1-imgthresh(:,:,i),strel('disk',1)),15)); %erode and label marker objects
    BWedges(:,:,i)=bwlabel(bwareaopen(imerode(1-imgedges(:,:,i),strel('line',5,0)),15)); 
    %BWedges(:,:,i)=bwlabel(bwareaopen(imerode(1-imgedges(:,:,i),strel('disk',1)),15));
end