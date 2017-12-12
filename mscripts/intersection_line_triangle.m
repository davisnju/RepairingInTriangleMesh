function [r,p]=intersection_line_triangle(q,r,tr)
%Line equation
%q+lambda*r
%   q,r:3-by-1 vector
%triangle 3-by-3

A=tr(1,:);
B=tr(2,:);
C=tr(3,:);

AB=B-A;
BC=C-B;
n=cross(AB,BC);
n=n/norm(n);
%then ABC planar equation is X.*n=d
%X.*n=d=A.*n
% P=q+lambda*r;
% A.*n=P.*n=(q+lambda*r).*n=q.*n+lambda*r.*n
% lambda=(A-q).*n/(r.*n);
p=q+((A-q).*n/(r.*n))*r;
r=point_in_triangle(p,A,B,C);

end