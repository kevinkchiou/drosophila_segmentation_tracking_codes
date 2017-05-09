function [ pCell aCell ] = measurePerimeterFromLabel(L,fig)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

sz=size(L);
if numel(sz)<3
    szz=1;
else
    szz=sz(3);
end
pCell=cell(szz,1);
aCell=cell(szz,1);

for i=1:szz
    Li=L(:,:,i);k=0;
    perim=zeros(max(max(Li)),1);area=zeros(max(max(Li)),1);
    for j=1:max(max(Li))
        [p,a]=measurePerim(Li,j);
        perim(j,1)=p;area(j,1)=a;
    end
    pCell{i}=perim;
    aCell{i}=area;
end

if nargin>1 %then plot stuff
    figure(fig);title('Perimeter (top) and Area (bottom) histograms');
    aggp=[pCell{1};pCell{end}];
    agga=[aCell{1};aCell{end}];
    [~,xp]=hist(aggp,15);
    [~,xa]=hist(agga,15);
    subplot(2,1,1);
    p1=hist(pCell{1},xp);pend=hist(pCell{end},xp);
    plot(xp,p1,'b-');hold on;plot(xp,pend,'r-');hold off;
    subplot(2,1,2);title('Area histograms: beginning and end');
    a1=hist(aCell{1},xa);aend=hist(aCell{end},xa);
    plot(xa,a1,'b-');hold on;plot(xa,aend,'r-');hold off;
    legend('Start','Finish','Location','NorthEast');
end

end


function [perim area]=measurePerim(L,cnum)

Ltemp=zeros(size(L));Ltemp(L==cnum)=1;
perim=sum(sum(imdilate(Ltemp,strel('disk',1))-Ltemp));
area=sum(sum(Ltemp));
end

