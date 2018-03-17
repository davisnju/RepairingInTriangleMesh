function beta = vec3ang_with_dir(u,v,n)

% beta vary [0,2*pi]
beta=vec3theta(u,v);

% judge direction
if vec3theta(cross(u,v),n)>pi/2
    beta=2*pi-beta;
end

end