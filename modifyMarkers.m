function [BWout,imgshift,Lout] = modifyMarkers(Lin,fig,img,timept)
%segmentMarkerMod uses keyboard and mouse input to modify object markers
%with individual markers labeled through watershed or bwlabel.
%   Text prompts will guide user

if nargin<2
    fig=1;
end
if nargin<3
    img=[];
end
Ltemp = Lin;

%erode away very large cells (likely boundaries)
L=erodeLargeRegions(Ltemp);

fprintf('Displaying in figure %d...\n',fig);
imgshift=imageShift(img); %shift image baseline for better display with markers
set(figure(fig),'Position',[0 0 1000 1000]);
stop=0;
while(1)
    imgdisp=imgshift;imgdisp(L>0)=0;
    imshow(imgdisp,'InitialMagnification','fit');
    insertRegionText(L);
    if nargin>3
        gcf;title(sprintf('t = %d',timept));
    end
    query=queryUser;
    if query==1
        Lprev=L;
        Ltemp=addMarkers(L,inputInt('How many (enter positive integer number)?:  '));
        L=Ltemp;
    elseif query==2
        Lprev=L;
        Ltemp=elimMarkers(L,inputInt('How many (enter positive integer number)?:  '));
        L=Ltemp;
    elseif query==3 %draw your own marker using polygons
        fprintf('Outline a polygonal marker by clicking points. Press return when done!\n');
        Lprev=L;
        Ltemp=createMarkerFromPolygon(L,ginput);
        L=Ltemp;
    elseif query==4 %draw your own polygon and delete all markers inside
        fprintf('Outline a polygon by clicking points which will delete all markers inside. Press return when done!\n');
        Lprev=L;
        Ltemp=deleteMarkerFromPolygon(L,ginput);
        L=Ltemp;
    elseif query==0
        stop=1;
    elseif query==6
        fprintf('Resetting markers to original label...');
        Lprev=L;
        L=erodeLargeRegions(Lin);
    elseif query==9
        L=Lprev;
    else
        fprintf('I did not understand... Please try again!');
    end
    if stop==1
        break;
    elseif stop==0
        fprintf('Refreshing markers...\n');
    else
        error('Really bad!');
    end
end
Lout=L;
BWout=im2bw(L);
end

function Lout=addMarkers(L,N,domain)
Lout=L;
if nargin<2
    N=1;
end
if nargin<3
    elt=strel('disk',2);
    domain=elt.getnhood;
end
sz=size(domain);dy=(sz(1)-1)/2;dx=(sz(2)-1)/2;
[xtemp ytemp]=ginput(N);x=round(xtemp);y=round(ytemp);m=max(max(L));
for i=1:N
    f = (m+i)*domain;
    Lout(y(i)-dy:y(i)+dy,x(i)-dx:x(i)+dx) = f;
end
end

function Lout=elimMarkers(L,N)
Lout=L;sz=size(L);
[xtemp ytemp]=ginput(N);
x=round(xtemp);y=round(ytemp);
locs=y(:)+sz(1)*x(:); %use linear index location in L
sublist=sort(unique(L(locs))); %only take unique values and sort them
sublist=sublist(sublist>0); %boundary cannot be eliminated
for i=1:numel(sublist)
    Lout(L==sublist(i))=0; %remove clicked marker domain; turn into boundary
    locs=find(L>sublist(i)); %find all objects of higher index
    Lout(locs)=L(locs)-i; %reduce their index by appropriate number
end

end

function out=queryUser
fprintf('0: Quit subroutine\n');fprintf('1: Add markers\n');fprintf('2: Eliminate markers\n');
fprintf('3: Draw a polygonal marker\n');fprintf('4: Delete markers within a drawn polygon\n');fprintf('6: Reset markers\n');
fprintf('9: Undo previous action\n');
out=input('Please choose one!:  ');
if isempty(out)
    out=queryUser;
end
if (out~=1 && out~=2 && out~=0 && out~=3 && out~=4 && out~=6 && out~=9)
    fprintf('I do not understand; please enter an appropriate number and try again!\n');
    out=queryUser;
end
end

function out=inputInt(str)
out=input(str);
if isempty(out) || out<0 ||(floor(out)~=ceil(out))
    fprintf('Please enter a positive integer!\n');
    out=inputInt(str);
end
end

function out=checkStop
str=input('End program? Yes or No?:  ','s');
if(~isempty(strfind(str,'Yes'))||~isempty(strfind(str,'yes'))||~isempty(strfind(str,'1')))
    out=1;
elseif(~isempty(strfind(str,'No'))||~isempty(strfind(str,'no'))||~isempty(strfind(str,'0')))
    out=0;
else
    fprintf('I am not smart. I do not understand your answer. Please try again!\n');
    out=checkStop;
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

function Lout=deleteMarkerFromPolygon(Lin,pos)
if isempty(pos) || length(pos)<3
    Lout=Lin;
    return;
end
if polyarea(pos(:,1),pos(:,2))<1e-2
    fprintf('Error: Points are likely collinear. Please redraw polygon\n');
    Lout=Lin;
    return;
end

pos=round(pos);
order=convhull(pos); %pos should be output like from ginput: [x(N,1),y(N,1)];

xv=pos(order(1:end-1),1);
yv=pos(order(1:end-1),2);
maxx=max(xv);minx=min(xv);maxy=max(yv);miny=min(yv);

%create a long vector (square shaped) of test points for in/out
xvec=(minx:maxx)';yvec=(miny:maxy)';xq=zeros(numel(xvec)*numel(yvec),1);yq=zeros(numel(xvec)*numel(yvec),1);
for i=1:numel(xvec)
    shift=(i-1)*numel(yvec);
    xq(shift+1:shift+numel(yvec))=xvec(i);
    yq(shift+1:shift+numel(yvec))=yvec(:);
end
L=Lin;
in=inpolygon(xq,yq,xv,yv);
p=convertXYtoPixelNum(xq(in),yq(in),size(Lin));
mlist=unique(Lin(p));
mlist=mlist(mlist>0);
for i=1:numel(mlist)
    L(Lin==mlist(i))=0;
end
U=unique(L);
U=U(U>0);
[~,idx]=sort(U);
Lout=L;
for i=1:numel(U);
    Lout(L==U(i))=idx(i);
end
end