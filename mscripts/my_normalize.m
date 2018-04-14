function [n]=my_normalize(a)
d=norm(a);d=max([d eps]);
n=a/d;
end