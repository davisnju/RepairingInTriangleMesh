% clear;
% clc;
% addpath(genpath('./toolbox'));
% load('m201803122238.mat');
create_ballsurface_sample
preprocess
%% repair hole
adj_list_t=adj_list;
vertex_m=vertex_c;
vm_idx=find(ol);
vm_n=size(vm_idx,1);
face_m=outer_surface(:,:);
nvm=size(vertex_m,1);
[normalv,normalf]=compute_normal(vertex_c,face_c);
[normalv_m,normalf_m]=compute_normal(vertex_m,face_m);

% Hole Boundary Identification
v_hb_idx=[];   % border vertex
v_hb_midx=[];   % border vertex

A_m = triangulation2adjacency(face_m,vertex_m);
adj_list_m = adjmatrix2list(A_m);

for i=1:vm_n
    %     if length(adj_list{vm_idx(i)})>length(adj_list_m{i})
    nn=length(adj_list_m{vm_idx(i)});
    if nn>0
        neighbor_face_idx=[find(face_m(:,1)==vm_idx(i));...
            find(face_m(:,2)==vm_idx(i));
            find(face_m(:,3)==vm_idx(i))];
        neighbor_face_num=length(neighbor_face_idx);
        if neighbor_face_num ~= nn
            %     if find(ol(adj_list{vm_idx(i)})==0)
            v_hb_idx=[v_hb_idx;vm_idx(i)];
            v_hb_midx=[v_hb_midx;i];
        end
    end
end


isborder=zeros(nv,1);
isborder(v_hb_idx)=1;
isborder_raw=isborder;
v_hb_num=length(v_hb_idx);

% v_hb_idx_2=v_hb_idx;
e_hb=[];  % border edge
for i=1:v_hb_num
    nb_idx=find_border_neighbor(v_hb_idx(i),adj_list_m,isborder);
    nb_idx_t=[];
    if length(nb_idx)>2
        for j=1:length(nb_idx)
            nb_idx2=find_border_neighbor(nb_idx(j),adj_list_m,isborder);
            if length(nb_idx2)==2
                nb_idx_t=[nb_idx_t;nb_idx(j)];
            end
        end
    else
        nb_idx_t=nb_idx';
    end
    edges=[(ones(size(nb_idx_t))*v_hb_idx(i)), nb_idx_t];
    e_hb=push_back_to_edge_set( e_hb, edges );
end
eb_n=size(e_hb,1);
% border facet
face_border_idx=[];
face_num=size(face_m,1);

for i=1:face_num
    if max(isborder(face_m(i,:)))
        face_border_idx=[face_border_idx;i];
    end
end
face_border_num=size(face_border_idx,1);
vertex_adj_face=cell(nv,1);
for i=1:face_border_num
    fi=face_border_idx(i);
    v1=face_m(fi,1);
    v2=face_m(fi,2);
    v3=face_m(fi,3);
    vertex_adj_face{v1}=[vertex_adj_face{v1};fi];
    vertex_adj_face{v2}=[vertex_adj_face{v2};fi];
    vertex_adj_face{v3}=[vertex_adj_face{v3};fi];
end

% hole segmentation
hv_u=table([1:nv]',zeros(nv,1),ones(nv,1));%[p,r,s]
hv_u.Properties.VariableNames = {'p','r','s'};
hv_u_size=nv;
neb=size(e_hb,1);
for i=1:neb
    edge_i=e_hb(i,:);
    [a,hv_u]=find_in_universe(hv_u,edge_i(1));
    [b,hv_u]=find_in_universe(hv_u,edge_i(2));
    if a~=b
        [hv_u]=join_dsu(hv_u,a,b);
        hv_u_size=hv_u_size-1;
    end
end
for i=1:neb
    edge_i=e_hb(i,:);
    [a,hv_u]=find_in_universe(hv_u,edge_i(1));
    [b,hv_u]=find_in_universe(hv_u,edge_i(2));
end
border_l=unique(hv_u.p(v_hb_idx));
border_num=length(border_l);
hv_u_matrix=[hv_u.p hv_u.r hv_u.s];
% calculate border edge info
edge_length=zeros(neb,1);
for i=1:neb
    edge_i=e_hb(i,:);
    edge_length=norm(vertex_m(edge_i(1),:)-vertex_m(edge_i(2),:));
end
edge_len_mean=mean(edge_length);

% adapt direction for edge
for i=1:neb
    e=e_hb(i,:);
    nb_idx1=find_nonborder_neighbor(e(1),adj_list_m,isborder);
    nb_idx2=find_nonborder_neighbor(e(2),adj_list_m,isborder);
    veop=intersect(nb_idx1,nb_idx2);
    if isempty(veop)
        nb_idx1=find_border_neighbor(e(1),adj_list_m,isborder);
        nb_idx2=find_border_neighbor(e(2),adj_list_m,isborder);
        veop=intersect(nb_idx1,nb_idx2);
    end
    face_cand=face_m([find(face_m(:,1)==e(1));...
        find(face_m(:,2)==e(1));
        find(face_m(:,3)==e(1))],:);
    face_cand=face_cand([find(face_cand(:,1)==e(2));...
        find(face_cand(:,2)==e(2));
        find(face_cand(:,3)==e(2))],:);
    face_cand=face_cand([find(face_cand(:,1)==veop);...
        find(face_cand(:,2)==veop);
        find(face_cand(:,3)==veop)],:);
    n=normal4plane(vertex_m(face_cand(1,1),:),...
        vertex_m(face_cand(1,2),:),vertex_m(face_cand(1,3),:));
    flip=n*normal4plane(vertex_m(e(1),:),vertex_m(e(2),:),...
        vertex_m(veop,:))'>0;
    if flip
        e_hb(i,:)=[e(2) e(1)];
    end
end

%% organization of border
border_vid=cell(border_num,1);
for i=1:border_num
    bli=border_l(i);
    v_bli=find(hv_u.p==bli);
    e_bli=e_hb(hv_u.p(e_hb(:,1))==bli,:);
    
    queueE=e_bli;
    e=queueE(1,:);
    queueE(1,:)=[];
    listE=e;
    while ~isempty(queueE)
        idx=find(queueE(:,1)==e(2));
        e2list=queueE(idx,:);
        if isempty(e2list)
            %check border
            if listE(1,1) ~= listE(end,2)
                disp('err 0');
                break;
            else
                bv=listE(:,1);
            end
        else
            e2=e2list(1,:);
            e=e2;
            if length(idx)==1
                queueE(idx,:)=[];
            end
            listE=[listE;e];
            if isempty(queueE)
                %check border
                if listE(1,1) ~= listE(end,2)
                    disp('err 0');
                else
                    bv=listE(:,1);
                end
                break;
            end
        end
    end
    
    border_vid{i}=bv;
end
%% the advancing front mesh generation
%
clc
figure(25)
clf;
show_patch

face_patch=[];
vertex_patch=[];

front_idx=v_hb_idx;
theta_thred1=deg2rad(75);
theta_thred2=deg2rad(135);
alpha=1;   %% param
point_merge_th_factor=0.4;
rotate_face=0;
front_size=size(front_idx,1);
loop_i=1;
while front_size>0
    % for loop_i=1:26
%     for loop_i=1:100
    % for loop_i=1:84
    % for loop_i=1:1
    loop
    
    front_size=0;
    for i=1:border_num
        front_size=front_size+length(border_vid{i});
    end
    loop_i=loop_i+1;
end % while(1)
show_patch
%%
% figure(25)
% hold off
% trisurf(face_m,vertex_m(:,1),vertex_m(:,2),vertex_m(:,3));
% view(3)
% hold on;
% show_patch
%% show Hole Boundary
figure(23);
hold off
trisurf(face_m,vertex_m(:,1),vertex_m(:,2),vertex_m(:,3));
axis([-2 2 -2 2 -2 2]);
grid off
view(3)
hold on;
color=['g','r','b','y','m','c','w','k'];
border_num=length(border_l);
for i=1:border_num
    bli=border_l(i);
    v_bli=find(hv_u.p==bli);
    e_bli=e_hb(hv_u.p(e_hb(:,1))==bli,:);
    e_bli_n=size(e_bli,1);
    for j=1:e_bli_n
        X=[vertex_m(e_bli(j,1),1);
            vertex_m(e_bli(j,2),1);];
        Y=[vertex_m(e_bli(j,1),2);
            vertex_m(e_bli(j,2),2);];
        Z=[vertex_m(e_bli(j,1),3);
            vertex_m(e_bli(j,2),3);];
        plot3(X,Y,Z,color(mod(find(border_l==bli),8)+1));
        scatter3(X,Y,Z,color(mod(find(border_l==bli),8)+1),'filled');
    end
end

X=vertex_m(isborder==1,1);
Y=vertex_m(isborder==1,2);
Z=vertex_m(isborder==1,3);
scatter3(X,Y,Z,color(mod(find(border_l==bli),8)+1),'filled');


