function [edgeL] = createEdgeLFromEdgeStruct(edgeStruct,origL)
%CREATEEDGELFROMEDGESTRUCT create an L file from edgeStruct created by
%findFullGraphStructure() function
%   Inputs for this function are the edgeStruct as well as the original L
%   used to create edgeStruct. Note that this is for a single slice L, and
%   not for a full stack. This should be run within a loop to capture
%   multiple time slices

edgeL=zeros(size(origL));
for i=1:numel(edgeStruct)
    edgeL(edgeStruct(i).pixels)=i;
end
end

