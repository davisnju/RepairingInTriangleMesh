%%
% expect surface mesh
vertex_sur=[];
face_sur=[];
nv=size(vertex_raw,1);
face_n=size(face_raw,1);
feps=0.08;
vertex_idx_t=[];
for i=1:nv
    [~,r,z]=cart2pol(vertex_raw(i,1),vertex_raw(i,2),vertex_raw(i,3));
    if float_eq(z,0,feps) || float_eq(z,10,feps)...
            || float_eq(r,5,feps)
        vertex_sur=[vertex_sur;vertex_raw(i,:)];
        vertex_idx_t=[vertex_idx_t;i];
    end
end
for t=1:face_n
    T=vertex_raw(face_raw(t,:),:);
    [~,r,z]=cart2pol(T(:,1),T(:,2),T(:,3));
    flag=0;
    for j=1:3
        if ( ~float_eq(r(j),5,feps) ) && (z(j) > 0 && z(j) < 10)
            flag=1;
            break
        end
    end
    if ~flag
        zmax=max(z);
        zmin=min(z);
        g=mean(T);
        [~,rg,~]=cart2pol(g(1),g(2),g(3));
        if float_eq(rg,5,feps)... %  side triangle
                ||...   %  top or bottom triangle
                (  float_eq(zmin,zmax,feps) ...
                && (float_eq(zmin,10,feps) || float_eq(zmin,0,feps))  )
            fi=face_raw(t,:);
            f=[find( vertex_idx_t==fi(1) ),...
                find( vertex_idx_t==fi(2) ),...
                find( vertex_idx_t==fi(3) )];
            face_sur=[face_sur;f];
        end
    end
end
% show_mesh(face_sur,vertex_sur);
%%
% expect complete result model
vertex_exp=[];
face_exp=[];
feps=1e-6;
% top and bottom vertex
vertex_idx_t=[];
for i=1:nv
    [~,~,z]=cart2pol(vertex_raw(i,1),vertex_raw(i,2),vertex_raw(i,3));
    if float_eq(z,0,feps) || float_eq(z,10,feps)
        vertex_exp=[vertex_exp;vertex_raw(i,:)];
        vertex_idx_t=[vertex_idx_t;i];
    end
end
for t=1:face_n
    T=vertex_raw(face_raw(t,:),:);
    [~,~,z]=cart2pol(T(:,1),T(:,2),T(:,3));
    if float_eq(mean(z),0,1e-6) || float_eq(mean(z),10,1e-6)
        fi=face_raw(t,:);
        f=[find( vertex_idx_t==fi(1) ),...
            find( vertex_idx_t==fi(2) ),...
            find( vertex_idx_t==fi(3) )];
        face_exp=[face_exp;f];
    end
end
L=size(vertex_exp,1);
% side vertex
r=5;h=10;BO=[0,0,0];factor=1;
[vertex_s,face_s]=create_cylinder_sample(r,h,BO,factor);
vertex_idx_t=[];
feps=0.08;
nv_s=size(vertex_s,1);
for i=1:nv_s
    [~,r,z]=cart2pol(vertex_s(i,1),vertex_s(i,2),vertex_s(i,3));
    if float_eq(r,5,feps)
        vertex_exp=[vertex_exp;vertex_s(i,:)];
        vertex_idx_t=[vertex_idx_t;i];
    end
end
face_n_s=size(face_s,1);
for t=1:face_n_s
    T=vertex_s(face_s(t,:),:);
    [~,r,z]=cart2pol(T(:,1),T(:,2),T(:,3));
    flag=0;
    for j=1:3
        if ( ~float_eq(r(j),5,feps) ) && (z(j) > 0 && z(j) < 10)
            flag=1;
            break
        end
    end
    if ~flag
        g=mean(T);
        [~,rg,~]=cart2pol(g(1),g(2),g(3))
        if float_eq(rg,5,feps)
            fi=face_s(t,:);
            f=[find( vertex_idx_t==fi(1) ),...
                find( vertex_idx_t==fi(2) ),...
                find( vertex_idx_t==fi(3) )];
            f = f+L;
            face_exp=[face_exp;f];
        end
    end
end
DT=delaunayTriangulation(vertex_exp(:,1),vertex_exp(:,2),vertex_exp(:,3));
[K,~] = convexHull(DT);
vertex_exp=DT.Points(:,:);
face_exp=K;
show_mesh(face_exp,vertex_exp);
%%
save cylinder_exp_model vertex_exp face_exp vertex_sur face_sur
