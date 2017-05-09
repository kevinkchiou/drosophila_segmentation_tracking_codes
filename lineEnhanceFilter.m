function [imgout] = lineEnhanceFilter(imgin,R,ord,norient)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

if nargin<2
    R=3;
end
if nargin<3
    ord=ceil(0.3*(2*R+1)); % 30% of total filter size
end
if nargin<4
    norient=8; %number of orientations
end

% low order statistic line-shaped filters to reconstruct cell junctions. 
dphi=180/norient;sz=size(imgin);
if numel(sz)>2
    error('need a single 2d slice!');
end
im=zeros(sz(1),sz(2),norient);
for i=1:norient
    s=strel('line',2*R+1,(i-1)*dphi);
    im(:,:,i)=ordfilt2(imgin,ord,s.getnhood)/norient;
end
imgout=sum(im,3);
end

