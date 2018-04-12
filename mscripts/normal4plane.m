function n = normal4plane(a,b,c)
v1=b-a;
v2=c-a;
n=cross(v1,v2);
if sum(abs(n))>0
    n=n/norm(n);
else
    n=[0 0 0];
end
end