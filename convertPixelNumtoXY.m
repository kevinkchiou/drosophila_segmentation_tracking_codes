function xy = convertPixelNumtoXY(p,sz)
%CONVERTPIXELNUMTOXY converts a pixel index from a matrix representation of
%a grayscale image into (x,y) pixel coordinates
%   Parameters for this function are the p the pixel index and the return
%   from sz=size(MatrixOfInterest). Alternatively this subroutine will
%   perform a rough detection if the actual matrix is entered instead of
%   its size
if(~isempty(setdiff(size(sz),[1 2])))
    sz=size(sz);
end
y=mod(p-1,sz(1))+1;x=(p-y)/sz(1)+1;
xy=[x,y];
end

