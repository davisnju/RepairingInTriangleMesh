function beta = angplane(u,v)

% beta vary [0,pi/2]
beta=vec3theta(u,v);
if beta > pi/2
    beta=pi-beta;
end
end