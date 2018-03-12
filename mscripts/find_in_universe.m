function [id,uo]=find_in_universe(u,x)
%find_in_universe(u,x,y)
%u table p,r
%x

y=x;
while(y ~= u.p(y))
    y=u.p(y);
end
u.p(x)=y;
uo=u;
id=y;
end