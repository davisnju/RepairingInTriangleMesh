% figures
% Lagrange phi(.)
vertex=[0 0 0;
    0 1 0;
    1 0 0;
    1 0 1];
figure(25);
clf
face=[4 1 2];
patch('Faces',face,'Vertices',vertex,'FaceColor','blue','FaceAlpha',.5);
axis([-0.5 1.5 -0.5 1.5 -0.5 1.5]);
face2=[1 2 3];
patch('Faces',face2,'Vertices',vertex,'FaceColor','blue','FaceAlpha',0);
hold on
grid off
% quiver3(0,0,0,0,0,1,1);
quiver3(vertex(3,1),vertex(3,2),vertex(3,3),0,0,1,1);
view([-80 60])
text(1+0.03,-0.03,1,'1');
% scatter3(0,0,1)