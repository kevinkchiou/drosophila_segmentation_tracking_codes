function Lout = multipleTimePtMarkerSegment(imgseq,t_pts,initL,fig)
%MULTEPLETIMEPTMARKERSEGMENT Correct markers of an image sequence from 
%initL. Enter an image sequence (imgseq) with a vector of time
%points (t_pts) that need correcting 
%   Detailed explanation goes here

if nargin<3 || isempty(initL)
    Lout=zeros(size(imgseq));
else
    Lout=initL;
end
if nargin<4
    fig=figure;
end
sz=size(imgseq);t_pts=unique(t_pts);
if ~isequal(sz,size(initL))
    error('Error: Input image sequence and label sizes do not match!');
end
if max(t_pts)>sz(3)
    error('Error: Prescribed time points exceeds image sequence');
end
for i=1:numel(t_pts)
    if ~isempty(initL) && nargin>=3
        Lout(:,:,t_pts(i))=singleTimePtMarkerSegment(imgseq(:,:,t_pts(i)),fig,t_pts(i),initL(:,:,t_pts(i)));
    else
        Lout(:,:,t_pts(i))=singleTimePtMarkerSegment(imgseq(:,:,t_pts(i)),fig,t_pts(i));
    end
end
end

