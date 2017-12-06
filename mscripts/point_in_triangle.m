function [r,u,v]=point_in_triangle(X,A,B,C)
%三维坐标系中点x是否在三角形ABC中，包括在边上
%输入确保四点共面
% AX=uAC+vAB;

% float_eq_epcilon=0.000001;
% if float_eq(X,A,float_eq_epcilon) || float_eq(X,B,float_eq_epcilon)...
%    || float_eq(X,C,float_eq_epcilon)...
%    ||points_in_line(A,X,B)||points_in_line(B,X,C)||points_in_line(A,X,C)
%     r=1;
%     return
% end
v0 = C-A;
v1 = B-A; 
v2 = X-A;
dot00=v0*v0';
dot01=v0*v1';
dot02=v0*v2';
dot11=v1*v1';
dot12=v1*v2';
inverDeno = 1 / (dot00 * dot11 - dot01 * dot01) ;
u = (dot11 * dot02 - dot01 * dot12) * inverDeno ;
v = (dot00 * dot12 - dot01 * dot02) * inverDeno ;
    if (u < 0 || u > 1) 
        r=0;
        return
    end
    if (v < 0 || v > 1) 
        r=0;
        return
    end
    
    r = (u + v) <= 1 ;

end