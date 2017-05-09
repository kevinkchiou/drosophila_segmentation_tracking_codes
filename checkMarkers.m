function [out imgshift] = checkMarkers(Lin,fig,img)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

Ltemp = Lin;
%erode away very large cells (likely boundaries)
L=erodeLargeRegions(Ltemp);

fprintf('Displaying in figure %d...\n',fig);
imgshift=imageShift(img); %shift image baseline for better display with markers
set(figure(fig),'Position',[0 0 1000 1000]);

imgdisp=imgshift;imgdisp(L>0)=0;
imshow(imgdisp,'InitialMagnification','fit');
insertRegionText(L);
str=input('Modify markers? (Yes/No/Quit) ','s');

yescell={'Yes','Yes ','Yes  ',' Yes', '  Yes','yes','yes ',' yes','1',' 1','1 ','y',' y','y ','  y','Y','Y ',' Y'};
nocell={'No','No ','No  ',' No','  No','no','no ',' no','no  ','  no','2','2 ',' 2','n','n ',' n','  n','N','N ',' N'};
quitcell={'quit','Quit',' Quit','Quit ',' quit','quit ','q',' q','q '};

if sum(strcmp(str,yescell))>0
    fprintf('Excellent. Executing user-input marker modification subroutine...\n');
    out=1;
elseif sum(strcmp(str,nocell))>0
    fprintf('Excellent. Skipping user-input marker modification subroutine...\n');
    out=0;
elseif sum(strcmp(str,quitcell))>0
    out=2;
else
    fprintf('I did not understand. Going with ''Quit'' and executing user-input marker modification subroutine...\n');
    out=2;
end

end

function insertRegionText(L)
gcf;
s=regionprops(L);N=numel(s);
cents=cat(1,s.Centroid);
for i=1:N
    text(cents(i,1)-3,cents(i,2),sprintf('%d',i),'Color',[1 1 1]);
end
end

function Lout=erodeLargeRegions(L,freqthresh)
if nargin<2
    freqthresh=0.05;
end
N=numel(L);
[n,x]=hist(L(:),unique(L(:))); %number of bins equal to number of unique L entries
freq=n/N;
largecells=x(freq'>freqthresh & x~=0); %find regions > freqthresh fractional area and aren't boundary
%now apply large erosion to these areas
for i=1:numel(largecells)
    rregion=L==largecells(i); %logical mask of region of interest
    rregiondilate=imerode(rregion,strel('disk',20)); %erosion of region
    L(rregion)=largecells(i)*rregiondilate(rregion); %set values of old region to values of new region
end
Lout=L;
end