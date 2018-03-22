%Voronoi2Delaunay

x = gallery('uniformdata',[1 20],0);
y = gallery('uniformdata',[1 20],1);
figure;
hold on

voronoi(x,y,'r--')
set(gca,'XTickLabel','','YTickLabel','');
tri = delaunay(x,y);
triplot(tri,x,y,'b');
plot(x(tri), y(tri), 'ro', ...
    'MarkerSize',5,...
    'MarkerEdgeColor','b',...
    'MarkerFaceColor','b');