
%read in appropriate files.
FNAME='Testing125min.tif';
imginfo=imfinfo(FNAME);
%n=numel([imginfo.Height]);
n=20;
imgraw=zeros(imginfo(1).Height,imginfo(1).Width,n);
for i=1:n
    imgraw(:,:,i)=imread(FNAME,101-i);
end

% Min/Max for displaying raw data
rawShow = [min(min(imgraw)) max(max(imgraw))];

%low frequency (background) subtraction through morphological methods
imgbgsub=bgSub(imgraw,strel('disk',10));

% Min/Max for displaying background subtracted data
bgShow = [min(min(imgbgsub)) max(max(imgbgsub))];

%use adaptive histogram equalization to equalize image contrast
imgadapt=zeros(size(imgbgsub));
for i=1:n
    imgadapt(:,:,i)=adapthisteq(imgbgsub(:,:,i));
end

%Simple thresholding
for i=1:n
    gray = mat2gray(imgadapt(:,:,i));
    level = graythresh(gray);
    imgthresh(:,:,i) = im2bw(gray,level);
end

%marker generation and watershed to get labeled image sequence, L.
lSize = size(imgbgsub);
imgedges=zeros(size(imgbgsub));A=zeros(size(imgbgsub));L=zeros(lSize(1)+2, lSize(2)+2, lSize(3));check=0;
%option for skipping
testval=input('Skip manual marker delination? (Yes = 1,No = 0) ');
if testval==1
    check=2;fprintf('Okay, skipping manual marker checking process!\n');
else
    check=0;fprintf('Okay, doing manual marker checking process!\n');
end
for i=1:n
    imgedges(:,:,i)=im2bw(gaborProcess(imgadapt(:,:,i),5,8)); %find edges
    BW=bwlabel(bwareaopen(imerode(1-imgedges(:,:,i),strel('disk',1)),15)); %erode and label marker objects
    if check<2 %if we are not completely skipping the marker checks
        [check imgshift]=checkMarkers(BW,1,imgadapt(:,:,i));
        if(check==0) %check marker objects for fidelity
            BWL=BW;
            [BW,imgshift]=modifyMarkers(BWL,1,imgadapt(:,:,i)); %modify marker objects for fidelity as necessary
        end
    else
        imgshift=imageShift(imgadapt(:,:,i));
    end
    A(:,:,i)=segmentFromMarker(imgshift,BW); %Create watershed matrix
    L(:,:,i) = erodeBorderCells(A(:,:,i)); %Keep only the interior, remember, larger than A
end

%process L into topological and geometric data
v=cell(n,1);c=cell(n,1);b=cell(n,1);
for i=1:n
    [b{i} v{i} c{i}]=findFullGraphStructure(L(:,:,i));
end

trackCell = trackAllKalman(L,c);

% image=zeros(size(L));
% for i=1:n
%     figure(i);
%     image(:,:,i) = (L(:,:,i) == cellList(i));
%     image(:,:,i) = image(:,:,i) + (L(:,:,i)==0);
%     imshow(image(:,:,i));
% end

%now we have vertex and cell structures with all kinds of geometric and
%topological data. No cell tracking yet though.

% %Associate Myosin Concentration
% 
% %Read Myosin data
% FNAME = 'TestingMyosin.tif';
% imginfo = imfinfo(FNAME);
% n=2;
% %n=numel([imginfo.Height]);
% myoraw=zeros(imginfo(1).Height,imginfo(1).Width,n);
% myobgsub=zeros(imginfo(1).Height,imginfo(1).Width,n);
% myopad=zeros(imginfo(1).Height+2,imginfo(1).Width+2,n);
% for i=1:n
%     myoraw(:,:,i)=imread(FNAME,i);
%     myobgsub(:,:,i)=bgSubLW(myoraw(:,:,i),strel('disk',10));
%     myopad(:,:,i)=padarray(myobgsub(:,:,i),[1,1]); %Pad myosin data to be same size as final segmentation image
% end
% 
% % Min/Max for displaying myosin data
% myoShow = [min(min(myopad)) max(max(myopad))];
% 
% % make a new structure that is old structure + myosin data
% % general strategy is to average myosin data over the pixels of each structure
% % as well as 'close by' pixels (probably in an 8-neighborhood)
% s = cell(n,1);
% for i=1:n
%     s{i} = associateSpatialData(myopad(:,:,i),c{i},'myosin');
% end
% 
% %Plot a histogram of a slice and a normalized color map of a slice
% sz = size(L(:,:,1));
% colorMap = plotSpatialData(sz,s{1},'myosin','on');
% mov = zeros(size(L));
% for i=1:n
%     mov(:,:,i) = plotSpatialData(sz,s{i},'myosin');
% end

%implay(mov)

