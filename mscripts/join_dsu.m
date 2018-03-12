function [uo] = join_dsu(u,x,y)
%join(u,x,y)
%u table p,r
%x
%y

if u.r(x)>u.r(y)
    u.p(y)=x;
    u.s(x) = u.s(x) + u.s(y);
else
    u.p(x)=y;
    u.s(y) = u.s(x) + u.s(y);
    if(u.r(x)==u.r(y))
        u.r(y)=u.r(y)+1;
    end
end
uo=u;
end