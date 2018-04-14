function [area,L]=area_tri(A,B,C)
a=norm(A-B);
b=norm(B-C);
c=norm(A-C);
L=a+b+c;
d=L/2; 
area=sqrt(d*(d-a)*(d-b)*(d-c));
end