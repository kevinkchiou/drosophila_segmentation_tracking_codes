function [ cell_list ] = userCellSelection(L,fig,im_init,cStruct)
%UNTITLED13 Summary of this function goes here
%   Detailed explanation goes here

cellvec=[];userflag=1;Lmod_init=L;Lmod_init(L>0)=1;
if nargin<2
    fig=1;
end
if nargin<3
    im_init=[];
end
if nargin<4
    cStruct=[];
end

%set colormap
CM='rbmap';

if ~isempty(im_init)
    im=im_init;im(L==0)=max(max(im_init)); %turn boundaries white
    Lrgb=label2rgb(Lmod_init,@mymap,'w','shuffle');
else
    im=label2rgb(Lmod_init,@mymap,'w','shuffle');Lrgb=[];
end

while(userflag)
    figure(fig);
    plotImObjects(im,[],cStruct,fig,Lrgb);
    in=input('Please select an option by entering a number.\n1 - Add cells by click-drag selection\n2 - Add cells by clicking\n3 - Remove cells by clicking\n0 - Exit\nEnter number: ');
    switch in
        case 1
            fprintf('Click-drag to select rectangle of desired cells in figure\n');
            recvec=round(getrect);
            xmin=recvec(1);xmax=recvec(1)+recvec(3);
            ymin=recvec(2);ymax=recvec(2)+recvec(4);
            [xmin,xmax,ymin,ymax]=checkRange(xmin,xmax,ymin,ymax,size(L));
            Lsub=L(ymin:ymax,xmin:xmax);cellvecadd=unique(Lsub(Lsub>0));
            cellvec=unique([cellvec;cellvecadd]);
        case 2
            fprintf('Left click desired cells to add. Press "Enter" to exit selection\n');
            [xtemp,ytemp]=getpts;x=round(xtemp);y=round(ytemp);p=convertXYtoPixelNum(x,y,size(L));
            cellvecadd=setdiff(unique(L(p)),0); %find unique cells, exclude boundaries
            cellvec=unique([cellvec;cellvecadd]);
        case 3
            fprintf('Left click desired cells to subtract. Press "Enter" to exit selection process\n');
            [xtemp,ytemp]=getpts;x=round(xtemp);y=round(ytemp);p=convertXYtoPixelNum(x,y,size(L));
            cellvecsub=setdiff(unique(L(p)),0); %find unique cells, exclude boundaries
            cellvec=setdiff(cellvec,cellvecsub);
        case 4
            fprintf('Exiting selection process!\n')
            userflag=0;
        case 0
            fprintf('Exiting selection process!\n');
            userflag=0;
        otherwise
            fprintf('I did not understand. Please select an option by entering a number!\n');
    end
    Lmod=Lmod_init;
    Lmod(ismember(L,cellvec))=2;
    if ~isempty(im_init)
        im=im_init;im(L==0)=max(max(im_init)); %turn boundaries white
        Lrgb=label2rgb(Lmod,@mymap,'w','shuffle');
    elseif isempty(im_init)
        im=label2rgb(Lmod,@mymap,'w','shuffle');
    end
end

cell_list=cellvec;
end

function [xmin,xmax,ymin,ymax]=checkRange(xmin,xmax,ymin,ymax,sz)
if xmin<0
    xmin=0;
end
if xmax>sz(2)
    xmax=sz(2);
end
if ymin<0
    ymin=0;
end
if ymax>sz(1)
    ymax=sz(1);
end

end

function out=mymap(N)
%out=jet(N);out=spring(N);
if N==1
    out=[0,0,1];return;
end
G=linspace(0,1,N)';
out=[flipud(G),zeros(size(G)),G];
end
