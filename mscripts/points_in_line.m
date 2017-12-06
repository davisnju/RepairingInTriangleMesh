function [r]=points_in_line(A,B,C)

AB=B-A;
BC=C-B;

r=acos(AB*BC/(norm(AB)*norm(BC)))>=0.999999;

end