%rotate new triangles
vn_raw=size(vertex_c,1);
facen_raw=size(face_o,1);
patch_v_num=size(vertex_m,1)-vn_raw;
patch_v_idx=vn_raw+1:size(vertex_m,1);
A_aa = triangulation2adjacency(face_m,vertex_m);
adj_list_aa = adjmatrix2list(A_aa);

[normalv_o,normalf_o]=compute_normal(vertex_m,face_o);

[normalv_aa,normalf_aa]=compute_normal(vertex_m,face_m);

nv=size(vertex_m,1);
isborder=zeros(nv,1);
isborder(v_hb_idx)=1;

%% calc geodesic distance
border_vid=v_hb_idx;
border_vid_num=length(border_vid);
N=5;
patch_v_normal=zeros(patch_v_num,3);
gd_map=zeros(nv,border_vid_num);
for j=1:border_vid_num
    vbid=border_vid(j);
    % dvvb
    %     disp(['d('  num2str(j) '):' ])
    %     tic
    gd_map=get_geodesic_dis(vbid,patch_v_idx,adj_list_aa,nv,...
        vn_raw, gd_map);
    %     toc
end

for i=1:patch_v_num
    vid=patch_v_idx(i);
    for j=1:border_vid_num
        vbid=border_vid(j);
        ni=[0 0 0];
        if gd_map(vid,vbid)>0
            ni=normalv_o(:,vbid)'*(gd_map(vid,vbid)^(-N));
        end
        patch_v_normal(i,:)=patch_v_normal(i,:)+ni;
    end
end

%% face c n
patch_face_num=size(face_patch,1);
patch_face_c=zeros(patch_face_num,3);
patch_face_normal_exp=zeros(patch_face_num,3);
for i=1:patch_face_num
    patch_face_c(i,:)=mean(vertex_m(face_patch(i,:),:));
    v1=face_patch(i,1);
    v2=face_patch(i,2);
    v3=face_patch(i,3);
    n1=patch_v_normal(patch_v_idx==v1,:);
    if isempty(n1)
        n1=normalv(:,v1)';
    end
    n2=patch_v_normal(patch_v_idx==v2,:);
    if isempty(n2)
        n2=normalv(:,v2)';
    end
    n3=patch_v_normal(patch_v_idx==v3,:);
    n1=n1/norm(n1);
    n2=n2/norm(n2);
    n3=n3/norm(n3);
    patch_face_normal_exp(i,:)=mean([n1; n2; n3;]);   
end

%% rotate and show 
figure(27);
clf;
% subplot(1,2,2)
hold off
trisurf(face_o,vertex_m(:,1),vertex_m(:,2),vertex_m(:,3),...
'facecolor','b');
hold on
grid off
vertex_rot=vertex_m;
for i=1:patch_face_num
    
    c=patch_face_c(i,:);
    n=normalf_aa(:,i+facen_raw)';
    n_exp=patch_face_normal_exp(i,:);
    
    rotate_theta=vec3theta(n,n_exp);
    rotate_axis=cross(n,n_exp);
    rotate_axis=rotate_axis/norm(rotate_axis);
    vertex_tri=vertex_m(face_patch(i,:),:);
    vl=vertex_tri-c;
    Rit=[0              -rotate_axis(3) rotate_axis(2);
        rotate_axis(3)  0               -rotate_axis(1);
        -rotate_axis(2) rotate_axis(1)  0;];
    R=eye(3)+Rit*sin(rotate_theta)+Rit*Rit*(1-cos(rotate_theta));
    
    vertex_r=vl*R'+c;        
    vertex_rot(face_patch(i,:),:)=vertex_r;
    
    tri_v=vertex_r;
    trisurf([1 2 3],tri_v(:,1),tri_v(:,2),tri_v(:,3),...
        'facecolor','r');
    
    n_exp=n_exp/norm(n_exp);
    quiver3(c(1),c(2),c(3),...
        n_exp(1)*0.2,n_exp(2)*0.2,n_exp(3)*0.2,'y','LineWidth',1);
end
axis([-2 2 -2 2 -2 2]);
% axis([-15 15 -15 15 -2 12]);
% view([-160 40])
view(2)
%  view([70 5])
% view([-160 40])
xlabel('x');
ylabel('y');
zlabel('z');

% subplot(1,2,1)
% hold off
% trisurf(face_c,vertex_m(:,1),vertex_m(:,2),vertex_m(:,3),...
% 'facecolor','b');
% hold on
% grid off
% trisurf(face_patch,vertex_m(:,1),vertex_m(:,2),vertex_m(:,3),...
%     'facecolor','y');
% 
% % axis([-2 2 -2 2 -2 2]);
% axis([-15 15 -15 15 -2 12]);
% % view([-160 40])
% % view(2)
%  view([70 5])
% % view([-160 40])
% xlabel('x');
% ylabel('y');
% zlabel('z');

