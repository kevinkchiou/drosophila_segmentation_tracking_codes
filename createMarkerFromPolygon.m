function [Lout] = createMarkerFromPolygon(Lin,pos)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

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
idx=max(max(Lin))+1;
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
Lout=Lin;
in=inpolygon(xq,yq,xv,yv);
p=convertXYtoPixelNum(xq(in),yq(in),size(Lin));
Lout(p)=idx;

end