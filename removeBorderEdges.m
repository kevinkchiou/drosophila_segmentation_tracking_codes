function [ out ] = removeBorderEdges( mat )
%REMOVEBORDEREDGES When passed a neigborhood, determines if the center
%pixel belongs to the border region 1. If so, return 1, if not, return the
%center pixel value

check = sum(sum(mat>1));
if check>0
    out = mat(2,2);
else
    out = 1;
end
end

