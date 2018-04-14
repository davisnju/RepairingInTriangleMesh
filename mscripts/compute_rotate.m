function [R]=compute_rotate(n,n_exp)
% n,n_exp nx3
rotate_theta=vec3theta(n,n_exp);
rotate_axis=cross(n,n_exp);
rotate_axis=rotate_axis/norm(rotate_axis);
Rit=[0              -rotate_axis(3) rotate_axis(2);
    rotate_axis(3)  0               -rotate_axis(1);
    -rotate_axis(2) rotate_axis(1)  0;];
R=eye(3)+Rit*sin(rotate_theta)+Rit*Rit*(1-cos(rotate_theta));

end