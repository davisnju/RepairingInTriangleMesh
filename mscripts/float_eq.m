function [r]=float_eq(a,b,e)
r=abs(a-b)<e;
r=sum(r)==length(r);
end