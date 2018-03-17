function beta = vec3theta(u,v)
% c = a*b'/(norm(a)*norm(b));
% if c>1
%     c=1;
% elseif c<-1
%     c=-1;
% end
% beta = acos(c);

% beta vary [0,pi]
du = sqrt( sum(u.^2) );
dv = sqrt( sum(v.^2) );
du = max(du,eps); dv = max(dv,eps);
beta = acos( sum(u.*v) / (du*dv) );
end