

%load appropriate data. this data has select z-stacks cut out
fprintf('Clearing all variables!\n');clear;
load '161004 e4 ecadGFP watershed test';
varlist=who;
varlist{1}='inimg'; %temporary solution to .mat file with more variables
eval(sprintf('inimg = %s;',varlist{1}));
sz=size(inimg);
n=sz(3);
satfactor=1.0; %factor for saturation intensity. Larger factor -> 
imgraw=inimg;imgrawsat=zeros(size(inimg));
for i=1:n
    %saturate high end due to punctate data observed in histogram
    imgrawsat(:,:,i)=satfactor*imgraw(:,:,i)/max(max(imgraw(:,:,i)));
    %imgrawsat(:,:,i)=min(imgrawsat(:,:,i),1);
end

% Min/Max for displaying raw data
rawShow = [min(min(imgrawsat)) max(max(imgrawsat))];

%low frequency (background) subtraction through morphological methods
imgbgsub=bgSub(imgrawsat,strel('disk',15));
%imgbgsub=imgrawsat; %no background subtraction

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

%adjust background subtracted image by its statistics after this
medval=mean(median(reshape(imgbgsub,sz(1)*sz(2),1,n),1));
for i=1:n
    imgadapt(:,:,i)=medval/median(reshape(imgbgsub(:,:,i),sz(1)*sz(2),1))*imgbgsub(:,:,i);
end

imgadapt(imgadapt>1)=1;

%No more simple thresholding - gabor filters it is
imgedges=zeros(sz);BWedges=zeros(sz);imgedgesmod=zeros(sz);
for i=1:n
    gray = mat2gray(gaborProcess(imgadapt(:,:,i),5,8));
    level = graythresh(gray)*0.65;
    imgedges(:,:,i)=medfilt2(im2bw(gray,level)); %find edges
    imgedgesmod(:,:,i)=imdilate(imgedges(:,:,i),strel('line',5,0));
end

%compute background markers.
bgMarker=zeros(sz);imgdistmarkers=zeros(sz);
imgdist=zeros(sz);thresh=zeros(n,1);
for i=1:n
    bgMarker(:,:,i)=imclose(imgedgesmod(:,:,i),strel('disk',15));
    imgdist(:,:,i)=mat2gray(bwdist(imgedgesmod(:,:,i) | ~bgMarker(:,:,i)));
    tempmat=imgdist(:,:,i);
    thresh(i)=median(tempmat(tempmat(:)>0))/3;
    imgdistmarkers(:,:,i)=im2bw(tempmat,thresh(i));
end

for i=1:n
    BWedges(:,:,i)=bwlabel(bwareaopen(imerode(1-imgedges(:,:,i),strel('line',5,0)),15));
end