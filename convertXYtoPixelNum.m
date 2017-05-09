function [ p ] = convertXYtoPixelNum(x,y,sz)
%CONVERTXYTOPIXELNUM converts (x,y) coordinate in pixel space to the
%corresponding pixel index of the full matrix.
%   Arguments are x position, y position, and the return of
%   sz=size(MatrixOfInterest). Alternatively, this algorithm will
%   (nominally) potentially detect the actual image matrix and attempt to
%   compensate.
if(~isempty(setdiff(size(sz),[1 2])))
    sz=size(sz);
end
if ~isequal(size(x),size(y))
    error('Unequal x and y!');
end
p=sz(1).*(x-1)+y;
end