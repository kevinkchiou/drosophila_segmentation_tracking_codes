function [aspectRatio_list] = computeAspectRatio(L)
%UNTITLED8 Summary of this function goes here
%   Detailed explanation goes here

N=max(max(L));
aspectRatio_list=zeros(N,2);
sz=size(L);
frac=0.05;testcells=round(N*rand(round(frac*N),1));j=0; %test frac of the cells
for i=1:N
    tempL=zeros(size(L));
    tempL(L==i)=1; %binary mask of cell of interest
    tempLdil=imdilate(tempL,strel('square',3)); %dilate by one pixel
    bdLi=tempLdil-tempL; %gives boundary pixels
    %figure(i);imshow(bdLi); %testing purposes
    bound=convertPixelNumtoXY(find(bdLi==1),sz); %boundary position list in xy
    area=convertPixelNumtoXY(find(L==i),sz); %area position list in xy
    cent=mean(area); %centroid position in xy
    %test for large boundary cell
    if numel(area)>30*(sz(1)*sz(2))/N
        AR=0;testAR=0;ellAR=0; %boundary cells!
    else
        %find principal directions through moment of inertia tensor
        dr=area-repmat(cent,length(area),1);dx=dr(:,1);dy=dr(:,2);
        Ixx=sum(dy.^2);Iyy=sum(dx.^2);Ixy=-sum(dx.*dy);Iyx=Ixy;
        I2=[Ixx,Ixy;Iyx,Iyy];
        [v,~]=eig(I2);
        
        %The following approach to AR with second moment tensor eigenvalues
        %does not work well!
        %testAR=d(2,2)/d(1,1); %aspect ratio that uses all area elts.
        
        e1=v(:,1);e2=v(:,2);
        %create other AR measure, which only uses the boundary by finding
        %pixels of closest approach to the eigenvector lines drawn out from the
        %center
        [AR majA minA]=calculateAspectRatio(e1,e2,bound-repmat(cent,length(bound),1));
        ellStruct=fit_ellipse(bound(:,1),bound(:,2));
        ellAR=ellStruct.long_axis / ellStruct.short_axis;
        %My method of AR calculation using eigenvectors nets results very
        %similar to ellipse fitting. But is more robust.
        if isempty(ellStruct.long_axis) || isempty(ellStruct.short_axis)
            ellAR=NaN;
            %arMeasuresTest(bdLi,v,d,[majA,minA]',cent,100,'on');
        end
        
        %test accuracy of AR measures. Pick a few cells at random.
        if(ismember(i,testcells))
            j=j+1;
            %arMeasuresTest(bdLi,v,d,[majA,minA]',cent,j,'on');
            %arMeasuresTest(bdLi,v,d,[majA,minA]',cent,j,'off');
        end
    end
    aspectRatio_list(i,1)=AR;
    aspectRatio_list(i,2)=ellAR;
end

%test accuracy of AR measures. pick a few at random.

end

function [out majAxis minAxis]=calculateAspectRatio(v1,v2,posList)
%easiest thing to do is to break up every point into the v1 and v2 basis
%and then divide and conquer based on p/m v1/v2

%coordinate lists in terms of [x,y] = a1*v1 + a2*v2
a1List=posList*v1;
a2List=posList*v2;

%now sort by the axes
a1posidx=a1List>0;
a2posidx=a2List>0;
a1negidx=a1List<0;
a2negidx=a2List<0;

[~,idx]=min(abs(a2List(a1posidx))); %find closest pixel along positive a1 axis
a1temp=a1List(a1posidx);da1pos=a1temp(idx);

[~,idx]=min(abs(a2List(a1negidx))); %find closest pixel along negative a1 axis
a1temp=a1List(a1negidx);da1neg=a1temp(idx);

[~,idx]=min(abs(a1List(a2posidx))); %find closeest pixel along positive a1 axis
a2temp=a2List(a2posidx);da2pos=a2temp(idx);

[~,idx]=min(abs(a1List(a2negidx)));
a2temp=a2List(a2negidx);da2neg=a2temp(idx);

majoraxis=da1pos-da1neg;minoraxis=da2pos-da2neg;
%can calculate the distance this way as long as v1 and v2 are normalized
%evectors in R2
out=majoraxis/minoraxis;
majAxis=majoraxis;
minAxis=minoraxis;

end

function arMeasuresTest(L,v,D,A,cent,fig,onoff)
if nargin<7
    onoff='on';
end
if strcmp(onoff,'off');
    return;
end
e1=v(:,1);e2=v(:,2);
d1=D(1,1);d2=D(2,2);majA=A(1);minA=A(2);

figure(fig);imshow(label2rgb(L));
r0=[cent(1);cent(2)];
dr1=e1*d1/2;dr2=e2*d2/2;
eval1Line1=[r0-dr1,r0+dr1];
eval1Line2=[r0-dr2,r0+dr2];

dr1=e1*majA/2;dr2=e2*minA/2;
eval2Line1=[r0-dr1,r0+dr1];
eval2Line2=[r0-dr2,r0+dr2];

hold on;
plot(eval1Line1(1,:),eval1Line1(2,:),'r-');
plot(eval1Line2(1,:),eval1Line2(2,:),'r-');
plot(eval2Line1(1,:),eval2Line1(2,:),'b-');
plot(eval2Line2(1,:),eval2Line2(2,:),'b-');hold off;

xy=convertPixelNumtoXY(find(L==1),size(L));
x=xy(:,1);y=xy(:,2);
ellipse_t=fit_ellipse(x,y,gca);

end