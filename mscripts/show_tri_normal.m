function show_tri_normal(v1,v2,v3)
c=mean([v1;v2;v3]);
n=0.2*my_normalize(cross(v2-v1,v3-v1));
quiver3(c(1),c(2),c(3),...
    n(1),n(2),n(3),'y','LineWidth',1);
end