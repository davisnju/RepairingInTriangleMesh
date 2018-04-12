%test 32 
% one ball one hole
clear;clc;
load ball_mesh300.mat
z_max=max(vertex(:,3));
z_min=min(vertex(:,3));
z_th=z_min+0.99*(z_max-z_min);  %% 84

fn=size(face,1);
face_bottom=[];
face_top=[];
BottomFace_idx=[];
nv=size(vertex,1);
ol=zeros(nv,1); %on surface

for i=1:fn
    if ~(vertex(face(i,1),3)>z_th || vertex(face(i,2),3)>z_th ...
            || vertex(face(i,3),3)>z_th)
        face_bottom=[face_bottom;face(i,:)]; 
        BottomFace_idx=[BottomFace_idx;i];
        ol(face(i,:))=1;
    else
        face_top=[face_top;face(i,:)]; 
    end
end
%
figure(2);
hold off;
grid off
trisurf(face_bottom,vertex(:,1),vertex(:,2),vertex(:,3));
% ,'FaceColor','blue'
axis([-1.5 1.5 -1.5 1.5 -1.5 1.5]);
face=face_bottom;
%% preprocess before repair
vertex_c=vertex;
face_c=face;
outer_surface=face_c;
nv=size(vertex,1);
ol=zeros(nv,1);
idx=unique(face(:));
ol(idx)=1;

A = triangulation2adjacency(face,vertex);
adj_list = adjmatrix2list(A);



%% post process
% border_idx=v_hb_idx;
% nvert=size(vertex_m,1);
% 
% v_idx_need_adjust=patch_v_idx;
% vertex_patch=vertex_m;
% 
% is_cur_border=zeros(nvert,1);
% 
% is_cur_border(border_idx)=1;
% patch_face_with_border=[];
% v_adjust=[];
% for i=1:patch_face_num
%     icb=is_cur_border(face_patch(i,:));
%     if sum(icb)==2
%         patch_face_with_border=[patch_face_with_border;i];
%         vid=face_patch(i,icb==0);
%         v_adjust=[v_adjust;vid];
%     end
% end
% nv_adjust=length(v_adjust);
% for i=1:nv_adjust
%     face_i=patch_face_with_border(i,:);
%     vaj=;
%     vertex_patch(v_adjust,:)=vaj;
% end

%%
% write_ply(vertex_m,face_patch,'res\bunny_repaired.ply');
border_vertex=vertex_m(border_vid{5},:);