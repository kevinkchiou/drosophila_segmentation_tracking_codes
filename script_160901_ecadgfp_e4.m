
%read in appropriate files.
FNAME='./Ecadherin-GFP movies/160901 ecadGFPr5 e4 t1-55.tif';
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
imgbgsub=bgSub(imgrawsat,strel('disk',10));

% Min/Max for displaying background subtracted data
bgShow = [min(min(imgbgsub)) max(max(imgbgsub))];

%abandon this ship for now
%use adaptive histogram equalization to equalize image contrast
%imgadapt=zeros(size(imgbgsub));BW=zeros(size(imgbgsub));
%for i=1:n
%    imgadapt(:,:,i)=adapthisteq(imgbgsub(:,:,i));
%    %additional filtering
%    temp=imgadapt(:,:,i);
%    temp(imgadapt(:,:,i)<1.2*median(reshape(imgadapt(:,:,i),numel(imgadapt(:,:,i)),1)))=0;
%    imgadapt(:,:,i)=medfilt2(temp);
%end
%clear temp;

imgadapt=imgbgsub;

%No more simple thresholding - gabor filters it is
imgedges=zeros(size(imgadapt));BWedges=zeros(size(imgadapt));
for i=1:n
    gray = mat2gray(imgadapt(:,:,i));
    level = graythresh(gray);
    imgedges(:,:,i)=medfilt2(im2bw(gaborProcess(imgadapt(:,:,i),5,8),level)); %find edges
end

for i=1:n
    BWedges(:,:,i)=bwlabel(bwareaopen(imerode(1-imgedges(:,:,i),strel('line',5,0)),15));
end