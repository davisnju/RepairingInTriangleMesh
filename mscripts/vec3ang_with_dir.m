function beta = vec3ang_with_dir(u,v,n)

% beta vary [0,pi]
beta=vec3theta(u,v);

% judge direction
% if vec3theta(cross(u,v),n)>pi/2
if cross(u,v)*n'<0
    beta=2*pi-beta;
end

end