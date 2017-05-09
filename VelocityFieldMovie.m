%Make Quiver Plot of Velocity Field over cells
FIG = 1;
PAUSE = 0.5;
NF = length(stateVec);

[x,y,u,v] = makeVelocityFields( stateVec );

figure(FIG)

for i = 1:NF
    imshow(revL(:,:,i))
    hold on
    quiver(x{i},y{i},u{i},v{i})
    pause(PAUSE)
end