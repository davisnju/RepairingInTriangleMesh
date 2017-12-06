function out = find_in_tp_u(u,edge,v)
global tp_ds_u;


y=x;
while(y ~= u.p(y))
    y=u.p(y);
end
ds_u.p(x)=y;
id=y;

end