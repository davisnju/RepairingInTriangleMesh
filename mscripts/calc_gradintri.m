function [grad,delta_phi]=calc_gradintri(v,A,B,C,coord)
% v A B C 1x3
x=[A(coord) B(coord) C(coord)]; % 1x3
area=area_tri(A,B,C);
n=normal4plane(A,B,C);
factor=area*0.5;
x=x*factor;

delta_phi=zeros(3,3);% 3x3

dv=v-A;
if sum(abs(dv))==0
    delta_phi(:,1)=[0;0;0];
else
    rotate_axis=cross(dv,n);
    rotate_axis=rotate_axis/norm(rotate_axis);
    h = makehgtform('axisrotate',rotate_axis,pi/2);
    dv = h(1:3,1:3)*dv(:);
    delta_phi(:,1)=dv;
end
dv=v-B;
if sum(abs(dv))==0
    delta_phi(:,2)=[0;0;0];
else
    rotate_axis=cross(dv,n);
    rotate_axis=rotate_axis/norm(rotate_axis);
    h = makehgtform('axisrotate',rotate_axis,pi/2);
    dv = h(1:3,1:3)*dv(:);
    delta_phi(:,2)=dv;
end
dv=v-C;
if sum(abs(dv))==0
    delta_phi(:,3)=[0;0;0];
else
    rotate_axis=cross(dv,n);
    rotate_axis=rotate_axis/norm(rotate_axis);
    h = makehgtform('axisrotate',rotate_axis,pi/2);
    dv = h(1:3,1:3)*dv(:);
    delta_phi(:,3)=dv;
end
grad=sum([delta_phi(1,:)*x(1);delta_phi(2,:)*x(2);delta_phi(3,:)*x(3)],2);% 3x1
end