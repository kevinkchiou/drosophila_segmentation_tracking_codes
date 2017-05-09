function [framenum,h_fig] = plotTrackedCells(L,figstart,cellvec,fig)
%PLOTTRACKEDCELLS takes output array from areaOverlapTracking and a image
%sequence segmentation and plots the tracked cells
%   Detailed explanation goes here

global OUT;
global userflag;

if nargin<2
    figstart=1;
end
if nargin<3
    cellvec=[];
end
if nargin<4
    fig=1;
end
sz=size(L);
%user interface: left/right arrows and q to quit
if ~isempty(cellvec)
    temp=find(sum(cellvec,1)>0);
    first=temp(1);last=temp(end);
else
    first=1;
    last=sz(3);
end
userflag=1;OUT=0;
if figstart>=first && figstart<=last
    framenum=figstart;
else
    framenum=first;
end
Lmod=ones(size(L(:,:,framenum)));Lmod(L(:,:,framenum)==0)=0;
%attempts at a user interface with keyboard
fprintf('Please use keyboard to navigate:\na - Step backwards\ns -Step forwards\nq - Quit and select this frame\n');
while(userflag)
    if ~isempty(cellvec)
        cells=cellvec(cellvec(:,framenum)>0,framenum);
        Lmod=ones(size(L(:,:,framenum)));Lmod(L(:,:,framenum)==0)=0;
        for j=1:numel(cells)
            Lmod(L(:,:,framenum)==cells(j))=j+1;
        end
    end
    h_fig=plotImObjects(label2rgb(Lmod),[],[],fig);
    set(h_fig,'KeyPressFcn',@keypress_fcn);
    if OUT==1
        %go left
        if framenum>first
            framenum=framenum-1;
        end
        OUT=0;
    elseif OUT==2
        %go right
        if framenum<last
            framenum=framenum+1;
        end
        OUT=0;
    end
    if userflag==0
        fprintf('Exiting!\n');
    end
    %user input!
end
close(h_fig);

%plots all of them instead of user interface
% sz=size(L);fcount=figstart-1;
% for i=1:sz(3)
%     cells=cellvec(cellvec(:,i)>0,i);
%     if ~isempty(cells)
%         fcount=fcount+1;
%         Lmod=ones(size(L(:,:,i)));Lmod(L(:,:,i)==0)=0; %modified label for plotting
%         for j=1:numel(cells)
%             Lmod(L(:,:,i)==cells(j))=j+1;
%         end
%         plotImObjects(label2rgb(Lmod),[],[],fcount);
%     end
% end

end

function keypress_fcn(hobj,event,handles)
global OUT;
global userflag;
key=event.Key;
%key=get(hobj,'CurrentKey');
switch key
    case 'a'
        OUT=1;
    case 's'
        OUT=2;
    case 'q'
        userflag=0;
end
end

