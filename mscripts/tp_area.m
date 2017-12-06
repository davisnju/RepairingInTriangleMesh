function [area]=tp_area(A,B,C)
a=sqrt(sum((B-C).^2));
b=sqrt(sum((A-C).^2));
c=sqrt(sum((A-B).^2));
s=(a+b+c)/2;
area=sqrt(s*(s-a)*(s-b)*(s-c));
end