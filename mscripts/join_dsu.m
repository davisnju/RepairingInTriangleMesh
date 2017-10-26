function join_dsu(u,x,y)
%join(u,x,y)
%u table p,r
%x
%y

global ds_u;

if u.r(x)>u.r(y)
    ds_u.p(y)=x;
else
    ds_u.p(x)=y;
    if(u.r(x)==u.r(y))
        ds_u.r(y)=u.r(y)+1;
    end
end

end