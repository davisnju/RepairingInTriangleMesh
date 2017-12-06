function id=find_in_universe(u,x)
%find_in_universe(u,x,y)
%u table p,r
%x

global ds_u;

y=x;
while(y ~= u.p(y))
    y=u.p(y);
end
ds_u.p(x)=y;
id=y;
end