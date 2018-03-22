
%%

z_normal = u(idx,:);
theta = [1,1,1,1,1]'*[0.,0.,0.,0.,0.];
for i=1:length(u)
    for j=1:length(u)
         theta(i,j) = vec3theta(u(j,:),u(i,:));
    end
end
theta_deg = rad2deg(theta);
theta_min = min(theta(theta>theta_e));

vertex_set_1 = [];
vertex_set_2 = [];
vertex_set_3 = [];
vertex_set_4 = [];
vertex_set_5 = [];

theta_e2 = pi/4;
for i=1:tn
    theta_i = vec3theta(normals(i,:), u);
    [mt,id]=min(theta_i);
    if mt<theta_e2 && id ~= idx
        %ÇøÓò»®·Ö
        eval(['vertex_set_',num2str(id),...
            '=[','vertex_set_',num2str(id),',i];']);
    end
end

