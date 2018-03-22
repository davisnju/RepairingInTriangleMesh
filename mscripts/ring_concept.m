x=[3.597 4.476 4.242 2.945  1.569 0.3528 1.099 2.293];
y=[4.161 3.197 2.308 0.5468 1.427 2.863  4.042 4.215];
o=[3.08 2.584];

figure(1);
hold off;
clear S
S.Vertices = [o;x' y';];
S.Faces = [1 2 3; 1 3 4; 1 4 5;1 5 6; 1 6 7; 1 7 8;1 8 9;1 9 2];
S.FaceVertexCData = [1; 1;1;1; 1;1;1;1];
S.FaceColor = 'flat';
S.EdgeColor = 'none';
patch(S)
hold on;
plot(o(1),o(2),'o',...    
    'MarkerSize',10,...
    'MarkerEdgeColor','b',...
    'MarkerFaceColor',[0.5,0.5,0.5])
axis([0 7 0 5]);
hold on;
plot(x,y,'o',...    
    'MarkerSize',10,...
    'MarkerEdgeColor','r',...
    'MarkerFaceColor',[0.5,0.5,0.5])

for i=1:8
    plot([o(1) x(i)],[o(2) y(i)],'--b') ;
end

for i=1:7
    plot([x(i+1) x(i)],[y(i+1) y(i)],'-b') ;
end
    plot([x(1) x(8)],[y(1) y(8)],'-b') ;
    
plot(5.25,4,'o',...    
    'MarkerSize',10,...
    'MarkerEdgeColor','r',...
    'MarkerFaceColor',[0.5,0.5,0.5])

plot([5 5.5],[3.5 3.5],'--b')

l=[5 2.7; 5.25 3.215;5.5 2.7];
clear S
S.Vertices = l;
S.Faces = [1 2 3];
S.FaceVertexCData = [1];
S.FaceColor = 'flat';
S.EdgeColor = 'b';
S.LineWidth=1;
patch(S)
    