function bondPixels=findBondPixels(v1,v2,L)
sz=size(L);
%need to round the values in case of 4-pt vertex
v1=round(v1);v2=round(v2);
firstPixel=convertXYtoPixelNum(v1(1),v1(2),sz);
currPixelList=convertXYtoPixelNum(v1(1),v1(2),sz);
finalPixel=convertXYtoPixelNum(v2(1),v2(2),sz);
prevPixelList=[];
while(1)
    nextPixelList=incrementPixelList(currPixelList,prevPixelList,L);
    %convertPixelNumtoXY(nextPixelList',[512,512])
    if(ismember(finalPixel,nextPixelList))
        break;
    else
        prevPixelList=currPixelList;currPixelList=nextPixelList;
    end
end
%once last pixel is found, use neighboring information of the last pixel,
%current pixel list, and previous pixel list to get a bond direction and
%track back. The current pixel should be a neighbor of last and prev pixel,
%but the next pixel back can be a neighbor of neither current or last. This
%guards against 4-pt vertices: 3-pt vertices do not require this nonsense.

%create isneighbor() function
currPixel=currPixelList(isneighbor(finalPixel,currPixelList,sz));
prevPixel=prevPixelList(isneighbor(currPixel,prevPixelList,sz));sz=size(L);
LList=[prevPixel-1;prevPixel-sz(1);prevPixel+sz(1);prevPixel+1];
ppPixelTest=L(LList);
ppPixel=LList(ppPixelTest(:)==0 & ~isneighbor(finalPixel,LList,sz)');
testsz=size(ppPixel);
if testsz(1)*testsz(2)>1
    fprintf('ppPixel = %f\n',ppPixel);
    error('This is terrible');
end
bondListReverse=[finalPixel;currPixel;prevPixel;ppPixel];
currPixel=ppPixel;
while(1)
    nextPixel=trackBackBond(currPixel,prevPixel,L,firstPixel);
    num=numel(bondListReverse);
    bondListReverse(num+1:num+numel(nextPixel))=nextPixel;
    if ismember(firstPixel,bondListReverse)
        break;
    else
        prevPixel=currPixel;currPixel=nextPixel;
    end
end
bondPixels=flipud(bondListReverse);
end

function [nextPixelList]=incrementPixelList(currPixelList,prevPixelList,L)
%currPixel should be a row vector and LList rows should correspond to
%currPixel. LList should contain only four rows with each entry as
%delineated in the bottom comment. These are neighbors for a pixel of
%interest in a 4-connected segmentation.

%currPixel need be a row vector for the following to work
sz=size(L);
LList=[currPixelList-1;currPixelList-sz(1);currPixelList+sz(1);currPixelList+1];
testL=L(LList);
nextPixelList=unique(LList(testL(:)==0 & ~ismember(LList(:),prevPixelList)))'; %these are pixel numbers that satisfy conditions for being next pixels.
if isempty(nextPixelList)
    %currPixelList
    %prevPixelList
    %convertPixelNumtoXY(currPixelList,sz);
    %convertPixelNumtoXY(prevPixelList,sz);
    error('fuck me!');
end
end

function res=isneighbor(p,plist,sizeL)
out=size(plist);
for i=1:numel(plist)
    pnlist=[plist(i)-1;plist(i)-sizeL(1);plist(i)+sizeL(1);plist(i)+1];
    out(i)=max(ismember(p,pnlist)); %max() provides 'or' logic
end
res=logical(out);
end

function nPixel=trackBackBond(cPixel,pPixel,L,fPixel)
sz=size(L);
neighbPixels=[cPixel-1;cPixel-sz(1);cPixel+sz(1);cPixel+1];
Ltest=L(neighbPixels);
nPixel=neighbPixels(Ltest==0 & ~ismember(neighbPixels,pPixel));
if ismember(fPixel,nPixel)
    return;
end
if(numel(nPixel)>1 & ~isneighbor(nPixel,fPixel,sz)) 
    error('More than one neighbor and not neighboring the final pixel.');
end
end

%     1
%   2 c 3
%     4
% These are the shortened pixel list indices in relation to a current pixel
%
%