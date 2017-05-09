function [ imgout ] = lineFeatureFilter(imgin,l,d,phi)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here

h=lineFilt(l,d,phi);
imgout=filter2(h,imgin,'same');

end

%inspired by Gabor filter, but different along the edge
function filter=lineFilt(l,d,phi)
s=strel('line',l,phi);
mat=s.getnhood;
sz=max(size(mat));
mod=zeros(sz);
midpt=(sz+1)/2;
rad=pi*phi/180;

for i=1:sz
    dy=i-midpt;
    for j=1:sz
        dx=j-midpt;
        dl=dx*sin(rad)+dy*cos(rad); %positive dx and dy are towards lower right corner of the matrix
        mod(i,j)=cos(2*pi*dl/d)*exp(-dl^2/(2*d)^2);
    end
end
%minor test
if sum(sum(mod-mod'))>1e-7
    fprintf('Filter = %f\n',mod);
    error('Filter has a problem!');
end
filter=mod/sum(sum(mod)); %normalize
end