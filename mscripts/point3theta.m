function [a]=point3theta(A,B,C)

BA=A-B;
BC=C-B;

a=vec3theta(BA,BC);

end