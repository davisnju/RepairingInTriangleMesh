figure(26);
% subplot(2,1,2)
trisurf(face_bottom,vertex_m(:,1),vertex_m(:,2),vertex_m(:,3),...
    'FaceColor','blue');
grid off
hold on
trisurf(face_top,vertex_m(:,1),vertex_m(:,2),vertex_m(:,3),...
    'FaceColor','y');

% trisurf(face_patch,vertex_m(:,1),vertex_m(:,2),vertex_m(:,3),...
%     'facecolor','yellow');

axis([-2 2 -2 2 -2 2]);
% view([-160 40])
view(2)
xlabel('x');
ylabel('y');
zlabel('z');