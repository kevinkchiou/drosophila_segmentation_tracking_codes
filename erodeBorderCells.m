function [ out ] = erodeBorderCells( M )
%ERODEBORDERCELLS Pads the watershed matrix M with zeros on the edges, and then
%erodes all of the cell walls on the edge, leaving the interior intact.
%   Detailed explanation goes here
Temp = (M == 0); %Now, we remove the border cells.
Temp = padarray(Temp,[1,1]);
Temp = 1-Temp;
Temp = bwlabel(Temp);
Skel = (Temp==0);
Loc = find(Skel);
[nr, nc] = size(Temp);
for j=1:numel(Loc);
    k=Loc(j);[r,c]=ind2sub([nr,nc],k);
    if (r == 1 || r == nr || c == 1 || c == nc) %Exclude 1 pixel frame
    else
        A = [Temp(r+1,c-1:c+1);Temp(r,c-1:c+1);Temp(r-1,c-1:c+1)];
        Temp(r,c)=removeBorderEdges(A);
    end
end

out = Temp;

end

