function [out]=distance2plane(X,P)
%X m-by-3
%P [p00,p10,p01]  p00+p10*x+p01*y-z=0

out = abs(X*[P(2),P(3),-1]'+P(1))./sqrt(P(2)^2+P(3)^2+1);
end