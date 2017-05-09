function [x,y,u,v] = makeVelocityFields( stateVec )
%PLOTVELOCITYFIELDS Outputs the state of the Kalman filter as a velocity
%field in variables x,y,u,v. Can then quiver plot those variables.
%   Detailed explanation goes here

numFrames = length(stateVec);
x = cell(1,numFrames); y = cell(1,numFrames);
u = cell(1,numFrames); v = cell(1,numFrames);

for i = 1:numFrames
    numCells = length(stateVec{i});
    xArray = zeros(1,numCells);
    yArray = zeros(1,numCells);
    uArray = zeros(1,numCells);
    vArray = zeros(1,numCells);
    for j = 1:numCells
        xArray(j) = stateVec{i}(1,j);
        uArray(j) = stateVec{i}(2,j);
        yArray(j) = stateVec{i}(3,j);
        vArray(j) = stateVec{i}(4,j);
    end
    x{i} = xArray;
    y{i} = yArray;
    u{i} = uArray;
    v{i} = vArray;
end
end

