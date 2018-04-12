function [r]=show_patch_func(i,vertex,face,face_patch)

figure(i);
% figure(30);
% subplot(3,2,fid)
% figure(fid);
% clf;
% subplot(2,1,2)
trisurf(face,vertex(:,1),vertex(:,2),vertex(:,3),...
    'facecolor','b');

grid off
hold on
trisurf(face_patch,vertex(:,1),vertex(:,2),vertex(:,3),...
    'facecolor','y');

axis([-2 2 -2 2 -2 2]);
% axis([-15 15 -15 15 -2 12]);
% view([-160 40])
% view(2)
% view([70 5])
% view([-90 80])
view(3)
xlabel('x');
ylabel('y');
zlabel('z');
% title(['loop idx=' num2str(loop_i)])


title(['iter ' num2str(i)])
hold off

end