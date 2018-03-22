% hole_plane
b=0.3;a=0.7;
k=50;
r=5.5;
rk=r*0.9*(rand(1,k)*a+b);
seta=2*pi*rand(1,k);
x=rk.*cos(seta);
y=rk.*sin(seta);
outerprofile =[x' y'];
rk=r;
k=10;
seta=2*pi*rand(1,k);
x=rk.*cos(seta);
y=rk.*sin(seta);
outerprofile =[outerprofile;x' y';];
r=0.5;
k=20;
rk=r*0.9*(rand(1,k)*a+b);
seta=2*pi*rand(1,k);
x=rk.*cos(seta);
y=rk.*sin(seta);
innerprofile  =[x' y'];
rk=r;
k=10;
seta=2*pi*rand(1,k);
x=rk.*cos(seta);
y=rk.*sin(seta);
innerprofile  =[outerprofile;x' y';];

profile = [outerprofile; innerprofile];
%%
DT = delaunayTriangulation(profile);
fe = freeBoundary(DT)';
figure(1);
subplot(1,2,1)
hold off;
triplot(DT);
hold on;
plot(profile(fe,1),profile(fe,2),'-r','LineWidth',2) ; 
% hold off;
% axis([-2 2 -2 2]);
axis equal  
% vertex=DT.Points;
% face=DT.ConnectivityList(:, :);
% fn=size(face,1);
% inside=ones(fn,1);
% ti = vertexAttachments(DT,64);
% inside(ti{1})=0;
% ti = vertexAttachments(DT,67);
% inside(ti{1})=0;
% ti = vertexAttachments(DT,61);
% inside(ti{1})=0;
% ti = vertexAttachments(DT,70);
% inside(ti{1})=0;
% 
% subplot(1,2,2)
% hold off
% triplot(face(inside==1, :),vertex(:,1),vertex(:,2))  
% axis equal  
% 
% fn=size(face,1);
% E = edges(DT);
% BE=[];
% en=size(E,1);
% for i=1:en
%     ti = edgeAttachments(DT,E(i,1),E(i,2));
%     if length(ti{1})==2 && sum(inside(ti{1})) == 1
%         BE=[BE;E(i,:)];
%     end
% end
% hold on
% 
% plot(profile(fe,1),profile(fe,2),'-r','LineWidth',2) ; 
% 
% % plot(DT.Points(BE',1),DT.Points(BE',2), '-r','LineWidth', 2)
% 
% 
% 
% % axis([-1 2 -1 2]);
% % set(gca,'XTickLabel','','YTickLabel','');
% % tri = delaunay(x,y);
% % triplot(tri,x,y,'b');
% % plot(x(tri), y(tri), 'ro', ...
% %     'MarkerSize',5,...
% %     'MarkerEdgeColor','b',...
% %     'MarkerFaceColor','b');
% % vertex=[x' y' zeros(size(x,2),1)];
% 
% %% show Hole Boundary
% figure;
% hold off
% trisurf(face,vertex(:,1),vertex(:,2),vertex(:,3));
% % triplot(DT);
% hold on;
% plot(x(fe),y(fe),'-r','LineWidth',1.2) ; 
% hold off;
% axis([-15 15 -15 15 -5 15]);
% grid off
