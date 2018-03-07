%%show labeled meshes, which label is produced by using watershed algorithm 
%
figure;
clf;
subplot(2,2,1);
options.face_vertex_color = perform_saturation(double(Lgauss),1.2);
plot_mesh(vertex,face, options); shading flat; colormap jet(256);
title('label using Gauss curvature');
subplot(2,2,2);
options.face_vertex_color = perform_saturation(double(Lmean),1.2);
plot_mesh(vertex,face, options); shading flat; colormap jet(256);
title('label using Mean curvature');
subplot(2,2,3);
options.face_vertex_color = perform_saturation(double(Lrms),1.2);
plot_mesh(vertex,face, options); shading flat; colormap jet(256);
title('label using RMS curvature');
subplot(2,2,4);
options.face_vertex_color = perform_saturation(double(Labs),1.2);
plot_mesh(vertex,face, options); shading flat; colormap jet(256);
title('label using ABS curvature');

%%
% face_n=size(face,1);
% 
% figure;
% % subplot(2,2,1)
% hold on;
% L=Lrms;
% for i=1:face_n
%     vid=face(i,:);
%     v=[vertex(vid(1),:);
%         vertex(vid(2),:);
%         vertex(vid(3),:)];
%     if 1 %L(vid(1))==L(vid(2)) && L(vid(1))==L(vid(3))
%         fill(v(:,1),v(:,2),v(:,3),'cdata',L(vid(:)));
%     else        
%     end
% end
% hold on;
% scatter3(vertex(:,1),vertex(:,2),vertex(:,3),...
%     'filled',...
%     'cdata',Lrms);
% axis([-15 15 -15 15 -5 15]);
% view(0,0);
