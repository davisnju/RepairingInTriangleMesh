%model curvature analysis
faces=face;
[normalv,normalf]=compute_normal(vertex,faces);
%%

figure;
quiver3(vertex(:,1),vertex(:,2),vertex(:,3),normalv(1,:)',normalv(2,:)',normalv(3,:)');
hold on;
trisurf(face,vertex(:,1),vertex(:,2),vertex(:,3));
axis([-15 15 -15 15 -5 15]);
view(0,0);


%%
name='cylinder';
clear options;
options.name = name; % useful for displaying
% compute the curvature
options.curvature_smoothing = 2;
options.verb = 0;
[Umin,Umax,Cmin,Cmax,Cmean,Cgauss,Normal] = compute_curvature(vertex,faces,options);
% display
figure;
clf;
subplot(1,2,1);
options.face_vertex_color = perform_saturation(Cgauss,1.2);
plot_mesh(vertex,faces, options); shading interp; colormap jet(256);
title('Gaussian curvature');
subplot(1,2,2);
options.face_vertex_color = perform_saturation(abs(Cmin)+abs(Cmax),1.2);
plot_mesh(vertex,faces, options); shading interp; colormap jet(256);
title('Total curvature');
%
figure;
clear options;
options.name = name; % useful for displaying
clf;
subplot(2,2,1);
plot_mesh(vertex,faces,options); shading interp; axis tight;
hold on;
q=quiver3(vertex(:,1),vertex(:,2),vertex(:,3),Umin(1,:)',Umin(2,:)',Umin(3,:)');
q.Color='b';
q.ShowArrowHead='off';

q=quiver3(vertex(:,1),vertex(:,2),vertex(:,3),Umax(1,:)',Umax(2,:)',Umax(3,:)');
q.Color='r';
q.ShowArrowHead='off';

subplot(2,2,2)
plot_mesh(vertex,faces,options); shading interp; axis tight;
hold on;
q=quiver3(vertex(:,1),vertex(:,2),vertex(:,3),Umin(1,:)',Umin(2,:)',Umin(3,:)');
q.Color='b';
q.ShowArrowHead='off';
title('min direction of curvature')
subplot(2,2,4)
plot_mesh(vertex,faces,options); shading interp; axis tight;
hold on;
q=quiver3(vertex(:,1),vertex(:,2),vertex(:,3),Umax(1,:)',Umax(2,:)',Umax(3,:)');
q.Color='r';
q.ShowArrowHead='off';
title('max direction of curvature')


%%
face_n=size(faces,1);
nv=size(vertex,1);

theta_sharp=0.5;
phi_corner=0.7;
n_m0=zeros(1,3);
n_m1=zeros(1,3);
angle_max=0;
mintheta=ones(nv,1).*-1;
maxphi=zeros(nv,1);
 for i=1:face_n
    v1=faces(i,1);
    v2=faces(i,2);
    v3=faces(i,3);
    n1=normalv(:,v1);
    n2=normalv(:,v2);
    n3=normalv(:,v3);
%     nf=normalf(:,i);
    dot12=n1'*n2;
    dot23=n3'*n2;
    dot31=n1'*n3;
    a12=myangle(n1,n2);
    a23=myangle(n2,n3);
    a31=myangle(n3,n1);
    [angle_max, idx]=max([angle_max a12 a23 a31]);
    switch(idx)            
        case 2
            n_m0=n1;n_m1=n2; 
        case 3
            n_m0=n2;n_m1=n3; 
        case 4
            n_m0=n3;n_m1=n1;             
        otherwise
            
    end
    if mintheta(v1)<0
        mintheta(v1)=min([dot12,dot31]);
    else
        mintheta(v1)=min([mintheta(v1),dot12,dot31]); 
    end
    if mintheta(v2)<0
        mintheta(v2)=min([dot12,dot23]);
    else
        mintheta(v2)=min([mintheta(v2),dot12,dot23]); 
    end
    if mintheta(v3)<0
        mintheta(v3)=min([dot31,dot23]);
    else
        mintheta(v3)=min([mintheta(v3),dot31,dot23]); 
    end
 end
 
 n_star=cross(n_m0,n_m1);
 
 for i=1:1
    
     maxphi(v1)=1
 end
 
%%
figure(11);
clf;
hold on;
grid on;
for i=1:face_n
    v1=faces(i,1);
    v2=faces(i,2);
    v3=faces(i,3);
    vs=[vertex(v1,:);
        vertex(v2,:);
        vertex(v3,:)];
    
    plot3tr(vs(:,1), vs(:,2),vs(:,3),'g-');
    if mintheta(v1)<theta_sharp
        if maxphi(v1)>phi_corner
            s='m*';
        else
            s='b*';
        end
        scatter3(vs(1,1), vs(1,2),vs(1,3),s);
    end
    if mintheta(v2)<theta_sharp
        if maxphi(v2)>phi_corner
            s='m*';
        else
            s='b*';
        end
        scatter3(vs(2,1), vs(2,2),vs(2,3),s);
    end
    if mintheta(v3)<theta_sharp
        if maxphi(v3)>phi_corner
            s='m*';
        else
            s='b*';
        end
        scatter3(vs(3,1), vs(3,2),vs(3,3),s);
    end
end

% %%
% face_n=size(faces,1);
% avgTheta=zeros(face_n,1);
% for i=1:face_n
%     n1=normalv(:,faces(i,1));
%     n2=normalv(:,faces(i,2));
%     n3=normalv(:,faces(i,3));
%     nf=normalf(:,i);
%     avgTheta(i)=mean([vec3theta(nf',n1') vec3theta(nf',n2') vec3theta(nf',n3') ]);
% end
% avgThetaThred=quantile(avgTheta,0.9);
% targetFaceIdx=find(avgTheta<=avgThetaThred);
% figure(10);
% clf;
% hold on;
% grid on;
% for i=1:face_n    
%     vs=[vertex(faces(i,1),:);
%        vertex(faces(i,2),:);
%        vertex(faces(i,3),:)];
%        
%     if find(targetFaceIdx==i)        
%             s='g-';
%     else
%             s='r*';
%     end
%     plot3tr(vs(:,1), vs(:,2),vs(:,3),s);
% end

%==========================================================================
% %%
% %vertex=vertex_set; faces=tpis(model_tp_k,:);
% 
% [normalv,normalf]=compute_normal(vertex,faces);
% avgTheta=zeros(tn2,1);
% for i=1:tn2
%     n1=normalv(:,tpis(i,1));
%     n2=normalv(:,tpis(i,2));
%     n3=normalv(:,tpis(i,3));
%     nf=normalf(:,i);
%     avgTheta(i)=mean([vec3theta(nf',n1') vec3theta(nf',n2') vec3theta(nf',n3') ]);
% end
% avgThetaThred=0.7;%quantile(avgTheta,0.9);
% targetFaceIdx=find(avgTheta<=avgThetaThred);
% figure(10);
% clf;
% hold on;
% grid on;
% for i=1:tn2    
%     vs=[vertex_set(tpis(i,1),:);
%        vertex_set(tpis(i,2),:);
%        vertex_set(tpis(i,3),:)];
%        
%     if find(targetFaceIdx==i)        
%             s='g-';
%     else
%             s='r.';
%     end
%     plot3tr(vs(:,1), vs(:,2),vs(:,3),s);
% end
% %%
% clear options
% options.curvature_smoothing = 10;
% options.verb = 0;
% [Umin,Umax,Cmin,Cmax,Cmean,Cgauss,Normalv] = compute_curvature(vertex,faces,options);
% figure(11);
% clf;
% hold on;
% grid on;
% grp_num=0;
% for i=1:tn2    
%     vs=[vertex_set(tpis(i,1),:);
%        vertex_set(tpis(i,2),:);
%        vertex_set(tpis(i,3),:)];
%     
%     plot3tr(vs(:,1), vs(:,2),vs(:,3),'g-');
%     
%     for j=1:3
%             if Cgauss(tpis(i,j))>0.15
%                    plot3(vs(j,1),vs(j,2),vs(j,3),'r.');
%                    grp_num=grp_num+1;
%             end
%     end
% end
% title(['gauss ridge point num=' num2str(grp_num)]);
% 
% figure(12);
% clf;
% hold on;
% grid on;
% mrp_num=0;
% for i=1:tn2    
%     vs=[vertex_set(tpis(i,1),:);
%        vertex_set(tpis(i,2),:);
%        vertex_set(tpis(i,3),:)];
%     
%     plot3tr(vs(:,1), vs(:,2),vs(:,3),'g-');
%     
%     for j=1:3
%             if Cmean(tpis(i,j))>0.7
%                    plot3(vs(j,1),vs(j,2),vs(j,3),'r.');
%                    mrp_num=mrp_num+1;
%             end
%     end
% end
% title(['mean ridge point num=' num2str(mrp_num)]);
% 
% %%
% % load the mesh
% name = 'bunny.ply';
% 
% clear options
% 
% options.name = name; % useful for displaying
% 
% % [vertex,faces] = read_mesh(name);
% vertex=vertex_set; faces=tpis(model_tp_k,:);
% %
% [normal,normalf] = compute_normal(vertex,faces);
% % display
% options.normal = normal;
% clf; plot_mesh(vertex,faces,options); shading interp;  axis tight;
% options.normal = [];
% %%
% % compute the curvature
% 
% clear options
% 
% options.name = name; % useful for displaying
% options.curvature_smoothing = 10;
% options.verb = 0;
% [Umin,Umax,Cmin,Cmax,Cmean,Cgauss,Normal] = compute_curvature(vertex,faces,options);
% % display
% clf;
% subplot(1,2,1);
% options.face_vertex_color = perform_saturation(Cgauss,1.2);
% plot_mesh(vertex,faces, options); shading interp; colormap jet(256);
% title('Gaussian curvature');
% subplot(1,2,2);
% options.face_vertex_color = perform_saturation(abs(Cmin)+abs(Cmax),1.2);
% plot_mesh(vertex,faces, options); shading interp; colormap jet(256);
% title('Total curvature');
% 
% %%
% % load a mesh
% name = 'bunny.ply';
% clear options
% options.name = name; % useful for displaying
% [vertex,faces] = read_mesh(name);
% % compute normal per vertex and per face
% [normal,normalf] = compute_normal(vertex,faces);
% % display
% options.normal = normal;
% clf; plot_mesh(vertex,faces,options); shading interp; axis tight;
% options.normal = [];
% 
% %%
% clear options
% normals = compute_normal(vertex,faces);
% laplacian_type = 'distance';
% options.symmetrize = 0;
% options.normalize = 1; % it must be normalized for filtering
% options.verb = 0;
% W = compute_mesh_weight(vertex,faces,laplacian_type,options);
% % This is the corresponding laplacian
% L = compute_mesh_laplacian(vertex,faces,laplacian_type,options);
% vertex2 = vertex;
% clf;
% options.face_vertex_color = [];
% for i=1:6
%     subplot(2,3,i);
%     plot_mesh(vertex2,faces,options); axis tight; shading interp;
%     vertex2 = (W*(W*vertex2'))';
% end
% 
% %%
% % load a mesh
% name = 'mushroom';
% clear options
% options.name = name; % useful for displaying
% [vertex,faces] = read_mesh(name);
% % compute normal per vertex and per face
% [normal,normalf] = compute_normal(vertex,faces);
% % display
% options.normal = normal;
% clf; plot_mesh(vertex,faces,options); shading interp; axis tight;
% options.normal = [];
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function beta = myangle(u,v)
% beta vary [0,2*pi)
du = sqrt( sum(u.^2) );
dv = sqrt( sum(v.^2) );
du = max(du,eps); dv = max(dv,eps);
beta = acos( sum(u.*v) / (du*dv) );
end