function ret = vec3theta(a,b)
c = a*b'/(norm(a)*norm(b));
if c>1
    c=1;
elseif c<-1
    c=-1;
end
ret = acos(c);
end