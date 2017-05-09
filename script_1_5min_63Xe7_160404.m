%read in appropriate files.
FNAME='1.5min interval/max_160404 ecadgfp sqhmcherry_e7_xImaging SD GFP_resaved.tif';
imginfo=imfinfo(FNAME);
n=numel([imginfo.Height]);
imgraw=zeros(imginfo(1).Height,imginfo(1).Width,n);
for i=1:n
    imgraw(:,:,i)=imread(FNAME,i);
end

%low frequency (background) subtraction through morphological methods
imgbgsub=bgSub(imgraw,strel('disk',10));

%use adaptive histogram equalization to equalize image contrast
imgadapt=zeros(size(imgbgsub));
for i=1:n
    imgadapt(:,:,i)=adapthisteq(imgbgsub(:,:,i));
end

%marker generation and watershed to get labeled image sequence, L.
imgedges=zeros(size(imgbgsub));L=zeros(size(imgbgsub));check=0;
%option for skipping
testval=input('Skip manual marker delination? (Yes = 1,No = 0) ');
if testval==1
    check=2;fprintf('Okay, skipping manual marker checking process!\n');
else
    check=0;fprintf('Okay, doing manual marker checking process!\n');
end
for i=1:n
    imgedges(:,:,i)=im2bw(gaborProcess(imgadapt(:,:,i),5,8)); %find edges
    BW=bwlabel(bwareaopen(imerode(1-imgedges(:,:,i),strel('disk',1)),10)); %erode and label marker objects
    if check<2 %if we are not completely skipping the marker checks
        [check imgshift]=checkMarkers(BW,1,imgadapt(:,:,i));
        if(check==0) %check marker objects for fidelity
            BWL=BW;
            [BW,imgshift]=modifyMarkers(BWL,1,imgadapt(:,:,i)); %modify marker objects for fidelity as necessary
        end
    else
        imgshift=imageShift(imgadapt(:,:,i));
    end
    L(:,:,i)=segmentFromMarker(imgshift,BW);
end

%process L into topological and geometric data (TBD)
v=cell(n,1);c=cell(n,1);
for i=1:n
    [v{i} c{i}]=extractTopologyFromSegment(L(:,:,i));
end

%now we have vertex and cell structures with all kinds of geometric and
%topological data. No cell tracking yet though.