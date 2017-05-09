function playMovie( movie, time )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

sz = size(movie);
nFrames = sz(3);

for i=1:nFrames
    imshow(movie(:,:,i),'InitialMagnification',200);
    pause(time);
end

end

