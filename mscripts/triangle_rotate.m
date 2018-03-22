%triangle rotate
vertex=[1 0 0;2 2 0;0 1 0;];
face=[1 2 3];
n=[0 0 1];

n_exp=[1 1 1];
n_exp=n_exp/norm(n_exp);
c=mean(vertex);

rotate_theta=vec3theta(n,n_exp);
rotate_axis=cross(n,n_exp);
rotate_axis=rotate_axis/norm(rotate_axis);
vl=vertex-c;
Rit=[0              -rotate_axis(3) rotate_axis(2);
    rotate_axis(3)  0               -rotate_axis(1);
    -rotate_axis(2) rotate_axis(1)  0;];
R=eye(3)+Rit*sin(rotate_theta)+Rit*Rit*(1-cos(rotate_theta));

vertex_r=vl*R'+c;

figure(1);
grid off
trisurf(face,vertex(:,1),vertex(:,2),vertex(:,3),'FaceColor','green');
hold on;
axis([-1 3 -1 3 -2 2]);
quiver3(c(1),c(2),c(3),n(1),n(2),n(3),'g');
quiver3(c(1),c(2),c(3),n_exp(1),n_exp(2),n_exp(3),'r');
scatter3(c(1),c(2),c(3),'bo','filled')
trisurf(face,vertex_r(:,1),vertex_r(:,2),vertex_r(:,3),'FaceColor','red');

xlabel('x');
ylabel('y');
zlabel('z');